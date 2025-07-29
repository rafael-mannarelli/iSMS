function openpool(handles)
% Callback for opening pool of workers
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

% Set pointer to thinking
pointer = setpointer(handles.figure1);
set(handles.mboard,'String','Attempting to open pool...')
drawnow

% Open pool
try
    T = evalc('parpool;');

catch err

    if strcmpi(err.message,sprintf('Found an interactive session. You cannot have multiple interactive sessions open simultaneously. To terminate the existing session, use ''delete(gcp)''.'))
        % If a pool is already running
        T = 'An interactive session is already running. Use ''Close pool'' to shut it down.';
    else
        T = err.message;
    end
end

% Update message board
set(handles.mboard,'String',T)

% Turn pointer back to arrow
pointer = setpointer(handles.figure1,pointer);
