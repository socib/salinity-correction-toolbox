function cruiseName = Stage_10a_Ship_CTD_salinity_corrections(DeploymentInfo,DIR)
%
%
% Loads the stuctured variable with the calibration coefficients under under
% the directory: pnameOUT = 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/';
% filename = [cruiseName,'_Correction_Coeff.mat']. Applies corrections to
% ship 5m averaged CTD salinity of the corresponding cruiseName.

global Path
% path name of output data:
pname_out = Path.dataCorrectedMat5mBinAvg;
% pname_out = 'SHIP/DATA/CTD/CTD_correction_files/Thredds/';

% If cruiseName is not provided, manually select cruiseName under directory
% where calibration data is stored:
Pname_coeffs_IN = Path.dataCorrectionCoefficientsMat;
cruiseName = strsplit(DeploymentInfo.deploymentName,'_Correction_Coeff.mat');

% Pname_coeffs_IN = 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/';
% if exist('cruiseName','var') == 0
%     [Fname, Pname, ~] = uigetfile([Pname_coeffs_IN,'*.mat']);
%     Fname2 = strsplit(Fname,'_Correction_Coeff.mat');
%     cruiseName = Fname2{1};
% end

% Extract date and deployment code from cruiseName to match up to filenames under Thredds:
% DeploymentInfo = strsplit(cruiseName{1},'_');
% dateCN = DeploymentInfo{4};
% datestrCr = dateCN;
% depCodeCN = DeploymentInfo{1};
% depCodestrCr = depCodeCN;

% dateCN = strsplit(cruiseName{1},'_');
% dateCN = dateCN{4};
% datestrCr = dateCN;


% Find matching date of cruiseName to Thredds nc filenames:
Pname_CTD_in = Path.dataCtdL1Thredds;

for n = 1:length(DIR)
    if isempty(strfind(DIR(n).name,DeploymentInfo.deploymentDate)) == 0 && isempty(strfind(DIR(n).name,DeploymentInfo.deploymentCode)) == 0
        X = strsplit(DIR(n).name,'.nc');
        FnameCTD = X{1};
    end
end

% % If a matching date doesn't work, manually determine which Thredds .nc file corresponds to cruiseName and manually select:    
% if n==length(DIR)
%      [FnameCTD, ~, ~] = uigetfile([Pname_CTD_in,'*.nc']);
%      X = strsplit(FnameCTD,'.nc');
%     FnameCTD = X{1};
% else
%     X = strsplit(DIR(n).name,'.nc');
%     FnameCTD = X{1};
% end

% load CTD data from Thredds .nc files:
finfo    = ncinfo([Pname_CTD_in,FnameCTD,'.nc']);
% Create cruisename as shown in Thredds (minus the date), this becomes the first order field name for the structured array of CTD data:  
X=strsplit(FnameCTD,'_L1_');
X2=strsplit(X{2},'.nc');
CruiseDate=X2{1};
CruiseVARname = strrep(X{1},'-','_');
CruiseVARname2{n,1} = CruiseVARname;
CruiseVARname3 = strrep(CruiseVARname,'_',' ');

% Read in nc file:
for n2 = 1:length(finfo.Variables)
    VAR.(CruiseVARname).L1.(finfo.Variables(n2).Name) = ncread([Pname_CTD_in,FnameCTD,'.nc'],finfo.Variables(n2).Name);
end
VAR.(CruiseVARname).lat         = VAR.(CruiseVARname).L1.LAT;
VAR.(CruiseVARname).lon         = VAR.(CruiseVARname).L1.LON;
VAR.(CruiseVARname).pressure    = VAR.(CruiseVARname).L1.WTR_PRE;
VAR.(CruiseVARname).depth       = -1.*gsw_z_from_p(VAR.(CruiseVARname).pressure,VAR.(CruiseVARname).lat);                                 %sw_dpth(pressureShip, 39.0);
if isfield(VAR.(CruiseVARname).L1,'SALT_01')==1
    VAR.(CruiseVARname).SALT_01     = VAR.(CruiseVARname).L1.SALT_01; 
