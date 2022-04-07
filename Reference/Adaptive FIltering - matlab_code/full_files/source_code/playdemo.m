%--------------------------------------------------------------------------
%this function is to set parameters for the program to run in play mode
%
%Chen Zhifeng
%UFID 12181197
%2007-05-19
%zhifeng@ecel.ufl.edu
%--------------------------------------------------------------------------
function output = playdemo()
disp(' ')
disp(' ')
disp('You need to specify the modulation type, channel type, estimation mode, and training mode;');
disp('For fequency selective fading channel, you also need to specify the equalization algorithm;');
disp('If you like to see the constellation, you need to specify which SNR for drawing;');
disp('If there is default option, you may just press enter to use the default setting;');
input('press enter to play it :-)')
disp(' ')
disp(' ')

%if without default setting here, we need to check which variable is not
%set in main file. For example, if user choose AWGN or flat fading, then
%eq_alg, training_mode and ResetBeforeFiltering is no return value
M=4;                    %M-ary
gray_encode = 1;
VarChan = 'AWGN';
Tr_pctg = 0.08;             %training percentage, default use 8%
eq_alg = 'LMS';
ResetBeforeFiltering = 0;
training_mode = 'training_only';        %decision_directed or training_only
plot_const = 1;
ebn0_for_plot = 5;      %default use 6th dB in the [0:Max_dB]
Ndata = 200000;      %to limit 1000000 samples for matlab ptocessing
Test_image = 1;
Image_name = 'photo.bmp';
velocity = 0;

disp('at present, modulation type only support psk modulation');

M = input('please set modulation order: 2 = BPSK, 4 = QPSK, 8 = 8PSK [default is QPSK] : ');
if isequal(M,[])
    M = 4;
end
M

gray_encode = input('would you like to use gray encode? 0: No; 1: Yes [default is Yes] : ');
if isequal(gray_encode,[])
    gray_encode = 1;
end
gray_encode

VarChan = input('please choose channel type, 0: AWGN; 1: flat; 2: FSF, [default is AWGN] : ');
if isequal(VarChan,[])
    VarChan = 0;
end
switch VarChan
    case 0,
        VarChan = 'AWGN'
    case 1,
        VarChan = 'flat'
    case 2,
        VarChan = 'FSF'
    otherwise,
end

if isequal(VarChan, 'AWGN')==0
    Tr_pctg = input('please set the percentage of training data length, [default is 8%] : ');
    if isequal(Tr_pctg,[])
        Tr_pctg = 0.08;
    end
    Tr_pctg

%     plot_const = input('would like to plot constellation, 0: No, 1: Yes, [default is yes] : ');
%     if isequal(plot_const,[])
%         plot_const = 1;
%     end
%     plot_const
    plot_const = 1; %It is better for user to see the plot
    
    if plot_const == 1;
        disp('please specify which dB for plot');
        disp('[0:2:2*10] for flat fading');
        disp('[0:3:3*10] for frequency selective fading');

        ebn0_for_plot = input('range from 0 to 10, [default is 5] : ');
        if isequal(ebn0_for_plot,[])
            ebn0_for_plot = 5;
        end
        ebn0_for_plot
    end
end

switch VarChan
    case 'flat',
        disp('you are now in a train with 20km/hr-120km/hr in Suburban environement :-|');
        velocity = input('please set the velocity, range(20~120km/hr), [default is: 20km/hr] : ');
        if isequal(velocity,[])
            velocity = 20;
        end
        velocity
    case 'FSF',
        velocity = 5;
        disp('you are now walking with 5km/hr in urban environement :-)');
        eq_alg = input('please choose equalization algorithm, 0: LMS; 1: RLS, [default is LMS] : ');
        if isequal(eq_alg,[])
            eq_alg = 0;
        end
        switch eq_alg
            case 0,
                eq_alg = 'LMS'
            case 1,
                eq_alg = 'RLS'
            otherwise,
        end
        
        disp('please choose channel estimation mode:');
        disp('0: without reset result from last coherent time; 1: reset result from last coherent time;');
        ResetBeforeFiltering = input('[default is without reset] : ');
        if isequal(ResetBeforeFiltering,[])
            ResetBeforeFiltering = 0
        end

        disp('please choose training mode, 0: training only mode; 1: decision directed mode;');
        training_mode = input('[default is training only mode] : ');
        if isequal(training_mode,[])
            training_mode = 0;
        end

        switch training_mode
            case 0,
                training_mode = 'training_only'
            case 1,
                training_mode = 'decision_directed'
            otherwise,
        end

    otherwise,
end

Test_image = input('would you like to transmit a image file over this channel? 1: yes, 0: no, [default is Yes] : ')
if isequal(Test_image,[])
    Test_image = 1;
end
Test_image

if Test_image
    disp('please specify a image file name here including path, the file size should not exceed 400KB');
    disp('if it is in the same directory, just input filename, [default is: photo.bmp] : ');
    Image_name = input('filename: ','s');
    if isequal(Image_name,[])
        Image_name = 'photo.bmp';
    end
    Image_name
else
    Ndata = input('please set the source data length, [default is 200000] : ');
    if isequal(Ndata,[])
        Ndata = 200000;
    end
    Ndata
end

output.M = M;
output.gray_encode = gray_encode;
output.VarChan = VarChan;
output.Tr_pctg = Tr_pctg;
output.plot_const = plot_const;
output.ebn0_for_plot = ebn0_for_plot;
output.eq_alg = eq_alg;
output.ResetBeforeFiltering = ResetBeforeFiltering;
output.training_mode = training_mode;
output.Ndata = Ndata;
output.Test_image = Test_image;
output.Image_name = Image_name;
output.velocity = velocity;

