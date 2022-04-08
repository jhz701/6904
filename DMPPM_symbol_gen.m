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
function sync_data_pulse = DMPPM_symbol_gen(data_bits,tguard,tstep,frame,n,fs,fc,pulse_duration,an)
    M = length(data_bits); %bits/symbol
    time = 0:1/fs:frame-1/fs; % digitized time
    sync_data_pulse = zeros(1,length(time));
    tstep_sampled = 0:1/fs:tstep-1/fs;
    tguard_sampled = 0:1/fs:tguard-1/fs;
    pulse_duration_sampled = 0:1/fs:pulse_duration-1/fs;
    sync_data_pulse(1:length(pulse_duration_sampled)) = gaussian_pulse(n,fs,fc,pulse_duration,an);%sync pulse
    data_dec = 0;
    for i = M:-1:1
        data_dec = data_dec + data_bits(i)*2^(i-1);
    end
    sync_data_pulse((length(tguard_sampled)+length(tstep_sampled)*data_dec):(length(tguard_sampled)+length(tstep_sampled)*data_dec+length(pulse_duration_sampled))-1) = gaussian_pulse(n,fs,fc,pulse_duration,an);
    

end