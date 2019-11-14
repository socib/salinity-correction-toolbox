function Stage_14d_add_meta_create_nc_halfmetre_correction_CTD(deploymentName, ncL1FileName)
%
%
% loads the corrected half metre bin averaged, corrected CTD data, and
% loads the coresponding meta data of the thredds corrected nc files, and
% uses the meta and global meta to create a half metre corrected netcdf file.

global Path

Pname_coeffs_IN = Path.dataCorrectedMatHalfmBinAvg;
Pname_CTD_in    = Path.dataCorrectedNc5mBinAvg;
Pname_out       = Path.dataCorrectedNcHalfmBinAvg;

load([Pname_coeffs_IN,deploymentName,'_corrected_halfmetreBINs.mat'])

% find date of first day of cruise to match up to Thredds deployment names:
datenumber = nan(length(dataCTD.timeUTC),1);
for n=1:length(dataCTD.timeUTC)
    if ischar(dataCTD.timeUTC{n})==1
        datenumber(n,1) = datenum(dataCTD.timeUTC{n},'mmm dd yyyy HH:MM:SS');
    else 
        datenumber(n,1) = nan;
    end
end
datestrCr = datestr(min(datenumber),'yyyy-mm-dd');

% load CTD data from Thredds .nc files:
FnameCTD = [ncL1FileName(1:end-3),'_Corrected'];
finfo    = ncinfo([Pname_CTD_in,FnameCTD,'.nc']);
[data, meta, global_meta] = loadnc(finfo.Filename);

if isfield(meta,'CHLO')==1
    data2.CHLO = dataCTD.Fluorescence.';
    meta2.CHLO = meta.CHLO;
     for Nn=1:length(meta.CHLO.attributes)
        if strcmpi(meta.CHLO.attributes(Nn).name,'ancillary_variables')==1
            meta2.CHLO.attributes(1,Nn).value = '';
            break
        end
     end 
end
if isfield(dataCTD,'Oxygen')==1 && isfield(dataCTD,'sbeox0')==0
    data2.OXY_CON = dataCTD.Oxygen.';
    meta2.OXY_CON = meta.OXY_CON;
    for Nn=1:length(meta.OXY_CON.attributes)
        if strcmpi(meta.OXY_CON.attributes(Nn).name,'ancillary_variables')==1
            meta2.OXY_CON.attributes(1,Nn).value = '';
            break
        end
     end 
end
% if isfield(dataCTD,'sbeox0')==1
%     data2.OXY_CON = dataCTD.sbeox0.';
%     meta2.OXY_CON = meta.OXY_CON_01;
%     for Nn=1:length(meta.OXY_CON_01.attributes)
%         if strcmpi(meta.OXY_CON_01.attributes(Nn).name,'ancillary_variables')==1
%             meta2.OXY_CON_01.attributes(1,Nn).value = '';
%             break
%         end
%      end 
% end
% if isfield(dataCTD,'sbeox1')==1
%     data2.OXY_CON = dataCTD.sbeox1.';
%     meta2.OXY_CON = meta.OXY_CON_02;
%     for Nn=1:length(meta.OXY_CON_02.attributes)
%         if strcmpi(meta.OXY_CON_02.attributes(Nn).name,'ancillary_variables')==1
%             meta2.OXY_CON_02.attributes(1,Nn).value = '';
%             break
%         end
%      end 
% end
if isfield(dataCTD,'c0mS')==1 && isfield(meta,'COND_01')==1
    data2.COND_01         = dataCTD.c0mS.';
    data2.COND_01_CORR    = dataCTD.Corrected.COND_01.';
    meta2.COND_01         = meta.COND_01;
    meta2.COND_01_CORR    = meta.COND_01_CORR;
   for Nn=1:length(meta.COND_01.attributes)
        if strcmpi(meta.COND_01.attributes(Nn).name,'ancillary_variables')==1
            meta2.COND_01.attributes(1,Nn).value = '';
        end
        if strcmpi(meta2.COND_01_CORR.attributes(Nn).name,'ancillary_variables')==1
            meta2.COND_01_CORR.attributes(1,Nn).value = '';
            break
        end
   end 
