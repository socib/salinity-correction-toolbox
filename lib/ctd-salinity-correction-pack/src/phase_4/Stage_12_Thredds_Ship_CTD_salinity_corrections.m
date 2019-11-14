function Stage_12_Thredds_Ship_CTD_salinity_corrections(cruiseName, DeploymentInfo)
%
%
% Loads the stuctured variable with the calibration coefficients under under
% the directory: pnameOUT = 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/';
% filename = [cruiseName,'_Correction_Coeff.mat']. Applies corrections to
% ship CTD salinity of the corresponding cruiseName.

global Path

% path name of output data:
% pname_out = 'SHIP/DATA/CTD/CTD_correction_files/ncfiles/';
pname_out = Path.dataCorrectedNc5mBinAvg;
% If cruiseName is not provided, manually select cruiseName under directory
% where calibration data is stored:
% Pname_coeffs_IN = Path.dataCorrectionCoefficientsMat;

% Pname_coeffs_IN = 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/';
% if exist('cruiseName','var') == 0
%     [Fname, Pname, ~] = uigetfile([Pname_coeffs_IN,'*.mat']);
%     Fname2 = strsplit(Fname,'_Correction_Coeff.mat');
%     cruiseName = Fname2{1};
% end

% Extract date from cruiseName to match up to filenames under Thredds:
% dateCN = strsplit(cruiseName,'_');
% dateCN = [dateCN{2},dateCN{1}];
% [YY, MM, DD] = datevec(dateCN,'yyyymmmdd');
% dateumber = datenum(YY,MM,DD);
% datestrCr = datestr(dateumber,'yyyy-mm-dd');

% Find matching date of cruiseName to Thredds nc filenames:
Pname_CTD_in = Path.dataCtdL1Thredds;
% Pname_CTD_in = 'SHIP/DATA/CTD/CTD_L1_Thredds/';
DIR = dir(fullfile(Pname_CTD_in,'*.nc'));
n = 1;
for i = 1:length(DIR)
    if isempty(strfind(DIR(i).name,DeploymentInfo.deploymentDate)) == 0 && n < length(DIR)
        if isempty(strfind(DIR(i).name,DeploymentInfo.deploymentCode)) == 0
            n = i;
        end
    end
end
% If a matching date doesn't work, manually determine which Thredds .nc file corresponds to cruiseName and manually select:    
if n == length(DIR)
     [FnameCTD, ~, ~] = uigetfile([Pname_CTD_in,'*.nc']);
     FnameCTD = strsplit(FnameCTD,'.nc');
     FnameCTD = FnameCTD{1};
else
    X = strsplit(DIR(n).name,'.nc');
    FnameCTD = X{1};
end

% load CTD data from Thredds .nc files:
[data, meta, global_meta] = loadnc([Pname_CTD_in,FnameCTD,'.nc']);

% load calibration data from 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/':
Pname_coeffs_IN = Path.dataCorrectionCoefficientsMat;
load([Pname_coeffs_IN,DeploymentInfo.deploymentName,'_Correction_Coeff'])

if isfield(data,'COND_01')==1
    % Apply calibration equation to CTD data:
    data.COND_01_CORR = data.COND_01*SALdata.A00;
    data.SALT_01_CORR = gsw_SP_from_C(data.COND_01_CORR,data.WTR_TEM_01,data.WTR_PRE);
    
    % Create meta data for all new variables:
    meta.COND_01_CORR.name       = [meta.COND_01.name,'_CORR'];
    meta.COND_01_CORR.datatype   = meta.COND_01.datatype;
    meta.SALT_01_CORR.name       = [meta.SALT_01.name,'_CORR'];
    meta.SALT_01_CORR.datatype   = meta.SALT_01.datatype;
    meta.COND_01_CORR.dimensions = meta.COND_01.dimensions;
    meta.SALT_01_CORR.dimensions = meta.SALT_01.dimensions;
    if isfield(SALdata,'insituFailedCorr')==0
        meta.COND_01_CORR.attributes = struct('name',{'standard_name','long_name','units','_FillValue','ancillary_variables','coordinates','original_units','observation_type'...
            ,'precision','Correction_coefficient_A','Calibration_equation','comment'},...
            'value',{'sea_water_electrical_conductivity_corrected','Conductivity of sensor 3872','ms cm-1',-9.999989999999999e+04,'QC_COND_01','time LAT LON DEPTH',...
            'ms cm-1','corrected_measurements','0.0001',SALdata.A00,'COND_01_CORR=A*COND_01','Salinity calibration reference: Seabird application note AN31 (www.seabird.com/application-notes)'});
    elseif isfield(SALdata,'insituFailedCorr')==1
        meta.COND_01_CORR.attributes = struct('name',{'standard_name','long_name','units','_FillValue','ancillary_variables','coordinates','original_units','observation_type'...
            ,'precision','Correction_coefficient_A','Calibration_equation','comment'},...
            'value',{'sea_water_electrical_conductivity_corrected','Conductivity of sensor 3872','ms cm-1',-9.999989999999999e+04,'QC_COND_01','time LAT LON DEPTH',...
            'ms cm-1','corrected_measurements','0.0001',SALdata.A00,'COND_01_CORR=A*COND_01','insitu calibration yielded poor results; TS diagram whitespace maximisation method has been applied instead'});
    end
    CS=reshape(SALdata.CorrectionSummary,1,[]);
    CS2 = horzcat(CS{1:length(CS)});
    meta.SALT_01_CORR.attributes = struct('name',{'standard_name','long_name','units','_FillValue','ancillary_variables','coordinates','original_units','observation_type'...
        ,'precision','resolution','Residual_Salinity_differences_mean','Residual_Salinity_differences_std','comment','outlier_removal_summary'},...
        'value',{'sea_water_practical_salinity_corrected','sea water practical salinity corrected','psu',-9.999989999999999e+04,'QC_SALT_01','time LAT LON DEPTH',...
        'psu','corrected_derived_from_COND_01_CORR','0.0001','0.0001',SALdata.meanResid_COR.Sal00,SALdata.stdResid_COR.Sal00,...
        'Salinity derived from COND_01_CORR and TEMP_01',CS2});
    clear CS CS2 n1
