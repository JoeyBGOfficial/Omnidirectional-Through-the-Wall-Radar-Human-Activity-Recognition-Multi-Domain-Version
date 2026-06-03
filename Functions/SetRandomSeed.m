%% Function of Random Seed Presetting
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.

function SetRandomSeed(Config)

    rng(Config.Training.Random_Seed,"twister");

end
