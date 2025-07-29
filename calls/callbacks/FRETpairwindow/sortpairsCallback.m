function mainhandles = sortpairsCallback(fpwHandle, choice)
% Callback for sorting molecules in the FRETpairwindow
%
%    Syntax:
%     mainhandles = sortpairsCallback(FRETpairwindowHandle, choice)
%
%    Input:
%     fpwHandle         - handle to the FRETpairwindow
%     choice            - 1/2/3/4.. See their meaning in getPairs.m
% 
%    Output:
%     mainhandles       - handles structure of the main window
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

if isempty(fpwHandle) || ~ishandle(fpwHandle)
    mainhandles = guidata(getappdata(0,'mainhandle'));
    return
end

% Get handles structures
fpwHandles = guidata(fpwHandle);
mainhandles = getmainhandles(fpwHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Default
if nargin<2
    choice = mainhandles.settings.FRETpairplots.sortpairs;
end

% Get selected pairs so listbox value can be changed afterwards
selectedPairs = getPairs(fpwHandles.main,'Selected',[],fpwHandles.figure1);

%% Update settings structure

mainhandles.settings.FRETpairplots.sortpairs = choice;

% Show mean FRET
if choice==3
    mainhandles.settings.FRETpairplots.avgFRET = 1;
end

%% Update

% Update handles structure
updatemainhandles(mainhandles)

% Update FRET pair window
updateFRETpairwindowGUImenus(mainhandles,fpwHandles)
updateFRETpairlist(fpwHandles.main,fpwHandles.figure1)

%% Keep selected FRETpairs

selectPairs(mainhandles, fpwHandles, selectedPairs)
