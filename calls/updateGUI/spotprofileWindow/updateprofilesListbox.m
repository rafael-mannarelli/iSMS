function updateprofilesListbox(spHandles) 
% Updates the listbox strings in the spot profile window
%
%   Input:
%    spHandles   - handles structure of the spot profile window
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

% Check if there are any green profiles
if isempty(spHandles.green)
    set(spHandles.greenListbox,'String','')
else
    % Set listbox strings
    set(spHandles.greenListbox,'String',{spHandles.green(:).name})
end
% Check if there are any red profiles
if isempty(spHandles.red)
    set(spHandles.redListbox,'String','')
else
    set(spHandles.redListbox,'String',{spHandles.red(:).name})
end

% Check listbox value
if (isempty(get(spHandles.greenListbox,'Value'))) || (isempty(spHandles.green))
    set(spHandles.greenListbox,'Value',1)
elseif (get(spHandles.greenListbox,'Value')>length(spHandles.green))
    set(spHandles.greenListbox,'Value',length(spHandles.green))
end
if (isempty(get(spHandles.redListbox,'Value'))) || (isempty(spHandles.red))
    set(spHandles.redListbox,'Value',1)
elseif (get(spHandles.redListbox,'Value')>length(spHandles.red))
    set(spHandles.redListbox,'Value',length(spHandles.red))
end
