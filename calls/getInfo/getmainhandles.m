function mainhandles = getmainhandles(handles)
% Returns the handles structure of the main figure window or show a
% messagebox if handle is lost
%
%    Input:
%     handles       - handles structure of the GUI calling this function.
%                     The handle to the main window should be put at
%                     handles.main
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

% Initialize handles structure of the main window
mainhandles = []; 

% Check handle to the main window and get mainhandles
try
    if isempty(handles.main) || ~ishandle(handles.main)
        
        % Default
        try mainhandles = guidata(getappdata(0,'mainhandle')); end
        
        % Show warning
        dbstack
        fprintf(['For some reason the main handle is lost. '...
            'This could be a bug. Try reopening active windows.'])
        return
    end
    
    % Get handles structure of the main figure window
    mainhandles = guidata(handles.main); 
    
catch err
    
    % An error occurs if input handles structure does not have a fieldname
    % main
    mainhandles = guidata(getappdata(0,'mainhandle'));
    
end

