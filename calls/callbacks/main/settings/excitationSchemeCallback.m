function mainhandles = excitationSchemeCallback(mainhandles,choice)
% Callback for setting excitation scheme
%
%    Input:
%     mainhandles   - handles structure of the main window
%     choice        - 0: single excitation / 1: ALEX
%
%    Output:
%     mainhandles   - ..
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

if mainhandles.settings.excitation.alex==choice
    return
end

%% Check if data has already been analysed

for i = 1:length(mainhandles.data)
    if ~isempty(mainhandles.data(i).FRETpairs)
        
        % Sure dialog
        answer = myquestdlg('Warning: This will reset all data and delete all FRET pairs.', 'Excitation scheme',...
            ' Continue ', ' Cancel ', ' Cancel ');
        
        % Return
        if isempty(answer) || strcmpi(answer,' Cancel ')
            return
        end
        break
    end
end

%% Update

% Update settings
mainhandles = savesettingasDefaultDlg(mainhandles, 'excitation','alex', choice);

% Update menu checkmarks
updatemainGUImenus(mainhandles)

% Waitbar
hWaitbar = mywaitbar(0,'Updating. Please wait...','name','iSMS');

% Update existing data
for i = 1:length(mainhandles.data)
    
    % Set new excitation order
    mainhandles.data(i).excorder = suggestExcOrder(mainhandles,mainhandles.data(i).imageData,mainhandles.data(i).Droi);
    
    % Clear peaks and pairs
    mainhandles = clearpeaksdata(mainhandles,i);
    mainhandles = resetPeakSliders(mainhandles,i);
    
    % Save new ROI movies
    mainhandles = saveROImovies(mainhandles,'all');
    
    % Update waitbar
    waitbar(i/length(mainhandles.data),hWaitbar);
end

% Update GUI
updatemainhandles(mainhandles)
updateframeslist(mainhandles)
mainhandles = updatepeakplot(mainhandles);

% Close all windows
mainhandles = closeWindows(mainhandles,'all');

% Update menus
mainhandles = updateALEX(mainhandles);

% Delete waitbar
try delete(hWaitbar), end