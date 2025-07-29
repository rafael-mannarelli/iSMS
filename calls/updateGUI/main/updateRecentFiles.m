function updateRecentFiles(mainhandles, filepath, filenames, type)
% Saves filepath to .lastdir file to make it usable in the recent files
% menu items in the main window. Also updates the menu items
%
%     Input:
%      mainhandles    - handles structure of the main window
%      filepath       - directory
%      filenames      - filename. For movies, filename is a cell array.
%      type           - 'session' or 'movie'
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

% Filepath to lastdir file
lastdirfile = fullfile(mainhandles.settingsdir,'recentfiles.lastdir');

% Check existence
if exist(lastdirfile,'file')
    load(lastdirfile,'-mat');
else
    sessions = {};
    movies = {};
end

%% Update

if strcmpi(type,'session')
    
    % Save filepath as loaded session
    if isempty(sessions)
        sessions{1} = fullfile(filepath,filenames);
    else
        sessions{end+1,1} = fullfile(filepath,filenames);
    end
    
    % Delete multiple instances of same file and order chronologically
    sessions = unique( circshift(sessions,[1 0]),'stable' );
    
    % Max items
    if size(sessions,1)>20
        sessions = sessions(1:20);
    end
    
elseif strcmpi(type,'movie')
    
    % Save filepath as loaded movie
    if isempty(movies)
        movies{1,1} = fullfile(filepath,filenames{1});
    else
        movies{end+1,1} = fullfile(filepath,filenames{1});
    end
    
    % Add additional files, if multiple are loaded
    if size(filenames,2)>1
        
        for i = 2:size(filenames,2)
            movies{end,i} = fullfile(filepath,filenames{i});
        end
        
    end
    
    % Set all cell elements to chars
    movies = cellfun(@char,movies,'UniformOutput',false);
    
    % Move latest entry to the top
    movies = circshift(movies,[1 0]);
    
    % Delete multiple instances of same file. This is needed a bit odd
    % because unique('rows') does not work on cell arrays
    [~,~,J] = uniqueRowsCA( movies ); % Determine what cell rows a duplicate
    temp = J(1);
    J(J==J(1)) = 0;
    J(1) = temp;
    movies(J==0,:) = []; % Remove all equals to just inserted entry
    
    % Max items
    if size(movies,1)>20
        movies = movies(1:20,:);
    end
    
end

% Save new lastdir file
save(lastdirfile,'sessions','movies')

% Update menu items:
updateRecentFilesMenu(mainhandles)
