%% 清空环境
close all;
clear;clc;

%% 读取实验图像

photo_a = imread("house.jpg");
photo_b = imread("M_M.bmp");

% 图像a存在白色边框，剔除以避免影响后续边缘提取
photo_a = photo_a(3:243,2:322,:);


%% 显示图像

figure('Name','显示图像');
subplot(1,2,1);
imshow(photo_a);
title("house.jpg");
subplot(1,2,2);
imshow(photo_b);
title("M\_M.bmp");


%% Sobel、roberts和prewitt边缘检测算子

% 灰度化原始图像
photo_a = rgb2gray(photo_a);
photo_b = rgb2gray(photo_b);

%选择边缘检测的原图像
testphoto = photo_a;

figure('name','边缘检测');
subplot(3,2,1);
imshow(testphoto);
title("检测图像");

% Sobel算子
sobel_edge = edge(testphoto,"sobel");
subplot(3,2,2);
imshow(sobel_edge);
title("Sobel边缘检测");

% Roberts算子
roberts_edge = edge(testphoto,"roberts");
subplot(3,2,3);
imshow(roberts_edge);
title("Roberts边缘检测");

% prewitt算子
prewitt_edge = edge(testphoto,"roberts");
subplot(3,2,4);
imshow(prewitt_edge);
title("Prewitt边缘检测");


%% log和Canny边缘检测算子

% log算子
log_edge = edge(testphoto,"log");
subplot(3,2,5);
imshow(log_edge);
title("log边缘检测");

% Canny算子
Canny_edge = edge(testphoto,"canny");
subplot(3,2,6);
imshow(Canny_edge);
title("Canny边缘检测");



% 选择边缘检测算子结果
binaryEdgeImage = roberts_edge;

% 显示二值边缘图像
figure('Name','边缘二值图像');
imshow(binaryEdgeImage);
title('边缘二值图像');



%% 对边缘二值图像进行Hough变换
[H, theta, rho] = hough(binaryEdgeImage);

% 显示Hough变换结果
figure('Name','Hough变换结果');
imshow(imadjust(rescale(H)), 'XData', theta, 'YData', rho,...
      'InitialMagnification', 'fit');
title('Hough变换结果');
xlabel('\theta (degrees)');
ylabel('\rho');
axis on;
axis normal;
hold on;
colormap(gca, "turbo");
colorbar;

% 寻找Hough变换的峰值点
peaks = houghpeaks(H, 5);
x = theta(peaks(:, 2));
y = rho(peaks(:, 1));
plot(x, y, 's', 'color', 'blue');

% 根据峰值点找到对应的线段
lines = houghlines(binaryEdgeImage, theta, rho, peaks, 'FillGap', 5, 'MinLength', 7);

% 在原图上绘制检测到的线段
figure('Name','直线提取');
imshow(testphoto), hold on;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
end
title('Hough变换检测到的直线');
