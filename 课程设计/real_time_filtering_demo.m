function filtered_img = real_time_filtering_demo(original_img)
    % 创建主窗口
    fig = uifigure('Name', '实时图像滤波演示', 'Position', [100, 100, 1000, 600]);
    
    % 确保输入图像为灰度图
    if ndims(original_img) == 3
        original_img = rgb2gray(original_img);
    end
    filtered_img = original_img;
    
    % 创建图像显示区域 - 左侧为原始图像，右侧为滤波后图像
    img_panel1 = uipanel(fig, 'Title', '原始图像', 'Position', [10, 10, 470, 500]);
    img_panel2 = uipanel(fig, 'Title', '滤波后图像', 'Position', [500, 10, 470, 500]);
    
    % 显示原始图像
    ax1 = uiaxes(img_panel1, 'Position', [10, 10, 450, 480]);
    h_original = imshow(original_img, 'Parent', ax1);
    
    % 显示滤波后图像（初始为原始图像）
    ax2 = uiaxes(img_panel2, 'Position', [10, 10, 450, 480]);
    h_filtered = imshow(filtered_img, 'Parent', ax2);
    
    % 创建控制面板
    control_panel = uipanel(fig, 'Title', '滤波器控制', 'Position', [980, 10, 210, 500]);
    
    % 滤波器类型选择
    filter_type = uilabel(control_panel, 'Text', '滤波器类型:', 'Position', [20, 460, 100, 22]);
    filter_dropdown = uidropdown(control_panel, 'Position', [20, 430, 170, 22], ...
        'Items', {'高斯滤波', '中值滤波', '均值滤波'});
    
    % 参数标签和滑块
    param_label = uilabel(control_panel, 'Text', '参数:', 'Position', [20, 390, 100, 22]);
    param_value = uilabel(control_panel, 'Text', '3', 'Position', [160, 390, 30, 22]);
    
    % 创建滑块（高斯滤波：标准差；中值/均值滤波：核大小）
    param_slider = uislider(control_panel, 'Position', [20, 360, 170, 22], ...
        'Limits',[0 7],'Value',3);
    
    % 退出按钮
    exit_btn = uibutton(control_panel, 'Position', [20, 100, 170, 30], ...
        'Text', '退出并返回结果', 'ButtonPushedFcn', @(~,~) delete(fig));
    
    % 实时更新图像的回调函数
    update_filtered_image = @(src, event) update_image(src, event, filter_dropdown, param_slider, ...
                                                         h_original, h_filtered, ax2, param_value, original_img);
    
    % 绑定回调函数
    addlistener(filter_dropdown, 'ValueChanged', update_filtered_image);
    addlistener(param_slider, 'ValueChanged', update_filtered_image);
    
    % 初始化显示
    filtered_img = update_image(nan, nan, filter_dropdown, param_slider, h_original, h_filtered, ax2, param_value, original_img);
    
    % 等待窗口关闭
    waitfor(fig);
    
    % 返回最终滤波结果
    % filtered = get(h_filtered, 'CData');
    
    % 更新图像的函数
    function re = update_image(src, event, filter_dropdown, param_slider, h_original, h_filtered, ax, param_value_label, img)
        % 获取当前选择的滤波器和参数值
        filter_name = filter_dropdown.Value;
        % filter_name = filter_dropdown.Items{filter_idx};
        param_val = round(param_slider.Value);
        
        % 更新参数显示
        param_value_label.Text = num2str(param_val);
        
        % 应用滤波
        switch filter_name
            case '高斯滤波'
                filtered = imgaussfilt(img, param_val/2);
                filter_desc = sprintf('高斯滤波 (标准差=%.1f)', param_val/2);
                
            case '中值滤波'
                if mod(param_val, 2) == 0
                    param_val = param_val + 1;  % 确保核大小为奇数
                end
                filtered = medfilt2(img, [param_val, param_val]);
                filter_desc = sprintf('中值滤波 (核大小=%dx%d)', param_val, param_val);
                
            case '均值滤波'
                filtered = imfilter(img, fspecial('average', param_val));
                filter_desc = sprintf('均值滤波 (核大小=%dx%d)', param_val, param_val);
        end
        
        % 更新显示
        set(h_filtered, 'CData', filtered);
        re = filtered;
        title(ax, filter_desc);
    end
end