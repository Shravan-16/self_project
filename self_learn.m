%% Micro-Hybrid Start-Stop System Simulation
% Driver inputs, battery SOC constraints and automatic engine shutdown

clear;
clc;
close all;

%% Simulation time
t = 0:0.1:50;       % Simulation time [seconds]

%% ---------------------------------------------------------
% 1. Vehicle Speed Profile
% ----------------------------------------------------------

vehicleSpeed = zeros(size(t));

vehicleSpeed(t >= 1  & t < 10) = 50;
vehicleSpeed(t >= 10 & t < 11) = linspace(50,30,...
    sum(t >= 10 & t < 11));
vehicleSpeed(t >= 11 & t < 15) = 30;
vehicleSpeed(t >= 15 & t < 16) = linspace(30,0,...
    sum(t >= 15 & t < 16));
vehicleSpeed(t >= 16 & t < 30) = 0;
vehicleSpeed(t >= 30 & t < 31) = linspace(0,20,...
    sum(t >= 30 & t < 31));
vehicleSpeed(t >= 31 & t < 40) = 20;
vehicleSpeed(t >= 40 & t < 41) = linspace(20,0,...
    sum(t >= 40 & t < 41));
vehicleSpeed(t >= 41) = 0;


%% ---------------------------------------------------------
% 2. Brake Pedal Profile
% ----------------------------------------------------------
% Brake input is scaled between 0 and 30 for visualization

brakePedal = zeros(size(t));

% Braking before engine shutdown
brakePedal(t >= 12 & t < 13) = linspace(0,30,...
    sum(t >= 12 & t < 13));

brakePedal(t >= 13 & t < 30) = 30;

% Brake released while vehicle is moving
brakePedal(t >= 30 & t < 31) = linspace(30,0,...
    sum(t >= 30 & t < 31));

brakePedal(t >= 31 & t < 40) = 0;

% Braking again at the final stop
brakePedal(t >= 40 & t < 41) = linspace(0,30,...
    sum(t >= 40 & t < 41));

brakePedal(t >= 41) = 30;


%% ---------------------------------------------------------
% 3. Battery State of Charge (SOC)
% ----------------------------------------------------------

batterySOC = 80 * ones(size(t));

% Battery SOC drops below critical threshold
batterySOC(t >= 25 & t < 30) = 42;

% Battery recovers after restart
batterySOC(t >= 30) = 75;


%% Critical SOC threshold
SOC_threshold = 45;


%% ---------------------------------------------------------
% 4. Micro-Hybrid Start-Stop Logic
% ----------------------------------------------------------
% Engine states:
% 1 = RUNNING
% 0 = SHUTDOWN

engineState = ones(size(t));

% Automatic shutdown condition:
% Vehicle stopped + brake applied
shutdownCondition = ...
    (vehicleSpeed == 0) & ...
    (brakePedal >= 30);

% Apply shutdown
engineState(shutdownCondition) = 0;


%% ---------------------------------------------------------
% 5. Safety Override
% ----------------------------------------------------------
% Restart engine when battery SOC falls below 45%

restartCondition = batterySOC < SOC_threshold;

engineState(restartCondition) = 1;


%% ---------------------------------------------------------
% 6. Plot
% ----------------------------------------------------------

figure('Color','w','Position',[100 50 1200 900]);


%% ---- Plot 1: Driver Inputs ----
subplot(3,1,1);

plot(t,vehicleSpeed,'b','LineWidth',2);
hold on;

plot(t,brakePedal,'r--','LineWidth',2);

grid on;

title('Micro-Hybrid Driver Inputs & Driving Profile',...
    'FontSize',16);

ylabel('Speed / Brake Int.');

legend('Vehicle Speed (km/h)',...
       'Brake Pedal Profile (Scaled 0-30)',...
       'Location','southwest');

xlim([0 52]);
ylim([-3 53]);


%% ---- Plot 2: Battery SOC ----
subplot(3,1,2);

plot(t,batterySOC,'g','LineWidth',2);
hold on;

yline(SOC_threshold,'k:',...
    'LineWidth',2);

grid on;

title('Energy Storage Constraints & Safety Interlocks',...
    'FontSize',16);

ylabel('Battery SOC (%)');

legend('Battery SOC (%)',...
       'Critical Threshold (45%)',...
       'Location','southwest');

xlim([0 52]);
ylim([40 82]);


%% ---- Plot 3: Engine State ----
subplot(3,1,3);

stairs(t,engineState,'k','LineWidth',2);

grid on;

title('Automated Micro-Hybrid Logic Executions',...
    'FontSize',16);

xlabel('Simulation Time (seconds)');
ylabel({'Engine State';'(RUNNING / SHUTDOWN)'});

xlim([0 52]);
ylim([-0.2 1.2]);

yticks([0 1]);
yticklabels({'(SHUTDOWN)','(RUNNING)'});


%% ---------------------------------------------------------
% 7. Add Explanatory Arrows
% ----------------------------------------------------------

subplot(3,1,3);
hold on;

% Auto shutdown annotation
annotation('textarrow',...
    [0.35 0.40],...
    [0.20 0.10],...
    'String',{'Auto-Shutdown','(v=0, Brake=1)'},...
    'FontSize',11);

% Override restart annotation
annotation('textarrow',...
    [0.60 0.55],...
    [0.37 0.52],...
    'String',{'Override Restart','(SOC < 45%)'},...
    'FontSize',11);

hold off;


%% ---------------------------------------------------------
% Results
% ----------------------------------------------------------

fprintf('\n========================================\n');
fprintf(' MICRO-HYBRID START-STOP SIMULATION\n');
fprintf('========================================\n');

fprintf('SOC Critical Threshold : %.0f %%\n',SOC_threshold);

fprintf('Engine Shutdown Events:\n');

% Find transitions from RUNNING to SHUTDOWN
shutdownEvents = find(diff(engineState) == -1);

for i = 1:length(shutdownEvents)
    fprintf('  Shutdown at %.1f seconds\n', ...
        t(shutdownEvents(i)+1));
end

fprintf('\nEngine Restart Events:\n');

restartEvents = find(diff(engineState) == 1);

for i = 1:length(restartEvents)
    fprintf('  Restart at %.1f seconds\n', ...
        t(restartEvents(i)+1));
end

fprintf('========================================\n');