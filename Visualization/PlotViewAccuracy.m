%% Function of View Accuracy Visualization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function PlotViewAccuracy(Testing_Result_Table,Config,Save_Path)

    Vis = Config.Visualization;
    Figure_Handle = figure("Name","JoeyBG Cross-View Accuracy","Color","w");
    set(Figure_Handle,"Position",[120 120 920 540]);

    plot(Testing_Result_Table.Angle,Testing_Result_Table.Ensemble * 100, ...
        "-o","LineWidth",2.4, ...
        "MarkerSize",7, ...
        "Color",Vis.JoeyBG_Colormap(10,:), ...
        "MarkerFaceColor",Vis.JoeyBG_Colormap(4,:));

    grid on;
    ylim([0 100]);
    xticks(Testing_Result_Table.Angle);
    xlabel("Testing View Angle (degree)","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    ylabel("Accuracy (%)","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    title("Cross-View Testing Accuracy","FontName",Vis.Font_Name, ...
        "FontWeight",Vis.Font_Weight_Title,"FontSize",Vis.Font_Size_Title);
    legend("Ensemble","Location","best","Interpreter","none");
    ApplyAxisStyle(Config,false);

    if nargin >= 3 && strlength(string(Save_Path)) > 0
        exportgraphics(Figure_Handle,Save_Path,"Resolution",300);
    end

end
