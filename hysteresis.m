function sigOut = hysteresis(sig, hi, lo)
    if(hi<lo)
        fprintf("WARNING: Wrong hi/lo hysteresis given\n");
        t = lo;
        lo = hi;
        hi = t;
    end
    siglen = length(sig(:))
    sigOut = zeros(size(sig(:)))
    up_dnn = 1;
    for i = 1:siglen
        if((up_dnn==1)&&(sig(i)<lo))
            up_dnn = 0;
        elseif ((up_dnn==0)&&(sig(i)>hi))
            up_dnn = 1;
        end
        sigOut(i) = up_dnn;
    end

