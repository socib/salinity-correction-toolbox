function list_nc_files_api(instrumentType, fileNameOut)

global MainPath

fprintf(1,'Connecting to SOCIB API...\n');

options = weboptions;
options.KeyName = 'api-key';
options.KeyValue = 'socib_webkey';
options.RequestMethod = 'Get';
options.HeaderFields = {'Content-Type' 'application/vnd.socib+json'};
URL = ['http://api.socib.es/data-sources/?instrument_type=', instrumentType];
%http://api.socib.es/data-entries/?instrument_type=Glider&data_mode=dt&processing_level=L1&apikey=socib_webkey
Response = webread(URL, options);

fprintf(1,'Listing available netCDF files from thredds...\n\n');

JsonQuery = {};
page = 1;
indx = 1;
    
while isempty(Response.next) == 0
    URL = ['http://api.socib.es/data-sources/?instrument_type=', instrumentType, '&page=', num2str(page)];
    Response = webread(URL, options);
    for i = 1 : length(Response.results)
        for j = 1:length(Response.results(i).entries)
            if contains(Response.results(i).entries(j).processing_level,'L1') == 1
                %if contains(Response.results(i).entries(j).data_mode,'dt') == 1 || contains(Response.results(i).entries(j).data_mode,'rt') == 1
                if contains(Response.results(i).entries(j).data_mode,'dt') == 1    
                    JsonQuery{indx} = Response.results(i).entries(j).services.opendap.url;  
                    indx = indx + 1;        
                end
            end
        end
    end
    page = page + 1;
end

NcFilesList.opendap = JsonQuery; 

save([MainPath.db, fileNameOut],'NcFilesList');


end