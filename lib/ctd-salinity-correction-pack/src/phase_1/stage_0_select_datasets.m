function [ncL1FileName, DIR, DeploymentInfo] = stage_0_select_datasets

global MainPath
global ONLINE_MODE

DataPname = MainPath.dataCtdL1Thredds;

if ONLINE_MODE == 0
    DIR = dir(fullfile(DataPname,'*.nc')); %list of accessible files in downloaded files folder
elseif ONLINE_MODE == 1
    %listncfiles; % list accessible files in thredds
    NcFilesList = load(fullfile(DataPname,'NcFilesList.mat'));
    NcFilesList = NcFilesList.NcFilesList;
    RANGE = length(NcFilesList.fileServer);
    for i = 1:RANGE
        NcFilesListSplit(i).name = strsplit(char(NcFilesList.fileServer(i)),'/');
        DIR(i).name = NcFilesListSplit(i).name{10};
        DIR(i).pathToFile = NcFilesList.fileServer(i);
    end

end

% list of files to select deployment
for i = 1:length(DIR)
    %list(i,:) = DIR(i).name;
    list{i} = DIR(i).name;
end
[indx,tf] = listdlg('ListString',list,'SelectionMode','single','ListSize',[450,650]);

if ONLINE_MODE == 0
    %ncL1FileName = char(list(indx,:));
    ncL1FileName = char(list{indx});
elseif ONLINE_MODE == 1
    %download file from thredds
%     URL = char(NcFilesList.fileServer(indx));
%     ncL1FileName = char(list(indx,:));
    URL = char(NcFilesList.fileServer(indx));
    ncL1FileName = char(list{indx});
    urlwrite(URL,[DataPname, ncL1FileName]);
end

deploymentName = regexprep(ncL1FileName,'L1_','','ignorecase'); %remove L1 from file name to be used as parameter to locate further files (btl, insituSal, etc)
deploymentName = deploymentName(1:end-3);
deploymentYear = deploymentName(end-9:end-6);

dum = strsplit(deploymentName,'_');

DeploymentInfo.deploymentCode = dum{1};
DeploymentInfo.researchVesselName = strrep(dum{2},'-','_');
DeploymentInfo.instrumentName = upper(dum{3});
DeploymentInfo.deploymentDate = dum{4};
DeploymentInfo.deploymentName = deploymentName;
DeploymentInfo.deploymentYear = deploymentYear;

% deploymentYear = deploymentName(30:33);

% if ~isnan(strfind(deploymentName,'scb-sbe9002'));
%     instrumentName = 'SCB-SBE9002';
% elseif ~isnan(strfind(deploymentName,'scb-sbe9001'));
%     instrumentName = 'SCB-SBE9001';    
% elseif ~isnan(strfind(deploymentName,'utm-sbe9001'));
%     instrumentName = 'UTM-SBE9001'; 
% elseif ~isnan(strfind(deploymentName,'nat-sbe9001'));
%     instrumentName = 'NAT-SBE9001'; 
% end

end

