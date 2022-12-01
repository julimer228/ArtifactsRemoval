%% Script to create boxplots

blurr_avg=readtable("..\ResultsCorrected\Tables\Raw\Q70\blurr\Avg\3_avg.csv");
tab1_avg=readtable("..\ResultsCorrected\Tables\Raw\Q70\otsu\Avg\3_avg.csv");
tab2_avg=readtable("..\ResultsCorrected\Tables\Raw\Q70\multi\Avg\3_avg.csv");
tab3_avg=readtable("..\ResultsCorrected\Tables\Raw\Q70\weights\Avg\3_avg.csv");

blurr_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q70\blurr\Gauss\11_gauss.csv");
tab1_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q70\otsu\Gauss\11_gauss.csv");
tab2_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q70\multi\Gauss\3_gauss.csv");
tab3_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q70\weights\Gauss\3_gauss.csv");

blurr_gauss=blurr_gauss(blurr_gauss.sigma==0.7,:);
tab1_gauss=tab1_gauss(tab1_gauss.sigma==1.1,:);
tab2_gauss=tab2_gauss(tab2_gauss.sigma==0.7,:);
tab3_gauss=tab3_gauss(tab3_gauss.sigma==0.7,:);




quality="Q10";
names=["blurr (avg)" "method 1 (avg)" "method 2 (avg)" "method 3 (avg)" "blurr (gauss)" "method 1 (gauss)" "method 2 (gauss)" "method 3 (gauss)"];
filters=["gauss" "avg"];
title=["SSIM" "PSNR" "NIQE" "BRISQUE"];

ssim_plot_avg=boxplot([blurr_avg.delta_SSIM tab1_avg.delta_SSIM tab2_avg.delta_SSIM tab3_avg.delta_SSIM blurr_gauss.delta_SSIM tab1_gauss.delta_SSIM tab2_gauss.delta_SSIM tab3_gauss.delta_SSIM],'Notch','on', ...
    'Labels',names);
psnr_plot_avg=boxplot([blurr_avg.delta_PSNR tab1_avg.delta_PSNR tab2_avg.delta_PSNR tab3_avg.delta_PSNR blurr_gauss.delta_PSNR tab1_gauss.delta_PSNR tab2_gauss.delta_PSNR tab3_gauss.delta_PSNR],'Notch','on', ...
    'Labels',names);
brisque_plot_avg=boxplot([blurr_avg.delta_brisque tab1_avg.delta_brisque tab2_avg.delta_brisque tab3_avg.delta_brisque blurr_gauss.delta_brisque tab1_gauss.delta_brisque tab2_gauss.delta_brisque tab3_gauss.delta_brisque],'Notch','on', ...
    'Labels',names);
niqe_plot_avg=boxplot([blurr_avg.delta_niqe tab1_avg.delta_niqe tab2_avg.delta_niqe tab3_avg.delta_niqe blurr_gauss.delta_niqe tab1_gauss.delta_niqe tab2_gauss.delta_niqe tab3_gauss.delta_niqe],'Notch','on', ...
    'Labels',names);




% %%Q30
% blurr_avg=readtable("..\ResultsCorrected\Tables\Raw\Q30\blurr\Avg\3_avg.csv");
% tab1_avg=readtable("..\ResultsCorrected\Tables\Raw\Q30\otsu\Avg\3_avg.csv");
% tab2_avg=readtable("..\ResultsCorrected\Tables\Raw\Q30\multi\Avg\3_avg.csv");
% tab3_avg=readtable("..\ResultsCorrected\Tables\Raw\Q30\weights\Avg\3_avg.csv");
% 
% blurr_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q30\blurr\Gauss\7_gauss.csv");
% tab1_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q30\otsu\Gauss\13_gauss.csv");
% tab2_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q30\multi\Gauss\3_gauss.csv");
% tab3_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q30\weights\Gauss\3_gauss.csv");
% 
% blurr_gauss=blurr_gauss(blurr_gauss.sigma==0.7,:);
% tab1_gauss=tab1_gauss(tab1_gauss.sigma==1.1,:);
% tab2_gauss=tab2_gauss(tab2_gauss.sigma==1.7,:);
% tab3_gauss=tab3_gauss(tab3_gauss.sigma==2,:);

%Q50
% blurr_avg=readtable("..\ResultsCorrected\Tables\Raw\Q50\blurr\Avg\3_avg.csv");
% tab1_avg=readtable("..\ResultsCorrected\Tables\Raw\Q50\otsu\Avg\3_avg.csv");
% tab2_avg=readtable("..\ResultsCorrected\Tables\Raw\Q50\multi\Avg\3_avg.csv");
% tab3_avg=readtable("..\ResultsCorrected\Tables\Raw\Q50\weights\Avg\3_avg.csv");
% 
% blurr_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q50\blurr\Gauss\15_gauss.csv");
% tab1_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q50\otsu\Gauss\15_gauss.csv");
% tab2_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q50\multi\Gauss\3_gauss.csv");
% tab3_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q50\weights\Gauss\3_gauss.csv");
% 
% blurr_gauss=blurr_gauss(blurr_gauss.sigma==0.7,:);
% tab1_gauss=tab1_gauss(tab1_gauss.sigma==1.1,:);
% tab2_gauss=tab2_gauss(tab2_gauss.sigma==1.1,:);
% tab3_gauss=tab3_gauss(tab3_gauss.sigma==1.1,:);


%Q=90
% blurr_avg=readtable("..\ResultsCorrected\Tables\Raw\Q90\blurr\Avg\3_avg.csv");
% tab1_avg=readtable("..\ResultsCorrected\Tables\Raw\Q90\otsu\Avg\3_avg.csv");
% tab2_avg=readtable("..\ResultsCorrected\Tables\Raw\Q90\multi\Avg\3_avg.csv");
% tab3_avg=readtable("..\ResultsCorrected\Tables\Raw\Q90\weights\Avg\3_avg.csv");
% 
% blurr_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q90\blurr\Gauss\5_gauss.csv");
% tab1_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q90\otsu\Gauss\3_gauss.csv");
% tab2_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q90\multi\Gauss\3_gauss.csv");
% tab3_gauss=readtable("..\ResultsCorrected\Tables\Raw\Q90\weights\Gauss\3_gauss.csv");
% 
% blurr_gauss=blurr_gauss(blurr_gauss.sigma==0.7,:);
% tab1_gauss=tab1_gauss(tab1_gauss.sigma==0.7,:);
% tab2_gauss=tab2_gauss(tab2_gauss.sigma==0.7,:);
% tab3_gauss=tab3_gauss(tab3_gauss.sigma==0.7,:);