function Stage_13_create_nc_correction_file_for_dataCentre(deploymentName)
%
%
% Loads correction coefficien mat file from /SHIP/DATA/CTD/CTD_btlFILES/MASHUP and creates a simple neat
% correction coefficient nc file fore the data centre to use to create the
% corrected file Thredds version.
% This code uses a nested function: depNum_to_cruiseName.m which matches
% the Seabird processed data directly off the ship to the deployment number
% assigned by the data centre at a later stage. At a later stage as things
% becomes more efficient with the data centre this may become obselete and
% the codes adjusted to work directly from Poseidon.
% Nested function: /SHIP/CODES/depNum_to_cruiseName
%       input requirements: yr, month and cruisename of Seabird processed
%       data files
%       output: the deployment number assigned by data centre and whether
%       the instrument used was sbe9001 or sbe9002.

global Path
% addpath SHIP/CODES/CTD

PN_in = Path.dataCorrectionCoefficientsMat;
PN_out = Path.dataCorrectionCoefficientsNc;

% PN_in = 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/';
% PN_out = 'SHIP/DATA/CTD/CTD_correction_files/Correction_meta_details/';
% PN_out_network = '//POSEIDON/users/vessel/SHIP_DATA/SBE911/Corrected__netcdfFiles_CTD/meta_data_correction_coefficients/';

% FNlist = dir(PN_in);
%
% [FN_in,~]=listdlg('PromptString','Select Cruise:',...
%                     'SelectionMode','multiple','ListString',{FNlist.name});
%

% for n = 1:length(FN_in)
%     load([PN_in,FNlist(FN_in(n)).name])
load([PN_in,deploymentName,'_Correction_Coeff']);
FN_out = [deploymentName,'.nc'];
%     [yr,mnth]=datevec(min(SALdata.btl.DateNum),'YY, MM');
%     CruiseName{1}=FNlist(FN_in(n)).name;
%     [depNUM,sbe900] = depNum_to_cruiseName(yr,mnth,CruiseName);
%
%     if depNUM<10
%         FN_out = ['dep000',num2str(depNUM),'socib_rv_scb_sbe900',num2str(sbe900)];
%     else
%         FN_out = ['dep00',num2str(depNUM),'socib_rv_scb_sbe900',num2str(sbe900)];
%     end
if exist([PN_out,FN_out]) == 2
    delete([PN_out,FN_out]);
end


