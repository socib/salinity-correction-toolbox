function TESTdat = plot_and_choose_whitespace_results(TESTdat, bgrndDAT, TSrange, AXISlims, idx_low, idx_high, dir_idx)

global PROFILE_DIR_SECTIONS

    % 3e) Plots TS diagrams of the background data and the "corrected" test
    % (glider) data as a result of the three different initial_guess values in
    % step 3d. Asks the user to decide which provides the best correction
    % coeficient:
    
    scrsz = get(0,'ScreenSize');
    figure('Position',[50 50 scrsz(3)-100 scrsz(4)-200]);
    subplot(1,3,1)
    if PROFILE_DIR_SECTIONS == 0
        plot(gsw_SP_from_C((TSrange.guess(1)*TESTdat.C(idx_low:idx_high)),TESTdat.T(idx_low:idx_high),TESTdat.Pr(idx_low:idx_high)),TESTdat.PT(idx_low:idx_high),'.r','markersize',3)
    elseif PROFILE_DIR_SECTIONS == 1
        plot(gsw_SP_from_C((TSrange.guess(1)*TESTdat.C(TESTdat.prof_dir == dir_idx)),TESTdat.T(TESTdat.prof_dir == dir_idx),TESTdat.Pr(TESTdat.prof_dir == dir_idx)),TESTdat.PT(TESTdat.prof_dir == dir_idx),'.r','markersize',3)
    end
    
    grid on; hold on; set(gca,'fontsize',14,'fontweight','b')
    plot(bgrndDAT.S,bgrndDAT.PT,'.k','markersize',3)
    axis([AXISlims.xMin,AXISlims.xMax,AXISlims.yMin,AXISlims.yMax])
    title(['Guess 1 = ',(sprintf('%0.8f',TSrange.guess(1)))],'fontsize',14,'fontweight','b')
    
    subplot(1,3,2)
    if PROFILE_DIR_SECTIONS == 0
        plot(gsw_SP_from_C((TSrange.guess(2)*TESTdat.C(idx_low:idx_high)),TESTdat.T(idx_low:idx_high),TESTdat.Pr(idx_low:idx_high)),TESTdat.PT(idx_low:idx_high),'.r','markersize',3)
    elseif PROFILE_DIR_SECTIONS == 1
        plot(gsw_SP_from_C((TSrange.guess(2)*TESTdat.C(TESTdat.prof_dir == dir_idx)),TESTdat.T(TESTdat.prof_dir == dir_idx),TESTdat.Pr(TESTdat.prof_dir == dir_idx)),TESTdat.PT(TESTdat.prof_dir == dir_idx),'.r','markersize',3)
    end
      
    grid on; hold on; set(gca,'fontsize',14,'fontweight','b')
    plot(bgrndDAT.S,bgrndDAT.PT,'.k','markersize',3)
    % axis([AXISlims.xMin,AXISlims.xMax,12.9,13.6])
    axis([AXISlims.xMin,AXISlims.xMax,AXISlims.yMin,AXISlims.yMax])
    title(['Guess 2 = ',sprintf('%0.8f',TSrange.guess(2))],'fontsize',14,'fontweight','b')
    
    subplot(1,3,3)
    if PROFILE_DIR_SECTIONS == 0
        plot(gsw_SP_from_C((TSrange.guess(3)*TESTdat.C(idx_low:idx_high)),TESTdat.T(idx_low:idx_high),TESTdat.Pr(idx_low:idx_high)),TESTdat.PT(idx_low:idx_high),'.r','markersize',3)
    elseif PROFILE_DIR_SECTIONS == 1
        plot(gsw_SP_from_C((TSrange.guess(3)*TESTdat.C(TESTdat.prof_dir == dir_idx)),TESTdat.T(TESTdat.prof_dir == dir_idx),TESTdat.Pr(TESTdat.prof_dir == dir_idx)),TESTdat.PT(TESTdat.prof_dir == dir_idx),'.r','markersize',3)
    end     
    grid on; hold on; set(gca,'fontsize',14,'fontweight','b')
    plot(bgrndDAT.S,bgrndDAT.PT,'.k','markersize',3)
    axis([AXISlims.xMin,AXISlims.xMax,AXISlims.yMin,AXISlims.yMax])
    title(['Guess 3 = ',sprintf('%0.8f',TSrange.guess(3))],'fontsize',14,'fontweight','b')
    % Choose best result:
    %input_sensor=n;
    buttonGUESS = questdlg('Which guess do we use?','Guess value to use','Guess 1','Guess 2', 'Guess 3','Guess 2');
    if strcmpi(buttonGUESS,'Guess 1')==1
        GUESS = TSrange.guess(1);
    elseif strcmpi(buttonGUESS,'Guess 2')==1
        GUESS = TSrange.guess(2);
    elseif strcmpi(buttonGUESS,'Guess 3')==1
        GUESS = TSrange.guess(3);
    end

    % 4.a) Correction coefficients, and corrected conductivity, salinity and
    % potential temperature:
    if PROFILE_DIR_SECTIONS == 0
        TESTdat.Corr.A  = [TESTdat.Corr.A GUESS];
        TESTdat.Corr.C  = [TESTdat.Corr.C; GUESS.*TESTdat.C(idx_low:idx_high)];
        TESTdat.Corr.S  = [TESTdat.Corr.S; gsw_SP_from_C(TESTdat.Corr.C(idx_low:idx_high),TESTdat.T(idx_low:idx_high),TESTdat.Pr(idx_low:idx_high))];   
        TESTdat.Corr.PT = [TESTdat.Corr.PT; sw_ptmp(TESTdat.Corr.S(idx_low:idx_high),TESTdat.T(idx_low:idx_high),TESTdat.Pr(idx_low:idx_high),0)];
    elseif PROFILE_DIR_SECTIONS == 1   
        TESTdat.Corr.A  = [TESTdat.Corr.A GUESS];
        
        new_testDat_corr_c = GUESS.*TESTdat.C(TESTdat.prof_dir == dir_idx);
        new_testDat_corr_t = TESTdat.T(TESTdat.prof_dir == dir_idx);
        new_testDat_corr_pr = TESTdat.Pr(TESTdat.prof_dir == dir_idx);
        new_testDat_corr_s = gsw_SP_from_C(new_testDat_corr_c, new_testDat_corr_t, new_testDat_corr_pr);
        new_testDat_corr_pt = sw_ptmp(new_testDat_corr_s, new_testDat_corr_t, new_testDat_corr_pr,0);
        
        TESTdat.Corr.C  = [TESTdat.Corr.C; new_testDat_corr_c];
        TESTdat.Corr.S  = [TESTdat.Corr.S; new_testDat_corr_s];   
        TESTdat.Corr.PT = [TESTdat.Corr.PT; new_testDat_corr_pt];
    end