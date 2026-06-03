%% Function of Training Curve Visualization
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function PlotTrainingCurves(Training_Info,Config,Save_Path)

    Vis = Config.Visualization;
    Figure_Handle = figure("Name","JoeyBG Training Curves","Color","w");
    set(Figure_Handle,"Position",[120 120 1100 450]);
    tiledlayout(1,2,"Padding","compact","TileSpacing","compact");

    nexttile;
    if isfield(Training_Info,"TrainingLoss")
        plot(Training_Info.TrainingLoss,"LineWidth",2,"Color",Vis.JoeyBG_Colormap(2,:));
        hold on;
        if isfield(Training_Info,"ValidationLoss")
            plot(Training_Info.ValidationLoss,"LineWidth",2,"Color",Vis.JoeyBG_Colormap(9,:));
            legend(["Training Loss","Validation Loss"],"Location","best");
        end
    end
    xlabel("Iteration","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    ylabel("Loss","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    title("Training Loss","FontName",Vis.Font_Name,"FontWeight",Vis.Font_Weight_Title, ...
        "FontSize",Vis.Font_Size_Title);
    grid on;
    ApplyAxisStyle(Config,false);

    nexttile;
    if isfield(Training_Info,"TrainingAccuracy")
        plot(Training_Info.TrainingAccuracy,"LineWidth",2,"Color",Vis.JoeyBG_Colormap(3,:));
        hold on;
        if isfield(Training_Info,"ValidationAccuracy")
            plot(Training_Info.ValidationAccuracy,"LineWidth",2,"Color",Vis.JoeyBG_Colormap(10,:));
            legend(["Training Accuracy","Validation Accuracy"],"Location","best");
        end
    end
    xlabel("Iteration","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    ylabel("Accuracy (%)","FontName",Vis.Font_Name,"FontSize",Vis.Font_Size_Axis);
    title("Training Accuracy","FontName",Vis.Font_Name,"FontWeight",Vis.Font_Weight_Title, ...
        "FontSize",Vis.Font_Size_Title);
    grid on;
    ApplyAxisStyle(Config,false);

    if nargin >= 3 && strlength(string(Save_Path)) > 0
        exportgraphics(Figure_Handle,Save_Path,"Resolution",300);
    end

end
