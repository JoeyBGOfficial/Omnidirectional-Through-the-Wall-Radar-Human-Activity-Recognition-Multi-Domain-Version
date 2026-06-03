%% Function of Multi-Window Ensemble Feature Extraction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function extracts the original DTM channel and a group of
% multi-window horizontal mDOF maps from a single Doppler-time map.

function Feature_Result = ExtractEnsembleFeatures(DTM_Path,Config)

    if ~isfile(DTM_Path)
        error("Input DTM image does not exist: %s",DTM_Path);
    end

    DTM_RGB = imread(DTM_Path);
    DTM_Gray = ToGrayDouble(DTM_RGB,Config);
    DTM_Gray = NormalizeDTMIntensity(DTM_Gray);
    DTM_Channel = imresize(DTM_Gray,Config.Feature.Input_Size(1:2),"bilinear");

    Modality_Names = Config.Feature.Modality_Names;
    Num_Modalities = numel(Modality_Names);
    Modality_Images = cell(Num_Modalities,1);
    Modality_Images{1} = DTM_Channel;

    mDOF_Channels = cell(numel(Config.Feature.mDOF_Specs),1);
    mDOF_Raw_Maps = cell(numel(Config.Feature.mDOF_Specs),1);

    for Spec_Index = 1:numel(Config.Feature.mDOF_Specs)
        Current_Spec = Config.Feature.mDOF_Specs(Spec_Index);
        [Current_Raw_Map,Current_Channel] = EstimateWindowedMDOF(DTM_Gray,Config,Current_Spec);
        Current_Channel = imresize(Current_Channel,Config.Feature.Input_Size(1:2),"bilinear");

        mDOF_Raw_Maps{Spec_Index} = Current_Raw_Map;
        mDOF_Channels{Spec_Index} = Current_Channel;
        Modality_Images{Spec_Index + 1} = Current_Channel;
    end

    Feature_Result.DTM_Channel = DTM_Channel;
    Feature_Result.mDOF_Channels = mDOF_Channels;
    Feature_Result.mDOF_Raw_Maps = mDOF_Raw_Maps;
    Feature_Result.Modality_Names = Modality_Names;
    Feature_Result.Modality_Images = Modality_Images;
    Feature_Result.Source_Path = string(DTM_Path);

end
