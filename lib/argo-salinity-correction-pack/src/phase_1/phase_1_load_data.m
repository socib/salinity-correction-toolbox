function [ArgoNcFilesList, ArgoDataFile, CtdCorrDataFile, Campaign, TESTdat, global_meta, CTD, buttonMC, depNUM_argo] = phase_1_load_data(InstrumentID)

global MainPath
global EXT_ARGO

%% list CTD corrected nc files available in thredds, store it in a mat file and load it later
%list_nc_files_dataDiscovery(InstrumentID.ctdInstrumentID, 'ctdCorrNcFilesList.mat')

[CtdNcFilesList, CtdCorrDataFile] = load_nc_files_list(MainPath.db, 'ctdCorrNcFilesList_dm.mat', 'ctd');
% Extract information from vessel, instrument, dates etc about the CTD
% corrected file name to be compared with FLDS
for i = 1 : size(CtdCorrDataFile.name, 1)
    CtdCorrDataFile.info{i,1} = strsplit(CtdCorrDataFile.name{i}, {'_', '.'}); 
    CtdCorrDataFile.info{i,1} = strrep(CtdCorrDataFile.info{i,1}, '-', '');
end


%% list argo nc files available in thredds, store it in a mat file and load
% it later
switch EXT_ARGO
    case 0
        list_nc_files_dataDiscovery(InstrumentID.argoInstrumentID, 'argoNcFilesList.mat')
        [ArgoNcFilesList, ArgoDataFile] = load_nc_files_list(MainPath.db, 'argoNcFilesList.mat', 'argo');
    case 1
        ArgoNcFilesList = [];
        ArgoDataFile = [];
end


%% 1.c load ARGO to be calibrated
disp('loading data ... ')
switch EXT_ARGO
    case 0
        argoDataFilePath = char(ArgoDataFile.path{1});
        [data, meta, global_meta] = loadnc(argoDataFilePath);
        %[data, meta, global_meta] = loadnc('http://thredds.socib.es/thredds/dodsC/drifter/profiler_drifter/profiler_drifter_arvorl003-ieo_arvorl001/L1/2019/dep0002_profiler-drifter-arvorl003_ieo-arvorl001_L1_2019-07-31.nc');
        % gather ARGO campaign information:
        tmpry = strsplit(argoDataFilePath,{'/','.nc'});
        Campaign.Test = tmpry{length(tmpry)-1};
        clear tmpry
        ArgoFileInfo = strsplit(Campaign.Test,'_');
        Campaign.testMeta = meta;
        Campaign.testGlobalMeta = global_meta;
        
    case 1
        argoDataFilePath = '/home/cmunoz/Desktop/Archive/spray_18505901_bin.mat';
        load (argoDataFilePath)
        data = bindata;
        meta = [];
        global_meta = [];
        Campaign.Test = 'spray_18505901_bin.mat';
        ArgoFileInfo{1} = 'dep0001';
        ArgoFileInfo{2} = 'spray02';
        ArgoFileInfo{3} = 'onc-spray002';
        ArgoFileInfo{5} = '2018-05-24';
end

Campaign.testDeploymentCode = ArgoFileInfo{1};
Campaign.testDeploymentDate = ArgoFileInfo{5};
Campaign.testPlatformName = ArgoFileInfo{2};
Campaign.testInstrumentName = ArgoFileInfo{3};


% set ancillary paths and create output folders in case they don't exist
argo_sc_set_ancillary_paths(Campaign, CtdCorrDataFile)
create_out_directories;

%% 2f) Argo test data: establish which variables to use for the correction:

% TESTdat.S = data.SALT;
% TESTdat.T = data.WTR_TEM;
% TESTdat.Pr = data.WTR_PRE;
% TESTdat.C = gsw_C_from_SP(TESTdat.S, TESTdat.T, TESTdat.Pr);
% 
% TESTdat.PT      = sw_ptmp(TESTdat.S,TESTdat.T,TESTdat.Pr,0);
% 
% TESTdat.timeNUM  = data.time/(60*60*24)  + datenum(1970,1,1,0,0,0) ; % sciTime to matlab time
% TESTdat.Lat     = data.LAT;
% TESTdat.Lon     = data.LON;

% After checking the spatial and time correspondence between the datasets,
% define the number of cycles to be compared.
Start_data = 1;
End_data = length(data.time);
TESTdat.S = data.SALT(Start_data:End_data,:);
TESTdat.T = data.WTR_TEM(Start_data:End_data,:);
TESTdat.Pr = data.WTR_PRE(Start_data:End_data,:);
TESTdat.C = gsw_C_from_SP(TESTdat.S(1:(End_data-Start_data+1),:), TESTdat.T(1:(End_data-Start_data+1),:), TESTdat.Pr(1:(End_data-Start_data+1),:));

%% Variables extraction

