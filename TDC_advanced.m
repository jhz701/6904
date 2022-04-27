% Module TDC_advanced
% This module models the TDC + oneshot inhibit function used in the RX circuit
% In addition to the physical capabilities, the module also checks the TDC status against
% a separate stream of ground truth (pat) to find the point at which the RX achieves locking

% INPUTS
%  sig:  Signal stream
%  pat:  Ground truth pattern stream, format: [[type0 duration0] [type1 duration1] ...]
%  fs:   Simulation Sampling Frequency
%  tres: TDC native resolution 
%  tdly: Oneshot delay
% OUTPUTS
%  dso:  Data stream out, format: 
%       [[uint5(0~31) Validity] ...]
module dso = TDC_advanced (sig, pat, fs, tres)
