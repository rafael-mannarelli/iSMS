function spHandles = renameSpotDataCallback(spHandles)
% Callback for renaming data in the spot profile window
%
%    Input:
%     spHandles   - handles structure of the spot profile window
%
%    Output:
%     spHandles   - ...
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

% Get data
reds = spHandles.red;
greens = spHandles.green;

% If there is no data loaded
if (isempty(reds)) && (isempty(greens))
    return
end

% Open selection dialog if there are too many spectra
if length(reds)+length(greens)>=15
    [Rchoice,Gchoice] = onelistboxselection(spHandles,'Rename spectra','Select spectra to rename: ');
    red_select = reds(Rchoice);
    green_select = greens(Gchoice);
else
    red_select = reds;
    green_select = greens;
    Rchoice = 1:length(reds);
    Gchoice = 1:length(greens);
end

if isempty(Rchoice) && isempty(Gchoice)
    return
end
   
%% Prepare dialog box

name = 'Rename data';

% Make prompt structure
prompt = {'Red profiles:' ''};
for i = 1:length(red_select)
    % Replace all '_' with '\_' to avoid toolbar_legend subscripts
    n = red_select(i).name;
    run = 0;
    for k = 1:length(n)
        run = run+1;
        if n(run)=='_'
            n = sprintf('%s\\%s',n(1:run-1),n(run:end));
            run = run+1;
        end
    end
    prompt{end+1,1} = sprintf('%s:',n);
    prompt{end,2} = sprintf('red%i',i);
end
if ~isempty(green_select)
    prompt{end+1,1} = 'Green profiles:';
    prompt{end,2} = '';
    for i = 1:length(green_select)
        % Replace all '_' with '\_' to avoid toolbar_legend subscripts
        n = green_select(i).name;
        run = 0;
        for k = 1:length(n)
            run = run+1;
            if n(run)=='_'
                n = sprintf('%s\\%s',n(1:run-1),n(run:end));
                run = run+1;
            end
        end
        prompt{end+1,1} = sprintf('%s:',n);
        prompt{end,2} = sprintf('green%i',i);
    end
end

% Make formats structure
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(1,1).type   = 'text';
for i = 1:length(red_select)
    formats(end+1,1).type   = 'edit';
end
if ~isempty(green_select)
    formats(end+1,1).type = 'text';
    for i = 1:length(green_select)
        formats(end+1,1).type   = 'edit';
    end
end

% Make DefAns 
DefAns = [];
for i = 1:length(red_select)
    DefAns.(sprintf('red%i',i)) = red_select(i).name;
end
if ~isempty(green_select)
    for i = 1:length(green_select)
        DefAns.(sprintf('green%i',i)) = green_select(i).name;
    end
end

% Open dialog box
[answer, cancelled] = myinputsdlg(prompt, name, formats, DefAns); 
if cancelled == 1
    return
end

%% Rename data

for i = 1:length(red_select)
    reds(Rchoice(i)).name = answer.(sprintf('red%i',i));
end
if ~isempty(green_select)
    for i = 1:length(green_select)
        greens(Gchoice(i)).name = answer.(sprintf('green%i',i));
    end
end

%% Update

spHandles.green = greens;
spHandles.red = reds;
guidata(spHandles.figure1,spHandles);

updateprofilesListbox(spHandles)
