function mainhandles = frameListboxCallback(hObject,event, mainhandle)
% Callback for selection change in the frame listbox
%
%    Input:
%     hObject      - handle the listbox
%     event        - not used
%     mainhandle   - handle to the main window
%
%    Output:
%     mainhandles   - ...
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

% Get mainhandles structure
try 
    % First try with input
    mainhandles = gogomainhandles(mainhandle);
catch err
    try 
        % Then try with parent
        mainhandles = gogomainhandles( get(hObject,'Parent') );
    catch err
        % Then try with stored handle in appdata
        mainhandles = gogomainhandles( getappdata(0,'mainhandle') );
    end
end

if isempty(mainhandles.data)
    return
end

%% Callback

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file
if get(mainhandles.FramesListbox,'Value')==2 % If selected background image
    
    if isempty(mainhandles.data(file).back)
        myquestdlg(sprintf('There is no background image stored for this file.'),'iSMS',...
            'OK','OK');
        set(mainhandles.FramesListbox,'Value',1)
    end
    
end

% Reset raw peaks, this will force a new peak run on the selected frame
mainhandles.data(file).DpeaksRaw = [];
mainhandles.data(file).ApeaksRaw = [];

% Update GUI
mainhandles = updaterawimage(mainhandles);
% mainhandles = updateROIhandles(mainhandles);
mainhandles = updateframesliderHandle(mainhandles);
updatemainframesliderTextbox(mainhandles)
mainhandles = updateROIimage(mainhandles,0);
mainhandles = updatecontrastSliders(mainhandles,1,0,1,1,1);
% mainhandles = updatepeakplot(mainhandles,'all',0,0);
end

function mainhandles = gogomainhandles(mainhandle)
mainhandles = guidata(mainhandle);
mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
end