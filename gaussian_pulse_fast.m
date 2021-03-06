% Similar to the Gaussian pulsegen function
% The difference is that this version is purely numerical, making it a lot faster
function [pulse] = gaussian_pulse_fast(n, fs, fc, tpulse, an)
    sigma     = sqrt(n)/(2*pi*fc);
    variance  = sigma^2;
    npulse    = tpulse*fs;
    t = -tpulse/2:1/fs:tpulse/2;
    x = an/(sqrt(2*pi*variance))*(exp(-(t).^2/(2*variance)));
    pulse = diff(x,n);
    npulse1 = length(pulse);
    pulse = [zeros(1,floor((npulse-npulse1)/2)+1) pulse zeros(1,floor((npulse-npulse1)/2))];
end
