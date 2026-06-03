%% Function of Single-Modality Datastore Construction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Modality_imds = BuildModalityDatastore(Record_Table,Config,Modality_Name,Use_Angle_Folder)

    Feature_Paths = GetFeaturePathsFromRecords(Record_Table,Config,Modality_Name,Use_Angle_Folder);

    if any(~isfile(Feature_Paths))
        Missing_Index = find(~isfile(Feature_Paths),1,"first");
        error("Feature file does not exist: %s",Feature_Paths(Missing_Index));
    end

    Modality_imds = imageDatastore(Feature_Paths);
    Modality_imds.Labels = categorical(Record_Table.Label,Config.Dataset.Class_Names);

end
