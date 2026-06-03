%% Function of Hard-Voting Ensemble Evaluation
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Evaluation_Result = EvaluateHardVotingEnsemble(Branch_Scores,True_Label,Class_Names,Selected_Branches,Config,Save_Path)

    Voting_Result = FuseHardVoting(Branch_Scores,Selected_Branches,Class_Names,Config);
    Accuracy = mean(Voting_Result.Predicted_Label == True_Label);

    Evaluation_Result.True_Label = True_Label;
    Evaluation_Result.Predicted_Label = Voting_Result.Predicted_Label;
    Evaluation_Result.Vote_Counts = Voting_Result.Vote_Counts;
    Evaluation_Result.Branch_Predicted_Label = Voting_Result.Branch_Predicted_Label;
    Evaluation_Result.Branch_Confidence = Voting_Result.Branch_Confidence;
    Evaluation_Result.Selected_Branches = Voting_Result.Selected_Branches;
    Evaluation_Result.Accuracy = Accuracy;

    if nargin >= 6 && strlength(string(Save_Path)) > 0
        PlotConfusionMatrix(True_Label,Voting_Result.Predicted_Label,Config,Save_Path);
    end

end
