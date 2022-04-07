%--------------------------------------------------------------------------
%this function is to plot the BER of received signal with and
%without phase estimation
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function BER_flat(ebn0DB, ber_w, ber_wo, ser_w, ser_wo, modtype, M)
figure;
semilogy(ebn0DB,ser_w, 'r^');
hold on;
semilogy(ebn0DB,ber_w,'b^');
grid on;
semilogy(ebn0DB,ser_wo,'ro');
semilogy(ebn0DB,ber_wo,'bo');

%calculate the theoratical ber
ber = berfading(ebn0DB, modtype, M, 1);
semilogy(ebn0DB,ber,'b');
title('BER vs SNR in flat fading');
xlabel('SNR');
ylabel('BER');
legend('SER with channel estimation', 'BER with channel estimation', 'SER without channel estimation', 'BER without channel estimation', 'Theoratical BER with exactly known phase','location', 'SouthWest');
hold off;