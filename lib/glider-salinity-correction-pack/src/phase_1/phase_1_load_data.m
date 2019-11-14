function [GliderNcFilesList, GliderDataFile, CtdCorrDataFile, Campaign, TESTdat, global_meta, CTD, buttonMC, depNUM_glider] = phase_1_load_data(InstrumentID)

global MainPath
global EXT_GLIDER

%% list CTD corrected nc files available in thredds, store it in a mat file and load it later
%list_nc_files_dataDiscovery(InstrumentID.ctdInstrumentID, 'ctdCorrNcFilesList.mat')

[CtdNcFilesList, CtdCorrDataFile] = load_nc_files_list(MainPath.db, 'ctdCorrNcFilesList.mat', 'ctd');
% Extract information from vessel, instrument, dates etc about the CTD
% corrected file name to be compared with FLDS
for i = 1 : size(CtdCorrDataFile.name, 1)
    CtdCorrDataFile.info{i,1} = strsplit(CtdCorrDataFile.name{i}, {'_', '.'}); 
    CtdCorrDataFile.info{i,1} = strrep(CtdCorrDataFile.info{i,1}, '-', '');
end

%% list glider nc files available in thredds, store it in a mat file and load
% it later
switch EXT_GLIDER
    case 0
        % gliderPlatformID = [105, 106, 89, 107, 108, 84, 109, 290, 292];
        %list_nc_files_api('Glider', 'gliderNcFilesList.mat')
        [GliderNcFilesList, GliderDataFile] = load_nc_files_list(MainPath.db, 'gliderNcFilesList.mat', 'glider');
    case 1
        GliderNcFilesList = [];
        GliderDataFile = [];
end


%% 1.c load glider to be calibrated
disp('loading data ... ')
switch EXT_GLIDER
    case 0
        gliderDataFilePath = char(GliderDataFile.path{1});
        [data, meta, global_meta] = loadnc(gliderDataFilePath);
        %[data, meta, global_meta] = loadnc('http://thredds.socib.es/thredds/dodsC/drifter/profiler_drifter/profiler_drifter_arvorl003-ieo_arvorl001/L1/2019/dep0002_profiler-drifter-arvorl003_ieo-arvorl001_L1_2019-07-31.nc');
        % gather glider campaign information:
        tmpry = strsplit(gliderDataFilePath,{'/','.nc'});
        Campaign.Test = tmpry{length(tmpry)-1};
        clear tmpry
        GliderFileInfo = strsplit(Campaign.Test,'_');
        Campaign.testMeta = meta;
        Campaign.testGlobalMeta = global_meta;
        
    case 1
        gliderDataFilePath = '/home/cmunoz/Desktop/Archive/spray_18505901_bin.mat';
        load (gliderDataFilePath)
        data = bindata;
        meta = [];
        global_meta = [];
        Campaign.Test = 'spray_18505901_bin.mat';
        GliderFileInfo{1} = 'dep0001';
        GliderFileInfo{2} = 'spray02';
        GliderFileInfo{3} = 'onc-spray002';
        GliderFileInfo{5} = '2018-05-24';
end

Campaign.testDeploymentCode = GliderFileInfo{1};
Campaign.testDeploymentDate = GliderFileInfo{5};
Campaign.testPlatformName = GliderFileInfo{2};
Campaign.testInstrumentName = GliderFileInfo{3};


% set ancillary paths and create output folders in case they don't exist
glider_sc_set_ancillary_paths(Campaign, CtdCorrDataFile)
create_out_directories;

%% 2f) Glider test data: establish which variables to use for the correction:
prompt = {'first idx:','last idx:'};
dlgtitle = 'data indices';
dims = [1 35];
RANGE = length(data.temperature);

%select idx ranges in case you want to load just a section in parrticular
definput = {'1',num2str(RANGE)};
answer = inputdlg(prompt,dlgtitle,dims,definput);
idx_start = str2num(answer{1});
idx_end = str2num(answer{2});

