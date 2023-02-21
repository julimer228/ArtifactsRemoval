% script to create plots 
folder_path = '..\ResultsCorrelation2\Tabels\Mean\Q';
quality = 5:5:95;

niqe={length(quality)};
ssim={length(quality)};
psnr={length(quality)};


niqe_val={length(quality)};
ssim_val={length(quality)};
psnr_val={length(quality)};

% Iterate through folders
for q=1:length(quality)
    f_path=strcat(folder_path, string(quality(q)),'\');

    % get method folders
    methods_folders=dir(f_path);

    for m=3:length(methods_folders)

        folder=methods_folders(m).folder;
        name_method=methods_folders(m).name;

        % get filter types folders
        filter_folder=dir(strcat(folder,'\',name_method,'\'));

        for f=3:length(filter_folder)

            folder=filter_folder(f).folder;
            name_filter=filter_folder(f).name;

            % Get tables with results
            res_files=dir(strcat(folder,'\', name_filter,'\*.csv'));

            % Count means and save them

            if name_filter=="Gauss"
                % read tables form csv
                for r=1:length(res_files)
                    tab=readtable([res_files(r).folder '\' res_files(r).name]);
                    tab=sortrows(tab, "mean_delta_niqe", "ascend");
                    niqe{q}=tab{1,"sigma"};
                    niqe_val{q}=tab{1,"mean_delta_niqe"};
                    tab=sortrows(tab, "mean_delta_PSNR", "descend");
                    psnr{q}=tab{1,"sigma"};
                    psnr_val{q}=tab{1,"mean_delta_PSNR"};
                    tab=sortrows(tab, "mean_delta_SSIM", "descend");
                    ssim{q}=tab{1,"sigma"};
                    ssim_val{q}=tab{1,"mean_delta_SSIM"};
                end
            end
        end
    end
end

niqe=cell2mat(niqe);
psnr=cell2mat(psnr);
ssim=cell2mat(ssim);

figure
plot(quality, niqe, "g--o")
hold on
plot(quality, psnr, "r--o")
hold on
plot(quality, ssim,"b--o")
ylim([0 6.1]);
legend("delta NIQE","delta PSNR", "delta SSIM");
xlabel("Q");
ylabel("sigma");