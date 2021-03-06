clear all;
close all;

global DEBUG_PRINT_ENABLE;
DEBUG_PRINT_ENABLE = 0;
%% SIMULATION SETUP
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
setup.SNR              = 18;        % dB10
setup.fadeType         = 'flat';    %
setup.rayleighVelocity = 0;         
setup.flatAttenuation  = 0;
setup.multiPathSetup   = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
setup.mode_bw          = 1;         % Black & White Mode
setup.fspl_distance_m  = 1;         % FSPL


%% S1 Encode Image
tic % -- S1 Timing
fprintf("S1: Image Encode... ");
image = imread('Lenna.bmp');
if(setup.mode_bw)
    image = im2gray(image);
end
[img_data, row_im, col_im, third_im] = image2data(image,2);
% Calculate padding to make the total bit count % 5 = 0
orig_len   = length(img_data);
target_len = ceil(orig_len/5);
pad_len    = target_len*5 - orig_len;
% Serialize
img_data    = [img_data zeros(1,pad_len)];
img_data_32 = uint8(zeros(1,target_len));
for i=1:target_len
    word = img_data((i-1)*5+1)*16+img_data((i-1)*5+2)*8+img_data((i-1)*5+3)*4+img_data((i-1)*5+4)*2+img_data((i-1)*5+5);
    img_data_32(i) = word;
end
toc % -- S1 Timing

%% S2 symbol gen
tic % -- S2 Timing
fprintf("S2: Symbol Gen... ");
data_test = [0 3 7 11 15 19 23 27 31];

n      = setup.pulse_order; % 10th order derivative
fs     = setup.fs;          % sampling frequency
fc     = setup.fc;          % center frequency
tframe = setup.tframe;      % 10ns frame
tguard = setup.tguard;      % multipath guard time
tstep  = setup.tstep;       % data step
an     = setup.pulse_an;    % scaling factor

nframe = length(img_data_32);
% nframe = 100;
RBW    = 1e-6/(tframe*nframe); %resolution bw in MHz
tpulse = setup.tpulse;      % duration for each pulse
%sigma_sync = 0.1;% sync pulse position uncertainty being 1*(1/fs)
%sigma_data = 0.1;% data pulse position uncertainty being 1*(1/fs)
%sigma_power = 0.01;% pulse data uncertainty being 1% nominal value

random_data = [];

% Generate a separate stream for locking dection
% Region Type
% 0~31: data code
% 32:   Sync
% 33:   tgl, Left Guard
% 34:   tgr, Right Guard
% todo: encode noidealities into this system
% The pattern is encoded in this way to better utilize the instruction cache
npulse     = round(tframe*fs);
nstep_sync = tpulse/2*fs;
nstep_tgl  = (tguard)*fs;
nstep_data = (tstep*31*fs);
nstep_tgr  = (tframe*fs)-nstep_sync-nstep_tgl-nstep_data;
dtx        = zeros(1, nframe);
progress   = 0;
signal_tx  = [];
pattern    = [];
% impair_record_tjdp = [];
% impair_record_tjsp = [];
% impair_record_pj   = [];
parfor i = 1:nframe
    data = double(img_data_32(i));
    dtx(i) = data;
    %if(DEBUG_PRINT_ENABLE)
    %    fprintf("DB@%d:\t%X\n",i,data);    
    %end
    impairment           = struct;
    impairment.datapulse =     round(normrnd(0,sigma_data))*(1/fs);  % datapulse timing uncertainty
    impairment.syncpulse = abs(round(normrnd(0,sigma_sync))*(1/fs)); % syncpulse timing uncertainty
    impairment.power     = abs(normrnd(1,sigma_power));              % pulse power uncertainty
    signal_tx = [signal_tx (DMPPM_symbol_gen_fast(data,tguard,tstep,tframe,n,fs,fc,tpulse,an,impairment))];
%     impair_record_tjdp = [impair_record_tjdp impairment.datapulse];
%     impair_record_tjsp = [impair_record_tjsp impairment.syncpulse];
%     impair_record_pj   = [impair_record_pj   impairment.power    ];
    patternlet = [[32 nstep_sync]' [33 nstep_tgl]' [data nstep_data]' [34 nstep_tgr]']; % for TDC's reference to decide whether it is locked to sync pulse or not, only for the purpose of simulation
    pattern = [pattern patternlet];
end
toc % -- S2 Timing

%% Run it thru a channel
tic % -- S3 Timing
fprintf("S3: Channel Model... ");
signal_post_fspl = FSPL(signal_tx, setup.fspl_distance_m, setup.fs);

snr = 10^(setup.SNR/10);
sig_energy   = norm(signal_post_fspl(:))^2;
noise_energy = sig_energy*fs/(2*snr*setup.BW);
nosVar      = noise_energy/(length(signal_post_fspl(:))-1);
nosStd      = sqrt(nosVar);
% nos         = nosStd*randn(size(pulse_fast));
nos         = normrnd(0, nosStd, 1, length(signal_post_fspl));   
%sigout_rx      = channel(pulse_fast,setup);
signal_rx      = signal_post_fspl + nos;
% sigout_rx = pulse_fast_post_fspl;

