%% 清空环境
clear;clc;
close all


%% 读取图像
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', '图像文件 (*.jpg, *.png, *.bmp, *.tif)'}, '选择要处理的图像');
if isequal(filename, 0)
    disp('用户取消了选择');
    return;
end
imagePath = fullfile(pathname, filename);
originalImage = imread(imagePath);
figure('Name',"原始图像")
imshow(originalImage);



%% 预处理


