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
n = 10; %10th order derivative
fs = 100e9; %sampling frequency
fc = 5e9; % center frequency
frame = 10e-9;% 10ns frame
an = 2e-114;% scaling factor
frame_num = 5;% frames of data
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
for i = 1:frame_num
    data = randi(32)-1;
    data_bits = de2bi(data,5,'left-msb'); %random data gen and convert to binary
    impairment.datapulse = round(normrnd(0,sigma_data))*(1/fs);% datapulse uncertainty
    impairment.syncpulse = abs(round(normrnd(0,sigma_sync))*(1/fs));% syncpulse uncertainty
    impairment.power = abs(normrnd(1,sigma_power)); % pulse power uncertainty
    pulse = [pulse (DMPPM_symbol_gen(data_bits,tguard,tstep,frame,n,fs,fc,pulse_duration,an,impairment))];  
    random_data = [random_data data];
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
figure
sigout_rx = channel(pulse,setup);
%hold off;
plot(sigout_rx);
% Envelope Detection
figure
sigout_hilbert = abs(hilbert(sigout_rx));
hold on;
plot(sigout_hilbert);

