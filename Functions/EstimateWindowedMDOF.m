%% Function of Windowed Horizontal mDOF Estimation
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function estimates one horizontal mDOF map by using the window length,
% frame interval, and start locations defined by a single branch specification.

function [Flow_Map_Raw,Flow_Map_Channel] = EstimateWindowedMDOF(DTM_Gray,Config,Window_Spec)

    Flow_Size = Config.Feature.Flow_Estimation_Size;
    DTM_Work = imresize(DTM_Gray,[Flow_Size Flow_Size],"bilinear");
    DTM_Work = NormalizeDTMIntensity(DTM_Work);
    DTM_Work = imgaussfilt(DTM_Work,Config.Feature.Flow_Gaussian_Sigma);

    Window_Width = max(16,round(Flow_Size * Window_Spec.Window_Ratio));
    Frame_Shift = max(2,round(Flow_Size * Window_Spec.Shift_Ratio));
    Start_Columns = round(1 + Window_Spec.Start_Ratios * Flow_Size);
    Start_Columns = unique(max(1,min(Flow_Size,Start_Columns)),"stable");

    Flow_Stack = zeros(Flow_Size,Flow_Size,numel(Start_Columns),"single");
    Valid_Counter = 0;

    for Start_Index = 1:numel(Start_Columns)
        Start_Column_0 = Start_Columns(Start_Index);
        Start_Column_1 = Start_Column_0 + Frame_Shift;
        End_Column_0 = Start_Column_0 + Window_Width - 1;
        End_Column_1 = Start_Column_1 + Window_Width - 1;

        if End_Column_1 > Flow_Size
            continue;
        end

        Frame_0 = DTM_Work(:,Start_Column_0:End_Column_0);
        Frame_1 = DTM_Work(:,Start_Column_1:End_Column_1);
        Frame_0 = imresize(Frame_0,[Flow_Size Flow_Size],"bilinear");
        Frame_1 = imresize(Frame_1,[Flow_Size Flow_Size],"bilinear");

        if Config.Feature.Flow_Method == "TVL1"
            [Current_U,~] = TVL1OpticalFlow(Frame_0,Frame_1);
        else
            opticFlow = opticalFlowFarneback( ...
                "NumPyramidLevels",Config.Feature.Farneback.NumPyramidLevels, ...
                "PyramidScale",Config.Feature.Farneback.PyramidScale, ...
                "NumIterations",Config.Feature.Farneback.NumIterations, ...
                "NeighborhoodSize",Config.Feature.Farneback.NeighborhoodSize, ...
                "FilterSize",Config.Feature.Farneback.FilterSize);

            estimateFlow(opticFlow,single(Frame_0));
            Flow = estimateFlow(opticFlow,single(Frame_1));
            Current_U = Flow.Vx;
        end

        Valid_Counter = Valid_Counter + 1;
        Flow_Stack(:,:,Valid_Counter) = single(Current_U);
    end

    if Valid_Counter == 0
        Flow_Map_Raw = zeros(Flow_Size,Flow_Size,"single");
    else
        Flow_Map_Raw = median(Flow_Stack(:,:,1:Valid_Counter),3);
    end

    Flow_Map_Raw = medfilt2(Flow_Map_Raw,Config.Feature.Median_Filter_Size,"symmetric");
    Flow_Map_Channel = SignedRobustNormalize(Flow_Map_Raw,Config.Feature.Robust_Clip_Scale);

end
