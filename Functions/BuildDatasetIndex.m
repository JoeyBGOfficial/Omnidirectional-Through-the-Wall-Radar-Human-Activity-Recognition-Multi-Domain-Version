%% Function of Dataset Index Construction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function scans the measured or simulated multi-view DTM dataset and
% builds structured tables for training, validation, and cross-view testing.

function Dataset_Index = BuildDatasetIndex(Config)

    if ~isfolder(Config.Path.Training_Source_Root)
        error("Training source folder does not exist: %s",Config.Path.Training_Source_Root);
    end

    if ~isfolder(Config.Path.Testing_Source_Root)
        error("Testing source folder does not exist: %s",Config.Path.Testing_Source_Root);
    end

    Class_Names = Config.Dataset.Class_Names;

    Training_Table_Cell = cell(numel(Class_Names),1);
    for Class_Index = 1:numel(Class_Names)
        Current_Class = Class_Names(Class_Index);
        Current_Folder = fullfile(Config.Path.Training_Source_Root,Current_Class);
        Current_Files = ListPngFiles(Current_Folder);

        Training_Table_Cell{Class_Index} = table( ...
            repmat(Current_Class,numel(Current_Files),1), ...
            string(Current_Files(:)), ...
            repmat("Training_and_Validation",numel(Current_Files),1), ...
            nan(numel(Current_Files),1), ...
            'VariableNames',{'Label','Image_Path','Subset','Angle'});
    end
    Training_Table = vertcat(Training_Table_Cell{:});

    Angle_Dirs = dir(Config.Path.Testing_Source_Root);
    Angle_Dirs = Angle_Dirs([Angle_Dirs.isdir]);
    Angle_Names = string({Angle_Dirs.name});
    Angle_Names = Angle_Names(~ismember(Angle_Names,[".",".."]));
    Testing_Angles = sort(str2double(Angle_Names));
    Testing_Angles = Testing_Angles(~isnan(Testing_Angles));

    Testing_Table_Cell = cell(numel(Testing_Angles) * numel(Class_Names),1);
    Testing_Cell_Index = 0;
    for Angle_Index = 1:numel(Testing_Angles)
        Current_Angle = Testing_Angles(Angle_Index);
        for Class_Index = 1:numel(Class_Names)
            Testing_Cell_Index = Testing_Cell_Index + 1;
            Current_Class = Class_Names(Class_Index);
            Current_Folder = fullfile(Config.Path.Testing_Source_Root,string(Current_Angle),Current_Class);
            Current_Files = ListPngFiles(Current_Folder);

            Testing_Table_Cell{Testing_Cell_Index} = table( ...
                repmat(Current_Class,numel(Current_Files),1), ...
                string(Current_Files(:)), ...
                repmat("Testing",numel(Current_Files),1), ...
                repmat(Current_Angle,numel(Current_Files),1), ...
                'VariableNames',{'Label','Image_Path','Subset','Angle'});
        end
    end
    Testing_Table = vertcat(Testing_Table_Cell{:});

    [Training_Group,Training_Label] = findgroups(Training_Table.Label);
    Training_Count = splitapply(@numel,Training_Table.Image_Path,Training_Group);
    Training_Count_Table = table(Training_Label,Training_Count, ...
        'VariableNames',{'Label','Count'});

    [Testing_Group,Testing_Angle,Testing_Label] = findgroups(Testing_Table.Angle,Testing_Table.Label);
    Testing_Count = splitapply(@numel,Testing_Table.Image_Path,Testing_Group);
    Testing_Count_Table = table(Testing_Angle,Testing_Label,Testing_Count, ...
        'VariableNames',{'Angle','Label','Count'});

    Dataset_Index.Training_Table = Training_Table;
    Dataset_Index.Testing_Table = Testing_Table;
    Dataset_Index.Training_Count_Table = Training_Count_Table;
    Dataset_Index.Testing_Count_Table = Testing_Count_Table;
    Dataset_Index.Testing_Angles = Testing_Angles;
    Dataset_Index.Class_Names = Class_Names;

end

function File_List = ListPngFiles(Folder_Path)

    if ~isfolder(Folder_Path)
        error("Dataset class folder does not exist: %s",Folder_Path);
    end

    File_Struct = dir(fullfile(Folder_Path,"*.png"));
    File_Names = string({File_Struct.name});
    [~,Sort_Index] = sort(str2double(erase(File_Names,".png")));
    File_Struct = File_Struct(Sort_Index);

    File_List = strings(numel(File_Struct),1);
    for File_Index = 1:numel(File_Struct)
        File_List(File_Index) = string(fullfile(File_Struct(File_Index).folder,File_Struct(File_Index).name));
    end

end
