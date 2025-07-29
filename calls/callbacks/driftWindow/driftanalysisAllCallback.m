function mainhandles = driftanalysisAllCallback(handles)
% Callback for analysing drift in all movies in the drift window
%
%    Input:
%     dwHandles    - handles structure of the drift window
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

mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
if isempty(mainhandles.data)
    set(CompensateCheckbox,'Value',0)
    return
end

% Files to analyse
filechoices = 1:length(mainhandles.data);

% Check if drift has been calculated for some of the files
idx = [];
for i = 1:length(filechoices)
    filechoice = filechoices(i);
    drft = mainhandles.data(filechoice).drifting.drift;
    
    if numel(unique(drft)) ~= 1 % If drift array contains more than one number (0) it means a drift vector is already stored
        idx = [idx; filechoice];
    end
end

if ~isempty(idx)
    message = sprintf('There are already drift-corrected movies stored for the following files:\n');
    for i = 1:length(idx)
        message = sprintf('%s\n - %s',message,mainhandles.data(idx(i)).name);
    end
    message = sprintf('%s\n\nDo you wish to (re)analyse drift in all files?',message);
    choice = myquestdlg(message,'iSMS',...
        'Yes, all','No, only files not already analysed','Cancel','No, only files not already analysed');
    
    % Choice is don't reanalyse the ones already analysed
    if isempty(choice) || strcmpi(choice,'Cancel')
        return
    elseif strcmpi(choice,'No, only files not already analysed')
        filechoices(ismember(filechoices,idx)) = [];
    end
end
if isempty(filechoices)
    return
end

% Turn on waitbar
if length(filechoices)>1
    hWaitbar = mywaitbar(0,'Analysing drifts. Please wait...','name','iSMS');
    try setFigOnTop([]), end % Sets the waitbar so that it is always in front
else
    hWaitbar = [];
end

%% Run drift analysis

for i = 1:length(filechoices)
    filechoice = filechoices(i);
    mainhandles = analyseDrift(handles.main,filechoice);
    
    % Update waitbar
    if ~isempty(hWaitbar)
        waitbar(i/length(filechoices))
    end
end

%% Update plots and close waitbar

mainhandles = updateDriftWindowPlots(handles.main,handles.figure1,'all');

% Delete waitbar
if ~isempty(hWaitbar)
    try delete(hWaitbar), end
end
