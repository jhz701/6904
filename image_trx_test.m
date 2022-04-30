close all;
image = imread('Lenna.bmp');
[img_data, row_im, col_im, third_im] = image2data(im2gray(image),2);
orig_len   = length(img_data);
target_len = ceil(orig_len/5);
pad_len    = target_len*5 - orig_len;
img_data   = [img_data zeros(1,pad_len)];
img_data_32 = uint8(zeros(1,target_len));
% Serialize
for i=1:target_len
    word = img_data((i-1)*5+1)*16+img_data((i-1)*5+2)*8+img_data((i-1)*5+3)*4+img_data((i-1)*5+4)*2+img_data((i-1)*5+5);
    img_data_32(i) = word;
end

%% Deserialize
img_data_recovered = zeros(1,target_len*5);
for i=1:target_len
    word = double(drx(i));
    for j=1:5
        b5 = floor(word/16);
        img_data_recovered((i-1)*5+j) = b5;
        word = (word - b5*16)*2;
    end
end

% Remove Padding
img_data_recovered(orig_len+1:orig_len+pad_len) = [];

parfor i=1:length(img_data_recovered)
    if(img_data_recovered(i)<0)
        img_data_recovered(i) = 0;
    end
    if(img_data_recovered(i)>1)
        img_data_recovered(i) = 1;
    end
end
img_rx = data2image(img_data_recovered, row_im, col_im, third_im, 2);

% Show image
figure();
subplot(1,2,1);
imshow(im2gray(image));
title('Original');
subplot(1,2,2);
imshow(uint8(img_rx));
title('Received');
