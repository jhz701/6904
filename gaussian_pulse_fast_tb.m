tpulse = 1e-9;
tframe = 10e-9;
fs     = 100e9;
fc     = 5e9; % center frequency
n      = 10;
an     = 2e-114;% scaling factor
pulselet  = gaussian_pulse_fast(n,fs,fc,tpulse,an/9.5447e-111);
pulse_cmp = gaussian_pulse     (n,fs,fc,tpulse,an            );
figure();
hold off;
plot(pulselet);
hold on;
plot(pulse_cmp);
