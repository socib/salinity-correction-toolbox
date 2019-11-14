function ctdbtl = stage_6a_read_dotbtl_files(DeploymentInfo)
%
%
% imports and converts .btl files from CTD cruise data into mat files.
% Do this by finding all lines with (avg) and (sdev).  It is important to
% ensure the pathname is correct and that the folder containing the .btl
% files of all stations is named after the cruiseName.
%
% Date created: 21/10/2015
% any questions: kreeve.socib.es

global Path

pname1 = Path.dataCtdBtl;
pname2 = pname1;
pname_out = Path.dataCtdBtlMat;
%pname2 = 'C:/Users/socib/Documents/MATLAB/MATLAB_SOCIB/SHIP/DATA/CTD/CTD_btlFILES/btlFILES/';
%pname2 = 'C:/Users/socib/Documents/DATA/SHIP/CTD/BOTTLE/';

% % If a cruise name is not entered when the code is run, the first
% % criuse name is selected from the list of folders in the directory.
% % cruiseName as to match the name of the folder of the corresponding
% % cruise.
% if exist('cruiseName','var') == 0
%     FolderName = uigetdir(pname1);
%     directory = FolderName(length(pname2)+1:end);
%     cruiseName = cellstr(directory);
% end
% pname2 = strcat((pname1),cruiseName,'/');
% pname_out = strcat(pname1,cruiseName,'/');
% pname_out = pname_out{1};

% pname2 = strcat((pname1),deploymentName,'/BOTTLE/');



% List standard variables that should be extracted from the .btl files, if
% available:
VARNAMEindex = {'Bottle', 'Date', 'Time', 'DepSM', 'Latitude', 'Longitude', 'T090C', 'T190C', 'C0mS/cm', 'C1mS/cm', 'Sal00', 'Sal11', 'Sbeox0Mg/L', 'Sbeox1Mg/LSbeox0Mg/Ldiff'};
%VARNAMEindex = {'Bottle', 'Date', 'Time', 'DepSM', 'Latitude', 'Longitude', 'T090C', 'T190C', 'C0mS/cm', 'C1mS/cm', 'Sal00', 'Sal11', 'Sbeox0Mg/L'};

% List all .btl files under cruiseName directory:
Pname = pname2;
Fn = dir([Pname,'*.btl']);

% For every .btl file... 
for nn = 1:length(Fn)
    % create the filename that can be used as a field name in the sctruct that will be created:
    Fname = Fn(nn).name;
    Fname2=strsplit(Fname,'.'); Fname2=Fname2{1};
    Fname2=strsplit(Fname2,' '); Fname2=Fname2{1};
    Fname2=strrep(Fname2,'-','_');

    %// Read lines from input file, finding the line where the meta info
    %stops and the variable names and data begins - this is located by
    %finding the line of the last '#' (hashfind).  If there are no '#', 
    %assume the file has been manually altered to remove meta info, and 
    %thus treat the first line as the header line;
    fid = fopen([Pname,Fname], 'rt');
    C = textscan(fid, '%s', 'delimiter', '\n');
    hashfind = (strfind(C{1},'#'));
    hashfind2=[];
    counter1=1;
    for n = 1:length(hashfind)
        if isempty(hashfind{n})==0
            hashfind2(counter1,1) = n;
            counter1 = counter1+1;
        end
    end
    if isempty(hashfind2)==1
        hashfind2=0;
    end
    idx1 = hashfind2(hashfind2==max(hashfind2));
    iavg = strfind(C{1},'(avg)');
    counter1=1;
    for n = 1:length(iavg)
        if isempty(iavg{n}) == 0
            i2avg(counter1,1) = n;
            i3avg(counter1,1) = n+1;
            DAT{counter1,:} = C{1}{i2avg(counter1)};        % DAT contains the data from the input file
            DATtime{counter1,:} = C{1}{i3avg(counter1)};
            counter1 = counter1+1;
        end
    end
    headers = [C{1}{idx1+1}, '     ', C{1}{idx1+2}];                                 % headers contains the variable names of the data included in the file
    %x = (strfind(C{1},'** Date'));
    x = (strfind(C{1},'* System UTC'));
    counter3=0;
    for nnn=1:length(x)
        if isempty(x{nnn})==0
            counter3 =counter3+1;
            xx(counter3,1) = nnn;
        end
    end
    DATE = C{1}{xx};
    DATE = DATE(16:end);
    %DATE = datetime(DATE,'InputFormat','MMM dd yyyy HH:mm:ss');
    DATE = datevec(DATE,'mmm dd yyyy HH:MM:ss');
    %DATE.Format = 'dd-MM-yyyy';
    DATE = datestr(DATE,'dd-MM-yyyy');

