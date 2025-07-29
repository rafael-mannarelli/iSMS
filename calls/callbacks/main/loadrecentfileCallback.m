function mainhandles = loadrecentfileCallback(hObject,event,type,mainhandle,file)
% Callback for loading a recent file from the file menu in the main window
%
%    Input:
%     hObject    - handle to the menu item
%     event      - eventdata
%     type       - 'session' 'movie'
%     mainhandle - handle to the main window
%     file       - fullfilepath. Cell array if type movie
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

% Must change path to the directory when loading data from server in R2014b
currdir = pwd;

if strcmpi(type,'session')
    % Load session
    
    % % R2014b fix for loading data from server
    try cd(fileparts(file))
    catch err
        mymsgbox(sprintf('The filepath seems to be broken:\n\n   %s   \n\nYou must load the file manually.',file))
        cd(currdir)
        return
    end

    % Check if session file exist
    if ~exist(file,'file')
        mymsgbox(sprintf('The filepath seems to be broken:\n\n   %s   \n\nYou must load the file manually.',file))
        cd(currdir)
        return
    end
    
    % Load a recent session
    mainhandles = opensession(mainhandle,file);
    
elseif strcmpi(type,'movie')
    % Load movie

    % R2014b fix for server files
    dir = fileparts(file{1,1});
    try cd(dir)
    catch err
        mymsgbox(sprintf('The filepath seems to be broken:\n\n   %s   \n\nYou must load the file manually.',dir))
        cd(currdir)
        return
    end
    
    % Check existence
    n = 0;
    nfiles = size(file,2);
    for i = 1:size(file,2)
        
        % Path to file
        filepath = file{1,i};
        if isempty(filepath)
            nfiles = i-1;
            break
        end
        n = n+1;
        
        if ~exist(filepath,'file')
            mymsgbox(sprintf('There seems to be a broken filepath to:\n\n   %s   \n\nYou must load the file(s) manually.',filepath))
            return
        end
    end
    if n==0
        return
    end
    
    % Load a recent movie
    mainhandles = guidata(mainhandle);
    
    % Turn on waitbar
    if size(file,2)>1
        hWaitbar = mywaitbar(0,sprintf('Loading %i movies. Please wait...',nfiles),'name','iSMS');
    else
        hWaitbar = mywaitbar(0,'Loading 1 movie. Please wait...','name','iSMS');
    end
%     try setFigOnTop([]), end % Sets the waitbar so that it is always in front
    
    dir = fileparts(file{1,1});
    filenames = {};
    for i = 1:size(file,2)
        
        % Path to file
        filepath = file{1,i};
        if isempty(filepath)
            waitbar(i/n, hWaitbar)
            break
        end
        
        % Load file i
        [mainhandles, cancelled] = loadDataCallback(mainhandles, 0, filepath, 0);
        if cancelled
            try delete(hWaitbar), end
            return
        end
        
        % Split path and name
        [~,NAME,EXT] = fileparts(filepath);
        filenames{1,i} = [NAME EXT];
        
        % Update waitbar
        waitbar(i/n, hWaitbar)
    end
    
    % Update recent files list
    updateRecentFiles(mainhandles, dir, filenames, 'movie');
    
    % Delete waitbar
    try delete(hWaitbar),end
end

% Return to directory
cd(currdir)
