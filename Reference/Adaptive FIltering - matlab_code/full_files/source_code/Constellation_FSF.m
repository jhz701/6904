%--------------------------------------------------------------------------
%this function is to plot the constellation of received signal with and
%without equalization, trained equalizer weights, and training curve in 
%the ith iteration, i.e. ith coherent time, where ith is random selected.
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

function Constellation_FSF(Sdata, Rdata, Radj, Sdata_wo_mod, M, gray_encode, err_eq, weights, ebn0_for_plot, block);

simName = sprintf('Linear equalization of frequency-selective fading channel under ebn0 == %dDB', ebn0_for_plot*3);
[rxdata_wo, BER_wo, yErr_wo] = adapteq_pskdetect_mine(...
    Rdata, Sdata, Sdata_wo_mod, M, gray_encode);
%we don't use rxdata_wo here

[rxData, BER, yErr] = adapteq_pskdetect_mine(...
    Radj, Sdata, Sdata_wo_mod, M, gray_encode);
%we don't use rxData here

adapteq_graphics(Rdata, yErr_wo, BER_wo, ...
    Radj, yErr, BER, ...
    err_eq, weights, ...
    simName, block);
