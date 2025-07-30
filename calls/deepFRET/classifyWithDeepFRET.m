function mainhandles = classifyWithDeepFRET(mainhandle, selectedPairs)
%CLASSIFYWITHDEEPFRET Classify traces using DeepFRET neural networks
%
% mainhandles = CLASSIFYWITHDEEPFRET(mainhandle, selectedPairs) loads the
% pre-trained DeepFRET models and classifies the selected FRET pairs.
% The resulting class label and confidence are stored in each
% FRETpair under the fields 'DeepFRET_class', 'DeepFRET_confidence', and
% 'DeepFRET_probs'.
%
% Input arguments:
%   mainhandle    - handle to the main iSMS window
%   selectedPairs - [file pair] array. If empty all selected pairs are used
%
% The DeepFRET model files 'FRET_2C_keras_model.h5' and
% 'FRET_3C_keras_model.h5' must be located in the folder
%    calls/deepFRET/model/
% Copy them from the DeepFRET distribution before running.

mainhandles = [];
if nargin < 1 || isempty(mainhandle) || ~ishandle(mainhandle)
    return
end
mainhandles = guidata(mainhandle);
if isempty(mainhandles) || isempty(mainhandles.data)
    return
end

if nargin < 2 || isempty(selectedPairs)
    selectedPairs = getPairs(mainhandle, 'Selected', [], mainhandles.FRETpairwindowHandle);
end
if isempty(selectedPairs)
    return
end

%% Load models (persist between calls)
persistent net2C net3C
if isempty(net2C) || isempty(net3C)
    thisdir = fileparts(mfilename('fullpath'));
    modeldir = fullfile(thisdir,'model');
    model2CPath = fullfile(modeldir, 'FRET_2C_keras_model.h5');
    model3CPath = fullfile(modeldir, 'FRET_3C_keras_model.h5');
    if exist(model2CPath, 'file')
        net2C = importKerasNetwork(model2CPath, 'OutputLayerType','classification');
    else
        errordlg(sprintf('DeepFRET model not found:\n%s', model2CPath), 'DeepFRET');
        return
    end
    if exist(model3CPath, 'file')
        net3C = importKerasNetwork(model3CPath, 'OutputLayerType','classification');
    else
        errordlg(sprintf('DeepFRET model not found:\n%s', model3CPath), 'DeepFRET');
        return
    end
end

progressbar('DeepFRET')

failedPairs = [];
for k = 1:size(selectedPairs,1)
    file = selectedPairs(k,1);
    pair = selectedPairs(k,2);

    intensities = cell(1,6);
    intensities{1} = mainhandles.data(file).FRETpairs(pair).DDtrace(:);
    intensities{2} = mainhandles.data(file).FRETpairs(pair).DDback(:);
    intensities{3} = mainhandles.data(file).FRETpairs(pair).ADtrace(:);
    intensities{4} = mainhandles.data(file).FRETpairs(pair).ADback(:);

    if isfield(mainhandles.data(file).FRETpairs(pair),'AAtrace') && ...
            ~isempty(mainhandles.data(file).FRETpairs(pair).AAtrace)
        intensities{5} = mainhandles.data(file).FRETpairs(pair).AAtrace(:);
        intensities{6} = mainhandles.data(file).FRETpairs(pair).AAback(:);
    else
        intensities{5} = NaN(size(intensities{1}));
        intensities{6} = NaN(size(intensities{1}));
    end

    [~, Dleakage, Adirect] = getGamma(mainhandles,[file pair]);

    try
        [cls, conf, prob] = classify_trace(intensities, Dleakage, Adirect, net2C, net3C);
        mainhandles.data(file).FRETpairs(pair).DeepFRET_class = cls;
        mainhandles.data(file).FRETpairs(pair).DeepFRET_confidence = conf;
        probs.aggregated = prob(2);
        probs.noisy = prob(3);
        probs.scrambled = prob(4);
        probs.static = prob(5);
        probs.dynamic = sum(prob(6:9));
        probs.confidence = conf;
        mainhandles.data(file).FRETpairs(pair).DeepFRET_probs = probs;
    catch ME
        warning('DeepFRET classification failed for pair (%i,%i): %s',file,pair,ME.message);
        failedPairs(end+1,:) = [file pair]; %#ok<AGROW>
    end

    progressbar(k/size(selectedPairs,1))
end

progressbar(1)
if ~isempty(failedPairs)
    warndlg(sprintf('DeepFRET classification failed for %d traces. See command window for details.', size(failedPairs,1)), 'DeepFRET');
end
updatemainhandles(mainhandles);

end

%% Helper functions
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

function Xn = sample_max_normalize(X)
    % Normalize each trace by its maximum intensity
    if isvector(X)
        X = X(:)';
    end
    arr_max = max(X,[],2);
    Xn = X ./ arr_max;
end

function bleachFrame = find_bleach(p_bleach, threshold, window)
    if nargin < 2, threshold = 0.5; end
    if nargin < 3, window = 7; end
    is_bleached = medfilt1(double(p_bleach > threshold), window);
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

function [traceClass, confidence, probs] = classify_trace(intensities, alpha, delta, net2C, net3C)
    [F_DA, I_DD, ~, I_AA] = correct_DA(intensities, alpha, delta);
    xi = [F_DA; I_DD; I_AA];

    hasRed = ~any(isnan(I_AA));
    if hasRed
        model = net3C;
        xi = xi([2 3 1], :);
        expectedDims = 3;
    else
        model = net2C;
        xi = xi([2 3], :);
        expectedDims = 2;
    end

    % Debug: visualize if the input feature dimension is incorrect
    if size(xi,1) ~= expectedDims
        figure('Name','DeepFRET input dimension mismatch');
        plot(xi');
        xlabel('Frame');
        ylabel('Intensity');
        title(sprintf('DeepFRET input dimension %d, expected %d', size(xi,1), expectedDims));
    end

    xi = sample_max_normalize(xi);
    yi = predict(model, xi);
    [p, confidence, ~] = seq_probabilities(yi);
    [~, idx] = max(p);
    classes = {"bleached","aggregated","noisy","scrambled","1-state", ...
               "2-state","3-state","4-state","5-state"};
    traceClass = classes{idx};
    probs = p;
end
