% Gaussian pulse generator
% The function will return an array with the length of pulse_duration/fs, in which
% fs is the sampling frequency of the pulse waveform and pulse_duration is the
% duration of the waveform.The pulse center will locate at pulse_duration/2.

% n is the order of the derivative, the pulse is essentially an nth order
% derivative of a gaussian pulse.

% fc is the center frequency of the PSD of the pulse

% an is the scaling factor used to limit the amplitude of the pulse. E.g.
% with n = 10 and fc = 4 GHz, the an should be 8e-114 to satisfy the FCC
% mask

function [pulse] = gaussian_pulse(n,fs,fc,pulse_duration,an)
sigma=sqrt(n)/(2*pi*fc);
syms t
variance=sigma^2;
x = an*1/(sqrt(2*pi*variance))*(exp(-(t)^2/(2*variance)));
single_pulse = matlabFunction(diff(x,t,n)); %pulse generation
duration=0:1/fs:(pulse_duration-1/fs);
pulse = single_pulse(duration-pulse_duration/2);
end


