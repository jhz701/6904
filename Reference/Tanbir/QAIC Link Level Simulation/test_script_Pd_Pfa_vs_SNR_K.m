%% This script is used to generate detection, false alarm probability vs SNR plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: October, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note that the script "script_setup_system_parameters.m" must be run before running
% this script
%
% This script will produce detection probability and false alarm probability as a function of SNR and support
% number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin system simulation
tic;

MaxSupports = 4; % maximum support number

snr_vals = -10:3:20; % SNR values in dB
[dummy points] = size(snr_vals);
MaxItters = 10; % maximum number of itterations per specified K and SNR

detects = zeros(points,MaxSupports);
detection_prob = zeros(points,MaxSupports);
alarms = zeros(points,MaxSupports);
false_alarm_probability = zeros(points,MaxSupports);

for r=1:MaxSupports
    K=r; % set support number
    
for l=1:points
    
    SNRdB = snr_vals(l); % set SNR value
    SNR = 10^(SNRdB/10);

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

fileID = fopen('Pd_Pfa_vs_SNR_K.txt','w');

fprintf(fileID,'total bins = %g; resolution BW = %g;\n',numBins,resBW);
fprintf(fileID,'RF Nyquist Rate = %g; BB Nyquist Rate = %g; CS Scanner Aggregate Rate = %g;\n',W,Wbb,q*(Wbb/mwc_branch_downsample_factor));
fprintf(fileID,'total branches = %g; RF to BB downconversion factor = %g; MWC branch downconversion factor = %g;\n',q,OSR, mwc_branch_downsample_factor);
fprintf(fileID,'ResThreshold = %6.5f; ResvsSolThreshold = %6.5f;\n',ResThreshold,ResvsSolThreshold);
fprintf(fileID,'Sensing matrix type: %s\n', sens_mat_type);
fprintf(fileID,'Number of itterations per setting = %g\n', MaxItters);
fprintf(fileID,'\n');
fprintf(fileID,'K SNR Pd Pfa\n');
fprintf(fileID,'\n');

for r=1:MaxSupports
    for l=1:points
        fprintf(fileID,'%g %g %6.2f %6.2f\n',r,snr_vals(l),detection_prob(l,r),false_alarm_probability(l,r)); 
    end
end
fclose(fileID);

%% The simulation results are plotted in the following script

figure
plot(snr_vals,detection_prob(:,1),'Marker','o');
grid on;
hold on;
plot(snr_vals,detection_prob(:,2),'Marker','s')
plot(snr_vals,detection_prob(:,3),'Marker','d')
plot(snr_vals,detection_prob(:,4),'Marker','*')
legend('K = 1','K = 2','K = 3','K = 4','Location','SouthEast');
xlabel('SNR (dB)','fontsize',14); 
ylabel('Detection Probability (%)','fontsize',14); 
title('Detection Probability vs SNR','fontsize',16);

figure
plot(snr_vals,false_alarm_probability(:,1),'Marker','o');
grid on;
hold on;
plot(snr_vals,false_alarm_probability(:,2),'Marker','s');
plot(snr_vals,false_alarm_probability(:,3),'Marker','d');
plot(snr_vals,false_alarm_probability(:,4),'Marker','*');
legend('K = 1','K = 2','K = 3','K = 4','Location','NorthEast');
xlabel('SNR (dB)','fontsize',14); 
ylabel('False Alarm Probability (%)','fontsize',14); 
title('False Alarm Probability vs SNR','fontsize',16);