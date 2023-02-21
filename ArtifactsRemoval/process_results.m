%% Process results, count means, create heatmaps

% tables for results
% gaussian filter
t_size_gauss = {'Size' [0 6]};
t_vars_gauss = {'VariableTypes', [ "double", ...
    "double", "double", "double", "double"]};

t_names_gauss = {'VariableNames', ["sigma","filter_size", "mean_delta_PSNR",...
    "mean_delta_SSIM", "mean_delta_niqe"]};
gauss_full_results=table();

% avg filter
t_size_avg = {'Size' [0 5]};
t_vars_avg = {'VariableTypes',
    ["double", "double", "double", "double"]};

t_names_avg = {'VariableNames', ["filter_size","mean_delta_PSNR",...
    "mean_delta_SSIM", "mean_delta_niqe"]};


folder_path ='..\ResultsGaussFunctionChanged\Tabels\Raw\Q';
folder_mean = '..\ResultsGaussFunctionChanged\Tabels\Mean\Q';
folder_heatmap = '..\ResultsGaussFunctionChanged\Tabels\Heatmap\Q';
quality = 10:20:90;
heatmap_vars=["mean_delta_PSNR",...
    "mean_delta_SSIM", "mean_delta_niqe"];
titles=["Mean of delta PSNR",...
    "Mean of delta SSIM", "Mean of delta NIQE"];

% Iterate through folders
for q=1:length(quality)
    f_path=strcat(folder_path, string(quality(q)),'\');

    % get method folders
    methods_folders=dir(f_path);

    for m=3:length(methods_folders)

        % make tables for results
        gauss_means = table(t_size_gauss{:}, t_vars_gauss{:}, t_names_gauss{:});
        avg_means = table(t_size_avg{:}, t_vars_avg{:}, t_names_avg{:});

        folder=methods_folders(m).folder;
        name_method=methods_folders(m).name;

        % get filter types folders
        filter_folder=dir(strcat(folder,'\',name_method,'\'));

        for f=3:length(filter_folder)

            folder=filter_folder(f).folder;
            name_filter=filter_folder(f).name;

            % Create folder for results
            mean_path=strcat(folder_mean, string(quality(q)),'\',name_method,'\',name_filter,'\');
            if isfolder(mean_path) == false
                mkdir(mean_path);
            end

            heatmap_path=strcat(folder_heatmap, string(quality(q)),'\',name_method,'\',name_filter,'\');
            if isfolder(heatmap_path) == false
                mkdir(heatmap_path);
            end

            
            % Get tables with results
            res_files=dir(strcat(folder,'\', name_filter,'\*.csv'));

            % Count means and save them
            if name_filter=="Avg"
                % table for result
                % read tables form csv
                for r=1:length(res_files)
                    % read file
                    tab=readtable([res_files(r).folder '\' res_files(r).name]);
                    tabstats= grpstats(tab,"filter_size","mean", "DataVars", ["delta_PSNR", "delta_SSIM", "delta_niqe"]);
                    tabstats=removevars(tabstats,{'GroupCount' });
                    avg_means=[avg_means;tabstats];
                end

                %Create heatmaps
                % Avg
                rows=length(avg_means.Properties.RowNames);
                additional_column(1:rows,1)=1;
                avg_means.name=additional_column;
                for j=1:length(heatmap_vars)
                    column_name=heatmap_vars(j);
                    title=titles(j);
                    h=heatmap(avg_means,"name","filter_size", ColorVariable=column_name,Title=title);
                    saveas(h,strcat(heatmap_path,name_method,"_",column_name,".jpg"));
                end

                % Save means to files
                avg_means=sortrows(avg_means, "filter_size");
                writetable(avg_means, strcat(mean_path, name_method, '_avg.csv'));


            elseif name_filter=="Gauss"
                % read tables form csv
                for r=1:length(res_files)
                    tab=readtable([res_files(r).folder '\' res_files(r).name]);
                    tabstats=grpstats(tab,["filter_size" "sigma"],"mean", "DataVars", ["delta_PSNR", "delta_SSIM", "delta_niqe"]);
                    tabstats=removevars(tabstats,{'GroupCount'});
                   % x=[strcat(tabstats.Properties.RowNames{1},string(quality(q)))];
                   % tabstats.Properties.RowNames{1}=x;
                    quality_column={quality(q)};
                    gauss_means=[gauss_means; tabstats];
                end

                quality_column=repmat(quality(q),height(gauss_means),1);
                gauss_means=addvars(gauss_means, quality_column);
                
                % Heatmaps
                % Gauss
                for j=1:length(heatmap_vars)
                    column_name=heatmap_vars(j);
                    title=titles(j);
                    h=heatmap(gauss_means,"filter_size","sigma", ColorVariable=column_name, Title=title);
                    saveas(h,strcat(heatmap_path,name_method,"_",column_name,"_gauss.jpg"));
                end



                % means
                gauss_means=sortrows(gauss_means, "filter_size");
                writetable(gauss_means, strcat(mean_path, name_method, '_gauss.csv'));

            end
        end
    end
end