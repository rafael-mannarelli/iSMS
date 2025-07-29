function mainhandles = updateDriftWindowPlots(mainhandle,driftwindowHandle,AxChoice)
% Updates the drift plots, intensity traces and images of the selected FRET
% pair in the driftwindow GUI window.
%
%    Input:
%     mainhandle        - handle to main GUI window (sms)
%     driftwindowHandle - handle to the driftwindow GUI window
%     AxChoice          - 'drift' 'pair' or 'all'
%
%    Output:
%     mainhandles       - handles structure of the main window
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

if nargin<3
    AxChoice = 'all';
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(driftwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(driftwindowHandle))
    try mainhandles = guidata(mainhandle);
    catch err
        mainhandles = [];
    end
    driftwindowHandles = [];
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
driftwindowHandles = guidata(driftwindowHandle); % Handles to the FRET pair window

% Shorten axes names
driftAxes1 = driftwindowHandles.driftAxes1;
driftAxes2 = driftwindowHandles.driftAxes2;

DDtraceAxes = driftwindowHandles.DDtraceAxes;
AAtraceAxes = driftwindowHandles.AAtraceAxes;
EtraceAxes = driftwindowHandles.EtraceAxes;

DDimageAxes1 = driftwindowHandles.DDimageAxes1;
DDimageAxes2 = driftwindowHandles.DDimageAxes2;
AAimageAxes1 = driftwindowHandles.AAimageAxes1;
AAimageAxes2 = driftwindowHandles.AAimageAxes2;

% If there is no data clear all axes
if (isempty(mainhandles.data))
    cla(driftAxes1),  cla(driftAxes2)
    cla(DDtraceAxes),  cla(AAtraceAxes),  cla(EtraceAxes)
    cla(DDimageAxes1),  cla(DDimageAxes2),  cla(AAimageAxes1),  cla(AAimageAxes2)
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

% Selected file
file = get(driftwindowHandles.FilesListbox,'Value');

%% Update drift plots

if strcmpi(AxChoice,'drift') || strcmpi(AxChoice,'all')
    
    % Acceptor
    drft = mainhandles.data(file).drifting.drift;
    steplength = round(size(drft,1)/3);
    
    % Plot in left axes
    if numel(unique(drft)) == 1 % If drift array contains only one number (0), plot filled markers
        scatter(driftAxes1,drft(:,1),drft(:,2),'filled','MarkerFaceColor',[1 0 0])
    else
        plot(driftAxes1,drft(1:steplength,1),drft(1:steplength,2),'-r'), hold(driftAxes1,'on')
        plot(driftAxes1,drft(steplength+1:steplength*2,1),drft(steplength+1:steplength*2,2),'-g')
        plot(driftAxes1,drft(steplength*2+1:end,1),drft(steplength*2+1:end,2),'-b'), hold(driftAxes1,'off')
    end
    
    % Set labels
    xlabel(driftAxes1,'Frame shift x /pixel')
    ylabel(driftAxes1,'Frame shift y /pixel')
    axis(driftAxes1,'equal')
    
    % Plot in right axes
    distvec = sqrt(sum(drft.^2,2));
    plot(driftAxes2,1:steplength,distvec(1:steplength),'-r'), hold(driftAxes2,'on')
    plot(driftAxes2,steplength+1:steplength*2,distvec(steplength+1:steplength*2),'-g')
    plot(driftAxes2,steplength*2+1:length(distvec),distvec(steplength*2+1:end),'-b'), hold(driftAxes2,'off')
    xlabel(driftAxes2,'Frame')
    ylabel(driftAxes2,'Shift distance /pixels')
    
    % Update UI context menu
    updateUIcontextMenus(mainhandles.figure1,[driftAxes1 driftAxes2])
end

%% Update pair plots

if ~mainhandles.data(file).drifting.choice
    return
end

