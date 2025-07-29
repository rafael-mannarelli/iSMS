function mainhandles = deletefileCallback(mainhandles, dlgchoice)
% Callback for deleting a file in the main window
%
%      Input:
%       mainhandles   - handles structure of the main window
%       dlgchoice     - 0/1 on prompt file dialog
%
%      Output:
%       mainhandles   - ..
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

% Turn off all interactive toggle buttons in the toolbar
mainhandles = turnofftoggles(mainhandles,'all');
if isempty(mainhandles.data)
    set(mainhandles.FilesListbox,'String','No data loaded')
    return
end

% Default
if nargin<2
    dlgchoice = 0;
end

% Default
filechoices = get(mainhandles.FilesListbox,'Value');

if dlgchoice && length(mainhandles.data)>1
    
    % Open file selection dialog
    [filechoices,OK] = mylistdlg(...
        'ListString', {mainhandles.data(:).name}',...
        'SelectionMode', 'Multiple',...
        'ListSize', [300 400], ...
        'InitialValue', filechoices,...
        'Name', 'Delete data',...
        'PromptString', 'Select files: ',...
        'OKString', ' Delete ');
    
    if ~OK || isempty(filechoices)
        return
    end
end

% Check if there are any stored pairs in the selected files
for i = 1:length(filechoices)
    file = filechoices(i);
    
    % Check for any analysed data
    if (~isempty(mainhandles.data(file).Dpeaks)) && (~isempty(mainhandles.data(file).Apeaks))
        
        % Display warning message
        a = '.';
        if length(filechoices)>1
            a = 's.';
        end        
        choice = myquestdlg(sprintf('This will delete all data and traces associated with the file%s',a), ...
            'Are you sure?', ...
            'Yes','Cancel','Yes');
        
        if isempty(choice) || strcmp(choice,'Cancel')
            return
        else
            break
        end
    end
end

%% Delete

size1 = whos('mainhandles'); % For calculating unleashed memory

mainhandles.data(filechoices) = [];

%% Update

filechoice = get(mainhandles.FilesListbox,'Value');

% Set new data selection
if isempty(mainhandles.data)
    set(mainhandles.FilesListbox,'Value',1)
elseif filechoice > length(mainhandles.data)
    set(mainhandles.FilesListbox,'Value',length(mainhandles.data))
else
    set(mainhandles.FilesListbox,'Value',filechoice)
end

% Update GUI
updatemainhandles(mainhandles)
updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)
updateframeslist(mainhandles)
set(mainhandles.FramesListbox,'Value',1);

% Update the FRETpairwindow
updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
updateFRETpairbinCounter(mainhandles.figure1, mainhandles.FRETpairwindowHandle)
updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)

mainhandles = filesListboxCallback(mainhandles.FilesListbox, [], mainhandles.figure1); % Imitate click in listbox

% Update memory statusbar
mainhandles = updateMemorybar(mainhandles);

% Show energy freed
size2 = whos('mainhandles');
saved = (size1.bytes-size2.bytes)*9.53674316*10^-7; % Memory difference before and after deletion /MB
set(mainhandles.mboard,'String',sprintf('%.1f MB of memory was released.',saved))
