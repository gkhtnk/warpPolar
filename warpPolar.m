function Dst = warpPolar(Src, varargin)
%% Dst = warpPolar(Src, Dst, Center, MaxRho)
% Dst = warpPolar(Src)
% Dst = warpPolar(Src, Dst)
% Dst = warpPolar(Src, SizDst)
% Dst = warpPolar(___, Name, Value)
% 
% # Required/Optional
%   Src     : Input Image
%   Dst     : Output Image or Size of Image (default: same size as Src)
%   Center  : Center Position (Y, X order in Pixcel; default: center of Src)
%   MaxRho  : Maximum value of Rho (default: Maximum length from center to the Four Corners)
%
% # Name Value pair
%   LinearPolarMapping    : Linear Polar Mapping (true) or Log Polar Mapping (false)
%           * true
%           - false
%   ForwardTransformation : Forward Transformation (true) or Inverse Transformation (false)
%           * true
%           - false
%   InterpolationMethod   : Interpolation method
%           * 'linear'
%           - 'nearest'
%           - 'natural'
%   ExtrapolationMethod   : Extrapolation method
%           - 'linear'
%           - 'nearest'
%           * 'none'
%
%   This function independently process different XY planes in Src.
%   Ex. For RGB image, this function create geometly for R, G, B channel and
%   interpolate values for each.

% Gaku Hatanaka




% Input parser
[SizSrc, ImgSrc, SizDst, ImgDst, Center, MaxRho, LinearPolarMapping, ForwardTransformation, InterpolationMethod, ExtrapolationMethod] = parseArgs(Src, varargin{:});


if ForwardTransformation
    
    % Center of ImgSrc
    if isempty(Center)
        Center = SizSrc/2+0.5;
    end
    
    
    % Magnification factor
    MaxThe = 2*pi;
    if isempty(MaxRho)
        MaxRho = max(max(hypot([1; SizSrc(1)]- Center(1), [1, SizSrc(2)] - Center(2))));
    end
    
    
    % Interpolation grids
    [RowSrc, ColSrc] = ndgrid(1:SizSrc(1), 1:SizSrc(2));
    if LinearPolarMapping
        [TheDst, RhoDst] = ndgrid(feval(@(x) x(1:end-1), linspace(0, MaxThe, SizDst(1)+1)), linspace(0, lin(MaxRho), SizDst(2)));
    else
        [TheDst, RhoDst] = ndgrid(feval(@(x) x(1:end-1), linspace(0, MaxThe, SizDst(1)+1)), linspace(0, log(MaxRho), SizDst(2)));
    end
    
    
    % Backward Implementation
    if LinearPolarMapping
        RowDst = lin(RhoDst).*sin(TheDst) + Center(1);
        ColDst = lin(RhoDst).*cos(TheDst) + Center(2);
    else
        RowDst = exp(RhoDst).*sin(TheDst) + Center(1);
        ColDst = exp(RhoDst).*cos(TheDst) + Center(2);
    end
    
    
    % Excute Forward Transformation
    for dim = 1:prod(SizSrc(3:end))
        Forward = scatteredInterpolant(ColSrc(:), RowSrc(:), reshape(ImgSrc(:, :, dim), [], 1), InterpolationMethod, ExtrapolationMethod);
        ImgDst(:, :, dim) = Forward(ColDst, RowDst);
    end
    
    
