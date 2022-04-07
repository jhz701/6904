function [ Phi ] = sens_mat_gen( mwc_branches,L,type )
%-------------------------------------------------------------------------
% This function generates the sensing matrix
%-------------------------------------------------------------------------
% Usage: [Phi_exten] = sens_mat_gen( mwc_branches,L )
%-------------------------------------------------------------------------
% Input parameters
% mwc_branches: total number of branches employed by the complex MWC structure
% L: specifies rate and period of random +/- 1 sequence wrt Nyquist rate (1/Tp=W/L)
% bins: this is the length of the baseband signal
% type: this specifies the type of sensing waveform used
%-------------------------------------------------------------------------
% Output parameters
% Phi_exten: sensing matrix (size mwc_branches x bins)
%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch type
    
    case 'noise'
        Phi=noisemat(mwc_branches/2,L); % generate noise samples
        
    case 'rademacher'
        Phi=rad_mat(mwc_branches/2,L); % generate random +/- 1 sequences
        
    case 'mseq'
        Phi=mseq_mat(mwc_branches/2,L); % generate m-sequence
        
    case 'gldseq'
        Phi=gldseq_mat(mwc_branches/2,L); % generate gold sequences
        
end % switch



function [Phi] = noisemat(M,m)
% Generates a M x m random matrix whose entries are drawn from {-1,+1} with equal probability.
% Usage: [Phi]=pnmat(M,m)

s=RandStream.getGlobalStream;
reset(s); % uncomment to reset random number generator and get repeatable results
Phi=randn(s,[M,m]);


function [Phi] = rad_mat(M,m)
% Generates a M x m random matrix whose entries are drawn from {-1,+1} with equal probability.
% Usage: [Phi]=pnmat(M,m)

s=RandStream.getGlobalStream;
reset(s); % uncomment to reset random number generator and get repeatable results
Phi=sign(rand(s,[M,m])-0.5);  


function [Phi] = gldseq_mat(rows,columns)

Phi = zeros(rows,columns);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 0, 'SamplesPerFrame', 63);
Phi(1,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 1, 'SamplesPerFrame', 63);
Phi(2,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 2, 'SamplesPerFrame', 63);
Phi(3,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 3, 'SamplesPerFrame', 63);
Phi(4,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 4, 'SamplesPerFrame', 63);
Phi(5,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 5, 'SamplesPerFrame', 63);
Phi(6,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 6, 'SamplesPerFrame', 63);
Phi(7,:) = 2*(step(hgld)-0.5);

hgld = comm.GoldSequence('FirstPolynomial',[6 1 0],'SecondPolynomial', [6 1 0],'FirstInitialConditions', [1 0 0 0 1 1],'SecondInitialConditions', [1 0 0 1 0 0],'Index', 7, 'SamplesPerFrame', 63);
Phi(8,:) = 2*(step(hgld)-0.5);



function [Phi] = mseq_mat(rows,columns)

Phi = zeros(rows,columns);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 0 0 0]);
Phi(1,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 0 0 1]);
Phi(2,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 0 1 0]);
Phi(3,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 0 1 1]);
Phi(4,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 1 0 0]);
Phi(5,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 1 0 1]);
Phi(6,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 1 1 0]);
Phi(7,:) = 2*(step(hpn)-0.5);

hpn = comm.PNSequence('Polynomial',[6 1 0], 'SamplesPerFrame', 63, 'InitialConditions',[1 0 0 1 1 1]);
Phi(8,:) = 2*(step(hpn)-0.5);
