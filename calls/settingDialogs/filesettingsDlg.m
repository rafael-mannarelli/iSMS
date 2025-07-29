function filesettingsDlg(mainhandles)
% Callback for file settings dialog
%
%    Input:
%     mainhandles    - handles structure of the main window
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

if isempty(mainhandles.data)
    set(mainhandles.mboard,'String','No data loaded.')
    return
end

% Green spot profiles
Gspots = getFiles(mainhandles,'Gspot');
Gstr = {'-'};
if ~isempty(Gspots)
    for i = 1:length(Gspots)
        Gstr{i+1} = sprintf('File %i',Gspots(i));
    end
end

% Red spot profiles
Rspots = getFiles(mainhandles,'Rspot');
Rstr = {'-'};
if ~isempty(Rspots)
    for i = 1:length(Rspots)
        Rstr{i+1} = sprintf('File %i',Rspots(i));
    end
end

%% Initialize table

% Data table properties
columns = {...
    'Name', 'char', 140, true;... % Name, type, width, editable
    'Path', 'char', 250, false;...
    'Mem.', 'char', 60, false;...
    'Backgr.', 'char', 55, false;...
    'Raw size', 'char', 85, false;...
    'ms/frame', 'char', 65, true;...
    'Pairs', 'numeric', 45, false;...
    'Exc.' 'char', 40, false;...
    'G profile', Gstr, 55, true;...
    'R profile', Rstr, 55, true;...
    'Profile', {'No' 'G' 'R'}, 48, true};

if ~mainhandles.settings.excitation.alex
    columns{8,2} = {'D' 'A'};
    columns{8,4} = true;
end

% Data for table
data = {};
for i = 1:length(mainhandles.data)
    
    data{i,1} = mainhandles.data(i).name;
    data{i,2} = getfulldir(mainhandles.data(i).filepath);
    data{i,3} = ByteSize(mainhandles.data(i));
    data{i,4} = getCameraBack(mainhandles.data(i).cameraBackground);
    data{i,5} = sprintf('%ix%ix%i',size(mainhandles.data(i).avgimage,1),size(mainhandles.data(i).avgimage,2),mainhandles.data(i).rawmovieLength);
    data{i,6} = num2str(mainhandles.data(i).integrationTime);
    data{i,7} = length(mainhandles.data(i).FRETpairs);
    
    % Excitation scheme
    if mainhandles.settings.excitation.alex
        data{i,8} = 'ALEX';
    else
        data{i,8} = mainhandles.data(i).excorder(1);
    end
    
    % Spots
    data{i,9} = assSpot('G');
    data{i,10} = assSpot('R');
    
    if mainhandles.data(i).spot==1
        data{i,11} = 'G';
    elseif mainhandles.data(i).spot==2
        data{i,11} = 'R';
    else
        data{i,11} = 'No';
    end
end

%% Initialize figure

h.figure1 = dialog(...
    'Name',     'File settings',...
    'Units',    'normalized',...
    'Visible',  'off',...
    'Resize',   'on',...
    'UserData', 'Cancel');

% Create table
h.table = uitable('Parent',h.figure1,...
    'ColumnName', columns(:,1)',...
    'ColumnFormat', columns(:,2)',...
    'ColumnWidth', columns(:,3)',...
    'ColumnEditable', [columns{:,4}],...
    'RearrangeableColumns', 'off',...
    'Data', data,...
    'units','normalized',...
    'position',[0 0 1 1]);
%     'RowName', namestr,...
% 'ColumnFormat', {'char', 'logical', 'logical', 'numeric', {'one' 'two' 'three'}},...

%-- OK pushbutton --%
h.OKpushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'OK',...
    'Style',    'pushbutton');

%-- Cancel pushbutton --%
h.CancelPushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'Cancel',...
    'Style',    'pushbutton'...
    );

%% Position

set(h.figure1,'ResizeFcn',{@fResizeFcn, h})

fResizeFcn([],[],h)
guiwidth = 1100;
guiheight = 350;
setpixelposition(h.figure1,[1 1 guiwidth guiheight])
movegui(h.figure1,'center') % Centerize
updatelogo(h.figure1) % Update logo

%% Callbacks