switch EXT_GLIDER
    case 0
        if isfield(data,'salinity_corrected_thermal')==1
            TESTdat.S    = data.salinity_corrected_thermal(idx_start:idx_end);                     % we use salinity corrected thermal, which has been derived from a conductivity which is corrected using a corrected temperature
            TESTdat.T    = data.temperature(idx_start:idx_end);                                    % the thermal lag corrected salinity is the correction required for the salinity to "match" the in situ temperature, so we use temperature and not the thermal lag corrected temperature 
            TESTdat.Tcor = data.temperature_corrected_thermal(idx_start:idx_end);                  % this is te value that was created to help derive a salinity corrected thermal, but should not be used in conjunction with salinity_corrected_thermal
            TESTdat.C_orig    = data.conductivity(idx_start:idx_end);                              % this is the in-situ conductivity
            TESTdat.C    = gsw_C_from_SP(TESTdat.S,TESTdat.T,data.pressure);    % we back-derive conductivity from the corrected salinity and in-situ temperature in order to get a thermal lag corrected salinity
            metC = meta.conductivity;
            metS = meta.salinity_corrected_thermal;
        else
            TESTdat.S = data.salinity(idx_start:idx_end);
            TESTdat.T = data.temperature(idx_start:idx_end);
            TESTdat.C = data.conductivity(idx_start:idx_end);
            metC = meta.conductivity;
        end 
        TESTdat.prof_dir    = data.profile_direction;
        for n= 1:length(metC.attributes)
            if strcmpi(metC.attributes(n).name,'units')==1
                break
            end
        end
        if strcmpi(metC.attributes(n).name,'units')==1 && strcmpi(metC.attributes(n).value,'S m-1')==1 && isfield(TESTdat,'C_orig')==0
            TESTdat.C = TESTdat.C.*10;
        elseif strcmpi(metC.attributes(n).name,'units')==1 && strcmpi(metC.attributes(n).value,'S m-1')==1 && isfield(TESTdat,'C_orig')==1
            TESTdat.C_orig = TESTdat.C_orig.*10;
        end
        
        Campaign.testregion.maxLon = global_meta.attributes(n).value;
        if strcmp(Campaign.Test,'dep0006_ideep02_ime-sldeep002_L1_2015-03-16_data_dt') == 0
            TESTdat.Pr = data.pressure(idx_start:idx_end);
        else
            %%%% this was a bad pressure mission - need to set up a spreadsheet
            %%%% that keeps track if this occurence...
            TESTdat.Pr = data.pressure(idx_start:idx_end) + 2.951;
            TESTdat.S  = sw_salt(TESTdat.C*(10 /sw_c3515()), TESTdat.T, TESTdat.Pr);% Conductivity from sw_c3515 is in mS/cm,
            disp('Salinity is recalculated after pressure adjustment using conductivity, adjusted pressure and adjusted temp inside the cell (thermal lag correction)'); 
        end
        TESTdat.PT      = sw_ptmp(TESTdat.S,TESTdat.T,TESTdat.Pr,0);
        if isfield(data,'time_ctd')
            TESTdat.timeNUM = data.time_ctd(idx_start:idx_end)/(60*60*24)  + datenum(1970,1,1,0,0,0); 
        else
            TESTdat.timeNUM  = data.time(idx_start:idx_end)/(60*60*24)  + datenum(1970,1,1,0,0,0) ; % sciTime to matlab time
        end
        TESTdat.Lat     = data.latitude(idx_start:idx_end);
        TESTdat.Lon     = data.longitude(idx_start:idx_end);
        % remove nans:
        r = isnan(TESTdat.S)==1 | isnan(TESTdat.T)==1 | isnan(TESTdat.PT)==1 | isnan(TESTdat.C)==1 | isnan(TESTdat.Pr)==1;
        FLDtest = fieldnames(TESTdat);
        for n1 = 1:length(FLDtest)
            TESTdat.(FLDtest{n1})(r) = [];
        end
        clear r
        TESTdat.timeUTC = (datestr(TESTdat.timeNUM,'mmm dd yyyy HH:MM:SS'));
        
    case 1
        TESTdat.S       = data.s;
        TESTdat.T       = data.t;
        TESTdat.timeNUM = data.time/(60*60*24)  + datenum(1970,1,1,0,0,0);
        TESTdat.Lat     = data.lat;
        TESTdat.Lon     = data.lon;
        TESTdat.PT      = data.theta;
        TESTdat.Pr      = gsw_p_from_z(-data.depth, mean(min(data.lat)));
        TESTdat.C       = gsw_C_from_SP(bindata.s, bindata.t, TESTdat.Pr);
        
        % remove nans:
        
