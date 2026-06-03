%% Main Script for New DTM Inference
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This script implements one-key inference for a new Doppler-time map. The
% script extracts the DTM and multi-window horizontal mDOF maps, performs
% hard-voting ensemble recognition, and visualizes branch decisions.

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

%% Input Presetting
Input_DTM_Path = fullfile(Project_Root,"Multi-View_RWSet", ...
    "Multi-View_RW_Testing_Set","30","Walking","1.png");
Model_Package_Path = fullfile(Project_Root,"Trained_Models", ...
    "JoeyBG_MultiWindowHardVote_RWSet_Model.mat");

if ~isfile(Input_DTM_Path)
    error("Input DTM image does not exist: %s",Input_DTM_Path);
end

if ~isfile(Model_Package_Path)
    error("Model package does not exist. Please run Main_Train_Omnidirectional_TWR_HAR_mDOF_GAF.m first.");
end

%% Load Model and Predict
Model_Package = load(Model_Package_Path);

if isfield(Model_Package,"Config")
    Config = Model_Package.Config;
    addpath(fullfile(Config.Path.Project_Root,"Functions"));
    addpath(fullfile(Config.Path.Project_Root,"Visualization"));
end

Inference_Result = PredictDTM(Model_Package,Input_DTM_Path,Config);

Save_Path = fullfile(Config.Path.Inference_Results,"Inference_Result.png");
ShowInferenceResult(Inference_Result,Config,Save_Path);

disp("Inference result:");
disp("Input DTM: " + string(Input_DTM_Path));
disp("Ensemble Predicted Label: " + string(Inference_Result.Label));
disp("Hard-Voting Score: " + string(Inference_Result.Score));
disp("Branch Predicted Labels:");
disp(table(Inference_Result.Branch_Names(:),Inference_Result.Branch_Labels(:), ...
    Inference_Result.Branch_Confidence(:), ...
    'VariableNames',{'Branch','Predicted_Label','Confidence'}));
