function [img, idxInt] = getPSFimages(mainhandles, selectedPair, frames, id)
% Returns the images used for fitting molecule point spread function (psf)
%
%   Input:
%    mainhandles  - handles structure of the main window (sms)
%    selectedPair - [filechoice pairchoice]
%    frames       - frames used to calculate the image
%    id           - 'DD' 'AD' 'AA'
%
%   Output:
%    img          - Molecule image
%    idxInt       - linear indices of the image area within the movie
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

img = [];
idxInt = [];

if size(selectedPair,1)>1
    error('You can only call getPSFimage with a single pair.')
elseif isempty(selectedPair)
    return
end

% File and pair
file = selectedPair(1);
pair = selectedPair(2);

% Position and width
xy = mainhandles.data(file).FRETpairs(pair).([id(1) 'xy']);
wh = mainhandles.data(file).FRETpairs(pair).([id(1) 'wh']);
backspace = mainhandles.data(file).FRETpairs(pair).backspace; % Space from integration region to background ring
backwidth = mainhandles.data(file).FRETpairs(pair).backwidth; % Width of background ring

% x and y-ranges
xx = round(xy(1)-wh(1)/2-backspace-backwidth) : round(xy(1)+wh(1)/2+backspace+backwidth); % Donor x range
yy = round(xy(2)-wh(2)/2-backspace-backwidth) : round(xy(2)+wh(2)/2+backspace+backwidth); % Donor y range

% ROI movies
ROImovie = mainhandles.data(file).([id '_ROImovie']);

% Check ROI movie is not empty
if isempty(ROImovie)
    mymsgbox('Reload the raw data of the selected FRET pairs in order to proceed with the request.')
    return
end

% Check that frames does not exceed movie
frames(frames>size(ROImovie,3)) = [];
if isempty(frames)
    return
end

%% PSF images as doubles

img = double( mean(ROImovie(xx,yy,frames),3) );

%% Linear indices of image region

[x y] = meshgrid(xx, yy);
idxInt = sub2ind(size(ROImovie(:,:,1)),x,y);