%         FLDtest = fieldnames(TESTdat);
%         for n1 = 1:length(FLDtest)
%             r = isnan(TESTdat.(FLDtest{n1}))==1;
%             TESTdat.(FLDtest{n1})(r) = [];
%         end
%         clear r
        TESTdat.timeUTC = (datestr(TESTdat.timeNUM,'mmm dd yyyy HH:MM:SS'));
end

%% Load CTD data selected

% Obtain length of all profiles from different files
lenAllProfiles = [];
for i = 1 : size(CtdCorrDataFile.path,1)
    CtdCorrDataFilePath    = CtdCorrDataFile.path{i,1}{1,1};
    dum = ncread(CtdCorrDataFilePath,'SALT_01_CORR');
    lengthSingleProfile = size(dum,1);
    lenAllProfiles =[lenAllProfiles lengthSingleProfile];
end

% Read variables and merge values in case multifiles selected
CTD.Corrected.SALT_01 = double.empty(max(lenAllProfiles),0);
CTD.Corrected.SALT_02 = double.empty(max(lenAllProfiles),0);
CTD.Corrected.COND_01 = double.empty(max(lenAllProfiles),0);
CTD.Corrected.COND_02 = double.empty(max(lenAllProfiles),0);
% CTD.Corrected.LAT = double.empty(max(lenAllProfiles),0);
% CTD.Corrected.LON = double.empty(max(lenAllProfiles),0);
CTD.pressure = double.empty(max(lenAllProfiles),0);
CTD.temp_01 = double.empty(max(lenAllProfiles),0);
CTD.temp_02 = double.empty(max(lenAllProfiles),0);

