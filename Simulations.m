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
T = 5;

% Beacon size (bytes)
BB =[100;200;300];% 100;

% trace file
TR='testvpm200.csv'; %'testvpm60.csv'; % 

% p2r vs sps
MODE=[false;true];

% generation interval
INTERVAL=[0.1;0.2;0.3];

%% LTE Autonomous (3GPP Mode 4) - on a subframe basis
% Autonomous allocation algorithm defined in 3GPP standard

% WiLabV2Xsim(configFile,'simulationTime',T,'BRAlgorithm',18,'Raw',150,...
% 'beaconSizeBytes',200,'startSimulationTime',ST,'enableP2R', true,...
% 'allocationPeriod',0.1,'generationInterval',0.1, ...
%     'filenameTrace',TR);

% for m=1:size(MODE)
    for b=1:size(BB)
        for i=1:size(INTERVAL)
%             MODE(m)            
%             fprintf("--%d------%f--------\n",BB(b),INTERVAL(i));
            WiLabV2Xsim(configFile,'simulationTime',T,'BRAlgorithm',18,'Raw',150,...
            'beaconSizeBytes',BB(b),'startSimulationTime',ST,'enableP2R', true,...
            'allocationPeriod',INTERVAL(i),'generationInterval',INTERVAL(i), ...
                'filenameTrace',TR);
        end
    end
% end