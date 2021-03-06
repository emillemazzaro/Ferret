	SUBROUTINE XEQ_LOAD

*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
*
*
* execute the LOAD command

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 9/4/87
* revision 0.1 - 9/16/87 - added want_cmnd_data to GET_CMND_DATA call
* revision 2.0 - 3/10/88 - added LOAD/NAME=
* revision 2.1 - 3/23/88 - enlarged cx_DIM_STR to accomodate date/time strings
* revision 2.2 - 8/15/88 - changed /NAME= re-cataloging procedure for new
*			   memory management routines
* revision 2.3 - 10/7/88 - remove in-plane transforms, too and re-catalog
* revision 2.4 -11/21/88 - new TM IO library GET_LIKE_GRID --> TM_GET_LIKE_GRID
*					     TRANSFER_GRID --> TM_COPY_GRID
* V200:  6/9/89 - deleted variables flagged in mr_protected
*		- /NAME= eliminated
*	12/15/89- fixed error check for LOAD/PERM expression
*	  5/1/90- added code so LOAD/TEMP works
*		  still flawed: doesn't detect region gt requested
*		- and bixed del_flink/blink bug in LOAD/PERM
* V230: 8/11/92 - double load of /PERMANENT got subscript error
* V312: 5/94 - array "memory" as a calling argument
* V530: *sh* 9/00 - added initial data type support in get_cmnd_data 
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)
* V702 2/17 *sh* keep track of LOAD/PERM memory usage

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include	'ferret.parm'
	include 'errmsg.parm'
	include 'xvariables.cmn'
	include 'xprog_state.cmn'

* local parameter definitions:
	INTEGER	slash_perm, slash_temp, slash_name
	PARAMETER     ( slash_temp = 1,		! (default)
     .			slash_perm = 2,
     .			slash_name = 16 )

* calling argument declarations:

* local variable declarations:
	LOGICAL		EXPLICIT_UVAR, permanent, named, temp
	INTEGER		status, iload, mr, next, prev, last_head

* initialize
	named	  = qual_given( slash_name ) .GT. 0
	permanent = qual_given( slash_perm ) .GT. 0
	temp	  = qual_given( slash_temp ) .GT. 0

* save the data under a given name
	IF ( named ) CALL ERRMSG( ferr_invalid_command, status,
     .		'/NAME= no longer supported - use DEFINE VARIABLE', *5000 )
	
* get the requested data somehow
	CALL GET_CMND_DATA (  cx_last, ptype_native, status )
	IF ( status .NE. ferr_ok ) GOTO 5000

* set protections as indicated (check for already protected 8/92)
	IF ( permanent ) THEN
	   DO 400 iload = 1, num_uvars_in_cmnd
	      mr = is_mr( iload )
	      IF ( mr_category( mr ) .EQ. cat_user_var ) THEN
	         IF ( .NOT.EXPLICIT_UVAR(mr_variable(mr)) ) CALL ERRMSG
     .			( ferr_invalid_command, status,
     .			'Cannot LOAD/PERM "expression".  Use DEFINE VARIABLE',
     .			 *5000 )
	      ENDIF
              IF ( mr_protected(mr) .NE. mr_perm_protected ) THEN  ! 8/92
	         mr_protected( mr ) = mr_perm_protected
* ... remove from deletion priority chain
	         prev = mr_del_blink(mr)
	         next = mr_del_flink(mr)
	         mr_del_flink(prev) = next
	         mr_del_blink(next) = prev
	         mr_del_flink( mr ) = unspecified_int4	! important 12/16
	         mr_del_blink( mr ) = unspecified_int4	! important 12/16
	         permanent_mem = permanent_mem + mr_size(mr)
              ENDIF
 400	   CONTINUE

	ELSEIF ( temp ) THEN
	   DO 500 iload = 1, num_uvars_in_cmnd
	      mr = is_mr( iload )
	      IF ( mr_protected( mr ) .EQ. mr_perm_protected ) THEN
	         mr_protected( mr ) = mr_not_protected
* ... restore at head of deletion priority chain
	         last_head = mr_del_flink(0)
	         mr_del_blink(mr) = 0
	         mr_del_flink(mr) = last_head
	         mr_del_flink(0)  = mr
	         mr_del_blink(last_head) = mr
	         permanent_mem = permanent_mem - mr_size(mr)
	      ENDIF
	      
 500	   CONTINUE

	ENDIF

	RETURN

* error exit(s)
 5000	RETURN
	END
