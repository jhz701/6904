%% Sampling sparse mulitband signals with a multi-channel, bandpass random demodulator
% This top-level script (m-file) demonstrates the sampling and recovery of sparse
% multiband signals using the modified (bandpass) Modulated Wideband Converter (MWC). 
% When the script is executed MATLAB will generate a sparse multiband signal 
% sample it, and recover the original signal from its samples.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;

%% The system parameters are defined in the following script
script_setup_system_parameters;

%% Run the scanner model
script_run_scanner_model;

%% Analyze results
script_analyze_results

%% The simulation results are plotted in the following script
script_plot_results;