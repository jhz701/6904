close all;
clear all;
clc;

%--------------------------------------------------------------------------
%Set parameters
%There are three places to set the parameters:
%default setting in main file, default setting in playdemo file, and user
%setting in playdemo file
%--------------------------------------------------------------------------
Max_dB = 10;							%total 11 dB, begin from 0dB
modtype = 'psk';
M=4;									% MPSK, M=4
gray_encode = 1;
VarChan = 'AWGN';
Tr_pctg = 0.08;							%training percentage, default use 8%
plot_const = 1;
ebn0_for_plot = round(Max_dB/2);		%default use 6th dB in the [0:Max_dB]
eq_alg = 'LMS';
ResetBeforeFiltering = 0;
training_mode = 'training_only';		%decision_directed or training_only
Ndata = 200000;							%to limit 1000000 samples for matlab ptocessing
Test_image = 1;
velocity = 5;				%5 km/hr, set default velocity for frequency selective fading

k      = log2(M);
ebn0DB = 0:3:3*Max_dB;
ebn0   = 10.^(ebn0DB/10);
esn0   = k*ebn0;

figure(1);
subplot(1,3,1);
Data=randint(1,Ndata,M);
im = imread('cxk.bmp');
imshow(im, 'InitialMagnification','fit');
drawnow
[Data, row_im, col_im, third_im] = image2data(im, M);
Ndata = length(Data);

[h,Tc,Ts,Lc]=MyRayleighPDP(100000, velocity);
Maxpercoh = floor(Tc/Ts);

Nonetrain = ceil(Tr_pctg * Maxpercoh);      %number of one time training, actually Nonetrain is calculated by floor(SamplesPerCoh/10)
Nonedata = Maxpercoh - Nonetrain;

Niter = ceil(Ndata/Nonedata);				%number of interation for get a statistical avarege
datalen = Niter*(Nonedata+Nonetrain);		%to get 1000000
Data_Ins = [Data, zeros(1, Niter*Nonedata - Ndata)];    %insert data here to make Niter an integer

Transmit = zeros(1,datalen);
for index = 0: Niter-1,
	Ttr = randint(1,Nonetrain,M);
	%Ttr = ones(1,Nonetrain);
	Transmit(index*Maxpercoh+1:index*Maxpercoh+Nonetrain) = Ttr;
	Transmit(index*Maxpercoh+Nonetrain+1:index*Maxpercoh+Maxpercoh) = Data_Ins(index * Nonedata +1 : index * Nonedata + Nonedata);
end

grayencod = bitxor(0:M-1, floor((0:M-1)/2));
[dummy graydecod] = sort(grayencod); graydecod = graydecod - 1;

% Gray encode symbols
Transmit_gray = grayencod(Transmit+1);

% Modulation
S = MPSK_mod(Transmit_gray, M);

%--------------------------------------------------------------------------
%all other processing including producing channel, channel estimation,
%channel adjustment, equlization, plot constellation, demodulation, and BER plot
%--------------------------------------------------------------------------
%Initialization
ser=zeros(size(ebn0));
ber=zeros(size(ebn0));
ser_com=zeros(size(ebn0));  %ser_com is without channel estimation, for compare with ser
ber_com=zeros(size(ebn0));
%uniform the noise power by 1/var=SNR=Es/(N0/2)=2*k*ebn0
std=(1/2/k./ebn0).^0.5;
%std=std/2^.5;    %sqrt(2) for complex Gaussian variance
nWeights = 8;

stepsize = 0.01
eqObj = lineareq(nWeights, lms(stepsize)); % Create an equalizer object.
eqObj.SigConst = MPSK_mod([0:M-1],M); % Set signal constellation.

eqObj.ResetBeforeFiltering = ResetBeforeFiltering;

