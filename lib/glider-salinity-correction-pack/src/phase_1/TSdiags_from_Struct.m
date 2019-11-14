function CtdCorrDataFile = TSdiags_from_Struct(withGlider,GliderCorr,TESTdat,depNUM_glider, CtdCorrDataFile, CTD)
%
%
% Code description: This code plots TS diagrams of half metre corrected SHIP CTD data, giving
% the user the option of:
% 1) The axes scales
% 2) Which cruises should be selected to plot
% 3) Which 4 cruises, in order, should be plotted on the topmost layer (i.e.
% are most visible).
%
% INPUT:
    % withGlider == 0 (no)  - just plots CTD data.
    % withGlider == 1 (yes) - plots CTD data, then, on top, plots glider
        % data that will be corrected in whitespace correction code (filename Glider_SalinityCorrection_TSdiag_WhitespaceMaximisation.m)
    % GliderCorr == 0 (no)  - plot uncorrected glider data  on top
    % GliderCorr == 1 (yes) - plot uncorrected, then corrected glider data on top
    % TESTdat               - if withGlider == 1, input test data  is the glider data
    % depNUM_glider         - the deployment number of the glider campaign,
    % which has been assigned in the Thredds catalogue where the TESTdata
    % are originally stored.
%
% OUTPUT: save png files of TS diagrams.
%
% Author: Krissy Reeve (kreeve@socib.es)
% Date created: 21/03/2016

global MainPath

% %CTD = load([MainPath.dataHalfmCtdCorrected, 'SHIP_allDATA_halfm_corrected.mat']);
% CtdCorrDataFilePath    = CtdCorrDataFile.path{1,1}{1,1};
% finfo    = ncinfo(CtdCorrDataFilePath);
% CTD.Corrected.SALT_01 = ncread(CtdCorrDataFilePath,'SALT_01_CORR');
% CTD.Corrected.SALT_02 = ncread(CtdCorrDataFilePath,'SALT_02_CORR');
% CTD.Corrected.COND_01 = ncread(CtdCorrDataFilePath,'COND_01_CORR');
% CTD.Corrected.COND_02 = ncread(CtdCorrDataFilePath,'COND_02_CORR');
% CTD.latitude =  ncread(CtdCorrDataFilePath,'LAT');
% CTD.longitude =  ncread(CtdCorrDataFilePath,'LON');
% CTD.pressure =  ncread(CtdCorrDataFilePath,'WTR_PRE');
% CTD.depth =  -1.*gsw_z_from_p(CTD.pressure,CTD.latitude);
% CTD.temp_01 = ncread(CtdCorrDataFilePath,'WTR_TEM_01');
% CTD.temp_02 = ncread(CtdCorrDataFilePath,'WTR_TEM_02');
% CTD.SALT_01 = ncread(CtdCorrDataFilePath,'SALT_01');
% CTD.SALT_02 = ncread(CtdCorrDataFilePath,'SALT_02');
% p_ref = 0;
% CTD.Corrected.ptemp_01 = sw_ptmp(CTD.SALT_01, CTD.temp_01, CTD.pressure, p_ref);
% CTD.Corrected.ptemp_02 = sw_ptmp(CTD.SALT_02, CTD.temp_02, CTD.pressure, p_ref);
% %CTD = CTD.CTD;
FLDS = fieldnames(CTD);

% Extract information from vessel, instrument, dates etc about the CTD
% corrected file name to be compared with FLDS
for i = 1 : size(CtdCorrDataFile.name, 1)
    CtdCorrDataFile.info{i,1} = strsplit(CtdCorrDataFile.name{i}, {'_', '.'}); 
    CtdCorrDataFile.info{i,1} = strrep(CtdCorrDataFile.info{i,1}, '-', '');
end

s1 = [CtdCorrDataFile.info{1,1}{1},'_',CtdCorrDataFile.info{1,1}{2},'_',CtdCorrDataFile.info{1,1}{3},'_',CtdCorrDataFile.info{1,1}{6}];
s = {s1};

if length(CtdCorrDataFile.path) == 2
    % Ask user to select for cruises in order, to be plotted last (and thus
    % over the top of the "background" cruise data):
    FLDS2 = cell(length(s),1);
