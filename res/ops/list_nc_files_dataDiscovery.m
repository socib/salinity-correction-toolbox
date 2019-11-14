function list_nc_files_dataDiscovery(instrumentIdList, fileNameOut)

global MainPath

fprintf(1,'Connecting to SOCIB Data Discovery API...\n');
JsonQuery = webread('http://apps.socib.es/DataDiscovery/list-deployments?');

fprintf(1,'Listing available netCDF files from thredds...\n\n');

% keep only deploymnts info from ctdInstrumentID
for i = 1:length(JsonQuery) 
    for j = 1 : length(instrumentIdList)
        if JsonQuery{i}.platform.jsonInstrumentList.id == instrumentIdList(j)
            FilteredJsonQuery{i,:} = JsonQuery{i};
            fprintf(1,[char(JsonQuery{i}.name),'\n']);
        end
    end
end

FilteredJsonQuery =  FilteredJsonQuery(~cellfun('isempty',FilteredJsonQuery)); % remove empty cells

 % create cell arrays with list of opendap and file server links to nc files
for i = 1:length(FilteredJsonQuery)
    ncFilesListOpendap{i} = FilteredJsonQuery{i}.platform.jsonInstrumentList.ncOpendapLink;
    ncFilesListFileServer{i} = FilteredJsonQuery{i}.platform.jsonInstrumentList.ncFileCatalogLink;
end

NcFilesList.opendap = ncFilesListOpendap; 
NcFilesList.fileServer = ncFilesListFileServer;
save([MainPath.db, fileNameOut], 'NcFilesList');
%save(['/home/cmunoz/Documents/programming/MATLAB/MATLAB_SOCIB/AUV/Glider/CODE/gliderSalCorrection_pack/', fileNameOut], 'NcFilesList');


end