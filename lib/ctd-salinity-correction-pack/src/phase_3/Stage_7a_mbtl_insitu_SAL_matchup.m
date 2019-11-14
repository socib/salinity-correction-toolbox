function [ctdbtl,insituSal,SALdata,Fname3,PN_fig, unique_sensor, rmX] = Stage_7a_mbtl_insitu_SAL_matchup(manual_outlier_removal, DeploymentInfo)
%
%
% for the selected cruise, matches up the in situ bottle salinity sample with the
% corresponding .btl data.
% input data:
%   1. ctdbtl: struct.mat file created by importing the .btl files of the
%   correspoding cruise, using read_dotbtl_files.m.  File directory:
%   '\SHIP\DATA\CTD\CTD_btlFILES\btlFILES\', under the folder of the
%   corresponding cruiseName. Filename is 'btlDATstruct.mat'.
%   2. insituSal: struct.mat file created by importing standardized excel
%   spreadsheet of in situ bottle salinity data (as determined by a
%   salinometer) using read_insituSalBTL.m. File directory:
%   'DATA\CTD\CTD_btlFILES\inSitu_btl_sal\MATfiles', and filename is
%   cruiseName.
% Step 1: The two input files are cross-referenced in order to extract the
%   ctd (.btl) data that corresponds with each insitu bottle field of data
%   (.insitu).  These are extracted and placed in a new structure, 'SALdata'
%   in the same size vectors.
% Step 2: Outliers are identified and excluded
% Step 3: Conductivity ratios are calculated of each conducivity and
% corrected salinity values are calculated.
%
% Date created: 23/10/2015....
%
% NOTE: in conductivity to/from salinity calculations, depth is used
% instead of pressure.
%
% NOTE: 18/02/2016: SECTION ADDED FOR MANUAL OUTLIER REMOVAL - CHANGE THIS
% SECTION EACH TIME THE CODE IS RUN, UNLESS THE OPTION TO EXCLUDE MANUAL
% OUTLIER REMOVAL IS ACTIVATED IN THE INPUT FUNCTION:
% manual_outlier_removal = 1 excludes manual outlier removal section.
% manual_outlier_removal = 0 includes manual outlier removal section.
%
% any questions: kreeve.socib.es

%% set-up stage
global Path

rmX = []; % empty vector where possible indexes of removed outliers may be allocated in case manual removal is applied
% pathnames of infiles and outfiles:
pnameINinsitu = Path.dataInsituSalinityConverted;
pnameOUT      = Path.dataCorrectionCoefficientsMat;
PN_fig        = Path.figsResidualsInsituSalinity;

% need to select the correct cruiseName manually:
Fname = [pnameINinsitu,DeploymentInfo.deploymentName];
Fname3 = DeploymentInfo.deploymentName;
pnameBTL = Path.dataCtdBtlMat;
FN = dir([pnameBTL,'*.mat']);
load([pnameBTL,DeploymentInfo.deploymentName,'.mat']) % structure should be called "ctdbtl" each time
load(Fname) % structure should be called "insituSal"


% Check both sensors are available, if not, call mtbl_insitu_SAL_matchup_unique_Sensor.m:
STATIONS = fields(ctdbtl);
if sum(strcmp(fields(ctdbtl.(STATIONS{1})),'T090C'))==0 || sum(strcmp(fields(ctdbtl.(STATIONS{1})),'Sal00'))==0
    disp('T090C and/or Sal00 sensor missing, calling mtbl_insitu_SAL_matchup_unique_Sensor.m...')
    [ctdbtl,insituSal,SALdata,Fname3,PN_fig] = Stage_7b_mbtl_insitu_SAL_matchup_unique_Sensor(manual_outlier_removal, DeploymentInfo, ctdbtl, insituSal, Fname3);
    unique_sensor = 'True';
elseif sum(strcmp(fields(ctdbtl.(STATIONS{1})),'T190C'))==0 || sum(strcmp(fields(ctdbtl.(STATIONS{1})),'Sal11'))==0
    disp('T190C and/or Sal11 sensor missing, calling mtbl_insitu_SAL_matchup_unique_Sensor.m...')
