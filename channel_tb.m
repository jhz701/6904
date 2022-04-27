clear all;
close all;
%%
setup = struct;
setup.fs = 100e9;
setup.regSNR   = 10;            % dB10
setup.fadeType = 'flat';
setup.rayleighVelocity= 0;
setup.flatAttenuation = 0;
setup.multiPathSetup = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
%% symbol gen
data_test = [0 3 7 11 15 19 23 27 31];

n = 10; %10th order derivative
fs = 100e9; %sampling frequency
fc = 5e9; % center frequency
frame = 10e-9;% 10ns frame
an = 2e-114;% scaling factor
frame_num = length(data_test);% frames of data
RBW = 1e-6/(frame*frame_num); %resolution bw in MHz
pulse_duration = 1.5e-9;% duration for each pulse
impairment = struct;
sigma_sync = 1;% sync pulse position uncertainty being 1*(1/fs)
sigma_data = 1;% data pulse position uncertainty being 1*(1/fs)
sigma_power = 0.01;% pulse data uncertainty being 1% nominal value
tguard = 3.5e-9;% multipath guard time
tstep = 0.1e-9;% data step
r = 1; %transmitter and receiver are 1m away
random_data = [];
pulse = [];


% Generate a separate stream for locking dection
% Region Type
% 0~31: data code
% 32:   Sync
% 33:   tgl, Left Guard
% 34:   tgr, Right Guard

%patternlet = repelem([0],nstep_sync);
%patternlet = [patternlet repelem([1],round(nstep_tgl))];
%patternlet = [patternlet repelem([2],nstep_data)];
%patternlet = [patternlet repelem([3],nstep_tgr)];
% todo: encode noidealities into this system
% The pattern is encoded in this way to better utilize the instruction cache
nstep_sync = pulse_duration/2*fs;
nstep_tgl  = (tguard)*fs;
nstep_data = (tstep*31*fs);
nstep_tgr  = (frame*fs)-nstep_sync-nstep_tgl-nstep_data;
pattern    = [];

for i = 1:frame_num
    %data = randi(32)-1;
    data = data_test(i);
    fprintf("DB@%d:\t%X\n",i,data);
    data_bits = de2bi(data,5,'left-msb'); %random data gen and convert to binary
    impairment.datapulse = round(normrnd(0,sigma_data))*(1/fs);% datapulse uncertainty
    impairment.syncpulse = abs(round(normrnd(0,sigma_sync))*(1/fs));% syncpulse uncertainty
    impairment.power = abs(normrnd(1,sigma_power)); % pulse power uncertainty
    
    pulse = [pulse (DMPPM_symbol_gen(data_bits,tguard,tstep,frame,n,fs,fc,pulse_duration,an,impairment))]; 
    
    patternlet = [[32 nstep_sync]' [33 nstep_tgl]' [data nstep_data]' [34 nstep_tgr]'];
    pattern    = [pattern patternlet];

    % random_data = [random_data data];
end
figure
pulse = FSPL(pulse,r,fs);
plot(pulse);
% sig = [];
% padding = round((10e-9 - pframe)*fs);
% for i = 1:frame_num
%     sig = [sig pulse zeros(1,padding)];
% end
% plot(sig);
%% Run it thru a channel
figure(2);
%subplot(2,1,1);
sigout_rx = channel(pulse,setup);
%hold off;
plot(sigout_rx);
% Envelope Detection
figure(3);
yyaxis left;
sigout_hilbert = abs(hilbert(sigout_rx));
plot(sigout_hilbert);


%yyaxis right;
%plot(pattern);
%ylim([-1,4]);

% When testing, we can first force the TDC to start at a point where it's
% desynced. Transmit a load of random data encoded using DMPPM, and see how
% long it takes to recover to the synced state.

