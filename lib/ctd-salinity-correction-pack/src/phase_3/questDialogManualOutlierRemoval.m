function rmX = questDialogManualOutlierRemoval(SALdata, resid_Sal00, resid_Sal11,Fname3,PN_fig)

inputDialog = inputdlg('Enter comma-separated numbers:',...
     'Outlier Indexes', [1 50]);
rmX = str2num(inputDialog{:}); 


%Stage7a_step3(rmX,SALdata, resid_Sal00, resid_Sal11,Fname3,PN_fig);

end

