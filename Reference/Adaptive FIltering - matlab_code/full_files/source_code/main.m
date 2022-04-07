%--------------------------------------------------------------------------
%This program is writen for EEL6509 course project
%This program can run either in default mode or play mode. If you want to
%play it, you need to specify the modulation type, modulation order, channel type; 
%for both fading channels, you may also need to specify the training data percentage, velocity;
%for fequency selective fading channel, you also need to specify the equalization algorithm and training mode. 
%If you want to plot dynamic constellation, you also need to specify at which SNR the constellation is drawed. 
%For random source data, you need to specify the data length; for image data, you need to specify a image path. 
%I set the same SNR for showing received image, but you may change it in program.
%Don't be panic about all the setting above. Actually I have set all default values there,
%so you may just press enter for those default options. 
%Hope you will enjoy it!
%
%Chen Zhifeng
%UFID 12181197
%2007-04-28
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------

close all;
clear all;
clc;

%--------------------------------------------------------------------------
%Set parameters
%There are three places to set the parameters:
%default setting in main file, default setting in playdemo file, and user
%setting in playdemo file
%--------------------------------------------------------------------------
Max_dB = 10;   %total 11 dB, begin from 0dB
modtype = 'psk';
M=4;                    %M-ary
gray_encode = 1;
VarChan = 'AWGN';
Tr_pctg = 0.08;             %training percentage, default use 8%
plot_const = 1;
ebn0_for_plot = round(Max_dB/2);      %default use 6th dB in the [0:Max_dB]
eq_alg = 'LMS';
ResetBeforeFiltering = 0;
training_mode = 'training_only';        %decision_directed or training_only
Ndata = 200000;      %to limit 1000000 samples for matlab ptocessing
Test_image = 1;
Image_name = 'photo.bmp';
switch VarChan
    case 'AWGN'
        velocity = 0;               %while in AWGN channel, this parameter is actually not used
    case 'flat'
        velocity = 20;              %20 - 120 km/hr, set default velocity for flat fading
    case 'FSF'
        velocity = 5;               %5 km/hr, set default velocity for frequency selective fading
    otherwise
end

disp('This program is writen for EEL6509 course project');
disp('It can run either in default mode or play mode');
disp('If you do not want to continue, you may use Ctrl+C to exit anytime');
disp('Would you like to play this program? please choose:  ');
play_type = 0;
play_type = input('0: I do not want to play; 1: let me try; [default is 0] : ');
if play_type
    output = playdemo();
    M = output.M;
    gray_encode = output.gray_encode;
    VarChan = output.VarChan;
    Tr_pctg = output.Tr_pctg;
    plot_const = output.plot_const;
    ebn0_for_plot = output.ebn0_for_plot;
    eq_alg = output.eq_alg;
    ResetBeforeFiltering = output.ResetBeforeFiltering;
    training_mode = output.training_mode;
    output.Ndata = Ndata;
    Test_image = output.Test_image;
    Image_name = output.Image_name;
    velocity = output.velocity;
end

k=log2(M);

switch VarChan
    case 'AWGN',
        ebn0DB=[0:1:Max_dB];
    case 'flat',
        ebn0DB = [0:2:2*Max_dB];
    case 'FSF',
        ebn0DB = [0:3:3*Max_dB];
    otherwise,
end

ebn0=10.^(ebn0DB/10);
esn0=k*ebn0;
%--------------------------------------------------------------------------
%produce data
%--------------------------------------------------------------------------
%use this method because we may transmit data from file, such as a image
%len=1000;
Data=randint(1,Ndata,M);
if Test_image == 1    
    im = imread(Image_name);
    disp('showing original image');
    image(im);
    drawnow
    [Data, row_im, col_im, third_im] = image2data(im, M);
end
Ndata = length(Data);

%before insert training data, we need to know one coherent time contains how
%many symbols
switch VarChan
    case 'flat'
        [h,Tc,Ts] = MyRayleigh(100000, velocity);
        Maxpercoh = floor(Tc/Ts);
    case 'FSF'
        [h,Tc,Ts,Lc]=MyRayleighPDP(100000, velocity);
        Maxpercoh = floor(Tc/Ts);
    case 'AWGN'
        Maxpercoh = 0;
    otherwise
end

