%--------------------------------------------------------------------------
%this function is to plot the constellation of received signal with and
%without phase estimation in the ith iteration, i.e. ith coherent time,
%where ith is random selected.
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function Constellation_flat(Sdata, Rdata, Radj, Fdata, Fadj, AdjAmpl, AdjPhase, iter)
%close all

subplot(2,2,1);
plot(real(Sdata),imag(Sdata),'ro', real(Fdata),imag(Fdata),'b.');
axis([-3 3 -3 3]);
title('without AWGN and without estimation');
xlabel('real part');
ylabel('image part');

subplot(2,2,2);
plot(real(Sdata),imag(Sdata),'ro', real(Fadj),imag(Fadj),'b.');
axis([-3 3 -3 3]);
title('without AWGN and with estimation');
xlabel('real part');
ylabel('image part');

subplot(2,2,3);
plot(real(Sdata),imag(Sdata),'ro', real(Rdata),imag(Rdata),'b.');
axis([-3 3 -3 3]);
title('with AWGN and without estimation');
xlabel('real part');
ylabel('image part');

subplot(2,2,4);
plot(real(Sdata),imag(Sdata),'ro', real(Radj),imag(Radj),'b.');
axis([-3 3 -3 3]);
title('with AWGN and with estimation');
xlabel('real part');
ylabel('image part');

legend(sprintf('ploting %d coherence time, adjusted phase = %d degree', iter, int16(-AdjPhase/pi*180)), 'location', 'South');

drawnow

