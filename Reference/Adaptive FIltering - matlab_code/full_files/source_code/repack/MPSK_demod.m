%--------------------------------------------------------------------------
%M-PSK demodulation
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function Receive = MPSK_demod(R, S, M)
step=2*pi/M;

Rphase = atan2(imag(R), real(R));
Rampl = abs(R);
Sphase = atan2(imag(S), real(S));
Sampl = abs(S);
Receive = Rphase/step;
Receive = round(Receive);
Receive = mod(Receive,M);

