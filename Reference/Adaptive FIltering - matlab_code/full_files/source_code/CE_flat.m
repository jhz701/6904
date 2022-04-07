%--------------------------------------------------------------------------
% flat fading channel estimation
% In this program, I just estimate the average phase error and amplitude
% error
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function [AdjAmpl, AdjPhase] = CE_flat(Rtr, Str, Rdata, Sdata)

%traning
%calculate channel error
err = Rtr./Str;
err_mean = mean(err);
AdjPhase = atan2(imag(err_mean), real(err_mean));

% ErrPhase = atan2(imag(err), real(err));
% %since ErrPhase may have positive and negtive phase during
% %[-pi, pi), we need to adjust to all positive before average
% %ErrPhase = ErrPhase + (ErrPhase<0)*2*pi;
% AdjPhase = mean(ErrPhase);
ErrAmpl = abs(err);
AdjAmpl = mean(ErrAmpl);
