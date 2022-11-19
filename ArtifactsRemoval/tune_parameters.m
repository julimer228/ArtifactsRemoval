%% script to tune algorithm parameters
close all; clc

% set a path to the images
im_path = '..\BreCaHAD\images2\*.tif';
im_files = dir(im_path);

% set a path for result images
image_folder = '..\ResultsTest\Images\Q';

%set a path for result .csv files
folder_csv ='..\ResultsTest\Tables\Raw\Q';

quality=[10 30 50 70 90];
for q=1:length(quality)
    % Check if folders exists if not, create them
    image_folder_gauss=strcat(image_folder, string(quality(q)),'\Gauss\');
    image_folder_avg=strcat(image_folder, string(quality(q)),'\Avg\');
    folder_csv_q=strcat(folder_csv, string(quality(q)),'\');

    if isfolder(image_folder_gauss) == false
        mkdir(image_folder_gauss);
    end

    if isfolder(image_folder_avg) == false
        mkdir(image_folder_avg)
    end

    if isfolder(folder_csv_q) == false
        mkdir(folder_csv_q)
    end

    %% make parameter sets
    sigmas = [0.4 0.7]; % 1.1 1.4 1.7 2 2.3 2.6 2.9];
    filter_sizes =[3 5]; %7 9 11 13 15 17 19];
    methods = ["canny" "otsu"]; % "multilevel_tresholding" "fixed_multilevel_tresholding"];
    cut_point=[1 1];

    %% make a tables for the results
    % gaussian filter
    t_size_gauss = {'Size' [0 14]};
    t_vars_gauss = {'VariableTypes', ["string", "string", "string", "double", ...
        "double", "double", "double", "double","double","double","double", "double", "double", "double"]};

    t_names_gauss = {'VariableNames', ["name", "type", "method", "sigma", ...
        "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
        "delta_SSIM", "jpg_brisque", "im_brisque", "delta_brisque"]};

    t_res_gauss = table(t_size_gauss{:}, t_vars_gauss{:}, t_names_gauss{:});
    t_tabs_gauss={t_res_gauss, t_res_gauss, t_res_gauss, t_res_gauss};

    % average filter
    t_size_avg = {'Size' [0 13]};
    t_vars_avg = {'VariableTypes', ["string", "string", "string", ...
        "double", "double", "double", "double","double","double","double","double","double","double"]};

    t_names_avg = {'VariableNames', ["name", "type", "method", ...
        "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
        "delta_SSIM", "jpg_brisque", "im_brisque", "delta_brisque"]};

    t_res_avg = table(t_size_avg{:}, t_vars_avg{:}, t_names_avg{:});
    t_tabs_avg={t_res_avg t_res_avg t_res_avg t_res_avg};



    %% main loop over the images
    for ind=1:1
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
        [jpg_ssim, jpg_psnr, jpg_brisque] = quality_metrics.count_metrics(im_jpg, im_org);

        % run gaussian filter
        parfor i=1:length(methods)
            for j=1:length(sigmas)
                for k=1:length(filter_sizes)
                    % run algorithm
                    rem = remove_artifacts(im_jpg, cut_point, sigmas(j),...
                        filter_sizes(k), 'gauss', methods(i));
                    im=run_artifacts_removal(rem);

                    % count metrics
                    [im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im, im_org);
                    delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
                    delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
                    delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);

                    % save row to the table
                    t_tabs_gauss{i}(end+1,:) = {name, 'gauss',methods(i), ...
                        sigmas(j), filter_sizes(k), jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                        im_ssim, delta_ssim, jpg_brisque, im_brisque, delta_brisque};

                    % save image to a file
                    % [gauss_method_s{sigma}_f{filter_size}_name.jpg]
                    img_rem_name = string(strcat(image_folder_gauss,'gauss_',methods(i), ...
                        '_s_',string(sigmas(j)),'_f_',string(filter_sizes(k)),name,'.png')) ;
                    imwrite(im,img_rem_name);
                end
            end
        end

        % Average filter does not use sigma
        use_sigma=false;
        %% run average filter
        parfor i=1:length(methods)
            for j=1:length(filter_sizes)
                % run the algorithm
                rem = remove_artifacts(im_jpg, cut_point, use_sigma,...
                    filter_sizes(j), 'avg', methods(i));
                im=run_artifacts_removal(rem);

                % count metrics
                [im_ssim, im_psnr, im_brisque] = quality_metrics.count_metrics(im, im_org);
                delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
                delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
                delta_brisque = quality_metrics.count_delta(im_brisque, jpg_brisque);

                % save results to the table
                t_tabs_avg{i}(end+1,:) = {name, 'avg',methods(i), ...
                    filter_sizes(j), jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                    im_ssim, delta_ssim, jpg_brisque, im_brisque, delta_brisque};

                % save image to a file
                % [avg_method_f{filter_size}_name.jpg]
                img_rem_name = string(strcat(image_folder_avg,'avg_',methods(i),'_f_',...
                    string(filter_sizes(j)),'_',name,'.jpg')) ;
                imwrite(im,img_rem_name);
            end
        end
    end

    %% save results to the csv file [methods{i}_filter.csv]
    % average filter
    parfor i=1:length(methods)
        writetable(t_tabs_avg{i}, string(strcat(folder_csv_q,string(methods(i)),'_avg.csv')));
    end

    %% gaussian filter
    parfor i=1:length(methods)
        writetable(t_tabs_gauss{i}, strcat(folder_csv_q, string(methods(i)),'_gauss.csv'));
    end