%     Stage_7b_mbtl_insitu_SAL_matchup_unique_Sensor(0,manual_outlier_removal)
    [ctdbtl,insituSal,SALdata,Fname3,PN_fig] = Stage_7b_mbtl_insitu_SAL_matchup_unique_Sensor(manual_outlier_removal, DeploymentInfo, ctdbtl, insituSal, Fname3);
    unique_sensor = 'True';
else
    % set up new struct file, with first order fields of insitu (i.e. in situ 
    %lab-based bottle salinity) and btl (ctd .btl file):
    SALdata.insitu = insituSal;
    SALdata.btl.DateNum      = nan(size(insituSal.Depth));
    SALdata.btl.depth        = nan(size(insituSal.Depth));
    SALdata.btl.lat          = nan(size(insituSal.Depth));
    SALdata.btl.T090C        = nan(size(insituSal.Depth));
    SALdata.btl.T190C        = nan(size(insituSal.Depth));
    SALdata.btl.C0mSpercm    = nan(size(insituSal.Depth));
    SALdata.btl.C1mSpercm    = nan(size(insituSal.Depth));
    SALdata.btl.Sal00        = nan(size(insituSal.Depth));
    SALdata.btl.Sal11        = nan(size(insituSal.Depth));
    SALdata.btl.Sbeox0MgperL = nan(size(insituSal.Depth));
    unique_sensor = 'False';

    %% Stage 1: match up stations and bottle data- cross-referencing across insitu and btl...
    stationBTL = fields(ctdbtl);
    for n = 1:length(insituSal.Station)
        i = strcmpi(stationBTL,insituSal.Station{n});                                % first find the matching stations
        if sum(i)==0
            i = strcmpi(stationBTL,strrep(insituSal.Station{n},'-','_'));            % first find the matching stations
        end
        if sum(i)~=0
            i2 = find(ctdbtl.(stationBTL{i}).Bottle==insituSal.Bottle(n));          % default way of matching up data at the correct station is by bottle number
            if isempty(i2) == 1
                i2 = knnsearch(ctdbtl.(stationBTL{i}).DepSM, insituSal.Depth(n));   % if bottle number is missing from insitu file, match data by finding the closest corresponding depths
            end
            SALdata.btl.depth(n)        = ctdbtl.(stationBTL{i}).DepSM(i2);         % complete new struct file with data from btl and insitu, where each row of each 
            if isfield(ctdbtl.(stationBTL{i}),'Latitude') == 1
                SALdata.btl.lat(n)          = ctdbtl.(stationBTL{i}).Latitude(i2);      %   vector coresponds to the same station, depth and thus data.
            end
            SALdata.btl.DateNum(n)      = ctdbtl.(stationBTL{i}).DATEnum(i2);
            SALdata.btl.T090C(n)        = ctdbtl.(stationBTL{i}).T090C(i2);
            SALdata.btl.T190C(n)        = ctdbtl.(stationBTL{i}).T190C(i2);
            SALdata.btl.C0mSpercm(n)    = ctdbtl.(stationBTL{i}).C0mSpercm(i2);
            SALdata.btl.C1mSpercm(n)    = ctdbtl.(stationBTL{i}).C1mSpercm(i2);
            SALdata.btl.Sal00(n)        = ctdbtl.(stationBTL{i}).Sal00(i2);
            SALdata.btl.Sal11(n)        = ctdbtl.(stationBTL{i}).Sal11(i2);
            SALdata.btl.Sbeox0MgperL(n) = ctdbtl.(stationBTL{i}).Sbeox0MgperL(i2);
        end
        clear i i2
    end
    
    [~, IX] = sort(SALdata.btl.DateNum);
    BTLfields = fields(SALdata.btl);
    inSITUfields = fields(SALdata.insitu);
    for n=1:length(BTLfields)
        SALdata.btl.(BTLfields{n}) = SALdata.btl.(BTLfields{n})(IX,1);
    end
    for n=1:length(inSITUfields)
        if strcmp(inSITUfields{n},'CommentsWhole') == 0
