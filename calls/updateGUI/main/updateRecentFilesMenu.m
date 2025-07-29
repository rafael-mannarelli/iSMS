function updateRecentFilesMenu(mainhandles)

% two edits by RR on 27April 2021

% Updates the recent files list in the main file menu
%
%     Input:
%      mainhandles   - handles structure of the main window
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

% Delete previous menu items
sessions=[]; % RR, added to define varibales
prevh = get(mainhandles.File_RecentSessionsMenu, 'Children');
delete(prevh)
prevh = get(mainhandles.File_RecentMoviesMenu, 'Children');
delete(prevh)

% Load recent files list
lastdirfile = fullfile(mainhandles.settingsdir,'recentfiles.lastdir');

% Check existence
if exist(lastdirfile,'file')
    load(lastdirfile,'-mat');
else
    insertEmpty([mainhandles.File_RecentSessionsMenu mainhandles.File_RecentMoviesMenu])
    return
end

% If there are no stored files
if (~exist('sessions','var') || ~exist('movies','var')) ...
        || (isempty(sessions) && isempty(movies))
    insertEmpty([mainhandles.File_RecentSessionsMenu mainhandles.File_RecentMoviesMenu])
    return
end

%% Session files

if ~isempty(sessions)
    % Create first
    mh = uimenu(mainhandles.File_RecentSessionsMenu,...
        'Label', 'Load most recent',...
        'Callback', {@loadrecentfileCallback, 'session', mainhandles.figure1, sessions{1}});
    if ispc
        set(mh, 'Accelerator', 'R');
    end
    
    % Create file items
    for i = 1:size(sessions,1)
        [path,filename,ext] = fileparts(sessions{i});
        
        mh = uimenu(mainhandles.File_RecentSessionsMenu,...
            'Label', filename,...
            'Callback', {@loadrecentfileCallback, 'session', mainhandles.figure1, sessions{i}} );
        if i==1
            set(mh,'separator','on')
        end
    end
    
else
    insertEmpty(mainhandles.File_RecentSessionsMenu)
end

%% Movie files

if ~isempty(movies)
    
    % Create first
    mh = createDataMenuItem(1,'Load most recent');
    if ispc
        set(mh,'Accelerator','K')
    end
    
    % Create file items
    for i = 1:size(movies,1)
        mh = createDataMenuItem(i,[]);
        if i==1
            set(mh,'separator','on')
        end
    end
    
else
    insertEmpty(mainhandles.File_RecentMoviesMenu)
end

%% Nested
movies=[]; % RR,  added to define varibales

    function mh = createDataMenuItem(idx,nameIn)
        % First file
        if isempty(nameIn)
            [path,name,ext] = fileparts(movies{idx,1});
        else
            name = nameIn;
        end
        
        % Second files
        if size(movies,2)>1
            
            % If item i contains more than one file
            for j = 2:size(movies,2)
                if isempty(movies{idx,j})
                    break
                end
                
                [path,filename,ext] = fileparts(movies{idx,j});
                name = sprintf('%s; %s',name,filename);
            end
        end
        
        % Create menu item
        mh = uimenu(mainhandles.File_RecentMoviesMenu,...
            'Label', name,...
            'Callback', {@loadrecentfileCallback, 'movie', mainhandles.figure1, movies(idx,:)} );
        
    end
end

function insertEmpty(h)
% Insert a disabled menu item under h called 'empty'

for i = 1:length(h)
    mh = uimenu(h(i),...
        'Label', '<empty>',...
        'enable', 'off');
end

end
