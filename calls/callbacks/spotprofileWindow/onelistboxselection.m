function [Rchoice,Gchoice] = onelistboxselection(handles,title,text,multi)
% Opens a modal dialog for selecting green and red profiles
% 
%    Input:
%     handles   - handles structure of the spot profile window
%     title     - title of the dialog
%     text      - text string of listbox
%     multi     - 'multi' if multiselection is allowed
%
%    Output:
%     Rchoice   - red filechoices
%     Gchoice   - green filechoices
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

if nargin<4
    multi = 'multi';
end

% Initialize
Rchoice = [];
Gchoice = [];

%% Loaded

reds = handles.red;
greens = handles.green;
if isempty(reds) && isempty(greens)
    return
elseif length(reds)==1 && isempty(greens)
    Rchoice = 1;
    return
elseif length(greens)==1 && isempty(reds)
    Gchoice = 1;
    return
end

if ~isempty(reds)
    plotsR = {reds(:).name};
    for i = 1:size(plotsR,2)
        plotsR{i} = sprintf('Red: %s',plotsR{i});
    end
else
    plotsR = cell(0);
end

if ~isempty(greens)
    plotsG = {greens(:).name};
    for i = 1:size(plotsG,2)
        plotsG{i} = sprintf('Green: %s',plotsG{i});
    end
else
    plotsG = cell(0);
end

plots = {plotsR{:}, plotsG{:}};

%%  Prepare choose plot dialog box

prompt = {text 'selection'};
name = title;

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = plots;
formats(2,1).size = [500 400];
if strcmp(multi,'multi')
    formats(2,1).limits = [0 2]; % multi-select
end
options.CancelButton = 'on';

% Default selection
selectedReds = get(handles.redListbox,'Value');
selectedGreens = get(handles.greenListbox,'Value');
if isempty(reds)
    defchoices = selectedGreens;
elseif ~isempty(reds) && ~isempty(selectedReds)
    defchoices = [selectedReds(:); length(reds)+selectedGreens(:)];
elseif ~isempty(reds) && isempty(selectedReds)
    defchoices = length(reds)+selectedGreens;
end

if strcmpi(multi,'multi')
    DefAns.selection = defchoices;
else
    DefAns.selection = defchoices(1);
end

%% Open dialog

[answer, cancelled] = myinputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if cancelled == 1
    return
end

%% Interpret selected data from dialog box

for i = 1:length(answer.selection)
    if (~isempty(reds)) && (answer.selection(i)<=length(reds))
        Rchoice(end+1) = answer.selection(i);
    elseif (isempty(reds))
        Gchoice(end+1) = answer.selection(i);
    elseif (~isempty(reds)) && (answer.selection(i)>length(reds))
        Gchoice(end+1) = answer.selection(i)-length(reds);
    end
end
