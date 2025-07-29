function mainhandles = excorderCallback(mainhandles)
% Callback for settings excitation order in the main window
%
%     Input:
%      mainhandles   - handles structure of the mainw window
%
%     Output:
%      mainhandles   - ..
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

if nargin<1
    mainhandles = guidata(getappdata(0,'mainhandle'));
end

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% Open dialog
if mainhandles.settings.excitation.alex
    [mainhandles files] = alexDlg(mainhandles);
else
    [mainhandles files] = scDlg(mainhandles);
end

if isempty(files)
    return
end

%% Update GUI

updatemainhandles(mainhandles)
updateframeslist(mainhandles)
mainhandles = updateavgimages(mainhandles,'all',files);
mainhandles = updaterawimage(mainhandles);
mainhandles = updateframesliderHandle(mainhandles);
mainhandles = updateROIhandles(mainhandles);
mainhandles = updateROIimage(mainhandles);
mainhandles = updatepeakplot(mainhandles,'both');

end

function [mainhandles, files] = alexDlg(mainhandles)
files = [];

%% Prepare dialog box

name = 'Excitation';

% Make prompt structure
prompt = {...
    sprintf('In ALEX, the excitation scheme goes as ''...DADADADA...''.\n\nTo use single-color excitation activate this setting in the ''Excitation order'' menu.') '';...
    'Select files: ' 'files';...
    'First excitation frame in ALEX: ' 'FirstFrame'};

% formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type = 'text';
formats(4,1).type = 'list';
formats(4,1).style = 'listbox';
formats(4,1).items = getfileslistStr(mainhandles);
formats(4,1).limits = [0 2];
formats(4,1).size = [350 200];
formats(6,1).type = 'list';
formats(6,1).style = 'popupmenu';
formats(6,1).items = {'Green (D)   ' 'Red (A)   '};

% Make DefAns structure
file = get(mainhandles.FilesListbox,'Value');
DefAns.files = file;
if strcmp(mainhandles.data(file).excorder(1),'D')
    DefAns.FirstFrame = 1;
else
    DefAns.FirstFrame = 2;
end

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if cancelled == 1
    return
end

files = answer.files;

%% Interpret

for i = 1:length(files)
    file = files(i);
    filelength = length(mainhandles.data(file).excorder);
    
    % Update excitation order
    if filelength==1
        if answer.FirstFrame==1
            mainhandles.data(file).excorder = 'D';
        else
            mainhandles.data(file).excorder = 'A';
        end
        
    elseif isodd(filelength)
        % Odd number of frames
        if answer.FirstFrame==1
            mainhandles.data(file).excorder = repmat('DA',1,filelength/2-1);
        else
            mainhandles.data(file).excorder = repmat('AD',1,filelength/2-1);
        end

    else
        % Normal file
        if answer.FirstFrame==1
            mainhandles.data(file).excorder = repmat('DA',1,filelength/2);
        else
            mainhandles.data(file).excorder = repmat('AD',1,filelength/2);
        end
    end
    
end

% %------ Make choices happen -----%
% if answer.AllFiles == 1
%     files = 1:length(mainhandles.data);
% elseif answer.AllFiles == 2
%     files = get(mainhandles.FilesListbox,'Value');
% end
% 
% Ds = answer.Ds;
% As = answer.As;
% for i = files(:)'
%     
%     % Check if raw movie has been deleted
%     if isempty(mainhandles.data(i).imageData)
%         choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload it from file?',mainhandles.data(i).name),...
%             'Movie deleted',...
%             'Yes','No','No');
%         if strcmp(choice,'Yes')
%             mainhandles = reloadMovieCallback(mainhandles);
%             return
%         elseif strcmp(choice,'No')
%             return
%         end
%     end
%     
%     n = size(mainhandles.data(i).imageData,3);
%     excorder = mainhandles.data(i).excorder;
%     run = 1;
%     if answer.FirstFrame == 1
%         DA = 'D';
%     elseif answer.FirstFrame == 2
%         DA = 'A';
%     end
%     
%     while run <= length(excorder)
%         if strcmp(DA,'D')
%             excorder(run:run+Ds-1) = char(ones(1,Ds)*'D');
%             run = run+Ds;
%             DA = 'A';
%         elseif strcmp(DA,'A')
%             excorder(run:run+As-1) = char(ones(1,As)*'A');
%             DA = 'D';
%             run = run+As;
%         end
%     end
%     
%     mainhandles.data(i).excorder = excorder;
% end

end

function [mainhandles, files] = scDlg(mainhandles)

files = [];

% Initialize
exc = [];
file = get(mainhandles.FilesListbox,'Value');

% Prepare dialog
name = 'Excitation';
formats = prepareformats();
prompt = {sprintf('Setting for single-color excitation. \n\nTo use ALEX scheme activate this setting in the ''Excitation order'' menu.') '';...
    'Select files: ' 'files';...
    'Excitation source of selected files: ' 'exc'};

formats(2,1).type = 'text';
formats(4,1).type = 'list';
formats(4,1).style = 'listbox';
formats(4,1).items = getfileslistStr(mainhandles);
formats(4,1).limits = [0 2];
formats(4,1).size = [350 200];
formats(6,1).type = 'list';
formats(6,1).style = 'popupmenu';
formats(6,1).items = {'Green (D)      '; 'Red (A)  '};

% Default
DefAns.files = get(mainhandles.FilesListbox,'Value');
excin = unique(mainhandles.data(file).excorder);
if length(excin)==1 && strcmpi(excin,'A')
    DefAns.exc = 2;
else
    DefAns.exc = 1;
end

% Dialog
[answer cancelled] = myinputsdlg(prompt,name,formats,DefAns);
if cancelled
    return
end

files = answer.files;

% Interpret
if answer.exc==1
    exc = 'D';
else
    exc = 'A';
end

% Update
for i = 1:length(files)
    file = files(i);
    filelength = length(mainhandles.data(file).excorder);
    
    % Excitation order
    mainhandles.data(file).excorder = char(ones(1,filelength)*exc);
    
end
end