end
if isfield(dataCTD,'c1mS')==1 && isfield(meta,'COND_02')==1
    data2.COND_02         = dataCTD.c1mS.';
    data2.COND_02_CORR    = dataCTD.Corrected.COND_02.';
    meta2.COND_02         = meta.COND_02;
    meta2.COND_02_CORR    = meta.COND_02_CORR;
    for Nn=1:length(meta.COND_02.attributes)
        if strcmpi(meta.COND_02.attributes(Nn).name,'ancillary_variables')==1
            meta2.COND_02.attributes(1,Nn).value = '';
        end
        if strcmpi(meta.COND_02_CORR.attributes(Nn).name,'ancillary_variables')==1
            meta2.COND_02_CORR.attributes(1,Nn).value = '';
            break
        end
   end 
end
if isfield(dataCTD,'sal00')==1 && isfield(meta,'SALT_01')==1
    data2.SALT_01         = dataCTD.sal00.';
    data2.SALT_01_CORR    = dataCTD.Corrected.SALT_01.';
    meta2.SALT_01         = meta.SALT_01;
    meta2.SALT_01_CORR    = meta.SALT_01_CORR;
   for Nn=1:length(meta.SALT_01.attributes)
        if strcmpi(meta.SALT_01.attributes(Nn).name,'ancillary_variables')==1
            meta2.SALT_01.attributes(1,Nn).value = '';
        end
        if strcmpi(meta2.SALT_01_CORR.attributes(Nn).name,'ancillary_variables')==1
            meta2.SALT_01_CORR.attributes(1,Nn).value = '';
            break
        end
   end 
end
if isfield(dataCTD,'sal11')==1 && isfield(meta,'SALT_02')==1
    data2.SALT_02         = dataCTD.sal11.';
    data2.SALT_02_CORR    = dataCTD.Corrected.SALT_02.';
    meta2.SALT_02         = meta.SALT_02;
    meta2.SALT_02_CORR    = meta.SALT_02_CORR;
    for Nn=1:length(meta.SALT_02.attributes)
        if strcmpi(meta.SALT_02.attributes(Nn).name,'ancillary_variables')==1
            meta2.SALT_02.attributes(1,Nn).value = '';
        end
        if strcmpi(meta.SALT_02_CORR.attributes(Nn).name,'ancillary_variables')==1
            meta2.SALT_02_CORR.attributes(1,Nn).value = '';
            break
        end
   end 
end
if isfield(dataCTD,'t090C')==1
    data2.WTR_TEM_01      = dataCTD.t090C.';
    data2.PTEMP_01        = dataCTD.ptemp_01.';
    data2.PTEMP_01_CORR   = dataCTD.Corrected.ptemp_01.';
    meta2.WTR_TEM_01      = meta.WTR_TEM_01;
    meta2.PTEMP_01        = meta.WTR_TEM_01;
    meta2.PTEMP_01.name   = 'PTEMP_01';
    meta2.PTEMP_01_CORR = meta.WTR_TEM_01;
    meta2.PTEMP_01_CORR.name   = 'PTEMP_01_CORR';
    meta2.PTEMP_01.attributes(1,1).value = 'sea_water_potential_temperature';
    meta2.PTEMP_01.attributes(1,2).value = 'Sea water potential temperature of sensor 5427';
    meta2.PTEMP_01.attributes(1,8).value = 'derived';
    meta2.PTEMP_01_CORR.attributes(1,1).value = 'sea_water_potential_temperature_corrected';
    meta2.PTEMP_01_CORR.attributes(1,2).value = 'Sea water potential temperature of sensor 5427 derived using corrected salinity';
    meta2.PTEMP_01_CORR.attributes(1,8).value = 'derived';
    for Nn=1:length(meta.WTR_TEM_01.attributes)
        if strcmpi(meta.WTR_TEM_01.attributes(Nn).name,'ancillary_variables')==1
            meta2.WTR_TEM_01.attributes(1,Nn).value = '';
        end
        if strcmpi(meta2.PTEMP_01.attributes(Nn).name,'ancillary_variables')==1
            meta2.PTEMP_01.attributes(1,Nn).value = '';
        end
        if strcmpi(meta2.PTEMP_01_CORR.attributes(Nn).name,'ancillary_variables')==1
            meta2.PTEMP_01_CORR.attributes(1,Nn).value = '';
            break
        end
   end 
