function mainhandles = sortcorrectionpairsCallback(cwHandle, choice)
% Callback for sorting molecules in the correction factor window
%
%    Syntax:
%     mainhandles = sortpairsCallback(cfHandle, choice)
%
%    Input:
%     cfHandle    - handle to the correction factor window
%     choice      - 1/2/3/4.. See their meaning in getPairs.m
% 
%    Output:
%     mainhandles             - handles structure of the main window
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

if isempty(cwHandle) || ~ishandle(cwHandle)
    return
end

% Get handles structures
cwHandles = guidata(cwHandle);
cwHandles = turnofftogglesCorrectionWindow(cwHandles);
mainhandles = getmainhandles(cwHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Default
if nargin<2
    choice = mainhandles.settings.correctionfactorplot.sortpairs;
end

% Get selected pairs so listbox value can be changed afterwards
selectedPairs = getPairs(cwHandles.main,'correctionSelected',[],[],[],cwHandles.figure1);

%% Update settings structure

mainhandles.settings.correctionfactorplot.sortpairs = choice;
updatemainhandles(mainhandles)

%% Update

updatecorrectionwindowGUImenus(cwHandles)
updateCorrectionFactorPairlist(mainhandles.figure1,cwHandle)

%% Keep selected FRETpairs

listedPairs = getPairs(cwHandles.main,'correctionlisted',[],[],[],cwHandles.figure1);
idx = find( ismember(listedPairs,selectedPairs,'rows','legacy') );
set(cwHandles.PairListbox, 'Value',idx)
