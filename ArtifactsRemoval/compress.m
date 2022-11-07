%% script to compress images with jpeg algorithm
% set a path to the images
imPath = '..\BreCaHAD\images\*.tif'; 
imFiles = dir(imPath);

% set a path for result images
ImageFolder = '..\BreCaHAD\compressed\Q';

% quality parameters
Q={10; 30; 50; 70; 90};

for i=1:length(Q)
    for ind=1:length(imFiles)   
        %% read an image and convert it into uint8
        im_name = strsplit(imFiles(ind).name, '.');
        f_name = [imFiles(ind).folder '\' imFiles(ind).name];
        im = imread(f_name);
        im_org = additional_functions.conv_to_uint8(im);
        res_name=strcat(ImageFolder,string(Q{i}),'\',im_name(1),'.jpg');

        %% compress to jpg with quality Q
        imwrite(im_org, res_name, 'jpg', 'Quality', Q{i});
    end
end