references = 'Salinity calibration reference: Seabird application note AN31 (www.seabird.com/application-notes); Allen, J.T.; Fuda,J-L.;Perivoliotis, L.; Munoz-Mas, C.; Alou, E. and Reeve, K. (2018) Guidelines for the delayed mode scientific correction of glider data. WP 5, Task 5.7, D5.15. Version 4.1. Palma de Mallorca, Spain, SOCIB - Balearic Islands Coastal Observing and Forecasting System for JERICO-NEXT, 20pp. (JERICO-NEXT-WP5-D5.15-140818-V4.1). DOI: 10.25607/OBP-430';
references_insituFailedCorr = 'insitu calibration yielded poor results; TS diagram whitespace maximisation method has been applied instead. Salinity calibration reference: Allen, J.T.; Fuda,J-L.;Perivoliotis, L.; Munoz-Mas, C.; Alou, E. and Reeve, K. (2018) Guidelines for the delayed mode scientific correction of glider data. WP 5, Task 5.7, D5.15. Version 4.1. Palma de Mallorca, Spain, SOCIB - Balearic Islands Coastal Observing and Forecasting System for JERICO-NEXT, 20pp. (JERICO-NEXT-WP5-D5.15-140818-V4.1). DOI: 10.25607/OBP-430';
if isfield(SALdata,'A00')==1
    %*****COND_01******
    nccreate([PN_out,FN_out],'COND_01_CORR');
    ncwriteatt([PN_out,FN_out],'COND_01_CORR','observation_type','corrected_measurements')
    ncwriteatt([PN_out,FN_out],'COND_01_CORR','correction_coefficient_A',SALdata.A00)
    ncwriteatt([PN_out,FN_out],'COND_01_CORR','calibration_equation','COND_01_CORR=A*COND_01')
    if isfield(SALdata,'insituFailedCorr')==0
        ncwriteatt([PN_out,FN_out],'COND_01_CORR','comment', references)
    elseif isfield(SALdata,'insituFailedCorr')==1
        ncwriteatt([PN_out,FN_out],'COND_01_CORR','comment', references_insituFailedCorr)
    end
    %*****SALT_01******
    nccreate([PN_out,FN_out],'SALT_01_CORR');
    ncwriteatt([PN_out,FN_out],'SALT_01_CORR','observation_type','corrected_derived_from_COND_01_CORR')
    if isfield(SALdata,'insituFailedCorr')==0
        ncwriteatt([PN_out,FN_out],'SALT_01_CORR','comment',references)
        ncwriteatt([PN_out,FN_out],'SALT_01_CORR','residual_salinity_differences_mean',SALdata.meanResid_COR.Sal00)
        ncwriteatt([PN_out,FN_out],'SALT_01_CORR','residual_salinity_differences_std',SALdata.stdResid_COR.Sal00)
    elseif isfield(SALdata,'insituFailedCorr')==1
        ncwriteatt([PN_out,FN_out],'SALT_01_CORR','comment', references_insituFailedCorr);
        ncwriteatt([PN_out,FN_out],'SALT_01_CORR','salinity_error_estimate',SALdata.stdResid_COR.Sal00)
    end
    ncwriteatt([PN_out,FN_out],'SALT_01_CORR','outlier_removal_summary',[SALdata.CorrectionSummary{1},' ',SALdata.CorrectionSummary{2},' ',SALdata.CorrectionSummary{3},' ',SALdata.CorrectionSummary{4}])
end
if isfield(SALdata,'B11')==1
    %*****COND_02******
    nccreate([PN_out,FN_out],'COND_02_CORR');
    ncwriteatt([PN_out,FN_out],'COND_02_CORR','observation_type','corrected_measurements')
    ncwriteatt([PN_out,FN_out],'COND_02_CORR','correction_coefficient_B',SALdata.B11)
    ncwriteatt([PN_out,FN_out],'COND_02_CORR','calibration_equation','COND_02_CORR=B*COND_02')
    if isfield(SALdata,'insituFailedCorr') == 0
        ncwriteatt([PN_out,FN_out],'COND_02_CORR','comment',references)
    elseif isfield(SALdata,'insituFailedCorr') == 1
        ncwriteatt([PN_out,FN_out],'COND_02_CORR','comment', references_insituFailedCorr)
    end
    %*****SALT_01******
    nccreate([PN_out,FN_out],'SALT_02_CORR');
    ncwriteatt([PN_out,FN_out],'SALT_02_CORR','observation_type','corrected_derived_from_COND_02_CORR')
    if isfield(SALdata,'insituFailedCorr') == 0
        ncwriteatt([PN_out,FN_out],'SALT_02_CORR','comment',references)
        ncwriteatt([PN_out,FN_out],'SALT_02_CORR','residual_salinity_differences_mean',SALdata.meanResid_COR.Sal11)
        ncwriteatt([PN_out,FN_out],'SALT_02_CORR','residual_salinity_differences_std',SALdata.stdResid_COR.Sal11)
    elseif isfield(SALdata,'insituFailedCorr') == 1
        ncwriteatt([PN_out,FN_out],'SALT_02_CORR','comment', references_insituFailedCorr);
        ncwriteatt([PN_out,FN_out],'SALT_02_CORR','salinity_error_estimate',SALdata.stdResid_COR.Sal11)
    end
    x=reshape(SALdata.CorrectionSummary,1,[]);
    x2 = horzcat(x{1:length(x)});
    ncwriteatt([PN_out,FN_out],'SALT_02_CORR','outlier_removal_summary',x2)
    clear x x2
    %     end
    
    %     copyfile([PN_out,FN_out],[PN_out_network,FN_out])           % copies file onto network for data centre
end

