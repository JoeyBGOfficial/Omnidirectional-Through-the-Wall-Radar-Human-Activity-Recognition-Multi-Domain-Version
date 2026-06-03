%% Function of Confusion Matrix Visualization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function PlotConfusionMatrix(True_Label,Predicted_Label,Config,Save_Path)

    Vis = Config.Visualization;
    Figure_Handle = figure("Name","JoeyBG Confusion Matrix","Color","w");
    set(Figure_Handle,"Position",[120 80 980 820]);
    Chart = confusionchart(True_Label,Predicted_Label);
    Chart.Title = "Confusion Matrix";
    Chart.RowSummary = "row-normalized";
    Chart.ColumnSummary = "column-normalized";
    Chart.FontName = Vis.Font_Name;
    Chart.FontSize = Vis.Font_Size_Basis;

    if nargin >= 4 && strlength(string(Save_Path)) > 0
        exportgraphics(Figure_Handle,Save_Path,"Resolution",300);
    end

end
