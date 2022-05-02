function [psdx, fvec] = PSD(x, fs)
    len  = length(x);
    xdft = fft(x);
    xdft = xdft(1:len/2+1);
    psdx = (1/(len)^2) * abs(xdft) .^2;
   % psdx(2:end-1) = psdx(2:end-1);        % Unit: db/Hz
    RBW = fs/len;
    ratio = RBW*1e-6;
    psdx = psdx/ratio; %mag/MHz
    psdx = psdx*1e3/50; %dbm/MHz 
    psdx(2:end-1) = 2*psdx(2:end-1);
    fvec = 0:fs/len:fs/2;
end