% Passband 4~6
signal_post_bpf = bandpass(signal_rx, [4e9 6e9], fs);

signal_hilbert = abs(hilbert(signal_post_bpf));


% When testing, we can first force the TDC to start at a point where it's
% desynced. Transmit a load of random data encoded using DMPPM, and see how
% long it takes to recover to the synced state.
toc % -- S3 Timing
%% TDC Test
tic % -- S4 Timing
fprintf("S4: RX... ");
vth = 1.5e-4;
signal_rx_q = hysteresis(signal_hilbert, vth, 1e-4);
nsigout = length(signal_rx_q);
lead = 0;
signal_rx_q = [zeros(1,lead) signal_rx_q'];
signal_rx_q(nsigout:nsigout+lead) = [];
signal_rx_q = [signal_rx_q 0];
dso = TDC_advanced(signal_rx_q, pattern, fs, tstep, tguard-tpulse/2, tguard/2, tframe);
toc % -- S4 Timing

drx       = (dso(1,:) - 35);
drx_valid = (dso(2,:) == 1);
dtrx_difference = find(drx~=dtx);
bern = length(dtrx_difference);
ber  = (bern/nframe);
fprintf("TRX cycle finished. Words sent: %d, Error: %d, BER: %e\n", nframe, bern, ber);

%% Decode Image
tic % -- S5 Timing
fprintf('S5: Decode Image');
% Deserialize
img_data_recovered = zeros(1,target_len*5);
for i=1:target_len
    word = double(drx(i));
    for j=1:5
        b5 = floor(word/16);
        img_data_recovered((i-1)*5+j) = b5;
        word = (word - b5*16)*2;
    end
end

% Remove Padding
img_data_recovered(orig_len+1:orig_len+pad_len) = [];

parfor i=1:length(img_data_recovered)
    if(img_data_recovered(i)<0)
        img_data_recovered(i) = 0;
    end
    if(img_data_recovered(i)>1)
        img_data_recovered(i) = 1;
    end
end
img_rx = data2image(img_data_recovered, row_im, col_im, third_im, 2);

toc % -- S5 Timing

% Show image
figure();
subplot(1,2,1);
imshow(image);
title('Original');
subplot(1,2,2);
imshow(uint8(img_rx));
title('Received');

%% Plot
% figure();
% t = 0:1/fs:(nframe*tframe)-1/fs;
% subplot(4,1,1);
% plot(t,signal_tx);
% xlim([0 20e-9]);
% title('Transmitted')
% ylim([-0.1 0.1]);
% subplot(4,1,2);
% plot(t,signal_rx);
% xlim([0 20e-9]);
% title('Post-Channel');
% ylim([-4e-4 4e-4]);
% subplot(4,1,3);
% plot(t,signal_post_bpf);
% ylim([-4e-4 4e-4]);
% xlim([0 20e-9]);
% title('Post-BPF');
% subplot(4,1,4);
% hold on;
% plot(t,signal_hilbert);
% plot(t,sigout_rx_q*max(signal_hilbert));
% title('Post-Hilbert (Rectifier)');

%% Plot PSD

% figure();
% t = 0:1/fs:(nframe*tframe)-1/fs;
% [sigout_tx_psd, f] = PSD(signal_tx, fs);
% plot(f*1e-9, 10*log10(sigout_tx_psd));
% FCC_mask = [];
% hold on
% for i = 1:length(f)
%     if(f(i)<=960e6)
%         FCC_mask = [FCC_mask -41.3];
%     else if(f(i)>960e6 && f(i)<=1610e6)
%         FCC_mask = [FCC_mask -75.3];
%     else if(f(i)>1610e6 && f(i)<=1990e6)
%         FCC_mask = [FCC_mask -53.3];
%     else if(f(i)>1990e6 && f(i)<=3100e6)
%         FCC_mask = [FCC_mask -51.3];
%     else if(f(i)>3100e6 && f(i)<=10600e6)
%         FCC_mask = [FCC_mask -41.3];
%     else if(f(i)>10600e6)
%         FCC_mask = [FCC_mask -51.3];
%         end
%         end
%         end
%         end
%         end
%     end
% end
% plot(f*1e-9,FCC_mask);
% title('Transimitted Power VS FCC')
% legend('Transmitted Signal','FCC');
% xlabel('Frequency (GHz)');
% ylabel('Magnitude dBm/MHz');
% ylim([-250 -40]);
% 
% % Received signal VS after BPF
% figure
% [sigout_rx_psd, f] = PSD(signal_rx, fs);
% plot(f*1e-9, 10*log10(sigout_rx_psd));
% hold on
% [sigout_post_bpf_psd, f] = PSD(signal_post_bpf, fs);
% plot(f*1e-9, 10*log10(sigout_post_bpf_psd));
% title('Received Signal VS Bandpass Filered')
% xlabel('Frequency (GHz)');
% ylabel('Magnitude dBm/MHz');
% ylim([-250 -60]);
% legend('Received Signal','After BPF');