function [mov, frameRate, mainhandles] = loadMovie(filepath,mainhandles)
% Imports the movie data located at filepath
%
%    Input:
%     filepath    - fullfile path
%     mainhandles - handles structure of the main window
%
%    Output:
%     mov         - movie image data
%     frameRate   - frame rate
%     mainhandles - handles structure of the main window
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
    mainhandles = guidata(getappdata(0,'mainhandle'));
end

% Initialize
mov = [];
frameRate = [];

% Create mov reader object
movObj = VideoReader(filepath);

% Load frames
nFrames = movObj.NumberOfFrames;
frameRate = movObj.FrameRate;
vidHeight = movObj.Height;
vidWidth = movObj.Width;

% Ask for number of frames
if nFrames>10
    
    % Input dialog
    if mainhandles.settings.import.askforframes
        [frame1, frame2] = framedlg(1);
        if isempty(frame1)
            return
        end
        
    else
        % Import all movie
        frame1 = 1;
        frame2 = movObj.NumberOfFrames;
    end
    
end

% Preallocate movie structure.
frames = frame1:frame2;
try
    % Try importing
    mov = zeros(vidHeight, vidWidth, 3, length(frames), 'uint8');
    
catch err
    % If not enough memory for all movie
    if strcmpi(err.identifier,'MATLAB:nomem')
        
        mov = [];
        while isempty(mov)
            
            % Dialog
            [frame1, frame2] = framedlg(0);
            if isempty(frame1)
                return
            end
            
            frames = frame1:frame2;
            try
                mov = zeros(vidHeight, vidWidth, 3, length(frames), 'uint8');
            end
        end
    end
end

%% Read one frame at a time.

for i = 1:length(frames)
    mov(:,:,:,i) = read(movObj, frames(i));
end

%% Nested

    function [frame1, frame2] = framedlg(askchoice)
        
        % Import all movie
        frame1 = 1;
        frame2 = movObj.NumberOfFrames;
        
        [path,file] = fileparts(filepath);
        file = strrep(file, '_', '\_'); % Replace all '_' with '\_' so it's not interpreted as subscript
        prompt = {sprintf('File: %s',file) '';...
            'Frame: ' 'frame1';...
            ' to ' 'frame2';...
            sprintf(' /%i',movObj.NumberOfFrames) ''};
        
        name = 'Import movie';
        formats = struct('type', {}, 'style', {}, 'items', {}, ...
            'format', {}, 'limits', {}, 'size', {});
        
        % Edit box
        
        % Default
        DefAns.frame1 = 1;
        DefAns.frame2 = movObj.NumberOfFrames;
        
        options.ButtonNames = {' Import ' ' Cancel '};
        
        % Don't ask again checkbox
        if askchoice
            formats(3,1).type   = 'text';
            formats(5,1).type   = 'edit';
            formats(5,1).size   = 50;
            formats(5,1).format = 'integer';
            formats(5,2).type   = 'edit';
            formats(5,2).size   = 50;
            formats(5,2).format = 'integer';
            formats(5,3).type   = 'text';
            prompt(end+1,:) = {'Don''t ask again' 'dontaskforframes'};
            formats(7,1).type   = 'check';
            DefAns.dontaskforframes = 0;
            
        else
            formats(2,2).type   = 'text';
            formats(4,2).type   = 'edit';
            formats(4,2).size   = 50;
            formats(4,2).format = 'integer';
            formats(4,3).type   = 'edit';
            formats(4,3).size   = 50;
            formats(4,3).format = 'integer';
            formats(4,4).type   = 'text';
            formats(2,1).type = 'text';
            prompt = cat(1,{'Not enough memory for movie import. Specify a subset of frames to import: ' ''}, prompt); % A different way to achieve the same as above
        end
        
        %--------------- Open dialog box --------------%
        [answer, cancelled] = myinputsdlg(prompt, name, formats, DefAns, options);
        if cancelled == 1
            frame1 = [];
            return
        end
        
        frame1 = answer.frame1;
        frame2 = answer.frame2;
        
        % Update settings structure
        if askchoice && answer.dontaskforframes
            mainhandles.settings.import.askforframes = 0;
            updatemainhandles(mainhandles)
            
            % Save default settings file
            try
                saveSettings(mainhandles, mainhandles.settings); % Saves settings structure to .mat file
            end
        end
        
        % Check if specified number of frames exceeds movie
        if frame1<1
            frame1 = 1;
        elseif frame1>movObj.NumberOfFrames
            frame1 = movObj.NumberOfFrames;
        end
        if frame2<1
            frame2 = 1;
        elseif frame2>movObj.NumberOfFrames
            frame2 = movObj.NumberOfFrames;
        end
        if frame2<frame1
            temp = frame1;
            frame1 = frame2;
            frame2 = temp;
        end
        
    end
end