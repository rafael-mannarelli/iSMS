function parallelMenuCallback(handles)
% Callback for selecting the parallel computing menu
%
%    Input:
%     handles  - handles structure of the main window. The parallel menu
%     must have sub item with tag handles.Performance_Parallel_ClusterSize
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

% Get pool size
try
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        T = 0;
    else
        T = poolobj.NumWorkers;
    end
    
    T = sprintf('Size of current pool: %i',T);
catch err
    T = 'Size of current pool';
end

% Update string
set(handles.Performance_Parallel_ClusterSize,'Label',T)