%             if isempty(SALdata.insitu.(inSITUfields{n})) == 1
%                 SALdata.insitu.(inSITUfields{n}) = NaN(length(IX),1);
%             end
            SALdata.insitu.(inSITUfields{n}) = SALdata.insitu.(inSITUfields{n})(IX,1);
        end
    end
    
    ii = find(isnan(SALdata.btl.DateNum)==1 & isnan(SALdata.insitu.Depth)==1);
    BTLfields2    = fieldnames(SALdata.btl);
    inSITUfields2 = fieldnames(SALdata.insitu);
    for n=1:length(BTLfields2)
        SALdata.btl.(BTLfields2{n})(ii) = [];
    end
    for n=1:length(inSITUfields2)
        SALdata.insitu.(inSITUfields2{n})(ii) = [];
    end

    %% Stage 2: Define, identify and exclude outliers in preparation for the correction calculation.
    %
    xlim_max = length(SALdata.insitu.Calculated_Salinity);
    
    % find the residuals between btl(cd) and insitu(lab) salinity, and plot:
    resid_Sal00 = SALdata.insitu.Calculated_Salinity-SALdata.btl.Sal00;
    resid_Sal11 = SALdata.insitu.Calculated_Salinity-SALdata.btl.Sal11;
    scrsz = get(groot,'ScreenSize');
    h = figure('Position',[50 50 scrsz(3)-300 scrsz(4)-150]);
    %plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00,'hr','markersize',14)
    plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00,'hk','markersize',16,'markerfacecolor','k')
    hold on
    %plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11,'*b','markersize',16)
    scatter(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11,86,SALdata.btl.Sal11,'o','filled')
    hbar=colorbar;
    CMi=37;CMa=38.8;
    caxis([CMi,CMa])
    cmap=colormap(jet(length(CMi:0.1:CMa)-1));
    set(hbar,'ytick',CMi:0.1:CMa)
    %plot(0:(roundn(length(SALdata.insitu.Calculated_Salinity),1)),repmat(nanmean(resid_Sal00),roundn(length(SALdata.insitu.Calculated_Salinity),1)+1,1),'r-','linewidth',2)
    plot(0:(xlim_max),repmat(nanmean(resid_Sal00),xlim_max+1,1),'r-','linewidth',2)
    %plot(0:(roundn(length(SALdata.insitu.Calculated_Salinity),1)),repmat(nanmean(resid_Sal11),(roundn(length(SALdata.insitu.Calculated_Salinity),1))+1,1),'b-','linewidth',2)
    plot(0:(xlim_max),repmat(nanmean(resid_Sal11),xlim_max+1,1),'b-','linewidth',2)
    legend('Sensor00','Sensor11','mean residual Sal00','mean residual Sal11','Location','best')
    grid on
    ylabel('residual salinity (in situ - sensor)','fontname','arial','fontsize',16,'fontweight','bold')
    set(gca,'fontsize',16,'fontweight','b')