%if or(isequal(VarChan, 'flat'), isequal(VarChan, 'FSF'))
if Maxpercoh    
%    Maxpercoh = 2000;        %suppose worst case is 100 samples per coherent time for GSM
    Nonetrain = ceil(Tr_pctg * Maxpercoh);      %number of one time training, actually Nonetrain is calculated by floor(SamplesPerCoh/10)
    Nonedata = Maxpercoh - Nonetrain;

    Niter = ceil(Ndata/Nonedata);   %number of interation for get a statistical avarege
    if Niter < 50
        disp(sprintf('caution!! Only %d iterations for your data length!', Niter))
        disp(sprintf('Your velocity is %d km/hr, which results number of symbols per conherence time are %d', velocity, Maxpercoh))
        disp(sprintf('to get better simulate result, suggest you to set 50 iteration, so you may set data length as %d', Maxpercoh*50))
        input('would you continue? press enter to continue, or press ctrl+c to exit')
    end
    datalen = Niter*(Nonedata+Nonetrain);      %to get 1000000
    Data_Ins = [Data, zeros(1, Niter*Nonedata - Ndata)];    %insert data here to make Niter an integer

    Transmit = zeros(1,datalen);
    for index = 0: Niter-1,
        Ttr = randint(1,Nonetrain,M);
        %Ttr = ones(1,Nonetrain);
        Transmit(index*Maxpercoh+1:index*Maxpercoh+Nonetrain) = Ttr;
        Transmit(index*Maxpercoh+Nonetrain+1:index*Maxpercoh+Maxpercoh) = Data_Ins(index * Nonedata +1 : index * Nonedata + Nonedata);
    end

else
    Transmit = Data;
    datalen = length(Transmit);
end
%Traning=randint


%--------------------------------------------------------------------------
%encode
%--------------------------------------------------------------------------
dataenc = 'nondiff';
if gray_encode
    % Create Gray encoding and decoding arrays
    grayencod = bitxor(0:M-1, floor((0:M-1)/2));
    [dummy graydecod] = sort(grayencod); graydecod = graydecod - 1;

    % Gray encode symbols
    Transmit_gray = grayencod(Transmit+1);
end
%--------------------------------------------------------------------------
%Modulation
%--------------------------------------------------------------------------
if gray_encode
    S = MPSK_mod(Transmit_gray, M);
else
    S = MPSK_mod(Transmit, M);
end

%--------------------------------------------------------------------------
%all other processing including producing channel, channel estimation,
%channel adjustment, equlization, plot constellation, demodulation, and BER plot
%--------------------------------------------------------------------------
%Initialization
ser=zeros(size(ebn0));
ber=zeros(size(ebn0));
ser_com=zeros(size(ebn0));  %ser_com is without channel estimation, for compare with ser
ber_com=zeros(size(ebn0));
%uniform the noise power by 1/var=SNR=Es/(N0/2)=2*k*ebn0
std=(1/2/k./ebn0).^0.5;
%std=std/2^.5;    %sqrt(2) for complex Gaussian variance

switch VarChan
    case 'flat'
        for i_ebn0 = 1:length(ebn0),
            disp('Program is running... ')
            disp(sprintf('we need to plot figure for %d different ebn0, This is the %d th, ebn0 = %d dB ' , length(ebn0), i_ebn0, ebn0DB(i_ebn0)));

            %produce channel

            [h,Tc,Ts]=MyRayleigh(datalen, velocity);

