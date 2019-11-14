function stage1_read_data_from_thredds(DIR, ncL1FileName)
%
%
% Reads and loads data from netcdf files stored in:
% SHIP/DATA/CTD/CTD_L1_Thredds and creates
% structured arrays and T/S profiles

% d = ncFilesList;
% [s,v] = listdlg('PromptString','Select a file:',...
%                 'SelectionMode','single',...
%                 'ListString',d)

global Path
global ONLINE_MODE

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

    X=strsplit(filename,'_L1_');
    X2=strsplit(X{2},'.nc');
    CruiseDate=X2{1};
    CruiseVARname = strrep(X{1},'-','_');
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
    %pot_rho_t_exact                 = sw_pden(VAR.(CruiseVARname).salinity,VAR.(CruiseVARname).insituT,VAR.(CruiseVARname).pressure,p_ref);
    % ship conductivity units are units: ms cm-1 (for S m-1 x100 /1000 = /10)
        %condShip        = VAR.COND_01 / 10;
        %timeShip        = VAR.time/(60*60*24)  + datenum(1970,1,1,0,0,0) ; % sciTime to matlab time
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % isopycynals for T/S diagram:
    VAR.DminT(n,1) = min(min(VAR.(CruiseVARname).ptemp));
    VAR.DmaxT(n,1) = max(max(VAR.(CruiseVARname).ptemp));
    VAR.DminS(n,1) = min(min(VAR.(CruiseVARname).salinity));
    VAR.DmaxS(n,1) = max(max(VAR.(CruiseVARname).salinity));
    % end
    %axis([37.8,39,12.4,14.4])
    DminT = 10;%min(VAR.DminT);
    DmaxT = 15;%max(VAR.DmaxT);
    DminS = 36;%min(VAR.DminS);
    DmaxS = 40;%max(VAR.DmaxS);
    
    %axis([38.4,38.6,12.8,13.6])
    DminT2 = 12.6;%min(VAR.DminT);
    DmaxT2 = 13.8;%max(VAR.DmaxT);
    DminS2 = 38.2;%min(VAR.DminS);
    DmaxS2 = 38.8;%max(VAR.DmaxS);
    
%     DmaxT = 13.6;
%     DminT = 12.6;
%     DmaxS = 38.6;
%     DminS = 38.4;

  %  Smin  = DminS - 0.5*(DmaxS - DminS);
  %  Smax  = DmaxS + 0.5*(DmaxS - DminS);
  %  Saxis = [Smin:(Smax-Smin)/1000:Smax];
    Saxis = DminS:(DmaxS-DminS)/1000:DmaxS;

%     DminSA = 36;%min(min(SA));
%     DmaxSA = 41;%max(max(SA));
%     DminSA2 = 38;%min(min(SA));
%     DmaxSA2 = 40;%max(max(SA));
%     
%     SAmin  = DminSA - 0.5*(DmaxSA - DminSA);
%     SAmax  = DmaxSA + 0.5*(DmaxSA - DminSA);
%     SAaxis = SAmin:(SAmax-SAmin)/1000:SAmax;

%     Tmin  = DminT - 0.5*(DmaxT - DminT);
%     Tmax  = DmaxT + 0.5*(DmaxT - DminT);
%     Taxis = Tmin:(Tmax-Tmin)/600:Tmax;
      Taxis = DminT:(DmaxT-DminT)/600:DmaxT;
    
%      Smin2  = DminS2 - 0.5*(DmaxS2 - DminS2);
%      Smax2  = DmaxS2 + 0.5*(DmaxS2 - DminS2);
%      Saxis2 = Smin2:(Smax2-Smin2)/1000:Smax2;
      Saxis2 = DminS2:(DmaxS2-DminS2)/1000:DmaxS2;
