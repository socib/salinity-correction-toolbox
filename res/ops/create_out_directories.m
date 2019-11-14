function create_out_directories
% This function creates all the directories that are not already created.
% See set_paths function for further info about the directories structure.
% author: C. Munoz SOCIB 2018

global MainPath

globalPathCell = struct2cell(MainPath);
try
    for i = 1:length(globalPathCell)
        if exist(globalPathCell{i}) == 0
            mkdir(globalPathCell{i})
        end
    end
catch
    disp('An error occurred while creating directories.');
    disp('Execution will continue.');
end
    
    
    
end