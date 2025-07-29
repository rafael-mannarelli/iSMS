function updateDynamicsPlot(mainhandle,dynamicswindowHandle,choice)
% Update the plots in the dynamics analysis window
%
%    Input:
%     mainhandle            - handle to main GUI window
%     dynamicswindowHandle  - handle to the FRET-pair GUI window
%     choice                - 'trace', 'hist', 'fit', 'all'. Chooses which
%                             axes to update
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

% Set defaults
if nargin<3
    choice = 'all';
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(dynamicswindowHandle))
    return
elseif (~ishandle(mainhandle)) || (~ishandle(dynamicswindowHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
dynamicswindowHandles = guidata(dynamicswindowHandle); % Handles to the dynamics window

% If there is no data, clear all axes and return
if (isempty(mainhandles.data))
    cla(dynamicswindowHandles.TraceAxes),  cla(dynamicswindowHandles.HistAxes)
    return
end

% If there are no FRET-pairs in any of the selected files, clear all axes
% and return
dynamicsPairs = getPairs(mainhandle, 'Dynamics');
if isempty(dynamicsPairs)
    cla(dynamicswindowHandles.TraceAxes),  cla(dynamicswindowHandles.HistAxes)
    return
end

%% Update trace plot

if strcmpi(choice,'trace') || strcmpi(choice,'all')
    
    % Get selection
    pairchoice = get(dynamicswindowHandles.PairListbox,'Value');
    if isempty(pairchoice) || size(dynamicsPairs,1)<pairchoice(end)
        set(dynamicswindowHandles.PairListbox,'Value',size(dynamicsPairs,1))
        pairchoice = get(dynamicswindowHandles.PairListbox,'Value');
    end
    selectedPairs = dynamicsPairs(pairchoice,:); % Pairs selected in the dynamics window [file pair;...]
    
    % Colors of individual traces
    colorseq = 'bcmykrg';
    if size(selectedPairs,1)>7
        colorseq = repmat(colorseq,1,ceil(size(selectedPairs,1)/7));
    end
    
    % Check time vector
    timed = checkTime(mainhandles,selectedPairs);
    
    % Time
    t = [];
    xstr = '';
    
    % Plot traces
    if size(selectedPairs,1)>2 && get(dynamicswindowHandles.PlotPopupmenu,'Value')==3
        cla(dynamicswindowHandles.TraceAxes)
    else
        for p = 1:size(selectedPairs,1)
            raw = mainhandles.data(selectedPairs(p,1)).FRETpairs(selectedPairs(p,2)).Etrace;
            fit = mainhandles.data(selectedPairs(p,1)).FRETpairs(selectedPairs(p,2)).vbfitE_fit(:,1);
            idx = mainhandles.data(selectedPairs(p,1)).FRETpairs(selectedPairs(p,2)).vbfitE_idx;
            
            % Time vector
            if timed
                t = getTimeVector(mainhandles,selectedPairs(p,:),'D');
                xstr = 'Time /s';
            else
                t = 1:length(raw);
                xstr = 'Time /frames';
            end
            
            if size(selectedPairs,1)==1
                % There is only one trace selected
                plotTrace(t, raw, '-r', 0.5)
                
                % Cut ideal traces according to intervals
                idx1 = 1;
                for j = 1:size(idx,1)
                    idx2 = idx1 + idx(j,2)-idx(j,1);
                    plotTrace(t(idx(j,1):idx(j,2)), fit(idx1:idx2), '-b', 2)
                    idx1 = idx2+1;
                end
                
            else
                % There are multiple selected traces, plot in different colors
                
                plotTrace(t, raw, sprintf('-%s',colorseq(p)), 0.5)
                idx1 = 1;
                for j = 1:size(idx,1)
                    idx2 = idx1 + idx(j,2)-idx(j,1);
                    plotTrace(t(idx(j,1):idx(j,2)), fit(idx1:idx2), sprintf('-%s',colorseq(p)), 2)
                    idx1 = idx2+1;
                end
            end
            
        end
    end
    
    % Set axes properties
    ylabel(dynamicswindowHandles.TraceAxes, 'FRET efficiency')
    xlabel(dynamicswindowHandles.TraceAxes, xstr)
    hold(dynamicswindowHandles.TraceAxes,'off')
    ylim(dynamicswindowHandles.TraceAxes,[-0.1 1.1])
    
    % UI context menu
    updateUIcontextMenus(mainhandle, dynamicswindowHandles.TraceAxes)
    
end

%% Update histogram plot

plotchoice = get(dynamicswindowHandles.PlotPopupmenu,'Value');
hold(dynamicswindowHandles.HistAxes,'off')
if strcmpi(choice,'hist') || strcmpi(choice,'all')
    
    if plotchoice == 1
        % Plot dwell times
        plotdwellTimes();
        
    elseif plotchoice == 2
        % No of states
        plotnumberStates();
        
    elseif plotchoice == 3
        % Transition density plot (TDP)
        plotTDP();
        
    elseif plotchoice == 4
        % Plot FRET histogram of selected states
        plothistStates();
        
        
    elseif plotchoice==5
        % Plot mean dwell times scatter
        plotdwellTimes();
        
    elseif plotchoice==6
        % Plot dwell times scatter
        plotdwellTimes();
    end
    
    % UI context menu
    updateUIcontextMenus(mainhandle, dynamicswindowHandles.HistAxes)
    
end

%% Update histogram fit plot

if strcmpi(choice,'fit') || strcmpi(choice,'all') && mainhandles.settings.dynamicsplot.fit && plotchoice==1
    % Delete previous graph
    delete( findobj(dynamicswindowHandles.HistAxes,'Color','red') );
    
    % Parameters and data range
    pars = get(dynamicswindowHandles.parTable,'data');
    data = get(dynamicswindowHandles.parTable,'UserData');
    if isempty(pars) || isempty(data)
        return
    end
    x = linspace(min(data(:,1)),max(data(:,1))*1.1,100);
    y = x;
    
    % Get fit
    [res,sim] = expfun(pars,[x(:) y(:)]);
    
    % Plot
    hold(dynamicswindowHandles.HistAxes,'on')
    plot(dynamicswindowHandles.HistAxes,x,sim,'-r','linewidth',2)
    hold(dynamicswindowHandles.HistAxes,'off')
end

%% Nested

    function plotTrace(x,y,col,w)
        pH = plot(dynamicswindowHandles.TraceAxes,x,y,col,'linewidth',w);
        hold(dynamicswindowHandles.TraceAxes,'on')
        
        % UI context menu
        updateUIcontextMenus(mainhandle, pH)
    end

    function dwellTimes = getDwellTimes(selectedStates)
        % Returns dwell times of all selectedStates
        
        % Initialize
        dwellTimes = {};
        
        % Check time
        timed = checkTime(mainhandles,selectedStates(:,1:2));
        
        % Run through all states
        for i = 1:size(selectedStates,1);
            state = selectedStates(i,:);
            fit = mainhandles.data(state(1)).FRETpairs(state(2)).vbfitE_fit(:,2); % Idealized trace
            idx = mainhandles.data(state(1)).FRETpairs(state(2)).vbfitE_idx; % Indices of the time-intervals plotted
            E = state(3); % E of this state
            
            % Initialize
            dwellTimes_i = [];
            dwellTimes_end = [];
            
            % Run through all plateous in ideal trace
            idx1 = 1;
            for j = 1:size(idx,1)
                
                idx2 = idx1 + idx(j,2)-idx(j,1);
                temp_fit = fit(idx1:idx2);
                idx1 = idx2+1;
                
                % Find dwell times
                temp = diff([0 temp_fit' 0]==state(4));
                temp_dwellTimes = [find(temp==-1)-find(temp==1)]; % All dwell times of this state in this trace
                
                % Correct for time
                if timed
                    [~,ms] = getTimeVector(mainhandles,state(1:2));
                    temp_dwellTimes = temp_dwellTimes*ms;
                end
                
                % Remove ends
                if mainhandles.settings.dynamicsplot.includeEnds ...
                        && mainhandles.settings.dynamicsplot.colorEnds==1
                    
                    % Plot ends in same color as rest
                    dwellTimes_i = [dwellTimes_i temp_dwellTimes]
                    
                else
                    % Don't count the ending plateaus
                    
                    % Indices of
                    idx1b = 1; % Start at first plateau
                    idx2b = length(temp_dwellTimes);
                    
                    % If selected state is the first state within the
                    % trace, don't count the first dwell time
                    if temp_fit(1)==state(4)
                        idx1b = 2;
                        
                        % Store dwell time
                        if mainhandles.settings.dynamicsplot.includeEnds
                            dwellTimes_end = [dwellTimes_end temp_dwellTimes(1)];
                        end
                    end
                    
                    % If selected state is the last within the trace, don't
                    % count the final dwell time
                    if temp_fit(end)==state(4)
                        idx2b = idx2b-1;
                        
                        % Store dwell time
                        if mainhandles.settings.dynamicsplot.includeEnds
                            dwellTimes_end = [dwellTimes_end temp_dwellTimes(end)];
                        end
                    end
                    
                    % Check if there are any middle intervals at all and
                    % store
                    if max([idx1b idx2b])<=length(temp_dwellTimes)
                        temp2 = temp_dwellTimes(idx1b:idx2b);
                        dwellTimes_i = [dwellTimes_i temp2]; %
                    end
                    
                end
                
            end
            
            % Collect
            dwellTimes{i,1} = dwellTimes_i; % Dwell times
            dwellTimes{i,2} = ones(1,length(dwellTimes_i))*E; % FRET value
            dwellTimes{i,3} = dwellTimes_end;
            dwellTimes{i,4} = ones(1,length(dwellTimes_end))*E; % FRET value, end
        end
        
    end

    function plotdwellTimes()
        
        % Initialize
        temp = getStates(mainhandle); % Get all states [file pair mu(E) state#;...]
        statechoices = get(dynamicswindowHandles.StateListbox,'Value');
        if size(temp,1) < statechoices(end)
            set(dynamicswindowHandles.StateListbox,'Value',size(temp,1))
            statechoices = get(dynamicswindowHandles.StateListbox,'Value');
        end
        selectedStates = temp(statechoices,:); % States selected in the states listbox
        
        % Check if correct for time
        timed = checkTime(mainhandles,selectedStates(:,1:2));
        
        % Find dwell times
        dwellTimes = getDwellTimes(selectedStates);
        
        if plotchoice==1
            
            % Plot histogram of dwell times
            if ~isempty(dwellTimes)
                d = [dwellTimes{:,1}]; % Dwell times is the first column
                
                nBins = get(dynamicswindowHandles.binSlider,'Value'); % Number of bins in histogram
                [n,xout] = hist(d,nBins); % n is frequency of bin centred at xout
                
                % VERSION DEPENDENT SYNTAX
                if mainhandles.matver>8.3
                    b = bar(dynamicswindowHandles.HistAxes,xout,n,'hist'); % Same as hist(ax,y,nBins)
                else
                    b = bar(dynamicswindowHandles.HistAxes,xout,n,'style','hist'); % Same as hist(ax,y,nBins)
                end
                
                % Set bar colors
                set(b, 'EdgeColor',[0.25  0.25  0.25],'FaceColor',[0.043137  0.51765  0.78039])
                
            else
                cla(dynamicswindowHandles.HistAxes)
            end
            
            % Set axes properties
            ylabel(dynamicswindowHandles.HistAxes,'Counts')
            if timed
                xlabel(dynamicswindowHandles.HistAxes,'Time /s')
            else
                xlabel(dynamicswindowHandles.HistAxes,'Time /frames')
            end
            
        elseif plotchoice==5
            
            % Plot mean times scatter
            if ~isempty(dwellTimes)
                
                % Initialize
                xy = zeros(size(dwellTimes,1),2);
                
                % Extract coordinates to plot
                for d = 1:size(dwellTimes,1)
                    if ~isempty(dwellTimes{d,1}) && ~isempty(dwellTimes{d,2})
                        y = mean(dwellTimes{d,1});
                        x = dwellTimes{d,2}(1);
                        xy(d,:) = [x y];
                    end
                end
                
                % Remove empty dwell times
                xy(find(xy(:,1)==0),:) = [];
                
                % Plot
                if isempty(xy)
                    cla(dynamicswindowHandles.HistAxes)
                else
                    plotscat(xy(:,1),xy(:,2))
                end
                
                % Plot ends in different colors
                if mainhandles.settings.dynamicsplot.includeEnds ...
                        && mainhandles.settings.dynamicsplot.colorEnds~=1
                    
                    % Initialize
                    xy = zeros(size(dwellTimes,1),2);
                    
                    % Extract coordinates to plot
                    for d = 1:size(dwellTimes,1)
                        if ~isempty(dwellTimes{d,3}) && ~isempty(dwellTimes{d,4})
                            y = mean(dwellTimes{d,3});
                            x = dwellTimes{d,4}(1);
                            xy(d,:) = [x y];
                        end
                    end
                    
                    % Remove empty dwell times
                    xy(find(xy(:,1)==0),:) = [];
                    
                    % Plot ends
                    if ~isempty(xy)
                        plotdwellEnds(xy(:,1),xy(:,2))
                    end
                    
                end
                
            else
                cla(dynamicswindowHandles.HistAxes)
            end
            
            % Set axes properties
            if timed
                ylabel(dynamicswindowHandles.HistAxes,'Mean dwell time /s')
            else
                ylabel(dynamicswindowHandles.HistAxes,'Mean dwell time /frames')
            end
            xlabel(dynamicswindowHandles.HistAxes,'FRET')
            zoom(dynamicswindowHandles.HistAxes,'reset')
            xlim(dynamicswindowHandles.HistAxes,[-0.1 1.1])
            
        elseif plotchoice==6
            
            % Plot dwell times scatter
            if ~isempty(dwellTimes)
                d = [dwellTimes{:,1}]; % Dwell times is the first column
                E = [dwellTimes{:,2}]; % FRET is the 2nd column
                
                plotscat(E,d)
                
                % Plot ends in different colors
                if mainhandles.settings.dynamicsplot.includeEnds ...
                        && mainhandles.settings.dynamicsplot.colorEnds~=1
                    
                    % Extract coordinates to plot
                    d = [dwellTimes{:,3}]; % Dwell times is the first column
                    E = [dwellTimes{:,4}]; % FRET is the 2nd column
                    
                    % Plot ends
                    plotdwellEnds(E,d)
                end
                
            else
                cla(dynamicswindowHandles.HistAxes)
            end
            
            % Set axes properties
            if timed
                ylabel(dynamicswindowHandles.HistAxes,'Dwell time /s')
            else
                ylabel(dynamicswindowHandles.HistAxes,'Dwell time /frames')
            end
            xlabel(dynamicswindowHandles.HistAxes,'FRET')
            zoom(dynamicswindowHandles.HistAxes,'reset')
            xlim(dynamicswindowHandles.HistAxes,[-0.1 1.1])
            
        end
        
    end

    function plotdwellEnds(x,y)
        % Plots the end dwell times
        if isempty(x) || isempty(y)
            return
        end
        
        % Color of end points
        c = [1 0 0]; % Red by default
        if mainhandles.settings.dynamicsplot.colorEnds==3
            c = [0 1 0];
        elseif mainhandles.settings.dynamicsplot.colorEnds==4
            c = [0 0 1];
        end
        
        % Plot
        hold(dynamicswindowHandles.HistAxes,'on')
        plotscat(x,y,c)
        hold(dynamicswindowHandles.HistAxes,'off')
        
    end

    function plotnumberStates()
        % Count no. of states in each trace
        selectedPairs = getPairs(mainhandle, 'Dynamics');
        if isempty(selectedPairs)
            return
        end
        nstates = zeros(size(selectedPairs,1),1);
        for i = 1:size(selectedPairs,1)
            nstates(i) = max(mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).vbfitE_fit(:,2));
        end
        
        % Plot histogram
        states = unique(nstates);
        nBins = length(states);
        [n,xout] = hist(nstates,nBins); % n is frequency of bin centred at xout
        
        % VERSION DEPENDENT SYNTAX
        if mainhandles.matver>8.3
            b = bar(dynamicswindowHandles.HistAxes,states(:),n(:),'hist'); % Same as hist(ax,y,nBins)
        else
            b = bar(dynamicswindowHandles.HistAxes,states(:),n(:),'Style','hist'); % Same as hist(ax,y,nBins)
        end
        
        % Set bar colors
        set(b, 'EdgeColor',[0.25  0.25  0.25], 'FaceColor',[0.043137  0.51765  0.78039])
        set(dynamicswindowHandles.HistAxes,'Xtick',states(:))
        
        % Set axes properties
        ylabel(dynamicswindowHandles.HistAxes,'#Traces')
        xlabel(dynamicswindowHandles.HistAxes,'#States')
        
    end

    function plotTDP()
        % Selected traces
        pairchoice = get(dynamicswindowHandles.PairListbox,'Value');
        if size(dynamicsPairs,1) < pairchoice(end)
            set(dynamicswindowHandles.PairListbox,'Value',size(dynamicsPairs,1))
            pairchoice = get(dynamicswindowHandles.PairListbox,'Value');
        end
        selectedPairs = dynamicsPairs(pairchoice,:); % Pairs selected in the dynamics window [file pair;...]
        
        % Make transition density matrix
        transitions = [];
        allTransitions = [];
        for i = 1:size(selectedPairs,1);
            file = selectedPairs(i,1);
            pair = selectedPairs(i,2);
            fit = mainhandles.data(file).FRETpairs(pair).vbfitE_fit(:,2)'; % Idealized trace
            fitE = mainhandles.data(file).FRETpairs(pair).vbfitE_fit(:,1)'; % Idealized trace
            
            % Edit timefilter
            vbset = mainhandles.settings.vbFRET;
            
            if isempty(vbset)
               vbset.bounds=[]; 
            end
            if any(strcmp('bounds',fieldnames(vbset)))==1 && isempty(vbset.bounds)==0 && size(vbset.bounds,2)==2
                lowbound = vbset.bounds(1); highbound=vbset.bounds(2);
            else
                lowbound = 1; 
                highbound = length(fit);
                mainhandles.settings.vbFRET.bounds = [lowbound, highbound];
                updatemainhandles(mainhandles);
            end
            
            % Find transitions
            transitions = find(diff(fit)~=0); % Indices of all transitions within fit
            transitions = [1; transitions(:); length(fit)];
            corrtrans=transitions(diff(transitions)>=lowbound & diff(transitions)<=highbound); %Apply specified timeinterval
            corrtrans=corrtrans(find(diff(fit(corrtrans+1))~=0)); %Extract only distinctive state changes

            stateTrace = [fitE(corrtrans+1)]; % [FRETstate1 state1 state1 state2 state1 state3 state2....]
            
%             % Find transitions
%             transitions = find(diff(fit)~=0); % Indices of all transitions within fit
%             stateTrace = [fitE(transitions) fitE(end)]; % [FRETstate1 state1 state1 state2 state1 state3 state2....]
            
            % List transitions
            if length(stateTrace)>1
                temp = zeros(length(stateTrace)-1,2);
                temp(:,1)=stateTrace(1:end-1);
                temp(:,2)=stateTrace(2:end);
                allTransitions = [allTransitions; temp];
            end
        end
        
        % Plot histogram
        bins = round(get(dynamicswindowHandles.binSlider,'Value'));
        xbins = linspace(-0.1,1.1,bins);
        ybins = linspace(-0.1,1.1,bins);
        axes(dynamicswindowHandles.HistAxes)
        if ~isempty(allTransitions)
            mHist2d = hist2d(allTransitions,ybins,xbins);
            
            nXBins = length(xbins);
            nYBins = length(ybins);
            vXLabel = 0.5*(xbins(1:(nXBins-1))+xbins(2:nXBins));
            vYLabel = 0.5*(ybins(1:(nYBins-1))+ybins(2:nYBins));
            h = pcolor(vXLabel, vYLabel,mHist2d);
            cb = colorbar;
            ylabel(cb,'#Events')
            colormap(dynamicswindowHandles.HistAxes,'Hot')
            updateUIcontextMenus(mainhandles.figure1,h)
            
            %         % Set color map
            %         cm = colormap(mainhandles.settings.SEplot.colormap);
            %         if mainhandles.settings.SEplot.colorinversion
            %             colormap(histogramwindowHandles.SEplot,flipud(cm))
            %         else
            %             colormap(histogramwindowHandles.SEplot,cm)
            %         end
        else cla
        end
        
        % Set axes properties
        xlabel(dynamicswindowHandles.HistAxes,'FRET before transition')
        ylabel(dynamicswindowHandles.HistAxes,'FRET after transition')
        xlim(dynamicswindowHandles.HistAxes,[-0.1 1.1])
        ylim(dynamicswindowHandles.HistAxes,[-0.1 1.1])
        
    end

    function plothistStates()
        
        % Get selection
        temp = getStates(mainhandle); % Get all states [file pair mu(E) state#;...]
        statechoices = get(dynamicswindowHandles.StateListbox,'Value');
        if size(temp,1) < statechoices(end)
            set(dynamicswindowHandles.StateListbox,'Value',size(temp,1))
            statechoices = get(dynamicswindowHandles.StateListbox,'Value');
        end
        selectedStates = temp(statechoices,:); % States selected in the states listbox
        
        % Find raw FRET values of all selected states
        E = [];
        for i = 1:size(selectedStates,1);
            state = selectedStates(i,:);
            fit = mainhandles.data(state(1)).FRETpairs(state(2)).vbfitE_fit(:,2); % Idealized trace
            idx = mainhandles.data(state(1)).FRETpairs(state(2)).vbfitE_idx; % Indices of the time-intervals plotted
            
            idx1 = 1;
            for j = 1:size(idx,1)
                idx2 = idx1 + idx(j,2)-idx(j,1);
                temp_fit = fit(idx1:idx2);
                idx1 = idx2+1;
                
                % Extract FRET efficiencies of selected state
                temp = find(temp_fit==state(4)); % Indices of frames to use
                E = [E; mainhandles.data(state(1)).FRETpairs(state(2)).Etrace(temp)];
            end
        end
        
        % Plot histogram
        if ~isempty(E)
            nBins = get(dynamicswindowHandles.binSlider,'Value');
            [n,xout] = hist(E,nBins); % n is frequency of bin centred at xout
            
            % VERSION DEPENDENT SYNTAX
            if mainhandles.matver>8.3
                b = bar(dynamicswindowHandles.HistAxes,xout,n,'hist'); % Same as hist(ax,y,nBins)
            else
                b = bar(dynamicswindowHandles.HistAxes,xout,n,'style','hist'); % Same as hist(ax,y,nBins)
            end
            
            % Set bar colors
            set(b, 'EdgeColor',[0.25  0.25  0.25],'FaceColor',[0.043137  0.51765  0.78039])
        else
            cla(dynamicswindowHandles.HistAxes)
        end
        
        % Set axes properties
        xlabel(dynamicswindowHandles.HistAxes,'FRET efficiency (E)')
        ylabel(dynamicswindowHandles.HistAxes,'Counts')
        xlim(dynamicswindowHandles.HistAxes,[-0.1 1.1])
        
    end

    function plotscat(x,y,c)
        % Plot scatter plot
        %
        %   Input:
        %    x    - x coordinates
        %    y    - y coordinates
        %    c    - color. Only used for end times
        
        if isempty(x) || isempty(y)
            return
        end
        
        if nargin<3
            c = [];
        end
        
        if length(x)>2500
            % Density plot for large datasets
            
            % Remove data points outside plot range
            xy = [x(:) y(:)];
            xy(xy(:,1)<-0.1,:) = [];
            xy(xy(:,1)>1.1,:) = [];
            
            % Remove points with identical coordinates (these are not
            % tolerated by scatplot
            [xyuniq,idxUniq] = unique(xy,'rows','legacy');
            
            % Color map
            colmap = eval( lower(mainhandles.settings.SEplot.colormap) ); % Returns colormap array (mx3). lower converts HSV (from older iSMS versions) to hsv
            if mainhandles.settings.SEplot.colorinversion
                colmap = flipud(colmap);
            end
            
            % Plot density scatter
            axes(dynamicswindowHandles.HistAxes) % Set as current axes
            out = scatplot(xyuniq(:,1),xyuniq(:,2),[],[],[],[],[],10,colmap,dynamicswindowHandles.HistAxes); % out = scatplot(x,y,method,radius,N,n,po,ms)
            
        else
            % Regular scatter
            scatter(dynamicswindowHandles.HistAxes, x, y,'*')
        end
        
        % Plot in color c. This is the end dwell times
        if ~isempty(c)
            scatter(dynamicswindowHandles.HistAxes, x, y,'*','markerfacecolor',c,'markeredgecolor',c)
        end
    end

    function timed = checkTime(mainhandles,selectedPairs)
        % Check if correcting time vector
        timed = 1;
        files = unique(selectedPairs(:,1));
        for i = 1:length(files)
            if isempty(mainhandles.data(files(i)).integrationTime)
                timed = 0;
                break
            end
        end
        
    end

end
