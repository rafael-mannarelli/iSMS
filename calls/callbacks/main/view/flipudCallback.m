function mainhandles = flipudCallback(mainhandles)
% Callback for flipping view updown in main window
%
%    Input:
%     mainhandles   - handles structure
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

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% Check for FRET pairs
if ~isempty(getPairs(mainhandles.figure1,'all'))
    
    % Dialog
    answer = myquestdlg('OBS: This will delete all FRET pairs.','View','Continue','Cancel','Cancel');
    if isempty(answer) || strcmpi(answer,'Cancel')
        return
    end
end

% All files
files = 1:length(mainhandles.data);

%% Flip

for i = 1:length(files)
    file = files(i);
    
    mainhandles.data(file).imageData = fliplr(mainhandles.data(file).imageData); % Raw images
    mainhandles.data(file).avgimage = fliplr(mainhandles.data(file).avgimage); % Avg. image
    mainhandles.data(file).avgDimage = fliplr(mainhandles.data(file).avgDimage); % Avg. image
    mainhandles.data(file).avgAimage = fliplr(mainhandles.data(file).avgAimage); % Avg. image
    for j = 1:size(mainhandles.data(file).geoTransformations,2) % Update all files in merged movie
        mainhandles.data(file).geoTransformations{1,j}{end+1,1} = 'flipud'; % Update transformation cell
    end
end

%% Update GUI

mainhandles.settings.view.flipud = abs(mainhandles.settings.view.flipud-1);
updatemainhandles(mainhandles)

% Update
mainhandles = clearpeaksdata(mainhandles,files);
mainhandles = resetPeakSliders(mainhandles);
mainhandles = updaterawimage(mainhandles);
mainhandles = updateROIhandles(mainhandles);
mainhandles = updateROIimage(mainhandles);
mainhandles = updatepeakplot(mainhandles,'all');
updatemainGUImenus(mainhandles)
mainhandles = closeWindows(mainhandles);

% Save as default
mainhandles = savesettingasDefaultDlg(mainhandles,'view','flipud',mainhandles.settings.view.flipud);
