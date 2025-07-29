function imageData = getrawImage(mainhandles,file)
% Returns the image to be plotted in the raw image ax in the main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     file          - movie file
%
%    Output:
%     imageData     - imageData
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

imageData = [];
if isempty(mainhandles.data)
    return
end

% Selected image
if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
frame = get(mainhandles.FramesListbox,'Value')-2;

%% Get image

if frame == -1
    
    % Average image is selected from frames listbox
    imageData = mainhandles.data(file).avgimage;
    
elseif frame == 0
    
    if isempty(mainhandles.data(file).back)
        
        % Dialog and return
        myquestdlg(sprintf('There is no background image stored for this file.'),'iSMS',...
            'OK','OK');
        set(mainhandles.FramesListbox,'Value',1)
        mainhandles = updaterawimage(mainhandles);
        return
        
    else
        imageData = double(mainhandles.data(file).back);
    end
    
else % If a frame is selected from the frames listbox
    imageData = mainhandles.data(file).imageData(:,:,frame);
end
