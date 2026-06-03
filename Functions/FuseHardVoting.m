%% Function of Hard-Voting Ensemble Fusion
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function fuses independent branch decisions by hard voting. Branch
% confidence is only used to break tied voting results.

function Voting_Result = FuseHardVoting(Branch_Scores,Selected_Branches,Class_Names,Config)

    if nargin < 2 || isempty(Selected_Branches)
        Selected_Branches = Config.Ensemble.Default_Selected_Branches;
    end

    Class_Names = string(Class_Names(:));
    Num_Classes = numel(Class_Names);
    Num_Branches = numel(Branch_Scores);
    Num_Samples = size(Branch_Scores{1},1);

    Selected_Branches = Selected_Branches(:)';
    Selected_Branches = Selected_Branches(Selected_Branches >= 1 & Selected_Branches <= Num_Branches);

    Branch_Predicted_Index = zeros(Num_Samples,Num_Branches);
    Branch_Confidence = zeros(Num_Samples,Num_Branches);

    for Branch_Index = 1:Num_Branches
        [Branch_Confidence(:,Branch_Index),Branch_Predicted_Index(:,Branch_Index)] = ...
            max(Branch_Scores{Branch_Index},[],2);
    end

    Predicted_Index = zeros(Num_Samples,1);
    Vote_Counts = zeros(Num_Samples,Num_Classes);

    for Sample_Index = 1:Num_Samples
        Current_Votes = zeros(1,Num_Classes);

        for Branch_Index = Selected_Branches
            Current_Class_Index = Branch_Predicted_Index(Sample_Index,Branch_Index);
            Current_Votes(Current_Class_Index) = Current_Votes(Current_Class_Index) + 1;
        end

        Vote_Counts(Sample_Index,:) = Current_Votes;
        Candidate_Index = find(Current_Votes == max(Current_Votes));

        if numel(Candidate_Index) > 1
            Candidate_Index = BreakTieByConfidence(Branch_Scores,Sample_Index, ...
                Candidate_Index,Selected_Branches,Config);
        end

        Predicted_Index(Sample_Index) = Candidate_Index(1);
    end

    Predicted_Label = categorical(Class_Names(Predicted_Index),Class_Names);
    Branch_Predicted_Label = categorical(Class_Names(Branch_Predicted_Index),Class_Names);

    Voting_Result.Predicted_Label = Predicted_Label;
    Voting_Result.Vote_Counts = Vote_Counts;
    Voting_Result.Branch_Predicted_Label = Branch_Predicted_Label;
    Voting_Result.Branch_Confidence = Branch_Confidence;
    Voting_Result.Selected_Branches = Selected_Branches;
    Voting_Result.Class_Names = Class_Names;

end

function Candidate_Index = BreakTieByConfidence(Branch_Scores,Sample_Index,Candidate_Index,Selected_Branches,Config)

    Confidence_Sum = zeros(1,numel(Candidate_Index));

    for Candidate_Counter = 1:numel(Candidate_Index)
        Current_Class_Index = Candidate_Index(Candidate_Counter);
        for Branch_Index = Selected_Branches
            Confidence_Sum(Candidate_Counter) = Confidence_Sum(Candidate_Counter) + ...
                Branch_Scores{Branch_Index}(Sample_Index,Current_Class_Index);
        end
    end

    Best_Confidence = max(Confidence_Sum);
    Candidate_Index = Candidate_Index(Confidence_Sum == Best_Confidence);

    if numel(Candidate_Index) <= 1
        return;
    end

    Priority_List = Config.Ensemble.Tie_Break_Priority;
    for Priority_Index = 1:numel(Priority_List)
        Current_Branch = Priority_List(Priority_Index);
        if ~ismember(Current_Branch,Selected_Branches)
            continue;
        end

        [~,Current_Class_Index] = max(Branch_Scores{Current_Branch}(Sample_Index,:),[],2);
        if ismember(Current_Class_Index,Candidate_Index)
            Candidate_Index = Current_Class_Index;
            return;
        end
    end

    Candidate_Index = Candidate_Index(1);

end
