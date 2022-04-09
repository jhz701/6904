function sigOut = channel(sig, setup)
    % SETTINGS:
    fs       = setup.fs;
    regSNR   = setup.regSNR;    % Requested Regulated SNR (compared to the RX signal), log Scale
    fadeType = setup.fadeType;  % Currently Supported:
                                %   'rayleigh':      Rayleigh Fade
                                %   'rayleigh_pdp':
                                %   'flat':          Uniform Attenuation
    rayleighVelocity = setup.rayleighVelocity;
    flatAttenuation  = setup.flatAttenuation;       % given in db20, should be a positive number
    multiPathSetup   = setup.multiPathSetup;        % Multi-Path Kernel
    % Apply Multi-Path (done using convolve)
    %% sig = conv(sig,kernel);
    for i = 1:length(multiPathSetup(:,1))
        amp = multiPathSetup(i,1);
        pos = multiPathSetup(i,2)*fs;
        sig = sig + amp.*[zeros(1,pos),sig(1:length(sig)-pos)];
    end

    % Apply Fading
    switch fadeType 
        case 'rayleigh'
            [h, rayleighTc, rayleighTs] = Rayleigh(length(sig(:)), rayleighVelocity);
            sig = sig.*h;
        case 'rayleigh_pdp'
            [h, rayleighTc, rayleighTs, rayleighLc] = RayleighPDP(length(sig(:)), rayleighVelocity); 
            sig = sig.*h;
        case 'flat'
            sig = sig*10^(-flatAttenuation/20);
        otherwise
            warning('No fade type specified, no fading applied');
    end

    sigEnergy = norm(sig(:))^2;             % Calculate the signal power
    nosEnergy = sigEnergy/(10^(regSNR/10)); % Calculate the noise applied under a given SNR
    nosVar    = nosEnergy/(length(sig(:))-1);
    nosStd    = sqrt(nosVar);
    nos       = nosStd*randn(size(sig));
    sigOut    = sig + nos;