%     set(gca,'ytick',-0.1:0.02:0.34)
%     ylim([-0.1,0.34])
    set(gca,'ytick',-0.8:0.02:0.8)
    ylim([-0.2,0.2])
    %xlim([0 roundn(length(SALdata.insitu.Calculated_Salinity),1)])
    xlim([0,xlim_max])
    set(gca,'xtick',0:2:xlim_max)
    title(strrep(Fname3,'_',' '),'fontsize',18,'fontweight','b')
    PnamFIG = [PN_fig,Fname3,'/'];
    %print(gcf,[PnamFIG,'SalResid_beforeCorrection',Fname3{1}],'-dpng','-r0')
    img = getframe(gcf);
    if exist([PN_fig,DeploymentInfo.deploymentName]) == 0
        mkdir([PN_fig,DeploymentInfo.deploymentName])
    end
    imwrite(img.cdata, [PnamFIG,'SalResid_beforeCorrection_',Fname3, '.png']);
    
    %% **************OUTLIER REMOVAL: MANUAL FOLLOWED BY STATISTICAL***************
    % manual based on comments in salinity spreadsheet and any specific
    % justifiable desisions.
    
    indTOkeep = ones(size(SALdata.insitu.Calculated_Salinity));
    
    %% 1) MANUAL OUTLIER REMOVAL:
    % manually assess figure as well as in situ spread sheet, and remove
    % the outliers that can be justified as outliers. THIS SECTION WILL
    % CHANGE EACH TIME THE CODE IS RUN!!!!
    if manual_outlier_removal == 0
        % Remove certain data points based on their index number (look on
        % residual plot to make this decision):
        iiii=find(SALdata.btl.depth<10);
        rmX = questDialogManualOutlierRemoval(SALdata, resid_Sal00, resid_Sal11,Fname3,PN_fig);
        indTOcircle = nan(size(SALdata.insitu.Calculated_Salinity));
        % to alter each time manual_outlier_removal==0!!!
        % Removes data points where there is a comment in the insitu
        % comments field, which is based on the comments on the
        % saliinometer excel spreadsheet:
        for n = 1:length(SALdata.insitu.Comments)
            if isempty(SALdata.insitu.Comments{n})~=0
                indTOkeep(n) = nan;
                indTOcircle(n) = 1;
            end
        end
        indTOkeep(rmX) = nan;
        indTOcircle(rmX) = 1;
        hold on
        plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00.*indTOcircle,'or','markersize',16)
        plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11.*indTOcircle,'ob','markersize',14)
        text(5,0.12,{'Circles: data points to be removed based on spreadsheet';' comments and manual outlier removal'},'fontsize',12,'fontweight','b','backgroundcolor','w','edgecolor','k')
        PnamFIG = [PN_fig,Fname3,'\'];
        %print(gcf,[PnamFIG,'SalResid_beforeCorrection_Manual_outliersCircled',Fname3{1}],'-dpng','-r0')
        img = getframe(gcf);
        imwrite(img.cdata, [PnamFIG,'SalResid_beforeCorrection_Manual_outliersCircled',Fname3, '.png']);
        
        h = figure('Position',[50 50 scrsz(3)-300 scrsz(4)-150]);
%         plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00.*indTOkeep,'*r','markersize',18)
        plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00.*indTOkeep,'hk','markersize',16,'markerfacecolor','k')
        hold on
