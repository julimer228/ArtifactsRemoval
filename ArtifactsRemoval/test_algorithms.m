%% script to detect and remove JPG compression artifacts for one image

%% read an .tif image an convert it to uint8
[im_file, im_path] = uigetfile({'*.tif' ; '*.tiff'}, 'Select an image');
im_org_uint16 = imread([im_path '\' im_file]);
im_org = additional_functions.conv_to_uint8(im_org_uint16);

%% compress to jpg
imwrite(im_org, 'jpg_conv.jpg', 'jpg', 'Quality', 30);
im_jpg= imread('jpg_conv.jpg');

%% remove jpg compression artifacts
% sigmas = [0.4 0.7 1.1 1.4 1.7 2 2.3 2.6 2.9];
% filter_sizes = [3 5 7 9 11 13 15 17 19];
% methods = ["method_1" "method_2" "method_3" "blurr"]
% filter = ["avg" "gauss"]

method="blurr";
sigma=0.4;
filter_size=3;
filter_type="gauss";

rem = remove_artifacts(im_jpg, [1 1], sigma,...
    filter_size,filter_type, method);

im=run_artifacts_removal(rem);

%% niqe model training
setDir = fullfile("C:\Users\Julia\Documents\GitHub\ArtifactsRemoval\BreCaHAD\images");
imds = imageDatastore(setDir,'FileExtensions',{'.tif'});
model = fitniqe(imds);

%% compare results img
[jpg_ssim, jpg_psnr, jpg_niqe] = quality_metrics.count_metrics(im_jpg, im_org, model);
[im_ssim, im_psnr, im_niqe] = quality_metrics.count_metrics(im, im_org, model);
delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
delta_niqe = quality_metrics.count_delta(im_niqe, jpg_niqe);
%% crop images
rect=[32 32 1024 1024];
crop_org=imcrop(im_org, rect);
crop_jpg=imcrop(im_jpg, rect);
crop_im=imcrop(im, rect);
img_array={crop_jpg;crop_org; crop_im};
montage(img_array,'Size',[1 3]);

rect=[32 32 128 128];
crop_org=imcrop(im_org, rect);
crop_jpg=imcrop(im_jpg, rect);
crop_im=imcrop(im, rect);

%% mount images
img_array={crop_jpg;crop_org; crop_im};
montage(img_array,'Size',[1 3]);
