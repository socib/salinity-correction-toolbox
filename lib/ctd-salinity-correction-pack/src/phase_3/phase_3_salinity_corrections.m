function [unique_sensor, rmX] = phase_3_salinity_corrections(DIR, DeploymentInfo, choice)

switch choice{1}
    case 'PHASE 3. Default Salinity Correction'
        [ctdbtl,insituSal,SALdata,Fname3,PN_fig,unique_sensor, rmX] = Stage_7a_mbtl_insitu_SAL_matchup(1, DeploymentInfo);
    case 'PHASE 3a. Manual Salinity Correction'
%         close figure 1
%         close figure 2
        [ctdbtl,insituSal,SALdata,Fname3,PN_fig,unique_sensor, rmX] = Stage_7a_mbtl_insitu_SAL_matchup(0, DeploymentInfo);
end
return
