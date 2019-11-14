function [data, names, lat,lon,gtime, date, time, timeUTC, cruise, station]= Stage_14b_cnv2mat_2013(cnv_file)
% CNV2MAT Reads the SeaBird ASCII .CNV file format

cruise = 'MEDESS 09/2013'; % one medness cruises not have the ** cruise header
%
%  Usage:   [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);
%
%     Input:  cnv_file = name of .CNV file  (e.g. 'cast002.cnv')
%
%     Output: lon = longitude in decimal degrees, West negative
%             lat = latitude in decimal degrees, North positive
%           gtime = Gregorian time vector in UTC
%            data = matrix containing all the columns of data in the .CNV file
%           names = string matrix containing the names and units of the columns
%         sensors = string matrix containing the names of the sensors
%
%  NOTE: How lon,lat and time are written to the header of the .CNV
%        file may vary with CTD setup.  For our .CNV files collected on 
%        the Oceanus, the lat, lon & time info look like this:
%
%    * System UpLoad Time = Mar 30 1998 18:48:42
%    * NMEA Latitude = 42 32.15 N
%    * NMEA Longitude = 069 28.69 W
%    * NMEA UTC (Time) = 23:50:36
%
%  Modify the lat,lon and date string handling if your .CNV files are different.

%  4-8-98  Rich Signell (rsignell@usgs.gov)  
%     incorporates ideas from code by Derek Fong & Peter Brickley
%

% Open the .cnv file as read-only text
%
  fid=fopen(cnv_file,'rt');
% 
% Read the header.
% Start reading header lines of .CNV file,
% Stop at line that starts with '*END*'
%
% Pull out NMEA lat & lon along the way and look
% at the '# name' fields to see how many variables we have.
%

str='*START*';
while (~strncmp(str,'*END*',5));
     str=fgetl(fid);
%-----------------------------------
%
%    Read the NMEA latitude string.  This may vary with CTD setup.
%
     if (strncmp(str,'* NMEA Latitude',15))
        is=strfind(str,'=');
        isub=is+1:length(str);
        dm=sscanf(str(isub),'%f',2);
        if(strfind(str(isub),'N'));
           lat=dm(1)+dm(2)/60;
        else  
           lat=-(dm(1)+dm(2)/60); 
        end
%-------------------------------
%
%    Read the NMEA longitude string.  This may vary with CTD setup.
%
     elseif (strncmp(str,'* NMEA Longitude',15))
        is=strfind(str,'=');
        isub=is+1:length(str);
        dm=sscanf(str(isub),'%f',2);
        if(strfind(str(isub),'E'));
           lon=dm(1)+dm(2)/60;
        else  
           lon=-(dm(1)+dm(2)/60); 
        end
%------------------------
%
%    Read the 'System upload time' to get the date.
%           This may vary with CTD setup.
%
     elseif (strncmp(str,'* System UpLoad',15))
        is=strfind(str,'=');
%    pick apart date string and reassemble in DATEFORM type 0 form
        datstr=[str(is+6:is+7) '-' str(is+2:is+4) '-' str(is+9:is+12)];
        datstr=[datstr ' ' str(is+14:is+21)];
%    convert datstr to Julian time
        n=datenum(datstr);
        gtime=datevec(n);
%----------------------------
%
%    Read the NMEA DATE/TIME string.  This may vary with CTD setup.

%
%      replace the System upload time with the NMEA time
     elseif (strncmp(str,'** Date',5))
        is=strfind(str,':');
        isub=is(1)+1:length(str);
        %gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
        date = str(isub);
    
     
     elseif (strncmp(str,'** Time',5))
        is=strfind(str,':');
        isub=is(1)+1:length(str);
        %gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
        time = str(isub);
     
     
     elseif (strncmp(str,'* System UTC',10))
        is=strfind(str,'=');
        isub=is(1)+1:length(str);
        %gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
        timeUTC = str(isub);
        
%------------------------------
% read in station no

    elseif (strncmp(str,'** Station',10))
            is=strfind(str,':');
            %isub=is(1)+2:length(str);
            isub=is(1)+1:length(str);
            station =  str(isub);

% read in maxDepth    
 elseif (strncmp(str,'** Depth',5))
            is=strfind(str,':');
            isub=is(1)+2:length(str);
            maxDepth =  str(isub);

            % read in cruise    
 elseif (strncmp(str,'** Cruise',5))
            is=strfind(str,':');
            isub=is(1)+2:length(str);
            cruise =  str(isub);
%
%    Read the variable names & units into a cell array
%
     elseif (strncmp(str,'# name',6))  
        var=sscanf(str(7:10),'%d',1);
        var=var+1;  % .CNV file counts from 0, Matlab counts from 1
 %      stuff variable names into cell array
      names{var}=str;
%------------------------------
%
%    Read the sensor names into a cell array
%
     elseif (strncmp(str,'# sensor',8))  
        sens=sscanf(str(10:11),'%d',1);
        sens=sens+1;  % .CNV file counts from 0, Matlab counts from 1
 %      stuff sensor names into cell array
      sensors{sens}=str;
%
%  pick up bad flag value
     elseif (strncmp(str,'# bad_flag',10))  
        isub=13:length(str);
        bad_flag=sscanf(str(isub),'%g',1);
     else
     end
end

check_var = exist('date', 'var');
if check_var == 0
    date = [];
end
check_var = exist('time', 'var');
if check_var == 0
    time = [];
end
check_var = exist('timeUTC', 'var');
if check_var == 0
    timeUTC = [];
end
check_var = exist('cruise', 'var');
if check_var == 0
    cruise = [];
end
check_var = exist('station', 'var');
if check_var == 0
    station = [];
end

%==============================================
%
%  Done reading header.  Now read the data!
%
nvars=var;  %number of variables

% Read the data into one big matrix
%
data=fscanf(fid,'%f',[nvars inf]); % note maybe need to increase no decimal places

fclose(fid);

%
% Flag bad values with nan
%
ind=find(data==bad_flag);
data(ind)=data(ind)*nan;

%
% Flip data around so that each variable is a column
data=data.';

% Convert cell arrays of names to character matrices
names=char(names);
%sensors=char(sensors);

return
