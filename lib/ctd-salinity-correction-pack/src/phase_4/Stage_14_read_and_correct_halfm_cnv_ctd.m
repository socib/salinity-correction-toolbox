function Stage_14_read_and_correct_halfm_cnv_ctd(deploymentName, unique_sensor)
%
%
% Imports and converts half metre bin averaged cnv files into matlab to
% create a structure, to which conductivity corrections are applied, from
% which corrected salinity is derived. The two outputs are as a
% structured .mat file and as a netcdf file.
%
% nested function: Stage_14b_cnv2mat_2013

global Path

% Pathname for the salinity correction coefficient data
Pname_in_corrCoeff = Path.dataCorrectionCoefficientsNc;

% Pathaname for output mat file:
Pname_out_MAT = Path.dataCorrectedMatHalfmBinAvg;
fname_out_part = '_corrected_halfmetreBINs';
Pname_in = Path.dataCtdBinAvgHalfm;
% %% 1. Pick a cruise campaign/file location
% % Select cruise from directory list, extracting pathname and cruise name
% % for loading and reading the data.
% %
% % 1.a) where is the seabird processed data stored: network or pc? User is
% %      advised to work from the network.
% %      This gives us the option of selection the pathname of the input cnv files
% %      from the SOCIB network, on the pc documents or to manually find the correct
% %      pathway:
% button = questdlg('Where is the cnv data stored?','Input data pathname','Network','PC','manual','Network');
% if strcmp(button,'Network')==1
%     Pname_in = uigetdir('//poseidon/users/vessel/RTDATA/socib_rv');%SHIP_DATA/SBE911/DATA');
% elseif strcmp(button,'PC')==1
%     Pname_in = uigetdir('/Documents/DATA/SHIP/CTD');
% elseif strcmp(button,'manual')==1
%     Pname_in = uigetdir;
% end
% %
% 1.b) Split pathname in order to extract the cruise campaign name:
% Pathparts=strsplit(Pname_in,'/');
% last = regexp(Pathparts,'PROCESSED_SOCIB_halfm');
% counter=1;
% while isempty(last(counter))==0 && counter<length(last)
%     counter=counter+1;
% end
% CruiseName = Pathparts(counter-1);
% CruiseName=strrep(CruiseName,'-','_');
% CruiseName=strrep(CruiseName,' ','_');
% 
% % 1.c) extract from cruise name, deployment number and sbe instrument (sbe9001
% %      or sbe9002):
% CruiseName2 = CruiseName{1};
% tmpry  = strfind(CruiseName2,'dep');
% x = tmpry;
% while strcmp(CruiseName2(x),'_')==0
%     x = x+1;
% end
% depNum = CruiseName2(tmpry:x-1);
% 
% tmpry  = strfind(CruiseName2,'sbe900');
% x = tmpry;
% while strcmp(CruiseName2(x),'_')==0
%     x = x+1;
% end
% sbe = CruiseName2(tmpry:x-1);
% 
% clear x tmpry 

%% 2. Load meta correction data: this is the netcdf file of the correction coefficients for conductivity.
% This section uses the deployment number and the instrument type (sbe) to
% find the corresponding netcdf file of the correction coefficient meta
% data on the network (supplied in stage 13 of the salinity correction procedure)
%
% 2.a) Find and load netCDF file:
[~, meta, ~] = loadnc([Pname_in_corrCoeff,deploymentName,'.nc']);
% Dir_meta = dir([Pname_in_corrCoeff,depNum,'*',sbe]);
% [~, meta, ~] = loadnc([Pname_in_corrCoeff,Dir_meta.name]);
%
% 2.b) Check if sensor 01 is available (i.e. for sal00 and t090) and extract
%     correction coefficient from meta data:
if isfield(meta,'COND_01_CORR')==1
    n=1;
    while strcmpi(meta.COND_01_CORR.attributes(n).name,'correction_coefficient_A')==0
        n=n+1;
    end
    A00 = meta.COND_01_CORR.attributes(n).value;
end
%
% 2.c) Check if sensor 02 is available (i.e. for sal11 and t190) and extract
%      correction coefficient from meta data:
if isfield(meta,'COND_02_CORR')==1
    n=1;
    while strcmpi(meta.COND_02_CORR.attributes(n).name,'correction_coefficient_B')==0
        n=n+1;
    end
    B11 = meta.COND_02_CORR.attributes(n).value;
end

%% 3. Read the half metre .cnv files of the cruise campaign into matlab.
%
% 3.a) list all .cnv files under cruiseName pathway - down files only:
profileList = dir(fullfile(Pname_in, ['d','*.cnv']));
numProfiles = length(profileList);                     % total number of downcast profiles
%
% 3.b). use Stage_14b_cnv2mat_2013.m determine size of data matrices by 
%      determining maximum number of pressure levels of all stations:
counter = 0;
FORGET = 0;
for n=1:numProfiles;
    [tmpry.data, tmpry.names, ~,~,~, ~, ~, ~, ~, ~]= Stage_14b_cnv2mat_2013([Pname_in,'/',profileList(n).name]);
    ii=1;
    while isempty(regexp(tmpry.names(ii,:),'Pressure', 'once'))==1
        ii=ii+1;
    end
    if isempty(tmpry.data)==0
        tmpry.maxdepth(n,1) = max(tmpry.data(:,ii));
        tmpry.maxlength(n,1) = size(tmpry.data,1);
    else 
        counter = counter +1;
        FORGET(counter,1) = n;
    end
