function peaks = findcentroids(imageData,peaks,halfwidth)
% Calculates centroid of peak spot
%
%    Input:
%     imageData   - input image
%     peaks       - all peak coordinates [x1 y1;...]
%     halfwidth   - half-width of spot image to calculate centroid within
%
%    Output:
%     peaks       - new peak coordinates
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

peaksin = peaks;

if nargin<3
    halfwidth = 3;
end

%% Centroid calculation

%get half the PSF range in pixels

%go over all local maxima
for i = 1 : size(peaks,1)
    
    %get part of image relevant for this local maximum
    x1 = peaks(i,2) - halfwidth;
    x2 = peaks(i,2) + halfwidth;
    y1 = peaks(i,1) - halfwidth;
    y2 = peaks(i,1) + halfwidth;
    
    % Check region does not exceed image
    if x1<1
        x1 = 1;
    end
    if y1<1
        y1 = 1;
    end
    if x2>size(imageData,2)
        x2 = size(imageData,2);
    end
    if y2>size(imageData,1)
        y2 = size(imageData,1);
    end
    
    %calculate centroid in small image
    im = imageData(round(y1:y2),round(x1:x2));
    ce = centroid2D( im );
    
    %shift to coordinates in overall image
    peaks(i,:) = [ce(2) ce(1)] + [y1 x1] - 1;
    
end
end

function xy = centroid2D(img)
% Returns centroid of img

img = double(img);

x = sum( sum(img).*[1:size(img,2)] );
y = sum( sum(img').*[1:size(img,1)] );

xy = [x y] / sum(img(:));
end

