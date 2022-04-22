% Free space path loss model
% Asigout/Asigin = (c/2r)*(1/w)
% fs is sampling frequency, fmin and fmax are the minimum and maximum
% frequecny that the algorithm is applied to. 
function sig_out = FSPL(sig_in,r,fs)
    c = 3e8;
    coef = c/(2*r);
    len = length(sig_in);
    time = (1/fs)*(len-1); % signal duration
    RBW = 1/time; % frequency resolution
    spectrum = fft(coef*sig_in);
    if(rem(len,2)) % if the lengthe of the sequence is odd 
        for i = 2:1:(len-1)/2
            w = 2*pi*(i-1)*RBW;
            spectrum(i) = (1/w)*specturm(i);
            spectrum(len-i+2) = (1/w)*spectrum(len-i+2);
        end
    else % the length of the sequence is even
        for i = 2:1:len/2
            w = 2*pi*(i-1)*RBW;
            spectrum(i) = (1/w)*spectrum(i);
            spectrum(len-i+2) = (1/w)*spectrum(len-i+2);
        end
        spectrum(len/2+1) = (1/(2*pi*(len/2)*RBW))*spectrum(len/2+1);
    end
    spectrum(1) = 0;
    sig_out = ifft(spectrum);
end