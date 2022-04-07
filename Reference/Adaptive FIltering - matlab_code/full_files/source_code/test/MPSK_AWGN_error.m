%calculate and plot M-PSK for AWGN channel with exact phase
%information and phase estimation error

%Chen Zhifeng
%UFID 12181197

function myMPSK()

clear all;
close all;
clc;

ebn0DB=[0:15];
ebn0=10.^(ebn0DB/10);
M=4;
k=log2(M);
esn0=k*ebn0;

alpha =[pi/32:pi/32:pi/4];
for i=1:length(esn0),
    ser(i)=1/pi*quad(@pskIntegrand,0,(M-1)/M*pi,[],[],esn0(i),pi/M);
end

for i_alpha=1:length(alpha),
    for i=1:length(esn0),
        sererror(i,i_alpha)=1/2/pi*quad(@pskIntegrand,0,(M-1)/M*pi-alpha(i_alpha),[],[],esn0(i),pi/M+alpha(i_alpha)) + 1/2/pi*quad(@pskIntegrand,0,(M-1)/M*pi+alpha(i_alpha),[],[],esn0(i),pi/M-alpha(i_alpha));;
    end

    %figure;
    %figure;
%     semilogy(ebn0DB,ber,'b--');
%     semilogy(ebn0DB,berbound,'r--');
end

semilogy(ebn0DB,ser,'b-');
hold on;
for i_alpha=1:length(alpha),
    semilogy(ebn0DB,sererror(:,i_alpha),'r-');
end
legend('exact 4-PSK symbol error probability','error 4-PSK symbol error probability','location','southwest');
xlabel('Eb/N0(dB)');
ylabel('error probability in log scale');


function out = pskIntegrand(phi,esn0_,M_phase) 
out = exp(-esn0_*(sin(M_phase)).^2./(sin(phi)).^2);

