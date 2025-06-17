% 显示图像频谱
function display_image_spectrum(img)
    
    % 检查图像类型（灰度或彩色）
    if size(img, 3) == 3
        % 彩色图像：转换为YCbCr以便分离亮度和色度
        img_ycbcr = rgb2ycbcr(img);
        img_gray = img_ycbcr(:,:,1); % 使用亮度通道
        is_color = true;
    else
        % 灰度图像
        img_gray = img;
        is_color = false;
    end
    
    % 计算傅里叶变换
    F = fft2(img_gray);
    
    % 将零频率分量移到频谱中心
    F_shifted = fftshift(F);
    
    % 计算幅度谱
    magnitude_spectrum = abs(F_shifted);
    
    % 对数变换以增强显示效果
    magnitude_spectrum_log = log(1 + magnitude_spectrum);
    
    % 归一化显示
    magnitude_spectrum_normalized = mat2gray(magnitude_spectrum_log);
       
    % 创建图形窗口
    figure;
    
    % 显示原始图像
    subplot(2, 2, 1);
    if is_color
        imshow(img);
        title('原始彩色图像');
    else
        imshow(img_gray);
        title('原始灰度图像');
    end
    
    % 显示幅度谱
    subplot(2, 2, 2);
    imshow(magnitude_spectrum_normalized);
    title('幅度谱（对数变换后）');
    
    % 显示幅度谱的3D视图
    subplot(2, 1, 2);
    [X, Y] = meshgrid(1:size(magnitude_spectrum, 2), 1:size(magnitude_spectrum, 1));
    surf(X, Y, magnitude_spectrum_log);
    shading interp;
    axis tight;
    title('幅度谱的3D视图');
    xlabel('频率X');
    ylabel('频率Y');
    zlabel('对数幅度');
    colorbar
    
    sgtitle(sprintf('图像频谱分析'), 'FontSize', 14);
end    