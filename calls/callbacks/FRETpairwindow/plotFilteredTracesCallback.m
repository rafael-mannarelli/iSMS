function mainhandles = plotFilteredTracesCallback(fpwHandles)
% Callback for plot filtered traces in the FRET pair window
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
mainhandles = getmainhandles(fpwHandles);
selectedPairs = getPairs(fpwHandles.main,'Selected',[],fpwHandles.figure1);
if size(selectedPairs,1)~=1
    mymsgbox('Please select a single FRET-pair for the plot.')
    return
end
file = selectedPairs(1,1);
pair = selectedPairs(1,2);
datalength = length(mainhandles.data(file).FRETpairs(pair).DDtrace);

%% Plot
axs = [fpwHandles.DDtraceAxes fpwHandles.ADtraceAxes fpwHandles.AAtraceAxes...
    fpwHandles.StraceAxes fpwHandles.PRtraceAxes];

h.mainhandle = fpwHandles.main;
h.fh = figure('Name',sprintf('Filtered: (%i,%i)',file,pair),...
    'MenuBar','none', 'Color',[1 1 1],...
    'Visible','off',...
    'Position',[1 1 800 500]);
updatelogo(h.fh)

h.axs = struct('ax',[],'raw',[],'filt',[]); h.axs(:) = [];
for i = 1:5

    % Copy axes
    ax = subplot(5,1,i);
    copyaxs(axs(i),ax)
    set(ax,'Units','pixels')
    h.axs(i).ax = ax;
    
    % Initialize data
    data = get(ax,'children');
    for j = 1:length(data)
        if ~strcmp(class(data(j)), 'matlab.graphics.chart.primitive.Line');
            break
        end
        x = get(data(j),'XData');
        if length(x)==datalength
            if isempty(h.axs(i).raw)
                h.axs(i).raw = data(j);
            else
                h.axs(i).raw(end+1) = data(j);
            end
            
            y = get(data(j),'YData');
%             y = filtfilt(filterSettings,y);
            
            hold(ax,'on')
            ph = plot(ax,x,y,'LineWidth',2, 'Color',[0 0 0]);
            if isempty(h.axs(i).filt)
                h.axs(i).filt = ph;
            else
                h.axs(i).filt(end+1) = ph;
            end 
        end
    end
    
    updateUIcontextMenus(fpwHandles.main,ax)
end

%% Add controls
h.typeText = uicontrol('Parent',h.fh, 'Style','text',...
    'String','Filter type: ', 'HorizontalAlignment','right', 'BackgroundColor',[1 1 1]);
h.typePopup = uicontrol('Parent',h.fh, 'Style','popup', ...
    'String',{'Zero-phase infinite impulse response (IIR) lowpass filter'; 'Median filter'}, 'Value',mainhandles.settings.filtering.type);

h.foText = uicontrol('Parent',h.fh, 'Style','text',...
    'String','Filter order: ', 'HorizontalAlignment','right', 'BackgroundColor',[1 1 1]);
[h.foSpinner, h.foSpinnerContainer] = javacomponent('javax.swing.JSpinner',[],h.fh);
h.hpfText = uicontrol('Parent',h.fh, 'Style','text',...
    'String','Half power frequency: ' , 'HorizontalAlignment','right', 'BackgroundColor',[1 1 1]);
[h.hpfSpinner, h.hpfSpinnerContainer] = javacomponent('javax.swing.JSpinner',[],h.fh);
setModel(h.hpfSpinner, javax.swing.SpinnerNumberModel(mainhandles.settings.filtering.hpf, 0.01, 100, 0.01))

h.plotrawCheck = uicontrol('Parent',h.fh, 'Style','check',...
    'String','Plot raw traces', 'Value',mainhandles.settings.filtering.plotraw, 'BackgroundColor',[1 1 1]);

h.infoPushbutton = uicontrol('Parent',h.fh, 'Style','Pushbutton', ...
    'String','More information', 'Callback', 'myopenURL(''http://isms.au.dk/documentation/filtering-traces/'')');

