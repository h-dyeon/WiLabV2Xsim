close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window

%LTEV2Vsim('help');

% Configuration file
configFile = 'HDY_Highway3GPP.cfg';
%configFile = 'BolognaA.cfg';
%configFile = 'Highway3GPP.cfg';


% startSimulationTime (s)
ST=300.001;
% Simulation time (s) (duration of the simulation)
T = 10;

% Beacon size (bytes)
B = 300;

%% LTE Autonomous (3GPP Mode 4) - on a subframe basis
% Autonomous allocation algorithm defined in 3GPP standard

WiLabV2Xsim(configFile,'simulationTime',T,'BRAlgorithm',18,'Raw',150,...
    'beaconSizeBytes',B,'startSimulationTime',ST);

