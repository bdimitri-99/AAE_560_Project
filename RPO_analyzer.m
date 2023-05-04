%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Instructions:
% This script breaks down the porfolios generated from
% the RPO code. I've started out with calculating the 
% costs, warheads, missiles, complexity, and aimpoints,
% but can easily add other calculations as well depending
% on what we think is important
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;close all;
cost_start = 1e3; %Lowest cost to evaluate at in millions of $
cost_end = 1e6; %Highest cost to evaluate at in million of $
cost_step = 40; %Number of steps between cost_start and cost_end to evaluate
SoScap = 1; %Capability to focus on; 1 is all, 2 is deterrence, 3 is survivability
if SoScap == 1
    Baseline_CAP_Normalization = 478.75; %Capability for base case for comparison
elseif SoScap == 2
    Baseline_CAP_Normalization = 497; %Base case capability for retaliation
else
    Baseline_CAP_Normalization = 460.5; %Base case capability for survivability
end
Baseline_COST_Normalization = 32.36e3; %Used to compare generated portfolios to the base cost
Baseline_CMPX_Normalization = 2229; %Complexity for base case for comparison
%filename = '+example/AAE560_NukeTraid_baseline.xlsx'; %Run RPO for Base
%case
filename = '+example/AAE560_NukeTraid.xlsx'; %Run RPO for test cases
cost_end = Baseline_COST_Normalization; %Limit max cost of test cases to current triad cost
include_mobile_launcher = 0; %Indicate whether or not mobile launchers will be included

%Run RPO code
out = RPOMain(cost_start,cost_end,cost_step,SoScap,filename);
results = out.rpoResults;

%Indices of systems in output
B2_cruise_missile = 1;
B52_cruise_missile = 2;
Trident = 3;
Minuteman_silo = 4;
Minuteman_mobile = 5;
B2 = 6;
B52 = 7;
Submarine = 8;
Silo = 9;
Mobile_launcher = 10;
AFB = 11;
Navy = 12;
CommandCenter = 13;
sys_costs = [.6,.6,3.8,1.1,1.1,50,10,80];

%Define complexity values for each of the above systems (higher number =
%more complex)
complexities = [1,1,2,1,2,4,4,4,2,3,5,5,1];

systems = [];
ap = [0,0,0,0,0,0,0,0,1,1,1,1,1]; %Defines which systems are aimpoints
aimpoints = [];
complex = [];
weapons = [];
w = [1,1,1,1,1,0,0,0,0,0,0,0,0]; %Defines which systems are weapons
wh = [1,1,4,1,1,0,0,0,0,0,0,0,0]; %Calculates the number of warheads in portfolio
warheads = [];
costs = [];
nsys = length(out.rpoResults(1).allocation); %Number of systems
capabilities = [];
bad_row = [];

%This loop iterates through each portfolio and calculates:
% a) The number of aimpoints
% b) The overall portfolio complexity
% c) The number of missiles included in the portfolio
% d) The number of warheads in the porfolio
% e) The cost of the porfolio
for i = 1:(out.riskStep*out.costStep)
    systems(i,1:nsys) = out.rpoResults(i).allocation;
    aimpoints(i) = ap*systems(i,1:nsys)';
    complex(i) = complexities*systems(i,1:nsys)';
    weapons(i) = w*systems(i,1:nsys)';
    warheads(i) = wh*systems(i,1:nsys)';
    costs(i) = out.rpoResults(i).cost;
    capabilities(i) = out.rpoResults(i).objective;
    if (isequal(systems(i,:),zeros(1,length(systems(i,:)))))
        bad_row = [bad_row,i];
    end
end

if length(bad_row) == out.riskStep*out.costStep %Used to remove instances of not finding a solution
    error('No Solutions Found')
end

if length(bad_row)
    for j = flip(bad_row)
        systems(j,:)=[];
        aimpoints(j)=[];
        complex(j)=[];
        weapons(j)=[];
        warheads(j)=[];
        costs(j)=[];
        capabilities(j)=[];
    end
end

%For highest performance system
j = find(capabilities==max(capabilities));
%For closest to current capability level
[val,k] = min(abs(capabilities-Baseline_CAP_Normalization*ones(1,length(capabilities))));
if length(k)>1
    k = k(1);
end
best_portfolio = systems(k,:);

