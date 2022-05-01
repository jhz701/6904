tpulse = 1e-9;
tframe = 10e-9;
fs     = 100e9;
fc     = 5e9; % center frequency
n      = 10;
an     = 2e-114;% scaling factor
pulselet = gaussian_pulse_fast(n,fs,fc,tpulse,an);
pulse = [zeros(1,fs*(tframe-tpulse)/2) pulselet zeros(1,fs*(tframe-tpulse)/2)];
figure();
plot(pulse);
