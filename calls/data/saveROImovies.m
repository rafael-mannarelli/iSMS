function [mainhandles,MBerror] = saveROImovies(mainhandles,choice)
% Saves the four ROI movies of DROItrace and AROItrace to the handles
% structure. Also returns MBerror (0/1) denoting whether function was
% stopped due to lack of memory.
% 
%    Input:
%     mainhandles  - handles of the main figure window (sms)
%     choice       - 'selected', 'all' of filechoices ([file1 file2...])
%
%    Output:
%     mainhandles  - ..
%     MBerror      - 0/1 stopped because of memory error
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

MBerror = 0; % Default

if isempty(mainhandles.data) % If there is no data loaded, return
    return
end
if nargin==1 % If function is called using only one input argument, set choice to 'selected'
    choice = 'selected';
end
if ischar(choice) && strcmpi(choice,'selected')
    files = get(mainhandles.FilesListbox,'Value'); % Selected movie file
elseif ischar(choice) && strcmpi(choice,'all')
    files = 1:length(mainhandles.data);
elseif ~ischar(choice)
    files = choice;
end

%% ROI movies

ok = [];
okraw = 0;
message = sprintf('OBS: The program attempted to calculate the D and A ROI movies but the raw movie has been deleted for the following files:\n');
for i = 1:length(files)
    file = files(i);
    
    % Check if raw movie has been deleted
    if isempty(mainhandles.data(file).imageData)
        if isempty(mainhandles.data(file).DD_ROImovie)
            message = sprintf('%s\n- %s',message,mainhandles.data(file).name);
            okraw = 1;
        end
        continue
    end
    
    % Raw movies
    imageData = mainhandles.data(file).imageData;
    
    % Get ROI
    [mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData);
    
    % D and A data ranges
    Dx = Droi(1):(Droi(1)+Droi(3))-1;
    Dy = Droi(2):(Droi(2)+Droi(4))-1;
    Ax = Aroi(1):(Aroi(1)+Aroi(3))-1;
    Ay = Aroi(2):(Aroi(2)+Aroi(4))-1;
    
    Dframes = find(mainhandles.data(file).excorder=='D'); % Indices of all F frames
    Aframes = find(mainhandles.data(file).excorder=='A'); % Indices of all A frames
    
    % Cut D and A ROIs from avgimage
    mainhandles.data(file).DD_ROImovie = imageData(Dx,Dy,Dframes);
    mainhandles.data(file).AD_ROImovie = imageData(Ax,Ay,Dframes);
    
    % Direct acceptor excitation
    if ~isempty(Aframes)
        mainhandles.data(file).AA_ROImovie = imageData(Ax,Ay,Aframes);
    else
        mainhandles.data(file).AA_ROImovie = [];
    end    
end

%% Finalize

% Display message about delete drift-compensated movies
if ~isempty(ok)
    message = 'Note that the drift-compensated movies was deleted for the following files:\n';
    for i = 1:length(ok)
        message = sprintf('%s\n- %s',message,mainhandles.data(ok(i)).name);
    end
    mymsgbox(message,'Movies deleted')
end

% Display message about deleted raw movies:
if okraw
    message = sprintf('%s\n\nIf you need to calculate new traces you will have to reload the raw movie file from the Memory menu.',message);
    set(mainhandles.mboard,'String',message)
end

% % Check memory:
% if ~ismac
% Slow
% [userview systemview] = memory;
% MB = userview.MemAvailableAllArrays*9.53674316*10^-7;
% if MB<1000
%     set(mainhandles.mboard,'String',sprintf(...
%         '%s\n%s %.0f %s\n%s',...
%         'Warning: More RAM needed!',...
%         'There is currently only',MB,'MB of memory available for iSMS.',...
%         'You may experience slowness and other memory-related problems if not deleting some raw data.'))
% end
% end

updatemainhandles(mainhandles)

