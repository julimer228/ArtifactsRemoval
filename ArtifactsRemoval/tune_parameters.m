%% script to tune algorithm parameters
close all; clear all; clc 

% set a path to the images
imPath = '..\BreCaHAD\images\*.tif'; 
imFiles = dir(imPath);

% set a path for result images
imageFolderGauss = '..\Results\Images\gauss30\';
imageFolderAvg='..\Results\Images\avg30\';

%set a path for result .csv files
folderCSV ='..\Results\Tables\Raw\Q30\';

%% make parameter sets
sigmas = {0.4 ; 0.7 ; 1.1 ; 1.4 ; 1.7 ; 2};
filter_sizes = {3 ; 5 ; 7 ; 9 ; 11 ; 13};
methods = {'otsu', 'multilevel_tresholding', 'fixed_multilevel_tresholding'}; 

%% make a tables for the results
% gaussian filter
t_size_gauss = {'Size' [0 14]};
t_vars_gauss = {'VariableTypes', ["string", "string", "string", "double", ...
    "double", "double", "double", "double","double","double","double", "double", "double", "double"]};

t_names_gauss = {'VariableNames', ["name", "type", "method", "sigma", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_brisque", "im_brisque", "delta_brisque"]};

t_res_gauss = table(t_size_gauss{:}, t_vars_gauss{:}, t_names_gauss{:});
t_tabs_gauss={t_res_gauss, t_res_gauss, t_res_gauss};

% average filter
t_size_avg = {'Size' [0 13]};
t_vars_avg = {'VariableTypes', ["string", "string", "string", ...
    "double", "double", "double", "double","double","double","double","double","double","double"]};

t_names_avg = {'VariableNames', ["name", "type", "method", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_brisque", "im_brisque", "delta_brisque"]};

t_res_avg = table(t_size_avg{:}, t_vars_avg{:}, t_names_avg{:});
t_tabs_avg={t_res_avg, t_res_avg, t_res_avg};

%% main loop over the images
for ind=1:10 %length(imFiles)   
    %% read an image and convert it into uint8
    im_name = strsplit(imFiles(ind).name, '.');
    f_name = [imFiles(ind).folder '\' imFiles(ind).name];
    im = imread(f_name);
    im_org = additional_functions.conv_to_uint8(im);
    
    %% compress to jpg with quality 30%
    imwrite(im_org, 'jpg_conv.jpg', 'jpg', 'Quality', 30);
    im_jpg = imread('jpg_conv.jpg');
    delete('jpg_conv.jpg');

    %% count quality metrics for the jpg image
    [jpg_ssim, jpg_psnr, jpg_brisque] = quality_metrics.count_metrics(im_jpg, im_org);

    % run gaussian filter 
    for i=1:length(methods)
        for j=1:length(sigmas) 
            for k=1:length(filter_sizes)
                % run algorithm
                rem = remove_artifacts(im_jpg, [1 1], sigmas{j},...
                filter_sizes{k}, 'gauss', methods{i}); 
                im=run_artifacts_removal(rem);

                % count metrics
                [im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im, im_org);
                delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
                delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
                delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);

                % save row to the table
                t_tabs_gauss{i}(end+1,:) = {im_name{1}, 'gauss',methods{i}, ...
                sigmas{j}, filter_sizes{k}, jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                im_ssim, delta_ssim, jpg_brisque, im_brisque, delta_brisque};

                % save image to a file
                % [gauss_method_s{sigma}_f{filter_size}_name.jpg]
                imgName = string(strcat(imageFolderGauss,'gauss_',methods{i}, ...
                    '_s_',string(sigmas{j}),'_f_',string(filter_sizes{k}),im_name(1),'.png')) ;
                imwrite(im,imgName); 
            end
        end
    end

    % Average filter does not use sigma
    use_sigma=false;
    %% run average filter 
    for i=1:length(methods)
        for j=1:length(filter_sizes) 
                % run the algorithm
                rem = remove_artifacts(im_jpg, [1 1], use_sigma,...
                filter_sizes{j}, 'avg', methods{i}); 
                im=run_artifacts_removal(rem);

                % count metrics
                [im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im, im_org);
                delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
                delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
                delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);

                % save results to the table
                t_tabs_avg{i}(end+1,:) = {im_name{1}, 'avg',methods{i}, ...
                filter_sizes{j}, jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                im_ssim, delta_ssim, jpg_brisque, im_brisque, delta_brisque};

                % save image to a file
                % [avg_method_f{filter_size}_name.jpg]
                imgName = string(strcat(imageFolderAvg,'avg_',methods{i},'_f_',...
                    string(filter_sizes{j}),'_',im_name(1),'.jpg')) ;
                imwrite(im,imgName); 
        end
    end
end

%% save results to the csv file [methods{i}_filter.csv] 
% average filter
for i=1:length(t_tabs_avg)
    writetable(t_tabs_avg{i}, string(strcat(folderCSV,string(methods{i}),'_avg.csv'))); 
end

%% gaussian filter
for i=1:length(t_tabs_gauss)
     writetable(t_tabs_gauss{i}, strcat(folderCSV, string(methods{i}),'_gauss.csv'));
end

