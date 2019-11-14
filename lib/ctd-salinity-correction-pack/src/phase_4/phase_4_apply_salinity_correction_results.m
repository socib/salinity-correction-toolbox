function fnameOutPath = phase_4_apply_salinity_correction_results(DeploymentInfo, DIR, ncL1FileName, unique_sensor)

global Path

cruiseName = Stage_10a_Ship_CTD_salinity_corrections(DeploymentInfo,DIR);

Stage_12_Thredds_Ship_CTD_salinity_corrections(cruiseName, DeploymentInfo);

Stage_13_create_nc_correction_file_for_dataCentre(DeploymentInfo.deploymentName);

Stage_14_read_and_correct_halfm_cnv_ctd(DeploymentInfo.deploymentName, unique_sensor);

CTD = Stage_14c_allDATA_halfm_corrected(DeploymentInfo.deploymentName);

Stage_14d_add_meta_create_nc_halfmetre_correction_CTD(DeploymentInfo.deploymentName, ncL1FileName);

Stage_14e_TSdiag_all_halfMetreBIN_corrected;

fnameOutPath = [Path.dataCorrectionCoefficientsNc];

end