%% Update
set(h.fh,'ResizeFcn',{@figresizefcn,h})
set([h.foSpinner h.hpfSpinner],'StateChangedCallback',{@updateFilterPlot,h})
set(h.plotrawCheck, 'Callback',{@updatePlotRaw,h})
set(h.typePopup,'Callback',{@updateType,h})
updateType([],[],h)
movegui(h.fh,'center')
set(h.fh,'Visible','on')
figresizefcn([],[],h)

%% Save

mainhandles.figures{end+1} = h.fh;
updatemainhandles(mainhandles)

function figresizefcn(hFig,event,h)
% Dimensions
GUIdimensions
figPos = getpixelposition(h.fh);
spinH = 22;
leftW = 120;
rightW = 100;
vpos = figPos(4)-topspace-popupheight;

% Controls
set(h.typeText, 'Position',[leftspace vpos leftW textheight]);
set(h.typePopup, 'Position',[leftspace+horspace+leftW vpos rightW popupheight])
vpos = vpos-verspace-spinH;
set(h.foText, 'Position',[leftspace vpos leftW textheight])
set(h.foSpinnerContainer, 'Position',[leftspace+horspace+leftW vpos rightW spinH])
vpos = vpos-verspace-spinH;
set(h.hpfText, 'Position',[leftspace vpos leftW textheight])
set(h.hpfSpinnerContainer, 'Position',[leftspace+horspace+leftW vpos rightW spinH])
vpos = vpos-vergap-spinH;
set(h.plotrawCheck, 'Position',[leftspace+horspace+leftW vpos leftW+horspace+rightW checkheight])
set(h.infoPushbutton, 'Position',[leftspace bottomspace leftW+horspace+rightW buttonheight])

% Axes
axH = floor(figPos(4)/5);
axW = figPos(3)-leftspace-leftW-horspace-rightW-8*horspace;
if axW<1
    axW = 1;
end
hpos = figPos(3)-axW;
vpos = figPos(4)-axH;
set(h.axs(1).ax, 'OuterPosition',[hpos vpos axW axH])
axPos = get(h.axs(1).ax,'Position');
vpos = axPos(2);
for i = 2:5
    
    vpos = vpos-axPos(4);
    set(h.axs(i).ax, 'Position',[axPos(1) vpos axPos(3:4)])
end

function updateFilterPlot(hObject,event,h)
filterSettings = designfilt('lowpassiir','FilterOrder',getValue(h.foSpinner), ...
    'HalfPowerFrequency',getValue(h.hpfSpinner), 'DesignMethod','butter');

for i = 1:5
    for j = 1:length(h.axs(i).filt)
        
        y = get(h.axs(i).raw(j),'YData');
        if get(h.typePopup,'Value')==1
            y = filtfilt(filterSettings,y);
        else
            y = medianSmoothFilter(y,getValue(h.foSpinner));
        end
        set(h.axs(i).filt(j), 'YData',y)
    end
end

updatePlotRaw([],[],h)

function updatePlotRaw(hCheck,event,h)
for i = 1:5
        
    for n = 1:length(h.axs(i).filt)
        raw = h.axs(i).raw(n);
        filt = h.axs(i).filt(n);
        if get(h.plotrawCheck,'value')
            set(raw,'Visible','on')
            set(filt,'Color',[0 0 0])
        else
            set(raw,'Visible','off')
            set(filt,'Color',get(raw,'Color'))
        end
    end
end

function updateType(hPopup,event,h)
mainhandles = guidata(h.mainhandle);
if get(h.typePopup,'Value')==1
    set([h.hpfText h.hpfSpinnerContainer],'Visible','on')
    set(h.foText,'String','Filter order: ')
    setModel(h.foSpinner, javax.swing.SpinnerNumberModel( mainhandles.settings.filtering.filterorder, 1, 100, 1))
else
    set([h.hpfText h.hpfSpinnerContainer],'Visible','off')
    set(h.foText,'String','Size (frames): ')
    setModel(h.foSpinner, javax.swing.SpinnerNumberModel( mainhandles.settings.filtering.medianFrames, 1, 100, 2))
end
updateFilterPlot([],[],h)
