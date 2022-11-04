function im_res = artifacts_removal_fixed(im, cut_point,sigm, filter_size)
% remove jpg compression artifacts from an RGB image
    
    %% preallocate memory
    [n, m, d] = size(im);
    all_edges = zeros(n, m, d, 'double'); % now we want numbers not logical values

    %% detect all edges for each image layer
    for i=1:d  
        %% extract a layer 
        layer = im(:,:,i);
        %% count gradients        
        [gmag, ~] = imgradient(layer, 'central');
        gmag_grayscale = mat2gray(gmag);
        gmag_grayscale=conv_to_uint8(gmag_grayscale); 
        %% detect edges
        [T, ~]=graythresh(gmag_grayscale); % makes image histogram inside the function
        T=T*255.0;
        gmag_grayscale(gmag_grayscale < T) = 0; % if pixel value is below treshold replace it with 0
        gmag_grayscale(gmag_grayscale > T) = gmag_grayscale(gmag_grayscale > T) - T;  % (piksel-treshold)/(1-treshold)
        imshow(gmag_grayscale);
        gmag_grayscale = double(gmag_grayscale);
        all_edges(:,:,i) = gmag_grayscale ./(255-T);  
        imshow(gmag_grayscale);
    end
    
    %% make a map of the edges ( edge in three channels => 0, compression grid and other => 1 )
    im_edges = sum(all_edges, 3);
    imshow(im_edges);
    im_edges = delete_false_edges(im_edges, n, m, cut_point);
    imshow(im_edges);
    im_edges = imopen(im_edges, strel('square',2));
    imshow(im_edges);
    map_edges = imcomplement(im_edges);
    imshow(map_edges);
    %% make a filter based on the chosen sigma
    filter_mask = make_gauss_filter(sigm, filter_size);

    %% make a weight map 
    W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');

    %% filter whole image
    im_res = imfilter(double(im) .* map_edges, ...
        filter_mask, 'symmetric', 'conv') ./ W;

    %% cast to uint8
    im_res = uint8(im_res);
    imshow(im_res);
end


%% Additional functions
function true_edges = delete_false_edges(im, n, m, cut)
% set borders 8x8 blocks to 0 
    
    %% count needed shifts caused by the very original image cut_point
    shift_r = mod(cut(1), 8) - 1;
    shift_c = mod(cut(2), 8) - 1;
    
    %% select rows to be copied
    rows = 1:n;
    rows = rows(mod(rows+shift_r, 8) ~= 0);
    rows = rows(mod(rows+shift_r, 8) ~= 1);

    %% select columns to be copied
    cols = 1:m;
    cols = cols(mod(cols+shift_c, 8) ~= 0);
    cols = cols(mod(cols+shift_c, 8) ~= 1);
    
    %% copy only true edges
    true_edges = zeros(n, m, 'double');
    true_edges(rows, cols) = im(rows, cols);

end

function mask = make_gauss_filter(sigm, f_size)
    [x, y] = meshgrid(-f_size/2:f_size/2, -f_size/2:f_size/2);
    to_be_exp = -(x.^2+y.^2) / (2*sigm*sigm);
    mask = exp(to_be_exp) / (2*pi*sigm*sigm);            
end

function converted = conv_to_uint8(im)
    im = double(im);
    converted = uint8(im ./ max(max(im)) * 255);
end


