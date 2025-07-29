function [mainhandles,FRETpairwindowHandles] = filterPairsDialog(mainhandles)
% Opens the pair filter dialog and runs the specified filter settings
% 
%    Input:
%     mainhandles   - handles structure of the main figure window
%
%    Output:
%     mainhandles   - ..
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
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

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Prepare dialog box

if alex
    prompt = {'Filter 1: ' 'filter1';...
        'Delete pairs where the mean D+A intensity of the' 'filter1frames';...
        'most intense frames is below                      ' 'filter1counts';...
        'counts' '';...
        'Filter 2: ' 'filter2';...
        'Delete pairs with neighbouring peak within  ' 'filter2dist';...
        'pixels' '';...
        'Filter 3: ' 'filter3';...
        'Delete pairs with bleaching within the first  ' 'filter3frames';...
        'frames' '';...
        'Filter 4: ' 'filter4';...
        'Delete pairs where the mean direct A intensity of the' 'filter4frames';...
        'most intense frames is below                      ' 'filter4counts';...
        'counts' '';...
        'Only filter pairs in selected file' 'filterselected';...
        'Set filters as permanent' 'permanentfilters'};
else
    prompt = {'Filter 1: ' 'filter1';...
        'Delete pairs where the mean D+A intensity of the' 'filter1frames';...
        'most intense frames is below                      ' 'filter1counts';...
        'counts' '';...
        'Filter 2: ' 'filter2';...
        'Delete pairs with neighbouring peak within  ' 'filter2dist';...
        'pixels' '';...
        'Filter 3: ' 'filter3';...
        'Delete pairs with bleaching within the first  ' 'filter3frames';...
        'frames' '';...
        'Only filter pairs in selected file' 'filterselected';...
        'Set filters as permanent' 'permanentfilters'};
end

name = 'Filter criteria';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Interpolation choices
% filter1
formats(2,1).type = 'check';
formats(2,2).type = 'edit';
formats(2,2).size   = 40;
formats(2,2).format = 'integer';
formats(3,2).type = 'edit';
formats(3,2).size   = 40;
formats(3,2).format = 'integer';
formats(3,3).type = 'text';
% filter2
formats(5,1).type = 'check';
formats(5,2).type = 'edit';
formats(5,2).size   = 40;
formats(5,2).format = 'float';
formats(5,3).type = 'text';
% filter3
formats(7,1).type = 'check';
formats(7,2).type = 'edit';
formats(7,2).size   = 40;
formats(7,2).format = 'integer';
formats(7,3).type = 'text';

if alex
    formats(9,1).type = 'check';
    formats(9,2).type = 'edit';
    formats(9,2).size   = 40;
    formats(9,2).format = 'integer';
    formats(10,2).type = 'edit';
    formats(10,2).size   = 40;
    formats(10,2).format = 'integer';
    formats(10,3).type = 'text';
    % filter selected movie choice
    formats(13,2).type = 'check';
    formats(14,2).type = 'check';
else
    % filter selected movie choice
    formats(10,2).type = 'check';
    formats(11,2).type = 'check';
end

% Default choices
DefAns.filter1 = mainhandles.settings.filterPairs.filter1;
DefAns.filter1frames = mainhandles.settings.filterPairs.filter1frames;
DefAns.filter1counts = mainhandles.settings.filterPairs.filter1counts;
DefAns.filter2 = mainhandles.settings.filterPairs.filter2;
DefAns.filter2dist = mainhandles.settings.filterPairs.filter2dist;
DefAns.filter3 = mainhandles.settings.filterPairs.filter3;
DefAns.filter3frames = mainhandles.settings.filterPairs.filter3frames;
DefAns.filterselected = mainhandles.settings.filterPairs.filterselected;
DefAns.permanentfilters = mainhandles.settings.filterPairs.permanentfilters;
if alex
    DefAns.filter4 = mainhandles.settings.filterPairs.filter4;
    DefAns.filter4frames = mainhandles.settings.filterPairs.filter4frames;
    DefAns.filter4counts = mainhandles.settings.filterPairs.filter4counts;
end

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)
    try FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
    catch err
        FRETpairwindowHandles = [];
    end
    return
end

%% Check answer

mainhandles.settings.filterPairs.filter1 = answer.filter1;
if answer.filter1frames<=0
    filter1frames = 1;
else
    filter1frames = answer.filter1frames;
end
if answer.filter1counts<0
    filter1counts = 0;
else
    filter1counts = answer.filter1counts;
end
if answer.filter2dist<1
    filter2dist = 1;
else
    filter2dist = answer.filter2dist;
end
if answer.filter3frames<0
    filter3frames = 0;
else
    filter3frames = answer.filter3frames;
end

if alex
    mainhandles.settings.filterPairs.filter4 = answer.filter4;
    if answer.filter4frames<=0
        filter4frames = 1;
    else
        filter4frames = answer.filter4frames;
    end
    if answer.filter4counts<0
        filter4counts = 0;
    else
        filter4counts = answer.filter4counts;
    end
end
%% Store new settings

mainhandles.settings.filterPairs.filter1frames = filter1frames;
mainhandles.settings.filterPairs.filter1counts = filter1counts;
mainhandles.settings.filterPairs.filter2 = answer.filter2;
mainhandles.settings.filterPairs.filter2dist = filter2dist;
mainhandles.settings.filterPairs.filter3 = answer.filter3;
mainhandles.settings.filterPairs.filter3frames = filter3frames;
mainhandles.settings.filterPairs.filterselected = answer.filterselected;
mainhandles.settings.filterPairs.permanentfilters = answer.permanentfilters;
if alex
    mainhandles.settings.filterPairs.filter4frames = filter4frames;
    mainhandles.settings.filterPairs.filter4counts = filter4counts;
end

%% Update

% Update mainhandles structure
updatemainhandles(mainhandles)

% Delete pairs according to specified criteria
[mainhandles, FRETpairwindowHandles] = filterPairs(mainhandles.figure1, mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);

% Remove filters again
if ~answer.permanentfilters
    mainhandles.settings.filterPairs.filter1 = 0;
    mainhandles.settings.filterPairs.filter2 = 0;
    mainhandles.settings.filterPairs.filter3 = 0;
    mainhandles.settings.filterPairs.filter4 = 0;
    updatemainhandles(mainhandles)
end
