%% DMPPM_symbol_gen_fast
% April 30: AL. Modified to make sure that this version behaves identically 
% to the symbolic version

% n,fs,fc,pulse_duration.an are inputs inherited from function
% gaussian_pulse

% This fuction will generated a complete frame of 1 symbol transmission,
% with a sync pulse locating at the beginning and a data pulse locating at
% the position defined by data_bits and the corresponding step time

% data_bits is the data to be modulated, in the form of an array with
% 5 binary bits

% tstep is the step between two data pulse
% tguard is the minimum delay time between a sync pulse and a data pulse,
% used for avoiding multipath interference.

% frame is the duration of the entire symbol
% impairment: struct with power uncertainty and data&sync pulse position ucertainty
function sync_data_pulse = DMPPM_symbol_gen_fast(data_word, tguard, ...
    tstep, tframe, n, fs, fc, tpulse, an, impairment)
    
    global DEBUG_PRINT_ENABLE;
    time = 0:1/fs:tframe-1/fs; % digitized time
    npulse = tpulse*fs;
    nstep  = tstep*fs;
    nguard = tguard*fs;
    njitter_data_hat = round(impairment.datapulse*fs)+1; 
    njitter_sync_hat = round(impairment.syncpulse*fs)+1; 
    sync_data_pulse = zeros(1,length(time));              % Untouched positions are set to 0
    sync_data_pulse(njitter_sync_hat:njitter_sync_hat+npulse-1) = gaussian_pulse_fast(n,fs,fc,tpulse,impairment.power*an);%sync pulse
    nd_start = (nguard+nstep*data_word       )+njitter_data_hat  -njitter_sync_hat;
    nd_end   = (nguard+nstep*data_word+npulse)+njitter_data_hat-1-njitter_sync_hat;
    sync_data_pulse(nd_start:nd_end) = gaussian_pulse_fast(n,fs,fc,tpulse,an*impairment.power);
   
end