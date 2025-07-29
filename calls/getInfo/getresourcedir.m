function dir = getresourcedir(workdir)
% Returns the directory of the resource files (icons etc.)
%
%    Input:
%     workdir   - installation directory
%
%    Output:
%     dir       - settings folder path
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

if isdeployed
    % For deployed applications the settings are located in the app folder
    dir = getapplicationdatadir(['iSMS' filesep 'resources'], 1, 1);
else
    % For MATLAB version
    dir = fullfile(workdir,'resources');
end