set(h.OKpushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback
set(h.CancelPushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback

%% Update dialog

guidata(h.figure1,h)
set(h.figure1,'Visible','on')

%% Go into uiwait if the figure handle is still valid.

if ishghandle(h.figure1)
    uiwait(h.figure1);
end

%% This code hereafter is only run once uiresume is called

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
if ishghandle(h.figure1)
    if strcmp(get(h.figure1,'UserData'),'OK')
        
        % Return data
        answer = get(h.table,'data');
        
        % Check if excitation order has been changed for files with pairs
        for i = 1:length(mainhandles.data)
            if ~isequal(answer{i,8},data{i,8}) && ~isempty(mainhandles.data(i).FRETpairs)
                % Sure dialog
                choice = myquestdlg(sprintf('You have selected a new excitation scheme of files with FRET pairs.\nThis will delete the FRET pairs of these files. \n\n Continue?'),...
                    'Are you sure?','Continue','Cancel','Cancel');
                
                % Return
                if isempty(choice) || strcmpi(choice,'Cancel')
                    try delete(h.figure1); end
                    return
                end
                break
            end
        end
        
        % New settings
        ok = 0;
        for i = 1:length(mainhandles.data)
            % New name
            mainhandles.data(i).name = answer{i,1};
            
            % Time
            if ~isequal(answer{i,6},data{i,6})
                mainhandles.data(i).integrationTime = str2num(answer{i,6});
                mainhandles = createTimeVector(mainhandles,i);
                
                % Ok to close all windows
                ok = 1;
            end
            
            % Excitation order
            if ~isequal(answer{i,8},data{i,8})
                % New excitation
                mainhandles.data(i).excorder = repmat(answer{i,8},1,length(mainhandles.data(i).excorder));
                
                % Clear peaks and FRET pairs
                mainhandles = clearpeaksdata(mainhandles,i);
                mainhandles = resetPeakSliders(mainhandles,i);
                updateframeslist(mainhandles)
                
                % Ok to close all windows
                ok = 1;
            end
            
            % Associated spot profiles
            mainhandles.data(i).GspotProfile = assSpot2(answer{i,end-2});
            mainhandles.data(i).RspotProfile = assSpot2(answer{i,end-1});
            
            % Spot
            if strcmpi(answer{i,end},'G')
                mainhandles.data(i).spot = 1;
            elseif strcmpi(answer{i,end},'R')
                mainhandles.data(i).spot = 2;
            else
                mainhandles.data(i).spot = 0;
            end
            
        end
        
        % Update
        updatemainhandles(mainhandles)
        updatefileslist(mainhandles.figure1)
        
        % Close windows
        if ok
            mainhandles = closeWindows(mainhandles);
        end
    end
    try delete(h.figure1); end
else
    return
end

%% Nested

    function str = assSpot(type)
        idx = getAssocSpotfile(mainhandles,i,type);
        if ~isempty(idx)
            str = sprintf('File %i',idx);
        else
            str = '-';
        end
    end

    function img = assSpot2(choice)
        if length(choice)>5
            idx = str2num(choice(6:end));
            img = mainhandles.data(idx).avgimage;
        else
            img = [];
        end
    end
end

function dir = getfulldir(filepaths)
% All paths
% [dir name ext] = fileparts(filepaths{1});
if ~iscell(filepaths)
    filepaths = {filepaths};
end

dir = filepaths{1};
if length(filepaths)>1
    for j = 2:length(filepaths)
        dir = sprintf('%s; %s',dir, filepaths{j});
    end
end
end

function backs = getCameraBack(cb)
backs = 'empty';
if isempty(cb)
    return
end
if ~iscell(cb)
    cb = {cb};
end

% Return backs as string
backs = returnBack(cb{1});
for j = 2:length(cb)
    backs = sprintf('%s; %s',backs,returnBack(cb{j}));
end

    function b = returnBack(in)
        if isempty(in)
            b = 'empty';
        elseif size(in,1)==1 && size(in,2)==1
            b = sprintf('%i',in);
        else
            b = 'image';
        end
    end
end

function fResizeFcn(hObject,event,h)
GUIdimensions;

fpos = getpixelposition(h.figure1);
setpixelposition(h.OKpushbutton, [fpos(3)-rightspace-buttonwidth bottomspace buttonwidth buttonheight])
setpixelposition(h.CancelPushbutton, [fpos(3)-2*rightspace-2*buttonwidth bottomspace buttonwidth buttonheight])

vpos = bottomspace+buttonheight+verspace;
setpixelposition(h.table, [1 vpos fpos(3) fpos(4)-vpos])
end

function pushbutton_Callback(hObject,eventdata,h) %%
if ~strcmp(get(hObject,'String'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end

end

