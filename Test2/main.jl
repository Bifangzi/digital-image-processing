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
Photo_2_fft_log = log10.(Photo_2_fft)
mesh(Photo_2_fft_log)


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

parms = Photo_2_fft
ret = lowpass_filter(parms,7000)
mesh(log10.(ret))



## 构建Butterworth低通滤波器
b,a = butter(6,0.6,"lowpass")
freqs(b,a;plotfig = true)

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
## 构建Butterworth高通滤波器
b,a = butter(9,0.6,"highpass")
freqs(b,a,plotfig = true)

## 频谱反移
Photo_2_ifft = ifftshift(Photo_2_fft)

## 图像逆傅里叶变换
Photo_2_ifft = ifft(Photo_2_ifft)
Photo_2_ifft = UInt8.floor.abs.(Photo_2_ifft)
# imshow(Photo_2_ifft)

## 滤波后图像幅度频谱


## 滤波器幅度谱



