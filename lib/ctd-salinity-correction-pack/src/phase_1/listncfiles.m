function listncfiles

global MainPath

fprintf(1,'Connecting to SOCIB Data Discovery API...\n');
JsonQuery = webread('http://apps.socib.es/DataDiscovery/list-deployments?');

fprintf(1,'Listing available netCDF files from thredds...\n\n');
for i = 1:length(JsonQuery) % keep only deploymnts info from RV CTD. id 172 and 448 and 640 belong to SCB-SBE9001 and SCB-SBE9002 and UTM-SBE9001
    if JsonQuery{i}.platform.jsonInstrumentList.id == 172 || JsonQuery{i}.platform.jsonInstrumentList.id == 448 || JsonQuery{i}.platform.jsonInstrumentList.id == 640 || JsonQuery{i}.platform.jsonInstrumentList.id == 642 || JsonQuery{i}.platform.jsonInstrumentList.id == 650
        FilteredJsonQuery{i,:} = JsonQuery{i};
        fprintf(1,[char(JsonQuery{i}.name),'\n']);
    end
end

FilteredJsonQuery =  FilteredJsonQuery(~cellfun('isempty',FilteredJsonQuery)); % remove empty cells

for i = 1:length(FilteredJsonQuery) % create cell arrays with list of opendap and file server links to nc files
    ncFilesListOpendap{i} = FilteredJsonQuery{i}.platform.jsonInstrumentList.ncOpendapLink;
    ncFilesListFileServer{i} = FilteredJsonQuery{i}.platform.jsonInstrumentList.ncFileCatalogLink;
end

NcFilesList.opendap = ncFilesListOpendap; 
NcFilesList.fileServer = ncFilesListFileServer;
save([MainPath.dataCtdL1Thredds, 'NcFilesList.mat'], 'NcFilesList');


end