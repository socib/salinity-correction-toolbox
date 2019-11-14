function insituSal = stage_4_read_insitu_salinity_data(DeploymentInfo)
%
%
% imports spreadsheet and sets out data in a useful format for comparison
% with cdt .btl files.
% The following procedure is necessary before running this code:
%       1. Attain spreadsheets of the in situ bottle salinity calculations
%       from the salinometer. 
%       2. Run the following code to import the original spreadsheet
%       and converts the data into a .mat file for comparison with the .btl
%       data (that is converted into .mat files using
%       runbtlFileread_allCruises.m and/or read_dotbtl_files.m for
%       individual cruises).
%
% Date created: 09/11/2015
% any questions: cmunoz.socib.es

%VARNAMEindex =  {'Sample ID', 'Bottle Label', 'DateTime', 'Bath Temperature', 'Uncorrected Ratio', 'Uncorrected Ratio StandDev', 'Correction', 'Adjusted Ratio', 'Calculated Salinity StandDev', 'Calculated Salinity', 'Comments'};

global Path

pname1 = Path.dataInsituSalinityRaw;
pname2 = Path.dataInsituSalinityConverted;

try
    [num,txt,raw] = xlsread([pname1,DeploymentInfo.deploymentName]);
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
    fprintf(1,'\n');
    fprintf(1,['Ensure that the insitu_salinity_raw file is in: ', char(Path.dataInsituSalinityRaw), ' and run the Phase 1 again']);
end
% Identifies the headers, which are already standardized in step 2 listed
% above (replacing any space delimiters with '_' so that header can be used as a field name in the structure):
headers=txt(1,:);
headers2 = strrep(headers,' ','_');

% finds the column of the string-based data based on standardized header
% names:
iID = strcmp(headers,'Sample ID')==1;
iRd = strcmp(headers,'Reading#')==1;
iBL = strcmp(headers,'Bottle Label')==1;
iDT = strcmp(headers,'DateTime')==1;
iBT = strcmp(headers,'Bath Temperature')==1;
iUR = strcmp(headers,'Uncorrected Ratio')==1;
iURS = strcmp(headers,'Uncorrected Ratio StandDev')==1;
iCt = strcmp(headers,'Correction')==1;
iAR = strcmp(headers,'Adjusted Ratio')==1;
iCS = strcmp(headers,'Calculated Salinity')==1;
iCSS = strcmp(headers,'Calculated Salinity StandDev')==1;
iCM = strcmp(headers,'Comments')==1;
% Creates structure with the corresponding field names, excluding the first
% line (headers) for the string (txt) -based variables:

% Parse Bottle Label column with regular expression to obtain flask number,
% station, niskin bottle number and depth
insituSalTemp.BottleLabel   = txt(2:end,iBL);
%expression = '(\d+)[-]+[ ]*([A-Za-z0-9]+_\d+) [A-Za-z0-9]*[-]*B(\d+) \((\d+)m\)([A-Za-z0-9]*)';  
expression = '(\d+)[-]*[ ]*([A-Za-z0-9]+_*[A-Za-z0-9]*\d*_*[A-Za-z0-9]*\d*) [A-Za-z0-9]*[-]*B(\d+) \((\d+.*d*)m\)([A-Za-z0-9]*)';

for i = 1:length(num)
    str = insituSalTemp.BottleLabel(i,:);
    [tok(:,i),matchStr] = regexp(str,expression, 'tokens', 'tokenExtents');
    if isempty(tok{1,i}) == 0
        insituSal.Station{i,:} = tok{1,i}{1,1}{1,2};
        insituSal.Bottle{i,:} = tok{1,i}{1,1}{1,3};
        insituSal.Depth{i,:} = tok{1,i}{1,1}{1,4};
    else 
        insituSal.Station{i,:} = tok{1,i};
        insituSal.Bottle{i,:} = tok{1,i};
        insituSal.Depth{i,:} = tok{1,i};
    end
end


for i = 1:length(insituSal.Bottle)
    if isempty(insituSal.Bottle{i,1}) == 1
        insituSal.Bottle{i,1} = 'NaN';
        insituSal.Bottle{i,1} = char(insituSal.Bottle{i,1});
    end
end
insituSal.Bottle = char(insituSal.Bottle{:});
insituSal.Bottle = str2num(insituSal.Bottle);
for i = 1:length(insituSal.Depth)
    if isempty(insituSal.Depth{i,1}) == 1
        insituSal.Depth{i,1} = 'NaN';
        insituSal.Depth{i,1} = char(insituSal.Depth{i,1});
    end
end
insituSal.Depth = char(insituSal.Depth{:});
insituSal.Depth = str2num(insituSal.Depth);



insituSal.DateTime  = raw(2:end,iDT);
insituSal.BathTmp   = raw(2:end,iBT);
insituSal.Comments  = raw(2:end,iCM);

insituSal.Adjusted_Ratio = raw(2:end,iAR);
insituSal.Correction = raw(2:end,iCt);
insituSal.Uncorrected_Ratio  = raw(2:end,iUR);
insituSal.Uncorrected_Ratio_StandDev  = raw(2:end,iURS);
insituSal.Calculated_Salinity = raw(2:end,iCS);
insituSal.Calculated_Salinity_StandDev = raw(2:end,iCSS);

% should there are extra samples before averaging and column Reading#
if any(iRd == 1)
    first_n = 6;
else
    first_n = 5;
end

for n = first_n:length(headers)-1
    insituSal.(headers2{n}) = cell2mat(insituSal.(headers2{n}));
end

insituSal.CommentsWhole = insituSal.Comments;
insituFields = fields(insituSal);
for n=1:length(insituFields)
    if iscell(insituSal.(insituFields{n}))==1 && strcmp(insituFields{n},'CommentsWhole')==0
        insituSal.(insituFields{n}) = insituSal.(insituFields{n})(1:length(insituSal.Depth),1);
    end
end

for i = 1:length(num)
    insituSal.Station{i,1} = char(insituSal.Station{i,1});
    insituSal.CommentsWhole{i,1} = char(insituSal.CommentsWhole{i,1});
end

% save struct.mat as the deploymentName under
save([pname2,DeploymentInfo.deploymentName], 'insituSal')

end
