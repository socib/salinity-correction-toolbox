function Stage_1a_compare_ts_diags_between_cruises(DIR, ncL1FileName, deploymentName)
%
%
% creates plots of T/S diagrams where red dots are uncorrected salnity and
% blue dots are corrected salinity. Information should show on each plot
% indicating (1) which sensor is used and (2) what the correction
% coefficient is.

global Path
% pathname to save figures to based on cruise campaign name:
pnameFIG = Path.figsTSdiagsSingleCruisesThreddsL1;
pnameFIGzoom = Path.figsTSdiagsSingleCruisesThreddsL1Zoom;



for n = 1:length(DIR)
    filename = DIR(n).name;
    try
        finfo    = ncinfo([Path.dataCtdL1Thredds,filename]);
    catch e
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        fprintf(1,'\n');
        fprintf(1,[filename,' will not be plotted unless the file is available in: ', char(Path.dataCtdL1Thredds)]);
        continue
    end
    % Create cruisename as shown in Thredds (minus the date), this becomes the first order field name for the structured array of CTD data:
    X=strsplit(filename,'_L1_');
    X2=strsplit(X{2},'.nc');
    CruiseDate=X2{1};
    CruiseVARname = strrep(X{1},'-','_');
    CruiseVARname2{n,1} = CruiseVARname;
    CruiseVARname3 = strrep(CruiseVARname,'_',' ');
    
    for n2 = 1:length(finfo.Variables)
        VAR.(CruiseVARname).L1.(finfo.Variables(n2).Name) = ncread([Path.dataCtdL1Thredds,filename],finfo.Variables(n2).Name);
    end
    VAR.(CruiseVARname).lat         = VAR.(CruiseVARname).L1.LAT;
    VAR.(CruiseVARname).lon         = VAR.(CruiseVARname).L1.LON;
    VAR.(CruiseVARname).pressure    = VAR.(CruiseVARname).L1.WTR_PRE;
    VAR.(CruiseVARname).depth       = -1.*gsw_z_from_p(VAR.(CruiseVARname).pressure,VAR.(CruiseVARname).lat);                                 %sw_dpth(pressureShip, 39.0);
    VAR.(CruiseVARname).salinity    = VAR.(CruiseVARname).L1.SALT_01;
    VAR.(CruiseVARname).insituT     = VAR.(CruiseVARname).L1.WTR_TEM_01;
    %[SA, in_ocean]                  = gsw_SA_from_SP(VAR.(CruiseVARname).salinity,VAR.(CruiseVARname).pressure,VAR.(CruiseVARname).lon,VAR.(CruiseVARname).lat);
    p_ref = 0;
    VAR.(CruiseVARname).ptemp       = sw_ptmp(VAR.(CruiseVARname).salinity,VAR.(CruiseVARname).insituT,VAR.(CruiseVARname).pressure,p_ref);                            %ptempShip       = sw_ptmp(salinityShip, WTR_TEM_01, pressureShip, 0); % temp to ptemp
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % isopycynals for T/S diagram:
%     VAR.DminT(n,1) = min(min(VAR.(CruiseVARname).ptemp));
%     VAR.DmaxT(n,1) = max(max(VAR.(CruiseVARname).ptemp));
%     VAR.DminS(n,1) = min(min(VAR.(CruiseVARname).salinity));
%     VAR.DmaxS(n,1) = max(max(VAR.(CruiseVARname).salinity));

    DminT = 10;%min(VAR.DminT);
    DmaxT = 15;%max(VAR.DmaxT);
    DminS = 36;%min(VAR.DminS);
    DmaxS = 40;%max(VAR.DmaxS);
    
    %axis([38.4,38.6,12.8,13.6])
    DminT2 = 12.6;%min(VAR.DminT);
    DmaxT2 = 13.8;%max(VAR.DmaxT);
    DminS2 = 38.2;%min(VAR.DminS);
    DmaxS2 = 38.8;%max(VAR.DmaxS);
    
    Saxis = DminS:(DmaxS-DminS)/1000:DmaxS;

    Taxis = DminT:(DmaxT-DminT)/600:DmaxT;
    
    Saxis2 = DminS2:(DmaxS2-DminS2)/1000:DmaxS2;
    Taxis2 = DminT2:(DmaxT2-DminT2)/600:DmaxT2;
    
    clear DminS DmaxS DminSA DmaxSA DminT DmaxT

    Sgridded = meshgrid(Saxis,1:length(Taxis));%36:0.001:41,12.6:0.001:13.8);
    Tgridded = meshgrid(Taxis,1:length(Saxis))'; %36:0.001:41,12.6:0.001:13.8);

    isopycs_gridded = sw_dens0(Sgridded,Tgridded)-1000;%gsw_sigma0_pt0_exact(SAgridded,Tgridded);
    isopycs_gridded = roundn(isopycs_gridded,-2);

    Sgridded2 = meshgrid(Saxis2,1:length(Taxis2));
    Tgridded2 = meshgrid(Taxis2,1:length(Saxis2))';

    isopycs_gridded2 = sw_dens0(Sgridded2,Tgridded2)-1000;
    isopycs_gridded2 = roundn(isopycs_gridded2,-2);
    
    
end