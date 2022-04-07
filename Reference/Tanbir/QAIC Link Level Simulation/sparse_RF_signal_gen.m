function [ xw,centerfreq,support_indexset,support_pattern ] = sparse_RF_signal_gen( W,numBins,tx_freqset,B,K,rf_sig_length,sigtype,SNR,noise )
%-------------------------------------------------------------------------
% This function returns a multiband RF signal with K active sub-bands each 
% B Hz wide in the frequency band ranging from fMIN to fMAX
%-------------------------------------------------------------------------
% Usage: [ x,centerfreq ] = sparse_RF_signal_gen( W,oversample,tx_freqset,B,K,rf_sig_length,sigtype,SNR,noise )
%-------------------------------------------------------------------------
% Input parameters
% W: Nyquist frequency (Hz), maximum signal frequency =< W/2
% oversample: 
% numBins: total number of bins or channels in the frequency range of interest
% rf_sig_length: this is the length of the RF signal
% tx_freqset: these are the valid RF frequency bin center frequencies
% B: width of each active sub-band (resolution bandwidth)
% K: number of active sub-bands
% sig_length: number of samples included in the signal vector
% sigtype: defines the type of signal - band limittted noise, sync function
% SNR: signal to noise power (linear) ratio
% noise: determines if noise is on or not
%-------------------------------------------------------------------------
% Output parameters
% x: multiband RF signal
% centerfreq: center frequencies of the active sub-bands
%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indexset = randperm(numBins);
support_indexset = indexset(1:K); %randomly activate K bins
%support_indexset = [5,9,14,31,40,60]; %acitave K specific bins

support_pattern = zeros(1,numBins);
support_pattern(support_indexset)=1;

centerfreq = tx_freqset(support_indexset)';
x = zeros(1,rf_sig_length); % initialize multiband RF signal vector

switch sigtype 
    
    case 'band_lim_noise'
        XX=10;
        for n=1:K
        f = [(centerfreq(n)-(3*B/8))/(W/2) (centerfreq(n)+(3*B/8))/(W/2)];
        hb = fir1(4000,f,'bandpass'); ha=1;% window based FIR design
        x = x + filter(hb,ha,randn(1,length(x))); % filtered white Gaussian noise
        end
        x = XX*(x/norm(x));
        
        
end %switch


switch noise
    
    case 'on'
        input_sigP=norm(x)^2/length(x); % compute signal power
        input_noiseP=(1/SNR)*input_sigP; %determine required noise power wrt input signal power
        s=RandStream.getGlobalStream;
        reset(s); % uncomment to reset random number generator for repeatable
        e=sqrt(input_noiseP)*randn(s,size(x)); %generate white Gaussian noise
        xw=x+e; % add noise
        
    case 'off'
        xw=x;
        
end % switch


