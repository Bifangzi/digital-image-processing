clc; clear; close all;

% 1. 读取图像并转为二值图
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif'}, '选择残缺文字图像');
if isequal(filename, 0), disp('用户取消'); return; end
img = im2gray(imread(fullfile(pathname, filename)));
binaryImg = imbinarize(img, graythresh(img)); % 自动阈值二值化

% 2. 预处理：去除小噪声（可选）
cleanImg = bwareaopen(binaryImg, 1); % 移除面积小于20像素的噪声

% 3. 形态学修复（核心步骤）
% 根据文字断裂方向选择结构元素（例如水平断裂用水平线核）
se_horizontal = strel('line', 5, 0);   % 水平线，长度5，角度0°
se_vertical = strel('line', 5, 90);    % 垂直线，长度5，角度90°
se_disk = strel('disk', 2);            % 通用圆形核

% 闭运算填充断裂
closedImg = imclose(cleanImg, se_horizontal);

% 膨胀加粗笔画（可选）
dilatedImg = imdilate(closedImg, se_disk);

% 4. 后处理：细化文字（若膨胀导致过粗）
skeletonImg = bwmorph(dilatedImg, 'skel', Inf); % 骨架提取

% 5. 显示结果
figure;
subplot(2,2,1), imshow(binaryImg), title('原始二值图像');
subplot(2,2,2), imshow(closedImg), title('闭运算修复后');
subplot(2,2,3), imshow(dilatedImg), title('膨胀加粗');
subplot(2,2,4), imshow(skeletonImg), title('骨架细化');

% 6. 保存结果
imwrite(skeletonImg, 'repaired_text.png');