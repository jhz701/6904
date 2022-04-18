%% DIFFERENTIATION
% The ultimate goal is to find the peak of each pulse instead of the edges.
% It greatly decreases timing error due to voltage noise on the edges.
% The downside is that the voltage noise on the flat part can also cause
% error. It's amplified by the differentiator.
%% 
% Generating some test signals
channel_tb;

%%
subplot(2,1,1);
hold off;
plot(sigout_rx);
hold on
plot(sigout_hilbert);

subplot(2,1,2);
hold off;
yyaxis left

% Low-pass using a filter with cutoff = 2GHz
% After this, pass it thru a differentiator
lpd = lowpass(diff(lowpass(sigout_hilbert,2e9,fs)),0.5e9,fs);
plot(lpd);
yyaxis right;
% Now the hyteresis comparator gives a more accurate timing result
% Note that the polarity is filpped such that the posedge is the 
% output signal we want. This is only due to convention
plot(hysteresis(-lpd,0,-2e-3));
ylim([-0.5,1.5]);