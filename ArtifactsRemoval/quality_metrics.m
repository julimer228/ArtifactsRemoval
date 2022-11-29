classdef quality_metrics
    %QUALITY_METRICS Static class used to calculate quality metrics and
    % percentage difference of results for image before and after artifacts
    % removal
    methods (Static)
        %COUNT_METRICS function to count image quality metrics
        function [im_ssim, im_psnr, im_brisque, im_niqe] = count_metrics(im, im_org, model)
            im_ssim=ssim(im, im_org);
            im_psnr=psnr(im, im_org);
            im_brisque=brisque(im);
            im_niqe=niqe(im,model);
        end

        %COUNT_DELTA function to count percentage difference between
        %quality metrics for jpg image and image after artifacts removal
        function delta = count_delta(im_metric, jpg_metric)
            delta=(im_metric - jpg_metric) / jpg_metric * 100;
        end

        function model = train_niqe(filepath)
            setDir = fullfile(filepath);
            imds = imageDatastore(setDir,'FileExtensions',{'.tif'});
            model = fitniqe(imds);
        end
    end
end

