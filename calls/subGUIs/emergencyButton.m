function fh = emergencyButton(~)
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

%--------- Create GUI window ---------%
h.figure1 = figure(...
    'Name',     '',...
    'Units',    'pixels',...
    'Position', [50  150  100  50],...
    'Visible',  'off',...
    'menubar',  'none',...
    'UserData', 'Cancel');
% movegui(h.figure1,'center')
updatelogo(h.figure1) % Update logo

%--------- Create GUI components ---------%

%-- OK pushbutton --%
h.OKpushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'Stop',...
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'FontUnits','normalized',...
    'Position', [0.1 0.1 0.8 0.8],...
    'Callback', {@pushbutton_Callback},...
    'BackgroundColor', [0.95 0.65 0.65]...
    );

    function pushbutton_Callback(varargin) %%
        try
            delete(h.figure1);
        end
    end

%--- Set callbacks ---%
% set(h.OKpushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback

% Output
fh = h.figure1;

%--- Update dialog ---%
guidata(h.figure1,h)
set(h.figure1,'Visible','on')
end