%%Plot results
figure(3)
subplot(1,2,1)
plot(costs,systems(:,7),'LineWidth',2)
hold on
plot(costs(k),systems(k,7),'k*')
plot(costs(j),systems(j,7),'r*')
plot(costs,systems(:,6),'LineWidth',2)
plot(costs(k),systems(k,6),'k*')
plot(costs(j),systems(j,6),'r*')
plot(costs,systems(:,8),'LineWidth',2)
plot(costs(k),systems(k,8),'k*')
plot(costs(j),systems(j,8),'r*')
plot(costs,systems(:,9),'LineWidth',2)
plot(costs(k),systems(k,9),'k*')
plot(costs(j),systems(j,9),'r*')
if include_mobile_launcher
    plot(costs,systems(:,10),'LineWidth',2)
    plot(costs(k),systems(k,10),'k*')
    plot(costs(j),systems(j,10),'r*')
    legend('B-52','','','B-2','','','Submarine','','','Silos','','','Mobile Launchers','Cost Efficiency Point','Max Performance Point','Location','northwest')
else
        legend('B-52','','','B-2','','','Submarine','','','Silos','Cost Efficiency Point','Max Performance Point','Location','northwest')
end
grid on
xlabel('Portfolio Cost (Millions of $)')
ylabel('Number of System')
title('Vehicle and Silo Distribution')

subplot(1,2,2)
plot(costs,systems(:,1)+systems(:,2),'LineWidth',2)
hold on
plot(costs(k),systems(k,1)+systems(k,2),'k*')
plot(costs(j),systems(j,1)+systems(j,2),'r*')
plot(costs,systems(:,3),'LineWidth',2)
plot(costs(k),systems(k,3),'k*')
plot(costs(j),systems(j,3),'r*')
plot(costs,systems(:,4),'LineWidth',2)
plot(costs(k),systems(k,4),'k*')
plot(costs(j),systems(j,4),'r*')
if include_mobile_launcher
    plot(costs,systems(:,5),'LineWidth',2)
    plot(costs(k),systems(k,5),'k*')
    plot(costs(j),systems(j,5),'r*')
    legend('Cruise Missile','','','SLBM','','','Stationary ICBM','','','Mobile ICBM','Cost Efficiency Point','Max Performance Point','Location','northwest')
else
    legend('Cruise Missile','','','SLBM','','','Stationary ICBM','Cost Efficiency Point','Max Performance Point','Location','northwest')
end
xlabel('Portfolio Cost (Millions of $)')
ylabel('Number of Missile')
title('Missile Type Distribution')
grid on

%Normalize cost, complexity, and capability against baseline
costs = costs/Baseline_COST_Normalization*100;
complex = complex/Baseline_CMPX_Normalization*100;
capabilities = capabilities/Baseline_CAP_Normalization*100;

figure(4)
subplot(1,3,1)
plot(costs,complex,'LineWidth',2)
hold on
plot(costs(k),complex(k),'k*')
plot(costs(j),complex(j),'r*')
grid on
xlabel('Percent of Baseline Cost')
ylabel('Portfolio Complexity')
title('Complexity vs Cost')
xtickformat('percentage')
ytickformat('percentage')
legend('','Cost Efficiency Point','Max Performance Point')

subplot(1,3,2)
plot(complex,capabilities,'LineWidth',2)
hold on
plot(complex(k),capabilities(k),'k*')
plot(complex(j),capabilities(j),'r*')
grid on
xlabel('Percent of Baseline Complexity')
ylabel('Percent of Baseline Deterrence')
title('Complexity vs Deterrence')
xtickformat('percentage')
ytickformat('percentage')

subplot(1,3,3)
plot(costs,capabilities,'LineWidth',2)
hold on
plot(costs(k),capabilities(k),'k*')
plot(costs(j),capabilities(j),'r*')
grid on
xlabel('Percent of Baseline Cost')
ylabel('Percent of Baseline Deterrence')
title('Cost vs Deterrence')
xtickformat('percentage')
ytickformat('percentage')

pdist = sys_costs.*best_portfolio(1:8);
figure(5)
tiledlayout(1,3);
nexttile;
if include_mobile_launcher
    labels = {'Cruise Missiles: ','SLBMs: ','Staionary ICBMs: ','Mobile ICBMs: ','B2s: ','B52s: ','Submarines: ','Missile Silos: ','Mobile Launchers: '};
    pdist = [pdist(1)+pdist(2),pdist(3),pdist(4),pdist(5),pdist(6),pdist(7),pdist(8),best_portfolio(9)*61,best_portfolio(10)*10];
    p = pie(pdist,[1,1,1,1,1,1,1,1,1]);
    pText = findobj(p,'Type','text');
    vals = {num2str(pdist(1)),num2str(pdist(2)),num2str(pdist(3)),num2str(pdist(4)),num2str(pdist(5)),num2str(pdist(6)),num2str(pdist(7)),num2str(pdist(8)),num2str(pdist(9))};
    combinedtxt = strcat(labels,strcat({'$','$','$','$','$','$','$','$','$'},vals));
