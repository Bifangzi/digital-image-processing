% MATLAB图像膨胀操作脚本
clc;        % 清空命令窗口
clear;      % 清空工作区变量
close all;  % 关闭所有图形窗口

% 1. 读取图像
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', '图像文件 (*.jpg, *.png, *.bmp, *.tif)'}, '选择要处理的图像');
if isequal(filename, 0)
    disp('用户取消了选择');
    return;
end
imagePath = fullfile(pathname, filename);
originalImage = imread(imagePath);

% 2. 如果图像是彩色图，转换为灰度图
if size(originalImage, 3) == 3
    grayImage = rgb2gray(originalImage);
    disp('已自动将彩色图像转换为灰度图像');
else
    grayImage = originalImage;
end

% 3. 如果需要二值图像，进行阈值处理（可选）
% 这里让用户选择是否要二值化
choice = questdlg('是否要将图像二值化？', '二值化选择', '是', '否', '是');
if strcmp(choice, '是')
    threshold = graythresh(grayImage); % 自动计算阈值
    binaryImage = imbinarize(grayImage, threshold);
    disp(['使用自动计算的阈值: ', num2str(threshold)]);
    imageToProcess = binaryImage;
else
    imageToProcess = grayImage;
end

% 4. 创建结构元素（膨胀核）
% 让用户选择结构元素类型和大小
prompt = {'输入结构元素大小 (3-21 之间的奇数):', '选择结构元素形状 (disk, square, diamond, line, octagon):'};
dlgtitle = '膨胀参数设置';
dims = [1 50];
definput = {'5', 'disk'};
answer = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(answer)
    disp('用户取消了操作');
    return;
end

seSize = str2double(answer{1});
seShape = answer{2};

% 验证输入
if isnan(seSize) || seSize < 3 || seSize > 21 || mod(seSize, 2) ~= 1
    seSize = 5; % 默认值
    disp('输入的结构元素大小无效，已设置为默认值5');
end

% 创建结构元素
switch lower(seShape)
    case 'disk'
        se = strel('disk', floor(seSize/2));
    case 'square'
        se = strel('square', seSize);
    case 'diamond'
        se = strel('diamond', floor(seSize/2));
    case 'line'
        se = strel('line', seSize, 0); % 水平线
    case 'octagon'
        se = strel('octagon', floor(seSize/2));
    otherwise
        se = strel('disk', floor(seSize/2)); % 默认使用disk
        disp('未知的结构元素形状，已使用disk形状');
end

% 5. 执行膨胀操作
dilatedImage = imdilate(imageToProcess, se);

% 6. 显示结果
figure('Name', '图像膨胀处理结果', 'NumberTitle', 'off');

if exist('binaryImage', 'var')
    % 如果进行了二值化，显示原始灰度图、二值图和膨胀结果
    subplot(1,3,1), imshow(grayImage), title('原始灰度图像');
    subplot(1,3,2), imshow(binaryImage), title('二值图像');
    subplot(1,3,3), imshow(dilatedImage), title('膨胀后的图像');
else
    % 如果没有二值化，显示灰度图和膨胀结果
    subplot(1,2,1), imshow(grayImage), title('原始灰度图像');
    subplot(1,2,2), imshow(dilatedImage), title('膨胀后的图像');
end

% 7. 保存结果（可选）
saveChoice = questdlg('是否要保存处理后的图像？', '保存结果', '是', '否', '是');
if strcmp(saveChoice, '是')
    [saveFilename, savePath] = uiputfile({'*.jpg;*.png;*.bmp;*.tif', '图像文件 (*.jpg, *.png, *.bmp, *.tif)'}, '保存处理后的图像', 'dilated_image.png');
    if ~isequal(saveFilename, 0)
        imwrite(dilatedImage, fullfile(savePath, saveFilename));
        disp(['图像已保存至: ', fullfile(savePath, saveFilename)]);
    else
        disp('用户取消了保存操作');
    end
end

disp('图像膨胀处理完成！');