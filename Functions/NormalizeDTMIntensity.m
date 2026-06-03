%% Function of DTM Intensity Normalization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function only maps the stored DTM intensity into [0,1]. No logarithmic
% transform and no histogram equalization are applied here.

function Normalized_Image = NormalizeDTMIntensity(Input_Image)

    Input_Image = double(Input_Image);
    Input_Image(~isfinite(Input_Image)) = 0;

    Low_Value = min(Input_Image(:));
    High_Value = max(Input_Image(:));

    if High_Value <= Low_Value
        Normalized_Image = zeros(size(Input_Image));
    else
        Normalized_Image = (Input_Image - Low_Value) ./ (High_Value - Low_Value);
        Normalized_Image = min(max(Normalized_Image,0),1);
    end

end
