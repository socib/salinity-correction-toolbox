function [ AXISlims, TESTdat] = phase_2_run_whitespace( Campaign, CTD, buttonMC, TESTdat, CtdCorrDataFile, depNUM_ARGO)
%  Allen JT, Munoz C, Gardiner J, Reeve KA, Alou-Font E andZarokanellos N (2020)
%  Near-AutomaticRoutine Field Calibration/Correction of Glider Salinity Data Using Whitespace Maximization Image Analysis of Theta/S Data.
%  Front. Mar. Sci. 7:398.
%  doi: 10.3389/fmars.2020.00398

% WHITESPACE MAXIMISATION METHOD FOR CORRECTING ARGO DATA: 
%       create vectors of background data using the chosen data from the previous step: an iterative process tests correction coefficients that allow the test (ARGO)
%       data to align with the background data in a TS diagram - the iterative procedure stops at the point at which the whitespace area of the TSdiagram is maximised. 

global MainPath
global WHITESPACE_SECTIONS
global PROFILE_DIR_SECTIONS

% delete(d) %in ARGO toolbox
% 3a) backgrnd comparison data for the whitespace maximisation correction method; combine and rearrange into a structure of vectors:
counter=1;
RANGE = size(Campaign.COMP,1);

for n1 = 1 : RANGE
    if RANGE == 1
        XX = Campaign.COMP;
        %XX = XX{1};
    else
        XX = Campaign.COMP{n1};
    end
    if isfield(CTD.Corrected,'SALT_01')==1 && isfield(CTD.Corrected,'SALT_02')==1
        ii=1:length(CTD.latitude);%find(CTD.(XX).longitude>2); %for Mallorca Channel only! 
        tmpry.S       = [reshape(CTD.Corrected.SALT_01(:,ii),[],1);reshape(CTD.Corrected.SALT_02(:,ii),[],1)];
        tmpry.T       = [reshape(CTD.temp_01(:,ii),[],1);reshape(CTD.temp_02(:,ii),[],1)];
        tmpry.PT      = [reshape(CTD.Corrected.ptemp_01(:,ii),[],1);reshape(CTD.Corrected.ptemp_02(:,ii),[],1)];
        tmpry.C       = [reshape(CTD.Corrected.COND_01(:,ii),[],1);reshape(CTD.Corrected.COND_02(:,ii),[],1)];
        tmpry.Pr      = [reshape(CTD.pressure(:,ii),[],1);reshape(CTD.pressure(:,ii),[],1)];
        tmpry.Lat     = [reshape(repmat(CTD.latitude(ii),size(CTD.pressure(:,ii),1),1),[],1);reshape(repmat(CTD.latitude(ii),size(CTD.pressure(:,ii),1),1),[],1)];
        tmpry.Lon     = [reshape(repmat(CTD.longitude(ii),size(CTD.pressure(:,ii),1),1),[],1);reshape(repmat(CTD.longitude(ii),size(CTD.pressure(:,ii),1),1),[],1)];
        bgrndDAT.S(counter:(counter-1+length(tmpry.S)),1)       = tmpry.S;
        bgrndDAT.T(counter:(counter-1+length(tmpry.T)),1)       = tmpry.T;
        bgrndDAT.PT(counter:(counter-1+length(tmpry.T)),1)      = tmpry.PT;
        bgrndDAT.C(counter:(counter-1+length(tmpry.T)),1)       = tmpry.C;
        bgrndDAT.Pr(counter:(counter-1+length(tmpry.T)),1)      = tmpry.Pr;
