function Stage_10a1_matching_TS_diags_with_without_corrections(VAR,CruiseVARname,CruiseVARname3,CruiseDate)
%
%
% creates plots of T/S diagrams where red dots are uncorrected salnity and
% blue dots are corrected salinity. Information should show on each plot
% indicating (1) which sensor is used and (2) what the correction
% coefficient is.

global Path
% pathname to save figures to based on cruise campaign name:
pnameFIG = [Path.figsTSdiagsWithWithoutCorrections,CruiseVARname,'/'];
% pnameFIG = ['SHIP/FIGS/TSdiags_with_without_corrections/',CruiseVARname,'/'];

    % which sensor?
    sensor = ['Sensor0',num2str(VAR.(CruiseVARname).Sensor)];
    sensor_ = ['_0',num2str(VAR.(CruiseVARname).Sensor)];

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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOTTING T/S DIAGRAM (without zoom):
    
    scrsz = get(groot,'ScreenSize');
    hfig = figure('Position',[scrsz(3)/3 50 scrsz(3)/2 scrsz(4)/3*2]);
    
    % uncorrected in red, corrected in blue:
    plot(VAR.(CruiseVARname).(['SALT',sensor_]),VAR.(CruiseVARname).(['ptemp',sensor_]),'r.') ; 
    hold on
    plot(VAR.(CruiseVARname).Corrected.(sensor).(['SALT',sensor_]),VAR.(CruiseVARname).(['ptemp',sensor_]),'b.') ; 
    
    axis([37.8,39,12.4,14.4])
    set(gca,'Xtick',37.8:0.2:39)
    set(gca,'Ytick',12.4:0.2:14.4)
    
    
    [c1,h] = contour(Sgridded,Tgridded,isopycs_gridded,28:0.1:30,':','Color',[.5 .5 .5]);
    clabel(c1,h,'labelspacing',360,'fontsize',12,'color',[.5 .5 .5]);
    p_ref=0;
    set(gca,'tickdir','out','fontsize',14,'fontweight','bold')
    text(0.01,0.99,[' p_r_e_f = ' int2str(p_ref) ' dbar'],...
    'horiz','left','Vert','top','units','normalized','color',[.3 .3 .3],'fontsize',16);
    
    % which sensor and what is the calibration correction coefficient?
    text(0.01,0.07,[sensor,' Correction coefficient = ',num2str(VAR.(CruiseVARname).Corrected.(sensor).Coefficient)],...
    'horiz','left','Vert','top','units','normalized','color',[.3 .3 .3],'fontsize',16);
    
    text(0.8,0.99,'· uncorrected',...
    'horiz','left','Vert','top','units','normalized','color','r','fontsize',16);
    text(0.8,0.95,'· corrected',...
    'horiz','left','Vert','top','units','normalized','color','b','fontsize',16);
    
    ylabel('Potential Temperature (\theta {\circ}C)','Fontweight','bold','fontsize',16)
    xlabel('Salinity','Fontweight','bold','fontsize',16)
    titleSTR = strcat(CruiseVARname3,': ',CruiseDate);
    title(titleSTR,'Fontweight','bold','fontsize',14)
    clear titleSTR
    
    
    
    if exist('pnameFIG','dir') == 0
        mkdir(pnameFIG)
    end
    saveas(hfig,[pnameFIG,CruiseVARname],'fig');
    
%     hfig2 = gcf;
%     hfig2.PaperPositionMode = 'manual';
%     hfig2.PaperUnits = 'centimeters';
%     hfig2.PaperPosition = [3,5,16.4,25.6]; %hfig2.PaperPosition = [3,10,12,20]; %12 +3.6 for width
    set(hfig,'PaperPosition',[3,5,16.4,25.6],'PaperUnits','centimeters')
    print(hfig,[pnameFIG,CruiseVARname],'-dpdf','-r0')
    close all
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOTTING T/S DIAGRAM (with zoom):    
    scrsz = get(groot,'ScreenSize');
    hzoom = figure('Position',[scrsz(3)/3 50 scrsz(3)/2 scrsz(4)/3*2]);
    
    % uncorrected in red, corrected in blue:
    plot(VAR.(CruiseVARname).(['SALT',sensor_]),VAR.(CruiseVARname).(['ptemp',sensor_]),'r.') ; 
    hold on
    plot(VAR.(CruiseVARname).Corrected.(sensor).(['SALT',sensor_]),VAR.(CruiseVARname).(['ptemp',sensor_]),'b.') ; 
    
    axis([38.4,38.6,12.8,13.6])
    set(gca,'Xtick',38.4:0.05:38.6)
    set(gca,'Ytick',12.8:0.1:13.6)
    
    
    [c1,h] = contour(Sgridded2,Tgridded2,isopycs_gridded2,28.9:0.05:29.3,':','Color',[.5 .5 .5]);
    clabel(c1,h,'labelspacing',360,'fontsize',12,'color',[.5 .5 .5]);
    
    set(gca,'tickdir','out','fontsize',14,'fontweight','bold')
    text(0.01,0.99,[' p_r_e_f = ' int2str(p_ref) ' dbar'],...
    'horiz','left','Vert','top','units','normalized','color',[.3 .3 .3],'fontsize',16);
    
    % which sensor and what is the calibration correction coefficient?
    text(0.01,0.07,[sensor,' Correction coefficient = ',num2str(VAR.(CruiseVARname).Corrected.(sensor).Coefficient)],...
    'horiz','left','Vert','top','units','normalized','color',[.3 .3 .3],'fontsize',16);
    
    text(0.8,0.99,'· uncorrected',...
    'horiz','left','Vert','top','units','normalized','color','r','fontsize',16);
    text(0.8,0.95,'· corrected',...
    'horiz','left','Vert','top','units','normalized','color','b','fontsize',16);

    ylabel('Potential Temperature (\theta {\circ}C)','Fontweight','bold','fontsize',16)
    xlabel('Salinity','Fontweight','bold','fontsize',16)
    titleSTR = strcat(CruiseVARname3,': ',CruiseDate, ': zoomed in');
    title(titleSTR,'Fontweight','bold','fontsize',14)
    clear titleSTR
%     
   
    saveas(hzoom,[pnameFIG,'Zoom_',CruiseVARname],'fig');
    
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

%     hfig3 = gcf;
%     hfig3.PaperPositionMode = 'manual';
%     hfig3.PaperOrientation ='landscape';
%     hfig3.PaperUnits = 'centimeters';
%     hfig3.PaperPosition = [0.5,0.5,26.9,20.5]; %hfig2.PaperPosition = [3,10,12,20]; %12 +3.6 for width  20 16
%     %set(hfig,'PaperPosition',[3,10,12,20],'PaperUnits','centimeters')
%     print(hfig3,[pnameFIG,CruiseVARname,'_Zoom'],'-dpdf','-r0')
      set(hzoom,'PaperPosition',[0.5,0.5,26.9,20.5],'PaperUnits','centimeters','PaperOrientation','landscape')
      print(hzoom,[pnameFIG,CruiseVARname,'_Zoom'],'-dpdf','-r0')
      
    clear CruiseVARname3 CruiseVARname2
    close all