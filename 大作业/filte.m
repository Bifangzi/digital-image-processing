close all

originalImage = imread("9.36.jpg");
figure;
imshow(originalImage);
title("原始图像")

img_noise = imnoise(originalImage,'salt & pepper', 0.01);
% figure;
% imshow(img_noise)
% title("带噪图像")

se = strel('disk',1);
J1 = imclose(img_noise,se);
J2 = imopen(J1,se);
% J3 = imclose(J2,se);
% J4 = imopen(J3,se);
figure('Name','形态学滤波');
subplot(1,3,1)
imshow(img_noise)
title("带噪图像")
subplot(1,3,2)
imshow(J1)
title("闭运算")
subplot(1,3,3)
imshow(J2)
title("开运算")

% m = medfilt2(img_noise,3)
% figure;
% imshow(m)

% zp = BaseZoom();
% zp.run;
