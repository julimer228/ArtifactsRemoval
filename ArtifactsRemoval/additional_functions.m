classdef additional_functions
    %ADDITIONAL_FUNCTIONS Other functions used during processing images

    methods (Static)
        function true_edges = delete_false_edges(im, n, m, cut_point)
            %DELETE_FALSE_EDGES function to detect jpg compression grid
            % copies the real edges and removes false edges from the image
            % for binary images it returns 2d logical array
            % for double images it returns 2d double array

            % set borders 8x8 blocks to 0
            % count needed shifts caused by the very original image cut_point
            shift_r = mod(cut_point(1), 8) - 1;
            shift_c = mod(cut_point(2), 8) - 1;

            % select rows to be copied
            rows = 1:n;
            rows = rows(mod(rows+shift_r, 8) ~= 0);
            rows = rows(mod(rows+shift_r, 8) ~= 1);

            % select columns to be copied
            cols = 1:m;
            cols = cols(mod(cols+shift_c, 8) ~= 0);
            cols = cols(mod(cols+shift_c, 8) ~= 1);

            % copy only true edges
            true_edges = zeros(n, m, class(im));
            true_edges(rows, cols) = im(rows, cols);
        end

        function converted = conv_to_uint8(im)
            %CONV_TO_UINT8 function to convert an image to uint8 image
            im = double(im);
            converted = uint8(im ./ max(max(im)) * 255);
        end

        function params = create_params(sigmas, filter_sizes)
            %CREATE_PARAMS creates params cell
            params=cell(length(sigmas)*length(filter_sizes),2);
            k=0;
            for i=0:length(params)-1
                if(mod(i,length(sigmas))==0)
                    k=k+1;
                end
                params{i+1,1}=sigmas(mod(i,length(sigmas))+1);
                params{i+1,2}=filter_sizes(k);
            end
        end

        function compress_files(im_path, res_path, Q)
            %COMPRESS_FILES Function to compress files with jpeg algorithm.
            % im_path - folder with files to compress
            % res_path - folder with results (must be different than im_path)
            % Q - vector of compression quality parameters

            im_files = dir(im_path);

            % set a path for result images
            images_folder = strcat(res_path,'\Q');

            for i=1:length(Q)
                % Check if folder exists, if not create it
                images_folder_q=strcat(images_folder,string(Q(i)));

                if isfolder(images_folder_q) == false
                    mkdir(images_folder_q);
                end

                for ind=3:length(im_files)
                    % read an image and convert it into uint8
                    im_name = strsplit(im_files(ind).name, '.');
                    f_name = [im_files(ind).folder '\' im_files(ind).name];
                    im = imread(f_name);

                    % convert to uint8
                    im_org = additional_functions.conv_to_uint8(im);

                    % set image name
                    res_name=strcat(images_folder_q,'\',im_name(1),'.jpg');

                    % compress to jpg with quality Q
                    imwrite(im_org, res_name, 'jpg', 'Quality', Q(i));
                end
            end
        end

        function perform_segmentation(im_path, res_filepath)
            %PERFORM_SEGMENTATION Function  to perform segmentation
            %   filepath - directory with images to segment
            %   res_filepath - directory for results
            im_files = dir(im_path);

            for ind=3:length(im_files)
                im_name = strsplit(im_files(ind).name, '.');
                name=string(im_name(1));
                f_name = [im_files(ind).folder '\' im_files(ind).name];
                im = imread(f_name);
                im_org = additional_functions.conv_to_uint8(im);
                numColors = 3;
                L_org = imsegkmeans(im_org,numColors);
                B_org = labeloverlay(im_org,L_org);
                imshow(B_org);
                title(name);
                res_filename=strcat(res_filepath,name,'_segm.png');
                imwrite(B_org,res_filename);
            end
        end

    end
end

