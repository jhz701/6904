%calculate and plot M-PSK for flat fading channel with exact phase
%information and phase estimation error

%Chen Zhifeng
%UFID 12181197

function MPSK_flat_error()

clear all;
close all;
clc;

ebn0DB=[0:15];
ebn0=10.^(ebn0DB/10);
M=4;
k=log2(M);
esn0=k*ebn0;

ser = 0.1./(1+ebn0);
alpha =[pi/32:pi/32:pi/4];
%sererror = zeros(size(alpha));
for i_alpha=1:length(alpha),
    temp =(cos(alpha(i_alpha)))^2;
    sererror(i_alpha,:) = 0.1./(1+ebn0*temp);

    %figure;
    %figure;
%     semilogy(ebn0DB,ber,'b--');
%     semilogy(ebn0DB,berbound,'r--');
end

semilogy(ebn0DB,ser,'b-');
hold on;
for i_alpha=1:length(alpha),
    semilogy(ebn0DB,sererror(i_alpha,:),'r-');
end
legend('exact 4-PSK symbol error probability','error 4-PSK symbol error probability','location','southwest');
xlabel('Eb/N0(dB)');
ylabel('error probability in log scale');

