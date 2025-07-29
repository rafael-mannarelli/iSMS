function [params, weights, normChi] = my_fit_mix_gaussian(data, n, initialguess)

% function [params count E imgFit] = GME(img, initialguess, lb, ub, threshold)
% Gaussian Mask Estimator (GME) of 2D Gaussian with a constant background:
% Performs a least squares fit with constant weights.
%
%    Input arguments:
%    data          - [x y;...] curve data
%    initialguess  - Initial guess of the parameters to be fit:
%                    [x0, y0, sx, sy, theta, background, amplitude]
%                    note: as the fit minimizes only localy it is important
%                    for this inital guess to be fairly close to the true
%                    value.
%    lb            - Lower parameter bounds
%    ub            - Upper parameter bounds
%    threshold     - 0-1 determining optimization settings (0 is for speed,
%                    1 is for accuracy)
%
%    Output arguments:
%    params  - Fitted parameters
%    count   - Integrated Gaussian intensity
%    E    - [x y] E used for imgFit
%    imgFit  - Fitted image

if nargin<2
    n = 1;
end
if nargin<3
    initialguess = [];
end

params = [];
weights = [];
normChi = [];

if isempty(data)
    return
end

E = data(:,1);
y = data(:,2);

% Default initial guess and bounds
if isempty(initialguess) || size(initialguess,1)~=n
    initialguess = zeros(n,3);
    
    xtemp = linspace(min(E),max(E),n+2);
    initialguess(:,1) = xtemp(2:end-1);
    initialguess(:,2) = 0.1;
    initialguess(:,3) = 1/n;

    lb = zeros(n,3);
    lb(:,1) = -0.1;
    lb(:,2) = 1e-25;
    lb(:,3) = 0;
    
    ub = zeros(n,3);
    ub(:,1) = 1.1;
    ub(:,2) = 2;
    ub(:,3) = max(y(:))*1.5;
end

params = initialguess;

% Optimization settings
options = optimset('lsqcurvefit');
options = optimset(options, 'Jacobian','off', 'Display','off',  'TolX',10^-2, 'TolFun',10^-2, 'MaxPCGIter',1, 'MaxIter',5000);

% Optimize
optFunc =  @(x, E) GaussFcn(x, E); % Function to optimize
[params, res] = lsqcurvefit(... % lsqcurvefit performs the optimization. This requires the Optimization Toolbox
    optFunc, ... % Function to optimize
    initialguess, E, y,... % p0, xdata, ydata
    lb, ub, options); % params: [x0, y0, sx, sy, theta, background, amplitude]

% Chi-square of fit
normChi = res/size(data,1); % Normalized chi square. numel(img) is number of pixels

% Integrated Gaussian (analytical)
weights = 2*pi*params(:,2).^2.*params(:,3); % The total count is 2*pi*sx*sy*Amplitude
% 
% % Fitted image
% imgFit = Gauss2D(E, x0, y0, sx, sy, theta, background, amplitude);
end

%% Functions to fit: Rotated, elliptical 2D Gaussian
function model = GaussFcn(params, E) %% All parameters free.

% Parameters being optimized
mu = params(:,1);
sigma = params(:,2);
a = params(:,3);

% Create Gaussian model corresponding to input parameters
model = a(1)*exp(-(E-mu(1)).^2/(2*sigma(1)^2));
if length(mu)>1
    for i = 2:length(mu)
        model = model+a(i)*exp(-(E-mu(i)).^2/(2*sigma(i)^2));
    end
end
end
