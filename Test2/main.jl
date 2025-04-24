## 导入所需库

using TyImageProcessing
using TySignalProcessing
using TyMath
# using Printf
import TyPlot
import TyBase
import TyTimeSeries

## 清空环境

plt_close("all")
clear()
clc()

## 实验内容

## 读入图像 
Photo_1 = imread("./TestPhotos/house.jpg");
Photo_2 = imread("./TestPhotos/lena_noise.jpg");
Photo_3 = imread("./TestPhotos/lena.jpg");


## 显示图像
imshow(Photo_2)


## 图像傅里叶变换
# 灰度化图像
Photo_2_gray = im2gray(Photo_2)
# imshow(Photo_2_gray)
Photo_2_fft = fft(Photo_2_gray)


## 将零频分量移到频谱中心
# Photo_2_fft = fftshift(abs.(Photo_2_fft))
Photo_2_fft = fftshift(Photo_2_fft)

## 创建图像的幅度谱图
# 取常用对数便于观察
Photo_2_fft_log = log10.(abs.(Photo_2_fft))
figure("原图像频谱")
mesh(Photo_2_fft_log)
zlim([0 7])


## 构建理想低通滤波器

function lowpass_filter(p,d0)
    l,w = size(p)
    ret = zeros(l,w)
    center_x = (l + 1)/2
    center_y = (w + 1)/2
    for i=1:l
        for j=1:w
            D = sqrt((i - center_x).^2 + (j - center_y).^2)
            if D<=d0
                ret[i,j] = 1
            else
                ret[i,j] = 0
            end

        end
    end
    return ret
end

# params = real.(Photo_2_fft)
ret1 = lowpass_filter(Photo_2,100)
figure("理想低通滤波后频谱")
mesh(ret1)
# zlim([0 7])



## 构建Butterworth低通滤波器

# lf = 1500
# b,a = butter(6,2*pi*lf,"s","lowpass")
# h,wout=freqs(b,a;plotfig = true)

function bu_lowpass_filter(p,d0,N)
    m,n=size(p)
    ret = zeros(m,n)


    
    # u,v=meshgrid2(1:m,1:n)
    center_x = (m + 1)/2
    center_y = (n + 1)/2

    for u = 1:m
        for v=1:n
            D = sqrt((u - center_x).^2 + (v - center_y).^2)
            ret[u,v] = 1 / (1 + (D / d0)^(2*N))
        end
    end
    return ret

end

figure("Butterworth lowpass")
butter_low = bu_lowpass_filter(Photo_2_gray,30,2)
mesh(butter_low)



## 构建理想高通滤波器
function highpass_filter(p,d0)
    l,w = size(p)
    ret = zeros(l,w)
    center_x = (l + 1)/2
    center_y = (w + 1)/2
    for i=1:l
        for j=1:w
            D = sqrt((i - center_x).^2 + (j - center_y).^2)
            if D<=d0
                ret[i,j] = 0
            else
                ret[i,j] = 1
            end

        end
    end
    return ret
end

params = real.(Photo_2_fft)
ret2 = highpass_filter(Photo_2,100)
figure("理想高通滤波频谱")
mesh(ret2)


## 构建Butterworth高通滤波器
# hf = 20000
# b,a = butter(9,2*pi*hf,"s","highpass")
# freqs(b,a,plotfig = true)

function bu_highpass_filter(p,d0,N)
    m,n=size(p)
    ret = zeros(m,n)


    
    # u,v=meshgrid2(1:m,1:n)
    center_x = (m + 1)/2
    center_y = (n + 1)/2

    for u = 1:m
        for v=1:n
            D = sqrt((u - center_x).^2 + (v - center_y).^2)
            ret[u,v] = 1 / (1 + (d0 / D)^(2*N))
        end
    end
    return ret

end

butter_high = bu_highpass_filter(Photo_1,70,3)
figure("Butterworth highpass")
surf(butter_high)

## 图像低通滤波处理

## 频谱反移

Photo_2_ifft = Photo_2_fft.*butter_low
Photo_2_ifft = ifftshift(Photo_2_ifft)


## 图像逆傅里叶变换
Photo_2_ifft = ifft(Photo_2_ifft)
Photo_2_ifft = UInt8.(floor.(abs.(real.(Photo_2_ifft))))
figure("滤波后图像")
imshow(Photo_2_ifft)


## 滤波后图像幅度频谱
Photo_2_fft_f = fft(Photo_2_ifft)



# Photo_2_fft = fftshift(abs.(Photo_2_fft))
Photo_2_fft_f = fftshift(Photo_2_fft_f)


Photo_2_fft_f_log = log10.(abs.(Photo_2_fft_f))
figure("滤波后图像频谱")
mesh(Photo_2_fft_f_log)
zlim([0 7])


## 图像低通滤波处理


## 显示图像
figure("高通滤波原图像")
imshow(Photo_1)


## 图像傅里叶变换
# 灰度化图像
Photo_1_gray = im2gray(Photo_1)
# imshow(Photo_2_gray)
Photo_1_fft = fft(Photo_1_gray)


## 将零频分量移到频谱中心
# Photo_2_fft = fftshift(abs.(Photo_2_fft))
Photo_1_fft = fftshift(Photo_1_fft)

## 创建图像的幅度谱图
# 取常用对数便于观察
Photo_1_fft_log = log10.(abs.(Photo_1_fft))
figure("原图像频谱")
mesh(Photo_1_fft_log)
zlim([0 7])


## 频谱反移

Photo_1_ifft = Photo_1_fft.*butter_high
Photo_1_ifft = ifftshift(Photo_1_ifft)


## 图像逆傅里叶变换
Photo_1_ifft = ifft(Photo_1_ifft)
Photo_1_ifft = UInt8.(floor.(abs.(real.(Photo_1_ifft))))
figure("滤波后图像")
imshow(Photo_1_ifft)


## 滤波后图像幅度频谱
Photo_1_fft_f = fft(Photo_1_ifft)



# Photo_2_fft = fftshift(abs.(Photo_2_fft))
Photo_1_fft_f = fftshift(Photo_1_fft_f)


Photo_1_fft_f_log = log10.(abs.(Photo_1_fft_f))
figure("滤波后图像频谱")
mesh(Photo_1_fft_f_log)
zlim([0 7])


## 不同滤波器幅度谱
figure("不同滤波器幅度谱")
subplot(2,2,1)
surf(ret1)
subplot(2,2,2)
surf(ret2)
subplot(2,2,3)
surf(butter_low)
subplot(2,2,4)
mesh(butter_high)