else
    labels = {'Cruise Missiles: ','SLBMs: ','Staionary ICBMs: ','B2s: ','B52s: ','Submarines: ','Missile Silos: '};
    pdist = [pdist(1)+pdist(2),pdist(3),pdist(4),pdist(6),pdist(7),pdist(8),best_portfolio(9)*61];
    p = pie(pdist,[1,1,1,1,1,1,1]);
    pText = findobj(p,'Type','text');
    vals = {num2str(pdist(1)),num2str(pdist(2)),num2str(pdist(3)),num2str(pdist(4)),num2str(pdist(5)),num2str(pdist(6)),num2str(pdist(7))};
    combinedtxt = strcat(labels,strcat({'$','$','$','$','$','$','$'},vals));    
end
for i = 1:length(labels)
    pText(i).String = combinedtxt(i);
end
set(p(2:2:end),'fontsize',6);
t = title('Cost Breakdown (Millions $)','Position',[0,1.3,0]);
txt = strcat('Total Cost: ',strcat(strcat(' $',num2str(sum(pdist)/1000)),' Billion'));
text(-.7,-1.4,txt)

sysdist = [best_portfolio(1)+best_portfolio(2),best_portfolio(3),best_portfolio(4),best_portfolio(5),best_portfolio(6),best_portfolio(7),best_portfolio(8),best_portfolio(9),best_portfolio(10)];

nexttile;
if include_mobile_launcher
    labels = {'Cruise Missiles: ','SLBMs: ','Stationary ICBMs: ','Mobile ICBMs: ','B2s: ','B52s: ','Submarines: ','Missile Silos: ','Mobile Launchers: '};
    sysdist = [best_portfolio(1)+best_portfolio(2),best_portfolio(3),best_portfolio(4),best_portfolio(5),best_portfolio(6),best_portfolio(7),best_portfolio(8),best_portfolio(9),best_portfolio(10)];
    p = pie(sysdist,[1,1,1,1,1,1,1,1,1]);
    pText = findobj(p,'Type','text');
    vals = {num2str(sysdist(1)),num2str(sysdist(2)),num2str(sysdist(3)),num2str(sysdist(4)),num2str(sysdist(5)),num2str(sysdist(6)),num2str(sysdist(7)),num2str(sysdist(8)),num2str(sysdist(9))};
else
    labels = {'Cruise Missiles: ','SLBMs: ','Stationary ICBMs: ','B2s: ','B52s: ','Submarines: ','Missile Silos: '};
    sysdist = [best_portfolio(1)+best_portfolio(2),best_portfolio(3),best_portfolio(4),best_portfolio(6),best_portfolio(7),best_portfolio(8),best_portfolio(9)];
    p = pie(sysdist,[1,1,1,1,1,1,1]);
    pText = findobj(p,'Type','text');
    vals = {num2str(sysdist(1)),num2str(sysdist(2)),num2str(sysdist(3)),num2str(sysdist(4)),num2str(sysdist(5)),num2str(sysdist(6)),num2str(sysdist(7))};    
end
combinedtxt = strcat(labels,vals);
for i = 1:length(labels)
    pText(i).String = combinedtxt(i);
end
set(p(2:2:end),'fontsize',7);
title('System Breakdown','Position',[0,1.3,0]);

nexttile;
if include_mobile_launcher
    labels = {'Cruise Missiles: ','SLBMs: ','Stationary ICBMs: ','Mobile ICBMs: '};
    whdist = [best_portfolio(1)+best_portfolio(2),best_portfolio(3)*4,best_portfolio(4),best_portfolio(5)];
    p=pie(whdist,[1,1,1,1]);
    pText = findobj(p,'Type','text');
    vals = {num2str(whdist(1)),num2str(whdist(2)),num2str(whdist(3)),num2str(whdist(4))};
else
    labels = {'Cruise Missiles: ','SLBMs: ','Stationary ICBMs: '};
    whdist = [best_portfolio(1)+best_portfolio(2),best_portfolio(3)*4,best_portfolio(4)];
    p=pie(whdist,[1,1,1]);
    pText = findobj(p,'Type','text');
    vals = {num2str(whdist(1)),num2str(whdist(2)),num2str(whdist(3))};
end
combinedtxt = strcat(labels,vals);
for i = 1:length(labels)
    pText(i).String = combinedtxt(i);
end
set(p(2:2:end),'fontsize',7);
title('Warhead Breakdown Distribution by Triad Leg','Position',[0,1.3,0]);
