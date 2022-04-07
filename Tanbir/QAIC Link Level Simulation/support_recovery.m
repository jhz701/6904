function [support_indexset_hat,support_pattern_hat,K_hat,support_bb_hat,ResNorm,NormResvsSol] = support_recovery(y,A,centerfreq_set_bb,numBins,ResThreshold,ResvsSolThreshold,NumIters)
% This script recovers the support of the original multiband
% signal x from samples y acquired by the Modulated Wideband Converter (MWC). The recovery 
% algorithm is that of Mishali and Eldar (see the technical report "Sampling Sparse Multiband 
% Signals with a Modulated Wideband Converter", accompanying the CTSS Sampling Toolbox).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: [Supp,K_hat,support_bb_hat,R,Psi,A,ResNorm,NormResvsSol]= support_recovery(y,L,W,centerfreq_set_bb,Phi,M,t,ResThreshold,ResvsSolThreshold,NumIters)
% 
% Inputs
% y: output samples of MWC
% L: specifies rate and period of random +/- 1 sequence wrt Nyquist rate (1/Tp=W/L)
% W: Nyquist rate (Hz)
% Phi: sensing matrix
% M: specifies sampling rate per channel (1/Ts=W/M)
% ResThreshold,ResvsSolThreshold: OMP algorithm thresholds
% NumIters: OMP algorithm number of itterations
% centerfreq_set_bb: valid baseband center frequencies
%
% Outputs
% support_index: the index of the recovered supports
% K_hat: recovered support number
% support_bb_hat: baseband center frequencies of the recovered supports
% R: covariance matrix
% Psi: dictionary matrix
% A: measurement matrix (Phi*Psi)
% ResNorm,NormResvsSol: OMP residues at each itteration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%R=2*pi*(M/W)*(y*y'); % estimate covariance matrix
%[eigvectors,eigvalues]=eig(R); % eigen-decomposition of R
%V=eigvectors*sqrt(eigvalues);

[support_indexset_hat,ResNorm,NormResvsSol]= RunOMP_Unnormalized(y,A,NumIters,ResThreshold,ResvsSolThreshold,'false'); % find support by solving MMV via OMP (M. Mishali's algorithm)
K_hat=length(support_indexset_hat);

support_pattern_hat = zeros(1,numBins);
support_pattern_hat(support_indexset_hat)=1;

%Associate support indices to corresponding center frequencies (Hz)
support_bb_hat(:,1) = centerfreq_set_bb(support_indexset_hat(1:K_hat));