for i = 1:size(CtdCorrDataFile.path,1)
    CtdCorrDataFilePath    = CtdCorrDataFile.path{i,1}{1,1};
    finfo                  = ncinfo(CtdCorrDataFilePath);
    
    SALT_01                = ncread(CtdCorrDataFilePath,'SALT_01_CORR');
    COND_01                = ncread(CtdCorrDataFilePath,'COND_01_CORR');
    LAT                    = ncread(CtdCorrDataFilePath,'LAT');
    LON                    = ncread(CtdCorrDataFilePath,'LON');
    PRESS                  = ncread(CtdCorrDataFilePath,'WTR_PRE');
    TEMP_01                = ncread(CtdCorrDataFilePath,'WTR_TEM_01');
    try
        SALT_02                = ncread(CtdCorrDataFilePath,'SALT_02_CORR');
        COND_02                = ncread(CtdCorrDataFilePath,'COND_02_CORR');
        TEMP_02                = ncread(CtdCorrDataFilePath,'WTR_TEM_02');
    catch
    end
    if ~exist('SALT_02','var')
        CTD.Corrected = rmfield(CTD.Corrected,'SALT_02');
        CTD.Corrected = rmfield(CTD.Corrected,'COND_02');
        CTD = rmfield(CTD,'temp_02');
    end
    
        

    
    if range(lenAllProfiles) == 1 % check if all elements are different
        
        if size(SALT_01,1) < max(lenAllProfiles)
            n = max(lenAllProfiles) - size(SALT_01,1);
        end 

        if i == 1   
            SALT_01     = [SALT_01; NaN(n,size(SALT_01,2))];           
            COND_01     = [COND_01; NaN(n,size(COND_01,2))];       
            PRESS       = [PRESS; NaN(n,size(PRESS,2))];
            TEMP_01     = [TEMP_01; NaN(n,size(TEMP_01,2))];           
            CTD.Corrected.SALT_01   = SALT_01;           
            CTD.Corrected.COND_01   = COND_01;          
            CTD.latitude            = LAT;
            CTD.longitude           = LON;
            CTD.pressure            = PRESS;       
            CTD.temp_01             = TEMP_01;
                     
            if exist('SALT_02','var') == 1
                SALT_02     = [SALT_02; NaN(n,size(SALT_02,2))];
                COND_02     = [COND_02; NaN(n,size(COND_02,2))];
                TEMP_02     = [TEMP_02; NaN(n,size(TEMP_02,2))];
                CTD.Corrected.SALT_02   = SALT_02;
                CTD.Corrected.COND_02   = COND_02;
                CTD.temp_02             = TEMP_02;
            end
        else
            CTD.Corrected.SALT_01 = [CTD.Corrected.SALT_01 SALT_01];          
            CTD.Corrected.COND_01 = [CTD.Corrected.COND_01 COND_01];          
            CTD.latitude = [CTD.latitude; LAT];
            CTD.longitude = [CTD.longitude; LON];
            CTD.pressure = [CTD.pressure PRESS];      
            CTD.temp_01 = [CTD.temp_01 TEMP_01];          
            if exist('SALT_02','var') == 1
                CTD.Corrected.SALT_02 = [CTD.Corrected.SALT_02 SALT_02];
                CTD.Corrected.COND_02 = [CTD.Corrected.COND_02 COND_02];
                CTD.temp_02 = [CTD.temp_02 TEMP_02];
            end
                
        end
        
    elseif range(lenAllProfiles) == 0 % check if all elements are the same
        if i == 1    
            CTD.Corrected.SALT_01   = SALT_01;           
            CTD.Corrected.COND_01   = COND_01;           
            CTD.latitude            = LAT;
            CTD.longitude           = LON;
            CTD.pressure            = PRESS;       
            CTD.temp_01             = TEMP_01;
             
            if exist('SALT_02','var') == 1
                CTD.Corrected.SALT_02   = SALT_02;
                CTD.Corrected.COND_02   = COND_02;
                CTD.temp_02             = TEMP_02;
            end
        else
            CTD.Corrected.SALT_01 = [CTD.Corrected.SALT_01 SALT_01];           
            CTD.Corrected.COND_01 = [CTD.Corrected.COND_01 COND_01];           
            CTD.latitude = [CTD.latitude; LAT];
            CTD.longitude = [CTD.longitude; LON];
            CTD.pressure = [CTD.pressure PRESS];      
            CTD.temp_01 = [CTD.temp_01 TEMP_01];
              
            if exist('SALT_02','var') == 1
                CTD.Corrected.SALT_02 = [CTD.Corrected.SALT_02 SALT_02];
                CTD.Corrected.COND_02 = [CTD.Corrected.COND_02 COND_02];
                CTD.temp_02 = [CTD.temp_02 TEMP_02];
            end
        end
    end
        
end
CTD.depth =  -1.*gsw_z_from_p(CTD.pressure,CTD.latitude);
p_ref = 0;
CTD.Corrected.ptemp_01 = sw_ptmp(CTD.Corrected.SALT_01, CTD.temp_01, CTD.pressure, p_ref);
if exist('SALT_02','var') == 1
    CTD.Corrected.ptemp_02 = sw_ptmp(CTD.Corrected.SALT_02, CTD.temp_02, CTD.pressure, p_ref);
end

