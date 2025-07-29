function updatemaincontrastsliderTextbox(mainhandles)
% Updates the text displayed in the contrast slider info textbox above the ROI
% image in the main window
%
%    Input:
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

%% Initialize
if isempty(mainhandles.data)
    set(mainhandles.rawcontrastTextbox,'String','')
    set(mainhandles.greenROIcontrastTextbox,'String','')
    set(mainhandles.redROIcontrastTextbox,'String','')    
    return
end

% Selection
file= get(mainhandles.FilesListbox,'Value'); % Selected file

% Choice of whether to update raw or ROI box
% if choice==1
    set(mainhandles.rawcontrastTextbox,...
        'String',sprintf('%i / %i ',round(mainhandles.data(file).rawcontrast)),...
        'ForeGroundColor','white', 'HorizontalAlignment','right')
    
% elseif choice==2
    set(mainhandles.greenROIcontrastTextbox,...
        'String',sprintf('%i / %i ',round(mainhandles.data(file).greenROIcontrast)),...
        'ForeGroundColor','white', 'HorizontalAlignment','right')
    
% elseif choice==3
    set(mainhandles.redROIcontrastTextbox,...
        'String',sprintf('%i / %i ',round(mainhandles.data(file).redROIcontrast)),...
        'ForeGroundColor','white', 'HorizontalAlignment','right')
% end


