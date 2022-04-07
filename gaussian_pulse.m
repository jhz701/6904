% Gaussian pulse generator
% The function will return an array with the length of frame/fs, in which
% fs is the sampling frequency of the pulse waveform and frame is the
% duration of the waveform.The pulse center will locate at frame/2.

% n is the order of the derivative, the pulse is essentially an nth order
% derivative of a gaussian pulse.

% duration is the pulse duration with the length of frame/fs

% fc is the center frequency of the PSD of the pulse, in this project it is
% 4 GHz

% an is the scaling factor used to limit the amplitude of the pulse. E.g.
% with n = 10 and fc = 4 GHz, the an should be 8e-114 to satisfy the FCC
% mask

function [pulse] = gaussian_pulse(n,fs,fc,frame,an)
sigma=sqrt(n)/(2*pi*fc);
syms t
variance=sigma^2;
x = an*1/(sqrt(2*pi*variance))*(exp(-(t)^2/(2*variance)));
single_pulse = matlabFunction(diff(x,t,n)); %pulse generation
duration=0:1/fs:(frame-1/fs);
pulse = single_pulse(duration-frame/2);
end


