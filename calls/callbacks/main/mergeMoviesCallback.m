function mainhandles = mergeMoviesCallback(mainhandles, defG, defR)
% Callback for merging two movies
%
%     Input:
%      mainhandles  - handles structure of the main window
%      defG         - default green choice
%      defR         - default red choice
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

mainhandles = turnofftoggles(mainhandles,'all'); % Turn off all interactive toggle buttons in the toolbar
if length(mainhandles.data)<2  % If less than two files are loaded
    mymsgbox('Load at least two movies before merging','iSMS');
    return
end

% Default
if nargin<2
    defG = [];
end
if nargin<3
    defR = [];
end

%% Prepare dialog box

name = 'Merge files';

% Make prompt structure
prompt = {'File 1: ' 'file1';...
    'File 2: ' 'file2';...
    'Delete files after merging (will also delete FRET-pairs)' 'delete'};

% Make formats structure
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = {mainhandles.data(:).name}';
formats(2,1).size = [300 300];
formats(2,1).limits = [0 1]; % multi-select
formats(2,2).type = 'list';
formats(2,2).style = 'listbox';
formats(2,2).items = {mainhandles.data(:).name}';
formats(2,2).size = [300 300];
formats(2,2).limits = [0 1]; % multi-select
formats(4,2).type   = 'check';

if isempty(defG)
    DefAns.file1 = get(mainhandles.FilesListbox,'Value');
else
    DefAns.file1 = defG;
end
if isempty(defR)
    if DefAns.file1<length(mainhandles.data)
        DefAns.file2 = get(mainhandles.FilesListbox,'Value')+1;
    elseif DefAns.file1>1
        DefAns.file2 = get(mainhandles.FilesListbox,'Value')-1;
    else
        DefAns.file2 = 1;
    end
else
    DefAns.file2 = defR;
end
DefAns.delete = 0;

%% Open dialog box

[answer, cancelled] = myinputsdlg(prompt, name, formats, DefAns);
if cancelled == 1
    return
end

%% Check answer

% Check if same file was selected twice
file1 = answer.file1;
file2 = answer.file2;
data1 = mainhandles.data(file1).imageData;
data2 = mainhandles.data(file2).imageData;
% if file1==file2
%     myquestdlg('You must select two different files','iSMS',...
%         'OK','OK');
%     mainhandles = mergeMoviesCallback(mainhandles);
%     return
% end

% Check if sizes are equal
file1size = size(data1);
file2size = size(data2);
if ~isequal(file1size(1:2),file2size(1:2))
    
    % Dialog
    mymsgbox(sprintf('The selected movies are not of equal sizes:\n\n %s  is:  %i*%i pixels.\n %s  is:  %i*%i pixels.\n',...
        mainhandles.data(file1).name, file1size(1), file1size(2), mainhandles.data(file2).name, file2size(1), file2size(2)),'iSMS');
    return
end

%% Perform merging

data.imageData =  cat(3, data1, data2);
filename = sprintf('Merged: %s -and- %s', mainhandles.data(file1).name, mainhandles.data(file2).name);
filepath = mainhandles.data(file1).filepath;
if iscell(mainhandles.data(file2).filepath)
    for i = 1:size(mainhandles.data(file2).filepath)
        filepath{end+1,1} = mainhandles.data(file2).filepath{i};
    end
else
    filepath{end+1,1} = mainhandles.data(file2).filepath;
end

%% Store

mainhandles = storeMovie(mainhandles,data,filename,filepath,0);

% Keep same excorder
mainhandles.data(end).excorder = [mainhandles.data(file1).excorder mainhandles.data(file2).excorder];

% Merge backgrounds and geometrical transformations
cameraBackground = mainhandles.data(file1).cameraBackground;
for i = 1:size(mainhandles.data(file2).cameraBackground,1)
    cameraBackground{end+1,1} = mainhandles.data(file2).cameraBackground{i};
end
mainhandles.data(end).cameraBackground = cameraBackground;

geoTransformations = mainhandles.data(file1).geoTransformations;
for i = 1:size(mainhandles.data(file2).geoTransformations,2)
    geoTransformations{1,end+1} = mainhandles.data(file2).geoTransformations{1,i};
end
mainhandles.data(end).geoTransformations = geoTransformations;

% Delete the two previous files
if answer.delete
    mainhandles.data([file1 file2]) = [];
end

%% Update GUI

set(mainhandles.FilesListbox,'Value',length(mainhandles.data))
updatemainhandles(mainhandles)
updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)
mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in files listbox

%% Check memory:

if ~ismac
    [userview systemview] = memory;
    MB = userview.MemAvailableAllArrays*9.53674316*10^-7;
    if MB<1000
        set(mainhandles.mboard,'String',sprintf(...
            '%s\n%s %.0f %s\n%s',...
            'Warning: More RAM needed!',...
            'There is currently only',MB,'MB of memory available for iSMS.',...
            'You may experience slowness and other memory-related problems if not deleting some raw data.'))
    end
end