%         plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11.*indTOkeep,'*b','markersize',14)
        scatter(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11.*indTOkeep,86,SALdata.btl.Sal11,'o','filled')
        hbar=colorbar;
        caxis([CMi,CMa])
        cmap=colormap(jet(length(CMi:0.1:CMa)-1));
        set(hbar,'ytick',CMi:0.1:CMa)
        plot(0:length(SALdata.insitu.Calculated_Salinity),repmat(nanmean(resid_Sal00.*indTOkeep),length(SALdata.insitu.Calculated_Salinity)+1,1),'r-','linewidth',2)
        plot(0:length(SALdata.insitu.Calculated_Salinity),repmat(nanmean(resid_Sal11.*indTOkeep),length(SALdata.insitu.Calculated_Salinity)+1,1),'b-','linewidth',2)
        legend('Sensor00','Sensor11','mean residual Sal00','mean residual Sal11','Location','best')
        grid on
        ylabel('residual salinity (in situ - sensor)','fontname','arial','fontsize',16,'fontweight','bold')
        set(gca,'fontsize',16,'fontweight','b')
        set(gca,'ytick',-0.02:0.005:0.08)
        ylim([-0.02,0.04])
        %xlim([0,roundn(length(SALdata.insitu.Calculated_Salinity),1)])
        xlim([0,xlim_max])
        set(gca,'xtick',0:2:xlim_max)
        title([strrep(Fname3,'_',' '),': after manual outlier removal'],'fontsize',18,'fontweight','b')
        PnamFIG = [PN_fig,Fname3,'\'];
        %print(gcf,[PnamFIG,'SalResid_beforeCorrection_MANUALoutlierREM',Fname3{1}],'-dpng','-r0')
        img = getframe(gcf);
        imwrite(img.cdata, [PnamFIG,'SalResid_beforeCorrection_MANUALoutlierREM_',Fname3, '.png']);
    end
        
    XX = 2;
    XX2 = 1;

    %% 2) STATISTICAL OUTLIER REMOVAL:
    % identify outliers where the difference between the two ctd sensors (Sal00 and Sal11) is larger than
    %0.01:
    %salSensorDiff = abs(SALdata.btl.Sal00-SALdata.btl.Sal11);
    salSensorDiffMean = nanmean(SALdata.btl.Sal00-SALdata.btl.Sal11);
    salSensorDiff = abs(SALdata.btl.Sal00-SALdata.btl.Sal11-salSensorDiffMean);
    indTOkeep(salSensorDiff > 0.01) = nan;
    % Remove outliers that deviate more than XX*std's from the mean:
    meanResid_Sal00 = nanmean(resid_Sal00.*indTOkeep);
    meanResid_Sal11 = nanmean(resid_Sal11.*indTOkeep);
    stdResid_Sal00  = nanstd(resid_Sal00.*indTOkeep);
    stdResid_Sal11  = nanstd(resid_Sal11.*indTOkeep);
    indTOkeep00 = indTOkeep;
    indTOkeep11 = indTOkeep;
    indTOkeep00((resid_Sal00.*indTOkeep00)>(meanResid_Sal00+XX*stdResid_Sal00) | (resid_Sal00.*indTOkeep00)<(meanResid_Sal00-XX*stdResid_Sal00)) = nan;
    indTOkeep11((resid_Sal11.*indTOkeep11)>(meanResid_Sal11+XX*stdResid_Sal11) | (resid_Sal11.*indTOkeep11)<(meanResid_Sal11-XX*stdResid_Sal11)) = nan;
    % Remove outliers that deviate more than 2*std's from the mean, a second
    % time:
    meanResid2_Sal00 = nanmean(resid_Sal00.*indTOkeep00);
    meanResid2_Sal11 = nanmean(resid_Sal11.*indTOkeep11);
    stdResid2_Sal00  = nanstd(resid_Sal00.*indTOkeep00);
    stdResid2_Sal11  = nanstd(resid_Sal11.*indTOkeep11);
    indTOkeep00((resid_Sal00.*indTOkeep00)>(meanResid2_Sal00+XX2*stdResid2_Sal00) | (resid_Sal00.*indTOkeep00)<(meanResid2_Sal00-XX2*stdResid2_Sal00)) = nan;
    indTOkeep11((resid_Sal11.*indTOkeep11)>(meanResid2_Sal11+XX2*stdResid2_Sal11) | (resid_Sal11.*indTOkeep11)<(meanResid2_Sal11-XX2*stdResid2_Sal11)) = nan;
    meanResid3_Sal00 = nanmean(resid_Sal00.*indTOkeep00);
    meanResid3_Sal11 = nanmean(resid_Sal11.*indTOkeep11);
    stdResid3_Sal00  = nanstd(resid_Sal00.*indTOkeep00);
    stdResid3_Sal11  = nanstd(resid_Sal11.*indTOkeep11);
    % indTOkeep00 and indTOkeep11 are the variables that mark which data points
    % should be used in the correction calculations.  Outliers are nan's.

    %% Stage 3: calculating the conductivity ratios for application of field corrected salinity.
    % Equations:
    %           conductivity00 = A*(conductivity of sensor 00)
    %           conductivity11 = B*(conductivity of sensor 11)
    % where
    %        A = sum(conducivity(lab)*conducivity(ctdbtl))/sum(conductivity(ctdbtl)^2)
    %           (or mean[con(lab)*con(ctdbtl)]/mean(con(ctdbtl)^2)
    % For calculating B the same eqation is applied but with sensor 11.
    %
    % Calculate the conductivity of in-situ bottle salinity (NOTE DEPTH IS USED INSTEAD OF PRESSURE!!!!!):
    SALdata.insitu.C0mSpercm = gsw_C_from_SP(SALdata.insitu.Calculated_Salinity,SALdata.btl.T090C,SALdata.btl.depth);
    SALdata.insitu.C1mSpercm = gsw_C_from_SP(SALdata.insitu.Calculated_Salinity,SALdata.btl.T190C,SALdata.btl.depth);
    %
    % Calculate A and B in order to determine the cunductivity ratios:
    A = nansum(SALdata.insitu.C0mSpercm.*SALdata.btl.C0mSpercm.*indTOkeep00)./nansum((SALdata.btl.C0mSpercm.*indTOkeep00).^2);
    B = nansum(SALdata.insitu.C1mSpercm.*SALdata.btl.C1mSpercm.*indTOkeep11)./nansum((SALdata.btl.C1mSpercm.*indTOkeep11).^2);

    % Calculate the corrected ctdbtl conductivities, and thus salinities (NOTE DEPTH IS USED INSTEAD OF PRESSURE!!!!!):
    SALdata.btl.C0mSpercm_CORRECTED = SALdata.btl.C0mSpercm.*A;
    SALdata.btl.C1mSpercm_CORRECTED = SALdata.btl.C1mSpercm.*B;
    SALdata.btl.Sal00_CORRECTED     = gsw_SP_from_C(SALdata.btl.C0mSpercm_CORRECTED,SALdata.btl.T090C,SALdata.btl.depth);
    SALdata.btl.Sal11_CORRECTED     = gsw_SP_from_C(SALdata.btl.C1mSpercm_CORRECTED,SALdata.btl.T190C,SALdata.btl.depth);

    % Plot the residuals of the corrected ctdbtl salinities to the in situ
    % (lab) salinities: how much of an improvement? Look at the means and
    % standard deviations:
    resid_Sal00_COR = SALdata.insitu.Calculated_Salinity-SALdata.btl.Sal00_CORRECTED;
    resid_Sal11_COR = SALdata.insitu.Calculated_Salinity-SALdata.btl.Sal11_CORRECTED;
    hold on
    plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00_COR.*indTOkeep00,'sk','markersize',10,'markerfacecolor','m')
    hold on
    plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11_COR.*indTOkeep11,'dk','markersize',10,'markerfacecolor','b')
    plot(0:length(SALdata.insitu.Calculated_Salinity),repmat(nanmean(resid_Sal00_COR.*indTOkeep00),length(SALdata.insitu.Calculated_Salinity)+1,1),'r--','linewidth',3)
    plot(0:length(SALdata.insitu.Calculated_Salinity),repmat(nanmean(resid_Sal11_COR.*indTOkeep11),length(SALdata.insitu.Calculated_Salinity)+1,1),'b--','linewidth',2)
    legend('Sensor00','Sensor11','mean residual Sal00','mean residual Sal11','Corrected Sensor00','Corrected Sensor11','mean residual Sal00','mean residual Sal11','Location','best')
    %print(gcf,[PnamFIG,'SalResid_with_without_correction_',Fname3{1}],'-dpng','-r0')
    img = getframe(gcf);
    imwrite(img.cdata, [PnamFIG,'SalResid_with_without_correction_',Fname3, '.png']);
    
    h2 = figure('Position',[50 50 scrsz(3)-300 scrsz(4)-150]);
