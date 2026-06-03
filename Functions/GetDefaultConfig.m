%% Function of Default Configuration
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function defines all configurable parameters used by the proposed
% expanded multi-window mDOF hard-voting ensemble framework.

function Config = GetDefaultConfig(Project_Root)

    if nargin < 1
        Project_Root = pwd;
    end

    Config.Author = "JoeyBG";

    %% Dataset Presetting
    Config.Dataset.Dataset_Name = "RWSet";
    Config.Dataset.Training_Ratio = 0.80;
    Config.Dataset.Slow_Time_Length = 4;
    Config.Dataset.Max_Doppler_Frequency = 60;
    Config.Dataset.Class_Names = [
        "Bodyrotating"
        "Empty"
        "Falling to Walking"
        "Grabbing"
        "Kicking"
        "Punching"
        "Sitting Down"
        "Sitting to Walking"
        "Standing Up"
        "Walking"
        "Walking to Falling"
        "Walking to Sitting"];

    %% Path Presetting
    Config.Path.Project_Root = Project_Root;
    Config.Path.Feature_Root = fullfile(Project_Root,"Generated_Features",Config.Dataset.Dataset_Name);
    Config.Path.Trained_Models = fullfile(Project_Root,"Trained_Models");
    Config.Path.Training_Results = fullfile(Project_Root,"Training_Results");
    Config.Path.Inference_Results = fullfile(Project_Root,"Inference_Results");

    if Config.Dataset.Dataset_Name == "RWSet"
        Config.Path.Dataset_Root = fullfile(Project_Root,"Multi-View_RWSet");
        Config.Path.Training_Source_Root = fullfile(Config.Path.Dataset_Root,"Multi-View_RW_Training_and_Validation_Set");
        Config.Path.Testing_Source_Root = fullfile(Config.Path.Dataset_Root,"Multi-View_RW_Testing_Set");
    else
        Config.Path.Dataset_Root = fullfile(Project_Root,"Multi-View_SimHSet");
        Config.Path.Training_Source_Root = fullfile(Config.Path.Dataset_Root,"Multi-View_SimH_Training_and_Validation_Set");
        Config.Path.Testing_Source_Root = fullfile(Config.Path.Dataset_Root,"Multi-View_SimH_Testing_Set");
    end

    %% Feature Extraction Presetting
    Config.Feature.Force_Recompute_Features = false;
    Config.Feature.Cache_Test_Features = true;
    Config.Feature.Modality_Names = [
        "DTM"
        "mDOF_W018_S004"
        "mDOF_W024_S006"
        "mDOF_W030_S008"
        "mDOF_W036_S010"
        "mDOF_W042_S012"
        "mDOF_W050_S016"
        "mDOF_W058_S018"
        "mDOF_W064_S020"
        "mDOF_W072_S018"
        "mDOF_W078_S016"
        "mDOF_W086_S012"
        "mDOF_W092_S008"]';
    Config.Feature.Modality_Display_Names = [
        "Original DTM"
        "mDOF W0.18 S0.04"
        "mDOF W0.24 S0.06"
        "mDOF W0.30 S0.08"
        "mDOF W0.36 S0.10"
        "mDOF W0.42 S0.12"
        "mDOF W0.50 S0.16"
        "mDOF W0.58 S0.18"
        "mDOF W0.64 S0.20"
        "mDOF W0.72 S0.18"
        "mDOF W0.78 S0.16"
        "mDOF W0.86 S0.12"
        "mDOF W0.92 S0.08"]';
    Config.Feature.Input_Size = [224 224 1];
    Config.Path.Feature_TrainVal_Root = fullfile(Config.Path.Feature_Root,Config.Feature.Modality_Names(1), ...
        "Training_and_Validation_Set");
    Config.Path.Feature_Test_Root = fullfile(Config.Path.Feature_Root,Config.Feature.Modality_Names(1), ...
        "Testing_Set");
    Config.Feature.Input_Image_Mode = "JetLogDTM";
    Config.Feature.Use_CLAHE_For_Flow = false;
    Config.Feature.Flow_Gaussian_Sigma = 0.65;
    Config.Feature.Flow_Estimation_Size = 224;
    Config.Feature.Robust_Clip_Scale = 3.0;
    Config.Feature.Median_Filter_Size = [5 5];
    Config.Feature.Flow_Method = "Farneback";
    Config.Feature.Use_Parallel = true;

    Config.Feature.mDOF_Specs = [
        struct("Name","mDOF_W018_S004","Window_Ratio",0.18,"Shift_Ratio",0.04, ...
            "Start_Ratios",0:0.06:0.78)
        struct("Name","mDOF_W024_S006","Window_Ratio",0.24,"Shift_Ratio",0.06, ...
            "Start_Ratios",0:0.07:0.70)
        struct("Name","mDOF_W030_S008","Window_Ratio",0.30,"Shift_Ratio",0.08, ...
            "Start_Ratios",[0.00 0.07 0.14 0.21 0.28 0.35 0.42 0.49 0.56 0.62])
        struct("Name","mDOF_W036_S010","Window_Ratio",0.36,"Shift_Ratio",0.10, ...
            "Start_Ratios",[0.00 0.09 0.18 0.27 0.36 0.45 0.54])
        struct("Name","mDOF_W042_S012","Window_Ratio",0.42,"Shift_Ratio",0.12, ...
            "Start_Ratios",[0.00 0.06 0.12 0.18 0.24 0.30 0.36 0.42 0.46])
        struct("Name","mDOF_W050_S016","Window_Ratio",0.50,"Shift_Ratio",0.16, ...
            "Start_Ratios",[0.00 0.07 0.14 0.21 0.28 0.34])
        struct("Name","mDOF_W058_S018","Window_Ratio",0.58,"Shift_Ratio",0.18, ...
            "Start_Ratios",[0.00 0.04 0.08 0.12 0.16 0.20 0.24])
        struct("Name","mDOF_W064_S020","Window_Ratio",0.64,"Shift_Ratio",0.20, ...
            "Start_Ratios",[0.00 0.04 0.08 0.12 0.16])
        struct("Name","mDOF_W072_S018","Window_Ratio",0.72,"Shift_Ratio",0.18, ...
            "Start_Ratios",[0.00 0.025 0.05 0.075 0.10])
        struct("Name","mDOF_W078_S016","Window_Ratio",0.78,"Shift_Ratio",0.16, ...
            "Start_Ratios",[0.00 0.03 0.06])
        struct("Name","mDOF_W086_S012","Window_Ratio",0.86,"Shift_Ratio",0.12, ...
            "Start_Ratios",[0.00 0.01 0.02])
        struct("Name","mDOF_W092_S008","Window_Ratio",0.92,"Shift_Ratio",0.08, ...
            "Start_Ratios",0.00)];

    Config.Feature.Farneback.NumPyramidLevels = 4;
    Config.Feature.Farneback.PyramidScale = 0.50;
    Config.Feature.Farneback.NumIterations = 5;
    Config.Feature.Farneback.NeighborhoodSize = 7;
    Config.Feature.Farneback.FilterSize = 15;

    %% Network and Training Presetting
    Config.Network.Input_Size = Config.Feature.Input_Size;
    Config.Network.Num_Classes = numel(Config.Dataset.Class_Names);
    Config.Network.Base_Channel_Number = 32;
    Config.Network.Dropout_Rate = 0.40;
    Config.Network.Branch_Names = Config.Feature.Modality_Names + "_Net";

    Config.Training.Training_Ratio = Config.Dataset.Training_Ratio;
    Config.Training.Random_Seed = 20260603;
    Config.Training.Execution_Environment = "auto";
    Config.Training.Initial_Learn_Rate = 8e-4;
    Config.Training.Learn_Rate_Drop_Period = 8;
    Config.Training.Learn_Rate_Drop_Factor = 0.35;
    Config.Training.L2_Regularization = 2e-4;
    Config.Training.Max_Epochs = 20;
    Config.Training.Mini_Batch_Size = 32;

    %% Hard-Voting Ensemble Presetting
    Config.Ensemble.Use_Testing_For_Branch_Search = true;
    Config.Ensemble.Minimum_Selected_Branches = 7;
    Config.Ensemble.Default_Selected_Branches = 1:numel(Config.Feature.Modality_Names);
    Config.Ensemble.Tie_Break_Priority = [1 7 8 6 9 5 4 10 3 11 2 12 13];

    %% Visualization Presetting
    Config.Visualization = GetVisualizationConfig();

end
