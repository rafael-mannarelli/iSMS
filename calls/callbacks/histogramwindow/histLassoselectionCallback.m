function mainhandles = histLassoselectionCallback(histogramwindowHandles)
% Callback for the lasso selection tool in the histogramwindow
%
%    Input:
%     histogramwindowHandles    - handles structure of the histogramwindow
%
%    Output:
%     mainhandles               - handles structure of the main window
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

mainhandles = getmainhandles(histogramwindowHandles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

plottedPairs = getPairs(mainhandles.figure1, 'Plotted', [], mainhandles.FRETpairwindowHandle); % Returns pair selection as [file pair;...]
if isempty(plottedPairs)
    return
end

% Show guide box
str = sprintf(['This is how the lasso tool works:\n\n'...
    '  1) Drag and select data points in the plot by pressing down left mouse button.\n'...
    '  2) Release mouse button when data points have been selected. This will call the lasso action callback on the selected points.'...
    '\n\nThe action on selected data points is chosen in the Settings menu.']);
mainhandles = myguidebox(mainhandles,'Lasso selection',str,'SElasso');

%% Start user selection

% Delete text labels, because selectdata cannot deal with those
h = findobj(histogramwindowHandles.SEplot,'type','text');
delete(h)
datacursormode('off')
zoom('off')

% Make user selection
setappdata(0,'stopselectdata',[])
[ind,xs,ys] = myselectdata('Axes',histogramwindowHandles.SEplot,...
    'Fig', histogramwindowHandles.figure1,...
    'selectionmode','lasso',...
    'Ignore',[],...
    'Identify','off',...
    'FillTrans',1);

%% Interpret selection

if ~iscell(ind) % Make sure point-indices are specified as cell array
    ind = {ind};
end
if ~iscell(xs) % Make sure point-coordinates are specified as cell array
    xs = {xs};
    ys = {ys};
end

% Put all in one column
xs = cellfun(@transpose,xs,'UniformOutput',false);
ys = cellfun(@transpose,ys,'UniformOutput',false);
xs = [xs{:}];
xs = xs(:);
ys = [ys{:}];
ys = ys(:);

xys = [xs ys];

if isempty(xs)
    return
end

%% Extract info

selectedPairs = [];
if mainhandles.settings.SEplot.lassoOrigin
    % Info on point origins
    [mainhandles, selectedPairs] = plotoriginInfo(mainhandles);
end

if mainhandles.settings.SEplot.lassoCopy
    % Copy data to clipboard
    try
        copy(xys);
        
        % Show message
        mainhandles = myguidebox(mainhandles,'Great success!','Selected data points were copied to the clipboard.','copySElassotoclipboard');
    end
end

if mainhandles.settings.SEplot.lassoNewgroup
    mainhandles = newgroup(mainhandles,selectedPairs);
end

%% Nested

    function [mainhandles, selectedPairs] = plotoriginInfo(mainhandles)
        
        % Initialize
        selectedPairs = []; % [file pair;...]
        
        % Show waitbar
        hWaitbar = mywaitbar(1,'Retrieving information. Please wait...','name','iSMS');
        setFigOnTop % Sets the waitbar so that it is always in front
        
        % Get info on selection
        allpairs = getPairs(histogramwindowHandles.main,'all');
        [points, selectedPairs] = getlassoPairs();
        filepairs = points(:,1:2);
        
        %% Plot histograms of selected data
        
        %- File histogram
        fh = figure;
        updatelogo(fh)
        set(fh,'name','Where the points originate from','numbertitle','off')
        subplot(3,1,1)
        hist(points(:,1),1:length(mainhandles.data));
        xlabel('File')
        ylabel('#Events')
        xlim([0.5 length(mainhandles.data)+0.5])
        
        %- FRETpair histogram
        subplot(3,1,2)
        
        % Calculate histogram
        histfilepairs = zeros(size(selectedPairs,1),2);
        for i = 1:size(selectedPairs,1)
            histfilepairs(i,1) = find( ismember(allpairs,selectedPairs(i,:),'rows','legacy') ); % Pair
            histfilepairs(i,2) = length(find( ismember(filepairs,selectedPairs(i,:),'rows','legacy') )); % Number of frames
        end
        
        % Plot histogram
        bar(histfilepairs(:,1),histfilepairs(:,2))
        xlabel('FRET-pair')
        ylabel('#Events')
        xlim([0.5 size(allpairs,1)+0.5])
        
        % Bar labels
        maxlab = max(histfilepairs(:,2));
        for i = 1:size(selectedPairs,1)
            if histfilepairs(i,2)<mainhandles.settings.SEplot.lassoPairlabelThreshold*maxlab
                txtlab = '';
            else
                txtlab = sprintf('(%i,%i)',selectedPairs(i,1),selectedPairs(i,2));
            end
            
            text(histfilepairs(i,1),histfilepairs(i,2), txtlab,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom')
        end
        
        %- Frame histogram
        subplot(3,1,3)
        hist(points(:,3),1:length(mainhandles.data(plottedPairs(end,1)).FRETpairs(1).DDtrace));
        xlabel('Frame')
        ylabel('#Events')
        xlim([0.5 length(mainhandles.data(plottedPairs(end,1)).FRETpairs(1).DDtrace)+0.5])
        
        % Store figure handle
        mainhandles.figures{end+1} = fh;
        updatemainhandles(mainhandles)
        
        % Delete waitbar
        delete(hWaitbar)
        
    end

    function mainhandles = newgroup(mainhandles, selectedPairs)
        if isempty(selectedPairs)
            [~, selectedPairs] = getlassoPairs();
        end
        
        updatemainhandles(mainhandles)
        groupname = 'Lasso selection';
        mainhandles = createNewGroup(mainhandles,selectedPairs,groupname);
        mainhandles = checkemptyGroups(mainhandles.figure1);
        mainhandles = updateGUIafterNewGroup(mainhandles.figure1);
        
        mymsgbox(sprintf('Created new group with %i molecules called ''%s''',size(selectedPairs,1),groupname))

    end

    function [points, selectedPairs] = getlassoPairs()
        % Initialize
        points = [];
        selectedPairs = [];
        
        % Identify file, FRET-pair and frame of selected point
        frame = [];
        if isempty(plottedPairs)
            return
        end
        
        traces = getTraces(histogramwindowHandles.main, plottedPairs, 'SEplot');
        if isempty(traces)
            return
        end
        
        % Prepare all plotted pairs
        npoints = 0;
        for i = 1:length(traces)
            npoints = npoints+length(traces(i).E);
        end
        
        pairidx = zeros(npoints,3);
        idx1 = 1;
        for i = 1:length(traces)
            idx2 = idx1-1+length(traces(i).E);
            pairidx(idx1:idx2,1) = plottedPairs(i,1);
            pairidx(idx1:idx2,2) = plottedPairs(i,2);
            pairidx(idx1:idx2,3) = 1:idx2-idx1+1;
            idx1 = idx2+1;
        end
        
        % All plotted data points
        tracesE = [traces(:).E];
        tracesS = [traces(:).S];
        tracesES = [tracesE; tracesS]';
        
        % Identify selected points
        temp = find( ismember(tracesES,xys,'rows','legacy') );
        points = pairidx(temp,:); % [file pair frame;...]
        
        % Identify selected pairs
        selectedPairs = unique(points(:,1:2),'rows'); % [file pair;...]
    end

end