%--------------------------------------------------------------------------
%M-PSK modulation
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function S = MPSK_mod(Transmit, M)
step=2*pi/M;
%m=[0:M-1];
S=exp(j*Transmit.*step);
