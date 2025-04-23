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
function lowpass_filter(p,tf)
    l,w = size(p)
    for i=1:l
        for j=1:w
            if p[i,j]>tf
                p[i,j]=0
            end
        end
    end
    return p
end

params = abs.(Photo_2_fft)
ret = lowpass_filter(params,20000)
figure("理想低通滤波后频谱")
mesh(log10.(ret))
zlim([0 7])



## 构建Butterworth低通滤波器

# lf = 1500
# b,a = butter(6,2*pi*lf,"s","lowpass")
# h,wout=freqs(b,a;plotfig = true)

function butter_lowpass_filter(p,d0,n)
    m,n=size(p)
    ret = zeros(m,n)


    
    u,v=meshgrid2(1:m,1:n)
    center_x = (m + 1)/2
    center_y = (n + 1)/2
    D = sqrt((u - center_x).^2 + (v - center_y).^2)
    # for i=1:m
    #     for j=1:n
    ret[i,j]=H = 1 ./ (1 .+ (D ./ d0).^(2*n))
    
end

y = butter_lowpass_filter(Photo_2,1500,6)

## 构建理想高通滤波器
function highpass_filter(p,tf)
    l,w = size(p)
    for i=1:l
        for j=1:w
            if p[i,j]<=tf
                p[i,j]=0
            end
        end
    end
    return p
end

params = abs.(Photo_2_fft)
ret = highpass_filter(params,1500)
figure("理想高通滤波后频谱")
mesh(log10.(ret))
zlim([0 7])


## 构建Butterworth高通滤波器
hf = 20000
b,a = butter(9,2*pi*hf,"s","highpass")
freqs(b,a,plotfig = true)


## 频谱反移

Photo_2_ifft = ifftshift(Photo_2_fft)


## 图像逆傅里叶变换
Photo_2_ifft = ifft(Photo_2_ifft)
Photo_2_ifft = UInt8.(floor.(abs.(Photo_2_ifft)))
# imshow(Photo_2_ifft)


## 滤波后图像幅度频谱


## 不同滤波器幅度谱


# import TyFilterDesigner.filterDesigner; 
# filterDesigner()

