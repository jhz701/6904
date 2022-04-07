function [ correct_detections,missed_detections,false_alarms ] = support_recovery_stats( numBins,support_pattern,support_pattern_hat )
%-------------------------------------------------------------------------
% This function generates support recovery statistics. It returns the
% number of correctly recovered supports and the number of false alarms.
%-------------------------------------------------------------------------
% Usage: [ correct_detections,false_alarms ] = compute_support_pattern( support,support_hat,support_pattern_hat )
%-------------------------------------------------------------------------
% Input parameters
%
% K: support number of the input wideband signal
% index_set: the set of active support indices of the input wideband signals
% index_set_hat: the set of active support indices of the recovered signal
% support_pattern_hat: support pattenr of the recovered signal
%-------------------------------------------------------------------------
% Output parameters
%
% correct_detections: number of correctly detected active supports
% false_alarms: number of false alarms
%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

correct_detections = 0;
missed_detections = 0;
false_alarms = 0;

for i=1:numBins
    
    if (support_pattern(i) == 1)
        
        if (support_pattern_hat(i) == 1)
            correct_detections = correct_detections + 1;
        end
        
        if (support_pattern_hat(i) ~= 1)
            missed_detections = missed_detections + 1;
        end
        
    end
    
    if (support_pattern(i) ~= 1)
        
        if (support_pattern_hat(i) == 1)
            false_alarms = false_alarms + 1;
        end
        
    end
    
end
