function [ TESTdat ] = phase_3_apply_corrections( GUESS, TESTdat, depNUM_ARGO, CtdCorrDataFile, CTD )
%% 4. CREATE AND SAVE MAT FILE WITH CORRECTED SALINITY AND CONDUCTIVITY, AND CORRESPONDING METADATA DETAILING THE CORRECTION COEFFICIENT, ERROR ESTIMATE, AND SUMMARY OF CORRECTION METHOD. 
%       PLOT FINAL TSdiagrams WITH UNCORRECTED AND CORRECTED ARGO DATA
%       OVER THE TOP OF CORRECTED SHIP (BACKGROUND) DATA.

% 4.a) Correction coefficients, and corrected conductivity, salinity and
% potential temperature:

TESTdat.Corr.A  = GUESS;
TESTdat.Corr.C  = GUESS.*TESTdat.C;
TESTdat.Corr.S  = gsw_SP_from_C(TESTdat.Corr.C,TESTdat.T,TESTdat.Pr);   %sw_salt(TESTdat.Corr.C *(10 / sw_c3515()),TESTdat.T,TESTdat.Pr);%
TESTdat.Corr.PT = sw_ptmp(TESTdat.Corr.S,TESTdat.T,TESTdat.Pr,0);

% 4.b)Create TS diagrams with uncorrected and corrected ARGO data over the
% top of background corrected ship data:
TSdiags_from_Struct(1,1,TESTdat,depNUM_ARGO, CtdCorrDataFile, CTD)
%TSdiags_from_Struct(1,1,TESTdat,depNUM_ARGO)

end

