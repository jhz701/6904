%--------------------------------------------------------------------------
% Frequency selective fading channel
% Generate Rayleigh multipath fading with Clarke' Model 
%return channel impulse response h, coherence time Tc, symble period Ts,
%and channel length Lc

%GSM in urban environment
%GSM in Urban environment, according to textbook Table5.1
%according to textbook equation 5.39 Bc<Bs ==>5ds>Ts or equation 5.44 Ts<ds
%according to textbook equation 5.47 Ts<<Tc
%so Ts<ds & Ts<<Tc
%suppose Ts=1/bandwidth=5us
% In Urban environment, we choose ds=10us, Coeff*vc/(velocity*fc)~=1ms
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function [h,Tc,Ts,Lc]= RayleighPDP(datalen, velocity)
%datalen = 1000000;
%velocity = 5*10^3/3600;       %40 km/h, to ensure there are about 500-600 symbol during one coherence time
velocity = velocity*10^3/3600;       %120 km/h
fc = 1.8*10^9;                  %GSM 1.8GHz
vc = 3*10^8;                    %300000 km/s
bandwidth = 200*10^3;           %200KHz
Ts = 1/bandwidth;               %suppose Nyquist pulse shape

Coeff=9/16/pi;                    %according to Rappaport's "wireless communications" P204, equation 5.40.c,
%Coeff=0.423;                    %according to Rappaport's "wireless communications" P204, equation 5.40.a, 5.40.b, 5.40.c
fs = 1/Ts;
fd = velocity*fc/vc;
Tc = Coeff/fd;                      %coherent time Tc

%get delay spread by the model in textbook Figure 5.28, where ds=3.8us
%refer to textbook Table 5.1, choose ds = 10us
ds = 10 *10^(-6);
Bc = 1/5/ds;        %according to textbook equation 5.39
if Bc>bandwidth
    disp('it is a flat fading channel');
else
    %disp('it is a frequency selective fading channel');
    tau = ds*2/log(100);   %suppose it is a exponential decay, and decay to 1%, so exp(-t/tau) <= 0.01 ==> tau >= ln(100)/t
    Lc = ceil(ds*2/Ts)+1;    %channel length Lc, suppose Maximum Excess Delay is two times of ds as textbook Figure 5.10
end


% Decay const. of exponentially decaying ISI  = tau . e.g. 5*Ts.
% Length of channel response (decay to 1%) = Tm = 4.6*tau0 

% Doppler Spectrum
%Niter=Nint/(Tc/Ts), Nv=Nint/fs*fd ==> Niter=Nv (Nv means valued number)
%according to Rappaport's "wireless communications" P204, equation 5.40.c,
%Tc=0.423/fm is a popular rule of thumb. So, Nv=Niter*0.423
%Nv = Niter*Coeff;
Nv=datalen/fs*fd;       %Nv = Niter*Coeff;  
%here set the resolution rn for sqrtpsd, its purpose is to ensure rn!=1 
%and the resulted Nint samples after ifft is not the total channel samples,
%that is, we may either use only part of the produced Nint samples in our simulation or use
%several times of Nint samples by Niter in main program.

rn = max(0,floor((Nv-1)/2));                      %there are 2*rn+1 points (include f=0) have value, rn>=0
sqrtpsd=1./(1-( [-rn:1:rn]/(Nv/2) ).^2).^.25;   %since -rn and rn have infinite value, we use rn-1

temp=[];
%sqrtpsd=[1./(1-([-fd/fs*Nint+.5:1:fd/fs*Nint-.5]/(fd/fs*Nint)).^2).^.25];
for (index=1:Lc)
    ampl=randn(1,2*rn+1)+j*randn(1,2*rn+1);
    %ampl=randn(1,floor(2*Nint*fd/fs))+j*randn(1,floor(2*Nint*fd/fs));
    y = ampl.*sqrtpsd;
    %below sentences for fftshift, although we may not necessary to do this for Rayleigh amplitude
    %Nint = ceil(Nv*fs/fd);            %get how many points in [-pi, pi), we also use Nint-point ifft
    pos=y(rn+1:2*rn+1);
    neg=y(1:rn);
    shifted=[pos,zeros(1,datalen-(2*rn+1)),neg];

    fading =  ifft(shifted);
    temp(:,index) = fading';
end
% Normalize channel impulse average energy to 1
temp = sqrt(datalen)*temp./sqrt(sum(sqrtpsd.^2)/(datalen/2));

% scale by exponential PDP (Power delay profile)
alpha = 1/sqrt(sum(exp(-[0:Lc-1]*Ts/tau)));
h = conj(temp*diag(alpha^0.5*exp(-0.5*[0:Lc-1]*Ts/tau)))';

% The envelope is Rayleigh distributed
index=3;  % path index
Rayleigh = abs(h(index,:));
phase = atan2(imag(h(index,:)),real(h(index,:)));

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

