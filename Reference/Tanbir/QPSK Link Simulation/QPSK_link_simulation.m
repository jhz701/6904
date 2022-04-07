%% --------------------------------
% Authors: Aditya Jolly
%----------------------------------
clear; clc;
%% Defining System Parameters

l=1e6; %number of data points
SNR=0:1:10; % range of signal to thermal noise ratio (SNR) 
SNR_l=10.^(SNR/10); % calculating SNR in Linear Terms

E_s = 1; %transmitted energy per symbol

% Defining receiver LO phase imbalance 
delPhi =0*(pi/180); %LO phase imbalance in radians

% Initialize variables
ber = zeros(length(SNR),length(delPhi));
si = zeros(1,l); %transmitted in-phase baseband signal 
sq = zeros(1,l); %transmitted quadrature-phase baseband signal 

%% Communication link model at baseband 

for n=1:length(SNR)
% loop through all values of SNR 
%-------------------------------

%% QPSK transmitter 
    %payload generation
    data_i = round(rand(1,l));
    data_q = round(rand(1,l));
    
    % Transmitted in-phase baseband signal  
    for i = 1:l
        if data_i(i) == 1;
            si(i) = sqrt(E_s/2);  %implement differential encoding 1-->sqrt(E_b)
        else
            si(i) = -sqrt(E_s/2); %implement differential encoding 0--> -sqrt(E_b)
        end
    end
    
    % Transmitted quadrature-phase baseband signal 
    for i = 1:l
       if data_q(i) == 1
            sq(i) = sqrt(E_s/2);
        else
            sq(i) = -sqrt(E_s/2);
        end
    end

%% AWGN channel 

% RMS noise voltage generation 
    n_i = sqrt(E_s/2)/sqrt(2*(SNR_l(n)))*randn(1,l);
    n_q = sqrt(E_s/2)/sqrt(2*(SNR_l(n)))*randn(1,l);
    
% add noise to the transmitted baseband signal 
    si_hat = si + n_i;
    sq_hat = sq + n_q;
    
%% QPSK receiver with linear impairments 

    ri = si_hat;
    rq = sq_hat;
    
    %Introduce LO phase imbalance at baseband  
    ri_hat = ri*cos(delPhi)+rq*sin(delPhi);
    rq_hat = rq*cos(delPhi)-ri*sin(delPhi);
        
    %Demodulation   
    si_=sqrt(E_s/2)*sign(ri_hat);                                
    sq_=sqrt(E_s/2)*sign(rq_hat);          
    
    %BER Calculation
    ber_i=(l-sum(si==si_))/l;                          
    ber_q=(l-sum(sq==sq_))/l;                          
  
    % Overall BER
    ber(n)=mean([ber_i ber_q]);
%-------------
% end SNR loop
end


%% Plot simulation results

plot(SNR,ber,'o-')
hold on
set(gca, 'YScale', 'log');
title('BER vs SNR for QPSK');
xlabel('SNR (dB)');                                   
ylabel('BER');                                         
grid on  