%         bgrndDAT.timeUTC(counter:(counter-1+length(tmpry.T)),1) = tmpry.timeUTC;
%         bgrndDAT.Station(counter:(counter-1+length(tmpry.T)),1) = tmpry.Station;
        bgrndDAT.Lat(counter:(counter-1+length(tmpry.T)),1)     = tmpry.Lat;
        bgrndDAT.Lon(counter:(counter-1+length(tmpry.T)),1)     = tmpry.Lon;
        counter=counter+length(tmpry.S)+1;
    elseif isfield(CTD.Corrected,'SALT_01') == 1 && isfield(CTD.Corrected,'SALT_02') == 0
        ii=1:length(CTD.latitude); 
        tmpry.S       = reshape(CTD.Corrected.SALT_01(:,ii),[],1);
        tmpry.T       = reshape(CTD.temp_01(:,ii),[],1);
        tmpry.PT      = reshape(CTD.Corrected.ptemp_01(:,ii),[],1);
        tmpry.C       = reshape(CTD.Corrected.COND_01(:,ii),[],1);
        tmpry.Pr      = reshape(CTD.pressure(:,ii),[],1);
        tmpry.Lat     = reshape(repmat(CTD.latitude(ii),size(CTD.pressure(:,ii),1),1),[],1);
        tmpry.Lon     = reshape(repmat(CTD.longitude(ii),size(CTD.pressure(:,ii),1),1),[],1);
        bgrndDAT.S(counter:(counter-1+length(tmpry.S)),1)       = tmpry.S;
        bgrndDAT.T(counter:(counter-1+length(tmpry.T)),1)       = tmpry.T;
        bgrndDAT.PT(counter:(counter-1+length(tmpry.T)),1)      = tmpry.PT;
        bgrndDAT.C(counter:(counter-1+length(tmpry.T)),1)       = tmpry.C;
        bgrndDAT.Pr(counter:(counter-1+length(tmpry.T)),1)      = tmpry.Pr;
%         bgrndDAT.timeUTC(counter:(counter-1+length(tmpry.T)),1) = tmpry.timeUTC;
%         bgrndDAT.Station(counter:(counter-1+length(tmpry.T)),1) = tmpry.Station;
        bgrndDAT.Lat(counter:(counter-1+length(tmpry.T)),1)     = tmpry.Lat;
        bgrndDAT.Lon(counter:(counter-1+length(tmpry.T)),1)     = tmpry.Lon;
        counter=counter+length(tmpry.S)+1;        
    end
    clear XX ii tmpry
end
% if we remove data from the Mallorca Channel:
if strcmpi(buttonMC,'YES')==1
    % replace data with nans for ship data:
    r = find(bgrndDAT.Lon>1.5);
    flds = fieldnames(bgrndDAT);
    for n=1:length(flds)
        if iscell(bgrndDAT.(flds{n}))==0
            bgrndDAT.(flds{n})(r) = nan;
        end
    end
    clear r 
    %replace data with nans for ARGO data:
    r = find(TESTdat.Lon>1.5);
    flds = fieldnames(TESTdat);
    for n=1:length(flds)
        if iscell(TESTdat.(flds{n}))==0
            TESTdat.(flds{n})(r) = nan;
        end
    end
    clear r   
end
% remove nans:
r = isnan(bgrndDAT.S)==1 | isnan(bgrndDAT.T)==1 |...
    isnan(bgrndDAT.PT)==1 | isnan(bgrndDAT.C)==1 |...
    isnan(bgrndDAT.Pr)==1 | bgrndDAT.C==0;
FLDbgnd = fieldnames(bgrndDAT);
for n1 = 1:length(FLDbgnd)
    bgrndDAT.(FLDbgnd{n1})(r) = [];
end
clear r tmpry

