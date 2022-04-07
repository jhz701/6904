function [ y ] = qaic_sampling(Phi_exten,xbb_I,xbb_Q,mwc_branches,hb,ha,mwc_branch_downsample_factor,Vadc_peak,SNR,noise)
%-------------------------------------------------------------------------
% This function implements a complex (I,Q) MWC structure.
%-------------------------------------------------------------------------
% Usage: [ y ] = qaic_sampling(Phi_exten,xbb_I,xbb_Q,mwc_branches,hb,ha,mwc_branch_downsample_factor,Vadc_peak,SNR,noise)
%-------------------------------------------------------------------------
% Input parameters
% xbb_I: discrete I path input signal
% xbb_Q: discrete Q path input signal
% mwc_branches: total number of branches employed by the complex MWC structure
% hb, ha: FIR low-pass filter coefficients
% M: 
%-------------------------------------------------------------------------
% Output parameters
% y: sampled output
% Phi: matrix of random +/- 1 (size L x q)
%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y_I = zeros(mwc_branches/2,length(xbb_I)); % 1/2 of the total branches in the I path
y_Q = zeros(mwc_branches/2,length(xbb_Q)); % 1/2 of the total branches in the Q path

for i=1:mwc_branches/2
 y_I(i,:) = xbb_I.*Phi_exten(i,:); % multiply input baseband I signal by random +/- 1 sequence
 y_Q(i,:) = xbb_Q.*Phi_exten(i,:); % multiply input baseband Q signal by random +/- 1 sequence
end

y_I=filter(hb,ha,y_I.'); % filter demodulated signal with low pass filter
y_I=mwc_branch_downsample_factor*(downsample(y_I,mwc_branch_downsample_factor))'; % downsample

y_Q=filter(hb,ha,y_Q.'); % filter demodulated signal with low pass filter
y_Q=mwc_branch_downsample_factor*(downsample(y_Q,mwc_branch_downsample_factor))'; % downsample

[measurements samples]=size(y_I);
switch noise
    
    case 'on' % add noise to measurements y_I and y_Q
        
    for i=1:samples
        IsigPower=norm(y_I(:,i))^2/measurements;
        QsigPower=norm(y_Q(:,i))^2/measurements;
        InoisePower=IsigPower/(2*SNR);
        QnoisePower=QsigPower/(2*SNR);
        e_I=sqrt(InoisePower)*randn(measurements,1);
        e_Q=sqrt(QnoisePower)*randn(measurements,1);
        y_I(:,i)=y_I(:,i)+e_I;
        y_Q(:,i)=y_Q(:,i)+e_Q;
    end %for

    case 'off'
        % do nothing
        
end %switch

%scale the I and Q measurements to the A/D input voltage range
scale=sqrt((norm(y_I)^2+norm(y_Q)^2)/(measurements*samples));
y_I=(Vadc_peak/(4*scale))*y_I;
y_Q=(Vadc_peak/(4*scale))*y_Q;

y = y_I + 1i*y_Q;
