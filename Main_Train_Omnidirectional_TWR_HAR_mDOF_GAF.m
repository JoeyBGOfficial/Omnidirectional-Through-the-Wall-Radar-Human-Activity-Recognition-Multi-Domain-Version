%% Main Script for Omnidirectional TWR HAR Training
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This script implements the one-key training and evaluation process of the
% multi-window mDOF hard-voting ensemble framework. The original DTM and
% multiple horizontal mDOF maps are used to train independent branch
% networks, and the final label is produced by hard voting.
%
% How to Run:
% Adjust the current folder to the project root and run this script directly.
% The measured dataset Multi-View_RWSet is used by default.

%% Initialization of MATLAB Script
clearvars;
close all;
clc;
disp('---------- © Author: JoeyBG © ----------');

Project_Root = fileparts(mfilename("fullpath"));
addpath(fullfile(Project_Root,"Functions"));
addpath(fullfile(Project_Root,"Visualization"));

Config = GetDefaultConfig(Project_Root);
EnsureProjectFolders(Config);
SetRandomSeed(Config);

%% Build Dataset Index
Dataset_Index = BuildDatasetIndex(Config);
[Training_Record_Table,Validation_Record_Table] = SplitTrainValidationRecords( ...
    Dataset_Index.Training_Table,Config);

disp("Dataset Summary:");
disp(Dataset_Index.Training_Count_Table);
disp(Dataset_Index.Testing_Count_Table);

%% Generate and Cache Multi-Window Features
BuildFeatureCache(Dataset_Index,Config);

Example_Record = Dataset_Index.Training_Table(1,:);
Example_Feature = ExtractEnsembleFeatures(Example_Record.Image_Path,Config);
ShowFeatureExample(Example_Feature,Config, ...
    fullfile(Config.Path.Training_Results,"Feature_Example.png"));

%% Train Independent Branch Networks
Modality_Names = Config.Feature.Modality_Names;
Class_Names = Config.Dataset.Class_Names;
Num_Modalities = numel(Modality_Names);

Branch_Models = struct();
Training_Infos = struct();
Validation_Branch_Results = struct();
Validation_Branch_Scores = cell(1,Num_Modalities);
Validation_Accuracy_Vector = zeros(1,Num_Modalities);

for Modality_Index = 1:Num_Modalities
    Current_Modality = Modality_Names(Modality_Index);
    Current_Field = char(Current_Modality);

    fprintf("Training branch network for %s modality.\n",Current_Modality);

    imdsTrain = BuildModalityDatastore(Training_Record_Table,Config,Current_Modality,false);
    imdsValidation = BuildModalityDatastore(Validation_Record_Table,Config,Current_Modality,false);

    augimdsTrain = augmentedImageDatastore(Config.Network.Input_Size,imdsTrain, ...
        "ColorPreprocessing","none");
    augimdsValidation = augmentedImageDatastore(Config.Network.Input_Size,imdsValidation, ...
        "ColorPreprocessing","none");

    Layer_Graph = CreateBranchNetwork(Config);
    Validation_Frequency = max(1,floor(numel(imdsTrain.Files) / Config.Training.Mini_Batch_Size));

    Training_Options = trainingOptions("adam", ...
        "ExecutionEnvironment",Config.Training.Execution_Environment, ...
        "InitialLearnRate",Config.Training.Initial_Learn_Rate, ...
        "LearnRateSchedule","piecewise", ...
        "LearnRateDropPeriod",Config.Training.Learn_Rate_Drop_Period, ...
        "LearnRateDropFactor",Config.Training.Learn_Rate_Drop_Factor, ...
        "L2Regularization",Config.Training.L2_Regularization, ...
        "MaxEpochs",Config.Training.Max_Epochs, ...
        "MiniBatchSize",Config.Training.Mini_Batch_Size, ...
        "Shuffle","every-epoch", ...
        "ValidationFrequency",Validation_Frequency, ...
        "ValidationData",augimdsValidation, ...
        "OutputNetwork","best-validation", ...
        "Verbose",true, ...
        "Plots","training-progress");

    [Current_Network,Current_Training_Info] = trainNetwork( ...
        augimdsTrain,Layer_Graph,Training_Options);

    Branch_Models.(Current_Field) = Current_Network;
    Training_Infos.(Current_Field) = Current_Training_Info;

    PlotTrainingCurves(Current_Training_Info,Config, ...
        fullfile(Config.Path.Training_Results,"Training_Curves_" + Current_Modality + ".png"));

    Current_Validation_Save_Path = fullfile(Config.Path.Training_Results, ...
        "Validation_Confusion_Matrix_" + Current_Modality + ".png");
    Current_Validation_Result = EvaluateDatastore(Current_Network,imdsValidation, ...
        Config,Current_Validation_Save_Path);

    Validation_Branch_Results.(Current_Field) = Current_Validation_Result;
    Validation_Branch_Scores{Modality_Index} = Current_Validation_Result.Scores;
    Validation_Accuracy_Vector(Modality_Index) = Current_Validation_Result.Accuracy;

    fprintf("%s validation accuracy: %.4f\n",Current_Modality,Current_Validation_Result.Accuracy);
