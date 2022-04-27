%% TDC Continouos
% A realistic model would be two TDCs working alternatively

function dstream = TDC_continuous(sig, fs)
    dstream = [];
    ds_ptr = 0;
    active = 0;
    last_position = 0;
    for i=1:length(sig(:))
        if((i==length(sig(:)))||(sig(i)==0)&&(sig(i+1)==1)))
            dstream[ds_ptr] = (i-last_position)/fs;
            ds_ptr = ds_ptr + 1;
            last_position = i;
        end
    end
