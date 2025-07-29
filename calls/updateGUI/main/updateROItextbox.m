function updateROItextbox(adjustROIswindowHandle)
% Updates the ROI position textboxes in the fine-adjust ROIs window
%
%    Input:
%     adjustROIswindowHandle   - handle to the adjust window
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

if isempty(adjustROIswindowHandle) || ~ishandle(adjustROIswindowHandle)
    return
end

adjustROIswindowHandles = guidata(adjustROIswindowHandle);
mainhandles = getmainhandles(adjustROIswindowHandles);
if isempty(mainhandles)
    return
end

% Colors
if mainhandles.settings.view.colorblind
    Dstr = 'Donor ROI (blue)';
    Astr = 'Acceptor ROI (yellow)';
else
    Dstr = 'Donor ROI (green)';
    Astr = 'Acceptor ROI (red)';
end

% Selected 
if (isempty(mainhandles.data)) || (isempty(mainhandles.AROIhandle)) || (isempty(mainhandles.DROIhandle)) % If no data is loaded, return
    set(adjustROIswindowHandles.DroiRadiobutton,'String', Dstr)
    set(adjustROIswindowHandles.AroiRadiobutton,'String', Astr)
    return
end
filechoice = get(mainhandles.FilesListbox,'Value'); % Selected movie file

%% Update

DROI = mainhandles.data(filechoice).Droi; % The position of the donor ROI in the global image
AROI = mainhandles.data(filechoice).Aroi; % The position of the acceptor ROI in the global image
set(adjustROIswindowHandles.DroiRadiobutton,'String', sprintf('%s:  [%.1f %.1f %.1f %.1f]',Dstr,DROI))
set(adjustROIswindowHandles.AroiRadiobutton,'String', sprintf('%s: [%.1f %.1f %.1f %.1f]',Astr,AROI))
