function Ixy = myFastPeakFind(mainhandles,img,threshold,useBack,maxPeaks,subPixel)
% Find all peaks and sort them in order of brightness
%
%    Input:
%     mainhandles   - handles structure of the main window
%     img           - image data
%     threshold     - threshold for peakfinder
%     useBack       - 0/1 use back subtraction
%     maxPeaks      - max no. of peaks
%     subPixel      - 0/1 use subpixel resolution
%

% --- Copyrights (C) ---
%
% This file is part of:
% iSMS - Single-molecule FRET microscopy software
% Copyright (C) Aarhus University, @ V. Birkedal Lab
% <http://isms.au.dk>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

%% Initialize

Ixy = [];

if nargin<3 || ischar(threshold)
    threshold = mainhandles.settings.peakfinder.(threshold);
    temp = sort(img(:)); % Image pixels sorted according to brightness
    threshold = mean(temp(1:round(end*threshold))); % Threshold for peakfinder is the mean of the 95% least-bright pixels
end
if nargin<4 || isempty(useBack)
    useBack = 1;%mainhandles.settings.peakfinder.useBack;
end
if nargin<5 || isempty(maxPeaks)
    maxPeaks = inf;% mainhandles.settings.peakfinder.maxpeaks
end
if nargin<6 || isempty(subPixel)
    subPixel = 0;%mainhandles.settings.peakfinder.subpixel;
end

%% FastPeakFind is a local maximum method

peaksRaw = FastPeakFind(img,threshold); % Peaks in [x; y; x; y]
if isempty(peaksRaw)
    return
end

% Peak coordinates
peaksRaw = [peaksRaw(1:2:end-1) peaksRaw(2:2:end)]; % Peaks in [x y; x y]
idx = sub2ind(size(img), peaksRaw(:,1), peaksRaw(:,2)); % Convert to linear indexing in order to evaluate Dint

%% Brightness of peak pixels

I = img(idx);

%% Subtract background

if useBack
    for i = 1:size(peaksRaw,1)
        
        % Get background mask
        [~, backMask] = getMask(...
            size(img), peaksRaw(i,1), peaksRaw(i,2), mainhandles.settings.integration.wh(1), mainhandles.settings.integration.wh(2),...
            'backMask', mainhandles.settings.background.backwidth, mainhandles.settings.background.backspace); % Get background mask
        
        % Convert to linear indexes
        idxBack = find(backMask);
        
        % Take mean
        back = sum(img(idxBack))/length(idxBack);%mean(img(idxBack));
        
        % Subtract background
        I(i) = I(i)-back;
    end
end

%% Sort according to intensity

Ixy = flipud( sortrows([I peaksRaw]) ); % Sort in ascending order and flip to descending order

%% Max # peaks

if size(Ixy,1) > maxPeaks
    Ixy = Ixy(1:maxPeaks,:);
end

%% Sub-pixel localization (centroids)

if subPixel
    Ixy(:,2:3) = findcentroids(img, Ixy(:,2:3), round(max(mainhandles.settings.integration.wh)/2) );
end
