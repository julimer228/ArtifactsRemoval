
%[im_file, im_path] = uigetfile({'*.tif' ; '*.tiff'; '*.png'; '*.jpg'}, 'Select an image');
folder=uigetdir();
folder_img="C:\Users\Julia\Documents\GitHub\ArtifactsRemoval\Segmentation\images\";
im_org = imread(strcat(folder_img,"s_1.1_f_3Case_4-03_method2_gauss.png"));
im_jpg = imread(strcat(folder_img,"Case_4-03_30.jpg"));
im_rem = imread(strcat(folder_img,"s_1.1_f_3Case_4-03_method2_gauss.png"));

imshow(im_org);
title("Original")

numColors = 3;
L_org = imsegkmeans(im_org,numColors);
B_org = labeloverlay(im_org,L_org);
imshow(B_org)
title("Original Image")
%imwrite(B_org, "original_segm.fig");
savefig(B_rem, "org_segm")


imshow(im_jpg);
title("JPEG")


L_jpg = imsegkmeans(im_jpg,numColors);
B_jpg = labeloverlay(im_jpg,L_jpg);
imshow(B_jpg)
title("Original Image")
%imwrite(B_jpg, "jpg_segm.fig");
savefig(B_rem, "jpg_segm")

%%
numColors=3;
im_rem = imread(strcat(folder_img,"s_1.1_f_3Case_4-03_method2_gauss.png"));
imshow(im_rem);
title("JPEG")


L_rem = imsegkmeans(im_rem,numColors);
B_rem = labeloverlay(im_rem,L_rem);
imshow(B_rem)
title("Original Image")
savefig(B_rem, "rem_segm");
%imwrite(B_rem, "rem_segm.fig");


%%
lab_he = rgb2lab(he);
ab = lab_he(:,:,2:3);
ab = im2single(ab);
pixel_labels = imsegkmeans(ab,numColors,NumAttempts=3);

B2 = labeloverlay(he,pixel_labels);
imshow(B2)
title("Labeled Image a*b*")


