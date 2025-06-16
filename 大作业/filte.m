close all

originalImage = imread("testphoto.jpg");
figure('Name','形态学滤波');
subplot(1,4,1)
imshow(originalImage);
title("原始图像")

img_noise = imnoise(originalImage,'salt & pepper', 0.07);

se = strel('disk',1);
J1 = imclose(img_noise,se);
J2 = imopen(J1,se);
subplot(1,4,2)
imshow(img_noise)
title("带噪图像")
subplot(1,4,3)
imshow(J1)
title("闭运算")
subplot(1,4,4)
imshow(J2)
title("开运算")

m = medfilt2(img_noise,[3 3]);
figure;
imshow(m)
title("中值滤波")

% zp = BaseZoom();
% zp.run;
