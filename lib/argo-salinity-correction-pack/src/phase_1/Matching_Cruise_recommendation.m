function [Campaign,Pname_in_comp] = Matching_Cruise_recommendation(Campaign,TYPE,bgrndRegions,first10)
%
%
% Code descripion: Using input test data, which is a cruise or ARGO mission, provide a
% recomendation of other campaigns for a cross-campaign comparison in order
% to determine a T-S diagram whitespace appraoch to correction of salinity
% data.
% The options for closest cruise include the following:
% 1. If the campaign is a Ship Canales campaign, Ship canales campaigns are used for
% the comparison.
%       OPTIONS:
%           1. ALL CANALES CAMPAIGNS
%           2. ALL CANALES CAMPAIGNS OF CORRESPONDING SEASON
%           3. CANALES CRUISES DIRECTLY BEFORE AND AFTER TEST CANALES
%           CAMPAIGN
%           4. CANALES CRUISES DIRECTLY BEFORE AND AFTER TEST CANALES
%           CAMPAIGN AND CANALES OF THE SAME SEASON AS THE TEST CAMPAIGN,
%           BUT OF THE PREVIOUS YEAR (AND YEAR AFTER IF AVAILABLE)
%           5.  MANUAL SELECTION
% 2. If the campaign is a Glider Canales campaign, Ship canales campaigns are used for
% the comparison.
%       OPTIONS:
%           1. ALL CANALES SHIP CAMPAIGNS
%           2. THE CORRESPONDING SHIP CANALES CAMPAIGN
%           3. ALL CANALES SHIP CAMPAIGNS OF CORRESPONDING SEASON
%           4. CANALES SHIP CRUISES DIRECTLY BEFORE AND AFTER TEST CANALES
%               CAMPAIGN, AND CORRESPONDING SHIP CANALES CAMPAIGN
%           5. CANALES CRUISES DIRECTLY BEFORE AND AFTER TEST CANALES
%               CAMPAIGN AND CANALES OF THE SAME SEASON AS THE TEST CAMPAIGN,
%               BUT OF THE PREVIOUS YEAR (AND YEAR AFTER IF AVAILABLE) AND 
%               CORRESPONDING SHIP CANALES CAMPAIGN
%           6.  MANUAL SELECTION
% 3. if the campaign is not a Canales campaign, use the campaign keyword
% to find the corresponding ship campaign (if the input is a glider
% dataset)
% 4. If the inpuT campaign is not canales and comes from ship CTD data, then
% use position coordinates of the test campaign to find other campaigns that
% correspond to the location of the test campaign - ideally a selection of
% campaigns.

