%% script to tune algorithm parameters
close all; clc

% set a path to the images
im_path = '..\BreCaHAD\images\*.tif';
im_files = dir(im_path);

% set a path for result images
image_folder = '..\ResultsCorrected\Images\Q';

%set a path for result .csv files
folder_csv ='..\ResultsCorrected\Tables\Raw\Q';


%train NIQE metric
%model=quality_metrics.train_niqe(im_path);



%% make a tables for the results
% gaussian filter
t_size_gauss = {'Size' [0 17]};
t_vars_gauss = {'VariableTypes', ["string", "string", "string", "double", ...
    "double", "double", "double", "double","double","double","double", "double", "double", "double","double", "double", "double"]};

t_names_gauss = {'VariableNames', ["name", "type", "method", "sigma", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_brisque", "im_brisque", "delta_brisque", "jpg_niqe", "im_niqe", "delta_niqe"]};

t_res_gauss = table(t_size_gauss{:}, t_vars_gauss{:}, t_names_gauss{:});

% average filter
t_size_avg = {'Size' [0 16]};
t_vars_avg = {'VariableTypes', ["string", "string", "string", ...
    "double", "double", "double","double","double","double","double","double","double","double","double", "double", "double"]};

t_names_avg = {'VariableNames', ["name", "type", "method", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_brisque", "im_brisque", "delta_brisque", "jpg_niqe", "im_niqe", "delta_niqe"]};

t_res_avg = table(t_size_avg{:}, t_vars_avg{:}, t_names_avg{:});

quality=[90];
for q=1:length(quality)
    % Check if folders exist if not, create them
    image_folder_gauss=strcat(image_folder, string(quality(q)),'\Gauss\');
    image_folder_avg=strcat(image_folder, string(quality(q)),'\Avg\');
    folder_csv_q=strcat(folder_csv, string(quality(q)),'\');

    %% make parameter sets
    sigmas =[0.4 0.7 1.1 1.4 1.7 2 2.3 2.6 2.9];
    filter_sizes =[3 5 7 9 11 13 15 17 19];
    methods = ["weights" "multi" "blurr" "otsu"];%"multilevel_tresholding" "fixed_multilevel_tresholding" "otsu"];
    cut_point=[1 1];
    use_sigma_avg=false;

    for m=1:length(methods)
        folder_g=strcat(image_folder_gauss,'/',methods(m),'/');
        folder_a=strcat(image_folder_avg,'/',methods(m),'/');
        if isfolder(folder_g) == false
            mkdir(folder_g);
        end
        if isfolder(folder_a) == false
            mkdir(folder_a);
        end
    end

    for i=1:length(methods)
        t_tabs_gauss={t_res_gauss, t_res_gauss, t_res_gauss, t_res_gauss,...
            t_res_gauss, t_res_gauss, t_res_gauss, t_res_gauss , t_res_gauss};

        t_tabs_avg={t_res_avg t_res_avg t_res_avg t_res_avg, ...
            t_res_avg t_res_avg t_res_avg t_res_avg, t_res_avg};

        %% main loop over the images
        method=methods(i);

        folder_csv_q_m_avg=strcat(folder_csv_q,'/',method,'/Avg/');
        folder_csv_q_m_gauss=strcat(folder_csv_q,'/',method,'/Gauss/');
        if isfolder(folder_csv_q_m_avg) == false
            mkdir(folder_csv_q_m_avg);
        end
        if isfolder(folder_csv_q_m_gauss) == false
            mkdir(folder_csv_q_m_gauss);
        end

        for ind=1:length(im_files)
            %% read an image and convert it into uint8
            im_name = strsplit(im_files(ind).name, '.');
            name=string(im_name(1));
            f_name = [im_files(ind).folder '\' im_files(ind).name];
            im = imread(f_name);
            im_org = additional_functions.conv_to_uint8(im);

            %% compress to jpg with quality q
            imwrite(im_org, 'jpg_conv.jpg', 'jpg', 'Quality', quality(q));
            im_jpg = imread('jpg_conv.jpg');
            delete('jpg_conv.jpg');

            %% count quality metrics for the jpg image
            [jpg_ssim, jpg_psnr, jpg_brisque, jpg_niqe] = quality_metrics.count_metrics(im_jpg, im_org,model);

            % run filters
            parfor k=1:length(filter_sizes)
                for j=1:length(sigmas)
                    % run algorithm
                    rem = remove_artifacts(im_jpg, cut_point, sigmas(j),...
                        filter_sizes(k), 'gauss', method);
                    im=run_artifacts_removal(rem);

                    % count metrics
                    [im_ssim, im_psnr, im_brisque, im_niqe] = quality_metrics.count_metrics(im, im_org,model);
                    delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
                    delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
                    delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);
                    delta_niqe=quality_metrics.count_delta(im_niqe, jpg_niqe);
                    % save row to the table
                    t_tabs_gauss{k}(end+1,:) = {name, 'gauss',method, ...
                        sigmas(j), filter_sizes(k), jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                        im_ssim, delta_ssim, jpg_brisque, im_brisque, delta_brisque, jpg_niqe,...
                        im_niqe, delta_niqe};

                    % save image to a file
                    % [gauss_method_s{sigma}_f{filter_size}_name.jpg]
                    img_rem_name_gauss = string(strcat(image_folder_gauss,'\',method,'\', ...
                        's_',string(sigmas(j)),'_f_',string(filter_sizes(k)),name,'.png')) ;
                    imwrite(im,img_rem_name_gauss,"png");
                end

                %Average filter
                % run the algorithm
                rem_avg = remove_artifacts(im_jpg, cut_point, use_sigma_avg,...
                    filter_sizes(k), 'avg', method);
                im_avg=run_artifacts_removal(rem_avg);

                % count metrics
                [im_ssim_avg, im_psnr_avg, im_brisque_avg, im_niqe] = quality_metrics.count_metrics(im_avg, im_org,model);
                delta_psnr_avg = quality_metrics.count_delta(im_psnr_avg, jpg_psnr);
                delta_ssim_avg = quality_metrics.count_delta(im_ssim_avg, jpg_ssim);
                delta_brisque_avg = quality_metrics.count_delta(im_brisque_avg, jpg_brisque);
                delta_niqe=quality_metrics.count_delta(im_niqe, jpg_niqe);
                % save results to the table
                t_tabs_avg{k}(end+1,:) = {name, 'avg',method, ...
                    filter_sizes(k), jpg_psnr, im_psnr_avg, delta_psnr_avg, jpg_ssim,...
                    im_ssim_avg, delta_ssim_avg, jpg_brisque, im_brisque_avg, delta_brisque_avg,...
                    jpg_niqe, im_niqe, delta_niqe};

                % save image to a file
                % [avg_method_f{filter_size}_name.jpg]
                img_rem_name_avg = string(strcat(image_folder_avg,'\',method,'\','f_',...
                    string(filter_sizes(k)),'_',name,'.png')) ;
                imwrite(im_avg,img_rem_name_avg);
            end
        end
        %% save results to the csv file 
        parfor idx=1:length(filter_sizes)
            writetable(t_tabs_avg{idx}, string(strcat(folder_csv_q_m_avg,string(filter_sizes(idx)),'_avg.csv')));
            writetable(t_tabs_gauss{idx}, strcat(folder_csv_q_m_gauss,string(filter_sizes(idx)),'_gauss.csv'));
        end
    end
end