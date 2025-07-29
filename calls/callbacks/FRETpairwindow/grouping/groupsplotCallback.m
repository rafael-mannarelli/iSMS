function mainhandles = groupsplotCallback(fpwHandles)
% Callback for plotting group distribution in FRET pair window
%
%    Input:
%     fpwHandles   - handles structure of the FRETpair window
%
%    Output:
%     mainhandles  - handles structure of the main window
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
    fpwHandles = guidata(mainhandles.FRETpairwindowHandle);
end

% Get mainhandles
mainhandles = getmainhandles(fpwHandles);
if isempty(mainhandles) || isempty(mainhandles.data)
    return
end

% Number of groups
ngroups = length(mainhandles.groups);

%% Dialog

% Prepare
prompt = {'Select groups to include: ' 'groupchoices';...
    'Plot type: ' 'plottype';...
    'Show percentage values in plot' 'showvalues';...
    'Color according to group color' 'color'};
name = 'Distribution plot';

groupString = getgroupString(mainhandles,fpwHandles.figure1);
formats = prepareformats();
formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = groupString;
formats(2,1).limits = [0 2];
formats(2,1).size = [250 150];
formats(2,2).type = 'list';
formats(2,2).style = 'popupmenu';
formats(2,2).items = {'Bar plot' 'Pie plot'};
formats(2,2).limits = [0 1];
formats(2,2).size = 100;
formats(3,1).type = 'check';
formats(4,1).type = 'check';

% Def. answers
DefAns.groupchoices = 1:ngroups;
DefAns.plottype = mainhandles.settings.grouping.distplottype;
DefAns.showvalues = mainhandles.settings.grouping.distplotShowvalues;
DefAns.color = mainhandles.settings.grouping.distplotColor;

% Open dialog
[answer cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled || isempty(answer.groupchoices)
    return
end

% Save default
mainhandles.settings.grouping.distplottype = answer.plottype;
mainhandles.settings.grouping.distplotShowvalues = answer.showvalues;
mainhandles.settings.grouping.distplotColor = answer.color;

% Choices
groupchoices = answer.groupchoices;
ngroups = length(groupchoices);

%% Prepare data for distribution plot

% Total number of pairs
allPairs = getPairs(mainhandles.figure1,'all');
npairs = size(allPairs,1);

% Get data
data = zeros(ngroups,1);
for i = 1:length(groupchoices)
    group = groupchoices(i);
    
    % All pairs in group
    groupPairs = getPairs(mainhandles.figure1,'group',group);
    
    % Ratio to total number of pairs
    data(i) = size(groupPairs,1)/npairs*100;
end

%% Plot

% Initialize figure
fh = figure;
updatelogo(fh)
set(fh,'name','Group distribution plot')
ax = gca;

% Plot bars in different colors
if answer.plottype==1
    
    % Bar plot of all groups in different colors (hence the for loop)
    for i = 1:ngroups
        
        % Plot
        if mainhandles.settings.grouping.distplotColor
            h = bar(i,data(i), 'facecolor',mainhandles.groups(groupchoices(i)).color/255);
        else
            h = bar(i,data(i));
        end
        
        if i==1
            hold on
        end
    end
    
    % Axes
    ylabel(ax,'% of molecules')
    
    % VERSION DEPENDENT SYNTAX
    if mainhandles.matver<8.3
        xlabel(ax,1:ngroups)%{mainhandles.groups(groupchoices).name})
        set(ax, 'XTickLabelRotation', 45);
    else
        xticklabel_rotate(1:ngroups,45,{mainhandles.groups(groupchoices).name});
    end
    gridxy([],[0 20 40 60 80 100],'Color','k','Linestyle',':') ;
    
    % Set y lims
    if max([data(:)])>40
        ylim([0 100])
    end
    
    % Bar labels
    if mainhandles.settings.grouping.distplotShowvalues
        for i = 1:length(data)
            text(i,data(i)+1, sprintf('%.2f%%',data(i)),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom',...
                'BackgroundColor', 'white')
        end
    end
    
elseif answer.plottype==2
    
    % Names
    str = {mainhandles.groups(groupchoices).name};
    
    % Add percentage values
    if mainhandles.settings.grouping.distplotShowvalues
        for i = 1:length(str)
            str{i} = sprintf('%s (%.2f%%)',str{i},data(i));
        end
    end
    
    % Pie plot
    h = pie(ax,data,str);
    
    % Set colors
    if mainhandles.settings.grouping.distplotColor
        hp = findobj(h, 'Type', 'patch');
        for i = 1:length(hp)
            set(hp(i), 'FaceColor', mainhandles.groups(groupchoices(i)).color/255);
        end
    end
    
    % Show warning
    if npairs~=sum(data/100*npairs)
        mymsgbox('Warning: When molecules belong to more than one group, the pie plot represents group-relative fractions. You should use the bar plot instead.')
    end
end

% UI context menu
updateUIcontextMenus(mainhandles.figure1,ax)

% Store figure handle in handles structure so it is deleted when closing
mainhandles.figures{end+1} = fh;
updatemainhandles(mainhandles)
