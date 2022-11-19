classdef quality_metrics
    %QUALITY_METRICS Static class used to calculate quality metrics and
    % percentage difference of results for image before and after artifacts
    % removal
    methods (Static)
        %COUNT_METRICS function to count image quality metrics
        function [im_ssim, im_psnr, im_brisque] = count_metrics(im, im_org)
            im_ssim=round(ssim(im, im_org), 3);
            im_psnr=round(psnr(im, im_org), 3);
            im_brisque=round(brisque(im),3);
        end

        %COUNT_DELTA function to count percentage difference between
        %quality metrics for jpg image and image after artifacts removal
        function delta = count_delta(im_metric, jpg_metric)
            delta=round((im_metric - jpg_metric) / jpg_metric * 100, 5);
        end
    end
end

