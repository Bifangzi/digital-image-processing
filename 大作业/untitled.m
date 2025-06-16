%% 清空环境
clear;clc;
close all

%% 参数定义

conn = 8;       %连通类型

Number = 280;   %斑点数量

se_list = {'square','disk','diamond'};  %形态学结构列表
se_list_img = zeros(41,41,3);
r = linspace(1,20,20);                  %结构半径

result = zeros(length(r),6);            %保存统计结果

% 读取图像
% [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', '图像文件 (*.jpg, *.png, *.bmp, *.tif)'}, '选择要处理的图像');
% if isequal(filename, 0)
%     disp('用户取消了选择');
%     return;
% end
% imagePath = fullfile(pathname, filename);
% originalImage = imread(imagePath);
% figure;
% imshow(originalImage);
% title("原始图像")

originalImage = imread("testphoto.jpg");
figure;
imshow(originalImage);
title("原始图像")

%% 添加模拟噪声
% img_noise = imnoise(originalImage,'salt & pepper', 0.01);
% imshow(img_noise)

%% 预处理
figure;
imhist(originalImage,255);
title("图像灰度分布")

T = inputdlg("请输入二值化阈值");
T = str2double(T{1});

figure;
img_bw = imbinarize(originalImage,T/256);
imshow(img_bw)
title("二值化图象")

ans0 = bwconncomp(img_bw,conn);



count = 1;
%% 形态学处理
for s = se_list
    for i = r
    
        se=strel(s{1},i);  % 圆盘型结构元素
        
        img_erode = imerode(img_bw,se);
%         figure;
%         imshow(img_erode)
        
        
         ans1 = bwconncomp(img_erode,conn);
         result(i,count*2-1) = ans1.NumObjects;
         result(i,count*2) = ans1.NumObjects/Number;
        
         fprintf("腐蚀结构半径为: %d\n",i);
         fprintf('处理前图像中白色斑点的数量为: %d\n', ans0.NumObjects);
         fprintf("识别正确率: %.3f\n",ans0.NumObjects/Number)
         fprintf('处理后图像中白色斑点的数量为: %d\n', ans1.NumObjects);
         fprintf("识别正确率: %.3f\n",ans1.NumObjects/Number)
    
    end
    count = count + 1;
    figure;
%     se_list_img(:,:,count)=se.Neighborhood;
    imshow(se.Neighborhood)



end
figure;
title("不同形态学结构处理结果");
xlabel("半径")
yyaxis left
bar1(:,1) = result(:,1);
bar1(:,2) = result(:,3);
bar1(:,3) = result(:,5);
GO = bar(bar1,1,'EdgeColor','black');
GO(1).FaceColor = [204/255,124/255,113/255];
GO(2).FaceColor = [122/255,182/255,86/255];
GO(3).EdgeColor = [126/255,153/255,244/255];
ylabel('统计斑点数量','FontName', '宋体')

yyaxis right
line1(:,1) = result(:,2);
line1(:,2) = result(:,4);
line1(:,3) = result(:,6);
P = plot(r,line1);
P(1).LineWidth = 1.5;
P(2).LineWidth = 1.5;
P(3).LineWidth = 1.5;
P(1).Color = [204/255,124/255,113/255];
P(2).Color = [122/255,182/255,86/255];
P(3).Color = [126/255,153/255,244/255];
P(1).Marker = "o";
P(2).Marker = "*";
P(3).Marker = "x";
ylabel('统计正确率','FontName', '宋体')
legend(se_list)
grid on