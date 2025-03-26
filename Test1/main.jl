## 导入所需库

using TyImageProcessing
import TyPlot.title
import TyBase.delete

## 清空环境

delete("Test1/write_photo.jpg")
plt_close("all")
clear()
clc()


## 读入图像 
Photo_1 = imread("Test1/TestPhotos/couple1.jpg")
Photo_2 = imread("Test1/TestPhotos/couple2.jpg")
Photo_3 = imread("Test1/TestPhotos/couple3.jpg")
Photo_4 = imread("Test1/TestPhotos/lena1.jpg")
Photo_5 = imread("Test1/TestPhotos/lena2.jpg")
Photo_6 = imread("Test1/TestPhotos/lena3.jpg")
Photo_7 = imread("Test1/TestPhotos/NBA1.jpg")
Photo_8 = imread("Test1/TestPhotos/NBA2.jpg")
Photo_9 = imread("Test1/TestPhotos/NBA3.jpg")
Photo_10 = imread("Test1/TestPhotos/town.jpg")

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
imwrite(Photo_1,"Test1/write_photo.jpg")


# 转化为二值图像
bw_photo=im2bw(Photo_1,0.5)
figure("二值图像")
imshow(bw_photo)

# 获取图像信息
photo_info=imfinfo("Test1/TestPhotos/couple1.jpg")


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

