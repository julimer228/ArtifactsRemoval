function im_res = artifacts_removal(im, cut_point,sigm, filter_size, filter_type)
% remove jpg compression artifacts from an RGB image
    %% preallocate memory
    [n, m, d] = size(im);
    all_edges = zeros(n, m, d, 'logical');
    filt=filters(filter_type, filter_size, sigm);

    %% detect all edges for each image layer
    for i=1:d  
        %% extract a layer 
        layer = im(:,:,i);
        
        %% count gradients        
        [gmag, ~] = imgradient(layer, 'central');
        gmag_grayscale = mat2gray(gmag);
        
        %% detect edges
        all_edges(:,:,i) = imbinarize(gmag_grayscale, 'global'); %Otsu  
    end
    
    %% make a map of the edges 
    im_edges = logical(sum(all_edges, 3) == 3); % sum ones 
    imshow(im_edges); 
    im_edges = delete_false_edges(im_edges, n, m, cut_point); 
    im_edges = imopen(im_edges, strel('square',2));
    map_edges = double(~im_edges);
    
    %% make a filter based on the chosen parameters
    filter_mask=make_filter(filt);

    %% make a weight map 
    W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');
    
    %% filter whole image
    im_res = imfilter(double(im) .* map_edges, ...
        filter_mask, 'symmetric', 'conv') ./ W;

    %% cast to uint8
    im_res = uint8(im_res);
    
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
    true_edges = zeros(n, m, 'logical');
    true_edges(rows, cols) = im(rows, cols);

end