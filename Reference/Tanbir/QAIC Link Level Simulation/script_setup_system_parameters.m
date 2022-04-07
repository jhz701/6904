%% The system parameters are defined in this script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; 
clc;
reset(RandStream.getGlobalStream,sum(100*clock)); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Spectrum scanner top level specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Target (resBW,numBins) pairs: (10,127), (20,63) and (40,31)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resBW = 20; %resolution bandwidth
numBins = 63; %number of bins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fMID = 3200; %band center frequency in MHz
centerfreq_set = (-floor(numBins/2)*resBW : resBW : floor(numBins/2)*resBW) + fMID; %set of valid channel center frequencies
centerfreq_set_bb = centerfreq_set - fMID;
fMAX = centerfreq_set(numBins) + resBW/2; %maximum RF frequency of interest
fMIN = centerfreq_set(1) - resBW/2; %minimum RF frequency of interest

%% Scanner model parameters
W = ceil(fMAX/(numBins*resBW))*(numBins*resBW)*2; %Nyquist frequency (Hz), max RF signal frequency =< W/2
Wbb = fMAX-fMIN; %baseband Nyquist frequency (=resBW*numBins), max baseband signal frequency =< Wbb/2
OSR = W/Wbb; %oversample ratio (RF sample rate)/(baseband I,Q sample rate)
Tx = 1; %assumed duration of observation interval in seconds
N = W; % this is the length of the input RF signal
t = 0 : 1/W : Tx - 1/W;
t_bb = 0 : 1/Wbb : Tx - 1/Wbb;
f = ((-length(t)/2 : length(t)/2 -1)/length(t))*(W);

%% Parameters for the Sparse RF Signal Generator
rf_sig_length = length(t);
rf_sig_type = 'band_lim_noise'; % choose signal type
SNRdB = 20;
SNR = 10^(SNRdB/10); % total signal power to noise power ratio (linear)

%% Parameters for the Direct IQ Down-converter
lpf_cutoff = 1.25*(fMAX-fMIN)/W; % Define the I, Q path lowpass filters used by the vector demodulator
hfilterorder = 40; % set FIR filter order (should be even)
iq_demod_hb = fir1(hfilterorder, lpf_cutoff); iq_demod_ha=1; % coefficients characterizing window-based FIR LPF (cut-off freq=W/2M Hz)

delAmp = 0; % amplitude imbabalnce relative relative to 1
delPhase = 0; % phase imbalance specified in degrees
DCoffset = 0;

%% QAIC Converter parameters
K = 3; % number of occupied frequency bands present the input signal x
B = resBW; % maximum bandwidth of each occupied frequency band (Hz)
q = 32; % total number of channels, q/2 for each of the I,Q paths
L = numBins; % L specifies period of p(t) wrt the Nyquist period; setting L=M means period of p(t) equals sampling period
M = L; % specifies sampling rate per branch (fs=W/M)

mwc_branch_downsample_factor = 2*M;
hfilterorder= 800; % set FIR filter order (should be even)
mwc_hb=fir1(hfilterorder,1/(2*mwc_branch_downsample_factor)); mwc_ha=1; % coefficients characterizing window-based FIR LPF (cut-off freq=W/4M Hz)
Vadc_peak=1; %A/D converter peak input voltage

sens_mat_type = 'noise'; % choose noise, rademacher, mseq or gldseq
Phi = sens_mat_gen( q,L,sens_mat_type ); % generate sensing matrix
Phi_exten(:,:) = Phi(:,mod(0:length(t_bb)-1,L)+1); % periodic extensions of Phi

l(:,1)=0:L-1;    
m = -floor((L/(2*M))*(M)):floor((L/(2*M))*(M));

Psi=exp(-1i*(2*pi/L)*l*m); % form Psi matrix
alpha=ones(size(m))*1/L; % complex factors do not appear in digital simulation (see technical 
                         % report "Sampling Sparse Multiband Signals with a Modulated Wideband Converter")
A=Phi*Psi*diag(alpha); % matrix characterising linear system of equations

%% Number of itterations and thresholds for OMP based recovery
NumIters = q/2;
ResThreshold = 10*Vadc_peak/L; %0.025; 
ResvsSolThreshold = 10*Vadc_peak/L; %0.025;

%% MWC parameter checks
if M>L 
 error('M must be less than or equal to L to prevent destructive aliasing');
end
if q>M
 error('q must be less than or equal to M to ensure sub-Nyquist sampling');
end
