%% script to detect and remove JPG compression artifacts
% close all; clear all; clc

%% read an .tif image an convert it to uint8
[im_file, im_path] = uigetfile({'*.tif' ; '*.tiff'}, 'Select an image');
im_org_uint16 = imread([im_path '\' im_file]); 
im_org = conv_to_uint8(im_org_uint16);

%% compress to jpg
imwrite(im_org, 'jpg_conv.jpg', 'jpg', 'Quality', 30);
im_jpg = imread('jpg_conv.jpg');

%% remove jpg compression artifacts
method="otsu";
sigma=0.4;
filter_size=3;
filter_type="gauss";

rem = remove_artifacts(im_jpg, [1 1], sigma,...
                filter_size,filter_type, method, false); 

rem_black = remove_artifacts(im_jpg, [1 1], sigma,...
                filter_size,filter_type, method, true); 

im=run_artifacts_removal(rem);
im_rem_b=run_artifacts_removal(rem_black);

%% compare results img
[jpg_ssim, jpg_psnr, jpg_brisque] = quality_metrics.count_metrics(im_jpg, im_org);
[im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im, im_org);
delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);

%% compare results img_rem_b
[im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im_rem_b, im_org);
delta_psnr_b = quality_metrics.count_delta(im_psnr, jpg_psnr);
delta_ssim_b = quality_metrics.count_delta(im_ssim, jpg_ssim);
delta_brisque_b = quality_metrics.count_delta(im_brisque, jpg_brisque);

%% crop images
rect=[0 0 32 32];
crop_org=imcrop(im_org, rect);
crop_jpg=imcrop(im_jpg, rect);
crop_im=imcrop(im, rect);
crop_im_black=imcrop(im_rem_b, rect);

%% mount images
img_array={crop_org; crop_jpg; crop_im; crop_im_black};
montage(img_array,'Size',[1 4]);

%% converting uint8 to uint16 function
function converted = conv_to_uint8(im)

    im = double(im);
    converted = uint8(im ./ max(max(im)) * 255);

end
