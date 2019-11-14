function [NcFilesList, DataFile] = load_nc_files_list(path_to_file, fileNameIn, dataType)

NcFilesList = load(fullfile(path_to_file,fileNameIn));
NcFilesList = NcFilesList.NcFilesList;
RANGE = length(NcFilesList.opendap);

for i = 1:RANGE
    switch dataType
        case 'glider'
            NcFilesListSplit(i).name = strsplit(char(NcFilesList.opendap(i)),'/');
            DIR(i).name = NcFilesListSplit(i).name{10};
            %NcFilesList.opendap{i} = [NcFilesList.opendap{i}(1:end-3),'_data_dt.nc'];
            DIR(i).pathToFile = NcFilesList.opendap(i); 
        case 'ctd'
            NcFilesListSplit(i).name = strsplit(char(NcFilesList.opendap(i)),'/');
            DIR(i).name = NcFilesListSplit(i).name{10};
            DIR(i).name = strrep(DIR(i).name,'L1','L1_corr');
            NcFilesList.opendap{i} = strrep(NcFilesList.opendap{i},'L1','L1_corr');
            DIR(i).pathToFile = NcFilesList.opendap(i);
        case 'argo'
            NcFilesListSplit(i).name = strsplit(char(NcFilesList.opendap(i)),'/');
            DIR(i).name = NcFilesListSplit(i).name{10};
            DIR(i).pathToFile = NcFilesList.opendap(i);   
    end
end

% list of files to select deployment
for i = 1:length(DIR)
    list{i} = DIR(i).name;
end

switch dataType
    case 'glider'
        selectionModeType = 'single';
    case 'ctd'
        selectionModeType = 'multiple';
    case 'argo'
        selectionModeType = 'single';        
end

[indx,tf] = listdlg('ListString',list,'SelectionMode',selectionModeType,'ListSize',[450,650]);

for i = 1 : length(indx)
    DataFile.path{i,:} = DIR(indx(i)).pathToFile;
    DataFile.name{i,:} = DIR(indx(i)).name;
end


end