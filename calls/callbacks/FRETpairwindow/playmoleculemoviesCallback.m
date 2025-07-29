function playmoleculemoviesCallback(FRETpairwindowHandles)
% Callback for playing individual molecule traces movie in the
% FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles   - handles structure of the FRETpairwindow
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

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Movie player');
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Cut molecule movies from the new ROI-ellipse position

Dxy = mainhandles.data(filechoice).FRETpairs(pairchoice).Dxy; % Position of the donor within the D ROI [x y]
Axy = mainhandles.data(filechoice).FRETpairs(pairchoice).Axy; % Position of the acceptor within the A ROI [x y]
Dwh = mainhandles.data(filechoice).FRETpairs(pairchoice).Dwh; % Width and height of the donor integration area [w h] /pixels
Awh = mainhandles.data(filechoice).FRETpairs(pairchoice).Awh; % Width and height of the acceptor integration area [w h] /pixels

pD = round([Dxy(1)-0.5*Dwh(1),  Dxy(2)-0.5*Dwh(2),  Dwh(1),  Dwh(2)]); % Donor position area [xmin ymin width height]
pA = round([Axy(1)-0.5*Awh(1),  Axy(2)-0.5*Awh(2),  Awh(1),  Awh(2)]); % Acceptor position area [xmin ymin width height]

% ROI movie data
DD_ROImovie = mainhandles.data(filechoice).DD_ROImovie; % All D-ROI D-exc frames
AD_ROImovie = mainhandles.data(filechoice).AD_ROImovie; % All A-ROI D-exc frames
AA_ROImovie = mainhandles.data(filechoice).AA_ROImovie; % All A-ROI A-exc frames

if isempty(DD_ROImovie) || isempty(AD_ROImovie)
    mymsgbox('Raw movie data has been deleted. Reload raw data from main menu.')
    return
end

% Open window
figh = figure;
updatelogo(figh)

% Initialize trace axes
if alex
    ax_DD1 = subplot(3,4,1:3);
    ax_AD1 = subplot(3,4,5:7);
    ax_AA1 = subplot(3,4,9:11);
else
    ax_DD1 = subplot(2,4,1:3);
    ax_AD1 = subplot(2,4,5:7);
end
% Cut out rectangular movies within the integration ranges + 4 pixels extra
% width and height for the donor and acceptor image plots
DDmovie = DD_ROImovie(pD(1):sum(pD([1 3]))-1, pD(2):sum(pD([2 4]))-1,:);
ADmovie = AD_ROImovie(pA(1):sum(pA([1 3]))-1, pA(2):sum(pA([2 4]))-1,:);
if alex
    AAmovie = AA_ROImovie(pA(1):sum(pA([1 3]))-1, pA(2):sum(pA([2 4]))-1,:);
end

%% Movie

% Plot intensity traces
[h1 ylim_DD] = initPlot(...
    ax_DD1,... % Trace ax
    DDmovie,... % ROI movie
    mainhandles.data(filechoice).FRETpairs(pairchoice).DDtrace,...
    'green'); % Trace
[h2 ylim_AD] = initPlot(...
    ax_AD1,... % Trace ax
    ADmovie,... % ROI movie
    mainhandles.data(filechoice).FRETpairs(pairchoice).ADtrace,...
    'red'); % Trace
% AA trace in alex
if alex
    [h4 ylim_AA] = initPlot(...
        ax_AA1,... % Trace ax
        AAmovie,... % ROI movie
        mainhandles.data(filechoice).FRETpairs(pairchoice).AAtrace,...
        'red'); % Trace
end

% Initialize image axes
if alex
    ax_DD2 = subplot(3,4,4);
    ax_AD2 = subplot(3,4,8);
    ax_AA2 = subplot(3,4,12);
else
    ax_DD2 = subplot(2,4,4);
    ax_AD2 = subplot(2,4,8);
end

for j = 1:size(mainhandles.data(filechoice).DD_ROImovie,3)
    
    %-- DD --
    delete(h1)
    
    if ~isvalid(ax_DD1)
       return 
    end
    
    h1 = plot(ax_DD1,[j j],ylim_DD,'black');
    if strcmp(get(get(ax_DD1,'ylabel'),'string'),'')
        ylabel(ax_DD1,'D - D')
        set(ax_DD1, 'XTickLabel','')
    end

    % Image
    axes(ax_DD2)
    imagesc(DDmovie(:,:,j)')
    axis(ax_DD2,'image')
    set(ax_DD2,'YDir','normal')
    if ~strcmp(get(ax_DD2,'XTickLabel'),'')
        set(ax_DD2, 'XTickLabel','', 'YTickLabel','')
    end
    
    %-- AD --
    % Trace
    delete(h2)
    h2 = plot(ax_AD1,[j j],ylim_AD,'black');
    if strcmp(get(get(ax_AD1,'ylabel'),'string'),'')
        ylabel(ax_AD1,'A - D')
        set(ax_AD1, 'XTickLabel','')
    end
    
    % Image
    axes(ax_AD2)
    imagesc(ADmovie(:,:,j)')
    axis(ax_AD2,'image')
    set(ax_AD2,'YDir','normal')
    if ~strcmp(get(ax_AD2,'XTickLabel'),'')
        set(ax_AD2, 'XTickLabel','', 'YTickLabel','')
    end

    %-- A intensity with A exc.--
    if alex
        % Trace
        delete(h4)
        h4 = plot(ax_AA1,[j j],ylim_AA,'black');
        if strcmp(get(get(ax_AA1,'ylabel'),'string'),'')
            ylabel(ax_AA1,'A - A exc')
            xlabel(ax_AA1,'Time /frame')
        end
        
        % Image
        axes(ax_AA2)
        imagesc(AAmovie(:,:,j)')
        axis(ax_AA2,'image')
        set(ax_AA2,'YDir','normal')
        if ~strcmp(get(ax_AA2,'XTickLabel'),'')
            set(ax_AA2, 'XTickLabel','', 'YTickLabel','')
        end
    end
    pause(0.01)
end
delete(figh)

%% Nested

    function [h ylim_ax] = initPlot(ax,ROImovie,y,col)
        if isempty(y)
            return
        end
        
        % Plot
        x = 1:length(y);
        plot(ax,x,y,'color',col)
        hold(ax,'on')
        
        % Initialize timer-bar
        ylim_ax = get(ax,'ylim');
        h = plot(ax,[1 1],ylim_ax,'black');
        
    end

end