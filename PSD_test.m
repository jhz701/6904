
close all
Fs = 1e3;
t = 0:1/Fs:1-1/Fs;
x = cos(2*pi*100*t)+randn(size(t));
L =length(x);
NFFT = 2^nextpow2(L);
plot(psd(spectrum.periodogram,x,'Fs',Fs,'NFFT',NFFT));
df = Fs/NFFT;
freq = 0:df:Fs/2;
xdft = fft(x,NFFT);
xdft_s = xdft(1:NFFT/2+1);
amp = abs(xdft_s)/NFFT;
psdest = amp.^2/(df); % original 
psdest(2:end-1) = 2*psdest(2:end-1);
hold on
plot(freq,10*log10(psdest),'r');
grid on;