if strcmpi(AxChoice,'pair') || strcmpi(AxChoice,'all')
    % Get filechoice and pairchoice
    selectedPair = getPairs(mainhandle,'driftSelected',[],[],[],[],driftwindowHandle); % Returns selection in [file pair;...]
    
    % If there is no FRET-pair or there is more than one FRET-pair selected, clear all axes
    if (isempty(selectedPair)) || (size(selectedPair,1)~=1)
        set(driftwindowHandles.BeforeTextbox1,'Visible','off')
        cla(DDtraceAxes),  cla(AAtraceAxes),  cla(EtraceAxes)
        cla(DDimageAxes1),  cla(DDimageAxes2),  cla(AAimageAxes1),  cla(AAimageAxes2)
        return
    else
        set(driftwindowHandles.BeforeTextbox1,'Visible','on')
    end
    
    file = selectedPair(1,1);
    pairchoice = selectedPair(1,2);
    
    % Integrated intensity traces within the integration range of the D and
    % A
    DtraceAfter = mainhandles.data(file).FRETpairs(pairchoice).DDtrace;
    EtraceAfter = mainhandles.data(file).FRETpairs(pairchoice).Etrace;
    if alex
        AtraceAfter = mainhandles.data(file).FRETpairs(pairchoice).AAtrace;
    else
        AtraceAfter = mainhandles.data(file).FRETpairs(pairchoice).ADtrace;
    end
    
    % Calculate temporary drift un-corrected intensity traces of selected
    % pair
    pairAfter = mainhandles.data(file).FRETpairs(pairchoice); % Save current drift-corrected pair data so it can be restored
    mainhandles.data(file).drifting.choice = 0; % Set as drift un-corrected calculation
    updatemainhandles(mainhandles)
    
    [mainhandles FRETpairwindowHandles] = calculateIntensityTraces(mainhandle, selectedPair, 0);
    
    % Get the drift uncorrected intensity traces saved to the mainhandles
    % structure by calculateIntensityTraces
    DtraceBefore = mainhandles.data(file).FRETpairs(pairchoice).DDtrace;
    EtraceBefore = mainhandles.data(file).FRETpairs(pairchoice).Etrace;
    if alex
        AtraceBefore = mainhandles.data(file).FRETpairs(pairchoice).AAtrace;
    else
        AtraceBefore = mainhandles.data(file).FRETpairs(pairchoice).ADtrace;
    end
    
    % Restore pair in mainhandles structure
    mainhandles.data(file).drifting.choice = 1; % Drift correction
    mainhandles.data(file).FRETpairs(pairchoice) = pairAfter; % Pair data
    updatemainhandles(mainhandles)
    
    %% Update trace axes
    
    % DD trace
    plot(DDtraceAxes,DtraceAfter,'Color','green','linewidth',2), hold(DDtraceAxes,'on')
    plot(DDtraceAxes,DtraceBefore,'Color','black'), hold(DDtraceAxes,'off')
    
    % AA trace
    plot(AAtraceAxes,AtraceAfter,'Color','red','linewidth',2), hold(AAtraceAxes,'on')
    plot(AAtraceAxes,AtraceBefore,'Color','black'), hold(AAtraceAxes,'off')
    
    % E trace
    plot(EtraceAxes,EtraceAfter,'Color','cyan','linewidth',2), hold(EtraceAxes,'on')
    plot(EtraceAxes,EtraceBefore,'Color','black'), hold(AAtraceAxes,'off')
    
    % Zoom y-axes
    if mainhandles.settings.FRETpairplots.autozoom
        ylim(DDtraceAxes,[min([DtraceAfter(:); DtraceBefore(:)]) max([DtraceAfter(:); DtraceBefore(:)])])
        ylim(AAtraceAxes,[min([AtraceAfter(:); AtraceBefore(:)]) max([AtraceAfter(:); AtraceBefore(:)])])
    end
    ylim(EtraceAxes,[-0.1 1.1])
    
    % Axes labels
    if strcmp(get(get(DDtraceAxes,'ylabel'),'string'),'')
        ylabel(DDtraceAxes,'D_e_m - D_e_x_c')
        set(DDtraceAxes, 'XTickLabel','')
    end
    if strcmp(get(get(AAtraceAxes,'ylabel'),'string'),'')
        ylabel(AAtraceAxes,getYlabel(mainhandles,'driftwindowAx2'))
        set(AAtraceAxes, 'XTickLabel','')
    end
    if strcmp(get(get(EtraceAxes,'ylabel'),'string'),'')
        xlabel(EtraceAxes,'Time /frame')
        ylabel(EtraceAxes,'E')
    end
    
    % Plot zero-lines
    plotZeroLine(DDtraceAxes,[0 0])
    plotZeroLine(AAtraceAxes,[0 0])
    plotZeroLine(EtraceAxes,[0 0])
    plotZeroLine(EtraceAxes,[1 1])
    
    % Update context menu
    updateUIcontextMenus(mainhandles.figure1,[DDtraceAxes AAtraceAxes EtraceAxes])
    
    %% Calculate avg. images
    
    % Calculate molecule images
    if ~isempty(mainhandles.data(file).DD_ROImovie) && isempty(mainhandles.data(file).FRETpairs(pairchoice).DD_avgimage) % If ROI movie has not been deleted, calculate the molecule images
        mainhandles = calculateMoleculeImages(mainhandle,selectedPair);
        
    elseif isempty(mainhandles.data(file).DD_ROImovie) && isempty(mainhandles.data(file).FRETpairs(pairchoice).DD_avgimage) % If both ROI movie and avg molecule image has been deleted
        cla(DDimageAxes1),  cla(DDimageAxes2),  cla(AAimageAxes1),  cla(AAimageAxes2)
        return
    end
    
    % Get images
    D_avgAfter = mainhandles.data(file).FRETpairs(pairchoice).DD_avgimage; % Avg. image of molecule in D emission with D excitations
    if alex
        A_avgAfter = mainhandles.data(file).FRETpairs(pairchoice).AA_avgimage; % Avg. image of molecule in A emission with A excitations
    else
        A_avgAfter = mainhandles.data(file).FRETpairs(pairchoice).AD_avgimage; % Avg. image of molecule in A emission with A excitations
    end
    
    % Get temporary drift-uncorrected molecule images of selected pair
    pairAfter = mainhandles.data(file).FRETpairs(pairchoice); % Save current drift-corrected pair data so it can be restored
    mainhandles.data(file).drifting.choice = 0; % Set as drift un-corrected calculation
    updatemainhandles(mainhandles)
    
    mainhandles = calculateMoleculeImages(mainhandle,selectedPair); % Calculates images
    
    % Get the drift uncorrected molecule images saved in mainhandles
    D_avgBefore = mainhandles.data(file).FRETpairs(pairchoice).DD_avgimage; % Avg. image of molecule in D emission with D excitations
    if alex
        A_avgBefore = mainhandles.data(file).FRETpairs(pairchoice).AA_avgimage; % Avg. image of molecule in A emission with A excitations
    else
        A_avgBefore = mainhandles.data(file).FRETpairs(pairchoice).AD_avgimage; % Avg. image of molecule in A emission with A excitations
    end
    
    % Restore pair in mainhandles structure
    mainhandles.data(file).drifting.choice = 1; % Drift correction
    mainhandles.data(file).FRETpairs(pairchoice) = pairAfter; % Pair data
    updatemainhandles(mainhandles)
    
    %% Plot images and set image axes properties
    
    % Make logarithmic scale plot
    if mainhandles.settings.FRETpairplots.logImage
        D_avgAfter = real(log10(D_avgAfter));
        A_avgAfter = real(log10(A_avgAfter));
        D_avgBefore = real(log10(D_avgBefore));
        A_avgBefore = real(log10(A_avgBefore));
    end
    
    % Plot
    showImg(DDimageAxes1,D_avgBefore) % D before
    showImg(DDimageAxes2,D_avgAfter) % D after
    showImg(AAimageAxes1,A_avgBefore) % A before
    showImg(AAimageAxes2,A_avgAfter) % A after
    
    % Update context menu
    updateUIcontextMenus(mainhandles.figure1,[DDimageAxes1 DDimageAxes2 AAimageAxes1 AAimageAxes2])
    
end

%% Nested

    function showImg(ax,imageData)
        % Plot image
        imagesc(imageData, 'Parent',ax);
        
        % Set ax properties
        axis(ax,'image') % Equalizes x and y limits
        set(ax,'YDir','normal') % Flips y-axis so that it goes from low to high numbers, going up
        set(ax, 'XTickLabel','')
        set(ax, 'YTickLabel','')
    end

    function plotZeroLine(ax,y)
        if ~mainhandles.settings.FRETpairplots.zeroline
            return
        end
        xl = get(ax,'xlim');
        hold(ax,'on')
        plot(ax,xl,y,'--k')
        hold(ax,'off')
    end

end