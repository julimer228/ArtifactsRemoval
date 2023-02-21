%% script to tune algorithms parameters

% set a path to the images
im_path = '..\BreCaHAD\images\*.tif';
im_files = dir(im_path);

% set a path for result images
image_folder = '..\Results\Images\Q';

%set a path for result .csv files
folder_csv ='..\Results\Tabels\Raw\Q';


%train NIQE metric
model=quality_metrics.train_niqe(im_path);

%% make a tables for the results
% gaussian filter
t_size_gauss = {'Size' [0 14]};
t_vars_gauss = {'VariableTypes', ["string", "string", "string", "double", ...
    "double", "double", "double", "double","double","double","double", "double","double", "double"]};

t_names_gauss = {'VariableNames', ["name", "type", "method", "sigma", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_niqe", "im_niqe", "delta_niqe"]};

t_res_gauss = table(t_size_gauss{:}, t_vars_gauss{:}, t_names_gauss{:});

% average filter
t_size_avg = {'Size' [0 13]};
t_vars_avg = {'VariableTypes', ["string", "string", "string", ...
    "double","double","double","double","double","double","double","double", "double", "double"]};

t_names_avg = {'VariableNames', ["name", "type", "method", ...
    "filter_size", "jpg_PSNR", "PSNR", "delta_PSNR","jpg_SSIM","SSIM",...
    "delta_SSIM", "jpg_niqe", "im_niqe", "delta_niqe"]};

t_res_avg = table(t_size_avg{:}, t_vars_avg{:}, t_names_avg{:});

% parameters
quality=[10 30 50 70 90];
sigmas =[0.4 0.7 1.1 1.4 1.7 2 2.3 2.6 2.9];
filter_sizes =[3 5 7 9 11 13 15 17 19];
methods =["method_1" "method_2" "method_3" "blurr"];
cut_point=[1 1];
use_gauss=true;
use_avg=true;
use_sigma_avg=false;

% create a cell with parameters for parallel operations
params=additional_functions.create_params(sigmas, filter_sizes);

for q=1:length(quality)
    % Check if folders exist if not, create them
    image_folder_gauss=strcat(image_folder, string(quality(q)),'\Gauss\');
    image_folder_avg=strcat(image_folder, string(quality(q)),'\Avg\');
    folder_csv_q=strcat(folder_csv, string(quality(q)),'\');

    for m=1:length(methods)

        % create folders for each method and filter type
        folder_g=strcat(image_folder_gauss,'/',methods(m),'/');
        folder_a=strcat(image_folder_avg,'/',methods(m),'/');
        if isfolder(folder_g) == false && use_gauss==true
            mkdir(folder_g);
        end
        if isfolder(folder_a) == false && use_avg==true
            mkdir(folder_a);
        end
    end

    for i=1:length(methods)

        % create tabels for results
        t_tabs_gauss=cell(length(params),1);
        for t=1:length(params)
            t_tabs_gauss{t}=t_res_gauss;
        end

        t_tabs_avg=cell(length(filter_sizes),1);
        for t=1:length(params)
            t_tabs_avg{t}=t_res_avg;
        end

        %% main loop over parameters and images
        method=methods(i);

        folder_csv_q_m_avg=strcat(folder_csv_q,method,'\Avg\');
        folder_csv_q_m_gauss=strcat(folder_csv_q,method,'\Gauss\');
        if isfolder(folder_csv_q_m_avg) == false && use_avg==true
            mkdir(folder_csv_q_m_avg);
        end
        if isfolder(folder_csv_q_m_gauss) == false && use_gauss==true
            mkdir(folder_csv_q_m_gauss);
        end

        for ind=1:2%length(im_files)
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
            [jpg_ssim, jpg_psnr, jpg_niqe] = quality_metrics.count_metrics(im_jpg, im_org,model);

            % gaussian filter
            if use_gauss==true
                % run filters
                parfor k=1:length(params)
                    param=params(k,:);
                    sigma=cell2mat(param(1,1));
                    filter_size=cell2mat(param(1,2));
                    % run algorithm
                    rem = remove_artifacts(im_jpg, cut_point, sigma,...
                        filter_size, 'gauss', method);
                    im=run_artifacts_removal(rem);

                    % count metrics
                    [im_ssim, im_psnr, im_niqe] = quality_metrics.count_metrics(im, im_org,model);
                    delta_psnr = quality_metrics.count_delta(im_psnr, jpg_psnr);
                    delta_ssim = quality_metrics.count_delta(im_ssim, jpg_ssim);
                    delta_niqe=quality_metrics.count_delta(im_niqe, jpg_niqe);
                    % save row to the table
                    t_tabs_gauss{k}(end+1,:) = {name, 'gauss',method, ...
                        sigma, filter_size, jpg_psnr, im_psnr, delta_psnr, jpg_ssim,...
                        im_ssim, delta_ssim, jpg_niqe, im_niqe, delta_niqe};

                    % save image to a file
                    % [gauss_method_s{sigma}_f{filter_size}_name.jpg]
                    img_rem_name_gauss = string(strcat(image_folder_gauss,'\',method,'\', ...
                        's_',string(sigma),'_f_',string(filter_size),name,'.png')) ;
                    imwrite(im,img_rem_name_gauss,"png");
                end
            end

            % save results
            for idx=1:length(params)
                param=params(idx,:);
                writetable(t_tabs_gauss{idx}, strcat(folder_csv_q_m_gauss,'sigma_',string(param(1,1)),'f_size',string(param(1,2)),'_gauss.csv'));
            end


            % average filter
            if use_avg==true
                parfor k=1:length(filter_sizes)
                    %Average filter
                    % run the algorithm
                    rem_avg = remove_artifacts(im_jpg, cut_point, use_sigma_avg,...
                        filter_sizes(k), 'avg', method);
                    im_avg=run_artifacts_removal(rem_avg);

                    % count metrics
                    [im_ssim_avg, im_psnr_avg, im_niqe] = quality_metrics.count_metrics(im_avg, im_org,model);
                    delta_psnr_avg = quality_metrics.count_delta(im_psnr_avg, jpg_psnr);
                    delta_ssim_avg = quality_metrics.count_delta(im_ssim_avg, jpg_ssim);
                    delta_niqe=quality_metrics.count_delta(im_niqe, jpg_niqe);
                    % save results to the table
                    t_tabs_avg{k}(end+1,:) = {name, 'avg',method, ...
                        filter_sizes(k), jpg_psnr, im_psnr_avg, delta_psnr_avg, jpg_ssim,...
                        im_ssim_avg, delta_ssim_avg,jpg_niqe, im_niqe, delta_niqe};

                    % save image to a file
                    % [avg_method_f{filter_size}_name.jpg]
                    img_rem_name_avg = string(strcat(image_folder_avg,'\',method,'\','f_',...
                        string(filter_sizes(k)),'_',name,'.png')) ;
                    imwrite(im_avg,img_rem_name_avg);
                end

                % save results
                for idx=1:length(filter_sizes)
                    writetable(t_tabs_avg{idx}, string(strcat(folder_csv_q_m_avg,string(filter_sizes(idx)),'_avg.csv')));
                end
            end
        end
    end
end