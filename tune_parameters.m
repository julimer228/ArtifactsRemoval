%% script to tune algorithm parameters
close all; clear all; clc 

%% set a path to the images
imPath = '..\..\BreCaHAD\images\*.tif'; 
imFiles = dir(imPath);

%% make parameter sets
use_maps = {1};%; 0};
sigmas = {0.4 ; 0.7 ; 1.1 ; 1.4 ; 1.7 ; 2};
filter_sizes = {3 ; 5 ; 7 ; 9 ; 11 ; 13};

%% make a table for the results
t_size = {'Size' [0 14]};
t_vars = {'VariableTypes', ["string", "string", "double", "double", ...
    "double", "double", "double", "double","double","double","double" , ...
    "double", "double", "double"]};
t_names = {'VariableNames', ["name", "type", "map",  "sigma", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_SCC", "SCC", "delta_SCC"]};
t_res = table(t_size{:}, t_vars{:}, t_names{:});


%% main loop over the images
for ind=1:4 %length(imFiles);    
    %% read an image and convert it into uint8
    im_name = strsplit(imFiles(ind).name, '.');
    f_name = [imFiles(ind).folder '\' imFiles(ind).name];
    im = imread(f_name);
    im_org = conv_to_uint8(im); 
    
    %% compress to jpg with quality 30%
    imwrite(im_org, 'jpg_conv.jpg', 'jpg', 'Quality', 30);
    im_jpg = imread('jpg_conv.jpg');
    delete('jpg_conv.jpg');

    [jpg_scc, jpg_ssim, jpg_psnr] = count_metrics(im_jpg, im_org);

    %% fill the table using gaussian filter
    for i=1:length(use_maps)
        for j=1:length(sigmas)
            for k=1:length(filter_sizes)
                im = artifacts_removal(im_jpg, [1 1], sigmas{j},...
                    filter_sizes{k}); 
                [im_scc, im_ssim, im_psnr] = count_metrics(im, im_org);
                delta_psnr = count_delta(im_psnr, jpg_psnr);
                delta_ssim = count_delta(im_ssim, jpg_ssim);
                delta_scc = count_delta(im_scc, jpg_scc);
                t_res(end+1,:) = {im_name{1}, 'gauss', use_maps{i}, ...
                sigmas{j}, filter_sizes{k}, jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                im_ssim, delta_ssim, jpg_scc, im_scc, delta_scc}; 
            end
        end
    end
            
    %% fill the table using avg filter
%     for i=1:length(use_maps)
%         for j=1:length(sigmas)
%             im = artifacts_removal(im_jpg, use_maps{i}, 'avg', ...
%                 filter_sizes{j}, 0);
%             im_psnr = round(psnr(im, im_org), 3);
%             dif = round((im_psnr - jpg_psnr) / jpg_psnr * 100, 2);
%             t_res(end + 1,:) = {im_name{1}, 'avg', use_maps{i}, ...
%                 0, filter_sizes{j}, jpg_psnr, im_psnr, dif}; 
%         end
%     end

end
      
%% write results
writetable(t_res, 'tuning_gauss.csv');

%% converting uint8 to uint16 function
function converted = conv_to_uint8(im)
    im = double(im);
    converted = uint8(im ./ max(max(im)) * 255);
end

function [im_scc, im_ssim, im_psnr] = count_metrics(im, im_org)
    im_scc=0; %round(scc(im, im_org), 3);
    im_ssim=round(ssim(im, im_org), 3);
    im_psnr=round(psnr(im, im_org), 3);
end

function delta = count_delta(im_metric, jpg_metric)
    delta=round((im_metric - jpg_metric) / jpg_metric * 100, 2);
end