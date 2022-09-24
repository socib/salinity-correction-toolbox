function argo_sc_set_ancillary_paths(Campaign, CtdCorrDataFile)


global MainPath 
global OPERATIONAL_MODE 
global ONLINE_MODE
global TEST_MODE 


switch OPERATIONAL_MODE
    case 1 % when working in the office network
        ASCPath.figs = [''];
        ASCPath.dataOut = [''];
    case 0 % when NOT working in the office network

end
        
switch ONLINE_MODE
    case 0 % when NOT working with internet connetion
    case 1 % when working with internet connetion
end

switch TEST_MODE
    case 0 % when NOT testing  
        ASCPath.figs = [MainPath.main,'out/prod/figs/']; % paths to figures       
        ASCPath.dataOut = [MainPath.main,'out/prod/data/']; % paths to data 
        outDir = 'prod';
    case 1 % when testing
        ASCPath.figs = [MainPath.main,'out/test/figs/']; % paths to figures
        ASCPath.dataOut = [MainPath.main,'out/test/data/']; % paths to data
        outDir = 'test';        
end

% paths through data folders 
MainPath.dataCorrectionFiles = [ASCPath.dataOut,'correction_data/correction_files/'];
MainPath.dataCorrectedMat = [MainPath.dataCorrectionFiles,'corrected_mat/'];
MainPath.dataHalfmCtdCorrected = [MainPath.mainToolbox, 'lib/ctd-salinity-correction-pack/out/', outDir, '/data/correction_data/correction_files/corrected_mat/ctd_all_data_halfm_corrected/']; % mat file with all CTD corrected data for halfmeter       
MainPath.dataCorrectedNc = [MainPath.dataCorrectionFiles,'corrected_nc/'];
MainPath.dataCorrectionCoefficients = [ASCPath.dataOut,'correction_data/correction_coefficients/'];
MainPath.dataCorrectionCoefficientsMat = [MainPath.dataCorrectionCoefficients,'correction_coefficients_mat/'];
MainPath.dataCorrectionCoefficientsNc = [MainPath.dataCorrectionCoefficients,'correction_coefficients_nc/'];

% path through figures folders
MainPath.outFigsCorrection = [ASCPath.figs,Campaign.testDeploymentCode, '-', Campaign.testPlatformName, '_vs_', CtdCorrDataFile.info{1}{1}, '-', CtdCorrDataFile.info{1}{3}, '/'];

% MainPath.figsTSdiagsWithWithoutCorrections = [GSCPath.figs,'ARGO_sal_correction/'];
MainPath.figsTSdiagsCorrectedReference = [ASCPath.figs,'ts_diag_corrected_reference/'];
MainPath.deploymentFigsTSdiagsCorrectedReference = [MainPath.figsTSdiagsCorrectedReference, Campaign.Test, '/'];
% MainPath.figDeploymentFigsTSdiagsCorrectedReference = [MainPath.figsTSdiagsCorrectedReference, Campaign.Test, 'fig/'];
% MainPath.pngDeploymentFigsTSdiagsCorrectedReference = [MainPath.figsTSdiagsCorrectedReference, Campaign.Test, 'png/'];

end