TESTdat.PT      = sw_ptmp(TESTdat.S(1:(End_data-Start_data+1),:),TESTdat.T(1:(End_data-Start_data+1),:),TESTdat.Pr(1:(End_data-Start_data+1),:),0);

TESTdat.timeNUM  = data.time/(60*60*24)  + datenum(1970,1,1,0,0,0) ; % sciTime to matlab time
TESTdat.timeNUM  = TESTdat.timeNUM(Start_data:End_data);
TESTdat.Lat     = data.LAT(Start_data:End_data,:);
TESTdat.Lon     = data.LON(Start_data:End_data,:);

%Reshape files to adapt to the toolbox
TESTdat.S = reshape(TESTdat.S,[],1);
TESTdat.T = reshape(TESTdat.T,[],1);
TESTdat.Pr = reshape(TESTdat.Pr,[],1);
TESTdat.C = reshape(TESTdat.C,[],1);
TESTdat.PT = reshape(TESTdat.PT,[],1);
TESTdat.timeNUM = reshape(TESTdat.timeNUM,[],1);
TESTdat.Lat = reshape(TESTdat.Lat,[],1);
TESTdat.Lon = reshape(TESTdat.Lon,[],1);

TESTdat.timeUTC = (datestr(TESTdat.timeNUM,'mmm dd yyyy HH:MM:SS'));

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

% cruise names for background comparison to ARGO:
FLDS = fieldnames(CTD);
disp(FLDS)

%... and the start and end dates of the ARGO campaign:
% STARTdate = datestr((min(data.time)./(60^2*24))+datenum(1970,01,01));
% ENDdate   = datestr((max(data.time)./(60^2*24))+datenum(1970,01,01));
STARTdate = TESTdat.timeNUM(1);
ENDdate   = TESTdat.timeNUM(end);

%disp([datestr(STARTdate); datestr(ENDdate)])

%% 1.e Create map of ARGO trajectory, for comparison to background data:
mine = m_mapWMED(42,35,5,-5);
m_plot(TESTdat.Lon,TESTdat.Lat,'k.','linewidth',2);
%m_plot(data.longitude,data.latitude,'k.','linewidth',2);
title('ARGO float cruise path (black)','fontsize',16,'fontweight','b')
xhh = get(gca,'title');
set(xhh,'Position',get(xhh,'Position') + [0 0.004 0])


%% 2. provide recomendations of background data for the ARGO correction...
% should this be limited to ship data or should corrected ARGO data also
% be an option for the background data?
% The recommendations are based on: 
%       A) Location
%       B) Time

switch EXT_ARGO
    case 0
        % 2a) Test (ARGO) data Location (this comes from the meta data of the netcdf ARGO data that is downloaded from thredds:
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
        %... test (ARGO) region bndrys vector:
        

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
[Campaign.testSEASON,~] = SEASON_of_Cruise(Campaign,'ARGO',STARTdate);
%... & test year:
Campaign.testYEAR = str2double(datestr(STARTdate,'yyyy'));
%... & test start date:
Campaign.STARTdate = (datestr(STARTdate,'dd-mmm-yyyy'));

% 2e) background data Season... & background data year.... & background daa start date:
% for n=1:length(FLDS)
%     [bgrndRegions.(FLDS{n}).SEASON,bgrndRegions.(FLDS{n}).MNTHS] = SEASON_of_Cruise([],'ARGO',CTD.(FLDS{n}).timeUTC(CTD.(FLDS{n}).sciTime==min(CTD.(FLDS{n}).sciTime)));
%     bgrndRegions.(FLDS{n}).YR = str2double(datestr(CTD.(FLDS{n}).timeUTC(CTD.(FLDS{n}).sciTime==min(CTD.(FLDS{n}).sciTime)),'yyyy'));
%     bgrndRegions.(FLDS{n}).STARTdate = (datestr(CTD.(FLDS{n}).timeUTC(CTD.(FLDS{n}).sciTime==min(CTD.(FLDS{n}).sciTime)),'dd-mmm-yyyy'));
% end


%% 2g) Create TS diagram of all background ship data, with the uncorrected
% ARGO data on top:
depNUM_argo = strsplit(Campaign.Test,'_');
depNUM_argo = depNUM_argo{1};
%CtdCorrDataFile = TSdiags_from_Struct(1, 0, TESTdat, depNUM_ARGO, CtdCorrDataFile);
CtdCorrDataFile = TSdiags_from_Struct(1, 0, TESTdat, depNUM_argo, CtdCorrDataFile, CTD);

% % 2h) Use date and time and options in matching_cruise_recommendation.m to
% % provide recomendations and options for selecting background cruise data
% % for correction application.
% TYPE = 'ARGO';
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

fprintf(1,'Data loaded successfully, please proceed with whitespace maximisation. \n\n');
argo_salinity_correction_main
end