%     for n=1:length(s)
%         FLDS2{n,1} = FLDS{s(n)};
%     end
    s2 = [CtdCorrDataFile.info{2,1}{1},'_',CtdCorrDataFile.info{2,1}{2},'_',CtdCorrDataFile.info{2,1}{3},'_',CtdCorrDataFile.info{2,1}{6}];
%     [s2,~] = listdlg('PromptString','Select 3 cruises to be plotted last:',...
%                     'SelectionMode','multiple',...
%                     'ListString',FLDS2);
    s = {s1; s2};
end
if length(CtdCorrDataFile.path) == 3 % and which of these cruises should be on the very top:
    FLDS3 = cell(length(s2),1);
%     for n=1:length(s2)
%         FLDS3{n,1} = FLDS2{s2(n)};
%     end
    s3 = [CtdCorrDataFile.info{3,1}{1},'_',CtdCorrDataFile.info{3,1}{2},'_',CtdCorrDataFile.info{3,1}{3},'_',CtdCorrDataFile.info{3,1}{6}];
%     [s3,~] = listdlg('PromptString','Select ONE cruise to be plotted last:',...
%                     'SelectionMode','single',...
%                     'ListString',FLDS3); 
    s = {s1; s2; s3};
end


% DATA QUALITY FLAG BY SALINITY (flags data points where salinity is larger than 40 or less than 28, for both sensors:            
for n=1:length(s)
    if isfield(CTD.Corrected,'SALT_01')==1
        CTD.Corrected.FLAG_01 = ones(size(CTD.Corrected.SALT_01));
        [~,c1] = find(CTD.Corrected.SALT_01>=40 | CTD.Corrected.SALT_01<=28);
        c1 = unique(c1);
        CTD.Corrected.FLAG_01(:,c1) = nan;
%         disp([s(n),'...... Station ',CTD.Station{c1}])
    end
    if isfield(CTD.Corrected,'SALT_02')==1
        CTD.Corrected.FLAG_02 = ones(size(CTD.Corrected.SALT_02));
        [~,c2] = find(CTD.Corrected.SALT_02>=40 | CTD.Corrected.SALT_02<=28);
        c2 = unique(c2);
%         disp([s(n),'...... Station ',CTD.Station{c2}])
        CTD.Corrected.FLAG_02(:,c2) = nan;
    end
end
% Asks user which type of plot they wish to create based on axis limits:
AXES = questdlg('Choose zoom or all','axes','zoom','all','all');

% plot TS of "background" cruises:

% create suitable legend for the diagram:
LEG = cell(length(s),1);
LEG{1} = 'potential density (kg m^{-3})';

legFLD = cell(length(FLDS),1);
for n= 1:length(FLDS)
    imageOutPath = strsplit(FLDS{n},'_corrected_halfmetreBINs');
    legFLD{n} = imageOutPath{1};
end
clear tmpry
% Create colormap:
CC = colormap(jet(length(s)));

%create plot:
scrsz = get(groot,'ScreenSize');
h = figure('Position',[50 50 scrsz(3)-700 scrsz(4)-150]);
if strcmpi(AXES,'zoom')==1
    %potential density grid for contours if plot is "zoomed in":
    XT = [38,38.7,0.05];
    YT = [12.8,14,0.05];
    XMAT = 37.6:0.02:39;
    YMAT = 11.6:0.05:14.6;
    [gXMAT,gYMAT] = meshgrid(XMAT,YMAT);
    gPDENS = sw_pden(gXMAT,gYMAT,0,0);
    [c,hc] = contour(XMAT,YMAT,gPDENS,1015:0.05:1035,'k');
else
    %potential density grid for contours for figure of whole water column:
    XT = [35,40,0.2];
    YT = [8,36,0.5];
    XMAT = 35:0.01:40;
    YMAT = 8:0.1:36;
    [gXMAT,gYMAT] = meshgrid(XMAT,YMAT);
    gPDENS = sw_pden(gXMAT,gYMAT,0,0);
    [c,hc] = contour(XMAT,YMAT,gPDENS,1015:0.5:1035,'k');
end
hold on
% plot the different datasets onto one figure, eac a different colour, and
% legend name:
for n = 1:length(s)
    %hh.(char(s{n}))= plot(reshape(CTD.Corrected.SALT_01.*CTD.Corrected.FLAG_01,[],1),reshape(CTD.Corrected.ptemp_01,[],1),'.','markersize',5,'color',CC(n,:));
    hh.(char(s{n}))= plot(reshape(CTD.Corrected.SALT_01.*CTD.Corrected.FLAG_01,[],1),reshape(CTD.Corrected.ptemp_01,[],1),'.','markersize',5,'color','red');
    LEG{n+1,1} = s{n};     
    hold on
end

% if plotting glider data, plot this over the top in grey, add to the legend:
if withGlider == 1
    hh.TEST = plot(TESTdat.S,TESTdat.PT,'.','markersize',5,'color','k');
    LEG = [LEG;'glider TEST']; 
    if GliderCorr == 1
        hh.TESTcorr = plot(TESTdat.Corr.S,TESTdat.Corr.PT,'.','markersize',5,'color',[0.6,0.6,0.6]);
        LEG = [LEG; ' glider TEST corrected']; 
    end
end
grid on
% plot legend:
LEG{2}=strrep(LEG{2},'_',' ');
LEG{2} = char(LEG{2});
legend(LEG,'location','best')
set(gca,'fontsize',12,'fontweight','b')
% set axis limits
if strcmpi(AXES,'zoom')==1
    set(gca,'xtick',XT(1):XT(3):XT(2))
    set(gca,'ytick',YT(1):YT(3):YT(2))
    xlim([38,38.6])
    ylim([12.8,14])
else
    set(gca,'xtick',XT(1):XT(3):XT(2))
    set(gca,'ytick',YT(1):YT(3):YT(2))
    xlim([36.4,38.8])
    ylim([12,28])
end
xlabel('Salinity','fontsize',14,'fontweight','b')
ylabel('Potential Temperature (deg C)','fontsize',14,'fontweight','b')

% option to have cruise ontop of glider (useful if the glider has more datapoints and "hides" the underlying background data):
if withGlider == 1
    AGAIN = questdlg('Plot with a comparison cruise on top of glider?','stack data','yes','no','no');
    if strcmpi(AGAIN,'yes') == 1
        % uistack(hh.(FLDS{s}),'top')
        %uistack(hh.(s1),'top')
        for k = 1:length(s)
            uistack(hh.(s{k}),'top')
        end
    end
end

% Ask user for suitable axes limits:
prompt = {'Enter max salinity:','Enter min salinity:','Enter max temp:','Enter min temp:'};
dlg_title = 'axes limits';
num_lines = 4;
def = {num2str(XT(2)),num2str(XT(1)),num2str(YT(2)),num2str(YT(1))};
answer = inputdlg(prompt,dlg_title,num_lines,def);
axis([str2double(answer{2}),str2double(answer{1}),str2double(answer{4}),str2double(answer{3})])
% adjust density contour labels accordingly:
if strcmpi(AXES,'zoom')==1
    clabel(c,hc,1015:0.1:1035)
else
    clabel(c,hc,1015:0.5:1035)
end

% Ask user for a keyword by which to save figure:
prompt    = 'Enter keyword for the filename this figure will be saved as:';
dlg_title = 'Filename keyword';
num_lines = 1;
defAns    = {'_'};
KEYWORD = inputdlg(prompt,dlg_title,num_lines,defAns);

% manually move legend so it is not hiding important data points (such as
% that lower tail):
% msgbox('Paused: move legend to best position before continuing')
% pause
legend(LEG,'location','best')


% save figure as a png file with an informative filename:
DIR = dir(MainPath.deploymentFigsTSdiagsCorrectedReference);
if withGlider == 0
    fnameOut = strcat('TSdiag_halfmCORR_',num2str(length(DIR)-2+1),'_',AXES,'_',KEYWORD);
else
    fnameOut = strcat(depNUM_glider,'_TSdiag_halfmCORR_',num2str(length(DIR)-2+1),'_',AXES,'_',KEYWORD);
    fnameOut = char(fnameOut);
end

imageDir = MainPath.outFigsCorrection;
save_figure( fnameOut, imageDir, h )


end



