%% Function of Signed Robust Image Normalization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Normalized_Image = SignedRobustNormalize(Input_Image,Clip_Scale)

    Input_Image = double(Input_Image);
    Center_Value = median(Input_Image(:),"omitnan");
    Scale_Value = mad(Input_Image(:),1);

    if Scale_Value < eps
        Scale_Value = std(Input_Image(:),"omitnan") + eps;
    end

    Normalized_Image = (Input_Image - Center_Value) ./ (Scale_Value + eps);
    Normalized_Image = min(max(Normalized_Image,-Clip_Scale),Clip_Scale);
    Normalized_Image = (Normalized_Image + Clip_Scale) ./ (2 * Clip_Scale);
    Normalized_Image = min(max(Normalized_Image,0),1);

end
