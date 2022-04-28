% Module TDC_advanced
% This module models the TDC + oneshot inhibit function used in the RX circuit
% In addition to the physical capabilities, the module also checks the TDC status against
% a separate stream of ground truth (pat) to find the point at which the RX achieves locking

% INPUTS
%  sig:  Signal stream (post hyst. comparator)
%  pat:  Ground truth pattern stream, format: [[type0 duration0] [type1 duration1] ...]
%  fs:   Simulation Sampling Frequency
%  tres: TDC native resolution 
%  tdly: Oneshot delay
% OUTPUTS
%  dso:  Data stream out, format: 
%       [[uint5(0~31) Validity] ...]

% Usage Warning: Certain operations (e.g. FIR) can cause extra delay in the data stream
%                The pattern stream must be synchronized to it
%
% You may want to start at the center of the first pulse (?), or the edge (?) 
% It's not determined yet I guess

function dso = TDC_advanced (sig, pat, fs, tres, tsync, tmiw)
    % Constants
    ndframe = fs*tframe;                        % Length of each data frame
    nframe  = floor(length(sig(:))/ndframe);    % Total number of frames
    ndres   = fs*tres;                          % length of DMPPM resolution
    dstream = zeros([2, nframe]);

    % Pattern FSM
    pfsm_ptr       = 1;
    pfsm_status    = pat(1, pfsm_ptr);
    pfsm_countdown = pat(2, pfsm_ptr);
    
    % TDC
    ds_ptr       = 1;   % Data stream
    tdc_started  = 0;
    tdc_startpos = 0;   % Use the absolute value    
    % TDC Inhibit Control
    tdc_inhibit            = 0;
    tdc_inhibit_countdown  = tsync * fs;    % Sync Inhibit, i.e. "Recovery Clock"
    tdc_MIW_countdown      = tmiw * fs;     % Multipath Ignore Window
    tdc_last_position      = 0;
    % Main Loop
    for i=1:length(sig(:))-1
        % Pattern FSM, for validation only (not physical)
        if(pfsm_countdown<=1) 
            pfsm_ptr       = pfsm_ptr + 1;
            pfsm_status    = pat(1, pfsm_ptr);
            pfsm_countdown = pat(2, pfsm_ptr);
        else
            pfsm_countdown = pfsm_countdown - 1;
        end

        if(tdc_inhibit)
            % TDC is inhibited from starting, this is a part of an async clock gen
            tdc_inhibit_countdown = tdc_inhibit_countdown - 1;
            if(tdc_inhibit_countdown<=0)
                % Reset inhibit, the tdc is now armed, waiting for the next pulse as the start pulse
                tdc_started           = 0;
                tdc_inhibit_countdown = tsync;
                tdc_inhibit           = 0;
            end
        else
            if(tdc_started==0)
                % Looking for SYNC
                if((sig(i)==0)&&(sig(i+1)==1))
                    % SYNC found, start
                    tdc_started       = 1;
                    tdc_MIW_countdown = tmiw * fs;  % Reset MIW Inhibit
                    tdc_last_position = i;          % Record the starting position
                end
            else
                % Looking for Data
                if(tdc_MIW_countdown<=0)
                    % MIW is done, ready for data capture
                    if(sig(i+1)==1)
                        d = round(log2((i-last_position)/ndres)); % We got one
                        if(pfsm_status<=31)
                            validity = 1;       % This is a data pulse
                        else
                            validity = 0;       % SYNC failed, we're not looking at a data pulse
                        end
                        dso(:,ds_ptr) = [d, validity];  % Append Data
                    end
                end
            end
        end

    end