% 3b) CREATE TS DIAG OF DATA TO JUDGE IF BACKGROUND DATA IS SENSIBLE, AND
% WHAT AXES LIMITS TO USE FOR WHITESPACE CORRECTION:
disp(Campaign.COMP)
%tmpry = strjoin(Campaign.COMP.');
tmpry = Campaign.COMP;
msgbox(['Select the following background data cruise for TS diagram: displayed in the Command Window (Campaign.COMP): ',tmpry])
clear tmpry

% 3c) Choose axis limits of the TSdiagram for the whitespace maximisation method:
AXISlims.xMin = 38.48;
AXISlims.xMax = 38.6;
AXISlims.yMin = 12.8;
AXISlims.yMax = 13.8;%28:-2:14;
disp(AXISlims)
buttonAXIS = questdlg('Do you wish to alter the default axis limits for the whitespace correction?','Axis limits','YES','NO','NO');
if strcmpi(buttonAXIS,'YES')==1
    prompt = {'Adjust temperature min?','Adjust temperature max?','Adjust salinity min?','Adjust salinity max?'};
    dlg_title = 'Data range for iteration';
    num_lines = 1;
    defaultans = {num2str(AXISlims.yMin),num2str(AXISlims.yMax),num2str(AXISlims.xMin),num2str(AXISlims.xMax)};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    %LIMIT BY RANGES:
    AXISlims.yMin = str2double(answer{1});
    AXISlims.yMax = str2double(answer{2});
    AXISlims.xMin = str2double(answer{3});
    AXISlims.xMax = str2double(answer{4});
end

% 3d) now for the whitespace correction: find correction by calculating whitespace area in a figure, and finding the maximum 
%     whitespace area through shifting the test campaign data to the left/right, i.e. when the curves are most coincident 
%     The std of the results provides a basic error estimate.

%init_guess  = [0.9999,1,1.0001]; % initial guess of correction coeff, so starts at 1 as in  condARGOAdj =  A * condARGO from which we make out steps to find the solution;
init_guess  = [1.0001,1.0002,1.0003];

step_major  = 0.0001; % initial solution search step
step_minor  = 0.00001; % second solution search step and level of accuracy (could increase this with more steps)
max_iterations  = 100; % nominal number of steps if more than this we have a problem
step_miniscule = 0.000001;  % third solution search step and level of accuracy (could increase this with more steps)

% if exist([FigsPname_out,Campaign.Test,'_V1/WHITESPACE'],'dir') ~= 7
%     mkdir([FigsPname_out ,Campaign.Test,'_V1/WHITESPACE'])
% end
% imageDir = [FigsPname_out,Campaign.Test,'_V1/WHITESPACE/'];
if exist(MainPath.deploymentFigsTSdiagsCorrectedReference,'dir') ~= 7
    mkdir(MainPath.deploymentFigsTSdiagsCorrectedReference)
end
imageDir = MainPath.deploymentFigsTSdiagsCorrectedReference;

% calls function optim3steps for the whitespace maximisation correction
% method
disp(['initial guess for A is: ', num2str(init_guess)])
disp(['A', ' Area', ' Difference'])

TESTdat.Corr.A = [];
TESTdat.Corr.C = [];
TESTdat.Corr.S = [];
TESTdat.Corr.PT = [];

if WHITESPACE_SECTIONS == 0

%     for n=1:length(init_guess)
%         %disp(['INITIAL GUESS = ', sprintf('%1.6f',init_guess(n))])
%         [TSrange.guess(n), TSrange.value(n), TSrange.iterations(n)] = optim3steps_john(@imageArea_V2, init_guess(n), step_major, step_minor, step_miniscule, max_iterations,...
%             TESTdat.C, TESTdat.T, TESTdat.Pr, TESTdat.PT, bgrndDAT.S, bgrndDAT.PT, imageDir,AXISlims,n);
%         disp(['FINAL GRADIENT = ',sprintf('%1.6f',(TSrange.guess(n)))]) 
%     end
    for n=1:length(init_guess)
        %disp(['INITIAL GUESS = ', sprintf('%1.6f',init_guess(n))])
        [TSrange.guess(n), TSrange.value(n), TSrange.iterations(n)] = optim3steps(init_guess(n), step_major, step_minor, step_miniscule, max_iterations,...
            TESTdat.C, TESTdat.T, TESTdat.Pr, TESTdat.PT, bgrndDAT.S, bgrndDAT.PT, imageDir,AXISlims,n);
        disp(['FINAL GRADIENT = ',sprintf('%1.6f',(TSrange.guess(n)))]) 
    end

    idx_low = 1;
    idx_high = length(TESTdat.C);
    dir_idx = 999; % this number is not used in this case
    TESTdat = plot_and_choose_whitespace_results(TESTdat, bgrndDAT, TSrange, AXISlims, idx_low, idx_high, dir_idx);
    