end

%% Process results, count means, create heatmaps and boxplots
% tables for results
% gaussian filter
t_size_gauss = {'Size' [0 13]};
t_vars_gauss = {'VariableTypes', ["string", "string", "double", ...
    "double", "double", "double", "double","double","double","double", "double", "double", "double"]};

t_names_gauss = {'VariableNames', ["type", "method", "sigma", ...
    "filter_size", "jpg_PSNR", "PSNR", "deltaPSNR","jpg_SSIM","SSIM",...
    "deltaSSIM", "jpg_brisque", "brisque", "deltaBrisque"]};

gauss_mean_table = table(t_size_gauss{:}, t_vars_gauss{:}, t_names_gauss{:});
t_gauss_res={gauss_mean_table, gauss_mean_table, gauss_mean_table, gauss_mean_table};

% avg filter
t_size_avg = {'Size' [0 12]};
t_vars_avg = {'VariableTypes', ["string", "string", ...
    "double", "double", "double", "double","double","double","double", "double", "double", "double"]};

t_names_avg = {'VariableNames', ["type", "method", ...
    "filter_size", "jpg_PSNR", "PSNR", "deltaPSNR","jpg_SSIM","SSIM",...
    "deltaSSIM", "jpg_brisque", "brisque", "deltaBrisque"]};

avg_mean_table = table(t_size_avg{:}, t_vars_avg{:}, t_names_avg{:});
t_avg_res={avg_mean_table, avg_mean_table, avg_mean_table, avg_mean_table};

