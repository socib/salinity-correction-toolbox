function [CtdBtl, InsituSal, DIR, ncL1FileName, DeploymentInfo] = phase_1_select_cruise_data

set_main_paths('salinity_ctd');

[ncL1FileName, DIR, DeploymentInfo] = stage_0_select_datasets;

ctd_sc_set_ancillary_paths(DeploymentInfo);

create_out_directories;

InsituSal = stage_4_read_insitu_salinity_data(DeploymentInfo);

CtdBtl = stage_6a_read_dotbtl_files(DeploymentInfo);

end