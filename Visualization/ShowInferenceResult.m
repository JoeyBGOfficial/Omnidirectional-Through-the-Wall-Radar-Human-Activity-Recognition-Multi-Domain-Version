%% Function of Inference Result Visualization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function ShowInferenceResult(Inference_Result,Config,Save_Path)

    Vis = Config.Visualization;
    Feature_Result = Inference_Result.Feature_Result;
    Num_Modalities = numel(Config.Feature.Modality_Names);
    Tile_Columns = 4;
    Feature_Rows = ceil(Num_Modalities / Tile_Columns);
    Total_Rows = Feature_Rows + 2;
    Figure_Handle = figure("Name","JoeyBG Inference Result","Color","w");
    set(Figure_Handle,"Position",[50 40 1550 min(1080,210 * Total_Rows)]);

    tiledlayout(Total_Rows,Tile_Columns,"Padding","compact","TileSpacing","compact");

    for Modality_Index = 1:Num_Modalities
        nexttile;
        imagesc(Feature_Result.Modality_Images{Modality_Index});
        colormap(gca,Vis.JoeyBG_Colormap_Flip);
        clim([0 1]);
        colorbar;
        title(Config.Feature.Modality_Display_Names(Modality_Index), ...
            "FontName",Vis.Font_Name, ...
            "FontWeight",Vis.Font_Weight_Title, ...
            "FontSize",max(10,Vis.Font_Size_Title - 3));
        ApplyAxisStyle(Config,true);
    end

    Empty_Tiles = Feature_Rows * Tile_Columns - Num_Modalities;
    for Tile_Index = 1:Empty_Tiles
        nexttile;
        axis off;
    end

    nexttile([1 Tile_Columns]);
    bar(categorical(string(Inference_Result.Class_Names)),Inference_Result.Vote_Ratio, ...
        "FaceColor",Vis.JoeyBG_Colormap(9,:));
    xtickangle(45);
    ylim([0 1]);
    grid on;
    ylabel("Vote Ratio","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    title("Hard Voting: " + string(Inference_Result.Label), ...
        "FontName",Vis.Font_Name, ...
        "FontWeight",Vis.Font_Weight_Title, ...
        "FontSize",Vis.Font_Size_Title);
    ApplyAxisStyle(Config,false);

    nexttile([1 Tile_Columns]);
    Branch_Names = string(Inference_Result.Branch_Names(:));
    Branch_Labels = string(Inference_Result.Branch_Labels(:));
    Branch_Confidence = Inference_Result.Branch_Confidence(:);
    Selected_Branches = Inference_Result.Selected_Branches(:);
    Branch_Display_Names = Branch_Names;
    Branch_Display_Names(Selected_Branches) = Branch_Display_Names(Selected_Branches) + " *";

    bar(categorical(Branch_Display_Names),Branch_Confidence, ...
        "FaceColor",Vis.JoeyBG_Colormap(4,:));
    ylim([0 1]);
    grid on;
    ylabel("Branch Confidence","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    title("Branch Decisions","FontName",Vis.Font_Name, ...
        "FontWeight",Vis.Font_Weight_Title, ...
        "FontSize",Vis.Font_Size_Title);
    ApplyAxisStyle(Config,false);

    Text_Y = min(0.96,Branch_Confidence + 0.06);
    for Branch_Index = 1:numel(Branch_Names)
        text(Branch_Index,Text_Y(Branch_Index),Branch_Labels(Branch_Index), ...
            "HorizontalAlignment","center", ...
            "FontName",Vis.Font_Name, ...
            "FontSize",max(8,Vis.Font_Size_Basis - 3), ...
            "FontWeight",Vis.Font_Weight_Basis, ...
            "Rotation",15);
    end

    if nargin >= 3 && strlength(string(Save_Path)) > 0
        exportgraphics(Figure_Handle,Save_Path,"Resolution",300);
    end

end
