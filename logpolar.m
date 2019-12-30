function Dst = logpolar(Src, varargin)
%% Dst = logpolar(Src, Dst, Center, MaxRho)
%
% # Required/Optional
%   Src     : Input Image
%   Dst     : Output Image or Size of Image (default: same size as Src)
%   Center  : Center Position (Y, X order in Pixcel; default: center of Src)
%   MaxRho  : Maximum value of Rho (default: Maximum length from center to the Four Corners)
%
% # Name Value pair
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

% Gaku Hatanaka


Dst = warpPolar(Src, varargin{:}, 'LinearPolarMapping', false);