function closepool(handles)
% Callback for closing pool of workers
%
%    Input:
%     handles   - handles structure of the main window
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

% Set pointer to thinking
pointer = setpointer(handles.figure1);

% Close pool
try
    T = evalc('delete(gcp)');

catch err    
    if strcmpi(err.message,sprintf('Pool is not currently active. Use ''parpool open'' to start an interactive session.'))
        % If there is no pool running
        T = 'No active pools were found. Use ''Open pool'' to start one.';
    else
        T = err.message;
    end
end

% Update message board
if strcmpi(T,sprintf('Parallel pool using the ''local'' profile is shutting down.\n'))
    T = 'Parallel pool using the ''local'' profile was shut down.';
end
set(handles.mboard,'String',T)

% Turn pointer back to arrow
pointer = setpointer(handles.figure1,pointer);