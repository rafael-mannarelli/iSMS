function [mainhandles, DidxInt, AidxInt, DintMask, AintMask] = correctMask(mainhandles, selectedPair)
% Correct D and A masks so that they have same size
%
%    Input:
%     mainhandles   - handles structure of the main window
%     selectedPair  - [file pair]
%
%    Output:
%     mainhandles   - ...
%     DidxInt       - new D idx for I mask
%     AidxInt       - new A idx for I mask
%     DintMask      - new D I mask
%     AintMask      - new A I mask
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

DidxInt = [];
AidxInt = [];
DintMask = [];
AintMask = [];

% Input
if isempty(selectedPair)
    return
end
file = selectedPair(1,1);
pair = selectedPair(1,2);

% Mask
DintMask = mainhandles.data(file).FRETpairs(pair).DintMask;
AintMask = mainhandles.data(file).FRETpairs(pair).AintMask;

% Convert to linear indices
DidxInt = find(DintMask);
AidxInt = find(AintMask);
if length(DidxInt)== length(AidxInt)
    return
end

% Get image
imageData = getimageData(mainhandles,file);
if isempty(imageData)
    return
end

% Get ROIs
[mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData);

%% Check

d = length(DidxInt)-length(AidxInt);
if d>0
    % D larger than A
    
    % Data range
    x = Droi(1):(Droi(1)+Droi(3))-1;
    y = Droi(2):(Droi(2)+Droi(4))-1;
    img = imageData(x , y , 1);
    
    % Intensities
    I = img(DidxInt);
    I2 = sort(I(:));
    
    % Remove low intensity pixels
    idx = find(ismember(I,I2(1:d)));
    idx = idx(1:d);
    [I,J] = ind2sub(size(img),DidxInt(idx));
    for i = 1:length(idx)
        DintMask(I(i),J(i)) = 0;
    end
    mainhandles.data(file).FRETpairs(pair).DintMask = DintMask;
    
    DidxInt(idx) = [];
    
elseif d<0
    % A larger than D
    
    % Cut ROI from image
    x = Aroi(1):(Aroi(1)+Aroi(3))-1;
    y = Aroi(2):(Aroi(2)+Aroi(4))-1;
    if size(imageData,3)==2
        img = imageData(x , y , 2);
    else
        img = imageData(x , y , 1);
    end
    
    % Intensities
    I = img(AidxInt);
    I2 = sort(I(:));
    
    % Remove low intensity pixels
    idx = find(ismember(I,I2(1:d)));
    idx = idx(1:d);
    [I,J] = ind2sub(size(img),AidxInt(idx));
    for i = 1:length(idx)
        AintMask(I(i),J(i)) = 0;
    end
    mainhandles.data(file).FRETpairs(pair).AintMask = AintMask;
    
    AidxInt(idx) = [];
end

%% Update handles
updatemainhandles(mainhandles)