%     plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00_COR.*indTOkeep00,'sr','markersize',10,'markerfacecolor','r')
%     hold on
%     plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11_COR.*indTOkeep11,'db','markersize',10,'markerfacecolor','b')
    plot(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal00_COR.*indTOkeep00,'hk','markersize',16,'markerfacecolor','k')
    hold on
    scatter(1:length(SALdata.insitu.Calculated_Salinity),resid_Sal11_COR.*indTOkeep11,86,SALdata.btl.Sal11,'o','filled')
    hbar=colorbar;
    caxis([CMi,CMa])
    cmap=colormap(jet(length(CMi:0.1:CMa)-1));
    set(hbar,'ytick',CMi:0.1:CMa)
    plot(0:roundn(length(SALdata.insitu.Calculated_Salinity),1)+5,repmat(nanmean(resid_Sal00_COR.*indTOkeep00),roundn(length(SALdata.insitu.Calculated_Salinity),1)+6,1),'r--','linewidth',3)
    plot(0:roundn(length(SALdata.insitu.Calculated_Salinity),1)+5,repmat(nanmean(resid_Sal11_COR.*indTOkeep11),roundn(length(SALdata.insitu.Calculated_Salinity),1)+6,1),'b:','linewidth',3)
    legend('Corrected Sensor01','Corrected Sensor02','mean residual Sal00','mean residual Sal11','Location','best')
    grid on
    ylabel('residual salinity (in situ - sensor)','fontname','arial','fontsize',16,'fontweight','bold')
    set(gca,'fontsize',16,'fontweight','b')
    set(gca,'ytick',-0.015:0.001:0.015)
    set(gca,'xtick',0:2:xlim_max)
    title([strrep(Fname3,'_',' '),' Corrected'],'fontsize',18,'fontweight','b')
    ylim([-0.015 0.015])    
    %xlim([0,roundn(length(SALdata.insitu.Calculated_Salinity),1)])
    xlim([0,xlim_max])
    format long
    text(2,-0.011,{['Sensor00 Coeff = ',sprintf('%0.15f',A)];['mean resid Sensor00: ',num2str(nanmean(resid_Sal00_COR.*indTOkeep00)),' \pm ',num2str(nanstd(resid_Sal00_COR.*indTOkeep00))];...
        ['Sensor11 Coeff = ',sprintf('%0.15f',B)];['mean resid Sensor11: ',num2str(nanmean(resid_Sal11_COR.*indTOkeep11)),' \pm ',num2str(nanstd(resid_Sal11_COR.*indTOkeep11))]},'fontsize',12,...
        'fontweight','b', 'backgroundcolor','w','edgecolor','k');
    for n=1:length(resid_Sal00_COR)
        text(n+0.75,resid_Sal00_COR(n).*indTOkeep00(n),{[num2str(round(SALdata.btl.depth(n))),' m'];strrep(SALdata.insitu.Station{n},'_','-')},'fontsize',12,'fontweight','b')
    end
    %print(gcf,[PnamFIG,'SalResid_Corrected_',Fname3{1}],'-dpng')
    img = getframe(gcf);
    imwrite(img.cdata, [PnamFIG,'SalResid_Corrected_',Fname3, '.png']);
    
    SALdata.meanResid_COR.Sal00 = nanmean(resid_Sal00_COR.*indTOkeep00);
    SALdata.meanResid_COR.Sal11 = nanmean(resid_Sal11_COR.*indTOkeep11);
    SALdata.stdResid_COR.Sal00  = nanstd(resid_Sal00_COR.*indTOkeep00);
    SALdata.stdResid_COR.Sal11  = nanstd(resid_Sal11_COR.*indTOkeep11); 
    
    

    %If happy with the corrections, save the correction coefficients within the
    %structure array SALdata and save as a mat file under the directory: pnameOUT = 'SHIP\DATA\CTD\CTD_btlFILES\MASHUP\';
    % So we have the correction of the form:
    %       Conductivity adjusted = A*Conductivity (sensor 00)
    %       Conductivity adjusted = B*Conductivity (sensor 11)
    % The sensor with the smallest correction coefficient should be used in the
    % calibration equations for CTD salinity corrections.
    SALdata.A00 = A;
    SALdata.B11 = B;
    
    
    %%************************MANUAL INPUT!!!! Provide summary of procedure to remove outliers***********************
    % provide quick summary of procedure to remove outliers
    SALdata.CorrectionSummary = {'1) Manual: Removed all data points which were flagged during the salinometer anaylsis, and all data points<10 m along with other obvious outliers.';...           %, along with other obvious outliers
        '2) Removed all data points where the difference between sensors (residuals) is larger than 0.01 from the mean difference.';...
        ['3) Removed all residual data points that deviate more than ',num2str(XX),'*stds from mean.'];...
        ['4) removed all residual data points that deviate more than ',num2str(XX2),'*stds from the new mean']};
    
%      SALdata.CorrectionSummary = {'1) No Manual: no data points were flagged during the salinometer anaylsis.';...
%         '2) Removed all data points where the difference between sensors (residuals) is larger than 0.01.';...
%         ['3) Removed all residual data points that deviate more than ',num2str(XX),'*stds from mean.'];...
%         ['4) removed all residual data points that deviate more than ',num2str(XX2),'*stds from the new mean']};
    
    save([pnameOUT,Fname3,'_Correction_Coeff'],'SALdata')
end
