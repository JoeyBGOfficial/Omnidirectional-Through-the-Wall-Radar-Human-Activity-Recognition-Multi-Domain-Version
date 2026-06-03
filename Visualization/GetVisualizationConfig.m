%% Function of Visualization Configuration
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Visualization_Config = GetVisualizationConfig()

    Visualization_Config.Font_Name = 'Palatino Linotype';
    Visualization_Config.Font_Size_Basis = 15;
    Visualization_Config.Font_Size_Axis = 16;
    Visualization_Config.Font_Size_Title = 18;
    Visualization_Config.Font_Weight_Basis = 'normal';
    Visualization_Config.Font_Weight_Axis = 'normal';
    Visualization_Config.Font_Weight_Title = 'bold';
    Visualization_Config.JoeyBG_Colormap = [
        0.6196 0.0039 0.2588
        0.8353 0.2431 0.3098
        0.9569 0.4275 0.2627
        0.9922 0.6824 0.3804
        0.9961 0.8784 0.5451
        1.0000 1.0000 0.7490
        0.9020 0.9608 0.5961
        0.6706 0.8667 0.6431
        0.4000 0.7608 0.6471
        0.1961 0.5333 0.7412
        0.3686 0.3098 0.6353];
    Visualization_Config.JoeyBG_Colormap_Flip = flip(Visualization_Config.JoeyBG_Colormap);

end
