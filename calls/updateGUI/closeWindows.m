function mainhandles = closeWindows(mainhandles,choice)
% Closes open windows except main
%
%    Input:
%     mainhandles   - handles structure of the main window
%     choice        - ['all']
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

if nargin<2
    choice = 'all';
end

if strcmpi(choice,'all')
    
    try set(mainhandles.Toolbar_FRETpairwindow,'State','off'), end
    try set(mainhandles.Toolbar_histogramwindow,'State','off'), end
    try set(mainhandles.Toolbar_correctionfactorWindow,'State','off'), end
    try set(mainhandles.Toolbar_dynamicswindow,'State','off'), end
    try delete(mainhandles.profilewindowHandle), end
    try delete(mainhandles.driftwindowHandle), end
    try delete(mainhandles.integrationwindowHandle), end
    try delete(mainhandles.psfwindowHandle), end
    
end
