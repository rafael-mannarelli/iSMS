function mainhandles = classifyDeepFRET(mainhandle, model2CPath, model3CPath)
%CLASSIFYDEEPFRET Classify FRET traces using pretrained DeepFRET models
%
%   mainhandles = CLASSIFYDEEPFRET(mainhandle, model2CPath, model3CPath)
%   loads the Keras models specified by model2CPath and model3CPath and
%   classifies all loaded FRET pairs. Results are stored in each
%   FRETpairs structure with fields:
%       .deepFRETclass       - Predicted class label
%       .deepFRETconfidence  - Sum probability of dynamic classes
%       .deepFRETbleachFrame - Bleaching frame estimated by the network
%
%   The function requires the Deep Learning Toolbox.
%
%   By default the function looks for the model files in
%   calls/deepFRET/model/FRET_2C_keras_model.h5 and
%   calls/deepFRET/model/FRET_3C_keras_model.h5.  Custom paths can be
%   provided via the optional input arguments.
%
%   Example:
%       mainhandles = classifyDeepFRET(gcf);               % use default paths
%       mainhandles = classifyDeepFRET(gcf,'my2c.h5','my3c.h5');
%
% The helper functions in this file are based on the MATLAB example
% provided with the DeepFRET project.

%% Determine model paths
baseDir = fileparts(mfilename('fullpath'));
if nargin < 2 || isempty(model2CPath)
    model2CPath = fullfile(baseDir,'model','FRET_2C_keras_model.h5');
end
if nargin < 3 || isempty(model3CPath)
    model3CPath = fullfile(baseDir,'model','FRET_3C_keras_model.h5');
end
if ~exist(model2CPath,'file') || ~exist(model3CPath,'file')
    error('DeepFRET model files not found. Expected in %s',fullfile(baseDir,'model'));
end

if isempty(mainhandle) || ~ishandle(mainhandle)
    mainhandles = [];
    return
end
mainhandles = guidata(mainhandle);
if isempty(mainhandles) || isempty(mainhandles.data)
    return
end

%% Load networks
net2C = importKerasNetwork(model2CPath,'OutputLayerType','classification');
net3C = importKerasNetwork(model3CPath,'OutputLayerType','classification');

%% Classify each pair
pairs = getPairs(mainhandle,'all');
for k = 1:size(pairs,1)
    file = pairs(k,1);
    pair = pairs(k,2);

    % Traces including intensity and background
    tr = getTraces(mainhandle,[file pair],'vbFRET',1);
    if isempty(tr)
        continue
    end

    % Correction factors
    alpha = mainhandles.data(file).FRETpairs(pair).Dleakage;
    delta = mainhandles.data(file).FRETpairs(pair).Adirect;
    if isempty(alpha); alpha = 0; end
    if isempty(delta); delta = 0; end

    intensities = {tr.DD+tr.DDback, tr.DDback, ...
                   tr.AD+tr.ADback, tr.ADback, ...
                   tr.AA+tr.AAback, tr.AAback};
    [cls, conf, bFrame] = classify_single(intensities, alpha, delta, net2C, net3C);

    mainhandles.data(file).FRETpairs(pair).deepFRETclass = cls;
    mainhandles.data(file).FRETpairs(pair).deepFRETconfidence = conf;
    mainhandles.data(file).FRETpairs(pair).deepFRETbleachFrame = bFrame;
end

updatemainhandles(mainhandles);
end

%% Helper functions
function [traceClass, confidence, bleachFrame] = classify_single(intensities, alpha, delta, net2C, net3C)
    [F_DA, I_DD, ~, I_AA] = correct_DA(intensities, alpha, delta);
    xi = [F_DA; I_DD; I_AA]';

    hasRed = ~any(isnan(I_AA));
    if hasRed
        model = net3C;
        xi = xi(:,[2 3 1]);
    else
        model = net2C;
        xi = xi(:,[2 3]);
    end

    xi = sample_max_normalize_3d(xi);
    yi = predict(model, xi);
    [p, confidence, bleachFrame] = seq_probabilities(yi);
    [~, idx] = max(p);
    classes = {"bleached","aggregated","noisy","scrambled","1-state", ...
               "2-state","3-state","4-state","5-state"};
    traceClass = classes{idx};
end

function [F_DA, I_DD, I_DA, I_AA] = correct_DA(intensities, alpha, delta)
    grn_int = intensities{1};
    grn_bg  = intensities{2};
    acc_int = intensities{3};
    acc_bg  = intensities{4};
    red_int = intensities{5};
    red_bg  = intensities{6};

    I_DD = grn_int - grn_bg;
    I_DA = acc_int - acc_bg;
    I_AA = red_int - red_bg;

    if any(isnan(I_AA))
        F_DA = I_DA - alpha .* I_DD;
    else
        F_DA = I_DA - alpha .* I_DD - delta .* I_AA;
    end
end

function Xn = sample_max_normalize_3d(X)
    if ndims(X) == 2
        X = reshape(X,1,size(X,1),size(X,2));
    end
    arr_max = max(X,[],[2 3]);
    Xn = X ./ arr_max;
end

function bleachFrame = find_bleach(p_bleach, threshold, window)
    if nargin < 2, threshold = 0.5; end
    if nargin < 3, window = 7; end
    is_bleached = medfilt(double(p_bleach > threshold), window);
    bleachFrame = find(is_bleached,1,'first');
    if isempty(bleachFrame)
        bleachFrame = [];
    elseif all(is_bleached)
        bleachFrame = 1;
    end
end

function [p, confidence, bleachFrame] = seq_probabilities(yi, skip_threshold, min_frames)
    if nargin < 2, skip_threshold = 0.5; end
    if nargin < 3, min_frames = 5; end
    bleachFrame = find_bleach(yi(:,1), skip_threshold);

    valid = yi(yi(:,1) < skip_threshold, :);
    if isempty(bleachFrame) || bleachFrame > min_frames
        p = sum(valid,1) ./ size(valid,1);
        p = p ./ sum(p);
    else
        p = zeros(1,size(yi,2));
        p(1) = 1;
    end
    confidence = sum(p(5:end));
end

