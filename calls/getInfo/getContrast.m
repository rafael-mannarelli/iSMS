function [contrastLims rawcontrast redROIcontrast greenROIcontrast] = getContrast(mainhandles,file,choice)
% Returns default contrast values and limits of file
%
%    Input:
%     mainhandles   - handles structure of the main window
%     file          - filechoice
%     choice        - 1 raw, 2 green, 3 red
%
%    Output:
%     contrastLims  - Contrast limits
%     rawcontrast   - default contrast value for raw image
%     redROIcontrast   - default contrast for red ROI image
%     greenROIcontrast - default contrast for green ROI image
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

if nargin<3
    choice = 1;
end

% Info on raw data
avgMin = ceil(getmovMin(mainhandles.data(file).avgimage));
avgMax = getmovMax(mainhandles.data(file).avgimage);

if ~isempty(mainhandles.data(file).imageData)
    rawMin = getmovMin(mainhandles.data(file).imageData);
    rawMax = getmovMax(mainhandles.data(file).imageData);
else
    rawMin = avgMin;
    rawMax = avgMax;
end

% Lower and upper contrast limits
contrastLims = [rawMin rawMax];

% ROI images
[redImage, greenImage] = getROIimages(mainhandles,file);

%% Calculate default contrast values

rawcontrast = [avgMin*mainhandles.settings.view.rawcontrast1 avgMax*mainhandles.settings.view.rawcontrast2];
redROIcontrast = calcContrast(redImage(:), mainhandles.settings.view.redcontrast1,mainhandles.settings.view.redcontrast2);
greenROIcontrast = calcContrast(greenImage(:), mainhandles.settings.view.greencontrast1,mainhandles.settings.view.greencontrast2);

%% Nested

    function contrast = calcContrast(img,fac1,fac2)
        % Default low and high contrast
        lo = median(img)*fac1;
%         hi = max(img)*fac2;
        hi = 2*lo-min(img)+(max(img)-2*lo)/2;
        
        % If not fitting this data set, use min and max
        if hi<=lo
            lo = min(img);
            hi = max(img);
        end
        
        % Contrast
        contrast = single([lo hi]);
    end
end

