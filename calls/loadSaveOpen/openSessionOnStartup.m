function mainhandles = openSessionOnStartup(mainhandles, varargin)
% Tries to open a session if it was provided as input argument for iSMS
%
%   Input:
%    mainhandles    - handles structure of the main window
%
%   Output:
%    mainhandles    - ...
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

try 
    % Open session 
    if ~isempty(varargin) && length(varargin)==1
    file = varargin{1};
    ok = 0;
    check3 = 0;
    if exist(file,'file')==2 || exist([file '.mat'],'file')==2 % First search for file in the same directory as sms.m
        if exist(file,'file')==2
            filename = fullfile(pwd,file);
        else
            filename = fullfile(pwd,[file '.mat']);
        end
        ok = 1;
        
    elseif exist('sessions','dir')==7 % Then look for a sessions folder
        cd sessions
        if exist(file,'file')==2 || exist([file '.mat'],'file')==2
            if exist(file,'file')==2
                filename = fullfile(pwd,file);
            else
                filename = fullfile(pwd,[file '.mat']);
            end
            ok = 1;
        else
            check3 = 1;
        end
        cd(mainhandles.workdir)
        
    else check3 = 1;
    end
    
    if check3   % Then look in the last-used sessions folder
        % name of mat file to save last used directory information
        lastDirMat = fullfile(mainhandles.settingsdir,'lastUsedSessionDir.mat');
        
        % load last data directory
        if exist(lastDirMat, 'file') ~= 0
            % lastDirMat mat file exists, load it
            load('-mat', lastDirMat)
            % check if lastDataDir variable exists and contains a valid path
            if (exist('lastUsedDir', 'var') == 1) && (exist(lastUsedDir, 'dir') == 7)
                % set default dialog open directory
                lastDir = lastUsedDir;
                cd(lastUsedDir)
                if exist(file,'file')==2 || exist([file '.mat'],'file')==2
                    if exist(file,'file')==2
                        filename = fullfile(pwd,file);
                    else
                        filename = fullfile(pwd,[file '.mat']);
                    end
                    ok = 1;
                end
                cd(mainhandles.workdir)
            end
        end
        
    end
    
    % Open session file
    if ok
        updatemainhandles(mainhandles)
        try mainhandles = opensession(mainhandles.figure1,filename); end
    end
end
end