% %load SHIP_allDATA_halfm_corrected.mat
% %load([MainPath.dataHalfmCtdCorrected,'SHIP_allDATA_halfm_corrected.mat'])
% CtdCorrDataFilePath    = CtdCorrDataFile.path{1,1}{1,1};
% finfo    = ncinfo(CtdCorrDataFilePath);
% CTD.Corrected.SALT_01 = ncread(CtdCorrDataFilePath,'SALT_01_CORR');
% CTD.Corrected.SALT_02 = ncread(CtdCorrDataFilePath,'SALT_02_CORR');
% CTD.Corrected.COND_01 = ncread(CtdCorrDataFilePath,'COND_01_CORR');
% CTD.Corrected.COND_02 = ncread(CtdCorrDataFilePath,'COND_02_CORR');
% CTD.latitude =  ncread(CtdCorrDataFilePath,'LAT');
% CTD.longitude =  ncread(CtdCorrDataFilePath,'LON');
% CTD.pressure =  ncread(CtdCorrDataFilePath,'WTR_PRE');
% CTD.depth =  -1.*gsw_z_from_p(CTD.pressure,CTD.latitude);
% CTD.temp_01 = ncread(CtdCorrDataFilePath,'WTR_TEM_01');
% CTD.temp_02 = ncread(CtdCorrDataFilePath,'WTR_TEM_02');
% CTD.SALT_01 = ncread(CtdCorrDataFilePath,'SALT_01');
% CTD.SALT_02 = ncread(CtdCorrDataFilePath,'SALT_02');
%p_ref = 0;
% CTD.Corrected.ptemp_01 = sw_ptmp(CTD.SALT_01, CTD.temp_01, CTD.pressure, p_ref);
% CTD.Corrected.ptemp_02 = sw_ptmp(CTD.SALT_02, CTD.temp_02, CTD.pressure, p_ref);

% cruise names for background comparison to glider:
FLDS = fieldnames(CTD);
disp(FLDS)

%... and the start and end dates of the glider campaign:
% STARTdate = datestr((min(data.time)./(60^2*24))+datenum(1970,01,01));
% ENDdate   = datestr((max(data.time)./(60^2*24))+datenum(1970,01,01));
STARTdate = TESTdat.timeNUM(1);
ENDdate   = TESTdat.timeNUM(end);

disp([datestr(STARTdate); datestr(ENDdate)])

%% 1.e Create map of glider trajectory, for comparison to background data:
mine = m_mapWMED(42,35,5,-5);
m_plot(TESTdat.Lon,TESTdat.Lat,'k.','linewidth',2);
%m_plot(data.longitude,data.latitude,'k.','linewidth',2);
title('Glider cruise path (black)','fontsize',16,'fontweight','b')
xhh = get(gca,'title');
set(xhh,'Position',get(xhh,'Position') + [0 0.004 0])


%% 2. provide recomendations of background data for the glider correction...
% should this be limited to ship data or should corrected glider data also
% be an option for the background data?
% The recommendations are based on: 
%       A) Location
%       B) Time

switch EXT_GLIDER
    case 0
        % 2a) Test (glider) data Location (this comes from the meta data of the netcdf glider data that is downloaded from thredds:
        for n= 1:length(global_meta.attributes)
            if strcmpi(global_meta.attributes(n).name,'geospatial_lat_min')==1
                break
            end
        end
        Campaign.testregion.minLat = global_meta.attributes(n).value;
        for n= 1:length(global_meta.attributes)
            if strcmpi(global_meta.attributes(n).name,'geospatial_lat_max')==1
                break
            end
        end
        Campaign.testregion.maxLat = global_meta.attributes(n).value;
        for n= 1:length(global_meta.attributes)
            if strcmpi(global_meta.attributes(n).name,'geospatial_lon_min')==1
                break
            end
        end
        Campaign.testregion.minLon = global_meta.attributes(n).value;
        for n= 1:length(global_meta.attributes)
            if strcmpi(global_meta.attributes(n).name,'geospatial_lon_max')==1
                break
            end
        end
        Campaign.testregion.maxLon = global_meta.attributes(n).value;
        %... test (glider) region bndrys vector:
        

    case 1
        Campaign.testregion.minLat = min(data.lat);
        Campaign.testregion.maxLat = max(data.lat);
        Campaign.testregion.minLon = min(data.lon);
        Campaign.testregion.maxLon = max(data.lon);
end
tmpryTest = [Campaign.testregion.minLat,Campaign.testregion.maxLat,Campaign.testregion.minLon,Campaign.testregion.maxLon];

%% 2b) background data location:
for n=1:length(FLDS)
%     bgrndRegions.(FLDS{n}).lat_min = min(min(CTD.(FLDS{n}).latitude));
%     bgrndRegions.(FLDS{n}).lat_max = max(max(CTD.(FLDS{n}).latitude));
%     bgrndRegions.(FLDS{n}).lon_min = min(min(CTD.(FLDS{n}).longitude));
%     bgrndRegions.(FLDS{n}).lon_max = max(max(CTD.(FLDS{n}).longitude));
    bgrndRegions.(FLDS{n}).lat_min = min(min(CTD.latitude));
    bgrndRegions.(FLDS{n}).lat_max = max(max(CTD.latitude));
    bgrndRegions.(FLDS{n}).lon_min = min(min(CTD.longitude));
    bgrndRegions.(FLDS{n}).lon_max = max(max(CTD.longitude));