end
if isfield(dataCTD,'t190C')==1 && isfield(dataCTD,'ptemp_02')==1
    data2.WTR_TEM_02    = dataCTD.t190C.';
    data2.PTEMP_02      = dataCTD.ptemp_02.';
    data2.PTEMP_02_CORR = dataCTD.Corrected.ptemp_02.';
    meta2.WTR_TEM_02    = meta.WTR_TEM_02;
    meta2.PTEMP_02      = meta.WTR_TEM_02;
    meta2.PTEMP_02.name = 'PTEMP_02';
    meta2.PTEMP_02_CORR = meta.WTR_TEM_02;
    meta2.PTEMP_02_CORR.name   = 'PTEMP_02_CORR';
    meta2.PTEMP_02.attributes(1,1).value = 'sea_water_potential_temperature';
    meta2.PTEMP_02.attributes(1,2).value = 'Sea water potential temperature of sensor 5427';
    meta2.PTEMP_02.attributes(1,8).value = 'derived';
    meta2.PTEMP_02_CORR.attributes(1,1).value = 'sea_water_potential_temperature_corrected';
    meta2.PTEMP_02_CORR.attributes(1,2).value = 'Sea water potential temperature of sensor 5427 derived using corrected salinity';
    meta2.PTEMP_02_CORR.attributes(1,8).value = 'derived';
    for Nn=1:length(meta.WTR_TEM_02.attributes)
        if strcmpi(meta.WTR_TEM_02.attributes(Nn).name,'ancillary_variables')==1
            meta2.WTR_TEM_02.attributes(1,Nn).value = '';
        end
        if strcmpi(meta2.PTEMP_02.attributes(Nn).name,'ancillary_variables')==1
            meta2.PTEMP_02.attributes(1,Nn).value = '';
        end
        if strcmpi(meta2.PTEMP_02_CORR.attributes(Nn).name,'ancillary_variables')==1
            meta2.PTEMP_02_CORR.attributes(1,Nn).value = '';
            break
        end
   end 
end
data2.DEPTH   = dataCTD.Depth.';
data2.LAT     = dataCTD.latitude.';
data2.LON     = dataCTD.longitude.';
data2.TURB    = dataCTD.Turbidity.';
data2.WTR_PRE = dataCTD.Pressure.';
meta2.DEPTH   = meta.DEPTH;
meta2.LAT     = meta.LAT;
meta2.LON     = meta.LON;
meta2.TURB    = meta.TURB;
meta2.WTR_PRE = meta.WTR_PRE;
for Nn=1:length(meta.TURB.attributes)
    if strcmpi(meta.TURB.attributes(Nn).name,'ancillary_variables')==1
        meta2.TURB.attributes(1,Nn).value = '';
        break
    end
end 



% get time in seconds since 1970-01-01 00:00:00:
REFJD = datenum(1970,01,01,00,00,00);
data2.time    = ((dataCTD.sciTime-REFJD)*(24*60^2)).';
meta2.time    = meta.time;

data2.trajectory = data.trajectory;
meta2.trajectory = meta.trajectory;

global_meta2 = global_meta;
global_meta2.dimensions(1,2).length = size(data2.DEPTH,2);

Fname_out = [Pname_out,FnameCTD,'_halfmetre.nc'];
savenc(data2,meta2,global_meta2,Fname_out);





