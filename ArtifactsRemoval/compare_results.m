%% Compare results for each quality
% maximize delta PSNR, delta SSIM, minimize brisque
% jpg quality parameters
quality = ["Q10" "Q30" "Q50" "Q70" "Q90"];

% create table for results
t_size = {'Size' [0 13]};
t_vars = {'VariableTypes', ["string", "string", "double", ...
    "double", "double", "double", "double","double","double","double", "double", "double", "double"]};

t_names = {'VariableNames', ["type", "method", "sigma", ...
    "filter_size", "jpg_PSNR", "PSNR", "deltaPSNR","jpg_SSIM","SSIM",...
    "deltaSSIM", "jpg_brisque", "brisque", "deltaBrisque"]};


% loop over the quality params
for qual_idx=1:length(quality)
    % load tables from the correct folder
    folder_csv =strcat("..\Results\Tables\Mean\",quality(qual_idx),"\*.csv");
    files = dir(folder_csv);

    compare_table = table(t_size{:}, t_vars{:}, t_names{:});
    % loop over tables with means
    for j=1:length(files)
        % load table
        tab_name = strsplit(files(j).name, '.');
        f_name = [files(j).folder '\' files(j).name];
        tab = readtable(f_name);

       
        % copy rows
        for k=1:height(tab)
            if(tab.type(1) == "avg")
                compare_table(end+1,:) = {tab.type(k),tab.method(k), ...
                    "null", tab.filter_size(k), tab.jpg_PSNR(k), tab.PSNR(k), tab.deltaPSNR(k), tab.jpg_SSIM(k),...
                    tab.SSIM(k), tab.deltaSSIM(k), tab.jpg_brisque(k), tab.brisque(k), tab.deltaBrisque(k)};
            else
                compare_table(end+1,:) = {tab.type(k),tab.method(k), ...
                    tab.sigma(k), tab.filter_size(k), tab.jpg_PSNR(k), tab.PSNR(k), tab.deltaPSNR(k), tab.jpg_SSIM(k),...
                    tab.SSIM(k), tab.deltaSSIM(k), tab.jpg_brisque(k), tab.brisque(k), tab.deltaBrisque(k)};
            end
        end
    end

    % sort rows 
    compare_table = sortrows (compare_table,{'deltaPSNR','deltaSSIM', 'deltaBrisque'},{'descend','descend', 'ascend'});
    % save result table
    filepath =strcat("..\Results\Tables\Sorted\",quality(qual_idx),"_sorted.csv");   
    writetable(compare_table,filepath); 
end
 




