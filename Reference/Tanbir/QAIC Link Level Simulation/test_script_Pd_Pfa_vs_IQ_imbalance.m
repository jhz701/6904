%% This script is used to generate detection, false alarm probability vs SNR plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: October, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note that the script "script_setup_system_parameters.m" must be run before running
% this script
%
% This script will produce detection probability and false alarm probability as a function of IQ imbalance
% with SNR and K fixed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin system simulation
tic;

K_vals = [1 2 3 4];
MaxSupports = length(K_vals); % maximum support number

delPhase_vals = 0:1:25; % phase imbalance values in degrees
[dummy points] = size(delPhase_vals);
MaxItters = 10; % maximum number of itterations per specified K and SNR

detects = zeros(points,MaxSupports);
detection_prob = zeros(points,MaxSupports);
alarms = zeros(points,MaxSupports);
false_alarm_probability = zeros(points,MaxSupports);

for r=1:MaxSupports
    K=K_vals(r); % set support number
    
for l=1:points
    
    delPhase = delPhase_vals(l); % set SNR value

    for m=1:MaxItters
        reset(RandStream.getGlobalStream,sum(100*clock)); % reset random number generator for every simulation run
        
        % run the scanner model and analyze results
        script_run_scanner_model;
        script_analyze_results;
        
        % log the simulation statistics
        detects(l,r) = detects(l,r) + correct_detections; % variable "correct_detections" updated by the script "script_analyze_results"
        alarms(l,r) = alarms(l,r) + false_alarms; % variable "false_alarms" updated by the script "script_analyze_results"

    end %for

    clc; 
    r 
    l % display current itteration number
    
    detection_prob(l,r) = 100*detects(l,r)/(MaxItters*K); % compute detection probability
    false_alarm_probability(l,r) = 100*alarms(l,r)/((numBins-K)*MaxItters); % compute false alarm probability

end

end

toc

%% Save simulation data to a file


%% The simulation results are plotted in the following script

figure
plot(2*delPhase_vals,detection_prob(:,1),'Marker','o');
grid on;
hold on;
plot(2*delPhase_vals,detection_prob(:,2),'Marker','s');
plot(2*delPhase_vals,detection_prob(:,3),'Marker','d');
plot(2*delPhase_vals,detection_prob(:,4),'Marker','*');
plot(2*delPhase_vals,false_alarm_probability(:,1),'--','Marker','o');
plot(2*delPhase_vals,false_alarm_probability(:,2),'--','Marker','s');
plot(2*delPhase_vals,false_alarm_probability(:,3),'--','Marker','d');
plot(2*delPhase_vals,false_alarm_probability(:,4),'--','Marker','*');
legend('Detection Probability, K=1','Detection Probability, K=2','Detection Probability, K=3','Detection Probability, K=4','False Alarm Probability, K=1','False Alarm Probability, K=2','False Alarm Probability, K=3','False Alarm Probability, K=4','Location','Best');
xlabel('IQ Phase Imbalance (degrees)','fontsize',14); 
ylabel('Probability (%)','fontsize',14); 
title('f_{RFNYQ}=10160MHz, f_{BBNYQ}=1270MHz, 2mf_S=160MHz, resBW=10MHz, SNR=9dB','fontsize',14);