for q=1:length(quality)
    %% count means for gaussian filtration results
    parfor k=1:length(methods)
        for i=1:length(sigmas)
            for j=1:length(filter_sizes)
                % extract rows
                idx=t_tabs_gauss{k}.sigma==sigmas(i) & t_tabs_gauss{k}.filter_size==filter_sizes(j);
                rows=t_tabs_gauss{k}(idx, :);
                % count means
                PSNR_mean=mean(rows{:,"PSNR"});
                delta_PSNR_mean=mean(rows{:,"delta_PSNR"});
                SSIM_mean=mean(rows{:,"SSIM"});
                delta_SSIM_mean=mean(rows{:,"delta_SSIM"});
                brisque_mean=mean(rows{:,"im_brisque"});
                delta_brisque_mean=mean(rows{:,"delta_brisque"});
                % save results to the table
                t_gauss_res{k}(end+1,:)={rows.type(1),rows.method(1), ...
                    rows.sigma(1), rows.filter_size(1), rows.jpg_PSNR(1), PSNR_mean, delta_PSNR_mean, rows.jpg_SSIM(1),...
                    SSIM_mean, delta_SSIM_mean, rows.jpg_brisque(1), brisque_mean, delta_brisque_mean};
            end
        end
    end

    %% count means for avg filtration results
    parfor k=1:length(methods)
        for i=1:length(filter_sizes)
            % extract rows
            idx=t_tabs_avg{k}.filter_size==filter_sizes(i);
            rows=t_tabs_avg{k}(idx, :);
            % count means
            PSNR_mean=mean(rows{:,"PSNR"});
            delta_PSNR_mean=mean(rows{:,"delta_PSNR"});
            SSIM_mean=mean(rows{:,"SSIM"});
            delta_SSIM_mean=mean(rows{:,"delta_SSIM"});
            brisque_mean=mean(rows{:,"im_brisque"});
            delta_brisque_mean=mean(rows{:,"delta_brisque"});
            % save results to the table
            t_avg_res{k}(end+1,:)={rows.type(1),rows.method(1), ...
                rows.filter_size(1), rows.jpg_PSNR(1), PSNR_mean, delta_PSNR_mean, rows.jpg_SSIM(1),...
                SSIM_mean, delta_SSIM_mean, rows.jpg_brisque(1), brisque_mean, delta_brisque_mean};
        end
    end

    %% save results to the csv file [methods{i}_filter_means.csv]
    % Path to the folder for results tables
    folder_means =strcat("..\ResultsTest\Tables\Mean\Q",string(quality(q)),"\");

    if isfolder(folder_means) == false
        mkdir(folder_means)
    end

    % gaussian filter
    parfor i=1:length(methods)
        writetable(t_avg_res{i}, string(strcat(folder_means,string(methods{i}),'_avg_means.csv')));
    end

    % avg filter
    parfor i=1:length(methods)
        writetable(t_gauss_res{i}, strcat(folder_means, string(methods{i}),'_gauss_means.csv'));
    end

    %% Create heatmaps
    % filepath to the results
    folder_heatmaps_gauss=strcat("..\ResultsTest\Tables\Heatmaps\Q",string(quality(q)),"\Gauss\");
    folder_heatmaps_avg=strcat("..\ResultsTest\Tables\Heatmaps\Q",string(quality(q)),"\Avg\");

    if isfolder(folder_heatmaps_gauss) == false
        mkdir(folder_heatmaps_gauss)
    end

    if isfolder(folder_heatmaps_avg) == false
        mkdir(folder_heatmaps_avg)
    end

    %% gaussian filter
    % columns with metrics
    columns_gauss={6; 7; 9; 10; 12; 13};

    parfor i=1:length(methods)
        for j=1:length(columns_gauss)
            % extract the column's name
            column_name=t_gauss_res{i}.Properties.VariableNames{columns_gauss{j}};
            % create a heatmap
            h=heatmap(t_gauss_res{i},"sigma","filter_size", ColorVariable=column_name);
            % save the heatmap
            exportgraphics(h, strcat(folder_heatmaps_gauss,methods{i},"_",column_name,".jpg"));
        end
    end

    %% avg filter
    %columns with metrics
    columns_avg={5; 6; 8; 9; 11; 12};
    parfor i=1:length(methods)
        for j=1:length(columns_avg)
            % extract the column's name
            column_name=t_avg_res{i}.Properties.VariableNames{columns_avg{j}};
            % create a heatmap
            h=heatmap(t_avg_res{i},1,"filter_size", ColorVariable=column_name);
            % save the heatmap
            exportgraphics(h, strcat(folder_heatmaps_avg,methods{i},"_",column_name,".jpg"))
        end
    end
end