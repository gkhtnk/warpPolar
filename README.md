# warpPolar
Implantation of polar transformation in matlab

- warpPolar.m
- linpolar.m
- logpolar.m

## warpPolar.m

### Input

**Required**

```
Src     : Input Image
```

**Optional**

```
Dst     : Output Image or Size of Image (default: same size as Src)
Center  : Center Position (Y, X order in Pixcel; default: center of Src)
MaxRho  : Maximum value of Rho (default: Maximum length from center to the Four Corners)
```

**Name Value pair**
```
LinearPolarMapping    : Linear Polar Mapping (true) or Log Polar Mapping (false)
        * true
        - false
ForwardTransformation : Forward Transformation (true) or Inverse Transformation (false)
        * true
        - false
InterpolationMethod   : Interpolation method
        * 'linear'
        - 'nearest'
        - 'natural'
ExtrapolationMethod   : Extrapolation method
        - 'linear'
        - 'nearest'
        * 'none'
```

### Output

```
Dst     : Output Image
```

## linolar.m
wrapper function to excute linear polar transformation.  
Just call warpPolar with `'LinearPolarMapping', true`.

```matlab
function Dst = linpolar(Src, varargin)
Dst = warpPolar(Src, varargin{:}, 'LinearPolarMapping', true);
```

## logolar.m
wrapper function to excute semilog polar transformation.  
Just call warpPolar with `'LinearPolarMapping', false`.

```matlab
function Dst = logpolar(Src, varargin)
Dst = warpPolar(Src, varargin{:}, 'LinearPolarMapping', false);
```
