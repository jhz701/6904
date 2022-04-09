function sigOut = channel(sig, setup)
    % SETTINGS:
    regSNR   = setup.regSNR;    % Requested Regulated SNR (compared to the RX signal), log Scale
    fadeType = setup.fadeType;  % Currently Supported:
                                %   'rayleigh':      Rayleigh Fade
                                %   'rayleigh_pdp':
                                %   'flat':          Uniform Attenuation
    rayleighVelocity = setup.rayleighVelocity;
    flatAttenuation  = setup.flatAttenuation;       % given in db20, should be a positive number
   
    % Apply Multi-Path (done using convolve)
    % TBD
    
    % Apply Fading
    switch fadeType 
        case 'rayleigh'
            [h, rayleighTc, rayleighTs] = Rayleigh(length(sig(:)), rayleighVelocity);
            rayleighMaxpercoh = floor(Tc/Ts);
            sig = sig.*h;
        case 'rayleigh_pdp'
            [h, rayleighTc, rayleighTs, rayleighLc] = RayleighPDP(length(sig(:)), rayleighVelocity); 
            rayleighMaxpercoh = floor(Tc/Ts);
            sig = sig.*h;
        case 'flat'
            sig = sig*10*(-flatAttenuation/20);
        otherwise
            warning('No fade type specified, no fading applied');
    end

    sigEnergy = norm(sig(:))^2;             % Calculate the signal power
    nosEnergy = sigEnergy/(10^(regSNR/10)); % Calculate the noise applied under a given SNR
    nosVar    = nosEnergy/(length(sig(:))-1);
    nosStd    = sqrt(nosVar);
    nos       = nosStd*randn(size(sig));
    sigOut    = sig + nos;