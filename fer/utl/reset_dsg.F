	SUBROUTINE RESET_DSG (nvars, cx_list)

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
* Clean up after a DSG plot; extra lines and grids were alloocated.
* Reset cx_feature, the number of variables plotted, cx_grid
* If a mask variable was used the number of variables and variable-
* memory pointer needs restoring

	include	'tmap_dims.parm'
	include 'ferret.parm'
	include 'xvariables.cmn'
	include 'xcontext.cmn'
	include 'xtm_grid.cmn_text'
	include 'xprog_state.cmn'

	INTEGER nvars, cx_list(*)

	LOGICAL its_dsg
	INTEGER TM_DSG_DSET_FROM_GRID, cx, grid, dset, i, 
     .		the_cx, iaxis, orientation, obsdimlen, fline, nv

* Get the DSG dataset, grid, and the orientation of the feature
* so we can get the axes that were allocated.

	cx = is_cx(1)
	grid = cx_grid(cx)
	dset = TM_DSG_DSET_FROM_GRID( grid )

	nv = nvars
	
	its_dsg = .TRUE.
	CALL TM_DSG_FACTS( grid, orientation, obsdimlen, fline, its_dsg )

	IF (nv .GT. 1) THEN

* Was this a single-feature, multi-variable plot?  If so we defined one
* temporary grid.
	   IF (cx_variable(cx) .NE. cx_variable(cx+1) ) THEN 
	       nv = 1
	   ELSE

* Restore number of variables - num_uvars_in_cmnd is reset for multi-
* feature plot or for mask-variable.
	      nvars = 1

	   ENDIF
	ENDIF

* Deallocate the temporary grid and axis used.  Reset cx_feature.
	
	the_cx = cx - 1
	DO i = 1, nv
	   the_cx = the_cx + 1
	   grid = cx_grid(the_cx)
	   iaxis = grid_line(orientation, grid)

	   CALL TM_deallo_dyn_grid( grid )
	   CALL FREE_LINE_DYNMEM ( iaxis )

           cx_feature(cx_list(i)) = pdsg_not_dsg  ! zero
	ENDDO

	grid_is_dsg = .FALSE.
	cx_grid(cx) = cx_grid(cx_buff)

	RETURN
	END
