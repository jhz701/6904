clear all;
close all;
%%
setup = struct;
setup.fs = 100e9;
setup.regSNR   = 10;            % dB10
setup.fadeType = 'flat';
setup.rayleighVelocity= 0;
setup.flatAttenuation = 0;
setup.multiPathSetup = [[0.0,1e-9];[0.0,2e-9];[0.0,3e-9]];
%% pulse gen
n = 10; %10th order derivative
fs = 100e9; %sampling frequency
fc = 5e9; % center frequency
pframe = 1e-9;% 10ns frame
an = 2e-114;% scaling factor
frame_num = 5;% 100 frames of data
RBW = 1e-6/(pframe*frame_num); %resolution bw in MHz
pulse = gaussian_pulse(n,fs,fc,pframe,an);

sig = [];
padding = round((10e-9 - pframe)*fs);
for i = 1:frame_num
    sig = [sig pulse zeros(1,padding)];
end
plot(sig);
%% Run it thru a channel
sigout_rx = channel(sig,setup);
hold off;
plot(sigout_rx);
% Envelope Detection
hold on;
plot(abs(hilbert(sigout_rx)))