%% symbol gen
n = 10; %10th order derivative
fs = 100e9; %sampling frequency
fc = 5e9; % center frequency
frame = 10e-9;% 10ns frame
an = 1e-114;% scaling factor
frame_num = 1;% 100 frames of data
RBW = 1e-6/(frame*frame_num); %resolution bw in MHz
pulse_duration = 1.5e-9;
pulse = [];
random_data = [];
impairment = struct;
tguard = 3.5e-9;
tstep = 100e-12;
for i = 1:frame_num
    data = randi(32)-1;
    data_bits = de2bi(data,5,'left-msb');
    impairment.datapulse = round(normrnd(0,10))*(1/fs);% datapulse uncertainty
    impairment.syncpulse = abs(round(normrnd(0,1))*(1/fs));% syncpulse uncertainty
    impairment.power = abs(normrnd(1,0.01));
    pulse = [pulse DMPPM_symbol_gen(data_bits,tguard,tstep,frame,n,fs,fc,pulse_duration,an,impairment)];
    random_data = [random_data data];
end
time = 0:1/fs:frame_num*frame-1/fs;
%% original pulse plot
figure
plot(time,pulse);
title('Gaussian Pulse');
xlabel('Time(s)');
ylabel('Amplitude');
%% pulse after path loss
r = 1; %distance is 1m
pulse_fspl = FSPL(pulse,r,fs);
figure;
plot(time,pulse_fspl);
title('Gaussian Pulse after FSPL')
xlabel('Time(s)');
ylabel('Amplitude');
%% PSD plot
figure
L=length(pulse);
X = fftshift(fft(pulse));
Pxx=X.*conj(X)/(L*L); %computing power with proper scaling
Pxx = Pxx/50; % power is defined with a 50 ohm load
f = fs*(-L/2:1:L/2-1)/L; %Frequency Vector
f = f(L/2+1:end);
Pxx = 2*Pxx(L/2+1:end); % positive freqency
PSD1 = Pxx*1e6*1e3/(1/(frame*frame_num)); % PSD has the unit of dBm/MHz
s = stem(f*1e-9,10*log10(PSD1));
s.BaseValue = -400;
title('PSD of the Original Pulse');
xlabel(['Frequency (GHz), RBW=',num2str(RBW),'MHz'])
ylabel('Magnitude dBm/MHz');
xlim([0 10.6]);
ylim([-300 -30]);
%% FSPL PSD plot
figure
L=length(pulse_fspl);
X = fftshift(fft(pulse_fspl));
Pxx=X.*conj(X)/(L*L); %computing power with proper scaling
Pxx = Pxx/50; % power is defined with a 50 ohm load
f = fs*(-L/2:1:L/2-1)/L; %Frequency Vector
f = f(L/2+1:end);
Pxx = 2*Pxx(L/2+1:end); % positive freqency
PSD2 = Pxx*1e6*1e3/(1/(frame*frame_num)); % PSD has the unit of dBm/MHz
s = stem(f*1e-9,10*log10(PSD2));
s.BaseValue = -400;
title('PSD of FSPL pulse');
xlabel(['Frequency (GHz), RBW=',num2str(RBW),'MHz'])
ylabel('Magnitude dBm/MHz');
xlim([0 10.6]);
ylim([-300 -30]);
%% Sanity check
semilogx(f*1e-9,10*log10(PSD1./PSD2));
title('Path Loss');
xlabel(['Frequency (GHz), RBW=',num2str(RBW),'MHz'])
ylabel('Path Loss dBm/MHz');