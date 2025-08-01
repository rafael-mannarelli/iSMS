function dwhandles = createDynamicsGridFlex(dwhandles)
% Creates the resizable GUI elements in the dynamics window. The resize
% function is called dynamicsResizeFcn.m
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
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

% Color definitions
backgrColor = get(dwhandles.figure1,'Color'); % Background color
purpleColor = [2*101/255 2*90/255 1.5*159/255];
grayColor = [0.88 0.88 0.88];
whiteColor = [1 1 1];
lightblueColor = [0.75 0.9 1];
lightblueColor2 = [0.80 0.92 0.99];
lightblueColor3 = [0.90 0.94 0.99];
orangeColor = [255/255 229/255 11/255];

% Put a layout in the panel
VBoxFlex = uiextras.VBoxFlex( 'Parent', dwhandles.gridflexPanel, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );

%% Top side of GUI

HBoxFlexTop = uiextras.HBoxFlex( 'Parent', VBoxFlex, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );

% Top left part
VBoxFlexTopLeft = uiextras.VBoxFlex( 'Parent', HBoxFlexTop, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );

% Pair listbox
setappdata(0,'tooltipCloseString', 'Remove selected from list')
dwhandles.pairlistboxBoxPanel = uiextras.BoxPanel( ...
    'Parent', VBoxFlexTopLeft,...
    'Title', 'Traces analysed',...
    'BackgroundColor','white',...
    'TitleColor', lightblueColor2,...
    'CloseRequestFcn', {@dynamicswindowTraceDeleteFcn, dwhandles.figure1});%,...
dwhandles.PairListbox = uicontrol(...
    'Parent', dwhandles.pairlistboxBoxPanel,...
    'Style', 'listbox',...
    'String', '',...
    'max', 2,...
    'units', 'normalized',...
    'Tag', 'FilesListbox',...
    'Position', [0 0 1 1],...
    'BackgroundColor', 'white',...
    'Interruptible', 'off',...
    'Callback', {@dynamicswindowPairlistCallback, dwhandles.figure1});
boxpanelTR = uiextras.BoxPanel( ...
    'Parent', HBoxFlexTop,...
    'Title', 'Idealized trace ',...
    'BackgroundColor','white',...
    'TitleColor', lightblueColor2,...
    'Units', 'Normalized',...
    'Position',[0 0 1 1]);
dwhandles.TraceAxes = axes(...
    'Parent', boxpanelTR,...
    'Tag', 'TraceAxes',...
    'Color', 'white',...
    'Units', 'normalized',...
    'OuterPosition', [0 0 1 1]);

%% Lower side of GUI

HBoxFlexBottom = uiextras.HBoxFlex( 'Parent', VBoxFlex, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );

%% Left lower

% Top left part of lower side
VBoxFlexBottomLeft = uiextras.VBoxFlex( 'Parent', HBoxFlexBottom, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );

% State listbox
% setappdata(0,'tooltipMenuString', 'Rename data')
dwhandles.statelistboxBoxPanel = uiextras.BoxPanel( ...
    'Parent', VBoxFlexBottomLeft,...
    'Title', 'States',...
    'BackgroundColor',backgrColor,...
    'TitleColor', grayColor);
dwhandles.StateListbox = uicontrol(...
    'Parent', dwhandles.statelistboxBoxPanel,...
    'Style', 'listbox',...
    'String', '',...
    'units', 'normalized',...
    'max', 2,...
    'Tag', 'FilesListbox',...
    'Position', [0 0 1 1],...
    'BackgroundColor', 'white',...
    'Interruptible', 'off',...
    'Callback', {@dynamicswindowStatelistCallback, dwhandles.figure1});

% % % % Group listbox
% % % % setappdata(0,'tooltipMenuString', 'Rename data')
% % % dwhandles.grouplistboxBoxPanel = uiextras.BoxPanel( ...
% % %     'Parent', VBoxFlexBottomLeft,...
% % %     'Title', 'State groups',...
% % %     'BackgroundColor', backgrColor,...
% % %     'TitleColor', grayColor);
% % % %     'MenuFcn', {@filespanelMenuFcn, dwhandles.figure1},...
% % % dwhandles.GroupListbox = uicontrol(...
% % %     'Parent', dwhandles.grouplistboxBoxPanel,...
% % %     'Style', 'listbox',...
% % %     'String', '',...
% % %     'units', 'normalized',...
% % %     'Tag', 'GroupListbox',...
% % %     'Position', [0 0 1 1],...
% % %     'BackgroundColor', 'white',...
% % %     'max', 2,...
% % %     'Interruptible', 'off',...
% % %     'Callback', {@dynamicswindowStatelistCallback, dwhandles.figure1});

%% Right lower

VBoxFlexBottomRight = uiextras.VBoxFlex( 'Parent', HBoxFlexBottom, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );
boxpanelLR = uiextras.BoxPanel( ...
    'Parent', VBoxFlexBottomRight,...
    'Title', 'Plot info',...
    'TitleColor', grayColor);
uipanelLR = uipanel(...
    'Parent', boxpanelLR,...
    'Units', 'normalized',...
    'Position', [0 0 1 0.9]);