%     DATE = C{1}{xx};
%     DATE = strsplit(DATE,{'Date:',' '});
%     DATE = DATE{2};
    delim = {' ','-','/','\','.'};
    xxx2=1;
    while length(strsplit(DATE,delim{xxx2}))==1
        xxx2=xxx2+1;
    end
    tmpryDate=strsplit(DATE,delim{xxx2});
        
    xxx=1;
    while length(tmpryDate{xxx})~=4 && xxx<3
        xxx=xxx+1;
    end
    if xxx==1
        dateFormat = ['yyyy',delim{xxx2},'mm',delim{xxx2},'dd HH:MM:SS'];
%     elseif xxx==3
%         dateFormat = ['dd',delim{xxx2},'mm',delim{xxx2},'yyyy HH:MM:SS'];
    elseif xxx==3
        dateDAT=strsplit(DAT{1},' ');
        dateDAT=dateDAT(2:4);
        dateDAT2=[dateDAT{2},'/',dateDAT{1},'/',dateDAT{3}];
        DATE = datestr(dateDAT2,'dd-mm-yyyy');
        dateFormat = 'dd-mm-yyyy HH:MM:SS';
    end
    clear xxx xxx2 tmpryDate
        
    fclose(fid);

    clear counter1 i2avg iavg idx1 hashfind hashfind2
    % headers is currently one long string, so we split the headers into
    % several strings (i.e. one string per variable name) and we match up
    % the header names with the list of standard variable names established
    % earlier (VARNAMEindex).  This means that if the file has different
    % variables, or in a different order of columns, the correct data is
    % matched up using an indexing system.
    headers2 = strsplit(headers);
    for n=1:length(VARNAMEindex)
        X = find(strcmpi(headers2,VARNAMEindex{n})==1);
        if isempty(X) == 0
            HEADERindex(n,1) = X(length(X));
        else
            HEADERindex(n,1) = nan;
        end
    end
    clear X
    % Take into account that by splitting the header intoseveral strings,
    % date becomes split into three components instead of one
    % ('dd','mmm','yyyy'), which affects the indexing of the headers.  This
    % corrects for this:
     X = find(strcmpi(headers2,'DATE')==1);
     HEADERindex(HEADERindex>2) = HEADERindex(HEADERindex>2)+2;
    %HEADERindex(isnan(HEADERindex))=[];    
    HEADERindex(HEADERindex==2)=nan;    
    
    % split the data into different columns to be read into their
    % corresponding variable names:
    for n=1:length(DAT)
        DAT2{n,:} = strsplit(DAT{n},' ');
        DAT2time{n,:} = strsplit(DATtime{n},' ');
    end

    % ensure variable names are suitable for use as field names within
    % structures by swapping '/' with 'per':
    VARNAMEindex2 = VARNAMEindex;
    for n=1:length(VARNAMEindex)
        if isempty(strfind(VARNAMEindex2{n},'/'))==0;
            VARNAMEindex2{n} = strrep(VARNAMEindex2{n},'/','per');
        end
    end
    % input data of each variable into the field of the corresponding
    % variable name, changing the format from string to double (i.e. to
    % numbers).
    for n1=1:length(DAT2)
        for n2=1:length(VARNAMEindex)
            if isnan(HEADERindex(n2)) == 0 && strcmp(VARNAMEindex{n2},'Time') == 0
                ctdbtl.(Fname2).(VARNAMEindex2{n2})(n1,1) = str2double(DAT2{n1}{HEADERindex(n2)});
            elseif isnan(HEADERindex(n2))==0 && strcmp(VARNAMEindex{n2},'Time')==1
                ctdbtl.(Fname2).(VARNAMEindex2{n2}){n1,1} = (DAT2time{n1}{1});
                ctdbtl.(Fname2).DATEnum(n1,1) = datenum([DATE,' ',DAT2time{n1}{1}],dateFormat);%'dd-mm-yyyy HH:MM:SS'); %if this fails, check format of DATE, may need to change datenum format to 'dd/mm/yyyy HH:MM:SS'
            end
        end
    end
    
    
    clearvars -except DeploymentInfo ctdbtl pname1 Pname FnPn VARNAMEindex Fn pname_out
end

% The result will be a structure.mat file where the first order fields are
% the different stations (i.e. file names listed under the cruiseName
% direcory). The second order fields list the standard variables with the
% corresponding data from the .btl files, if such data is provided in the
% .btl files.

% Save the struct.mat file under the cruiseName directory:
save([pname_out,DeploymentInfo.deploymentName],'ctdbtl');

end