elseif WHITESPACE_SECTIONS == 1
    
    if PROFILE_DIR_SECTIONS == 0
        % import indices of sections to be processed
        %idxToProcess = ARGO_load_sections_idx();

%         for k = 1:length(idxToProcess)-1
%             idx_low = idxToProcess(k);
%             idx_high = idxToProcess(k+1)-1;

    %         for n=1:length(init_guess)
    %             %disp(['INITIAL GUESS = ', sprintf('%1.6f',init_guess(n))])
    %             [TSrange.guess(n), TSrange.value(n), TSrange.iterations(n)] = optim3steps_john(@imageArea_V2, init_guess(n), step_major, step_minor, step_miniscule, max_iterations,...
    %                 TESTdat.C(idx_low:idx_high), TESTdat.T(idx_low:idx_high), TESTdat.Pr(idx_low:idx_high), TESTdat.PT(idx_low:idx_high), bgrndDAT.S, bgrndDAT.PT, imageDir,AXISlims,n);
    %             disp(['FINAL GRADIENT = ',sprintf('%1.6f',(TSrange.guess(n)))]) 
    %         end   
            for n=1:length(init_guess)
                %disp(['INITIAL GUESS = ', sprintf('%1.6f',init_guess(n))])
                [TSrange.guess(n), TSrange.value(n), TSrange.iterations(n)] = optim3steps(init_guess(n), step_major, step_minor, step_miniscule, max_iterations,...
                    TESTdat.C(idx_low:idx_high), TESTdat.T(idx_low:idx_high), TESTdat.Pr(idx_low:idx_high), TESTdat.PT(idx_low:idx_high), bgrndDAT.S, bgrndDAT.PT, imageDir,AXISlims,n);
                disp(['FINAL GRADIENT = ',sprintf('%1.6f',(TSrange.guess(n)))]) 
            end   
            dir_idx = 999; % this number is not used in this case
            TESTdat = plot_and_choose_whitespace_results(TESTdat, bgrndDAT, TSrange, AXISlims, idx_low, idx_high, dir_idx);
%         end
        
    elseif PROFILE_DIR_SECTIONS == 1     
        for k = 1:3 % perform whitespace depending on downcast, upcast or neutral direction
            if k == 1
                dir_idx = 1;
            elseif k == 2
                dir_idx = -1; 
            elseif k == 3
                dir_idx = 0;  
            end
            for n=1:length(init_guess)
                %disp(['INITIAL GUESS = ', sprintf('%1.6f',init_guess(n))])
                [TSrange.guess(n), TSrange.value(n), TSrange.iterations(n)] = optim3steps(init_guess(n), step_major, step_minor, step_miniscule, max_iterations,...
                    TESTdat.C(TESTdat.prof_dir == dir_idx), TESTdat.T(TESTdat.prof_dir == dir_idx), TESTdat.Pr(TESTdat.prof_dir == dir_idx), TESTdat.PT(TESTdat.prof_dir == dir_idx), bgrndDAT.S, bgrndDAT.PT, imageDir,AXISlims,n);
                disp(['FINAL GRADIENT = ',sprintf('%1.6f',(TSrange.guess(n)))]) 
            end   
            idx_low = 999;
            idx_high = 999;
            TESTdat = plot_and_choose_whitespace_results(TESTdat, bgrndDAT, TSrange, AXISlims, idx_low, idx_high, dir_idx);
        end        
    end
end

% 4.b)Create TS diagrams with uncorrected and corrected ARGO data over the
% top of background corrected ship data:
TSdiags_from_Struct(1,1,TESTdat,depNUM_ARGO, CtdCorrDataFile, CTD)
    
argo_salinity_correction_main
end