Pname_in_comp='';
if strcmpi(TYPE,'SHIP')==1
    tmpry = regexpi(Campaign.Test,'Canales');
    if isempty(tmpry{1})==0
        % if the input campaign is a ship canales campaign, we have the
        % following options for corresponding campaign recommendations:
        %       OPTIONS:
        %           1. ALL CANALES CAMPAIGNS
        %           2. ALL CANALES CAMPAIGNS OF CORRESPONDING SEASON
        %           3. CANALES CRUISES DIRECTLY BEFORE AND AFTER TEST CANALES
        %              CAMPAIGN
        %           4. CANALES CRUISES DIRECTLY BEFORE AND AFTER TEST CANALES
        %              CAMPAIGN AND CANALES OF THE SAME SEASON AS THE TEST CAMPAIGN,
        %              BUT OF THE PREVIOUS YEAR (AND YEAR AFTER IF AVAILABLE)
        %           5. MANUAL SELECTION
        [Selection,~]=listdlg('PromptString','Choose suggestions for cruise campaigns to compare to test campaign:',...
        'SelectionMode','single','ListString',{'ALL CANALES','MATCHING SEASON CANALES','CANALES DIRECTLY BEFORE AND AFTER CRUISE',...
        'CANALES DIRECTLY BEFORE AND AFTER CRUISE AND SAME SEASON A YEAR PREVIOUS/LATER','MANUAL SELECTION'});
        if Selection == 1
            % comparison campaigns: all Canales ship campaigns
            Pname_in_comp = 'SHIP\DATA\CTD\CTD_correction_files\halfmetreBIN\';
            DIR   = dir([Pname_in_comp,'*Canales*']);
            for n1=1:length(DIR)
                x = DIR(n1).name;
                x = strsplit(x,'_corrected_halfmetreBINs.mat');
                Campaign.COMP{n1,1} = x{1};
                clear x
            end
        elseif Selection == 2
            % comparison campaigns: all Canales ship campaigns of the same
            % season to input test campaign
            % 1. Which season is the input test campaign?
            [SEASON,MNTHS] = SEASON_of_Cruise(Campaign,TYPE,[]);
            % find all Canales ship campaigns of matching season:
            Pname_in_comp = 'SHIP\DATA\CTD\CTD_correction_files\halfmetreBIN\';
            DIR.D1   = dir([Pname_in_comp,'*Canales*',['*',SEASON,'*']]);
            DIR.D2   = dir([Pname_in_comp,'*Canales*',['*',MNTHS{1},'*']]);
            DIR.D3   = dir([Pname_in_comp,'*Canales*',['*',MNTHS{2},'*']]);
            DIR.D4   = dir([Pname_in_comp,'*Canales*',['*',MNTHS{3},'*']]);
            FLDS2 = fieldnames(DIR);
            counter=0;
            for n1=1:length(FLDS2)
                if ~isempty(DIR.(FLDS2{n1}))
                   x = DIR.(FLDS2{n1}).name;
                   x = strsplit(x,'_corrected_halfmetreBINs.mat');
                    if strcmpi(x{1},Campaign.Test)==0
                        counter = counter+1;
                        Campaign.COMP{counter,1} = x{1};
                    end
                end
                clear x
            end
            
        elseif Selection == 3
            % comparison campaigns: Canales ship campaigns directly before
            % and after the input test campaign
            xtest=strsplit(Campaign.Test{1},'SOCIB_Canales_');
            xtest=xtest{2};
            xtest=strsplit(xtest,'1');
            YR = 10+str2double(xtest{2});
            [SEASON,~] = SEASON_of_Cruise(Campaign,TYPE,[]);
            if strcmpi(SEASON,'Winter')==1
                findSEASONS = {'Spring','Autumn'};
                findYR = [YR,YR-1];
                findMNTHS = {'Apr','May','Jun','Oct','Nov','Dec'};
            elseif strcmpi(SEASON,'Spring')==1
                findSEASONS = {'Summer','Winter'};
                findYR = [YR,YR];
                findMNTHS = {'Jul','Aug','Sep','Jan','Feb','Mar'};
            elseif strcmpi(SEASON,'Summer')==1
                findSEASONS = {'Autumn','Spring'};
                findYR = [YR,YR];
                findMNTHS = {'Oct','Nov','Dec','Apr','May','Jun'};
            elseif strcmpi(SEASON,'Autumn')==1
                findSEASONS = {'Winter','Summer'};
                findYR = [YR+1,YR];
                findMNTHS = {'Jan','Feb','Mar','Jul','Aug','Sep'};
            end
            Pname_in_comp = 'SHIP\DATA\CTD\CTD_correction_files\halfmetreBIN\';
            DIR.D1   = dir([Pname_in_comp,'*Canales*',['*',findSEASONS{1},num2str(findYR(1)),'*']]);
            DIR.D2   = dir([Pname_in_comp,'*Canales*',['*',findSEASONS{2},num2str(findYR(2)),'*']]);
            DIR.D3   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{1},num2str(findYR(1)),'*']]);
            DIR.D4   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{2},num2str(findYR(1)),'*']]);
            DIR.D5   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{3},num2str(findYR(1)),'*']]);
            DIR.D6   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{4},num2str(findYR(2)),'*']]);
            DIR.D7   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{5},num2str(findYR(2)),'*']]);
            DIR.D8   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{6},num2str(findYR(2)),'*']]);
            FLDS2 = fieldnames(DIR);
            counter=0;
            for n1=1:length(FLDS2)
                if ~isempty(DIR.(FLDS2{n1}))
                   x = DIR.(FLDS2{n1}).name;
                   x = strsplit(x,'_corrected_halfmetreBINs.mat');
                    if strcmpi(x{1},Campaign.Test)==0
                        counter = counter+1;
                        Campaign.COMP{counter,1} = x{1};
                    end
                end
                clear x
            end
                
            
        elseif Selection == 4
            % comparison campaigns: Canales ship campaigns directly before
            % and after the input test campaign, as well as the canales
            % ship campaign of the same season a year before/after the
            % input test campaign
            xtest=strsplit(Campaign.Test{1},'SOCIB_Canales_');
            xtest=xtest{2};
            xtest=strsplit(xtest,'1');
            YR = 10+str2double(xtest{2});
            [SEASON,MNTHS] = SEASON_of_Cruise(Campaign,TYPE,[]);
            if strcmpi(SEASON,'Winter')==1
                findSEASONS = {'Spring','Autumn'};
                findYR = [YR,YR-1];
                findMNTHS = {'Apr','May','Jun','Oct','Nov','Dec'};
            elseif strcmpi(SEASON,'Spring')==1
                findSEASONS = {'Summer','Winter'};
                findYR = [YR,YR];
                findMNTHS = {'Jul','Aug','Sep','Jan','Feb','Mar'};
            elseif strcmpi(SEASON,'Summer')==1
                findSEASONS = {'Autumn','Spring'};
                findYR = [YR,YR];
                findMNTHS = {'Oct','Nov','Dec','Apr','May','Jun'};
            elseif strcmpi(SEASON,'Autumn')==1
                findSEASONS = {'Winter','Summer'};
                findYR = [YR+1,YR];
                findMNTHS = {'Jan','Feb','Mar','Jul','Aug','Sep'};
            end
             Pname_in_comp = 'SHIP\DATA\CTD\CTD_correction_files\halfmetreBIN\';
            DIR.D1   = dir([Pname_in_comp,'*Canales*',['*',findSEASONS{1},num2str(findYR(1)),'*']]);
            DIR.D2   = dir([Pname_in_comp,'*Canales*',['*',findSEASONS{2},num2str(findYR(2)),'*']]);
            DIR.D3   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{1},num2str(findYR(1)),'*']]);
            DIR.D4   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{2},num2str(findYR(1)),'*']]);
            DIR.D5   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{3},num2str(findYR(1)),'*']]);
            DIR.D6   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{4},num2str(findYR(2)),'*']]);
            DIR.D7   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{5},num2str(findYR(2)),'*']]);
            DIR.D8   = dir([Pname_in_comp,'*Canales*',['*',findMNTHS{6},num2str(findYR(2)),'*']]);
            DIR.D9   = dir([Pname_in_comp,'*Canales*',['*',SEASON,num2str(YR-1),'*']]);
            DIR.D10  = dir([Pname_in_comp,'*Canales*',['*',SEASON,num2str(YR+1),'*']]);
            DIR.D11  = dir([Pname_in_comp,'*Canales*',['*',MNTHS{1},num2str(YR-1),'*']]);
            DIR.D12  = dir([Pname_in_comp,'*Canales*',['*',MNTHS{2},num2str(YR-1),'*']]);
            DIR.D13  = dir([Pname_in_comp,'*Canales*',['*',MNTHS{3},num2str(YR-1),'*']]);
            DIR.D14  = dir([Pname_in_comp,'*Canales*',['*',MNTHS{1},num2str(YR+1),'*']]);
            DIR.D15  = dir([Pname_in_comp,'*Canales*',['*',MNTHS{2},num2str(YR+1),'*']]);
            DIR.D16  = dir([Pname_in_comp,'*Canales*',['*',MNTHS{3},num2str(YR+1),'*']]);
            FLDS2 = fieldnames(DIR);
            counter=0;
            for n1=1:length(FLDS2)
                if ~isempty(DIR.(FLDS2{n1}))
                   x = DIR.(FLDS2{n1}).name;
                   x = strsplit(x,'_corrected_halfmetreBINs.mat');
                    if strcmpi(x{1},Campaign.Test)==0
                        counter = counter+1;
                        Campaign.COMP{counter,1} = x{1};
                    end
                end
                clear x
            end
        elseif Selection==5
            % comparison campaigns: manually select campaigns:
             Pname_in_comp = 'SHIP\DATA\CTD\CTD_correction_files\halfmetreBIN\';
             FILES = uigetfile(Pname_in_comp,'MultiSelect','on');
             if iscell(FILES)==1
                 for nnn=1:length(FILES)
                     DIR.(['D',num2str(nnn)]) = dir([Pname_in_comp,FILES{nnn}]);
                 end
             elseif iscell(FILES)==0
                 DIR.(['D',num2str(1)]) = dir([Pname_in_comp,FILES]);
             end
             FLDS2 = fieldnames(DIR);
            counter=0;
            for n1=1:length(FLDS2)
                if ~isempty(DIR.(FLDS2{n1}))
                   x = DIR.(FLDS2{n1}).name;
                   x = strsplit(x,'_corrected_halfmetreBINs.mat');
                    if strcmpi(x{1},Campaign.Test)==0
                        counter = counter+1;
                        Campaign.COMP{counter,1} = x{1};
                    end
                end
                clear x
            end
        end
    else
        disp('figure out for non Canales based on location, then options for time and season')
    end
