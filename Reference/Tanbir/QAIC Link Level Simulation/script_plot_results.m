%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The simulation results are plotted in this script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: June, 2013
% Author: Tanbir Haque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Maximum RF frequency of interest %3.3f Hz\n',fMAX);
fprintf('Minimum RF frequency of interest %3.3f Hz\n',fMIN);
fprintf('Specified resolution bandwidth %3.3f Hz\n',resBW);
fprintf('Number of bins in the frequency range of interest %3.0f \n',numBins);
fprintf('Number of active sub-bands %3.0f \n',K);
fprintf('Information BW of the sparse input multiband signal %3.3f Hz\n',K*resBW);
fprintf('\n');

fprintf('Sampling window duration %3.3f seconds \n',Tx);
fprintf('Scanner RF Nyquist sampling rate %3.3f Hz\n',W);
fprintf('Scanner baseband Nyquist sampling rate %3.3f Hz\n',Wbb);
fprintf('MWC branch sampling rate %3.3f Hz\n',Wbb/mwc_branch_downsample_factor);
fprintf('Implemented aggregate baseband sampling rate %3.3f Hz\n',(q*(Wbb/mwc_branch_downsample_factor)));
fprintf('Subsampling factor relative to baseband Nyquistrate rate %3.3f\n',Wbb/(q*(Wbb/mwc_branch_downsample_factor)));
fprintf('Subsampling factor relative to RF Nyquist rate %3.3f\n',W/(q*(Wbb/mwc_branch_downsample_factor)));
fprintf('\n');

fprintf('Center frequencies of the input multi-band signal active sub-bands \n');
fprintf('%3.2f\n',sort(support)); % display true center frequencies of active bands
fprintf('Center frequencies of the recovered sub-bands \n');
fprintf('%3.2f\n',sort(support_hat)); % display recovered center frequencies 
fprintf('\n');
fprintf('Number of correct support detections %3.0f \n',correct_detections);
fprintf('Number of missed support detections %3.0f \n',missed_detections);
fprintf('Number of false alarms %3.0f \n',false_alarms);
fprintf('\n');

fprintf('Column rank of A matrix: %2i\n',rank(A)); % display rank of A
fprintf('Column rank of R matrix: %2i\n',rank(2*pi*(M/W)*(y*y'))); % display rank of R
fprintf('\n');

figure;
stem(centerfreq_set,support_pattern,'Marker','*');
hold on;
stem(centerfreq_set,support_pattern_hat,'Marker','O');
xlim([centerfreq_set(1)-resBW/2 centerfreq_set(numBins)+resBW/2]);
xlabel('Possible Center Frequencies','fontsize',12); 
ylabel('1=bin occupied, 0=bin empty','fontsize',12); 
title('Support Pattern of original and recovered signals','fontsize',14); 

figure;
plot(f,(abs(fftshift(fft(x)))));
%ylim([-20 60]);
grid on
xlabel('Frequency in MHz','fontsize',12); 
ylabel('Magnitude (linear)','fontsize',12); 
title('Fourier Spectrum of the Input RF Signal','fontsize',14); 

figure % plot fft of original signal x_bb and reconstructed signal x_bb_hat
h0=subplot(211); plot(f_bb,(abs(fftshift(fft(x_bb)))),'Marker','none'); title('Fourier Spectrum of the Original Signal at Baseband'); 
grid on
xlim([(fMIN-fMID) (fMAX-fMID)])
xlabel('MHz'); ylabel('Magnitude (linear)');
h1=subplot(212); plot(f_bb,(abs(fftshift(fft(x_bb_hat)))),'Marker','none'); title('Fourier Spectrum of the Reconstructed Signal at Baseband');
grid on
xlabel('MHz'); ylabel('Magnitude (linear)')
linkaxes([h0 h1])

figure;
plot(f_bb,(abs(fftshift(fft(x_bb)))));
%ylim([-20 60]);
grid on
xlabel('Frequency in MHz','fontsize',12); 
ylabel('Magnitude (linear)','fontsize',12); 
title('Fourier Spectrum of the Original Signal at Baseband','fontsize',14); 

figure;
plot(f_bb,(abs(fftshift(fft(x_bb_hat)))));
%ylim([-20 60]);
grid on
xlabel('Frequency in MHz','fontsize',12); 
ylabel('Magnitude (linear)','fontsize',12); 
title('Fourier Spectrum of the Reconstructed Signal at Baseband','fontsize',14); 

figure % graphically display key matrices
subplot(211); imagesc(Phi); axis equal; axis tight; title('\Phi matrix');
subplot(212); imagesc(abs(Psi)); axis equal; axis tight; title('\Psi matrix (magnitude)');

figure %graphically display key matrices
subplot(211); imagesc(abs(A)); axis equal; axis tight; title('A matrix (magnitude)');
subplot(212); imagesc(abs(2*pi*(M/W)*(y*y'))); axis equal; axis tight; title('R matrix (magnitude)');
