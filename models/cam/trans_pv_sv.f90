program trans_pv_sv

!----------------------------------------------------------------------
! purpose: interface between CAM and DART
!
! method: Read CAM 'initial' file (netCDF format).
!         Reform fields into a state vector.
!         Write out state vector in "proprietary" format for DART
!
! author: Kevin Raeder 2/21/03
!         based on prog_var_to_vector and vector_to_prog_var by Jeff Anderson
!
!----------------------------------------------------------------------

use model_mod, only : model_type, init_model_instance, read_cam_init, &
   prog_var_to_vector
use assim_model_mod, only : assim_model_type, static_init_assim_model, &
   init_assim_model, get_model_size , set_model_state_vector, write_state_restart, &
   binary_restart_files
use utilities_mod, only : get_unit

character (len = 128) :: file_name = 'caminput.nc', file_out = 'temp_ic'
character (len = 16)  :: file_form

! Temporary allocatable storage to read in a native format for cam state
type(assim_model_type) :: x
type(model_type) :: var
real, allocatable :: x_state(:)
integer :: file_unit, x_size


! Static init assim model calls static_init_model
PRINT*,'static_init_assim_model in trans_pv_sv'
call static_init_assim_model()

! Initialize the assim_model instance
call init_assim_model(x)

! Allocate the local state vector
x_size = get_model_size()
allocate(x_state(x_size))

! Allocate the instance of the cam model type for storage
call init_model_instance(var)

! Read the file cam state fragments into var
call read_cam_init(file_name, var)

! transform fields into state vector for DART
call prog_var_to_vector(var, x_state)

! Put this in the structure
call set_model_state_vector(x, x_state)
! What about setting the time???; currently zero from init_assim_model???

! get form of file output from assim_model_mod
if (binary_restart_files ) then
   file_form = 'unformatted'
else
   file_form = 'formatted'
endif
PRINT*,'In trans_pv_sv binary_restart_files, file_form = ',binary_restart_files, file_form

! Get channel for output 
! debug file_unit = get_unit()
file_unit = 13
open(unit = file_unit, file = file_out, form=file_form)
PRINT*,'In trans_pv_sv file_out unit = ',file_unit
PRINT*,' '
! write out state vector in "proprietary" format
call write_state_restart(x, file_unit, file_form)
close(file_unit)

end program trans_pv_sv