end
counter=1;
for n=1:length(FLDS)
    tmpry(counter,:) = [bgrndRegions.(FLDS{n}).lat_min,bgrndRegions.(FLDS{n}).lat_max,bgrndRegions.(FLDS{n}).lon_min,bgrndRegions.(FLDS{n}).lat_max];
    counter=counter+1;
end
%%%% 2c) Find, for each boundary constraint,the 10 closest cruise background data
% boundary cnstraints. (This is not a good way to do the location
% calculation..., how can we improve it?)
TMPRY(1,:) = knnsearch(tmpry(:,1),tmpryTest(1),'k',10);
TMPRY(2,:) = knnsearch(tmpry(:,2),tmpryTest(2),'k',10);
TMPRY(3,:) = knnsearch(tmpry(:,3),tmpryTest(3),'k',10);
TMPRY(4,:) = knnsearch(tmpry(:,4),tmpryTest(4),'k',10);

res = [1:length(FLDS); histc(TMPRY(:)', 1:length(FLDS))]';
sortedres = sortrows(res, -2); % sort by second column, descending
first10 = sortedres(1:length(FLDS), :); % 8 best matching cruise regions
clear tmpry

%2d) Test Season:
[Campaign.testSEASON,~] = SEASON_of_Cruise(Campaign,'GLIDER',STARTdate);
%... & test year:
Campaign.testYEAR = str2double(datestr(STARTdate,'yyyy'));
%... & test start date:
Campaign.STARTdate = (datestr(STARTdate,'dd-mmm-yyyy'));

% 2e) background data Season... & background data year.... & background daa start date:
% for n=1:length(FLDS)
%     [bgrndRegions.(FLDS{n}).SEASON,bgrndRegions.(FLDS{n}).MNTHS] = SEASON_of_Cruise([],'GLIDER',CTD.(FLDS{n}).timeUTC(CTD.(FLDS{n}).sciTime==min(CTD.(FLDS{n}).sciTime)));
%     bgrndRegions.(FLDS{n}).YR = str2double(datestr(CTD.(FLDS{n}).timeUTC(CTD.(FLDS{n}).sciTime==min(CTD.(FLDS{n}).sciTime)),'yyyy'));
%     bgrndRegions.(FLDS{n}).STARTdate = (datestr(CTD.(FLDS{n}).timeUTC(CTD.(FLDS{n}).sciTime==min(CTD.(FLDS{n}).sciTime)),'dd-mmm-yyyy'));
% end
% 2f) Glider test data: establish which variables to use for the correction:
if isfield(data,'salinity_corrected_thermal')==1
    TESTdat.S    = data.salinity_corrected_thermal(idx_start:idx_end);                     % we use salinity corrected thermal, which has been derived from a conductivity which is corrected using a corrected temperature
    TESTdat.T    = data.temperature(idx_start:idx_end);                                    % the thermal lag corrected salinity is the correction required for the salinity to "match" the in situ temperature, so we use temperature and not the thermal lag corrected temperature 
    TESTdat.Tcor = data.temperature_corrected_thermal(idx_start:idx_end);                  % this is te value that was created to help derive a salinity corrected thermal, but should not be used in conjunction with salinity_corrected_thermal
    TESTdat.C_orig    = data.conductivity(idx_start:idx_end);                              % this is the in-situ conductivity
    TESTdat.C    = gsw_C_from_SP(TESTdat.S,TESTdat.T,data.pressure);    % we back-derive conductivity from the corrected salinity and in-situ temperature in order to get a thermal lag corrected salinity
    metC = meta.conductivity;
    metS = meta.salinity_corrected_thermal;
