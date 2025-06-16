function [H,theta,rho,x,y,lines] = find_line(image)
%FIND_LINE 此处显示有关此函数的摘要
%   此处显示详细说明
% 对边缘二值图像进行Hough变换
[H, theta, rho] = hough(image);

% 寻找Hough变换的峰值点
peaks = houghpeaks(H, 2);
x = theta(peaks(:, 2));
y = rho(peaks(:, 1));


% 根据峰值点找到对应的线段
lines = houghlines(image, theta, rho, peaks, 'FillGap', 30, 'MinLength', 20);
end

