function [ TESTdat ] = phase_3_apply_corrections( GUESS, TESTdat, depNUM_glider, CtdCorrDataFile, CTD )
%% 4. CREATE AND SAVE MAT FILE WITH CORRECTED SALINITY AND CONDUCTIVITY, AND CORRESPONDING METADATA DETAILING THE CORRECTION COEFFICIENT, ERROR ESTIMATE, AND SUMMARY OF CORRECTION METHOD. 
%       PLOT FINAL TSdiagrams WITH UNCORRECTED AND CORRECTED GLIDER DATA
%       OVER THE TOP OF CORRECTED SHIP (BACKGROUND) DATA.

% 4.a) Correction coefficients, and corrected conductivity, salinity and
% potential temperature:

TESTdat.Corr.A  = GUESS;
TESTdat.Corr.C  = GUESS.*TESTdat.C;
TESTdat.Corr.S  = gsw_SP_from_C(TESTdat.Corr.C,TESTdat.T,TESTdat.Pr);   %sw_salt(TESTdat.Corr.C *(10 / sw_c3515()),TESTdat.T,TESTdat.Pr);%
TESTdat.Corr.PT = sw_ptmp(TESTdat.Corr.S,TESTdat.T,TESTdat.Pr,0);

% 4.b)Create TS diagrams with uncorrected and corrected glider data over the
% top of background corrected ship data:
TSdiags_from_Struct(1,1,TESTdat,depNUM_glider, CtdCorrDataFile, CTD)
%TSdiags_from_Struct(1,1,TESTdat,depNUM_glider)


% % 4.c) error estimate of corrected salinity:
% ERROR = inputdlg('Provide error estimate:','error estimate',1,{'0.01'});
% TESTdat.Corr.Error = str2double(ERROR);
% 
%     
% % 4.d) Providing information for metadata:
% TESTdat.metaCorr.A = sprintf('%.6f',TESTdat.Corr.A);
% TESTdat.metaCorr.ErrorEst = str2double(ERROR{1});
% TESTdat.metaCorr.CorrectionSummaryMethod  = 'whitespace area maximisation of a Theta-S diagram comparison, between glider data and other nearby (in time and space) cruises was employed';
% TESTdat.metaCorr.Calibration_equation = 'COND_CORR=A*COND_01';
% TESTdat.metaCorr.CorrectionSummaryREPORT  = 'For further details, refer to report...TBC';
% TESTdat.metaCorr.CorrectionSummaryGLIDERREPORT  = 'http://www.socib.es/?seccion=gliderPage&facility=gliderReports';
% RANGE = size(Campaign.DEP, 1);
% for n = 1 : RANGE
% %     x{n} = strjoin([num2str(n),')',Campaign.DEP(n),Campaign.DATE(n)]);
%     x{n} = [num2str(n),') ', CtdCorrDataFile.name{n}(1:end-3)];
% end
% TESTdat.metaCorr.CorrectionSummaryBGRNDdata  = strjoin(['Background comparison Cruises used:', x]); clear x
% TESTdat.metaCorr.CorrectionSummaryERRORestimate  = 'error estimate is based on the range of salinity values of the comparison cruises at about 13 deg C (i.e. at the tail end of the deepest values on the Theta-S diagram)';
% TESTdat.metaCorr.CorrectionSummaryWHTSPACE = ['Salinity: ',num2str(AXISlims.xMin),' to ', num2str(AXISlims.xMax), ' psu, Temperature: ',num2str(AXISlims.yMin),' to ', num2str(AXISlims.yMax), ' deg C'];

