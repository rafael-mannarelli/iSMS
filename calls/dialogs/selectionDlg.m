function choices = selectionDlg(mainhandles,title,text,choice) 
% Creates a dialog for choosing datasets and returns choices: 
% the selected movie file indices (if choice='file'), or
% the selected molecule indices [file, pair;...] if choice = 'pair'
%
%    Input:
%     mainhandles - mainhandles structure
%     title       - title of dialog
%     text        - text in dialog
%     choice      - 'file', 'pair'. If pair function returns pairs as [file pair;..]
%
%    Output:
%     choices     - selected data
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

% Defaults
choices = [];
if isempty(mainhandles.data)
    return
end
if nargin<4
    choice = 'file';
end

%% Prepare dialog box

%--------- Get plots ---------%
if strcmpi(choice,'file')
    listitems = {mainhandles.data(:).name};
else
    allPairs = getPairs(mainhandles.figure1, 'all');
    listitems = cell(size(allPairs,1),1);
    for j = 1:size(allPairs,1)
        listitems{j} = sprintf('%i,%i', allPairs(j,1), allPairs(j,2)); % Change listbox string
    end
end
%-------------------------------------%

%--- Prepare choose plot dialog box ----%
prompt = {text 'selection'};
name = title;

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = listitems;
formats(2,1).size = [200 300];
formats(2,1).limits = [0 2]; % multi-select

if strcmpi(choice,'file')
    DefAns.selection = get(mainhandles.FilesListbox,'Value');
elseif strcmpi(choice,'pair')
    try
        selectedPairs = getPairs(mainhandles.figure1,'Selected',[],mainhandles.FRETpairwindowHandle);
        [~, idx] = ismember(selectedPairs,allPairs,'rows','legacy');
        DefAns.selection = idx;
    catch err
        DefAns.selection = 1:length(listitems);
    end
else
    DefAns.selection = 1:length(listitems);
end
options.CancelButton = 'on';

%% Open dialog

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if cancelled == 1
    return
end

selection = {listitems{answer.selection}}';
if isempty(selection)
    return
end

%% Interpret selected data from dialog box

if strcmpi(choice,'file')
    choices = answer.selection;
else
    choices = allPairs(answer.selection,:);
end
