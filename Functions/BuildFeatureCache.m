%% Function of Single-Modality Feature Cache Construction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function generates hard-voting ensemble feature caches. The original
% DTM and multi-window horizontal mDOF maps are stored in separated modality
% folders and are used to train independent branch networks.

function BuildFeatureCache(Dataset_Index,Config)

    disp("Feature cache generation started.");

    CacheRecordTable(Dataset_Index.Training_Table,Config,false);

    if Config.Feature.Cache_Test_Features
        CacheRecordTable(Dataset_Index.Testing_Table,Config,true);
    end

    disp("Feature cache generation finished.");

end

function CacheRecordTable(Record_Table,Config,Use_Angle_Folder)

    Num_Records = height(Record_Table);
    Source_Paths = Record_Table.Image_Path;
    Modality_Names = Config.Feature.Modality_Names;
    Output_Path_Table = strings(Num_Records,numel(Modality_Names));

    for Modality_Index = 1:numel(Modality_Names)
        Current_Modality = Modality_Names(Modality_Index);
        Output_Path_Table(:,Modality_Index) = GetFeaturePathsFromRecords( ...
            Record_Table,Config,Current_Modality,Use_Angle_Folder);
    end

    Missing_Mask = false(Num_Records,1);
    for Modality_Index = 1:numel(Modality_Names)
        Missing_Mask = Missing_Mask | ~isfile(Output_Path_Table(:,Modality_Index));
    end

    Need_Recompute = Config.Feature.Force_Recompute_Features | Missing_Mask;
    Pending_Index = find(Need_Recompute);
    Num_Pending = numel(Pending_Index);

    if Use_Angle_Folder
        Cache_Name = "Testing cache";
    else
        Cache_Name = "Training and validation cache";
    end

    fprintf("%s total records: %d, pending records: %d\n",Cache_Name,Num_Records,Num_Pending);

    if Num_Pending == 0
        return;
    end

    Pending_Source_Paths = Source_Paths(Pending_Index);
    Pending_Output_Path_Table = Output_Path_Table(Pending_Index,:);

    Use_Parallel = Config.Feature.Use_Parallel && license("test","Distrib_Computing_Toolbox");
    if Use_Parallel
        Use_Parallel = EnsureProcessPool();
    end

    if Use_Parallel
        parfor Pending_Counter = 1:Num_Pending
            WriteOneFeatureSet(Pending_Source_Paths(Pending_Counter), ...
                Pending_Output_Path_Table(Pending_Counter,:),Config);
        end
    else
        for Pending_Counter = 1:Num_Pending
            WriteOneFeatureSet(Pending_Source_Paths(Pending_Counter), ...
                Pending_Output_Path_Table(Pending_Counter,:),Config);
            if mod(Pending_Counter,50) == 0 || Pending_Counter == Num_Pending
                fprintf("Cached %d / %d feature sets.\n",Pending_Counter,Num_Pending);
            end
        end
    end

end

function Use_Parallel = EnsureProcessPool()

    Use_Parallel = true;

    try
        Pool = gcp("nocreate");

        if isempty(Pool)
            StartProcessPool();
            return;
        end

        Pool_Class = string(class(Pool));
        if contains(Pool_Class,"ThreadPool","IgnoreCase",true)
            delete(Pool);
            StartProcessPool();
        end
    catch Error_Info
        warning("BuildFeatureCache:ParallelDisabled", ...
            "Feature cache parallel mode is disabled: %s",Error_Info.message);
        Use_Parallel = false;
    end

end

function StartProcessPool()

    try
        parpool("Processes");
    catch
        parpool("local");
    end

end

function WriteOneFeatureSet(Source_Path,Output_Paths,Config)

    Feature_Result = ExtractEnsembleFeatures(Source_Path,Config);

    for Modality_Index = 1:numel(Config.Feature.Modality_Names)
        Current_Output_Path = Output_Paths(Modality_Index);
        Current_Output_Folder = fileparts(Current_Output_Path);
        if ~isfolder(Current_Output_Folder)
            mkdir(Current_Output_Folder);
        end
        imwrite(im2uint8(Feature_Result.Modality_Images{Modality_Index}),Current_Output_Path);
    end

end