%             %----------------------------------------------------------------            
%             %here is for test channel estimation by using constant channel
%             h = (0.707+j*0.707)*ones(1,length(h));
%             %----------------------------------------------------------------            
            
            %         SamplesPerCoh = floor(Tc/Ts);          %samples per coherence time
            %         %SamplesTotal should have upper bound and low bound. Usually we need Niter=1000 to simulate a fading channel, so 1000*SamplesPerCoh<=Niter*SamplesPerCoh<=1000000
            %         %Niter = min(1000, ceil(1000000/SamplesPerCoh)); %set 1000000 to avoid excessing matlab processing capability
            %         if SamplesPerCoh > (datalen/Niter)
            %             %disp(sprintf('samples per coherence time is %d', SamplesPerCoh));
            %             Niter = floor(datalen/SamplesPerCoh);     %set 1000000 to avoid excessing matlab processing capability
            %         end
            %         datalen = Niter*SamplesPerCoh;
            %         Nonetrain = floor(SamplesPerCoh/10);           %use 10 percent of data to train
            %disp(sprintf('the total number of samples is %d, and datalen is truncated to %d', length(h), datalen));

            %pass fading channel
            Fading = S.*h;

            %add AWGN
            Z = std(i_ebn0)*( randn(1,datalen)+j*randn(1,datalen) );
            R = Fading + Z;
            
            %Begin Channel estimation and adjust
            Sa = [];
            Ra = [];
            Rb = [];
            %ith = randint(1,1,Niter);        %constellation comparison will plot in ith coherent time
            for index = 0:Niter-1,
                %traning
                Rtr = R(index * Maxpercoh +1 : index * Maxpercoh + Nonetrain);
                Str = S(index * Maxpercoh +1 : index * Maxpercoh + Nonetrain);
                Rdata = R(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);
                Sdata = S(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);
                Fdata = Fading(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);  %just for plot usage
                
                [AdjAmpl, AdjPhase] = CE_flat(Rtr, Str, Rdata, Sdata);

                %use trained result to adjust data
                Radj = Rdata.*exp(-j*AdjPhase);
                Fadj = Fdata.*exp(-j*AdjPhase);         %just for plot usage
                
              
                %to recombine the wanted data after discard traning data
                Ra = [Ra, Radj];        %Received data after adjustment
                Rb = [Rb, Rdata];       %Received data before adjustment
                Sa = [Sa, Sdata];       %Sent data before fading channel

                %plot constellation
                if plot_const & ((i_ebn0-1) == ebn0_for_plot)
                    if index == 0
                        disp(' ');
                        disp(sprintf('ploting constellation, there are %d times of iteration, so it may take some time', Niter));
                        disp(' ');
                    end
                    Constellation_flat(Sdata, Rdata, Radj, Fdata, Fadj, AdjAmpl, AdjPhase, index+1);
                end
            end
%             %---------------------------------------------------------
%             %here is to test how many the phase estimation error, and
%             %its distribution
%             err_esti = Ra./Sa;
%             ErrPhase_esti = atan2(imag(err_esti), real(err_esti));
%             ErrPhase_esti_mean(i_ebn0) = mean(ErrPhase_esti);
%             figure;hist(ErrPhase_esti,100);
%             err_wo_esti = Rb./Sa;
%             ErrPhase_wo_esti = atan2(imag(err_wo_esti), real(err_wo_esti));
%             ErrPhase_wo_esti_mean(i_ebn0) = mean(ErrPhase_wo_esti);
%             figure;hist(ErrPhase_wo_esti,100);
%             %---------------------------------------------------------

            %demodulation
            Receive = MPSK_demod(Ra, Sa, M);
            Receive_wo = MPSK_demod(Rb, Sa, M);

            if gray_encode
                % Gray decode message
                Receive = graydecod(Receive+1);
                Receive_wo = graydecod(Receive_wo+1);
            end
            
            %to truncate the data to original length, note we do the
            %process above: Data = [Data, zeros(1, Niter*Nonedata - Ndata)];
            Receive = Receive( 1 : Ndata );     %k is the bits per symbol
            Receive_wo = Receive_wo( 1 : Ndata );

            %calculate ber
            [number(i_ebn0),ber(i_ebn0)] = biterr(Receive,Data);
            [numser(i_ebn0),ser(i_ebn0)] = symerr(Receive,Data);

            [number(i_ebn0),ber_wo(i_ebn0)] = biterr(Receive_wo,Data);
            [numser(i_ebn0),ser_wo(i_ebn0)] = symerr(Receive_wo,Data);

            if Test_image & (i_ebn0-1 == ebn0_for_plot)
                ima_wo = data2image(Receive_wo, row_im, col_im, third_im, M);
                ima_wo = uint8(ima_wo);
                imwrite(ima_wo, 'Received_image.bmp');
                disp(' ');
                disp('have save the received image as Received_image.bmp in the same directory');
                disp(' ');
                f_rcv = figure;
                image(ima_wo);
                set(f_rcv, 'name', 'Received image');
                drawnow
                
                ima = data2image(Receive, row_im, col_im, third_im, M);
                ima = uint8(ima);
                imwrite(ima, 'Adjusted_image.bmp');
                disp(' ');
                disp('have save the Adjusted image as Adjusted_image.bmp in the same directory');
                disp(' ');
                f_adj = figure;
                image(ima);
                set(f_adj, 'name', 'Adjusted image');
                drawnow
            end


        end
        %plot BER of flat fading
        BER_flat(ebn0DB, ber, ber_wo, ser, ser_wo, modtype, M);
