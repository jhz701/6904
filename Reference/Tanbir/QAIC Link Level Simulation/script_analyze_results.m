%% This script is used to analyse the support recovery and signal reconstruction resutls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the support recovery statistics
[correct_detections,missed_detections,false_alarms] = support_recovery_stats(numBins,support_pattern,support_pattern_hat);
