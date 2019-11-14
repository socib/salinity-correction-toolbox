function set_ancillary_paths(DeploymentInfo)

global MainPath
global Path 
global OPERATIONAL_MODE 
global ONLINE_MODE
global TEST_MODE 


Path.main = MainPath.main;
Path.dataCtdL1Thredds = MainPath.dataCtdL1Thredds;
Path.dataInsituSalinityRaw = MainPath.dataPortasal;
Path.dataCtd = [MainPath.dataCtd,DeploymentInfo.researchVesselName,'/', DeploymentInfo.instrumentName,'/rawArchive/',DeploymentInfo.deploymentYear,'/',DeploymentInfo.deploymentName,'/'];
Path.dataCTDInsituCalHistory = MainPath.dataCTDInsituCalHistory;

switch OPERATIONAL_MODE
    case 1 % when working in the office network
        Path.figs = [];
        Path.dataOut = [];
    case 0 % when NOT working in the office network
        Path.figs = []; % paths to figures       
        Path.dataOut = []; % paths to data
end
        
switch ONLINE_MODE
    case 0 % when NOT working with internet connetion
    case 1 % when working with internet connetion
end

switch TEST_MODE
    case 0 % when NOT testing  
        Path.figs = [Path.main,'out/prod/figs/']; % paths to figures
        Path.dataOut = [Path.main,'out/prod/data/']; % paths to data 
    case 1 % when testing
        Path.figs = [Path.main,'out/test/figs/']; % paths to figures
        Path.dataOut = [Path.main,'out/test/data/']; % paths to data
end

Path.code = [Path.main,'src/']; % path to the source code
Path.libraries = [Path.main,'ext/']; % path to external libraries
Path.resources = [Path.main,'res/']; % path to resources like configuration files and ancillary images

% paths through data folders
Path.dataCtdBtl = [Path.dataCtd,'BOTTLE/'];
Path.dataCtdBinAvgHalfm = [Path.dataCtd,'PROCESSED_SOCIB_halfm/'];
Path.dataCtdBtlMat = [Path.dataOut,'ctd_btl_mat/'];
Path.dataInsituSalinityConverted = [Path.dataOut,'insitu_salinity_mat/'];

Path.dataCorrectionFiles = [Path.dataOut,'correction_data/correction_files/'];
Path.dataCorrectedMat = [Path.dataCorrectionFiles,'corrected_mat/'];
Path.dataCorrectedMat5mBinAvg = [Path.dataCorrectedMat,'corrected_mat_5m_bin_avg/'];
Path.dataCorrectedMatHalfmBinAvg = [Path.dataCorrectedMat,'corrected_mat_halfm_bin_avg/'];
Path.dataCorrectedMatHalfmBinAvgAll = [Path.dataCorrectedMat,'ctd_all_data_halfm_corrected/'];
Path.dataCorrectedNc = [Path.dataCorrectionFiles,'corrected_nc/'];
Path.dataCorrectedNc5mBinAvg = [Path.dataCorrectedNc,'corrected_nc_5m_bin_avg/'];
Path.dataCorrectedNcHalfmBinAvg = [Path.dataCorrectedNc,'corrected_nc_halfm_bin_avg/'];
Path.dataCorrectionCoefficients = [Path.dataOut,'correction_data/correction_coefficients/'];
Path.dataCorrectionCoefficientsMat = [Path.dataCorrectionCoefficients,'correction_coefficients_mat/'];
Path.dataCorrectionCoefficientsNc = [Path.dataCorrectionCoefficients,'correction_coefficients_nc/'];


% path through figures folders
Path.figsTSdiagsAllCruisesThreddsL1 = [Path.figs,'ts_diag_all_cruises_thredds_L1/'];
Path.figsTSdiagsSingleCruisesThreddsL1 = [Path.figsTSdiagsAllCruisesThreddsL1,'single_cruises/'];
Path.figsTSdiagsSingleCruisesThreddsL1Zoom = [Path.figsTSdiagsSingleCruisesThreddsL1,'zoom/'];
Path.figsTSdiagsComparedCruisesThreddsL1 = [Path.figsTSdiagsAllCruisesThreddsL1,'compared_cruises/'];
Path.figsResidualsInsituSalinity = [Path.figs,'residuals_insitu_salinity/'];
Path.figsTSdiagsWithWithoutCorrections = [Path.figs,'ts_diag_with_without_corrections/'];
Path.figsTSdiagsCorrectedReference = [Path.figs,'ts_diag_corrected_reference/'];
Path.figsTSdiagsCorrectedReferenceHalfmSingle = [Path.figsTSdiagsCorrectedReference,'halfm_single/'];
Path.figsTSdiagsCorrectedReferenceHalfmAll = [Path.figsTSdiagsCorrectedReference,'halfm_all/'];

end