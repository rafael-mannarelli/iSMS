function updatemainframesliderTextbox(mainhandles,choice)
% Updates the text displayed in the frame slider info textbox above the ROI
% image in the main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     choice        - 1: ROI. Else: Raw
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

if nargin<2
    choice = 1;
end

% Check that data is loaded
if isempty(mainhandles.data)
    set(mainhandles.rawframesliderTextbox,'String','')
    set(mainhandles.ROIframesliderTextbox,'String','')
    return
end

% Choice of whether to update raw or ROI box
if choice==1
    avgFramesField = 'avgimageFrames';
    textboxField = 'ROIframesliderTextbox';
    
else
    avgFramesField = 'avgimageFramesRaw';
    textboxField = 'rawframesliderTextbox';
end

% Selection
file = get(mainhandles.FilesListbox,'Value'); % Selected file
frame = get(mainhandles.FramesListbox,'Value'); % Selected image
n = mainhandles.data(file).rawmovieLength; % Total number of frames

%% Info string

if frame==1
    % Showing avg. image
    frameinfo = '';
    
    % Text
    try 
        frameinfo = sprintf('Avg. %i-%i', mainhandles.data(file).(avgFramesField)(1), mainhandles.data(file).(avgFramesField)(2));
        frameinfo = sprintf('%s / %i',frameinfo,n);
    catch err
        % If raw movie has been deleted
        try frameinfo = sprintf('%s / %i', frameinfo, length(mainhandles.data(file).FRETpairs(1).DDtrace));
        catch err
        end
    end
    
elseif frame == 2
    % Background image
    frameinfo = 'Background';
    
else
    % Single frame
    frameinfo = sprintf('Frame %i / %i',frame-2,n);
end

%% Update

set(mainhandles.(textboxField),'String',frameinfo ,'ForeGroundColor','white', 'HorizontalAlignment','left')
