%% Function of Multi-Window Feature Example Visualization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function ShowFeatureExample(Feature_Result,Config,Save_Path)

    Vis = Config.Visualization;
    Num_Modalities = numel(Config.Feature.Modality_Names);
    Tile_Columns = 4;
    Tile_Rows = ceil(Num_Modalities / Tile_Columns);
    Figure_Handle = figure("Name","JoeyBG Multi-Window Feature Example","Color","w");
    set(Figure_Handle,"Position",[60 60 1500 min(980,260 * Tile_Rows)]);

    tiledlayout(Tile_Rows,Tile_Columns,"Padding","compact","TileSpacing","compact");

    for Modality_Index = 1:Num_Modalities
        nexttile;
        imagesc(Feature_Result.Modality_Images{Modality_Index});
        colormap(gca,Vis.JoeyBG_Colormap_Flip);
        clim([0 1]);
        colorbar;
        title(Config.Feature.Modality_Display_Names(Modality_Index), ...
            "FontName",Vis.Font_Name, ...
            "FontWeight",Vis.Font_Weight_Title, ...
            "FontSize",max(10,Vis.Font_Size_Title - 2));
        xlabel("Slow Time (s)","FontName",Vis.Font_Name,"FontSize",max(9,Vis.Font_Size_Axis - 3));
        ylabel("Doppler (Hz)","FontName",Vis.Font_Name,"FontSize",max(9,Vis.Font_Size_Axis - 3));
        ApplyAxisStyle(Config,true);
    end

    if nargin >= 3 && strlength(string(Save_Path)) > 0
        exportgraphics(Figure_Handle,Save_Path,"Resolution",300);
    end

end