else
    switch EXT_GLIDER
        case 0
            TESTdat.S = data.salinity(idx_start:idx_end);
            TESTdat.T = data.temperature(idx_start:idx_end);
            TESTdat.C = data.conductivity(idx_start:idx_end);
            metC = meta.conductivity;
    end
end 
TESTdat.prof_dir    = data.profile_direction(idx_start:idx_end);
switch EXT_GLIDER
    case 0       
        for n= 1:length(metC.attributes)
            if strcmpi(metC.attributes(n).name,'units')==1
                break
            end
        end
        if strcmpi(metC.attributes(n).name,'units')==1 && strcmpi(metC.attributes(n).value,'S m-1')==1 && isfield(TESTdat,'C_orig')==0
            TESTdat.C = TESTdat.C.*10;
        elseif strcmpi(metC.attributes(n).name,'units')==1 && strcmpi(metC.attributes(n).value,'S m-1')==1 && isfield(TESTdat,'C_orig')==1
            TESTdat.C_orig = TESTdat.C_orig.*10;
        end

        Campaign.testregion.maxLon = global_meta.attributes(n).value;
        if strcmp(Campaign.Test,'dep0006_ideep02_ime-sldeep002_L1_2015-03-16_data_dt')==0
            TESTdat.Pr = data.pressure(idx_start:idx_end);
        else
            %%%% this was a bad pressure mission - need to set up a spreadsheet
            %%%% that keeps track if this occurence...
            TESTdat.Pr = data.pressure(idx_start:idx_end) + 2.951;
            TESTdat.S  = sw_salt(TESTdat.C*(10 /sw_c3515()), TESTdat.T, TESTdat.Pr);% Conductivity from sw_c3515 is in mS/cm,
            disp('Salinity is recalculated after pressure adjustment using conductivity, adjusted pressure and adjusted temp inside the cell (thermal lag correction)'); 
        end
        TESTdat.PT      = sw_ptmp(TESTdat.S,TESTdat.T,TESTdat.Pr,0);
        if isfield(data,'time_ctd')
            TESTdat.timeNUM = data.time_ctd(idx_start:idx_end)/(60*60*24)  + datenum(1970,1,1,0,0,0); 
        else
            TESTdat.timeNUM  = data.time(idx_start:idx_end)/(60*60*24)  + datenum(1970,1,1,0,0,0) ; % sciTime to matlab time
        end
        TESTdat.Lat     = data.latitude(idx_start:idx_end);
        TESTdat.Lon     = data.longitude(idx_start:idx_end);
%         % remove nans:
%         r = isnan(TESTdat.S)==1 | isnan(TESTdat.T)==1 | isnan(TESTdat.PT)==1 | isnan(TESTdat.C)==1 | isnan(TESTdat.Pr)==1;
%         FLDtest = fieldnames(TESTdat);
%         for n1 = 1:length(FLDtest)
%             TESTdat.(FLDtest{n1})(r) = [];
%         end
%         clear r
%        TESTdat.timeUTC = (datestr(TESTdat.timeNUM,'mmm dd yyyy HH:MM:SS'));
end
%clear data

