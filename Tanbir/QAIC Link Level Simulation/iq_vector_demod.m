function [ f_bb,xbb_I,xbb_Q,x_bb ] = iq_vector_demod( x,W,fMID,Tx,t,hb,ha,R,delamp,delphase,DCoffset,impairments )
%-------------------------------------------------------------------------
% This function performs IQ vector demodulation. The output baseband I and 
% Q signals are filtered and downsampled.
%-------------------------------------------------------------------------
% Usage: [ f_bb,xbb_I,xbb_Q,x_bb ] = iq_vector_demod( x,W,oversample,fMID,Tx,t,hb,ha,R )
%-------------------------------------------------------------------------
% Input parameters
% x: input multiband RF signal
% W: Nyquist frequency (Hz), maximum signal frequency =< W/2
% oversample: oversample ratio
% fMID: center of the frequency range of interest
% Tx: duration of the observation time interval
% t: time vector
% lpf_cutoff: cutoff frequency of the vector demodulator lowpass filters
% R: during downsampling every Rth sample is kept
% hb, ha: window based filter definition
% impairments: determines if impairments are included or not
% delapm: amplitude imbalance
% delphase: phase imbalance
% DCoffset: Dc offset caused by carrier leakage
%-------------------------------------------------------------------------
% Output parameters
% xbb_I: down-converter, filtered I signal
% xbb_Q: down-converter, filtered Q signal
% xbb: xbb_I - 1i*xbb_Q
% f_bb: baseband frequency vector
%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch impairments
    
    case 'on'
        LO_I = (1+delamp)*cos((2*pi/Tx)*fMID*t+delphase*2*pi/360); % zero phase LO, cosine function
        LO_Q = (1-delamp)*sin((2*pi/Tx)*fMID*t-delphase*2*pi/360); % 90 degree phase LO, sine function
        xbb_I_fullrate = x.*LO_I + DCoffset;
        xbb_Q_fullrate = x.*LO_Q + DCoffset;
        
    case 'off'
        LO_I = cos((2*pi/Tx)*fMID*t); % zero phase LO, cosine function
        LO_Q = sin((2*pi/Tx)*fMID*t); % 90 degree phase LO, sine function
        xbb_I_fullrate = x.*LO_I;
        xbb_Q_fullrate = x.*LO_Q;
        
end % switch

xbb_I_fullrate_filtered = filter(hb,ha,xbb_I_fullrate); % filtered fullrate I signal
xbb_Q_fullrate_filtered = filter(hb,ha,xbb_Q_fullrate); % filtered fullrate Q signal

xbb_I = R*downsample(xbb_I_fullrate_filtered,R); % filtered, downsampled I qignal
xbb_Q = R*downsample(xbb_Q_fullrate_filtered,R); % filtered, downsampled Q signal

x_bb = xbb_I + 1i*xbb_Q;
f_bb = ((-length(x_bb)/2 : length(x_bb)/2 -1)/length(x_bb))*(W/R);

end

