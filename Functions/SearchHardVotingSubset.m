%% Function of Hard-Voting Branch Subset Search
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function searches branch subsets for hard voting. The primary metric
% is the minimum cross-view accuracy when angle labels are available.

function [Selected_Branches,Search_Table] = SearchHardVotingSubset(Branch_Scores,True_Label,Class_Names,Config,Angle_Vector)

    if nargin < 5
        Angle_Vector = [];
    end

    Num_Branches = numel(Branch_Scores);
    Minimum_Branches = Config.Ensemble.Minimum_Selected_Branches;
    Candidate_Cell = {};

    for Branch_Count = Minimum_Branches:Num_Branches
        Current_Combinations = nchoosek(1:Num_Branches,Branch_Count);
        for Combination_Index = 1:size(Current_Combinations,1)
            Candidate_Cell{end + 1,1} = Current_Combinations(Combination_Index,:); %#ok<AGROW>
        end
    end

    Num_Candidates = numel(Candidate_Cell);
    Branch_Count_Vector = zeros(Num_Candidates,1);
    Branch_String_Vector = strings(Num_Candidates,1);
    Mean_Accuracy = zeros(Num_Candidates,1);
    Minimum_Angle_Accuracy = zeros(Num_Candidates,1);

    Best_Index = 1;
    Best_Primary = -inf;
    Best_Secondary = -inf;

    for Candidate_Index = 1:Num_Candidates
        Current_Branches = Candidate_Cell{Candidate_Index};
        Current_Result = EvaluateHardVotingEnsemble(Branch_Scores,True_Label, ...
            Class_Names,Current_Branches,Config,"");

        Branch_Count_Vector(Candidate_Index) = numel(Current_Branches);
        Branch_String_Vector(Candidate_Index) = join(string(Current_Branches),",");
        Mean_Accuracy(Candidate_Index) = Current_Result.Accuracy;

        if isempty(Angle_Vector)
            Current_Minimum = Current_Result.Accuracy;
        else
            Current_Minimum = ComputeMinimumAngleAccuracy( ...
                Current_Result.Predicted_Label,True_Label,Angle_Vector);
        end
        Minimum_Angle_Accuracy(Candidate_Index) = Current_Minimum;

        if Current_Minimum > Best_Primary || ...
                (Current_Minimum == Best_Primary && Current_Result.Accuracy > Best_Secondary)
            Best_Index = Candidate_Index;
            Best_Primary = Current_Minimum;
            Best_Secondary = Current_Result.Accuracy;
        end
    end

    Selected_Branches = Candidate_Cell{Best_Index};
    Search_Table = table(Branch_String_Vector,Branch_Count_Vector, ...
        Mean_Accuracy,Minimum_Angle_Accuracy, ...
        'VariableNames',{'Selected_Branches','Branch_Count','Mean_Accuracy','Minimum_Angle_Accuracy'});

end

function Minimum_Accuracy = ComputeMinimumAngleAccuracy(Predicted_Label,True_Label,Angle_Vector)

    Angle_List = unique(Angle_Vector);
    Accuracy_Vector = zeros(numel(Angle_List),1);

    for Angle_Index = 1:numel(Angle_List)
        Current_Mask = Angle_Vector == Angle_List(Angle_Index);
        Accuracy_Vector(Angle_Index) = mean(Predicted_Label(Current_Mask) == True_Label(Current_Mask));
    end

    Minimum_Accuracy = min(Accuracy_Vector);

end
