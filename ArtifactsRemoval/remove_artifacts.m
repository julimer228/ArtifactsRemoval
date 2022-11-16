classdef remove_artifacts
    %REMOVE_ARTIFACTS class to perform artifacts removal operations
    
    properties
        Image 
        CutPoint 
        Sigma {mustBeNumericOrLogical}
        FilterSize {mustBeNumericOrLogical}
        FilterType 
        TresholdingMethod 
        RemoveBlackPixels
    end
    
    methods
        function obj = remove_artifacts(im, cut_point,sigm, filter_size,...
                filter_type, tresholding, remove_black_pixels)
            %REMOVE_ARTIFACTS Construct an instance of the remove_artifacts
            %class
            obj.CutPoint=cut_point;
            obj.Image=im;
            obj.Sigma=sigm;
            obj.FilterSize=filter_size;
            obj.FilterType=filter_type;
            obj.TresholdingMethod=tresholding;
            obj.RemoveBlackPixels=remove_black_pixels;
        end
        
        function im_res = run_artifacts_removal(obj)
            %RUN_ARTIFACTS_REMOVAL method removes artifacts
            %   Method removes artifacts with chosen methods and filters

              switch obj.TresholdingMethod
                case 'otsu'
                    im_res = run_otsu(obj);
                case 'multilevel_tresholding'
                    im_res = run_multilevel_tresholding(obj);
                case 'fixed_multilevel_tresholding'
                    im_res = run_fixed_multilevel_tresholding(obj);
                case 'canny'
                    im_res = run_canny(obj);
              end  

              %% cast to uint8
              im_res = uint8(im_res);

              %% Remove black pixels
              if(obj.RemoveBlackPixels==true)
                  im_res(im_res==0)=obj.Image(im_res==0);
                  imshow(im_res);
              end
        end

        function im_res = run_canny(obj)
            im=obj.Image;
            filter_type=obj.FilterType;
            filter_size=obj.FilterSize;
            sigm=obj.Sigma;
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
                all_edges(:,:,i) = edge(gmag_grayscale,'Canny');
                imshow(all_edges(:,:,i));
            end

            %% make a map of the edges 
            im_edges = logical(sum(all_edges, 3) == 3); % sum ones 
            im_edges = additional_functions.delete_false_edges(im_edges, n, m, obj.CutPoint); 
            map_edges = double(~im_edges);
            
            %% make a filter based on the chosen parameters
            filter_mask=make_filter(filt);
        
            %% make a weight map 
            W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');
            
            %% filter whole image
            im_res = imfilter(double(im) .* map_edges, ...
                filter_mask, 'symmetric', 'conv') ./ W;
        end

        function im_res = run_otsu(obj)
            %RUN_OTSU artifact removal method
            % function uses otsu algorithm in order to create a map of edges
            im=obj.Image;
            filter_type=obj.FilterType;
            filter_size=obj.FilterSize;
            sigm=obj.Sigma;
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
            im_edges = additional_functions.delete_false_edges(im_edges, n, m, obj.CutPoint); 
            im_edges = imopen(im_edges, strel('square',2));
            map_edges = double(~im_edges);
            
            %% make a filter based on the chosen parameters
            filter_mask=make_filter(filt);
        
            %% make a weight map 
            W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');
            
            %% filter whole image
            im_res = imfilter(double(im) .* map_edges, ...
                filter_mask, 'symmetric', 'conv') ./ W;
        end

        function im_res = run_multilevel_tresholding(obj)
            %RUN_MULTILEVEL_TRESHOLDING artifact removal method
            % function uses multilevel tresholding in order to create a map of edges
                im=obj.Image;
                filter_type=obj.FilterType;
                filter_size=obj.FilterSize;
                sigm=obj.Sigma;
                filt=filters(filter_type, filter_size, sigm);

                %% preallocate memory
                [n, m, d] = size(im);
                all_edges = zeros(n, m, d, 'double'); % now numbers not logical values
                all_edges_bin=zeros(n,m,d,'logical'); % to detect ones in three channels
                %% detect all edges for each image layer
                for i=1:d  
                    %% extract a layer 
                    layer = im(:,:,i);
                    %% count gradients        
                    [gmag, ~] = imgradient(layer, 'central');
                    gmag_grayscale = mat2gray(gmag);
                    gmag_grayscale=additional_functions.conv_to_uint8(gmag_grayscale); 
                    %% detect edges
                    [T, ~]=graythresh(gmag_grayscale); % makes image histogram inside the function
                    T=T*255.0;
                    gmag_grayscale(gmag_grayscale < T) = 0; % if pixel value is below treshold replace it with 0
                    gmag_grayscale(gmag_grayscale > T) = gmag_grayscale(gmag_grayscale > T) - T;  % (piksel-treshold)
                    gmag_grayscale = double(gmag_grayscale);
                    all_edges(:,:,i) = gmag_grayscale ./(255-T); %(piksel - treshold)/(255-treshold)
                                                                 % or 0/(255-treshold)=0

                    all_edges_bin(:,:,i) = imbinarize(gmag_grayscale, 'global'); %Otsu for three channel validation

                end
                
                %% make a map of the edges ( edge in three channels => 0, compression grid and other => 1 )
                im_edges = sum(all_edges, 3);
                im_edges_binary=logical(sum(all_edges_bin, 3) == 3); % sum ones 
                im_edges=im_edges.*im_edges_binary; 
                im_edges = additional_functions.delete_false_edges(im_edges, n, m, obj.CutPoint);
                im_edges = imopen(im_edges, strel('square',2));
                map_edges = imcomplement(im_edges);
                %% make a filter based on the chosen sigma
                filter_mask=make_filter(filt);
            
                %% make a weight map 
                W = imfilter(map_edges, filter_mask, 'symmetric', 'conv');
            
                %% filter whole image
                im_res = imfilter(double(im) .* map_edges, ...
                    filter_mask, 'symmetric', 'conv') ./ W;
        end

        function im_res = run_fixed_multilevel_tresholding(obj)
                        %RUN_MULTILEVEL_TRESHOLDING artifact removal method
            % function uses multilevel tresholding in order to create a map of edges
                im=obj.Image;
                filter_type=obj.FilterType;
                filter_size=obj.FilterSize;
                sigm=obj.Sigma;
                filt=filters(filter_type, filter_size, sigm);

                %% preallocate memory
                [n, m, d] = size(im);
                all_edges = zeros(n, m, d, 'double'); % now numbers not logical values
                all_edges_bin=zeros(n,m,d,'logical'); % to detect ones in three channels
                %% detect all edges for each image layer
                for i=1:d  
                    %% extract a layer 
                    layer = im(:,:,i);
                    %% count gradients        
                    [gmag, ~] = imgradient(layer, 'central');
                    gmag_grayscale = mat2gray(gmag);
                    gmag_grayscale=additional_functions.conv_to_uint8(gmag_grayscale); 
                    %% detect edges
                    [T, ~]=graythresh(gmag_grayscale); % makes image histogram inside the function
                    T=T*255.0;
                    gmag_grayscale(gmag_grayscale < T) = 0; % if pixel value is below treshold replace it with 0
                    gmag_grayscale(gmag_grayscale > T) = gmag_grayscale(gmag_grayscale > T) - T;  % (piksel-treshold)
                    gmag_grayscale = double(gmag_grayscale);
                    all_edges(:,:,i) = gmag_grayscale ./(255-T); %(piksel - treshold)/(255-treshold)
                                                                 % or 0/(255-treshold)=0

                    all_edges_bin(:,:,i) = imbinarize(gmag_grayscale, 'global'); %Otsu for three channel validation

                end
                
                %% make a map of the edges ( edge in three channels => 0, compression grid and other => 1 )
                im_edges = sum(all_edges, 3);
                im_edges_binary=logical(sum(all_edges_bin, 3) == 3); % sum ones 
                im_edges=im_edges.*im_edges_binary; % check all channels

                % prepare multilevel tresholding map
                im_edges = additional_functions.delete_false_edges(im_edges, n, m, obj.CutPoint); 
                im_edges = imopen(im_edges, strel('square',2));
                map_edges = imcomplement(im_edges);

                % prepare binary map
                im_edges_binary=additional_functions.delete_false_edges(im_edges_binary,n,m,obj.CutPoint);
                im_edges_binary = imopen(im_edges_binary, strel('square', 2));    
                map_edges_binary=double(~im_edges_binary);

                %% make a filter based on the chosen sigma
                filter_mask=make_filter(filt);
            
                %% make a weight maps 
                W1 = imfilter(map_edges, filter_mask, 'symmetric', 'conv');
                W2 = imfilter(map_edges_binary, filter_mask, 'symmetric', 'conv');
            
                %% filter whole images
                im_res_level = imfilter(double(im) .* map_edges, ...
                    filter_mask, 'symmetric', 'conv') ./ W1;

                im_res_bin = imfilter(double(im) .* map_edges_binary, ...
                    filter_mask, 'symmetric', 'conv') ./ W2;

                % add results with correct weight
                im_res=im_res_level.*map_edges+(1.-map_edges).*im_res_bin;
        end
    end
end

