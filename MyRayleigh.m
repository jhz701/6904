% THIS FILE IS COPIED FROM THE ADAP. FILTERING REFERENCE PROJECT
% ALL CREDIT GOES TO THE ORIGINAL AUTHOR

%--------------------------------------------------------------------------
% Flat fading channel
% Generate Rayleigh fading with Clarke' Model 
%return channel impulse response h, coherence time Tc, and symble period Ts
%
%GSM in Suburban environment, according to textbook Table5.1
%according to textbook equation 5.39 Bc>Bs ==>5ds<Ts or equation 5.42 Ts>>ds
%according to textbook equation 5.47 Ts<<Tc
%so ds<<Ts<<Tc ==> ds << Coeff*vc / (velocity*fc)
%suppose Ts=1/bandwidth=5us
% In Suburban environment, we choose ds=300ns, Coeff*vc/(velocity*fc)~=1ms
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function [h,Tc,Ts]=Rayleigh(datalen, velocity)
% datalen = 1000000;
% velocity = 20*10^3/3600;
velocity = velocity*10^3/3600;       %120 km/h
fc = 1.8*10^9;                  %GSM 1.8GHz
bandwidth = 200*10^3;           %200KHz
%------------------------
%for simulate the setting in Rappaport textbook Figure 6.58
% fc = 0.85*10^9;
% bandwidth = 24*10^3;
%------------------------

vc = 3*10^8;                    %300000 km/s
Ts = 1/bandwidth;               %suppose Nyquist pulse shape

Coeff=9/16/pi;                    %according to Rappaport's "wireless communications" P204, equation 5.40.c,
%Coeff=0.423;                    %according to Rappaport's "wireless communications" P204, equation 5.40.a, 5.40.b, 5.40.c
fs = 1/Ts;
fd = velocity*fc/vc;
Tc = Coeff/fd;                      %coherent time Tc

%refer to textbook Table 5.1, choose ds = 300ns
ds = 300 *10^(-9);
Bc = 1/5/ds;        %according to textbook equation 5.39

if Bc>bandwidth
    %disp('it is a flat fading channel');
else
    disp('it is a frequency selective fading channel');
end

% Doppler Spectrum
%Niter=Nint/(Tc/Ts), Nv=Nint/fs*fd ==> Niter=Nv (Nv means valued number)
%according to Rappaport's "wireless communications" P204, equation 5.40.c,
%Tc=0.423/fm is a popular rule of thumb. So, Nv=Niter*0.423
%Nv = Niter*Coeff;
Nv=datalen/fs*fd;
%here set the resolution rn for sqrtpsd, its purpose is to ensure rn!=1 
%and the resulted Nint samples after ifft is not the total channel samples,
%that is, we may either use only part of the produced Nint samples in our simulation or use
%several times of Nint samples by Niter in main program.

rn = floor((Nv-1)/2);                      %there are 2*rn+1 points (include f=0) have value
sqrtpsd=1./(1-( [-rn:1:rn]/(Nv/2) ).^2).^.25;   %since -rn and rn have infinite value, we use rn-1

% Generate complex Gaussian
ampl=randn(1,2*rn+1)+j*randn(1,2*rn+1);

%sqrtpsd=ones(1,15);
y=ampl.*sqrtpsd;
%y=sqrtpsd;

%below sentences for fftshift, although we may not necessary to do this for Rayleigh amplitude
%Nint = ceil(Nv*fs/fd);            %get how many points in [-pi, pi), we also use Nint-point ifft
pos=y(rn+1:2*rn+1);
neg=y(1:rn);
shifted=[pos,zeros(1,datalen-(2*rn+1)),neg];

h =  ifft(shifted); % h is channel impulse response   
%figure;plot(abs(h));

% Normalize channel impulse average energy to 1
h = sqrt(datalen)*h./sqrt(sum(sqrtpsd.^2)/(datalen/2));
%sum(abs(h).^2)/length(h)

% The envelope is Rayleigh distributed
Rayleigh = abs(h);
phase = atan2(imag(h),real(h));

%--------------------------------
%below are for debug
% close all;
% figure;plot(Rayleigh);
% figure;plot(phase);
% figure;plot(Rayleigh(1:10000));
% figure;plot(phase(1:10000));
% figure; hist(Rayleigh,100);
% figure; hist(phase,100);
%--------------------------------

