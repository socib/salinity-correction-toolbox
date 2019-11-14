function CTD = Stage_14c_allDATA_halfm_corrected(deploymentName)
%
%
% loads all half metre corrected ship data into one structured array. You
% can run this each time a new campaign salinity correction to half metre
% data has been carried out - this code will update the file with the
% latest available data. May have to change this approach in the future if
% data become too large to handle easily.

global Path

Pname_out = Path.dataCorrectedMatHalfmBinAvgAll;
% Pname_out = 'SHIP/DATA/CTD/CTD_correction_files/';
Fname_out = 'SHIP_allDATA_halfm_corrected';

if exist([Pname_out,Fname_out,'.mat'],'file')==2 % this checks if there is a mat file already existing with corrected half metre ship CTD data. If yes, then it loads this file and adds to it.
    CTD = load([Pname_out,Fname_out]);
    CTD = CTD.CTD;
    FLDS = fields(CTD);
else
    FLDS = [];
end

% Pname_in = 'SHIP/DATA/CTD/CTD_correction_files/halfmetreBIN/matfiles/';
Pname_in = Path.dataCorrectedMatHalfmBinAvg;
DIR = dir([Pname_in,'*halfmetreBINs.mat']);             % lists all mat files of corrected half metre ship CTD data

% deploymentNameSplit = strsplit(deploymentName,'_');
% for i= 1:length(deploymentNameSplit)
%    deploymentNameSplit{i} = regexprep(deploymentNameSplit{i},'-', '');    
% end
for n=1:length(DIR)    
    CAMPAIGN = DIR(n).name;
    CAMPAIGN = strsplit(DIR(n).name,'_corrected_halfmetreBINs.mat');
    CAMPAIGN = CAMPAIGN{1};
    CAMPAIGN_cust = regexprep(CAMPAIGN,'-', '');
    
    if sum(strcmpi(CAMPAIGN,FLDS))==0                   % if the master structured array Fname_out is missing a campaign listed in DIR, here that campaign is loaded and added to the structured array.
        load([Pname_in, CAMPAIGN, '_corrected_halfmetreBINs.mat']);
%         CTD.([deploymentNameSplit{1}, deploymentNameSplit{2}, deploymentNameSplit{3}, deploymentNameSplit{4}]) = dataCTD;
        CTD.(CAMPAIGN_cust) = dataCTD;
        disp(CAMPAIGN)
    end
end

save([Pname_out,Fname_out],'CTD') % saves over the original file of all data
