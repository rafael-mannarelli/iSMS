function mainhandles = createMovieObject(mainhandles,choice)
% Callback for creating movie object
%
%   Input:
%    mainhandles  - handles structure of the main window
%    choice       - 'raw','roi'
%
%   Output:
%    mainhandles  - ..
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

% Default
if nargin<2
    choice = 'raw';
end

% Check for toolbox
if ~license('test','image_toolbox')
    mymsgbox('Sorry, this utility requires the image processing toolbox.')
    return
end
% Check if any data is loaded
if isempty(mainhandles.data)
    set(mainhandles.mboard,'String','No data loaded.')
    return
end

% Waitbar
hWaitbar = mywaitbar(0,'Preparing movie object...', 'name','iSMS');

% Selected movie
file = get(mainhandles.FilesListbox,'Value'); 

if strcmpi(choice,'raw')
    
    % Check if raw movie has been deleted
    [mainhandles, hasRaw] = checkRawData(mainhandles,file);
    if ~hasRaw
        try delete(hWaitbar), end
        return
    end
    
    imageData = mainhandles.data(file).imageData;
    imageData = permute(imageData, [2 1 4 3]);
    for frame = 1:size(imageData,4)
        imageData(:,:,frame) = flipud(imageData(:,:,frame));
    end
end

movsize = [size(imageData,1) size(imageData,2)  size(imageData,3)]; % Size of frames
totallength = size(imageData,4); % Total movie length

%% Prepare movie

% if mainhandles.settings.view.rawlogscale;
%     movframes = zeros(movsize(1),movsize(2),movsize(3), totallength, 'single');
% else
    imgclass = class(imageData);
    movframes = zeros(movsize(1),movsize(2),movsize(3), totallength, imgclass);
% end
for frame = 1:totallength
%     if mainhandles.settings.view.rawlogscale;
%         % Try plotting in log-scale intensity
%         movframes(:,:,:,frame) = real(log10(single(imageData(:,:,:,frame))));
%         
%     else
        movframes(:,:,:,frame) = imageData(:,:,:,frame);        
%     end
end

if ~isa(movframes,'uint8')
    movframes = setimageDatatype(movframes,'uint8');
end

% Colormap
if min(movframes(:))<1
    temp = movframes(:,:,:,1);
    movframes = mat2gray(movframes,double([min(temp(:)) max(temp(:))]));
    [movframes, colmap] = gray2ind(movframes);
else
    colmap = [];
end

%% Make movie object

mov = immovie(movframes, colmap);

% Play movie
implay(mov)
updatelogo(gcf)

% Delete waitbar
try delete(hWaitbar), end

% Update handles structure with new figure handle
mainhandles.figures{end+1} = gcf;
updatemainhandles(mainhandles)

