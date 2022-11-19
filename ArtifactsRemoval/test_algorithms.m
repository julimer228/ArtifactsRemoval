%% script to detect and remove JPG compression artifacts for one image
% close all; clear all; clc

%% read an .tif image an convert it to uint8
[im_file, im_path] = uigetfile({'*.tif' ; '*.tiff'}, 'Select an image');
im_org_uint16 = imread([im_path '\' im_file]);
im_org = additional_functions.conv_to_uint8(im_org_uint16);

%% compress to jpg
imwrite(im_org, 'jpg_conv.jpg', 'jpg', 'Quality', 30);
im_jpg = imread('jpg_conv.jpg');

%% remove jpg compression artifacts
method="canny";
sigma=1.1;
filter_size=15;
filter_type="gauss";

rem = remove_artifacts(im_jpg, [1 1], sigma,...
    filter_size,filter_type, method);

im=run_artifacts_removal(rem);

%% compare results img
[jpg_ssim, jpg_psnr, jpg_brisque] = quality_metrics.count_metrics(im_jpg, im_org);
[im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im, im_org);
delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);

%% crop images
rect=[32 32 64 64];
crop_org=imcrop(im_org, rect);
crop_jpg=imcrop(im_jpg, rect);
crop_im=imcrop(im, rect);

%% mount images
img_array={crop_org; crop_jpg; crop_im};
montage(img_array,'Size',[1 3]);