end

if isfield(data,'COND_02')==1
    % Apply calibration equation to CTD data:
    data.COND_02_CORR = data.COND_02*SALdata.B11;
    data.SALT_02_CORR = gsw_SP_from_C(data.COND_02_CORR,data.WTR_TEM_02,data.WTR_PRE);

    % Create meta data for all new variables:
    meta.COND_02_CORR.name       = [meta.COND_02.name, '_CORR']; 
    meta.COND_02_CORR.datatype   = meta.COND_02.datatype;
    meta.SALT_02_CORR.name       = [meta.SALT_02.name,'_CORR'];
    meta.SALT_02_CORR.datatype   = meta.SALT_02.datatype;
    meta.COND_02_CORR.dimensions = meta.COND_02.dimensions;
    meta.SALT_02_CORR.dimensions = meta.SALT_02.dimensions;
    if isfield(SALdata,'insituFailedCorr')==0
        meta.COND_02_CORR.attributes = struct('name',{'standard_name','long_name','units','_FillValue','ancillary_variables','coordinates','original_units','observation_type'...
            ,'precision','Correction_coefficient_B','Calibration_equation','comment'},...
            'value',{'sea_water_electrical_conductivity_corrected','Conductivity of sensor 3877','ms cm-1',-9.999989999999999e+04,'QC_COND_01','time LAT LON DEPTH',...
            'ms cm-1','corrected_measurements','0.0001',SALdata.B11,'COND_02_CORR=B*COND_02','Salinity calibration reference: Seabird application note AN31 (www.seabird.com/application-notes)'});
    elseif isfield(SALdata,'insituFailedCorr')==1
        meta.COND_02_CORR.attributes = struct('name',{'standard_name','long_name','units','_FillValue','ancillary_variables','coordinates','original_units','observation_type'...
            ,'precision','Correction_coefficient_B','Calibration_equation','comment'},...
            'value',{'sea_water_electrical_conductivity_corrected','Conductivity of sensor 3877','ms cm-1',-9.999989999999999e+04,'QC_COND_01','time LAT LON DEPTH',...
            'ms cm-1','corrected_measurements','0.0001',SALdata.B11,'COND_02_CORR=B*COND_02','insitu calibration yielded poor results; TS diagram whitespace maximisation method has been applied instead'});
    end
    CS=reshape(SALdata.CorrectionSummary,1,[]);
    CS2 = horzcat(CS{1:length(CS)});
    meta.SALT_02_CORR.attributes = struct('name',{'standard_name','long_name','units','_FillValue','ancillary_variables','coordinates','original_units','observation_type'...
        ,'precision','resolution','Residual_Salinity_differences_mean','Residual_Salinity_differences_std','comment','outlier_removal_summary'},...
        'value',{'sea_water_practical_salinity_corrected','sea water practical salinity corrected','psu',-9.999989999999999e+04,'QC_SALT_02','time LAT LON DEPTH',...
        'psu','corrected_derived_from_COND_02_CORR','0.0001','0.0001',SALdata.meanResid_COR.Sal11,SALdata.stdResid_COR.Sal11,...
        'Salinity derived from COND_02_CORR and TEMP_02',CS2});
    clear CS CS2 n1
end


% adjust/update global meta data:
%????
% need to update the following somehow:
% 'date_update'
% 'date_modified'
% 'date_mode'
% 'processing_level'
% and add some information about the following:
% - what corrections are made
% - cite an online document of correction procedure??
% - name/email of delayed-mode data processor??

% save new file:
fname_out = [FnameCTD,'_Corrected'];
savenc(data,meta,global_meta,[pname_out,fname_out,'.nc'])

% Plot T/S diagrams using the function:
% matching_TS_diags_with_without_corrections2(data,meta,FnameCTD)



