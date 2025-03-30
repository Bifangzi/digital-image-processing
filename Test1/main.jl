## 导入所需库

using TyImageProcessing
using Printf
import TyPlot
import TyBase.delete

## 清空环境

delete("./write_photo.jpg")
plt_close("all")
clear()
clc()


## 读入图像 
Photo_1 = imread("./TestPhotos/couple1.jpg");
Photo_2 = imread("./TestPhotos/couple2.jpg");
Photo_3 = imread("./TestPhotos/couple3.jpg");
Photo_4 = imread("./TestPhotos/lena1.jpg");
Photo_5 = imread("./TestPhotos/lena2.jpg");
Photo_6 = imread("./TestPhotos/lena3.jpg");
Photo_7 = imread("./TestPhotos/NBA1.jpg");
Photo_8 = imread("./TestPhotos/NBA2.jpg");
Photo_9 = imread("./TestPhotos/NBA3.jpg");
Photo_10 = imread("./TestPhotos/town.jpg");

## 实验内容

# 获取图像长宽及深度
length_1,height_1,depth_1 = size(Photo_1)


# 展示图像
figure("展示图像1")
imshow(Photo_1)
title("Photo_1")


# 复合图像
figure("复合图像")
fuse_photo, =imfuse(Photo_1,Photo_2)
imshow(fuse_photo)


# 显示图像差异
figure("图像差异")
imshowpair(Photo_4,Photo_5)


# 保存图像
imwrite(Photo_1,"./write_photo.jpg")


# 转化为二值图像
figure("二值图像")
for i = 1:4
    level = 0.1*i
    subplot(2,2,i)
    bw_photo=im2bw(Photo_1,level)
    imshow(bw_photo)
    str_level = @sprintf("%0.1f",level)
    title("Level = " *str_level* "")
end

# 获取图像信息
photo_info=imfinfo("./TestPhotos/couple1.jpg")


# 直方图均衡化
histeq_photo = histeq(Photo_7)
figure("直方图均衡化处理")
subplot(2,2,1)
imshow(Photo_7)
title("原图像")
subplot(2,2,2)
imhist(Photo_7,64,fig=true)
title("原图像直方图")
subplot(2,2,3)
imshow(histeq_photo)
title("均衡化后图像")
subplot(2,2,4)
imhist(histeq_photo,64,fig=true)
title("均衡化后直方图")

## 思考题




I = imread("./TestPhotos/lena.bmp");



## 亮暗图像直方图均衡化对比

# 原图像
dark_photo = Photo_6
light_photo = Photo_5
figure("亮/暗原图像")
subplot(2,2,1)
imshow(light_photo)
title("亮图像")
subplot(2,2,2)
imhist(light_photo,64,fig=true)
title("亮图像直方图")
subplot(2,2,3)
imshow(dark_photo)
title("暗图像")
subplot(2,2,4)
imhist(dark_photo,64,fig=true)
title("暗图像直方图")

# 直方图均衡化处理
light_histeq_photo = histeq(light_photo)
figure("亮/暗图像均衡化处理")
subplot(2,2,1)
imshow(light_histeq_photo)
title("亮图像均衡化处理")
subplot(2,2,2)
imhist(light_histeq_photo,64,fig=true)
title("亮图像处理后直方图")
dark_histeq_photo = histeq(dark_photo)
subplot(2,2,3)
imshow(dark_histeq_photo)
title("暗图像均衡化处理")
subplot(2,2,4)
imhist(dark_histeq_photo,64,fig=true)
title("暗图像处理后直方图")




## (6) 如果对同一幅图像连续两次进行直方图均衡化，能否进一步改善图像的质量？
dou_histeq_photo = histeq(histeq_photo)
figure("两次直方图均衡化处理")
subplot(2,2,1)
imshow(histeq_photo)
title("一次均衡化处理")
subplot(2,2,2)
imhist(histeq_photo,64,fig=true)
title("一次处理直方图")
subplot(2,2,3)
imshow(dou_histeq_photo)
title("两次均衡化图像")
subplot(2,2,4)
imhist(dou_histeq_photo,64,fig=true)
title("两次处理直方图")