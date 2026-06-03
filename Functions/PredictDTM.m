%% Function of Single DTM Hard-Voting Ensemble Prediction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Inference_Result = PredictDTM(Model_Package,DTM_Path,Config)

    if isfield(Model_Package,"Config")
        Config = Model_Package.Config;
    end

    Feature_Result = ExtractEnsembleFeatures(DTM_Path,Config);
    Modality_Names = Config.Feature.Modality_Names;
    Class_Names = Config.Dataset.Class_Names;
    Num_Modalities = numel(Modality_Names);

    Branch_Scores = cell(1,Num_Modalities);
    Branch_Labels = categorical(strings(Num_Modalities,1),Class_Names);
    Branch_Confidence = zeros(Num_Modalities,1);

    for Modality_Index = 1:Num_Modalities
        Current_Modality = Modality_Names(Modality_Index);
        Current_Field = char(Current_Modality);
        Current_Network = Model_Package.Branch_Models.(Current_Field);
        Current_Image = im2single(Feature_Result.Modality_Images{Modality_Index});
        Current_Image = reshape(Current_Image,size(Current_Image,1),size(Current_Image,2),1);

        [Current_Label,Current_Scores] = classify(Current_Network,Current_Image, ...
            "ExecutionEnvironment",Config.Training.Execution_Environment);

        Branch_Scores{Modality_Index} = Current_Scores;
        Branch_Labels(Modality_Index) = Current_Label;
        Branch_Confidence(Modality_Index) = max(Current_Scores,[],2);
    end

    if isfield(Model_Package,"Selected_Branches")
        Selected_Branches = Model_Package.Selected_Branches;
    else
        Selected_Branches = Config.Ensemble.Default_Selected_Branches;
    end

    Voting_Result = FuseHardVoting(Branch_Scores,Selected_Branches,Class_Names,Config);
    Vote_Counts = Voting_Result.Vote_Counts(1,:);
    Vote_Ratio = Vote_Counts ./ max(1,numel(Selected_Branches));
    [Vote_Score,~] = max(Vote_Ratio,[],2);

    Inference_Result.Label = Voting_Result.Predicted_Label;
    Inference_Result.Score = Vote_Score;
    Inference_Result.Vote_Counts = Vote_Counts;
    Inference_Result.Vote_Ratio = Vote_Ratio;
    Inference_Result.Class_Names = Class_Names;
    Inference_Result.Branch_Names = Modality_Names;
    Inference_Result.Branch_Labels = Branch_Labels;
    Inference_Result.Branch_Confidence = Branch_Confidence;
    Inference_Result.Branch_Scores = Branch_Scores;
    Inference_Result.Selected_Branches = Selected_Branches;
    Inference_Result.Feature_Result = Feature_Result;
    Inference_Result.Input_Path = string(DTM_Path);

end
