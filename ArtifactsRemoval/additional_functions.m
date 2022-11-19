classdef additional_functions
    %ADDITIONAL_FUNCTIONS Other functions for conversion and operation on
    %images

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
    end
end

