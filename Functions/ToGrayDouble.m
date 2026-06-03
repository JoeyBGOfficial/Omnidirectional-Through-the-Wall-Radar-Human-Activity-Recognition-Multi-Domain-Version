%% Function of DTM Grayscale Conversion
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function Gray_Image = ToGrayDouble(Input_Image,Config)

    Input_Image = im2double(Input_Image);

    if ndims(Input_Image) == 3
        if nargin >= 2 && isfield(Config.Feature,"Input_Image_Mode") && ...
                Config.Feature.Input_Image_Mode == "JetLogDTM"
            Gray_Image = DecodeJetLogDTM(Input_Image);
        else
            Gray_Image = rgb2gray(Input_Image);
        end
    else
        Gray_Image = Input_Image;
    end

end

function Scalar_Image = DecodeJetLogDTM(RGB_Image)

    Image_Size = size(RGB_Image);
    Pixel_Table = reshape(RGB_Image,[],3);
    Pixel_Table = round(Pixel_Table * 255) / 255;

    [Unique_Color_Table,~,Pixel_Index] = unique(Pixel_Table,"rows","stable");
    Jet_Table = round(jet(256) * 255) / 255;
    Unique_Value = zeros(size(Unique_Color_Table,1),1);

    Chunk_Size = 20000;
    for Start_Index = 1:Chunk_Size:size(Unique_Color_Table,1)
        End_Index = min(Start_Index + Chunk_Size - 1,size(Unique_Color_Table,1));
        Current_Colors = Unique_Color_Table(Start_Index:End_Index,:);

        Distance_Table = ...
            (Current_Colors(:,1) - Jet_Table(:,1)').^2 + ...
            (Current_Colors(:,2) - Jet_Table(:,2)').^2 + ...
            (Current_Colors(:,3) - Jet_Table(:,3)').^2;

        [~,Nearest_Index] = min(Distance_Table,[],2);
        Unique_Value(Start_Index:End_Index) = (Nearest_Index - 1) / 255;
    end

    Scalar_Image = reshape(Unique_Value(Pixel_Index),Image_Size(1),Image_Size(2));
    Scalar_Image = min(max(Scalar_Image,0),1);

end