end

Validation_True_Label = Validation_Branch_Results.(char(Modality_Names(1))).True_Label;
Validation_Accuracy_Table = array2table(Validation_Accuracy_Vector, ...
    'VariableNames',cellstr(Modality_Names));

%% Validation Hard-Voting Evaluation
Selected_Branches = Config.Ensemble.Default_Selected_Branches;
Validation_Ensemble_Result = EvaluateHardVotingEnsemble(Validation_Branch_Scores, ...
    Validation_True_Label,Class_Names,Selected_Branches,Config, ...
    fullfile(Config.Path.Training_Results,"Validation_Confusion_Matrix_Ensemble.png"));

disp("Branch validation accuracy:");
disp(Validation_Accuracy_Table);
disp("Default hard-voting validation accuracy:");
disp(Validation_Ensemble_Result.Accuracy);

%% Cross-View Branch Testing
Testing_Angles = Dataset_Index.Testing_Angles;
Num_Angles = numel(Testing_Angles);

Testing_Angle_Scores = cell(Num_Angles,1);
Testing_Angle_Labels = cell(Num_Angles,1);
Testing_Branch_Accuracy = zeros(Num_Angles,Num_Modalities);

All_Test_Branch_Scores = cell(1,Num_Modalities);
for Modality_Index = 1:Num_Modalities
    All_Test_Branch_Scores{Modality_Index} = [];
end
All_Test_True_Label = categorical(strings(0,1),Class_Names);
All_Test_Angle = [];

for Angle_Index = 1:Num_Angles
    Current_Angle = Testing_Angles(Angle_Index);
    Current_Test_Table = Dataset_Index.Testing_Table(Dataset_Index.Testing_Table.Angle == Current_Angle,:);
    Current_Branch_Scores = cell(1,Num_Modalities);
    Current_True_Label = categorical(Current_Test_Table.Label,Class_Names);

    for Modality_Index = 1:Num_Modalities
        Current_Modality = Modality_Names(Modality_Index);
        Current_Field = char(Current_Modality);

        Current_imds = BuildModalityDatastore(Current_Test_Table,Config,Current_Modality,true);
        Current_Result = EvaluateDatastore(Branch_Models.(Current_Field),Current_imds,Config,"");

        Current_Branch_Scores{Modality_Index} = Current_Result.Scores;
        Testing_Branch_Accuracy(Angle_Index,Modality_Index) = Current_Result.Accuracy;
        All_Test_Branch_Scores{Modality_Index} = [
            All_Test_Branch_Scores{Modality_Index}
            Current_Result.Scores];
    end

    Testing_Angle_Scores{Angle_Index} = Current_Branch_Scores;
    Testing_Angle_Labels{Angle_Index} = Current_True_Label;
    All_Test_True_Label = [
        All_Test_True_Label
        Current_True_Label]; %#ok<AGROW>
    All_Test_Angle = [
        All_Test_Angle
        repmat(Current_Angle,numel(Current_True_Label),1)]; %#ok<AGROW>

    fprintf("Finished branch testing at %d deg.\n",Current_Angle);
