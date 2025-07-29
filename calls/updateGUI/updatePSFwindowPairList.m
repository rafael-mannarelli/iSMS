function updatePSFwindowPairlist(mainhandle, psfwindowHandle)
% Updates the FRETpair listbox string in the psf parameters plot window
%
%    Input:
%     mainhandle      - handle to the main figure window
%     psfwindowHandle - handle to the psf parameters window
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

% If one of the windows is closed
if (isempty(mainhandle)) || (isempty(psfwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(psfwindowHandle))
    return
end

% Get handles
psfwindowHandles = guidata(psfwindowHandle);

% Get all FRETpairs
listPairs = getPairs(mainhandle, 'All'); 
if isempty(listPairs)
    set(psfwindowHandles.PairListbox,'String','')
    set(psfwindowHandles.PairListbox,'Value',1)
    return
end

%% Make string cell

if get(psfwindowHandles.PSFpopupMenu,'Value')==1
    gaussPairs = getPairs(mainhandle, 'psf', 'DD'); % Returns all pairs that have had their relevant psf trace calculated
elseif get(psfwindowHandles.PSFpopupMenu,'Value')==2
    gaussPairs = getPairs(mainhandle, 'psf', 'AD'); % Returns all pairs that have had their relevant psf trace calculated
elseif get(psfwindowHandles.PSFpopupMenu,'Value')==3
    gaussPairs = getPairs(mainhandle, 'psf', 'AA'); % Returns all pairs that have had their relevant psf trace calculated
end
npairs = size(listPairs,1);
namestr = cell(npairs,1);
for i = 1:npairs
    file = listPairs(i,1);
    pair = listPairs(i,2);
    
    % Add file suffix
    namestr{i} = sprintf('%i,%i', file, pair); % Change listbox string
    
    % Boldface calculated pairs
    if ismember([file pair], gaussPairs, 'rows','legacy')
        namestr{i} = sprintf('<HTML><b>%s</b></HTML>', namestr{i}); % Change string to HTML code
    end
end

% Check that selection does not exceed string size
pairchoice = get(psfwindowHandles.PairListbox,'Value');
if pairchoice(end)>npairs
    set(psfwindowHandles.PairListbox,'Value',npairs)
end

%% Set pairlistbox string

set(psfwindowHandles.PairListbox,'String',namestr)
