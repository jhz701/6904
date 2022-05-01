clear all;
close all;

global DEBUG_PRINT_ENABLE;
DEBUG_PRINT_ENABLE = 0;
%%
setup = struct;
setup.fs = 100e9;
setup.regSNR   = 10;            % dB10
setup.fadeType = 'flat';
setup.rayleighVelocity= 0;
setup.flatAttenuation = 0;
setup.multiPathSetup = [[0.1,1e-9];[0.2,2e-9];[0.3,3e-9]];
%% Encode Image
tic
mode_bw = 1;
fprintf("S1: Image Encode... ");
image = imread('Lenna.bmp');
if(mode_bw)
    image = im2gray(image);
end
[img_data, row_im, col_im, third_im] = image2data(image,2);
orig_len   = length(img_data);
target_len = ceil(orig_len/5);
pad_len    = target_len*5 - orig_len;
img_data   = [img_data zeros(1,pad_len)];
img_data_32 = uint8(zeros(1,target_len));
% Serialize
for i=1:target_len
    word = img_data((i-1)*5+1)*16+img_data((i-1)*5+2)*8+img_data((i-1)*5+3)*4+img_data((i-1)*5+4)*2+img_data((i-1)*5+5);
    img_data_32(i) = word;
end
toc

%% symbol gen
tic
fprintf("S2: Symbol Gen... ");
data_test = [0 3 7 11 15 19 23 27 31];

n      = 10; %10th order derivative
fs     = 100e9; %sampling frequency
fc     = 5e9; % center frequency
tframe = 10e-9;% 10ns frame
tguard = 3.5e-9;% multipath guard time
tstep  = 0.1e-9;% data step
an     = 2e-114;% scaling factor
%nframe = 100;
nframe = length(img_data_32);
RBW = 1e-6/(tframe*nframe); %resolution bw in MHz
tpulse     = 1.5e-9;% duration for each pulse
%sigma_sync = 0.1;% sync pulse position uncertainty being 1*(1/fs)
%sigma_data = 0.1;% data pulse position uncertainty being 1*(1/fs)
%sigma_power = 0.01;% pulse data uncertainty being 1% nominal value
sigma_sync = 0.5;% sync pulse position uncertainty being 1*(1/fs)
sigma_data = 0.5;% data pulse position uncertainty being 1*(1/fs)
sigma_power = 0.01;% pulse data uncertainty being 1% nominal value
r = 1; %transmitter and receiver are 1m away
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
pulse_fast = [];
pattern    = [];
impair_record_tjdp = [];
impair_record_tjsp = [];
impair_record_pj   = [];
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
    pulse_fast = [pulse_fast (DMPPM_symbol_gen_fast(data,tguard,tstep,tframe,n,fs,fc,tpulse,an/9.5447e-111,impairment))];
    impair_record_tjdp = [impair_record_tjdp impairment.datapulse];
    impair_record_tjsp = [impair_record_tjsp impairment.syncpulse];
    impair_record_pj   = [impair_record_pj   impairment.power    ];
    patternlet = [[32 nstep_sync]' [33 nstep_tgl]' [data nstep_data]' [34 nstep_tgr]'];
    pattern = [pattern patternlet];
end
toc
tic
pulse_fast = FSPL(pulse_fast,r,fs);
toc

%% Run it thru a channel
tic
fprintf("S3: Channel Model... ");
sigout_rx = channel(pulse_fast,setup);
sigout_hilbert = abs(hilbert(sigout_rx));

% When testing, we can first force the TDC to start at a point where it's
% desynced. Transmit a load of random data encoded using DMPPM, and see how
% long it takes to recover to the synced state.
toc
%% TDC Test
tic
fprintf("S4: RX... ");
vth = 1.2e-4;
sigout_rx_q = hysteresis(lowpass(sigout_rx, 0.1), vth, -vth);
nsigout = length(sigout_rx_q);
lead = 0;
sigout_rx_q = [zeros(1,lead) sigout_rx_q'];
sigout_rx_q(nsigout:nsigout+lead) = [];
dso = TDC_advanced(sigout_rx_q, pattern, fs, tstep, tguard-tpulse/2, tguard/2, tframe);
toc
drx       = (dso(1,:) - 35);
drx_valid = (dso(2,:) == 1);
dtrx_difference = find(drx~=dtx);
bern = length(dtrx_difference);
ber = (bern/nframe);
fprintf("TRX cycle finished. Words sent: %d, Error: %d, BER: %e\n", nframe, bern, ber);

%% Decode Image
tic
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

toc

% Show image
figure();
subplot(1,2,1);
imshow(image);
title('Original');
subplot(1,2,2);
imshow(uint8(img_rx));
title('Received');