% save([MainPath.dataCorrectedMat,Campaign.Test,'_corr'],'TESTdat')
% 
% % 4.f) Create netcdf file of the meta data for corrected conductivity and
% % salinity (to go to the data centre):
% %nccreate([Pname_outMeta,Campaign.Test,'_CORR'],'name',gliderDataFilename)
% fileNameOut = [MainPath.dataCorrectionCoefficientsNc,Campaign.Test,'_corr.nc'];
% nccreate(fileNameOut,'conductivity_corr','Dimensions',{'time',inf})
% ncwrite(fileNameOut,'conductivity_corr',TESTdat.Corr.C);
% ncwriteatt(fileNameOut,'conductivity_corr','observation_type','corrected_measurements')
% 
% if isfield(data,'salinity_corrected_thermal') == 1
%     ncwriteatt(fileNameOut,'conductivity_corr','conductivity_thermal_corr_used','YES')
% else
%     ncwriteatt(fileNameOut,'conductivity_corr','conductivity_thermal_corr_used','NO, unavailable')
% end
% 
% ncwriteatt(fileNameOut,'conductivity_corr','correction_coefficient_A',TESTdat.metaCorr.A)
% ncwriteatt(fileNameOut,'conductivity_corr','calibration_equation',TESTdat.metaCorr.Calibration_equation)
% %ncwriteatt([Pname_outMeta,Campaign.Test,'_corr'],'conductivity_corr','salinity_error_estimate',TESTdat.metaCorr.ErrorEst)
% ncwriteatt(fileNameOut,'conductivity_corr','summary_method', TESTdat.metaCorr.CorrectionSummaryMethod)
% ncwriteatt(fileNameOut,'conductivity_corr','summary_method_error_estimate', TESTdat.metaCorr.CorrectionSummaryERRORestimate)
% ncwriteatt(fileNameOut,'conductivity_corr','summary_method_report', TESTdat.metaCorr.CorrectionSummaryREPORT)
% if isfield(TESTdat.metaCorr,'CorrectionSummaryGLIDERREPORT') ==1
%     ncwriteatt(fileNameOut,'conductivity_corr','glider_report', TESTdat.metaCorr.CorrectionSummaryGLIDERREPORT)
% end
% ncwriteatt(fileNameOut,'conductivity_corr','background_data_used_for_correction', TESTdat.metaCorr.CorrectionSummaryBGRNDdata)
% ncwriteatt(fileNameOut,'conductivity_corr','theta-sal_whitespace_for_correction', TESTdat.metaCorr.CorrectionSummaryWHTSPACE)
% nccreate(fileNameOut,'salinity_corr','Dimensions',{'time',inf});
% ncwrite(fileNameOut,'salinity_corr',TESTdat.Corr.S);
% ncwriteatt(fileNameOut,'salinity_corr','observation_type','corrected_derived_from_conductivity_corr')
% ncwriteatt(fileNameOut,'salinity_corr','summary_details','Refer to meta.conductivity_corr.attributes')
% ncwriteatt(fileNameOut,'salinity_corr','salinity_error_estimate',TESTdat.metaCorr.ErrorEst)
% ncwriteatt(fileNameOut,'salinity_corr','background_data_used_for_correction', TESTdat.metaCorr.CorrectionSummaryBGRNDdata)
% ncwriteatt(fileNameOut,'salinity_corr','residual_salinity_differences_std_background_data', [sprintf('%.6f',CTD_CORR.meta.SALT_01_CORR.attributes(2).value), ' given temperature and given pressure'])
% 
% nccreate(fileNameOut,'temperature_corr','Dimensions',{'time',inf});
% ncwrite(fileNameOut,'temperature_corr',TESTdat.T);
% ncwriteatt(fileNameOut,'temperature_corr','observation_type','corrected_measurements')
% ncwriteatt(fileNameOut,'temperature_corr','summary_details','At this stage, temperature_corr is the same as original temperature. This section will be updated if de-spiking is required')
% 
% ncwriteatt(fileNameOut,'/','name',char(GliderDataFile.path{1}));
% ncdisp(fileNameOut,'/');
% 
% disp(Campaign.COMP)
% disp(AXISlims)
% format long
% disp(TESTdat.Corr.A)
% disp(ERROR)
end