% Hist axes
uipanelLRL = uipanel(...
    'Parent', uipanelLR,...
    'BorderType', 'none',...
    'Units', 'normalized',...
    'BackgroundColor', 'white');%,...
%     'Position', [0 0 1 0.9]);%,...
dwhandles.HistAxes = axes(...
    'Parent', uipanelLRL,...
    'Tag', 'HistAxes',...
    'Color', 'white',...
    'units', 'normalized',...
    'OuterPosition', [0 0 1 1]);

% Top bar
uipanelLRT = uipanel(...
    'Parent', uipanelLR,...
    'Units', 'normalized',...
    'BorderType', 'none',...
    'Units', 'normalized',...
    'ResizeFcn', {@dynamicswindowHisttopbarResizeFcn, dwhandles.figure1},...
    'BackgroundColor', 'white');%,...
%     'Position', [0 0.9 1 0.1]);
% Popupmenu
listStr = {'Dwell times histogram (select states)';...
    'No. of states';...
    'Transition density plot (select traces)';...
    'FRET histogram (select states)';...
    'Mean dwell times scatter (select states)';...
    'Dwell times scatter (select states)'};
dwhandles.PlotPopupmenu = uicontrol(...
    'Parent', uipanelLRT,...
    'Style', 'popupmenu',...
    'String', listStr,...
    'units', 'normalized',...
    'Tag', 'PlotPopupmenu',...
    'BackgroundColor','white',...
    'Interruptible', 'off',...
    'Callback', {@dynamicswindowPopupmenuCallback, dwhandles.figure1});
% Slider
dwhandles.binSlider = uicontrol(...
    'Parent', uipanelLRT,...
    'Style', 'slider',...
    'TooltipString', 'Bins',...
    'Interruptible', 'off',...
    'Value', 10,...
    'max', 101,...
    'min', 1.0,...
    'sliderStep', [0.01 0.1],...
    'Tag', 'binSlider',...
    'BackgroundColor', backgrColor,...
    'Callback', {@dynamicswindowBinsliderCallback,dwhandles.figure1},...
    'units', 'normalized');
% Bin textbox
dwhandles.BinsTextbox = uicontrol(...
    'Style', 'text',...
    'Parent', uipanelLRT,...
    'Tag', 'BinsTextbox',...
    'BackgroundColor', get(uipanelLRT,'BackgroundColor'),...
    'ForegroundColor', abs([1 1 1]-get(uipanelLRT,'BackgroundColor')),...
    'String', 'Bins: 10',...
    'HorizontalAlignment', 'left',...
    'units', 'normalized');

% Store in handles
dwhandles.boxpanelTR = boxpanelTR;

dwhandles.uipanelLR = uipanelLR;
dwhandles.uipanelLRL = uipanelLRL;
dwhandles.uipanelLRT = uipanelLRT;
dwhandles.boxpanelLR = boxpanelLR;

%% Element sizes

VBoxFlex.Sizes = [-3 -5]; % Row sizes
HBoxFlexTop.Sizes = [-1 -4]; % Row sizes
HBoxFlexBottom.Sizes = [-1 -4]; % Column sizes

% intitialize positions
% set(uipanelLRT,'Position',[0 0.9 1 0.1])
set(dwhandles.PlotPopupmenu,'Position', [0 0.1 .7 0.9])
set(dwhandles.binSlider,'Position',[0.72 0.1 0.1 0.9])
set(dwhandles.BinsTextbox,'Position',[0.83 0.1 0.15 0.75])

% Update handles
guidata(dwhandles.figure1,dwhandles)

end

function dockFcn( hObject, eventData, mainhandle, whichpanel )
% Get box panel object
try  mainhandles = guidata(mainhandle);
    [boxPanel, parentFlex] = getwhichpanel();
catch err
    mainhandle = getappdata(0,'mainhandle');
    mainhandles = guidata(mainhandle);
    [boxPanel, parentFlex] = getwhichpanel();
end

% Set the flag
boxPanel.IsDocked = ~boxPanel.IsDocked;
if boxPanel.IsDocked
    % Put it back into the layout
    newfig = get( boxPanel, 'Parent' );
    set( boxPanel, 'Parent', parentFlex );
    delete( newfig );
else
    % Take it out of the layout
    pos = getpixelposition( boxPanel );
    newfig = figure( ...
        'Name', get( boxPanel, 'Title' ), ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'CloseRequestFcn', { @dockFcn, mainhandle, whichpanel} );
    updatelogo(newfig)
    figpos = get( newfig, 'Position' );
    set( newfig, 'Position', [figpos(1,1:2), pos(1,3:4)] );
    set( boxPanel, 'Parent', newfig, ...
        'Units', 'Normalized', ...
        'Position', [0 0 1 1] );
end

    function [boxPanel, parentFlex] = getwhichpanel(~)
        % Returns relevant handles to current object
        if strcmpi(whichpanel,'mboard')
            boxPanel = mainhandles.mboardBoxPanel;
            parentFlex =  mainhandles.VBoxFlexLeft;
            
        elseif strcmpi(whichpanel, 'peakfinder')
            boxPanel = mainhandles.peakfinderBoxPanel;
            parentFlex = mainhandles.HBoxFlexTopLeft;
        end
    end

end
