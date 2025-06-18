%% 清空环境

clear;clc;
close all
warning off

%% 设置参数

% 检测要求
isnoline = 0;           %是否要求交点在线上
minangle = 0.01;        %最小夹角（度）

% 噪声参数
which_noise = 0;        %噪声类型 0:高斯白噪声 1:椒盐噪声
d = 0.1;                %椒盐噪声密度
m = 0;                  %高斯噪声均值
var_local = 0.05;        %高斯噪声方差

% 获取屏幕大小用于最大化图窗

scrsz = get(0,'ScreenSize');
scrsz(3) = scrsz(3) - 200;
scrsz(4) = scrsz(4) - 100;

%% 读取图像

[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', '图像文件 (*.jpg, *.png, *.bmp, *.tif)'}, '选择要处理的图像');
if isequal(filename, 0)
    disp('用户取消了选择');
    return;
end
imagePath = fullfile(pathname, filename);

% 提取文件名部分（不含扩展名）
[~, name, ~] = fileparts(filename);

% 转换为数值并计算角度
num = str2double(name);
angle_std = num / 100;  % 除以100得到实际角度值

img = imread(imagePath);
figure;
imshow(img);
title("原始图像")


%% 噪声处理

% 施加高斯白噪声和椒盐噪声
img_pepper_noise = imnoise(img,'salt & pepper', d);
img_gaussian_noise = imnoise(img,'gaussian',m,var_local);
figure;
title("噪声处理")
subplot(1,3,1)
imshow(img)
title("原始图像")
subplot(1,3,2)
imshow(img_pepper_noise)
title("施加椒盐噪声")
subplot(1,3,3)
imshow(img_gaussian_noise)
title("施加高斯白噪声")

% 计算图像的傅里叶频谱

display_image_spectrum(img)
display_image_spectrum(img_pepper_noise)
display_image_spectrum(img_gaussian_noise)

if which_noise
    img_noise = img_pepper_noise;
else
    img_noise = img_gaussian_noise;
end

%% 预处理

% 转换为灰度图
if size(img_noise,3)>1
    img_gray = im2gray(img_noise);
end

[img_width , img_length] = size(img_gray);
% filter = zeros(img_width,img_length);

figure;
imshow(img_gray)
title("灰度化图像")

%% 滤波去噪

% img_medfilt = medfilt2(img_gray,[8 8]);
% img_gaussfilt = imgaussfilt(img_gray);

img_filtered = real_time_filtering_demo(img_gray);
img_filtered = imread("./temp/filtered_img.jpg");
delete("./temp/*")
figure;

imshow(img_filtered)
title("滤波后图像")

testphoto = img_filtered(2:end-1,2:end-1);


%% 边缘提取

f = figure('name','边缘检测');
f.Position = scrsz;
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

% log算子
log_edge = edge(testphoto,"log");
subplot(3,2,5);
imshow(log_edge);
title("log边缘检测");

% Canny算子
canny_edge = edge(testphoto,"canny");
subplot(3,2,6);
imshow(canny_edge);
title("Canny边缘检测");


% 选择边缘检测算子结果
method_list = {'sobel','roberts','prewitt','log','canny'};
[indx,tf] = listdlg('ListString',method_list,...
    'Name','选择边缘检测算子结果','ListSize',[300 200]);

f = figure();
f.Position = scrsz;
for i=1:length(indx)

    switch indx(i)
        case 1
            binaryEdgeImage = sobel_edge;
        case 2
            binaryEdgeImage = roberts_edge;
        case 3
            binaryEdgeImage = prewitt_edge;
        case 4
            binaryEdgeImage = log_edge;
        case 5
            binaryEdgeImage = canny_edge;
    end

    subplot(length(indx),3,3*i-2)
    imshow(binaryEdgeImage);
    title([method_list(indx(i)) "算子结果二值化"])
    [H, theta, rho,x,y,lines]=find_line(binaryEdgeImage);
    subplot(length(indx),3,3*i-1)
    imshow(imadjust(rescale(H)), 'XData', theta, 'YData', rho,...
      'InitialMagnification', 'fit');
    title([method_list(indx(i)) "算子Hough变换结果"]);
    xlabel('\theta (degrees)');
    ylabel('\rho');
    axis on;
    axis normal;
    hold on;
    colormap(gca, "turbo");
    colorbar;
    plot(x, y, 's', 'color', 'red','MarkerSize',12,'LineWidth',2);
    subplot(length(indx),3,3*i)
    imshow(testphoto), hold on;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
       
       % 绘制直线端点

       plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
       plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
    end
    
    title([method_list(indx(i)) "算子Hough变换检测到的直线"]);
end

%% 提取直线

figure(99)
imshow(img), hold on;
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
denominator = abs(dy2 * dx1 - dx2 * dy1);

if denominator/(norm([dx1 dy1])*norm([dx2 dy2]))<sind(minangle)
    % 线段平行或共线，无交点或无限多交点
    intersection_point = [];
    angle_deg = 0;
    disp('线段平行或共线，无唯一交点');
    return;
end

% 计算参数 t 和 u
denominator = dy2 * dx1 - dx2 * dy1;
t = ((x3 - x1) * dy2 + (y1 - y3) * dx2) / denominator;
u = -((x1 - x3) * dy1 + (y3 - y1) * dx1) / denominator;

% 检查交点是否在线段上
if isnoline
    if t >= 0 && t <= 1 && u >= 0 && u <= 1
        intersection_x = x1 + t * dx1;
        intersection_y = y1 + t * dy1;
        intersection_point = [intersection_x, intersection_y];
    else
        intersection_point = [];
        disp('线段不相交');
        return;
    end
end

intersection_x = x1 + t * dx1;
intersection_y = y1 + t * dy1;
intersection_point = [intersection_x, intersection_y];


%% 计算交点坐标

intersection_x = x1 + t * dx1;
intersection_y = y1 + t * dy1;
intersection_point = [intersection_x, intersection_y];


%% 计算夹角

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
if angle_std < 90
    if angle_deg >90
        angle_deg = 180 -angle_deg;
    end
else
    if angle_deg < 90
        angle_deg = 180 - angle_deg;
    end
end

        
%% 显示结果

figure(99)
plot(intersection_point(1),intersection_point(2), 'p','MarkerSize' ,12, 'LineWidth', 2, 'Color', 'red');
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot([xy(1,1) intersection_x], [xy(1,2) intersection_y], '--','LineWidth', 2, 'Color', 'green');
   
end

absolute_error = angle_deg - angle_std;
relative_error = absolute_error/angle_std;

str = sprintf("交点坐标为:(%.2f,%.2f) 夹角为:%.4f",intersection_x,intersection_y,angle_deg);
text(intersection_x,intersection_y+20,str);

fprintf("计算角度绝对误差为:%.4f ,相对误差为:%.4f",absolute_error,relative_error)

% fprintf("交点坐标为：(%.2f,%.2f)",intersection_point(1),intersection_point(2))
% fprintf("夹角大小为：%.2f",angle_deg)



