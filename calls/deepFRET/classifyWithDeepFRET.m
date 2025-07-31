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

    % Retrieve FRET pair data for bleaching detection
    FRETpair = mainhandles.data(file).FRETpairs(pair);
    [dbleach, ableach] = detect_bleach_times(FRETpair, mainhandles.settings.bleachfinder, mainhandles.settings.excitation.alex);
    if isempty(FRETpair.DbleachingTime)
        FRETpair.DbleachingTime = dbleach;
    end
    if isempty(FRETpair.AbleachingTime)
        FRETpair.AbleachingTime = ableach;
    end

    try
        [cls, conf, prob] = classify_trace(intensities, Dleakage, Adirect, net2C, net3C, FRETpair);
        mainhandles.data(file).FRETpairs(pair).DeepFRET_class = cls;
        mainhandles.data(file).FRETpairs(pair).DeepFRET_confidence = conf;
        probs.aggregated = prob(1);
        probs.noisy = prob(2);
        probs.scrambled = prob(3);
        probs.static = prob(4);
        probs.dynamic = prob(5);
        probs.confidence = conf;
        mainhandles.data(file).FRETpairs(pair).DeepFRET_probs = probs;
    catch ME
        [F_DA, I_DD, ~, I_AA] = correct_DA(intensities, Dleakage, Adirect);
        if ~any(isnan(I_AA))
            xi = [I_DD, I_AA, F_DA]';
        else
            xi = [I_DD, F_DA]';
        end
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
    arr_max = max(X(:));
    if arr_max == 0
        Xn = X;
    else
        Xn = X ./ arr_max;
    end
end

function bleachFrame = find_bleach(p_bleach, threshold, window)
    if nargin < 2, threshold = 0.5; end
    if nargin < 3, window = 7; end

    p_bleach = p_bleach(:);
    is_bleached = medfilt1(double(p_bleach > threshold), window);
    bleachFrame = find(is_bleached, 1, 'first');

    if isempty(bleachFrame)
        bleachFrame = [];
    elseif all(is_bleached)
        bleachFrame = 1;
    end
end

function [p, confidence, bleachFrame] = seq_probabilities(yi, skip_threshold, min_frames, FRETpair)
    if nargin < 2, skip_threshold = 0.5; end
    if nargin < 3, min_frames = 1; end

    T = size(yi, 2);  % number of frames
    bleachMask = true(1, T);  % initialize all frames as non-bleached

    if nargin >= 4 && ~isempty(FRETpair)
        Didx = FRETpair.DbleachingTime;
        Aidx = FRETpair.AbleachingTime;

        if ~isempty(Didx) && ~isnan(Didx) && Didx <= T
            bleachMask(Didx:end) = false;
        end
        if ~isempty(Aidx) && ~isnan(Aidx) && Aidx <= T
            bleachMask(Aidx:end) = false;
        end

        validBleachTimes = [Didx, Aidx];
        validBleachTimes = validBleachTimes(~isnan(validBleachTimes) & validBleachTimes <= T);
        if isempty(validBleachTimes)
            bleachFrame = [];
        else
            bleachFrame = min(validBleachTimes);
        end
    else
        bleachFrame = find_bleach(yi(1,:), skip_threshold);
        bleachMask = yi(1,:) < skip_threshold;
    end

    if isempty(bleachFrame) || bleachFrame > min_frames
        p_ordered = [yi(2,:); yi(4,:); yi(3,:); yi(5,:); yi(6,:)];
        valid_probs = p_ordered(:, bleachMask);
        p = mean(valid_probs, 2)';
        conf_values = yi(5,:) + yi(6,:);
        conf_values(~bleachMask) = NaN;
        confidence = mean(conf_values, 'omitnan');
    else
        p = [0 0 0 0 0];
        confidence = 0;
    end
end


function [traceClass, confidence, probs] = classify_trace(intensities, alpha, delta, net2C, net3C, FRETpair)
    [F_DA, I_DD, ~, I_AA] = correct_DA(intensities, alpha, delta);
    hasRed = ~any(isnan(I_AA));
    if hasRed
        model = net3C;
        xi = [I_DD, I_AA, F_DA]';
        expectedDims = 3;
    else
        model = net2C;
        xi = [I_DD, F_DA]';
        expectedDims = 2;
    end

    if size(xi,1) ~= expectedDims
        fprintf('DeepFRET expected %d features but got %d. Trace matrix:\n', expectedDims, size(xi,1));
        figure('Name','DeepFRET input dimension mismatch');
        plot(xi');
        xlabel('Frame');
        ylabel('Intensity');
        title(sprintf('DeepFRET input dimension %d, expected %d', size(xi,1), expectedDims));
    end

    xi = sample_max_normalize(xi);
    yi = predict(model, xi);
    if nargin < 6
        [p, confidence, ~] = seq_probabilities(yi);
    else
        [p, confidence, ~] = seq_probabilities(yi, 0.5, 1, FRETpair);
    end
    [~, idx] = max(p);

    classes = {"bleached","aggregated","noisy","scrambled","static","dynamic"};

    if idx > numel(classes)
        warning('DeepFRET returned invalid class index %d. p = %s', idx, mat2str(p));
        traceClass = 'unknown';
    else
        traceClass = classes{idx};
    end

    probs = p;
end

function [Didx, Aidx] = detect_bleach_times(FRETpair, settings, alex)
    allow = settings.allow;
    Didx = [];
    Aidx = [];

    DD = FRETpair.DDtrace - FRETpair.DDback;
    AD = FRETpair.ADtrace - FRETpair.ADback;
    sumDA = medianSmoothFilter(DD + AD, 7);

    if settings.findD
        Didx = detect_trace_bleach(sumDA, settings.Dthreshold, allow);
    end

    if settings.findA
        if alex && isfield(FRETpair,'AAtrace') && ~isempty(FRETpair.AAtrace)
            AA = medianSmoothFilter(FRETpair.AAtrace - FRETpair.AAback, 7);
            Aidx = detect_trace_bleach(AA, settings.Athreshold, allow);
        else
            ADcorr = medianSmoothFilter(AD, 7);
            Aidx = detect_trace_bleach(ADcorr, settings.Dthreshold, allow);
        end
    end
end

function idx = detect_trace_bleach(I, threshold, allow)
    idx = [];
    L = length(I);
    if L <= allow+1
        return
    end

    if any(I(end-allow:end) < threshold)
        run = 0;
        for j = L:-1:1
            if I(j) < threshold
                idx = j;
                run = 0;
            else
                run = run + 1;
                if run > allow
                    break
                end
            end
        end

        if ~isempty(idx) && (idx >= L-allow || idx < 2)
            idx = [];
        end
    end
end
