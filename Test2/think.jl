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


## 思考题

test_pthoto = imread("./TestPhotos/lena_noise.jpg");
test_gray = im2gray(test_pthoto)

figure("原图像")
imshow(test_gray)
test_fft = fft(test_gray)
l,w = size(test_gray)


## 填充图像

test_a = UInt8.(zeros(442,442));
test_b = UInt8.(zeros(442,442));

for i=1:l
    for j=1:w
        test_a[i,j]=test_gray[i,j]
    end
end

figure("末尾填充")
imshow(test_a)


for i=52:391
    for j=52:390
        test_b[i,j]=test_gray[i-51,j-51]
    end
end

figure("四周填充")
imshow(test_b)

#计算FFT

fft_a = fft(test_a)
fft_b = fft(test_b)


## 不进行频谱移中

fft_A_log = log10.(abs.(fft_a))
fft_B_log = log10.(abs.(fft_b))

figure("不移中末尾填充频谱")
mesh(fft_A_log)
zlim([0 7])

figure("不移中四周填充频谱")
mesh(fft_B_log)
zlim([0 7])

figure("不移中频谱差异")
DIFF = fft_A_log - fft_B_log
mesh(DIFF)



## 进行频谱移中


fft_a = fftshift(fft_a)
fft_b = fftshift(fft_b)

fft_a_log = log10.(abs.(fft_a))
fft_b_log = log10.(abs.(fft_b))


figure("移中末尾填充频谱")
mesh(fft_a_log)
zlim([0 7])

figure("移中四周填充频谱")
mesh(fft_b_log)
zlim([0 7])

figure("移中频谱差异")
diff = fft_a_log - fft_b_log
mesh(diff)

## 组合图
figure("不同填充对比")
subplot(2,2,1)
imshow(test_a)
title("末尾填充效果图")
subplot(2,2,3)
imshow(test_b)
title("四周填充效果图")
subplot(2,2,2)
mesh(fft_a_log)
zlim([1 6])
title("末尾填充后频谱")
subplot(2,2,4)
mesh(fft_b_log)
zlim([1 6])
title("四周填充后频谱")

## 滤波
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
butter_low = bu_lowpass_filter(test_a,30,2)
mesh(butter_low)

test_a_ifft = fft_a.*butter_low
test_b_ifft = fft_b.*butter_low

test_a_ifft = ifftshift(test_a_ifft)
test_b_ifft = ifftshift(test_b_ifft)

test_a_ifft = ifft(test_a_ifft)
test_b_ifft = ifft(test_b_ifft)

test_a_ifft = UInt8.(floor.(abs.(real.(test_a_ifft))))
test_b_ifft = UInt8.(floor.(abs.(real.(test_b_ifft))))
figure("末尾填充低通滤波后图像")
imshow(test_a_ifft)
figure("四周填充低通滤波后图像")
imshow(test_b_ifft)

## 还原图像

result_a = UInt8.(zeros(340,339));
result_b = UInt8.(zeros(340,339));

for i=1:340
    for j=1:339
        result_a[i,j]=test_a_ifft[i,j]
    end
end

figure("末尾填充结果图")
imshow(result_a)


for i=1:340
    for j=1:339
        result_b[i,j]=test_b_ifft[i+51,j+51]
    end
end

figure("四周填充结果图")
imshow(result_b)


## 组合图
figure("不同填充滤波结果")
subplot(2,2,1)
imshow(test_a_ifft)
title("末尾填充低通滤波后图像")
subplot(2,2,3)
imshow(test_b_ifft)
title("四周填充低通滤波后图像")
subplot(2,2,2)
imshow(result_a)
title("末尾填充结果图")
subplot(2,2,4)
imshow(result_b)
title("四周填充结果图")

## 显示差异
figure("输出图像间差异")
imshowpair(result_a,result_b)
