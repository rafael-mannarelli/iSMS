function mainhandles = driftSettings(mainhandle)
% Opens a dialog for specifying drift settings and saves the settings to
% the main handles structure, possibly followed by a drift analysis
%
%    Input:
%     mainhandle   - handle to the main figure window
%
%    Output:
%     mainhandles  - handles structure of the main window
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

mainhandles = guidata(mainhandle);

filechoice = get(mainhandles.FilesListbox,'Value');

%% Prepare dialog box

prompt = {'Drift resolution (drift determined in pixels to within 1/resolution): ' 'upscale';...
    'Use image averaging between neighbouring frames when analyzing drift' 'avgchoice';...
    'Number of neighbouring frames averaged: ' 'avgneighbours';...
    'Apply these settings to: ' 'applyToAll'};
name = 'Drift analysis settings';
%     'When using drift compensation, use the drift calculated for: ' 'driftmovie';...

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Interpolation choices
formats(2,1).type = 'edit';
formats(2,1).size = 50;
formats(2,1).format = 'integer';
% formats(4,1).type = 'list';
% formats(4,1).style = 'popupmenu';
% formats(4,1).items = {'Acceptors'};%,'Donors'};
formats(4,1).type = 'check';
formats(5,1).type = 'edit';
formats(5,1).size = 50;
formats(5,1).format = 'integer';
formats(7,1).type = 'list';
formats(7,1).style = 'popupmenu';
formats(7,1).items = {'Selected file','All files'};

% Default choices
if isempty(mainhandles.data) % If there is no data loaded, show defaults
    DefAns.upscale = mainhandles.settings.drifting.upscale;
%     DefAns.driftmovie = mainhandles.settings.drifting.driftmovie;
    DefAns.avgchoice = mainhandles.settings.drifting.avgchoice;
    DefAns.avgneighbours = mainhandles.settings.drifting.avgneighbours;
else
    DefAns.upscale = mainhandles.data(filechoice).drifting.upscale;
%     DefAns.driftmovie = mainhandles.data(filechoice).drifting.driftmovie;
    DefAns.avgchoice = mainhandles.data(filechoice).drifting.avgchoice;
    DefAns.avgneighbours = mainhandles.data(filechoice).drifting.avgneighbours;
end
DefAns.applyToAll = 1; % 1: selected file only. 2: all files

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)% || (isequal(DefAns,answer))
    return
end

%% Selection

% Filechoices
if answer.applyToAll==2 % If settings are to be applied on all files
    filechoices = 1:length(mainhandles.data);
else % If settings are to be applied on selected file only
    filechoices = filechoice;
end

% Get callback to the Files Listbox of the main window
% FilesListbox_Callback = mainhandles.functionHandles.FilesListbox_Callback; % Handle to the Files Listbox Callback function of the main figure window (sms)

%% Save new settings

if isempty(mainhandles.data) % If there is no data loaded, show defaults
    mainhandles.settings.drifting.upscale = answer.upscale;
%     mainhandles.settings.drifting.driftmovie = answer.driftmovie;
    mainhandles.settings.drifting.avgchoice = answer.avgchoice;
    mainhandles.settings.drifting.avgneighbours = answer.avgneighbours;
    
else % If there is data loaded
    for i = filechoices(:)'
        mainhandles.data(i).drifting.upscale = answer.upscale;
%         mainhandles.data(i).drifting.driftmovie = answer.driftmovie;
        mainhandles.data(i).drifting.avgchoice = answer.avgchoice;
        mainhandles.data(i).drifting.avgneighbours = answer.avgneighbours;
    end
end

% Update handles
updatemainhandles(mainhandles)
