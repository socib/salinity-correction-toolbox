% At the Balearic Islands Coastal Observing and Forecasting System (SOCIB) a semi-automatic routine
% field calibration/correction for salinity data using whitespace maximisation image analysis
% of theta/S data (adiabatic potential temperature - theta / Salinity - θ/S) has been developed.
% The application was originally created for gliders in the framework of the JERICO-Next EU project
% and is available in the Ocean Best Practices System Repository (http://dx.doi.org/10.25607/OBP-430.
% 
% A peer-reviewed paper describing the method has recently been published in Frontiers
% in Marine Science Best Practices in the Ocean Observing Research Topic:
% Allen JT, Munoz C, Gardiner J, Reeve KA, Alou-Font E andZarokanellos N (2020)
% Near-AutomaticRoutine Field Calibration/Correction of Glider Salinity Data Using Whitespace Maximization Image Analysis of Theta/S Data.
% Front. Mar. Sci. 7:398.
% doi: 10.3389/fmars.2020.00398

% Editd by Matteo Marasco and John Allen in April 2022



set_main_paths('salinity_argo');
InstrumentID = import_instrument_ids;


choice = {'Load CTD/ARGO Data', ...
          'Run Whitespace Maximization', ...
          'Export Metadata', ...
          'Write L1_corr Data'};
      
choiceFunction = {'[ArgoNcFilesList, ArgoDataFile, CtdCorrDataFile, Campaign, TESTdat, global_meta, CTD, buttonMC, depNUM_argo] = phase_1_load_data( InstrumentID)', ...
    '[ AXISlims, TESTdat] = phase_2_run_whitespace( Campaign, CTD, buttonMC, TESTdat, CtdCorrDataFile, depNUM_argo )', ...
    '[ TESTdat, fnameOutPath ] = phase_4_export_metadata_files(TESTdat, CtdCorrDataFile, ArgoDataFile, Campaign, AXISlims)', ...
    'write_L1_corr_data_files(fnameOutPath)'
    };
         
d = dialog('Position',[80 250 550 400],'Name','ARGO Floats Salinity Correction Pack');       
firstButtonY = 355;
firstButtonWidth = 350;
firstButtonX = 10;
firstBttonHeight = 40;
% txt = uicontrol('Parent',d,...
%        'Style','text',...
%        'Position',[20 80 210 40],...
%        'String','Select a color');
[x,~]=imread('LogoSocib.png');
I2=imresize(x, [102 113]);
socibLogo=uicontrol('Parent',d,...
            'units','pixels',...
            'position',[10 100 113 102],...
            'cdata',I2);
        
[x,~]=imread('gliderSocib.jpg');
I2=imresize(x, [202 140]);
ctdLogo=uicontrol('Parent',d,...
            'units','pixels',...
            'position',[380 192 140 202],...
            'cdata',I2);
        
[x,~]=imread('jericoLogo.jpg');
I2=imresize(x, [102 183]);
jericoLogo=uicontrol('Parent',d,...
            'units','pixels',...
            'position',[150 100 183 102],...
            'cdata',I2);


[~,n] = size(choice);
count = 0;
for i = 1:n
    stage(i) = uicontrol('Parent',d,...
       'Position',[firstButtonX firstButtonY - count firstButtonWidth firstBttonHeight],...
       'String',choice(i),...
       'fontSize',12, ...
       'Callback',choiceFunction{i}, ...
       'Interruptible', 'on');
    count = count + 45;
end
   
   
   
   
   