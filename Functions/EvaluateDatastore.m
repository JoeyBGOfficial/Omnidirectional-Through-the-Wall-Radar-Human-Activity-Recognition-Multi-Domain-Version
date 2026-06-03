%% Function of Datastore Evaluation
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Evaluation_Result = EvaluateDatastore(Trained_Network,Input_imds,Config,Save_Path)

    augimds = augmentedImageDatastore(Config.Network.Input_Size,Input_imds, ...
        "ColorPreprocessing","none");
    [Predicted_Label,Scores] = classify(Trained_Network,augimds, ...
        "ExecutionEnvironment",Config.Training.Execution_Environment);

    True_Label = Input_imds.Labels;
    Accuracy = mean(Predicted_Label == True_Label);

    Evaluation_Result.True_Label = True_Label;
    Evaluation_Result.Predicted_Label = Predicted_Label;
    Evaluation_Result.Scores = Scores;
    Evaluation_Result.Accuracy = Accuracy;

    if nargin >= 4 && strlength(string(Save_Path)) > 0
        PlotConfusionMatrix(True_Label,Predicted_Label,Config,Save_Path);
    end

end
