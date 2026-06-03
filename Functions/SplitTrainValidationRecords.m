%% Function of Class-Balanced Training and Validation Splitting
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function [Training_Table,Validation_Table] = SplitTrainValidationRecords(Training_Validation_Table,Config)

    Class_Names = Config.Dataset.Class_Names;
    Training_Cell = cell(numel(Class_Names),1);
    Validation_Cell = cell(numel(Class_Names),1);

    rng(Config.Training.Random_Seed,"twister");

    for Class_Index = 1:numel(Class_Names)
        Current_Class = Class_Names(Class_Index);
        Current_Table = Training_Validation_Table(Training_Validation_Table.Label == Current_Class,:);
        Num_Records = height(Current_Table);
        Random_Index = randperm(Num_Records);
        Num_Training = floor(Num_Records * Config.Training.Training_Ratio);

        Training_Cell{Class_Index} = Current_Table(Random_Index(1:Num_Training),:);
        Validation_Cell{Class_Index} = Current_Table(Random_Index(Num_Training + 1:end),:);
    end

    Training_Table = vertcat(Training_Cell{:});
    Validation_Table = vertcat(Validation_Cell{:});

end
