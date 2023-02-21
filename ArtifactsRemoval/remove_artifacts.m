classdef remove_artifacts
    %REMOVE_ARTIFACTS class to perform artifacts removal operations

    properties
        Image 
        CutPoint
        Sigma
        FilterSize 
        FilterType
        Method
    end

    methods
        function obj = remove_artifacts(im, cut_point,sigm, filter_size,...
                filter_type, method)
            %REMOVE_ARTIFACTS Construct an instance of the remove_artifacts
            %class
            % im - compressed image
            % cut_point - cut point of the image ([1 1]) when the original .tiff image is
            % compressed in matlab and artifacts removal is run for the whole image
            % sigm - sigma parameter (standard deviation) for the gaussian filter
            % (for average filter set pass false value) 
            % filter_size - size of the filter
            % filter_type - type of the filter
            % method - artifacts removal method

            obj.CutPoint=cut_point;
            obj.Image=im;
            obj.Sigma=sigm;
            obj.FilterSize=filter_size;
            obj.FilterType=filter_type;
            obj.Method=method;
        end

        function im_res = run_artifacts_removal(obj)
            %RUN_ARTIFACTS_REMOVAL method removes artifacts
            % Method removes artifacts with chosen methods and filters
            % im_res - image after artifacts removal

            switch obj.Method
                case 'method_1'
                    im_res = run_method_1(obj);
                case 'method_2'
                    im_res = run_method_2(obj);
                case 'method_3'
                    im_res = run_method_3(obj);
                case 'blurr'
                    im_res = run_blurr(obj);
            end

            % cast to uint8
            im_res = im2uint8(im_res);
        end

        function im_res = run_method_1(obj)
            %RUN_OTSU artifacts removal method
            % function uses otsu algorithm in order to create a map of edges
             % im_res - image after artifacts removal

            im=im2double(obj.Image);
            filter_type=obj.FilterType;
            filter_size=obj.FilterSize;
            sigm=obj.Sigma;
            % preallocate memory
            [n, m, d] = size(im);
            all_edges = zeros(n, m, d, 'logical');
            filt=filters(filter_type, filter_size, sigm);

            % detect all edges for each image layer
            for i=1:d
                % extract a layer
                layer = im(:,:,i);

                % count gradients
                [gmag, ~] = imgradient(layer, 'central');
                gmag_grayscale = mat2gray(gmag);

                % detect edges
                all_edges(:,:,i) = imbinarize(gmag_grayscale, 'global'); %Otsu

            end

            % make a map of the edges
            im_edges = logical(sum(all_edges, 3) == 3); % sum ones
            im_edges = additional_functions.delete_false_edges(im_edges, n, m, obj.CutPoint);
            im_edges = imopen(im_edges, strel('square',2));
            map_edges = im2double(~im_edges);

            % make a filter based on the chosen parameters
            filter_mask=make_filter(filt);

            % make a weight map
            W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');

            % filter whole image
            im_res = imfilter(im .* map_edges, ...
                filter_mask, 'symmetric', 'conv') ./ W;

             im_res(isnan(im_res))=im(isnan(im_res));
        end

        function im_res = run_method_2(obj)
            %RUN_MULTILEVEL_TRESHOLDING artifact removal method
            % function uses multilevel tresholding in order to create a map of edges
             % im_res - image after artifacts removal

            im=im2double(obj.Image);
            filter_type=obj.FilterType;
            filter_size=obj.FilterSize;
            sigm=obj.Sigma;
            filt=filters(filter_type, filter_size, sigm);

            % preallocate memory
            [n, m, d] = size(im);
            im_res=zeros(n,m,d,"double");
            all_edges = zeros(n, m, d, 'double'); % now numbers not logical values
            all_edges_bin=zeros(n,m,d,'logical'); % to detect ones in three channels
            % detect all edges for each image layer
            for i=1:d
                % extract a layer
                layer = im(:,:,i);
                % count gradients
                [gmag, ~] = imgradient(layer, 'central');
                gmag_grayscale = mat2gray(gmag);
                % detect edges
                [T, ~]=graythresh(gmag_grayscale); % Computes treshold value (Otsu algorithm)
                gmag_grayscale(gmag_grayscale < T) = 0; % if pixel value is below treshold replace it with 0
                gmag_grayscale(gmag_grayscale > T) = gmag_grayscale(gmag_grayscale > T) - T;  % (pixel-treshold)
                all_edges(:,:,i) = gmag_grayscale ./(1-T); %(pixel - treshold)/(1-treshold) or 0/(1-treshold)=0
                all_edges_bin(:,:,i) = imbinarize(gmag_grayscale, 'global'); %Otsu for three channel edges validation
            end

            % make a map of the edges ( edge in three channels => 0, compression grid and other => 1 )
            im_edges_binary=logical(sum(all_edges_bin, 3) == 3);
            im_edges_binary=additional_functions.delete_false_edges(im_edges_binary, n, m, obj.CutPoint);
            im_edges_binary = imopen(im_edges_binary, strel('square',2));

            % make a filter based on the chosen sigma
            filter_mask=make_filter(filt);

            for i=1:d
                % create map for each layer
                im_edges=all_edges(:,:,i).*im_edges_binary;
                map_edges = imcomplement(im_edges);

                % make a weights map for each layer
                W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');

                % filter whole image layer
                im_res(:,:,i) = imfilter(im(:,:,i) .* map_edges, ...
                    filter_mask, 'symmetric', 'conv') ./ W;
            end
        end

        function im_res = run_blurr(obj)
            %RUN_MULTILEVEL_TRESHOLDING artifact removal method
            % function uses multilevel tresholding in order to create a map of edges
             % im_res - image after artifacts removal

            im=im2double(obj.Image);
            filter_type=obj.FilterType;
            filter_size=obj.FilterSize;
            sigm=obj.Sigma;
            filt=filters(filter_type, filter_size, sigm);
            filter_mask=make_filter(filt);
            im_res = imfilter(im, ...
                filter_mask, 'symmetric', 'conv');
        end

        function im_res = run_method_3(obj)
            %RUN_FIXED_MULTILEVEL_TRESHOLDING artifact removal method
            % function uses multilevel tresholding and Otsu method
            % in order to create maps of edges in the last step results
            % of both methods are added together with weights
             % im_res - image after artifacts removal

            im=im2double(obj.Image);
            filter_type=obj.FilterType;
            filter_size=obj.FilterSize;
            sigm=obj.Sigma;
            filt=filters(filter_type, filter_size, sigm);

            % preallocate memory
            [n, m, d] = size(im);
            im_res=zeros(n, m, d, "double");
            all_edges = zeros(n, m, d, 'double'); % now numbers not logical values
            all_edges_bin=zeros(n,m,d,'logical'); % to detect ones in three channels
            % detect all edges for each image layer
            for i=1:d
                % extract a layer
                layer = im(:,:,i);
                % count gradients
                [gmag, ~] = imgradient(layer, 'central');
                gmag_grayscale = mat2gray(gmag);
                % detect edges
                [T, ~]=graythresh(gmag_grayscale); % compute treshold value (Otsu algorithm)
                gmag_grayscale(gmag_grayscale < T) = 0; % if pixel value is below treshold replace it with 0
                gmag_grayscale(gmag_grayscale > T) = gmag_grayscale(gmag_grayscale > T) - T;  % (piksel-treshold)
                all_edges(:,:,i) = gmag_grayscale ./(1-T); %(piksel - treshold)/(1-treshold) or 0/(1-treshold)=0

                all_edges_bin(:,:,i) = imbinarize(gmag_grayscale, 'global'); %Otsu for three channel edges validation
            end

            % Prepare binary map of edges
            im_edges_binary=logical(sum(all_edges_bin, 3) == 3);
            im_edges_binary=additional_functions.delete_false_edges(im_edges_binary, n, m, obj.CutPoint);
            im_edges_binary_open = imopen(im_edges_binary, strel('square', 2));
            map_edges_binary=double(~im_edges_binary_open);

            % Create a filter mask
            filter_mask=make_filter(filt);
          
            % Prepare weights matrix
            W2 = imfilter(map_edges_binary, filter_mask, 'symmetric', 'conv');

            % Create result image
            im_res_bin = imfilter(im .* map_edges_binary, ...
                filter_mask, 'symmetric', 'conv') ./ W2;

            % Remove black pixels
            im_res_bin(isnan(im_res_bin))=im(isnan(im_res_bin));

            for i=1:d
                im_edges=all_edges(:,:,i).*im_edges_binary_open;
                map_edges = imcomplement(im_edges);

                % make a weight map
                W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');

                % filter whole image layer
                im_res(:,:,i) = imfilter(im(:,:,i) .* map_edges, ...
                    filter_mask, 'symmetric', 'conv') ./ W;

                % add results with correct weights
                im_res(:,:,i)=im_res(:,:,i).*map_edges+(1.- map_edges).*im_res_bin(:,:,i);
            end
        end
    end
end

