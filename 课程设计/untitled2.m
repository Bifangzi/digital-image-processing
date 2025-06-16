%% 清空环境

clear;clc;
close all

%% 读取图像

img = imread("test2.jpg");
img = img(:,1:450);
figure;
imshow(img)

%% 预处理

% 转换为灰度图
if size(img,3)>1
    img = im2gray(img);
end

[img_width , img_length] = size(img);

filter = zeros(img_width,img_length);


%% 滤波
m = medfilt2(img,[7 7]);
figure;
imshow(m)
title("中值滤波")
m = imbinarize(m);


%% 边缘提取

% Canny算子
canny_edge = edge(img,"canny");
% subplot(3,2,6);
figure;
imshow(canny_edge);
title("Canny边缘检测");



%% 提取直线

[H, theta, rho,x,y,lines]=find_line(canny_edge);
figure;
imshow(imadjust(rescale(H)), 'XData', theta, 'YData', rho,...
  'InitialMagnification', 'fit');
xlabel('\theta (degrees)');
ylabel('\rho');
axis on;
axis normal;
hold on;
colormap(gca, "turbo");
colorbar;
plot(x, y, 's', 'color', 'blue');

figure(99)
imshow(m), hold on;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
   % 绘制直线端点

   plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
   plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
end



title("Hough变换检测到的直线");


%% 计算直线方程

% 提取线段端点
point_1 = lines(1).point1;
x1 = point_1(1);
y1 = point_1(2);

point_2 = lines(1).point2;
x2 = point_2(1);
y2 = point_2(2);

point_3 = lines(2).point1;
x3 = point_3(1);
y3 = point_3(2);

point_4 = lines(2).point2;
x4 = point_4(1);
y4 = point_4(2);


% 计算两条线段的向量
dx1 = x2 - x1; dy1 = y2 - y1;
dx2 = x4 - x3; dy2 = y4 - y3;

% 检查线段是否平行或共线（避免除以零）
denominator = dy2 * dx1 - dx2 * dy1;

if denominator == 0
    % 线段平行或共线，无交点或无限多交点
    intersection_point = [];
    angle_deg = 0;
    disp('线段平行或共线，无唯一交点');
    return;
end

% 计算参数 t 和 u
t = ((x3 - x1) * dy2 + (y1 - y3) * dx2) / denominator;
u = -((x1 - x3) * dy1 + (y3 - y1) * dx1) / denominator;

% 检查交点是否在线段上
if t >= 0 && t <= 1 && u >= 0 && u <= 1
    intersection_x = x1 + t * dx1;
    intersection_y = y1 + t * dy1;
    intersection_point = [intersection_x, intersection_y];
else
    intersection_point = [];
    disp('线段不相交');
    return;
end

% 计算夹角（单位向量点积）
vec1 = [dx1, dy1];
vec2 = [dx2, dy2];

% 归一化向量
norm_vec1 = vec1 / norm(vec1);
norm_vec2 = vec2 / norm(vec2);

% 计算点积和夹角（弧度）
dot_product = dot(norm_vec1, norm_vec2);
angle_rad = acos(min(max(dot_product, -1), 1)); % 确保在有效范围内

% 转换为角度
angle_deg = rad2deg(angle_rad);



%% 计算交点坐标





%% 计算夹角


%% 

figure(99)
plot(intersection_point(1),intersection_point(2), '*', 'LineWidth', 2, 'Color', 'yellow');

fprintf("交点坐标为：(%.2f,%.2f)",intersection_point(1),intersection_point(2))
fprintf("夹角大小为：%.2f",angle_deg)