end
if isfield(VAR.(CruiseVARname).L1,'SALT_02')==1
    VAR.(CruiseVARname).SALT_02     = VAR.(CruiseVARname).L1.SALT_02; 
end
if isfield(VAR.(CruiseVARname).L1,'WTR_TEM_01')==1
    VAR.(CruiseVARname).insituT_01  = VAR.(CruiseVARname).L1.WTR_TEM_01; 
end
if isfield(VAR.(CruiseVARname).L1,'WTR_TEM_02')==1
    VAR.(CruiseVARname).insituT_02  = VAR.(CruiseVARname).L1.WTR_TEM_02; 
end
% provide potential temperature:
p_ref = 0;
if isfield(VAR.(CruiseVARname).L1,'WTR_TEM_01')==1
    VAR.(CruiseVARname).ptemp_01    = sw_ptmp(VAR.(CruiseVARname).SALT_01,VAR.(CruiseVARname).insituT_01,VAR.(CruiseVARname).pressure,p_ref);      
end
if isfield(VAR.(CruiseVARname).L1,'WTR_TEM_02')==1
    VAR.(CruiseVARname).ptemp_02    = sw_ptmp(VAR.(CruiseVARname).SALT_02,VAR.(CruiseVARname).insituT_02,VAR.(CruiseVARname).pressure,p_ref);      
end

% load calibration data from 'SHIP/DATA/CTD/CTD_btlFILES/MASHUP/':
load([Pname_coeffs_IN,DeploymentInfo.deploymentName,'_Correction_Coeff.mat' ])
% load([Pname,Fname])
% Determine which sensor has the smallest calliration coefficient and thus
% should be used (i.e. will be used for plotting T/S diagrams):
if isfield(SALdata,'A00')==1 && isfield(SALdata,'B11')==1
    if SALdata.A00<SALdata.B11
        VAR.(CruiseVARname).Sensor = 1;
    elseif SALdata.B11<SALdata.A00
        VAR.(CruiseVARname).Sensor = 2;
    end
elseif isfield(SALdata,'A00')==1
    VAR.(CruiseVARname).Sensor = 1;
elseif isfield(SALdata,'B11')==1
    VAR.(CruiseVARname).Sensor = 2;
end

% Apply calibration equation to CTD data:
if isfield(SALdata,'A00')==1
    VAR.(CruiseVARname).Corrected.Sensor01.Coefficient = SALdata.A00;
    VAR.(CruiseVARname).Corrected.Sensor01.COND_01 = SALdata.A00*VAR.(CruiseVARname).L1.COND_01;
    VAR.(CruiseVARname).Corrected.Sensor01.SALT_01 = gsw_SP_from_C(VAR.(CruiseVARname).Corrected.Sensor01.COND_01,VAR.(CruiseVARname).insituT_01,VAR.(CruiseVARname).pressure);
end
if isfield(SALdata,'B11')==1
    VAR.(CruiseVARname).Corrected.Sensor02.Coefficient = SALdata.B11;
    VAR.(CruiseVARname).Corrected.Sensor02.COND_02 = SALdata.B11*VAR.(CruiseVARname).L1.COND_02;
    VAR.(CruiseVARname).Corrected.Sensor02.SALT_02 = gsw_SP_from_C(VAR.(CruiseVARname).Corrected.Sensor02.COND_02,VAR.(CruiseVARname).insituT_02,VAR.(CruiseVARname).pressure);
end

% save structured array with correction variables:
save([pname_out,FnameCTD,'with_corrections'],'VAR')

% Plot T/S diagrams using the function:
%Stage_10a1_matching_TS_diags_with_without_corrections(VAR,CruiseVARname,CruiseVARname3,CruiseDate)
%Stage_10b_TS_diags_with_without_corrections_BOTHsensors(VAR, deploymentName)