function set_main_paths(correctionMethod)

%Salinity Correction Toolbox
global MainPath
global OPERATIONAL_MODE 
global ONLINE_MODE
global TEST_MODE 
global PORTABLE_MODE
global EXT_GLIDER
global WHITESPACE_SECTIONS
global PROFILE_DIR_SECTIONS


OPERATIONAL_MODE = 0;       % case running application in operational mode in SOCIB server. 0 means NO, 1 means YES
ONLINE_MODE = 1;            % case working in the office network
TEST_MODE = 0;              % case testing the application      
PORTABLE_MODE = 0;          % case working in another device such as a laptop
EXT_GLIDER = 0;             % case an external glider dataset with different format needs to be analysed
WHITESPACE_SECTIONS = 0;    % case glider whitespace is gonna be adjusted by sections defined in idxToPRocess
PROFILE_DIR_SECTIONS = 0;   % case glider whitespace is gonna be adjusted by sections defined in profile_directions


%% Toolbox main paths
switch OPERATIONAL_MODE
    case 1 % when working in the office network
        MainPath.mainToolbox = '';       
    case 0 % when NOT working in the office network
        switch PORTABLE_MODE
            case 0
                MainPath.mainToolbox = '/LOCALDATA/MATLAB/salinity-correction-toolbox/';
            case 1 
                MainPath.mainToolbox = 'C:/Users/socib/Documents/MATLAB/salinity-correction-toolbox/';
        end
end
MainPath.code = [MainPath.mainToolbox,'lib/']; % path to the source main toolbox code
MainPath.resources = [MainPath.mainToolbox,'res/']; % path to general toolbox resources like configuration files
MainPath.libraries = [MainPath.mainToolbox,'ext/']; % path to external libraries
MainPath.db = [MainPath.resources, 'db/']; % path to database functions or mat files containing lists of available resources from thredds

%% CTD salinity correction pack paths   
switch correctionMethod  
    case 'salinity_ctd'
        MainPath.correctionMethod = 'salinity_ctd';
        switch OPERATIONAL_MODE
            case 1 % when working in the office network
                MainPath.main = [MainPath.mainToolbox, 'lib/ctd-salinity-correction-pack/'];
                MainPath.dataCtdL1Thredds = [MainPath.main,''];
                MainPath.dataCtd = '';
                MainPath.dataPortasal = '';
                MainPath.dataCTDInsituCalHistory = '';

            case 0 % when NOT working in the office network
                MainPath.main = [MainPath.mainToolbox,'lib/ctd-salinity-correction-pack/'];
                switch PORTABLE_MODE
                    case 0 % primary device (office computer) 
                        MainPath.dataCtdL1Thredds = '/home/cmunoz/Desktop/ctd_nc_L1_thredds/';
                        MainPath.dataCtd = '/home/vessel/RTDATA/';
                        MainPath.dataPortasal = '/home/cmunoz/Desktop/vessel_portasal_data/';
                        MainPath.dataCTDInsituCalHistory = '';
                    case 1 % secondary device (laptop)
                        MainPath.dataCtdL1Thredds = '';
                        MainPath.dataCtd = '';
                        MainPath.dataPortasal = '';
                        MainPath.dataCTDInsituCalHistory = '';                       
                end
        end
end

%% Glider salinity correction pack paths  
switch correctionMethod  
    case 'salinity_glider'
        MainPath.correctionMethod = 'salinity_glider';
        switch OPERATIONAL_MODE
            case 1 % when working in the office network
                MainPath.main = '/home/glider';
                MainPath.dataGliderL1Thredds = '';
                MainPath.metadataGliderCorrected = '';

            case 0 % when NOT working in the office network
                MainPath.main = [MainPath.mainToolbox, 'lib/glider-salinity-correction-pack/'];
                switch PORTABLE_MODE
                    case 0 % primary device (office computer)                                  
                        MainPath.dataGliderL1Thredds = '/LOCALDATA/glider_data_L1/data/backup_dt/';
                        MainPath.metadataGliderCorrected = '';
                    case 1 % secondary device (laptop)
                        MainPath.dataGliderL1Thredds = 'C:/Users/socib/Documents/data/glider_L1_data/'; 
                        MainPath.metadataGliderCorrected = 'C:/Users/socib/Documents/data/meta_correction_new/';
                end
        end

        MainPath.codePack = [MainPath.main,'src/']; % path to the glider correction pack source code        
        MainPath.resourcesPack = [MainPath.main,'res/']; % path to specific resources of the package like list of available files in thredds, images, etc
        
end 

%% ARGO salinity correction pack paths  
switch correctionMethod  
    case 'salinity_argo'
        MainPath.correctionMethod = 'salinity_argo';
        switch OPERATIONAL_MODE
            case 1 % when working in the office network
                MainPath.main = '/home/glider';
                MainPath.dataGliderL1Thredds = '';
                MainPath.metadataGliderCorrected = '';

            case 0 % when NOT working in the office network
                MainPath.main = [MainPath.mainToolbox, 'lib/argo-salinity-correction-pack/'];
                switch PORTABLE_MODE
                    case 0 % primary device (office computer)                                  
                        MainPath.dataGliderL1Thredds = '/LOCALDATA/glider_data_L1/data/backup_dt/';
                        MainPath.metadataGliderCorrected = '';
                    case 1 % secondary device (laptop)
                        MainPath.dataGliderL1Thredds = 'C:/Users/socib/Documents/data/glider_L1_data/'; 
                        MainPath.metadataGliderCorrected = 'C:/Users/socib/Documents/data/meta_correction_new/';
                end
        end

        MainPath.codePack = [MainPath.main,'src/']; % path to the glider correction pack source code        
        MainPath.resourcesPack = [MainPath.main,'res/']; % path to specific resources of the package like list of available files in thredds, images, etc
        
end 
 
