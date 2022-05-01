%% DMPPM_symbol_gen testbench

n = 10; %10th order derivative
fs = 100e9; %sampling frequency
fc = 5e9; % center frequency
frame = 10e-9;% 10ns frame
an = 2e-114;% scaling factor
sigma_sync = 1;% sync pulse position uncertainty being 1*(1/fs)
sigma_data = 1;% data pulse position uncertainty being 1*(1/fs)
sigma_power = 0.01;% pulse data uncertainty being 1% nominal value
tframe = 10e-9;% 10ns frame
tguard = 3.5e-9;% multipath guard time
tstep = 0.1e-9;% data step
RBW = 1e-6/(frame*frame_num); %resolution bw in MHz
tpulse = 1.5e-9;% duration for each pulse
t = 0:1/fs:frame-1/fs;

impairment = struct;
impairment.datapulse =0;  % datapulse timing uncertainty
impairment.syncpulse =0; % syncpulse timing uncertainty
impairment.power     =1; % pulse power uncertainty
pulse_ideal = DMPPM_symbol_gen_fast(16,tguard, tstep, tframe, n, fs, fc, tpulse, an, impairment);

impairment = struct;
impairment.datapulse =     round(normrnd(0,sigma_data))*(1/fs);  % datapulse timing uncertainty
impairment.syncpulse = abs(round(normrnd(0,sigma_sync))*(1/fs)); % syncpulse timing uncertainty
impairment.power     = abs(normrnd(1,sigma_power)); % pulse power uncertainty
fprintf("tj_dp= %e s  tj_sp= %e s  pj= %e\n", impairment.datapulse, impairment.syncpulse, impairment.power);

pulse_fast = DMPPM_symbol_gen_fast(16,tguard, tstep, tframe, n, fs, fc, tpulse, an, impairment);
figure();
hold off;
plot(t,pulse_ideal);
hold on;
plot(t,pulse_fast);