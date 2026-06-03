%% Function of Axis Style Application
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function ApplyAxisStyle(Config,Use_Image_Axis)

    if nargin < 2
        Use_Image_Axis = false;
    end

    Vis = Config.Visualization;
    set(gca,"FontName",Vis.Font_Name);
    set(gca,"FontSize",Vis.Font_Size_Basis);
    set(gca,"FontWeight",Vis.Font_Weight_Basis);
    box on;

    if Use_Image_Axis
        axis image;
        set(gca,"YDir","normal");
    end

end
