function aboutProgram(handles)
% Displays a dialog containing information on the software
%
%    Input:
%     handles  - handles structure of the main window. Must contain fields
%                version, name and website
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


% Open dialog
% choice = myquestdlg(sprintf(...
%     'Version: %s\n\nContact:\nSøren Preus: spreus@fluortools.com\n', handles.version), ...
%     sprintf('About %s',handles.name), ...
%     '     Website     ','     Website     ');
choice = myquestdlg(sprintf(...
    'Version: %s', handles.version), ...
    sprintf('About %s',handles.name), ...
    '     Close     ','     Close     ');

% % Handle response
% if strcmpi(choice,'     Website     ')
%     myopenURL(handles.website)
% end
