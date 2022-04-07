function [x_hat] = signal_reconstruction(A,support_index,K_hat,y,t,centerfreq_set_bb_hat)
% This script recovers the amplitudes of the original multiband
% signal x from samples y acquired by the Modulated Wideband Converter (MWC).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: [centerfreq_hat,x_hat,R,Psi,A] = reconstruct_signal(A,Supp,K_hat,y,t,centerfreq_set_bb_hat)
%
% Inputs:
% A: measurement matrix (Phi*Psi)
% support_index: the index of the recovered supports
% K_hat: number of recovered supports
% y: output samples of MWC
% t: time vector
% centerfreq_set_bb_hat: center frequencies of the recovered supports
%
% Outputs
% x_hat: reconstructed signal (signal estimate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A_Omega=A(:,support_index(1:K_hat)); % reduce dimension of A 

s_hat = pinv(A_Omega)*y; % y and s_hat are matrices of time domain signals
s_interp = zeros(size(s_hat,1),length(t));
for i=1:size(s_interp,1) 
 s_interp(i,:) = interpft(s_hat(i,:),length(t)); % interpolate to expand to original (Nyquist) length
end
 
x_hat=sum(s_interp.*exp(-1i*2*pi*centerfreq_set_bb_hat*t),1); % modulate spectrum slices to appropriate locations

XX=10;
x_hat=XX*(x_hat/norm(x_hat));