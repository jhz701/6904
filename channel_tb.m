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
fprintf("S1: Image Encode... ");
image = imread('Lenna.bmp');
[img_data, row_im, col_im, third_im] = image2data(im2gray(image),2);
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

n = 10; %10th order derivative
fs = 100e9; %sampling frequency
fc = 5e9; % center frequency
frame = 10e-9;% 10ns frame
an = 2e-114;% scaling factor
% frame_num = length(data_test);% frames of data
% frame_num = 100;
frame_num = length(img_data_32);
RBW = 1e-6/(frame*frame_num); %resolution bw in MHz
pulse_duration = 1.5e-9;% duration for each pulse
%sigma_sync = 0.1;% sync pulse position uncertainty being 1*(1/fs)
%sigma_data = 0.1;% data pulse position uncertainty being 1*(1/fs)
%sigma_power = 0.01;% pulse data uncertainty being 1% nominal value
sigma_sync = 1;% sync pulse position uncertainty being 1*(1/fs)
sigma_data = 1;% data pulse position uncertainty being 1*(1/fs)
sigma_power = 0.01;% pulse data uncertainty being 1% nominal value
tguard = 3.5e-9;% multipath guard time
tstep = 0.1e-9;% data step
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
npulse     = round(frame*fs);
nstep_sync = pulse_duration/2*fs;
nstep_tgl  = (tguard)*fs;
nstep_data = (tstep*31*fs);
nstep_tgr  = (frame*fs)-nstep_sync-nstep_tgl-nstep_data;
dtx        = zeros(1, frame_num);
progress   = 0;
pulse = [];
pattern = [];

parfor i = 1:frame_num
    %progress = progress+1;
    %if(progress==50)
    %    fprintf("%d ", i);
    %    progress = 0;
    %end
    % data = randi(32)-1;
    data = double(img_data_32(i));
    dtx(i) = data;
    %if(DEBUG_PRINT_ENABLE)
    %    fprintf("DB@%d:\t%X\n",i,data);    
    %end
    impairment = struct;
    impairment.datapulse =     round(normrnd(0,sigma_data))*(1/fs);  % datapulse timing uncertainty
    impairment.syncpulse = abs(round(normrnd(0,sigma_sync))*(1/fs)); % syncpulse timing uncertainty
    impairment.power     = abs(normrnd(1,sigma_power)); % pulse power uncertainty
    pulse = [pulse (DMPPM_symbol_gen(data,tguard,tstep,frame,n,fs,fc,pulse_duration,an,impairment))];
    
    patternlet = [[32 nstep_sync]' [33 nstep_tgl]' [data nstep_data]' [34 nstep_tgr]'];
    pattern = [pattern patternlet];
end
toc
tic
pulse = FSPL(pulse,r,fs);
toc

%% Run it thru a channel
tic
fprintf("S3: Channel Model... ");
sigout_rx = channel(pulse,setup);
sigout_hilbert = abs(hilbert(sigout_rx));

% When testing, we can first force the TDC to start at a point where it's
% desynced. Transmit a load of random data encoded using DMPPM, and see how
% long it takes to recover to the synced state.
toc
%% TDC Test
tic
fprintf("S4: RX... ");
sigout_rx_q = hysteresis(lowpass(sigout_rx, 0.1), 2e-4, 1e-4);
dso = TDC_advanced(sigout_rx_q, pattern, fs, tstep, tguard/2, tguard/2, frame);
toc
drx       = (dso(1,:) - 35);
drx_valid = (dso(2,:) == 1);
dtrx_difference = find(drx~=dtx);
ber = (length(dtrx_difference)/frame_num);
fprintf("TRX cycle finished. Words sent: %d, BER: %e\n", frame_num, ber);

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
imshow(im2gray(image));
title('Original');
subplot(1,2,2);
imshow(uint8(img_rx));
title('Received');

