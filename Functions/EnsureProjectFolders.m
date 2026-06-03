%% Function of Folder Initialization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function EnsureProjectFolders(Config)

    Folder_List = [
        string(Config.Path.Feature_Root)
        string(Config.Path.Trained_Models)
        string(Config.Path.Training_Results)
        string(Config.Path.Inference_Results)];

    for Modality_Index = 1:numel(Config.Feature.Modality_Names)
        Current_Modality = Config.Feature.Modality_Names(Modality_Index);
        Folder_List = [
            Folder_List
            string(fullfile(Config.Path.Feature_Root,Current_Modality,"Training_and_Validation_Set"))
            string(fullfile(Config.Path.Feature_Root,Current_Modality,"Testing_Set"))]; %#ok<AGROW>
    end

    for Folder_Index = 1:numel(Folder_List)
        if ~isfolder(Folder_List(Folder_Index))
            mkdir(Folder_List(Folder_Index));
        end
    end

end
