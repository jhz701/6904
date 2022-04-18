%%
% The input is already passed through a hysteresis comparator (1/0 sequence)
% ARGUMENTS
%   sig:    Post-Comparator Data Stream @ fs (logical)
%   fs:     Sampling Frequency (Hz)
%   tframe: Duration of each data frame (s)
%   tres:   TDC Resolution (s)
%   tsep:   Guard Separation of Data Frames (s)
function dstream = TDC(sig, fs, tframe, tres, tsep)
    ndframe = fs*tframe;                        % Length of each data frame
    nframe  = floor(length(sig(:))/ndframe);    % Total number of frames
    ndres   = fs*tres;                          % length of PSM resolution
    dstream = zeros([1,nframe]);
    ds_ptr = 1;
    active = 0;
    last_position = 0;
    for i=1:length(sig(:))-1
        if((sig(i)==0)&&(sig(i+1)==1))
            % Posedge Detected
            if((i-last_position)>tsep)
                % Past the buffer region, which means that the 
                % current edge we're looking at represents SYNC
                active = 1;
                last_position = i;
            elseif (active)
                % Valid data
                active = 0;
                d = round(log2((i-last_position)/ndres));   % Pulse-Separation-Modulation (PSM)
                dstream[ds_ptr] = d;
                ds_ptr = ds_ptr+1;
                last_position = i;
            end
        end
    end

    


