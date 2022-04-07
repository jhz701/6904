%% This script is used to generate phase transition plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: October, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note that the script "script_setup_system_parameters.m" must be run before running
% this script
%
% This script will produce detection probability, missed detection
% probability and false alarm probability as a function of the support
% number and SNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin system simulation
tic;

Kmax = 16;
Kvals = 1:Kmax;
MaxItters = 10;
snr_vals = [6,9,12,15]';
[SNRpoints dummy]=size(snr_vals);

detects = zeros(Kmax,SNRpoints);
detects_missed = zeros(Kmax,SNRpoints);
alarms = zeros(Kmax,SNRpoints);

detection_prob = zeros(Kmax,SNRpoints);
missed_detection_prob = zeros(Kmax,SNRpoints);
false_alarm_rate = zeros(Kmax,SNRpoints);

for r=1:SNRpoints
    SNRdB = snr_vals(r);
    SNR = 10^(SNRdB/10);
    
for l=1:Kmax
    
    K = Kvals(l);

    for m=1:MaxItters
        reset(RandStream.getGlobalStream,sum(100*clock));
        
        % run the bandpass configuration scanner model
        script_run_scanner_model;
        script_analyze_results;
        
        % log the simulation statistics
        detects(l,r) = detects(l,r) + correct_detections;
        detects_missed(l,r) = detects_missed(l,r) + missed_detections;
        alarms(l,r) = alarms(l,r) + false_alarms;

    end

    clc;
    r
    l
    detection_prob(l,r) = 100*(detects(l,r)/(MaxItters*K));
    missed_detection_prob(l,r) = 100*(detects_missed(l,r)/(MaxItters*K));
    false_alarm_rate(l,r) = 100*(alarms(l,r)/((numBins-K)*MaxItters));

end

end

toc

%% Save simulation data to a file

fileID = fopen('Pd_Pfa_vs_K_SNR.txt','w');

fprintf(fileID,'total bins = %g; resolution BW = %g;\n',numBins,resBW);
fprintf(fileID,'RF Nyquist Rate = %g; BB Nyquist Rate = %g; CS Scanner Aggregate Rate = %g;\n',W,Wbb,q*(Wbb/mwc_branch_downsample_factor));
fprintf(fileID,'total branches = %g; RF to BB downconversion factor = %g; MWC branch downconversion factor = %g;\n',q,OSR, mwc_branch_downsample_factor);
fprintf(fileID,'ResThreshold = %6.5f; ResvsSolThreshold = %6.5f;\n',ResThreshold,ResvsSolThreshold);
fprintf(fileID,'Sensing matrix type: %s\n', sens_mat_type);
fprintf(fileID,'Number of itterations per setting = %g\n', MaxItters);
fprintf(fileID,'\n');
fprintf(fileID,'SNR K Pd Pfa\n');
fprintf(fileID,'\n');

for r=1:SNRpoints
    for l=1:Kmax
        fprintf(fileID,'%g %g %6.2f %6.2f\n',snr_vals(r),l,detection_prob(l,r),false_alarm_rate(l,r)); 
    end
end
fclose(fileID);

%% Plot the simulation results 

figure
plot(Kvals,detection_prob(:,1),'Marker','o');
grid on;
hold on;
plot(Kvals,detection_prob(:,2),'Marker','s');
plot(Kvals,detection_prob(:,3),'Marker','d');
plot(Kvals,detection_prob(:,4),'Marker','*');
xlim([1 Kmax]);
legend('SNR = 6dB','SNR = 9dB','SNR = 12dB','SNR = 15dB','Location','NorthEast');
xlabel('Support Number (K)','fontsize',14); 
ylabel('Detection Probability (%)','fontsize',14); 
title('Detection Probability vs Support Number','fontsize',16);

figure
plot(Kvals,false_alarm_rate(:,1),'Marker','o');
grid on;
hold on;
plot(Kvals,false_alarm_rate(:,2),'Marker','s');
plot(Kvals,false_alarm_rate(:,3),'Marker','d');
plot(Kvals,false_alarm_rate(:,4),'Marker','*');
xlim([1 Kmax]);
legend('SNR = 6dB','SNR = 9dB','SNR = 12dB','SNR = 15dB','Location','SouthEast');
xlabel('Support Number (K)','fontsize',14); 
ylabel('False Alarm Probability (%)','fontsize',14); 
title('False Alarm Probability vs Support Number','fontsize',12);
