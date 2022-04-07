%% This script runs the bandpass configuration MWC scanner model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate a sparse, wideband, RF signal
[x,support,support_indexset,support_pattern] = sparse_RF_signal_gen(W,numBins,centerfreq_set,B,K,rf_sig_length,rf_sig_type,SNR,'on');

% Downconvert the input RF signal, lowpass filter and downsample
[f_bb,xbb_I,xbb_Q,x_bb] = iq_vector_demod(x,W,fMID,Tx,t,iq_demod_hb,iq_demod_ha,OSR,delAmp,delPhase,DCoffset,'on');

% Sub-sampling
[y] = qaic_sampling(Phi_exten,xbb_I,xbb_Q,q,mwc_hb,mwc_ha,mwc_branch_downsample_factor,Vadc_peak,SNR,'on'); % MWC sampling

% Support recovery and signal reconstruction
[support_indexset_hat,support_pattern_hat,K_hat,support_bb_hat,ResNorm,NormResvsSol] = support_recovery(y,A,centerfreq_set_bb,numBins,ResThreshold,ResvsSolThreshold,NumIters); % recover support
support_hat = support_bb_hat + fMID; % translate to RF
[x_bb_hat] = signal_reconstruction(A,support_indexset_hat,K_hat,y,t_bb,support_bb_hat); % reconstruct signal
