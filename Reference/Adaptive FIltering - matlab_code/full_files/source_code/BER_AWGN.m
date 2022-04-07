%--------------------------------------------------------------------------
%this function is to plot the BER of received signal
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function BER_AWGN(ebn0DB, ber, ser, modtype, M, dataenc)
figure;
semilogy(ebn0DB,ber,'b^');
hold on;
grid on;
semilogy(ebn0DB,ser, 'r^');

%calculate the theoratical ber
ber = berawgn(ebn0DB, modtype, M, dataenc);
semilogy(ebn0DB,ber,'b');
title('BER vs SNR in AWGN');
xlabel('SNR');
ylabel('BER');
legend('simulated BER','simulated SER', 'Theoratical BER','location', 'SouthWest');
hold off;