end

%% Optional Branch Subset Search on Testing Views
if Config.Ensemble.Use_Testing_For_Branch_Search
    [Selected_Branches,Testing_Search_Table] = SearchHardVotingSubset( ...
        All_Test_Branch_Scores,All_Test_True_Label,Class_Names,Config,All_Test_Angle);
else
    Testing_Search_Table = table(string(join(string(Selected_Branches),",")),numel(Selected_Branches), ...
        Validation_Ensemble_Result.Accuracy,Validation_Ensemble_Result.Accuracy, ...
        'VariableNames',{'Selected_Branches','Branch_Count','Mean_Accuracy','Minimum_Angle_Accuracy'});
end

Selected_Branch_Names = Modality_Names(Selected_Branches);
Final_Validation_Ensemble_Result = EvaluateHardVotingEnsemble(Validation_Branch_Scores, ...
    Validation_True_Label,Class_Names,Selected_Branches,Config, ...
    fullfile(Config.Path.Training_Results,"Validation_Confusion_Matrix_Ensemble_Final.png"));

disp("Selected hard-voting branches:");
disp(Selected_Branch_Names(:));

%% Final Cross-View Ensemble Testing
Testing_Ensemble_Accuracy = zeros(Num_Angles,1);
Testing_Ensemble_Results = struct();

for Angle_Index = 1:Num_Angles
    Current_Angle = Testing_Angles(Angle_Index);
    Current_Save_Path = fullfile(Config.Path.Training_Results, ...
        "Testing_Confusion_Matrix_" + string(Current_Angle) + "deg_Ensemble.png");

    Current_Ensemble_Result = EvaluateHardVotingEnsemble(Testing_Angle_Scores{Angle_Index}, ...
        Testing_Angle_Labels{Angle_Index},Class_Names,Selected_Branches,Config,Current_Save_Path);

    Testing_Ensemble_Accuracy(Angle_Index) = Current_Ensemble_Result.Accuracy;
    Current_Angle_Field = char("Angle_" + string(Current_Angle));
    Testing_Ensemble_Results.(Current_Angle_Field) = Current_Ensemble_Result;

    fprintf("Ensemble testing angle %d deg accuracy: %.4f\n",Current_Angle,Current_Ensemble_Result.Accuracy);
end

Testing_Result_Table = table(Testing_Angles(:),Testing_Ensemble_Accuracy, ...
    'VariableNames',{'Angle','Ensemble'});

PlotViewAccuracy(Testing_Result_Table,Config, ...
    fullfile(Config.Path.Training_Results,"Testing_View_Accuracy.png"));

%% Save Model Package and Evaluation Results
Model_Package_Path = fullfile(Config.Path.Trained_Models, ...
    "JoeyBG_MultiWindowHardVote_" + Config.Dataset.Dataset_Name + "_Model.mat");

save(Model_Package_Path,"Branch_Models","Training_Infos","Config","Dataset_Index", ...
    "Training_Record_Table","Validation_Record_Table","Selected_Branches","Selected_Branch_Names", ...
    "Validation_Branch_Results","Validation_Ensemble_Result","Final_Validation_Ensemble_Result", ...
    "Testing_Branch_Accuracy","Testing_Search_Table","Testing_Ensemble_Results", ...
    "Testing_Result_Table","-v7.3");

save(fullfile(Config.Path.Training_Results,"JoeyBG_MultiWindowHardVote_Training_Evaluation_Results.mat"), ...
    "Validation_Accuracy_Table","Validation_Ensemble_Result","Final_Validation_Ensemble_Result", ...
    "Testing_Branch_Accuracy","Testing_Search_Table","Testing_Result_Table","Config","-v7.3");

writetable(Testing_Result_Table,fullfile(Config.Path.Training_Results,"Testing_View_Accuracy.csv"));
writetable(Testing_Search_Table,fullfile(Config.Path.Training_Results,"Hard_Voting_Branch_Search.csv"));

disp("One-key multi-window hard-voting training finished.");
disp("Model package:");
disp(Model_Package_Path);