%         figure;plot(ErrPhase_esti_mean, 'bx');hold on;
%         plot(ErrPhase_wo_esti_mean, 'r+');



    case 'FSF'                     %frequency selective fading
        
        nWeights = 8;

        switch eq_alg

            case 'LMS',
                stepsize = 0.01
                eqObj = lineareq(nWeights, lms(stepsize)); % Create an equalizer object.
                eqObj.SigConst = MPSK_mod([0:M-1],M); % Set signal constellation.
            case 'RLS',
                forgetFactor = 0.99  % RLS algorithm forgetting factor
                eqObj = lineareq(nWeights, rls(forgetFactor)); % Create an equalizer object.
                eqObj.SigConst = MPSK_mod([0:M-1],M); % Set signal constellation.


            otherwise,
                disp('please set which algorithm you want to use, LMS or RLS?');
        end
        eqObj.ResetBeforeFiltering = ResetBeforeFiltering;

        for i_ebn0 = 1:length(ebn0),
            disp('Program is running... ')
            disp(sprintf('we need to plot figure for %d different ebn0, This is the %d th, ebn0 = %d dB ' , length(ebn0), i_ebn0, ebn0DB(i_ebn0)));

            %produce channel

            [h,Tc,Ts,Lc]=MyRayleighPDP(datalen, velocity);
%             %----------------------------------------------------------------            
%             %here is for test adaptive equalizer by using constant channel
%             [test_row, test_col] = size(h);            
%             test_v = [1.0000, 0.3163, 0.1001, 0.0317, 0.0100];
%             test_1 = rand(1, 5)*2*pi;
%             test_2 = exp(j*test_1);
%             test_3 = test_2.*test_v;
%             h = test_3'*ones(1,test_col);
%             %----------------------------------------------------------------            
           
            %pass fading channel
            Fading  = zeros(1, length(S)+Lc-1);
            for i_tap = 1:Lc,
                Si(i_tap,:) = [zeros(1,i_tap - 1), S, zeros(1,Lc - i_tap)];
                hi(i_tap,:) = [h(i_tap,:), zeros(1,Lc-1)];
                temp = Si(i_tap,:) .* hi(i_tap,:);
                Fading = Fading+temp;
            end
            Fading = Fading(1:length(S));

            %add AWGN
            Z = std(i_ebn0)*( randn(1,datalen)+j*randn(1,datalen) );
            R = Fading + Z;
            
            %Begin Channel estimation and adjustment
            Sa = [];
            Ra = [];
            Rb = [];
            for index = 0:Niter-1,
                Rtr = R(index * Maxpercoh +1 : index * Maxpercoh + Nonetrain);
                Str = S(index * Maxpercoh +1 : index * Maxpercoh + Nonetrain);
                Rdata = R(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);
                Sdata = S(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);
                Sdata_wo_mod = Transmit(index * Maxpercoh + Nonetrain +1 : index * Maxpercoh + Maxpercoh);

                if eqObj.ResetBeforeFiltering
                    eqObj.weights  = zeros(size(eqObj.weights));
                end
                switch training_mode
                    case 'decision_directed',
                        [Radj, Receive_data, err_eq] = equalize(eqObj, [Rtr, Rdata], Str); % Equalize.
                        Radj = Radj(Nonetrain +1 : Maxpercoh);  %get adjusted Rdata
                        %Receive_data is a by product here, we don't use it
                        Receive_data = Receive_data(Nonetrain +1 : Maxpercoh);

                    case 'training_only'
                        [Radj_tr,Receive_data,err_eq] = equalize(eqObj, Rtr, Str); % Equalize.
                        %[y, yd, err] = equalize(eq1, [rxSamples0(1:nTrain+eqDelay/eq1.nSampPerSym)], xTrain);
                        Radj = filter(eqObj.Weights,1,Rdata);
%                     case 'decision_directed',
%                         [Req, Receive_data, err_eq] = equalize(eqObj, [Rtr, Rdata], Str); % Equalize.
%                         Req_tr =  Req(1 : Nonetrain);  %get equalized Rtr
%                         Req_data = Req(Nonetrain +1 : Maxpercoh);  %get equalized Rdata but before adjustment
%                         %Receive_data is a by product here, we don't use it
%                         Receive_data = Receive_data(Nonetrain +1 : Maxpercoh);
% 
%                     case 'training_only'
%                         [Req_tr,Receive_data,err_eq] = equalize(eqObj, Rtr, Str); % Equalize.
%                         %[y, yd, err] = equalize(eq1, [rxSamples0(1:nTrain+eqDelay/eq1.nSampPerSym)], xTrain);
%                         Req_data = filter(eqObj.Weights,1,Rdata);

                    otherwise,
                        disp('please set training_only mode or decision_directed mode');
                end
                        
