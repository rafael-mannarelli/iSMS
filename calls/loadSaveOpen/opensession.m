function mainhandles = opensession(mainhandle,file)
% Opens a dialog and loads iSMS session of selected file
%
%    Input:
%     mainhandle    - handle to the main figure window
%     file          - file fullfilepath (optional)
%
%    Output:
%     mainhandles   - handles structure of the main window
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

% Get mainhandles structure
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    mainhandles = [];
    return
else
    mainhandles = guidata(mainhandle);
end

if nargin<2
    file = [];
end

% Save current session dialog
if 0 && ~isempty(mainhandles.data)
    choice = myquestdlg('Do you wish to save the current session before closing? ','Save session',...
        ' Yes ', ' No ', ' Cancel ', ' Yes ');
    
    if isempty(choice) || strcmpi(choice, ' Cancel ')
        setappdata(0,'closeok',1)
        return
        
    elseif strcmpi(choice,' Yes ')
        mainhandles = savesession(mainhandles.figure1);
    end
end

%% Open a dialog for specifying file

if isempty(file)
    fileformats = {'*.iSMSsession;*.mat', 'iSMS session files'; '*.iSMSsession', 'New session files'; '*.mat', 'Old session files'; '*.*', 'All files'};
    [FileName,PathName,chose] = uigetfile3(mainhandles,'session', fileformats, 'Open iSMS Session','name.iSMSsession','off');
    if chose == 0
        return
    end
    file = fullfile(PathName,FileName);
    
else
    [PathName,NAME,EXT] = fileparts(file);
    FileName = [NAME EXT];
end

% Turn on waitbar
hWaitbar = mywaitbar(1,'Opening session. Please wait...','name','iSMS');
setFigOnTop([]) % Sets the waitbar so that it is always in front
% movegui(hWaitbar,'north')

%% Open file and retrieve state structure

try temp = load(file,'-mat');
catch err    
    return
end

if ~myIsField(temp,'state')
    if myIsField(temp,'settings')
        set(mainhandles.mboard,'String',sprintf(...
            'It appears the selected file was a settings file, not a session file. Please select a new session file.'))
    else
        set(mainhandles.mboard,'String',sprintf(...
            'No correct iSMS session selected. A correct session is an .mat file containing a structure named state.'))
    end
    
    % Close waitbar
    delete(hWaitbar)
    return
end
state = temp.state;

%% Load session

% try
    set(mainhandles.FilesListbox,'Value',1) % This makes sure the FilesListbox is not set at a value larger than the number of files in the loaded session
    mainhandles = loadstate(mainhandle,state);
% catch err
%     set(mainhandles.mboard,'String',sprintf('The selected file was either from a different iSMS version or it was not an iSMS session.\nError message: %s',err.message))
%     return
% end

% Close waitbar
delete(hWaitbar)

%% Update

mainhandles.filename = file;
set(mainhandles.figure1,'Name',sprintf('iSMS - smFRET software on immobilized molecules.  Session: %s',mainhandles.filename))
updatemainhandles(mainhandles)

% Save recent files list
updateRecentFiles(mainhandles, PathName, FileName, 'session');

%% Reload raw movie data
if ~strcmpi(FileName,'demo.iSMSsession') && mainhandles.settings.save.askforraw
    
    % Dialog
    choice = MFquestdlg([ 0.4 , 0.65 ], sprintf(['Do you wish to load raw movie data too? \n\n'...
        'The raw data is needed if you want to re-calculate intensity traces.\nIf this is not needed in the current session press ''No'' to save RAM.\n\n'...
        'Raw data can always be reloaded later from the memory menu in the main window.']),...
        'iSMS',...
        'Yes','No','No, don''t ask again','No');
    
    % Callback
    if strcmpi(choice,'Yes') % Reload movies
        mainhandles = reloadMovies(mainhandles.figure1,[],1);
    elseif strcmpi(choice,'No, don''t ask again')
        mainhandles = savesettingasDefault(mainhandles,'save','askforraw',0);
    end
end

%% Demo session callback
if strcmpi(FileName,'demo.iSMSsession')
    
    % Open FRET-pair window (only for demo session)
    mainhandles = openFRETpairwindowCallback(mainhandles);
    
    % Turn on the toolbar toggle button, but make sure it doesn't initiate
    % another callback
    setappdata(0,'callback',1)
    set(mainhandles.Toolbar_FRETpairwindow,'State','on')
    rmappdata(0,'callback')

    % Dialog
    str = sprintf([...
        'Welcome to this demo session!\n\n'...
        'This session contains analysed demo data from 3 raw video files.\n'...
        'To EXPLORE the analysed data open the following windows from the toolbar:\n\n'...
        '   1) FRET-pairs window (<-has already been opened for you)\n'...
        '   2) Histogram window\n'...
        '   3) Correction factor window\n'...
        '   4) Dynamics window\n\n'...
        'NOTE:\nThe raw image data is not loaded into the session. '...
        'If you wish to re-calculate traces using new settings you must reload the raw image data from file. '...
        'This is done from the Performance->Memory menu.\n\n'...
        'Good luck!\n']);
    
    mymsgbox(str)
    
end