%% 2g) Create TS diagram of all background ship data, with the uncorrected
% glider data on top:
depNUM_glider = strsplit(Campaign.Test,'_');
depNUM_glider = depNUM_glider{1};
%CtdCorrDataFile = TSdiags_from_Struct(1, 0, TESTdat, depNUM_glider, CtdCorrDataFile);
CtdCorrDataFile = TSdiags_from_Struct(1, 0, TESTdat, depNUM_glider, CtdCorrDataFile, CTD);

% % 2h) Use date and time and options in matching_cruise_recommendation.m to
% % provide recomendations and options for selecting background cruise data
% % for correction application.
% TYPE = 'GLIDER';
% [Campaign,~] = Matching_Cruise_recommendation(Campaign,TYPE,bgrndRegions,first10);

% expression = ['dep(\d{4})_',CtdCorrDataFile.info{1,1}{1,2},'_',CtdCorrDataFile.info{1,1}{1,3},'_(\d{8})'];
% for n = 1:length(Campaign.COMP)
%     [tok,matchStr] = regexp(Campaign.COMP{n},expression, 'tokens', 'tokenExtents');
%     Campaign.DEP{n,1} = tok{1,1}{1,1};
%     Campaign.DATE{n,1} = tok{1,1}{1,2};
% end

COMP = {};
for n = 1: length(CtdCorrDataFile.info)
    COMP{n} = [CtdCorrDataFile.info{n,1}{1,1}, '_' , ...
                CtdCorrDataFile.info{n,1}{1,2}, '_', ...
                CtdCorrDataFile.info{n,1}{1,3}, '_', ...
                CtdCorrDataFile.info{n,1}{1,6}];
end
Campaign.COMP = COMP;

% Campaign.COMP = [CtdCorrDataFile.info{1,1}{1,1}, '_' , ...
%                 CtdCorrDataFile.info{1,1}{1,2}, '_', ...
%                 CtdCorrDataFile.info{1,1}{1,3}, '_', ...
%                 CtdCorrDataFile.info{1,1}{1,6}];
            
Campaign.DEP = CtdCorrDataFile.info{1,1}{1,1};
Campaign.DATE = CtdCorrDataFile.info{1,1}{1,6};

        
%% 2i) plot these cruises onto the map earlier - check how well the campaign
% paths match up, and the dates of the campaigns. If they're good enough,
% move on, else, recall the above "matching_cruise_recommendation" function.
figure(mine)
% Include Mallorca Channel data?
buttonMC = questdlg('Remove data from the Mallorca Channel?','Remove Mallorca Channel?','YES','NO','YES');

m_text(-4.5,41.5,{['---  ',strrep(Campaign.Test,'_','-')]},'linestyle','-', ...
    'edgecolor','k','color','k','fontweight','b','fontsize',12,'backgroundcolor',[0.5,0.5,0.5])
textUpLim = 41.2;
CC = colormap(jet(length(Campaign.COMP)));
hold on
RANGE = size(Campaign.COMP, 2);
for n = 1 : RANGE
    if RANGE == 1
        ctdCorrDep = char(Campaign.COMP);
    else
        ctdCorrDep = Campaign.COMP{n}; 
    end
%     m_plot(CTD.([ctdCorrDep]).longitude, CTD.([ctdCorrDep]).latitude, ...
%         '-*', 'linewidth', 2, 'color', CC(n,:));    
    m_plot(CTD.longitude, CTD.latitude, ...
        '-*', 'linewidth', 2, 'color', CC(n,:));

    m_text(-4.5, textUpLim, {['---  ',strrep(ctdCorrDep, '_', '-')]}, 'linestyle', ...
        '-', 'edgecolor', 'k', 'color', CC(n,:), 'fontweight', 'b', 'fontsize', ...
        12, 'backgroundcolor', [0.5,0.5,0.5])
    textUpLim = textUpLim-0.3;
end

fnameOut = 'cruise_location_map';
imageDir = MainPath.outFigsCorrection;
save_figure( fnameOut, imageDir, figure(mine) )

end
