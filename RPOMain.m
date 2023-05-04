% function out = RPOMain()
%     % Spacecraft Autonomy Example
%      filename = '+example/Spacecraft_Autonomy.xlsx';
%      gamma = [0,200];
%      step_gam = 5;
%      cost = [1e5,4e5];
%      step_cost = 2;
%      SoScap = [1,2,3];
%      uncertains = [1,2];
%      out = example.RPO_Input.test(filename,gamma,step_gam,cost,step_cost,SoScap,uncertains);
%      
% end

% function out = RPOMain()
%     % Homework 4 Problem
%      filename = '+example/RPO_HW4.xlsx';
%      gamma = [0,1];
%      step_gam = 2;
%      cost = [80,1000];
%      step_cost = 5;
%      SoScap = 3;
%      uncertains = [1,2];
%      out = example.RPO_Input.test(filename,gamma,step_gam,cost,step_cost,SoScap,uncertains);
%      
% end

function out = RPOMain(min_cost,max_cost,step_cost,SoScap,filename)
    % Project
     gamma = [0,1];
     step_gam = 1;
     cost = [min_cost,max_cost];
     %step_cost = 10;
     %SoScap = 1;
     uncertains = [1,2,3,4,5,6,7,8,9];
     out = example.RPO_Input.test(filename,gamma,step_gam,cost,step_cost,SoScap,uncertains);
     
end