%                 [AdjAmpl, AdjPhase] = CE_flat(Req_tr, Str, 0,0);
%                 %use trained result to adjust phase after equalization. It
%                 %seems no need, equlizer seems adjust phase already!!!
%                 Radj = Req_data.*exp(-j*AdjPhase);

                
                Ra = [Ra, Radj];        %Received data after equlization and phase adjustment
                Rb = [Rb, Rdata];       %Received data before equlization
                Sa = [Sa, Sdata];       %Sent data before fading channel

                 
                %plot constellation
                if plot_const == 1
                    switch modtype
                        case 'psk',
                            if (i_ebn0-1) == ebn0_for_plot;
                                if index == 0
                                    disp(' ');
                                    disp(sprintf('ploting constellation, there are %d times of iteration, so it may take some time', Niter));
                                    disp(' ');
                                end
                                weights = eqObj.weights;
                                Constellation_FSF(Sdata, Rdata, Radj, Sdata_wo_mod, M, gray_encode, err_eq, weights, ebn0_for_plot, index+1);
                            end
                        otherwise,
                            disp('only psk modulation can be plot at present');
                    end
                end
                
           end



            %demodulation
            Receive = MPSK_demod(Ra, Sa, M);
            Receive_wo = MPSK_demod(Rb, Sa, M);

            if gray_encode
                % Gray decode message
                Receive = graydecod(Receive+1);
                Receive_wo = graydecod(Receive_wo+1);
            end
            
            %to truncate the data to original length, note we do the
            %process above: Data = [Data, zeros(1, Niter*Nonedata - Ndata)];
            Receive = Receive( 1 : Ndata );     %k is the bits per symbol
            Receive_wo = Receive_wo( 1 : Ndata );
            
            %calculate ber
            [number(i_ebn0),ber(i_ebn0)] = biterr(Receive,Data);
            [numser(i_ebn0),ser(i_ebn0)] = symerr(Receive,Data);

            [number(i_ebn0),ber_wo(i_ebn0)] = biterr(Receive_wo,Data);
            [numser(i_ebn0),ser_wo(i_ebn0)] = symerr(Receive_wo,Data);

            if Test_image & (i_ebn0-1 == ebn0_for_plot)
                ima_wo = data2image(Receive_wo, row_im, col_im, third_im, M);
                ima_wo = uint8(ima_wo);
                imwrite(ima_wo, 'Received_image.bmp');
                disp(' ');
                disp('have save the received image as Received_image.bmp in the same directory');
                disp(' ');
                f_rcv = figure;
                image(ima_wo);
                set(f_rcv, 'name', 'Received image');
                drawnow
                
                ima = data2image(Receive, row_im, col_im, third_im, M);
                ima = uint8(ima);
                imwrite(ima, 'Equalized_image.bmp');
                disp(' ');
                disp('have save the Equalized image as Equalized_image.bmp in the same directory');
                disp(' ');
                f_adj = figure;
                image(ima);
                set(f_adj, 'name', 'Equalized image');
                drawnow
            end

        end
        %plot BER of flat fading
        BER_FSF(ebn0DB, ber, ber_wo, ser, ser_wo, modtype, M);

    case 'AWGN'
        for i_ebn0 = 1:length(ebn0),
            disp('Program is running... ')
            disp(sprintf('we need to plot figure for %d different ebn0, This is the %d th, ebn0 = %d dB ' , length(ebn0), i_ebn0, ebn0DB(i_ebn0)));

            %add AWGN
            Z = std(i_ebn0)*( randn(1,datalen)+j*randn(1,datalen) );
            R=S+Z;

            %demodulation
            Receive = MPSK_demod(R, S, M);
            
            if gray_encode
                % Gray decode message
                Receive = graydecod(Receive+1);
            end

            %calculate ber
            [number(i_ebn0),ber(i_ebn0)] = biterr(Receive,Transmit);
            [numser(i_ebn0),ser(i_ebn0)] = symerr(Receive,Transmit);

            if Test_image & (i_ebn0-1 == ebn0_for_plot)
                ima = data2image(Receive, row_im, col_im, third_im, M);
                ima = uint8(ima);
                imwrite(ima, 'Received_image.bmp');
                disp(' ');
                disp('have save the received image as Received_image.bmp in the same directory');
                disp(' ');
                figure;
                image(ima);
                drawnow
            end

        end

        %plot BER of AWGN
        BER_AWGN(ebn0DB, ber, ser, modtype, M, dataenc);
    otherwise,
        disp('the channel type has not be set');
end






