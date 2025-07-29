function mainhandles = deleteRawDataCallback(mainhandles)
% Callback for delete raw movie data from the memory menu in the main
% window
%
%     Input:
%      mainhandles  - handles structure of the main window
%
%     Output:
%      mainhandles  - ..
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

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

%% Prepare dialog box

name = 'Delete raw data from RAM';

% Make files listbox string
fileslist = {};
for i = 1:length(mainhandles.data)
    filestring = sprintf('%i) %s',i,mainhandles.data(i).name);
    if ~isempty(mainhandles.data(i).imageData) && isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(raw)</b></HTML>', filestring); % Change string to HTML code
    elseif ~isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(raw,ROI)</b></HTML>',filestring);
    elseif ~isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && ~isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(raw,ROI,drift)</b></HTML>',filestring);
    elseif isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(ROI)</b></HTML>',filestring);
    elseif isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && ~isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(ROI,drift)</b></HTML>',filestring);
    elseif isempty(mainhandles.data(i).imageData) && isempty(mainhandles.data(i).DD_ROImovie) && ~isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(drift)</b></HTML>',filestring);
    elseif isempty(mainhandles.data(i).imageData) && isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
        filestring = sprintf('<HTML>%s <b>(empty)</b></HTML>',filestring);
    end
    
    fileslist{i,1} = filestring;
end

% Make prompt structure
prompt = {...
    'Select files:   ' 'filechoices';...
    'Delete the following items from the selected movies: ' '';...
    'Delete raw movies   ' 'deleteRaw';...
    'Delete ROI movies   ' 'deleteROI';...
    'Delete drift-corrected ROI movies   ' 'deleteDrift'};

% formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(1,1).type = 'list';
formats(1,1).style = 'listbox';
formats(1,1).items = fileslist;
formats(1,1).size = [500 300];
formats(1,1).limits = [0 2]; % multi-select
formats(3,1).type = 'text';
formats(4,1).type = 'check';
formats(5,1).type = 'check';
formats(6,1).type = 'check';

% Make DefAns structure
DefAns.filechoices = get(mainhandles.FilesListbox,'Value');
DefAns.deleteRaw = 1;
DefAns.deleteROI = 0;
DefAns.deleteDrift = 0;

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if cancelled==1 || (~answer.deleteRaw && ~answer.deleteROI && ~answer.deleteDrift)
    return
end

%% Delete data

size1 = whos('mainhandles'); % For calculating free'd RAM
for i = 1:length(answer.filechoices)
    filechoice = answer.filechoices(i);
    if answer.deleteRaw % Delete raw movies
        mainhandles.data(filechoice).imageData = [];
    end
    if answer.deleteROI % Delete ROI movies
        mainhandles.data(filechoice).DD_ROImovie = [];
        mainhandles.data(filechoice).AD_ROImovie = [];
        mainhandles.data(filechoice).AA_ROImovie = [];
        mainhandles.data(filechoice).DA_ROImovie = [];
    end
    if answer.deleteDrift % Delete drift-corrected ROI movies
        mainhandles.data(filechoice).DD_ROImovieDriftCorr = [];
        mainhandles.data(filechoice).AD_ROImovieDriftCorr = [];
        mainhandles.data(filechoice).AA_ROImovieDriftCorr = [];
        mainhandles.data(filechoice).DA_ROImovieDriftCorr = [];
    end
end

%% Update GUI

set(mainhandles.FramesListbox,'Value',1)
updatemainhandles(mainhandles)
updatefileslist(mainhandles.figure1, [], 'main')
updateframeslist(mainhandles)

% Update memory statusbar
mainhandles = updateMemorybar(mainhandles);

%% Show energy freed

size2 = whos('mainhandles');
saved = (size1.bytes-size2.bytes)*9.53674316*10^-7; % Memory difference before and after deletion /MB
set(mainhandles.mboard,'String',sprintf('%.1f MB RAM was released.',saved))

