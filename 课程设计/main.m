%%
clear;clc;
close all

%% 参数设置
sigma = 1.0;          % 高斯滤波器标准差
threshold_low = 50;   % Canny边缘检测低阈值
threshold_high = 150; % Canny边缘检测高阈值
rho_res = 1;          % Hough变换距离分辨率(pixels)
theta_res = pi/180;   % Hough变换角度分辨率(radians)
votes_threshold = 100; % Hough变换投票阈值

%% 读取图像
% 可替换为实际图像路径
image = imread("test.png");
if size(image, 3) > 1
    image = rgb2gray(image); % 转为灰度图
end

%% 显示原始图像
figure('Position', [100, 100, 1200, 800]);
subplot(2, 3, 1);
imshow(image);
title('原始图像');

%% 步骤1: 高斯滤波去噪
filtered_image = imgaussfilt(image, sigma);
subplot(2, 3, 2);
imshow(filtered_image);
title('高斯滤波后图像');

%% 步骤2: 边缘检测
% edge_image = edge(filtered_image, 'Canny', [threshold_low, threshold_high]);
edge_image = edge(filtered_image, 'Canny');
subplot(2, 3, 3);
imshow(edge_image);
title('Canny边缘检测结果');

%% 步骤3: Hough变换检测直线
[H, theta, rho] = hough(edge_image, 'RhoResolution', rho_res, 'ThetaResolution', theta_res);
subplot(2, 3, 4);
imshow(imadjust(mat2gray(H)), 'XData', theta*180/pi, 'YData', rho, 'InitialMagnification', 'fit');
title('Hough变换累积矩阵');
xlabel('\theta (degrees)');
ylabel('\rho (pixels)');
axis on;

% 寻找峰值
peaks = houghpeaks(H, 2, 'Threshold', votes_threshold);
subplot(2, 3, 4);
hold on;
plot(theta(peaks(:, 2))*180/pi, rho(peaks(:, 1)), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
hold off;

% 提取直线
lines = houghlines(edge_image, theta, rho, peaks);
subplot(2, 3, 5);
imshow(image);
title('检测到的直线');
hold on;

% 绘制检测到的直线
max_len = 0;
line_points = zeros(2, 4); % 存储两条直线的端点
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    line_points(k, :) = [xy(1,1), xy(1,2), xy(2,1), xy(2,2)];
    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    
    % 绘制直线端点
    plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
    plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
end
hold off;

%% 步骤4: 计算交点和夹角
if length(lines) >= 2
    % 提取两条直线的端点
    x1 = line_points(1, 1); y1 = line_points(1, 2);
    x2 = line_points(1, 3); y2 = line_points(1, 4);
    x3 = line_points(2, 1); y3 = line_points(2, 2);
    x4 = line_points(2, 3); y4 = line_points(2, 4);
    
    % 计算交点
    denominator = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
    
    if denominator == 0
        disp('错误: 两条直线平行或重合');
    else
        px = ((x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4)) / denominator;
        py = ((x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4)) / denominator;
        
        % 计算直线方向向量
        v1 = [x2-x1, y2-y1];
        v2 = [x4-x3, y4-y3];
        
        % 归一化向量
        v1 = v1 / norm(v1);
        v2 = v2 / norm(v2);
        
        % 计算夹角(弧度)
        cos_theta = dot(v1, v2);
        angle_rad = acos(cos_theta);
        angle_deg = rad2deg(angle_rad);
        
        % 显示结果
        subplot(2, 3, 6);
        imshow(image);
        title(sprintf('交点坐标: (%.2f, %.2f), 夹角: %.2f°', px, py, angle_deg));
        hold on;
        
        % 绘制直线
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
        end
        
        % 绘制交点
        plot(px, py, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        
        % 绘制角度指示
        radius = 50;
        angle1 = atan2(v1(2), v1(1));
        angle2 = atan2(v2(2), v2(1));
        
        % 确保角度在正确范围内
        if angle1 < 0
            angle1 = angle1 + 2*pi;
        end
        if angle2 < 0
            angle2 = angle2 + 2*pi;
        end
        
        % 确定绘制角度的方向
        if angle1 > angle2
            temp = angle1;
            angle1 = angle2;
            angle2 = temp;
        end
        
        % 绘制圆弧
        arc_angles = linspace(angle1, angle2, 100);
        arc_x = px + radius * cos(arc_angles);
        arc_y = py + radius * sin(arc_angles);
        plot(arc_x, arc_y, 'b-', 'LineWidth', 1.5);
        
        % 显示角度值
        mid_angle = (angle1 + angle2) / 2;
        text_x = px + radius*1.2 * cos(mid_angle);
        text_y = py + radius*1.2 * sin(mid_angle);
        text(text_x, text_y, sprintf('%.1f°', angle_deg), 'Color', 'blue', 'FontSize', 12);
        
        hold off;
        
        % 输出结果到命令窗口
        fprintf('交点坐标: (%.2f, %.2f)\n', px, py);
        fprintf('两直线夹角: %.2f°\n', angle_deg);
    end
else
    disp('错误: 未检测到足够的直线');
end