function clustersize(handles)
% Callback for checking current number of workers
%
%   Input:
%    handles   - handles structure of the main window
%

% --- Copyrights (C) ---
%
% Copyright (C)  Søren Preus, FluorTools.com
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

% Close pool
try
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        T = 0;
    else
        T = poolobj.NumWorkers;
    end
    T = sprintf('Number of workers:\n%i',T);
catch err
    T = err.message;
end

% Update message board
set(handles.mboard,'String',T)