end
dataPressureLength = max(tmpry.maxlength);
clear tmpry
%
% 3.c) set up structured array using the size of the data from 3.b:
dataCTD.sciTime         = nan(1,numProfiles);
dataCTD.latitude        = nan(1,numProfiles);
dataCTD.longitude       = nan(1,numProfiles);
dataCTD.profileNo       = nan(1,numProfiles);
dataCTD.Station         = {};
dataCTD.timeUTC         = {};

dataCTD.t090C           = nan(dataPressureLength,numProfiles);
dataCTD.sal00           = nan(dataPressureLength,numProfiles);
dataCTD.c0mS            = nan(dataPressureLength,numProfiles);

dataCTD.Fluorescence    = nan(dataPressureLength,numProfiles);
dataCTD.Turbidity       = nan(dataPressureLength,numProfiles);
dataCTD.Oxygen          = nan(dataPressureLength,numProfiles);
dataCTD.sbeox0          = nan(dataPressureLength,numProfiles);
dataCTD.maxDepth        = nan(1,numProfiles);
dataCTD.minDepth        = nan(1,numProfiles);
dataCTD.Pressure        = nan(dataPressureLength,numProfiles);
dataCTD.Depth           = nan(dataPressureLength,numProfiles);

switch unique_sensor
    case 'False' % in case there are two CT sensors
        dataCTD.t190C   = nan(dataPressureLength,numProfiles);
        dataCTD.sal11   = nan(dataPressureLength,numProfiles);
        dataCTD.c1mS    = nan(dataPressureLength,numProfiles); 
        dataCTD.sbeox1  = nan(dataPressureLength,numProfiles);
end

Fields = fieldnames(dataCTD);

% 3.d) use Stage_14b_cnv2mat_2013 to import cnv files into matlab, and uses 
%      the names in the headers to allocate the data to the corresponding 
%      field variable names in the structure dataCTD:
for n=1:numProfiles;
    if sum(FORGET==n)==0
        % import cnv files:
        if n == 1
            [tmpry.data, names, ~,~,~,~,~,tmpry.timeUTC, tmpry.cruise, tmpry.station]= Stage_14b_cnv2mat_2013([Pname_in,'/',profileList(n).name]);
        else
            [tmpry.data, ~, ~,~,~,~,~,tmpry.timeUTC, ~, tmpry.station]= Stage_14b_cnv2mat_2013([Pname_in,'/',profileList(n).name]);
        end
        % for each field in dataCTD, find the index where variable name in
        % "names" matches the field variable name, and assign the data from the corresponding index:
        for n2=1:size(Fields,1)
            ii=1;
            if strcmpi(Fields{n2},'sal00')==1 || strcmpi(Fields{n2},'sal11')==1
                while isempty(regexp(names(ii,:),Fields{n2}, 'once'))==1 && ii<size(names,1)
                    ii=ii+1;
                end
                ii=ii+1;
                while isempty(regexp(names(ii,:),Fields{n2}, 'once'))==1 && ii<size(names,1)
                    ii=ii+1;
                end
            else
                while isempty(regexp(names(ii,:),Fields{n2}, 'once'))==1 && ii<size(names,1)
                    ii=ii+1;
                end
            end
            if ii~=size(names,1)
                if size(dataCTD.(Fields{n2}),1) == 1
                    dataCTD.(Fields{n2})(1,n) = nanmean(tmpry.data(:,ii));
                else
                    dataCTD.(Fields{n2})(1:size(tmpry.data(:,ii),1),n) = tmpry.data(:,ii);
                end
            end
        end
        dataCTD.profileNo(1,n)  = n;
        dataCTD.Station{1,n}    = strrep(tmpry.station,' ','');
        dataCTD.sciTime(1,n)    = datenum(tmpry.timeUTC, 'mmm dd yyyy HH:MM:SS'); %produces matlab time
        dataCTD.timeUTC{1,n}    = tmpry.timeUTC;
        dataCTD.maxDepth(1,n)   = max(dataCTD.Depth(:,n));
        dataCTD.minDepth(1,n)   = min(dataCTD.Depth(:,n));

        clear tmpry
    end
end
  

%% 4. Apply corrections:
%
% 4.a) ...to conductivity, and use this to derive salinity:
if isfield(meta,'COND_01_CORR')==1
    dataCTD.Corrected.COND_01 = dataCTD.c0mS.*A00;
    dataCTD.Corrected.SALT_01 = gsw_SP_from_C(dataCTD.Corrected.COND_01,dataCTD.t090C,dataCTD.Pressure);
end
if isfield(meta,'COND_02_CORR')==1
    dataCTD.Corrected.COND_02 = dataCTD.c1mS.*B11;
    dataCTD.Corrected.SALT_02 = gsw_SP_from_C(dataCTD.Corrected.COND_02,dataCTD.t190C,dataCTD.Pressure);
end
%
% 4.b) ...and to provide potential temperature:
p_ref = 0;
if isfield(meta,'COND_01_CORR')==1
    dataCTD.Corrected.ptemp_01 = sw_ptmp(dataCTD.Corrected.SALT_01,dataCTD.t090C,dataCTD.Pressure,p_ref);      
    dataCTD.ptemp_01 = sw_ptmp(dataCTD.sal00,dataCTD.t090C,dataCTD.Pressure,p_ref);      
end
if isfield(meta,'COND_02_CORR')==1
    dataCTD.Corrected.ptemp_02 = sw_ptmp(dataCTD.Corrected.SALT_02,dataCTD.t190C,dataCTD.Pressure,p_ref);      
    dataCTD.ptemp_02 = sw_ptmp(dataCTD.sal11,dataCTD.t190C,dataCTD.Pressure,p_ref);     
end

    
%% 5. Save as .mat file:
% fname_out = [CruiseName{1},fname_out_part];
fname_out = [deploymentName,fname_out_part];
save([Pname_out_MAT,fname_out],'dataCTD')
