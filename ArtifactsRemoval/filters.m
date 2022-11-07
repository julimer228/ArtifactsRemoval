classdef filters
    %FILTER Creates a filter based on the name
    %   Creates a filter mask of different types
    
    properties
        Type % type of the filter 
        Size {mustBeNumericOrLogical} % size of the filter or logical value false if not used
        Sigma {mustBeNumericOrLogical} % sigma or the logical value false if not used
    end
    
    methods
        function obj = filters(type, size, sigma)
            %FILTER Construct an instance of this class
            %   Creates the filter object
            obj.Type = type;
            obj.Size = size;
            obj.Sigma = sigma;
        end

        function mask = make_filter(obj)
            %MAKE_FILTER Creates a filter mask
            %   Creates a mask of chosen filter type
            switch obj.Type
                case 'gauss'
                    mask = gauss_filter(obj);
                case 'avg'
                    mask = avg_filter(obj);
            end
        end

        function mask = gauss_filter(obj)
            %GAUSS_FILTER Returns a gaussian filter mask
            % Creates a gaussian filter mask with the given size and sigma
            % Substract 1 from filter size, because we have to take 0
            % coordinate
            f_range=obj.Size - 1;
            sigm=obj.Sigma;
            [x, y] = meshgrid(-f_range/2:f_range/2, -f_range/2:f_range/2);
            to_be_exp = -(x.^2+y.^2) / (2*sigm*sigm);
            mask = exp(to_be_exp) / (2*pi*sigm*sigm);          
        end

        function mask = avg_filter(obj)
            %AVG_FILTER Returns an average filter mask
            % Creates an average filter mask with the given size and sigma
            f_size=obj.Size;
            mask = fspecial("average",[f_size f_size]);
        end
    end
end

