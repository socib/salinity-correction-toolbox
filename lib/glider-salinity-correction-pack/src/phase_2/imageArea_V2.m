function [area] = imageArea_V2(A,  condGlider, tempCondCellGlider, pressureGlider, ~, salinityShip, ptempShip, imageDir,AXISlims,counter)
%
% imageArea_V2: Computes the whitespace area on a figure of a TS diagram
% with data points from test glider data and background ship data.
%
%  Syntax:
%    [area] = imageArea_V2(A,  condGlider, tempCondCellGlider, pressureGlider, ptempGlider, salinityShip, ptempShip, imageDir,AXISlims,counter)
%
%
% For further information, refer to: *insert link to future document here*,
% and the corresponding readme_gliderCorrection.txt.
%
% Code Description: The conductivity correction coefficient A is applied to
% the input test conductivity (condGlider) and an adjusted salinity and
% potential temperature are derived. A TS diagram of the input background
% data and the adjusted test data is created, the png of which is converted
% into a binary image. The output data is the whitespace area of the binary
% image of the TS diagram.

%
% INPUT: 1.  A                  = correction coefficient
%        2.  condGlider          = test (glider) data conductivity
%        3.  tempCondCellGlider = test (glider) data in situ temperature;
%        4.  pressureGlider     = test (glider) pressure
%        5.  ptempGlider        = test (glider) data potential temperature
%        6.  salinityShip       = background (ship) salinity
%        7.  ptempShip          = background (ship) potential temperature
%        8.  imageDir           = path name where png of TS diagram will be saved to
%        9.  AXISlims           = axes limits for the TS diagram
%        10. counter            = filepart for the image filename
%
% OUTPUT: area = the computed whitespace area of a binary image of the TS
% diagram of the input test and background data.
%
% Author: Emma Heslop, Krissy Reeve (kreeve@socib.es)
% Date of creation: 23/06/2016.




% multiply conductivity by the correction coefficient, A:
condGliderAdj       =  A * condGlider ;

% convert the adjusted conductivity into salinity (different function option based on whether user has GSW or SW seawater package:
if exist('GSW','dir')
    salinityGliderAdj   = gsw_SP_from_C(condGliderAdj,tempCondCellGlider, pressureGlider);
    ptempGliderAdj      = sw_ptmp(salinityGliderAdj,tempCondCellGlider, pressureGlider,0);
elseif exist('seawater','dir')
    %Conductivity from sw_c3515is also in mS/cm, returns conductivity at S=35 psu , T=15 C [IPTS 68] and P=0 db).
    salinityGliderAdj   = sw_salt(condGliderAdj * (10 / sw_c3515()), tempCondCellGlider, pressureGlider);
    ptempGliderAdj      = sw_ptmp(salinityGliderAdj,tempCondCellGlider, pressureGlider,0);
else
    msgbox('NEED TO DOWNLOAD SEAWATER PACKAGE')
end

%  Create T/S diagram of test (glider) data against background (ship)
%  data:
markerSize = 10;
scrsz = get(0,'ScreenSize');
fig   = figure('Position',[50 50 scrsz(3)/2 scrsz(4)-200]);
plot(salinityGliderAdj,ptempGliderAdj,'b.','markersize', markerSize);
hold on
% grid on
% axis([AXISlims.xMin, AXISlims.xMax,AXISlims.yMin, AXISlims.yMax]);
plot(salinityShip,ptempShip,'r.','markersize', markerSize) ; 
axis([AXISlims.xMin, AXISlims.xMax,AXISlims.yMin, AXISlims.yMax]);
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
axis off
hold off
% grid on
% title(['TS ranges: ', num2str(AXISlims.xMin),' to ',num2str(AXISlims.xMax),' and ',num2str(AXISlims.yMin),' C to ',num2str(AXISlims.yMax),' C'],'fontsize',16,'fontweight','b')
% xlabel('Salinity','fontsize',14,'fontweight','b')
% ylabel('Potential Temperature (C)','fontsize',14,'fontweight','b')
% legend('Glider data (blue)','Background (ship) data (red)','location','best')
% set(gca,'fontsize',14,'fontweight','b')
% hold on
% %potential density grid for contours if plot is "zoomed in":
%     XT = [38,38.7,0.05];
%     YT = [12.8,14,0.05];
%     XMAT = 37.6:0.02:39;
%     YMAT = 11.6:0.05:14.6;
%     [gXMAT,gYMAT] = meshgrid(XMAT,YMAT);
%     gPDENS = sw_pden(gXMAT,gYMAT,0,0);
%     [c,hc] = contour(XMAT,YMAT,gPDENS,1015:0.05:1035,'k');
%     clabel(c,hc,1015:0.1:1035
           
% pause(1)
% % Save figure: 
% imageDataFilename = fullfile(imageDir, [ 'comparison_workings_',num2str(counter) ]);
% % print('-dpng',imageDataFilename);
% saveas(fig, [imageDataFilename,'.png'])
% 
% 
% % load figure as a png:
% BWAdj  = imread([imageDataFilename,'.png']);
% BWAdj = rgb2gray(BWAdj);

% conversion of figure to image

F = getframe(fig);
pause(0.25)
[BWAdj, ~] = frame2im(F);
%BWAdj = rgb2gray(BWAdj);
pause(0.25)


% saveas(fig,'/home/cmunoz/test.png')
% image='/home/cmunoz/test.png'
% I = imread(image);
% level = graythresh(I)
% BWAdj  =im2bw(I,level);

% convert figure into a binary image (i.e. only two options for the colour of pixels, black and white):
level = graythresh(BWAdj);
pause(0.25)
BWAdj  =im2bw(BWAdj,level);




close
%pause(1)
% Compute the total whitespace area in the image (i.e. the sum of nonzero pixels):

totalAdj = bwarea(BWAdj);
%totalAdj = bweuler(BWAdj, 8);
area = totalAdj;

close
clearvars -except area;
end
            
           
            