	INTEGER FUNCTION TM_GET_GRID_OF_LINE (line)
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
* Searches the list of predefined and user-defined grid_names and returns the
* number associated with the first grid using the given axis.
* If no match is found the value unspecified_int4 is returned.

* V510 *sh* 5/00 - based on TM_GET_GRIDNUM
* V674 2/12 *acm* 6D Ferret: use nferdims rather than 4 for dimension indexing

# include "tmap_dset.parm"	
	include 'tmap_dims.parm'
	include 'xtm_grid.cmn_text'	! pre-defined grid common
#include "gt_lib.parm"

* input arguments
	INTEGER		line

* local argument declarations
	INTEGER		igrd, idim

* check the static grids
	DO 100 igrd=1,max_grids
	  IF (grid_name(igrd) .EQ. char_init16) GOTO 100
	  DO 90 idim = 1, nferdims
	    IF ( grid_line(idim, igrd) .EQ. line ) THEN
	      TM_GET_GRID_OF_LINE = igrd
	      GOTO 900 
	    ENDIF
 90	  CONTINUE
100	CONTINUE

* check the dynamic grids
	igrd = 0
 200	CALL TM_NEXT_DYN_GRID( igrd, *299)
	  DO 190 idim = 1, nferdims
	    IF ( grid_line(idim, igrd) .EQ. line ) THEN
	      TM_GET_GRID_OF_LINE = igrd
	      GOTO 900 
	    ENDIF
 190	  CONTINUE
	GOTO 200

* not found
 299	TM_GET_GRID_OF_LINE = unspecified_int4

* found
 900	RETURN
	END
