function Stage_14e_TSdiag_all_halfMetreBIN_corrected
%
%
% loads corrected half metre bin ship data and creates TSdiags.
global Path

PN_in = Path.dataCorrectedMatHalfmBinAvg;
PN_fig = Path.figsTSdiagsCorrectedReferenceHalfmAll;
FN_fig = ['Theta_S_shipCorrected_all_',date];
% PN_in = 'SHIP/DATA/CTD/CTD_correction_files/halfmetreBIN/matfiles/';
% PN_fig = 'SHIP/FIGS/TSdiag_corrected_Reference/halfmetre_all/';
% FN_fig = ['Theta_S_shipCorrected_all_',date];

DIR = dir([PN_in,'*.mat']);

for n=1:length(DIR)
    x = strsplit(DIR(n).name,'_');
    if isempty(strfind(x{2},'dep'))==0
        DEP = x{2};
    elseif isempty(strfind(x{1},'dep'))==0
        DEP = x{1};
    end
    DATA.(DEP) = load([PN_in,DIR(n).name]);
    [yr,~,~] = datevec(DATA.(DEP).dataCTD.sciTime);
    DATA.(DEP).YR = nanmean(yr);
    clear yr mnth ddd
end


for zoom=1:2
    scrsz = get(groot,'ScreenSize');
    figure('Position',[50 50 scrsz(3)-700 scrsz(4)-150]);


    DEP = fieldnames(DATA);
    DEP2 = cell(size(DEP));
    for n = 1:length(DEP)
        DEP2{n,1} = [DEP{n},':',num2str(DATA.(DEP{n}).YR)];
    end
    % cmap1 = colormapMat;
    % xx=round(length(cmap1)/length(DEP));
    % cmap = cmap1(1:xx:xx*length(DEP),:);
    cmap = colormap(jet(length(DEP)));
    for n=1:length(DEP)
        plot(reshape(DATA.(DEP{n}).dataCTD.Corrected.SALT_01,[],1),reshape(DATA.(DEP{n}).dataCTD.Corrected.ptemp_01,[],1),'.','color',cmap(n,:));
        hold on
    end

    if zoom==1
        XMAT = 37.6:0.02:39;
        YMAT = 11.6:0.05:14.6;
        axis1=([38.4,38.6,12.85,13.6]);
        axis(axis1);
        set(gca,'YTick',12.6:0.05:14.6)
        set(gca,'XTick',38.4:0.02:38.6)
    else
        XMAT = 35:0.01:40;
        YMAT = 8:0.1:36;
        axis1=[36.5,38.6,12.5,28];
        axis(axis1)
        set(gca,'YTick',12.5:0.5:28)
        set(gca,'XTick',36.5:0.1:38.6)
    end
    legend(DEP2,'location','best')

    [gXMAT,gYMAT] = meshgrid(XMAT,YMAT);
    gPDENS = sw_pden(gXMAT,gYMAT,0,0);
    if zoom==2
        [c,~] = contour(XMAT(find(XMAT==axis1(1)):find(XMAT==axis1(2))),YMAT(find(YMAT==axis1(3)):find(YMAT==axis1(4))),gPDENS(find(YMAT==axis1(3)):find(YMAT==axis1(4)),find(XMAT==axis1(1)):find(XMAT==axis1(2))),1015:0.5:1035,'k');
    else
        [c,~] = contour(XMAT(find(XMAT==axis1(1)):find(XMAT==axis1(2))),YMAT(find(YMAT==axis1(3)):find(YMAT==axis1(4))),gPDENS(find(YMAT==axis1(3)):find(YMAT==axis1(4)),find(XMAT==axis1(1)):find(XMAT==axis1(2))),1015:0.05:1035,'k'); 
    end
    clabel(c,'fontsize',12,'fontweight','b');


    set(gca,'fontsize',14,'fontweight','b')
    xlabel('Salinity','fontsize',14,'fontweight','b')
    ylabel('Potential Temperature (ºC)','fontsize',14,'fontweight','b')
    
    helpdlg('paused: move legend','paused: move legend')
    pause 
    
    if zoom == 1
        FN_fig2 = [FN_fig,'_ZOOM'];
    else
        FN_fig2 = [FN_fig,'_whole'];
    end
    set(gcf,'PaperPositionMode', 'auto');
    print('-dpng',[PN_fig,FN_fig2],'-r0');
end


% Create figure without axes limits to check all data looks reasonable!
scrsz = get(groot,'ScreenSize');
figure('Position',[50 50 scrsz(3)-700 scrsz(4)-150]);


cmap = colormap(jet(length(DEP)));
for n=1:length(DEP)
    plot(reshape(DATA.(DEP{n}).dataCTD.Corrected.SALT_01,[],1),reshape(DATA.(DEP{n}).dataCTD.Corrected.ptemp_01,[],1),'.','color',cmap(n,:));
    hold on
end

XMAT = 35:0.01:40;
YMAT = 8:0.1:36;
axis1=[36.5,38.6,12.5,28];
axis(axis1)
set(gca,'YTick',12.5:0.5:28)
set(gca,'XTick',36.5:0.1:38.6)
legend(DEP2,'location','best')

[gXMAT,gYMAT] = meshgrid(XMAT,YMAT);
gPDENS = sw_pden(gXMAT,gYMAT,0,0);
[c,~] = contour(XMAT(find(XMAT==axis1(1)):find(XMAT==axis1(2))),YMAT(find(YMAT==axis1(3)):find(YMAT==axis1(4))),gPDENS(find(YMAT==axis1(3)):find(YMAT==axis1(4)),find(XMAT==axis1(1)):find(XMAT==axis1(2))),1015:0.5:1035,'k');
clabel(c,'fontsize',12,'fontweight','b');


set(gca,'fontsize',14,'fontweight','b')
xlabel('Salinity','fontsize',14,'fontweight','b')
ylabel('Potential Temperature (ºC)','fontsize',14,'fontweight','b')
