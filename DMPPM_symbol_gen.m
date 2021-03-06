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
function sync_data_pulse = DMPPM_symbol_gen(data_word,tguard,tstep,frame,n,fs,fc,pulse_duration,an,impairment)
    global DEBUG_PRINT_ENABLE;
    M = 5; %bits/symbol
    time = 0:1/fs:frame-1/fs; % digitized time
    data_position_uncertainty = 0:1/fs:impairment.datapulse; % pulse uncertainty digitized
    sync_position_uncertainty = 0:1/fs:impairment.syncpulse; % sync pulse uncertainty
    sync_data_pulse = zeros(1,length(time));
    tstep_sampled = 0:1/fs:tstep-1/fs;
    tguard_sampled = 0:1/fs:tguard-1/fs;
    pulse_duration_sampled = 0:1/fs:pulse_duration-1/fs;
    sync_data_pulse(length(sync_position_uncertainty):length(sync_position_uncertainty)+length(pulse_duration_sampled)-1) = gaussian_pulse(n,fs,fc,pulse_duration,impairment.power*an);%sync pulse
    %for i = M:-1:1
    %    data_dec = data_dec + data_bits(i)*2^(i-1);
    %end
    data_dec = data_word;
    nd_start = (length(tguard_sampled)+length(tstep_sampled)*data_dec                               )+length(data_position_uncertainty)  -length(sync_position_uncertainty);
    nd_end   = (length(tguard_sampled)+length(tstep_sampled)*data_dec+length(pulse_duration_sampled))+length(data_position_uncertainty)-1-length(sync_position_uncertainty);
    if(DEBUG_PRINT_ENABLE)
        fprintf("Actual %d\n", nd_start);
    end
    sync_data_pulse(nd_start:nd_end) = gaussian_pulse(n,fs,fc,pulse_duration,an*impairment.power);
   
end