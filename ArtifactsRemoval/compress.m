%% script to compress .tiff/.tif images with jpeg algorithm
% set a path to the images
im_path = '..\BreCaHAD\images\*.tif'; 
im_files = dir(im_path);

% set a path for result images
images_folder = '..\BreCaHAD\compressed\Q';

% compression quality parameters
Q=[10 30 50 70 90];

for i=1:length(Q)
    % Check if folder exists, if not create it
    images_folder_q=strcat(images_folder,string(Q(i)));

    if isfolder(images_folder_q) == false
       mkdir(images_folder_q);
    end

    for ind=1:length(im_files)   
        % read an image and convert it into uint8
        im_name = strsplit(im_files(ind).name, '.');
        f_name = [im_files(ind).folder '\' im_files(ind).name];
        im = imread(f_name);

        % convert to uint8
        im_org = additional_functions.conv_to_uint8(im);

        % set image name 
        res_name=strcat(images_folder_q,'\',im_name(1),'.jpg');

        % compress to jpg with quality Q
        imwrite(im_org, res_name, 'jpg', 'Quality', Q(i));
    end
end