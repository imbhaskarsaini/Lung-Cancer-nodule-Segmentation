clc;

I=dicomread('image\img2.dcm');
info = dicominfo('image\img2.dcm');
I=dicomread(info);
imshow(I,'DisplayRange',[]);
title('original image');
% image_gray=rgb2gray(I);
image_resize=imresize(I,[256 256]);
image_resize=im2double(image_resize);
%filtering
%B=medfilt2(I,[7 7],'symmetric');
%figure,imshow(B);
gamma=0.1;%aspect ratio
psi=0;%phase
theta=50;%orientation
bw=2.8;
lambda=3;%wavelength
pi=180;
for x=1:256
for y=1:256
        x_theta=image_resize(x,y)*cos(theta)+image_resize(x,y)*sin(theta);
        y_theta=image_resize(x,y)*sin(theta)+image_resize(x,y)*cos(theta);
gb(x,y)=exp(-(x_theta.^2/2*bw^2+gamma^2*y_theta.^2/2*bw^2))*cos(2*pi/lambda*x_theta+psi);
end
end
figure,imshow(gb);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(gb), hy, 'replicate');
Ix = imfilter(double(gb), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
L=watershed(gradmag);
Lrgb=label2rgb(L);
threshold=graythresh(gb);
BW=im2bw(gb,threshold);
figure,imshow(BW);
se=strel('disk',5);
Io=imopen(BW,se);
figure,imshow(Io);
title('opening Io');
Ie=imerode(BW, se);
Iobr=imreconstruct(Ie, BW);
figure,imshow(Iobr);
title('opening by re-construction');
Ioc=imclose(Io, se);
figure,imshow(Ioc);
title('opening-closing');
Iobrd=imdilate(Iobr, se);
Iobrcbr=imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr=imcomplement(Iobrcbr);
figure,imshow(Iobrcbr);
title('opening by re-construction(Iobrcbr)');
fgm=imregionalmax(Iobrcbr);
figure,imshow(fgm);
title('regional maxima');
I2=BW;
I2(fgm)=255;
figure,imshow(I2);
% title('regional maxima super imposed');
se2=strel(ones(5,5));
fgm2=imclose(fgm, se2);
fgm3=imerode(fgm2,se2);
fgm4=bwareaopen(fgm3, 5);
I3=BW;
I3(fgm4)=255;
figure,imshow(I3);
D=bwdist(BW);
DL=watershed(D);
bgm = DL == 0;
figure,imshow(bgm);
title('watershed ridge lines');
gradmag2=imimposemin(gradmag, bgm| fgm4);
L=watershed(gradmag2);
I4=BW;
I4(imdilate(L==0, ones(3,3))|bgm|fgm4)=255;
figure,imshow(I4);
Lrgb=label2rgb(L,'jet', 'w', 'shuffle');
figure,imshow(Lrgb);
title('watershed');
figure,imshow(BW);
holdon
himage=imshow(Lrgb);
himage.AlphaData=0.3;
