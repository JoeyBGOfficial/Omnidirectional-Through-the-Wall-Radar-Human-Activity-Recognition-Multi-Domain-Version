%% Function of Single-Branch Network Construction
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function constructs one lightweight ConvNeXt-style branch network for
% a single DTM or multi-window mDOF modality image. All branches share the
% same topology but are trained independently.

function Layer_Graph = CreateBranchNetwork(Config)

    Num_Classes = Config.Network.Num_Classes;
    Base_Channel = Config.Network.Base_Channel_Number;

    Layer_Graph = layerGraph();

    Stem_Layers = [
        imageInputLayer(Config.Network.Input_Size,"Name","imageinput","Normalization","none")
        convolution2dLayer([5 5],Base_Channel,"Name","stem_conv","Padding","same","Stride",[2 2])
        batchNormalizationLayer("Name","stem_bn")
        geluLayer("Name","stem_gelu")
        averagePooling2dLayer([2 2],"Name","stem_pool","Padding","same","Stride",[2 2])];
    Layer_Graph = addLayers(Layer_Graph,Stem_Layers);

    Layer_Graph = AddDecisionBranchBlock(Layer_Graph,"stage1_block1","stem_pool",Base_Channel);
    Layer_Graph = AddDecisionBranchBlock(Layer_Graph,"stage1_block2","stage1_block1_add",Base_Channel);

    Transition_1 = [
        convolution2dLayer([3 3],Base_Channel * 2,"Name","trans1_conv","Padding","same","Stride",[2 2])
        batchNormalizationLayer("Name","trans1_bn")
        geluLayer("Name","trans1_gelu")];
    Layer_Graph = addLayers(Layer_Graph,Transition_1);
    Layer_Graph = connectLayers(Layer_Graph,"stage1_block2_add","trans1_conv");

    Layer_Graph = AddDecisionBranchBlock(Layer_Graph,"stage2_block1","trans1_gelu",Base_Channel * 2);
    Layer_Graph = AddDecisionBranchBlock(Layer_Graph,"stage2_block2","stage2_block1_add",Base_Channel * 2);

    Transition_2 = [
        convolution2dLayer([3 3],Base_Channel * 4,"Name","trans2_conv","Padding","same","Stride",[2 2])
        batchNormalizationLayer("Name","trans2_bn")
        geluLayer("Name","trans2_gelu")];
    Layer_Graph = addLayers(Layer_Graph,Transition_2);
    Layer_Graph = connectLayers(Layer_Graph,"stage2_block2_add","trans2_conv");

    Layer_Graph = AddDecisionBranchBlock(Layer_Graph,"stage3_block1","trans2_gelu",Base_Channel * 4);
    Layer_Graph = AddDecisionBranchBlock(Layer_Graph,"stage3_block2","stage3_block1_add",Base_Channel * 4);

    Head_Layers = [
        convolution2dLayer([1 1],Base_Channel * 4,"Name","head_mix","Padding","same")
        batchNormalizationLayer("Name","head_bn")
        geluLayer("Name","head_gelu")
        globalAveragePooling2dLayer("Name","head_gap")
        dropoutLayer(Config.Network.Dropout_Rate,"Name","head_dropout")
        fullyConnectedLayer(Num_Classes,"Name","head_fc")
        softmaxLayer("Name","softmax")
        classificationLayer("Name","classification")];
    Layer_Graph = addLayers(Layer_Graph,Head_Layers);
    Layer_Graph = connectLayers(Layer_Graph,"stage3_block2_add","head_mix");

end

function Layer_Graph = AddDecisionBranchBlock(Layer_Graph,Block_Name,Input_Name,Channel_Number)

    Branch_3 = [
        convolution2dLayer([3 3],Channel_Number,"Name",Block_Name + "_conv3","Padding","same")
        batchNormalizationLayer("Name",Block_Name + "_bn3")
        geluLayer("Name",Block_Name + "_gelu3")];

    Branch_5 = [
        convolution2dLayer([5 5],Channel_Number,"Name",Block_Name + "_conv5","Padding","same")
        batchNormalizationLayer("Name",Block_Name + "_bn5")
        geluLayer("Name",Block_Name + "_gelu5")];

    Branch_7 = [
        convolution2dLayer([7 7],Channel_Number,"Name",Block_Name + "_conv7","Padding","same")
        batchNormalizationLayer("Name",Block_Name + "_bn7")
        geluLayer("Name",Block_Name + "_gelu7")];

    Fuse_Layers = [
        depthConcatenationLayer(3,"Name",Block_Name + "_cat")
        convolution2dLayer([1 1],Channel_Number,"Name",Block_Name + "_mix","Padding","same")
        batchNormalizationLayer("Name",Block_Name + "_bn_mix")
        geluLayer("Name",Block_Name + "_gelu_mix")];

    Gate_Layers = [
        convolution2dLayer([1 1],Channel_Number,"Name",Block_Name + "_gate_conv","Padding","same")
        sigmoidLayer("Name",Block_Name + "_gate_sigmoid")];

    Output_Layers = [
        multiplicationLayer(2,"Name",Block_Name + "_multiply")
        convolution2dLayer([1 1],Channel_Number,"Name",Block_Name + "_out_conv","Padding","same")
        batchNormalizationLayer("Name",Block_Name + "_out_bn")
        additionLayer(2,"Name",Block_Name + "_add")];

    Layer_Graph = addLayers(Layer_Graph,Branch_3);
    Layer_Graph = addLayers(Layer_Graph,Branch_5);
    Layer_Graph = addLayers(Layer_Graph,Branch_7);
    Layer_Graph = addLayers(Layer_Graph,Fuse_Layers);
    Layer_Graph = addLayers(Layer_Graph,Gate_Layers);
    Layer_Graph = addLayers(Layer_Graph,Output_Layers);

    Layer_Graph = connectLayers(Layer_Graph,Input_Name,Block_Name + "_conv3");
    Layer_Graph = connectLayers(Layer_Graph,Input_Name,Block_Name + "_conv5");
    Layer_Graph = connectLayers(Layer_Graph,Input_Name,Block_Name + "_conv7");
    Layer_Graph = connectLayers(Layer_Graph,Input_Name,Block_Name + "_add/in2");

    Layer_Graph = connectLayers(Layer_Graph,Block_Name + "_gelu3",Block_Name + "_cat/in1");
    Layer_Graph = connectLayers(Layer_Graph,Block_Name + "_gelu5",Block_Name + "_cat/in2");
    Layer_Graph = connectLayers(Layer_Graph,Block_Name + "_gelu7",Block_Name + "_cat/in3");

    Layer_Graph = connectLayers(Layer_Graph,Block_Name + "_gelu_mix",Block_Name + "_gate_conv");
    Layer_Graph = connectLayers(Layer_Graph,Block_Name + "_gelu_mix",Block_Name + "_multiply/in1");
    Layer_Graph = connectLayers(Layer_Graph,Block_Name + "_gate_sigmoid",Block_Name + "_multiply/in2");

end