else % Inverse Transformation
    
    % Center of ImgDst
    if isempty(Center)
        Center = SizDst/2+0.5;
    end
    
    
    % Magnification factor
    MaxThe = 2*pi;
    if isempty(MaxRho)
        MaxRho = max(max(hypot([1; SizDst(1)]- Center(1), [1, SizDst(2)] - Center(2))));
    end
    
    
    % Interpolation grids
    [RowDst, ColDst] = ndgrid(1:SizDst(1), 1:SizDst(2));
    if LinearPolarMapping
        [TheSrc, RhoSrc] = ndgrid(feval(@(x) x(1:end-1), linspace(0, MaxThe, SizSrc(1)+1)), linspace(0, lin(MaxRho), SizSrc(2)));
    else
        [TheSrc, RhoSrc] = ndgrid(feval(@(x) x(1:end-1), linspace(0, MaxThe, SizSrc(1)+1)), linspace(0, log(MaxRho), SizSrc(2)));
    end
    
    % Concat "Head" and "Tail" to make the data "Circular"
    PreIdx = floor(SizSrc(1)/2):SizSrc(1);
    PstIdx = 1:ceil(SizSrc(1)/2);
    TheSrc = cat(1, TheSrc(PreIdx, :)-2*pi, TheSrc, TheSrc(PstIdx, :)+2*pi);
    RhoSrc = cat(1, RhoSrc(PreIdx, :),      RhoSrc, RhoSrc(PstIdx, :));
    ImgSrc = cat(1, ImgSrc(PreIdx, :, :),   ImgSrc, ImgSrc(PstIdx, :, :));
    
    
    % Backward Implementation
    TheDst = mod(atan2(RowDst-Center(1), ColDst-Center(2)), 2*pi);
    if LinearPolarMapping
        RhoDst = max(0, lin(hypot(RowDst-Center(1), ColDst-Center(2))));
    else
        RhoDst = max(0, log(hypot(RowDst-Center(1), ColDst-Center(2))));
    end
    
    
    % Excute Inverse Transformation
    for dim = 1:prod(SizSrc(3:end))
        Inverse = scatteredInterpolant(RhoSrc(:), TheSrc(:), reshape(ImgSrc(:, :, dim), [], 1), InterpolationMethod, ExtrapolationMethod);
        ImgDst(:, :, dim) = Inverse(RhoDst, TheDst);
    end
end

Dst = ImgDst;
end



% This function is just for increase readability
function dst = lin(src)
dst = src;
end




function [SizSrc, ImgSrc, SizDst, ImgDst, Center, MaxRho, LinearPolarMapping, ForwardTransformation, InterpolationMethod, ExtrapolationMethod] = parseArgs(Src, varargin)
% Input parser
parser = inputParser;

% Required arguments
parser.addRequired('Src', @(x) isnumeric(x));

% Any optional, positional arguments
parser.addOptional('Dst',    [], @(x) isnumeric(x));
parser.addOptional('Center', [], @(x) isnumeric(x) & (isempty(x) | isvector(x) & 1 < numel(x)));
parser.addOptional('MaxRho', [], @(x) isnumeric(x) & (isempty(x) | isscalar(x) & 0 < x));

% Any name-value pairs
parser.addParameter('LinearPolarMapping', true, @(x) islogical(x));
parser.addParameter('ForwardTransformation', true, @(x) islogical(x));
parser.addParameter('InterpolationMethod', 'linear', @(option) any(strcmp(option, {'linear', 'nearest', 'natural'})));
parser.addParameter('ExtrapolationMethod', 'none', @(option) any(strcmp(option, {'none', 'linear', 'nearest'})));

% Parse function inputs
parser.parse(Src, varargin{:});


% Assign values for outputs
Src    = parser.Results.Src;
Dst    = parser.Results.Dst;
Center = parser.Results.Center;
MaxRho = parser.Results.MaxRho;
LinearPolarMapping = parser.Results.LinearPolarMapping;
ForwardTransformation = parser.Results.ForwardTransformation;
InterpolationMethod = parser.Results.InterpolationMethod;
ExtrapolationMethod = parser.Results.ExtrapolationMethod;


% For Src, obtain Size and reshpae to 3 dimensions (row x col x num)
SizSrc = arrayfun(@(dim) size(Src, dim), 1:max(3, ndims(Src)));
ImgSrc = Src(:, :, :);


% For Dst
if isempty(Dst) % Default size and type is same as ImgSrc
    SizDst = SizSrc;
    ImgDst = zeros(SizDst, 'like', ImgSrc);
else
    if isvector(Dst) % In case size is specified by vector Dst, type is same as ImgSrc
        SizDst = [Dst(1), Dst(2), SizSrc(3:end)];
        ImgDst = zeros(SizDst, 'like', ImgSrc);
    else % In case size is specified by the size of Dst, type is same as Dst
        SizDst = arrayfun(@(dim) size(Dst, dim), 1:max(3, ndims(Dst)));
        if prod(SizDst(3:end)) == prod(SizSrc(3:end))
            ImgDst = zeros(SizDst, 'like', Dst);
        end
    end
end
if ~exist('ImgDst', 'var')
    error('warpPolar:CanNotInitializedDst', 'Input Dst is wrong');
end


end