elseif strcmpi(TYPE,'GLIDER')==1
    %   Input: top 10 spatially closest background datasets 
    %       OPTIONS:
    %           1. ALL SHIP CAMPAIGNS
    %           2. THE CORRESPONDING SHIP CAMPAIGN
    %           3. ALL SHIP CAMPAIGNS OF CORRESPONDING SEASON
    %           4. SHIP CRUISES DIRECTLY BEFORE AND AFTER TEST CAMPAIGN, AND CORRESPONDING SHIP CAMPAIGN
    %           5. CRUISES DIRECTLY BEFORE AND AFTER TEST CAMPAIGN AND SHIP CAMPAIGN OF THE SAME SEASON AS THE TEST CAMPAIGN,
    %               BUT OF THE PREVIOUS YEAR (AND YEAR AFTER IF AVAILABLE) AND CORRESPONDING SHIP CAMPAIGN
    %           6. MANUAL SELECTION
    [Selection,~]=listdlg('PromptString','Choose suggestions for cruise campaigns to compare to test campaign:',...
        'SelectionMode','single','ListString',{'ALL SHIP CAMPAIGNS','CORRESPONDING SHIP CAMPAIGN','MATCHING SEASONS','SHIP CAMPAIGN DIRECTLY BEFORE AND AFTER GLIDER MISSION AND CORRESPONDING SHIP CAMPAIGN',...
        'SHIP CAMPAIGN DIRECTLY BEFORE AND AFTER GLIDER MISSION AND SAME SEASON A YEAR PREVIOUS/LATER AND CORRESPONDING SHIP CAMPAIGN','MANUAL SELECTION'});
    FLDS = fieldnames(bgrndRegions);
    first10 = first10(:,1);
        if Selection == 1
            % ALL SHIP CAMPAIGNS
            for n = 1:length(first10)
                x = FLDS{first10(n)};
                x = strsplit(x,'_corrected_halfmetreBINs');
                Campaign.COMP{n,1} = x{1};
                clear x
            end
        elseif Selection == 2
            % THE CORRESPONDING SHIP CAMPAIGN
            testDatnum = datenum(Campaign.STARTdate,'dd-mmm-yyyy');
            bgrndDatnum = nan(length(first10),1);
            for n = 1:length(first10)
                bgrndDatnum(n,1) = datenum(bgrndRegions.(FLDS{first10(n)}).STARTdate,'dd-mmm-yyyy');
            end
            iShip = abs(testDatnum-bgrndDatnum)==min(abs(testDatnum-bgrndDatnum));
            x = FLDS{first10(iShip)};
            x = strsplit(x,'_corrected_halfmetreBINs');
            Campaign.COMP{1} = x{1};
            clear x
        elseif Selection == 3
            % ALL SHIP CAMPAIGNS OF SAME SEASON:
            counter = 1;
            for n = 1:length(first10)
                if strcmpi(Campaign.testSEASON,bgrndRegions.(FLDS{first10(n)}).SEASON) == 1;
                    x = FLDS{first10(n)};
                    x = strsplit(x,'_corrected_halfmetreBINs');
                    Campaign.COMP{counter,1} = x{1};
                    clear x
                    counter = counter +1;
                end
            end
        elseif Selection == 4
            % 4. SHIP CRUISES DIRECTLY BEFORE AND AFTER TEST CAMPAIGN, AND CORRESPONDING SHIP CAMPAIGN
            testDatnum = datenum(Campaign.STARTdate,'dd-mmm-yyyy');
            bgrndDatnum = nan(length(first10),1);
            for n = 1:length(first10)
                bgrndDatnum(n,1) = datenum(bgrndRegions.(FLDS{first10(n)}).STARTdate,'dd-mmm-yyyy');
            end
            iShip = knnsearch(bgrndDatnum,testDatnum,'k',3);
            if sum(testDatnum<bgrndDatnum(iShip))==0
                itmpry = find(testDatnum<bgrndDatnum);
                itmpry2 = itmpry(abs(testDatnum-bgrndDatnum(itmpry))==min(abs(testDatnum-bgrndDatnum(itmpry))));
                iShip(abs(testDatnum-bgrndDatnum(iShip))==max(abs(testDatnum-bgrndDatnum(iShip))))=itmpry2;
                clear itmpry itmpry2
            end
            if sum(testDatnum>bgrndDatnum(iShip))==0
                itmpry = find(testDatnum>bgrndDatnum);
                itmpry2 = itmpry(abs(testDatnum-bgrndDatnum(itmpry))==min(abs(testDatnum-bgrndDatnum(itmpry))));
                iShip(abs(testDatnum-bgrndDatnum(iShip))==max(abs(testDatnum-bgrndDatnum(iShip))))=itmpry2;
                clear itmpry itmpry2
            end
            for n = 1:length(iShip)
                x = FLDS{first10(iShip(n))};
                x = strsplit(x,'_corrected_halfmetreBINs');
                Campaign.COMP{n,1} = x{1};
                clear x
            end
        elseif Selection == 5
            % 5. CRUISES DIRECTLY BEFORE AND AFTER TEST CAMPAIGN AND SHIP CAMPAIGN OF THE SAME SEASON AS THE TEST CAMPAIGN,
                % BUT OF THE PREVIOUS YEAR (AND YEAR AFTER IF AVAILABLE) AND CORRESPONDING SHIP CAMPAIGN
            testDatnum = datenum(Campaign.STARTdate,'dd-mmm-yyyy');
            bgrndDatnum = nan(length(first10),1);
            for n = 1:length(first10)
                bgrndDatnum(n,1) = datenum(bgrndRegions.(FLDS{first10(n)}).STARTdate,'dd-mmm-yyyy');
            end
            iShip = knnsearch(bgrndDatnum,testDatnum,'k',3);
            if sum(testDatnum<bgrndDatnum(iShip))==0
                itmpry = find(testDatnum<bgrndDatnum);
                itmpry2 = itmpry(abs(testDatnum-bgrndDatnum(itmpry))==min(abs(testDatnum-bgrndDatnum(itmpry))));
                iShip(abs(testDatnum-bgrndDatnum(iShip))==max(abs(testDatnum-bgrndDatnum(iShip))))=itmpry2;
                clear itmpry itmpry2
            end
            if sum(testDatnum>bgrndDatnum(iShip))==0
                itmpry = find(testDatnum>bgrndDatnum);
                itmpry2 = itmpry(abs(testDatnum-bgrndDatnum(itmpry))==min(abs(testDatnum-bgrndDatnum(itmpry))));
                iShip(abs(testDatnum-bgrndDatnum(iShip))==max(abs(testDatnum-bgrndDatnum(iShip))))=itmpry2;
                clear itmpry itmpry2
            end
            for n = 1:length(iShip)
                x = FLDS{first10(iShip(n))};
                x = strsplit(x,'_corrected_halfmetreBINs');
                Campaign.COMP{n,1} = x{1};
                clear x
            end
            %...and same season on the previous year...
            for n = 1:length(first10)
                if strcmpi(Campaign.testSEASON,bgrndRegions.(FLDS{first10(n)}).SEASON) == 1 && Campaign.testYEAR==(bgrndRegions.(FLDS{first10(n)}).YR+1);
                    x = FLDS{first10(n)};
                    x = strsplit(x,'_corrected_halfmetreBINs');
                    Campaign.COMP{length(Campaign.COMP)+1,1} = x{1};
                    clear x
                end
            end
        elseif Selection == 6
            % 6. MANUAL SELECTION
                [bgvals,~]=listdlg('PromptString','Manually select background cruise data:',...
            'SelectionMode','multiple','ListString',(FLDS(first10)));
            for n = 1:length(bgvals)   
                %Campaign.COMP{n,1} = FLDS{first10(bgvals(n))};
                x = FLDS{first10(bgvals(n))};
                x = strsplit(x,'_corrected_halfmetreBINs');
                Campaign.COMP{n,1} = x{1};
                clear x
            end
            clear bgvals ok
        end   
end