% 
%     Tmin2  = DminT2 - 0.5*(DmaxT2 - DminT2);
%     Tmax2  = DmaxT2 + 0.5*(DmaxT2 - DminT2);
%     Taxis2 = Tmin2:(Tmax2-Tmin2)/600:Tmax2;
      Taxis2 = DminT2:(DmaxT2-DminT2)/600:DmaxT2;

    
    clear DminS DmaxS DminSA DmaxSA DminT DmaxT

    Sgridded = meshgrid(Saxis,1:length(Taxis));%36:0.001:41,12.6:0.001:13.8);
    Tgridded  = meshgrid(Taxis,1:length(Saxis))'; %36:0.001:41,12.6:0.001:13.8);

    isopycs_gridded = sw_dens0(Sgridded,Tgridded)-1000;%gsw_sigma0_pt0_exact(SAgridded,Tgridded);
    isopycs_gridded=roundn(isopycs_gridded,-2);

    
    Sgridded2 = meshgrid(Saxis2,1:length(Taxis2));
    Tgridded2  = meshgrid(Taxis2,1:length(Saxis2))';

    isopycs_gridded2 = sw_dens0(Sgridded2,Tgridded2)-1000;
    isopycs_gridded2=roundn(isopycs_gridded2,-2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOTTING T/S DIAGRAM:
    
    scrsz = get(groot,'ScreenSize');
    hfig = figure('Position',[scrsz(3)/3 50 scrsz(3)/2 scrsz(4)/3*2]);
    
    plot(VAR.(CruiseVARname).salinity,VAR.(CruiseVARname).ptemp,'b.') ; 
    hold on
    
    axis([37.8,39,12.4,14.4])
    set(gca,'Xtick',37.8:0.2:39)
    set(gca,'Ytick',12.4:0.2:14.4)
    
    
    [c1,h] = contour(Sgridded,Tgridded,isopycs_gridded,28:0.1:30,':','Color',[.5 .5 .5]);
    clabel(c1,h,'labelspacing',360,'fontsize',12,'color',[.5 .5 .5]);
    
    set(gca,'tickdir','out','fontsize',14,'fontweight','bold')
    text(0.01,0.99,[' p_r_e_f = ' int2str(p_ref) ' dbar'],...
    'horiz','left','Vert','top','units','normalized','color',[.3 .3 .3],'fontsize',16);
    
    
    ylabel('Potential Temperature (\theta {\circ}C)','Fontweight','bold','fontsize',16)
    xlabel('Salinity','Fontweight','bold','fontsize',16)
    titleSTR = strcat(CruiseVARname3,': ',CruiseDate);
    title(titleSTR,'Fontweight','bold','fontsize',14)
    clear titleSTR
    

    saveas(hfig,[pnameFIG,CruiseVARname],'fig');
    
    hfig2 = gcf;
    hfig2.PaperPositionMode = 'manual';
    hfig2.PaperUnits = 'centimeters';
    hfig2.PaperPosition = [3,5,16.4,25.6]; %hfig2.PaperPosition = [3,10,12,20]; %12 +3.6 for width
    %set(hfig,'PaperPosition',[3,10,12,20],'PaperUnits','centimeters')
    print(hfig2,[pnameFIG,CruiseVARname],'-dpdf','-r0')
    close all
    
%     yZoomMax = Tmax;
%     yZoomMin = Tmin;
%     xZoomMax = Smax;
%     xZoomMin = Smin;
%     yZoomMax = 13.6;
%     yZoomMin = 12.6;
%     xZoomMax = 38.6;
%     xZoomMin = 38.4;
%     axis([xZoomMin xZoomMax,yZoomMin yZoomMax]);

 scrsz = get(groot,'ScreenSize');
    hzoom = figure('Position',[scrsz(3)/3 50 scrsz(3)/2 scrsz(4)/3*2]);
    
    plot(VAR.(CruiseVARname).salinity,VAR.(CruiseVARname).ptemp,'b.') ; 
    hold on
    
    axis([38.4,38.6,12.8,13.6])
    set(gca,'Xtick',38.4:0.05:38.6)
    set(gca,'Ytick',12.8:0.1:13.6)
    
    
    [c1,h] = contour(Sgridded2,Tgridded2,isopycs_gridded2,28.9:0.05:29.3,':','Color',[.5 .5 .5]);
    clabel(c1,h,'labelspacing',360,'fontsize',12,'color',[.5 .5 .5]);
    
    set(gca,'tickdir','out','fontsize',14,'fontweight','bold')
    text(0.01,0.99,[' p_r_e_f = ' int2str(p_ref) ' dbar'],...
    'horiz','left','Vert','top','units','normalized','color',[.3 .3 .3],'fontsize',16);
    
    
    ylabel('Potential Temperature (\theta {\circ}C)','Fontweight','bold','fontsize',16)
    xlabel('Salinity','Fontweight','bold','fontsize',16)
    titleSTR = strcat(CruiseVARname3,': ',CruiseDate, ': zoomed in');
    title(titleSTR,'Fontweight','bold','fontsize',14)
    clear titleSTR
%     
   
    
    saveas(hzoom,[pnameFIGzoom,CruiseVARname],'fig');
    
%     set(hzoom,'PaperPosition',[3,10,12,20],'PaperUnits','centimeters')
%     print(hzoom,[pnameFIG,CruiseVARname],'-dpdf')
% ti = get(gca,'TightInset')
% set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
% set(gca,'units','centimeters')
% pos = get(gca,'Position');
% ti = get(gca,'TightInset');
% 
% set(gcf, 'PaperUnits','centimeters');
% set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

    hfig3 = gcf;
    hfig3.PaperPositionMode = 'manual';
    hfig3.PaperOrientation ='landscape';
    hfig3.PaperUnits = 'centimeters';
    hfig3.PaperPosition = [0.5,0.5,26.9,20.5]; %hfig2.PaperPosition = [3,10,12,20]; %12 +3.6 for width  20 16
    %set(hfig,'PaperPosition',[3,10,12,20],'PaperUnits','centimeters')
    print(hfig3,[pnameFIGzoom,CruiseVARname,'_Zoom'],'-dpdf','-r0')
    
    clear CruiseVARname3 CruiseVARname2
    close all
end    
    
    