for i_ebn0 = 1:length(ebn0),
	disp(sprintf('共有 %d 组ebn0, 当前在第 %d 组, ebn0 = %d dB ' , length(ebn0), i_ebn0, ebn0DB(i_ebn0)));

	%produce channel
	[h,Tc,Ts,Lc]=MyRayleighPDP(datalen, velocity);

	%pass fading channel
	Fading  = zeros(1, length(S)+Lc-1);
	for i_tap = 1:Lc,
		Si(i_tap,:) = [zeros(1,i_tap - 1), S, zeros(1,Lc - i_tap)];
		hi(i_tap,:) = [h(i_tap,:), zeros(1,Lc-1)];
		temp = Si(i_tap,:) .* hi(i_tap,:);
		Fading = Fading+temp;
	end
	Fading = Fading(1:length(S));

	%add AWGN
	Z = std(i_ebn0)*( randn(1,datalen)+j*randn(1,datalen) );
	R = Fading + Z;

	%Begin Channel estimation and adjustment
	Sa = [];
	Ra = [];
	Rb = [];
	for index = 0:Niter-1,
		Rtr = R(index * Maxpercoh +1 : index * Maxpercoh + Nonetrain);
		Str = S(index * Maxpercoh +1 : index * Maxpercoh + Nonetrain);
		Rdata = R(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);
		Sdata = S(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);
		Sdata_wo_mod = Transmit(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);

		if eqObj.ResetBeforeFiltering
			eqObj.weights  = zeros(size(eqObj.weights));
		end

		[Radj_tr,Receive_data,err_eq] = equalize(eqObj, Rtr, Str); % Equalize.
		%[y, yd, err] = equalize(eq1, [rxSamples0(1:nTrain+eqDelay/eq1.nSampPerSym)], xTrain);
		Radj = filter(eqObj.Weights,1,Rdata);
		Ra = [Ra, Radj];        %Received data after equlization and phase adjustment
		Rb = [Rb, Rdata];       %Received data before equlization
		Sa = [Sa, Sdata];       %Sent data before fading channel

		if (i_ebn0-1 == ebn0_for_plot);
			weights = eqObj.weights;
			Constellation_FSF(Sdata, Rdata, Radj, Sdata_wo_mod, M, gray_encode, err_eq, weights, ebn0_for_plot, index+1);
		end
	end

	%demodulation
	Receive = MPSK_demod(Ra, Sa, M);
	Receive_wo = MPSK_demod(Rb, Sa, M);
	% Gray decode message
	Receive = graydecod(Receive+1);
	Receive_wo = graydecod(Receive_wo+1);
	
	%to truncate the data to original length, note we do the
	%process above: Data = [Data, zeros(1, Niter*Nonedata - Ndata)];
	Receive = Receive( 1 : Ndata );     %k is the bits per symbol
	Receive_wo = Receive_wo( 1 : Ndata );
	
	%calculate ber
	[number(i_ebn0),ber(i_ebn0)] = biterr(Receive,Data);
	[numser(i_ebn0),ser(i_ebn0)] = symerr(Receive,Data);
	[number(i_ebn0),ber_wo(i_ebn0)] = biterr(Receive_wo,Data);
	[numser(i_ebn0),ser_wo(i_ebn0)] = symerr(Receive_wo,Data);

	if(i_ebn0-1==ebn0_for_plot)
		figure(1);
		subplot(1,3,2);
		ima_wo = data2image(Receive_wo, row_im, col_im, third_im, M);
		ima_wo = uint8(ima_wo);
		%f_rcv = figure;
		imshow(ima_wo,'InitialMagnification','fit');
		%set(f_rcv, 'name', '接收到的图像');
		drawnow
		subplot(1,3,3);
		ima = data2image(Receive, row_im, col_im, third_im, M);
		ima = uint8(ima);
		%f_adj = figure;
		imshow(ima,'InitialMagnification','fit');
		%set(f_adj, 'name', '均衡后的图像');
		drawnow
	end
end
%plot BER of flat fading
BER_FSF(ebn0DB, ber, ber_wo, ser, ser_wo, modtype, M);