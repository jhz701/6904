clc
clear

SER = zeros(1,15);
SERN = zeros(1,15);
%%
for i = 1:1:15
    setup = struct;
setup.BW               = 2e9;       % BW of the transmitted signal
setup.fs               = 100e9;     % Testbench Sampling Frequency
setup.fc               = 5e9;       % Center Frequency
setup.tframe           = 10e-9;     % Frame Duration (s)
setup.tguard           = 3.5e-9;    % Anti-Multipath Guard Duration (s)
setup.tstep            = 0.1e-9;    % Data Step (s)
setup.tpulse           = 1.5e-9;    % Pulse Length (s)
setup.pulse_order      = 10;        % n-th Order Gaussian Pulse
setup.pulse_an         = 2e-4;      % Amplitude Scaling Factor
setup.sigma_sync       = 0.001;     % sync pulse position uncertainty being 1*(1/fs)
setup.sigma_data       = 0.001;     % data pulse position uncertainty being 1*(1/fs)
setup.sigma_power      = 0.01;      % pulse data uncertainty being 1% nominal value
%setup.SNR              = 18;        % dB10
setup.fadeType         = 'flat';    %
setup.rayleighVelocity = 0;         
setup.flatAttenuation  = 0;
setup.multiPathSetup   = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
setup.mode_bw          = 1;         % Black & White Mode
setup.fspl_distance_m  = 1;         % FSPL
    setup.SNR = i*0.5+12; % 15dB to 20dB
    [SER(i) SERN(i)]=system_top(setup);
    
end
x = 1:1:15;
SNR = x*0.5+12;
semilogy(SNR,SER,'*-');
title('SER Variation V.S. SNR');
xlabel('SNR(dB)')
ylabel('Symbol Error Rate');
grid on
%%
for i = 1:1:15
    setup = struct;
setup.BW               = 2e9;       % BW of the transmitted signal
setup.fs               = 100e9;     % Testbench Sampling Frequency
setup.fc               = 5e9;       % Center Frequency
setup.tframe           = 10e-9;     % Frame Duration (s)
setup.tguard           = 3.5e-9;    % Anti-Multipath Guard Duration (s)
setup.tstep            = 0.1e-9;    % Data Step (s)
setup.tpulse           = 1.5e-9;    % Pulse Length (s)
setup.pulse_order      = 10;        % n-th Order Gaussian Pulse
setup.pulse_an         = 2e-4;      % Amplitude Scaling Factor
setup.SNR              = 20;        % 15dB to 20dB
setup.sigma_data       = 0.001;     % data pulse position uncertainty being 1*(1/fs)
setup.sigma_power      = 0.01;      % pulse data uncertainty being 1% nominal value
%setup.SNR              = 18;        % dB10
setup.fadeType         = 'flat';    %
setup.rayleighVelocity = 0;         
setup.flatAttenuation  = 0;
setup.multiPathSetup   = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
setup.mode_bw          = 1;         % Black & White Mode
setup.fspl_distance_m  = 1;         % FSPL
setup.sigma_sync       = 0.1*i;     % sync pulse position uncertainty being 1*(1/fs)
    [SER(i) SERN(i)]=system_top(setup);
    
end

x = 1:1:15;
sigma_sync = 0.1*x*(1/setup.fs)*1e12; % standard deviation in ps
semilogy(sigma_sync,SER,'*-');
title('SER Variation V.S. Uncertainty in Sync Pulse');
xlabel('Standard Deviation(ps)');
ylabel('Symbol Error Rate');
grid on
%% 
for i = 1:1:15
    setup = struct;
setup.BW               = 2e9;       % BW of the transmitted signal
setup.fs               = 100e9;     % Testbench Sampling Frequency
setup.fc               = 5e9;       % Center Frequency
setup.tframe           = 10e-9;     % Frame Duration (s)
setup.tguard           = 3.5e-9;    % Anti-Multipath Guard Duration (s)
setup.tstep            = 0.1e-9;    % Data Step (s)
setup.tpulse           = 1.5e-9;    % Pulse Length (s)
setup.pulse_order      = 10;        % n-th Order Gaussian Pulse
setup.pulse_an         = 2e-4;      % Amplitude Scaling Factor
setup.SNR              = 20;        % 15dB to 20dB
setup.sigma_sync       = 0.001;     % data pulse position uncertainty being 1*(1/fs)
setup.sigma_power      = 0.01;      % pulse data uncertainty being 1% nominal value
%setup.SNR              = 18;        % dB10
setup.fadeType         = 'flat';    %
setup.rayleighVelocity = 0;         
setup.flatAttenuation  = 0;
setup.multiPathSetup   = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
setup.mode_bw          = 1;         % Black & White Mode
setup.fspl_distance_m  = 1;         % FSPL
setup.sigma_data       = 0.1*i;     % sync pulse position uncertainty being 1*(1/fs)
    [SER(i) SERN(i)]=system_top(setup);
    
end

x = 1:1:15;
sigma_data = 0.1*x*(1/setup.fs)*1e12; % standard deviation in ps
semilogy(sigma_data,SER,'*-');
title('SER Variation V.S. Uncertainty in Data Pulse');
xlabel('Standard Deviation(ps)');
ylabel('Symbol Error Rate');
grid on
%%
for i = 1:1:15
    setup = struct;
setup.BW               = 2e9;       % BW of the transmitted signal
setup.fs               = 100e9;     % Testbench Sampling Frequency
setup.fc               = 5e9;       % Center Frequency
setup.tframe           = 10e-9;     % Frame Duration (s)
setup.tguard           = 3.5e-9;    % Anti-Multipath Guard Duration (s)
setup.tstep            = 0.1e-9;    % Data Step (s)
setup.tpulse           = 1.5e-9;    % Pulse Length (s)
setup.pulse_order      = 10;        % n-th Order Gaussian Pulse
setup.pulse_an         = 2e-4;      % Amplitude Scaling Factor
setup.SNR              = 20;        % 15dB to 20dB
setup.sigma_sync       = 0.001;     % data pulse position uncertainty being 1*(1/fs)
setup.sigma_data       = 0.001;      % pulse data uncertainty being 1% nominal value
%setup.SNR              = 18;        % dB10
setup.fadeType         = 'flat';    %
setup.rayleighVelocity = 0;         
setup.flatAttenuation  = 0;
setup.multiPathSetup   = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
setup.mode_bw          = 1;         % Black & White Mode
setup.fspl_distance_m  = 1;         % FSPL
setup.sigma_power      = 0.01*i;     % sync pulse position uncertainty being 1*(1/fs)
    [SER(i) SERN(i)]=system_top(setup);
    
end

x = 1:1:15;
sigma_power = 0.01*x*100; % standard deviation with repect to 1
semilogy(sigma_power,SER,'*-');
title('SER Variation V.S. Variance in Transmitted Power');
xlabel('Standard Deviation(%)');
ylabel('Symbol Error Rate');
grid on