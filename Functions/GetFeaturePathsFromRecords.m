%% Function of Feature Path Construction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Feature_Paths = GetFeaturePathsFromRecords(Record_Table,Config,Modality_Name,Use_Angle_Folder)

    Num_Records = height(Record_Table);
    Feature_Paths = strings(Num_Records,1);

    for Record_Index = 1:Num_Records
        Current_Record = Record_Table(Record_Index,:);

        if Use_Angle_Folder
            Current_Folder = fullfile(Config.Path.Feature_Root,Modality_Name, ...
                "Testing_Set",string(Current_Record.Angle),Current_Record.Label);
        else
            Current_Folder = fullfile(Config.Path.Feature_Root,Modality_Name, ...
                "Training_and_Validation_Set",Current_Record.Label);
        end

        [~,File_Name,~] = fileparts(Current_Record.Image_Path);
        Feature_Paths(Record_Index) = string(fullfile(Current_Folder,File_Name + ".png"));
    end

end
