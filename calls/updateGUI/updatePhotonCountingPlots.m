function updatePhotonCountingPlots(mainhandle, integrationwindowHandle, choice, calc)
% Updates the axes in the integrationsettingsWindow, which compares different
% methods of photon counting
%
%   Input parameters:
%    mainhandle                  - handle to the main figure window
%    photoncountingwindowHandle  - handle to the photoncountingwindow
%    choice                      - 'all', 'traces', 'axes1', 'axes2' or
%                                  'psf' 
%    calc                        - 0/1: Calculate the intensity traces 
%                                  before plotting (if 0 the data plotted
%                                  will be extracted from the axes userdata)  
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

% Default
if nargin<3
    choice = 'all'; % Update all axes
end
if nargin<4
    calc = 1; % Calculate traces before plotting
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle)) || isempty(integrationwindowHandle) || ~ishandle(integrationwindowHandle)
    return
end

% Get handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
integrationwindowHandles = guidata(integrationwindowHandle); % Handles to the main GUI window (sms)

% Selected FRET-pair
selectedPair = getPairs(mainhandle, 'photonSelected', [],[],[],[],[], integrationwindowHandle);
if size(selectedPair,1)~=1
    clearAxes('all')
    return
end
file = selectedPair(1);
pairchoice = selectedPair(2);

% Which axes to update depends on choice
updateAxes1 = 0;
updateAxes2 = 0;
updatePSFaxes = 0;
if strcmpi(choice,'all') || strcmpi(choice,'traces') || strcmpi(choice,'axes1')
    clearAxes('Axes1') % First axes
    updateAxes1 = 1;
end
if strcmpi(choice,'all') || strcmpi(choice,'traces') || strcmpi(choice,'axes2')
    clearAxes('Axes2') % First axes
    updateAxes2 = 1;
end
if strcmpi(choice,'all') || strcmpi(choice,'psf')
    clearAxes('psf') % First axes
    updatePSFaxes = 1;
end

% Check raw data is loaded
if isempty(mainhandles.data(file).DD_ROImovie)
    mymsgbox('Reload the raw data of the selected FRET pairs in order to proceed with the request.')
    return
end

%% Update left axes

if updateAxes1 % Update left traces axes
    % Get traces for axes1
    if calc
        % Calculate traces
        [DDtrace, ADtrace, DDback, ADback, Etrace] = runTraceCalc(get(integrationwindowHandles.Axes1PopupMenu,'Value'));
        
        % Store traces in userdata (allows re-plotting without
        % re-calculating)
        userdata = [DDtrace(:), ADtrace(:), DDback(:), ADback(:), Etrace(:)];
        set(integrationwindowHandles.Axes1PopupMenu, 'UserData', userdata); % Store traces in userdata        
        
    else
        % Get traces from userdata
        userdata = get(integrationwindowHandles.Axes1PopupMenu, 'UserData');

        if ~isempty(userdata)
            DDtrace = userdata(:,1);
            ADtrace = userdata(:,2);
            DDback = userdata(:,3);
            ADback = userdata(:,4);
            Etrace = userdata(:,5);
        end
    end
    
    % Update plots
    if ~isempty(userdata)
        updateTraceAxes(1)
    end
end

%% Update right axes

if updateAxes2 % Update right traces axes
    % Get traces for axes1
    if calc
        % Calculate traces
        [DDtrace, ADtrace, DDback, ADback, Etrace] = runTraceCalc(get(integrationwindowHandles.Axes2PopupMenu,'Value'));

        % Store traces in userdata (allows re-plotting without
        % re-calculating) 
        userdata = [DDtrace, ADtrace, DDback, ADback, Etrace];
        set(integrationwindowHandles.Axes2PopupMenu, 'UserData', userdata); 
    
    else
        % Get traces from userdata
        userdata = get(integrationwindowHandles.Axes2PopupMenu, 'UserData');
        if ~isempty(userdata)
            DDtrace = userdata(:,1);
            ADtrace = userdata(:,2);
            DDback = userdata(:,3);
            ADback = userdata(:,4);
            Etrace = userdata(:,5);
        end
    end
    
    % Update plots
    if ~isempty(userdata)
        updateTraceAxes(2)
    end
end

%% Update PSF image

if updatePSFaxes % Update PSF plot
    % Selected method, channel and frame
    PSFmethod = get(integrationwindowHandles.PSFmethodPopupMenu, 'Value');
    PSFchannel = get(integrationwindowHandles.PSFchannelPopupMenu, 'Value');
    PSFframe = get(integrationwindowHandles.PSFframePopupMenu, 'Value');
    
    % Get psf image
    DDimage = getPSFimages(mainhandles, [file pairchoice], PSFframe, 'DD');
    ADimage = getPSFimages(mainhandles, [file pairchoice], PSFframe, 'AD');
    if PSFchannel == 1
        PSFimage = DDimage;
    elseif PSFchannel == 2
        PSFimage = ADimage;
    end
    
    % Get start guess + lower and upper bounds (lb, ub)
    [initialguess, lb, ub] = initialGuessGaussian(PSFimage);
    
    % Calculate psf
    threshold = mainhandles.settings.integration.threshold;
    if PSFmethod==1 % MLEwG
        
        [params, count, grid, imgFit] = MLEwG(PSFimage, initialguess, lb, ub, threshold); % Parameters = [x0 y0 sx sy theta background amplitude]
        
    elseif PSFmethod==2 % GME
        
        [params, count, grid, imgFit] = GME(PSFimage, initialguess, lb, ub, threshold); % Parameters = [x0 y0 sx sy theta background amplitude]
        
    end
    
    % Plot psf overlay
    X = grid(:,1:end/2);
    Y = grid(:,end/2+1:end);
    m = surf(integrationwindowHandles.PSFaxes, imgFit); % Fitted surface
    alpha(m,0.4)
    
    hold(integrationwindowHandles.PSFaxes, 'on')
    sh = scatter3(integrationwindowHandles.PSFaxes, X(:), Y(:), PSFimage(:), '.k'); % Raw data
    hold(integrationwindowHandles.PSFaxes, 'off')
    
    % Ui context menus
    updateUIcontextMenus(mainhandles.figure1,[integrationwindowHandles.PSFaxes m sh])
    
    % Remove labels
%     set(integrationwindowHandles.PSFaxes, 'XTickLabel','','YTickLabel','')
end

%% Nested

    function [DDtrace,ADtrace,DDback,ADback,PRtrace] = runTraceCalc(method)
        % Simulates trace-calculation using method and returns the
        % simulated/calculated traces
        %
        %    Input:
        %    method  - Method used for the calculating (Mask, MLEwG, GME)
        %    Outputs:
        %    ...   - Calculated traces
        
        % Current intensity traces
        currentSettings = mainhandles.settings;
        pair = mainhandles.data(file).FRETpairs(pairchoice);
        
        % Set temporary settings
        mainhandles.settings.integration.type = method;
        
        % Set parameters for calculation
        if method==1
            % Don't use intensity after bleach as background for mask
            mainhandles.settings.background.bleachchoice = 0;
            
        else
            
            mainhandles.settings.integration.wh = [...
                str2num(get(integrationwindowHandles.AreaSizeEditbox,'String')) str2num(get(integrationwindowHandles.AreaSizeEditbox,'String'))];
            mainhandles.settings.integration.posLim = str2num(get(integrationwindowHandles.PosLimEditbox,'String'));
            mainhandles.settings.integration.sigmaLim = [...
                str2num(get(integrationwindowHandles.MinWidthEditbox,'String')) str2num(get(integrationwindowHandles.MaxWidthEditbox,'String'))];
            mainhandles.settings.integration.thetaLim = [...
                str2num(get(integrationwindowHandles.MinAngleEditbox,'String')) str2num(get(integrationwindowHandles.MaxAngleEditbox,'String'))];
            mainhandles.settings.integration.constrainGaussianFWHM = get(integrationwindowHandles.ConstrainWidthCheckbox,'Value');
            mainhandles.settings.integration.threshold = get(integrationwindowHandles.ThresholdSlider,'Value');
            
        end
        
        updatemainhandles(mainhandles) % Update the handles structure
        
        % Calculate traces. calculateIntensityTraces returns the traces in
        % the mainhandles structure
        frames = str2num(get(integrationwindowHandles.FirstFramesEditbox,'String'));
        mainhandles = calculateIntensityTraces(mainhandle, selectedPair, 0, frames, 0, 'FRET'); % Calculate intensity traces
        
        % Collect calculated traces
        DDtrace = mainhandles.data(file).FRETpairs(pairchoice).DDtrace;
        ADtrace = mainhandles.data(file).FRETpairs(pairchoice).ADtrace;
        DDback = mainhandles.data(file).FRETpairs(pairchoice).DDback;
        ADback = mainhandles.data(file).FRETpairs(pairchoice).ADback;
        PRtrace = mainhandles.data(file).FRETpairs(pairchoice).PRtrace;
        
        % Reset handles structure to previous content
        mainhandles.data(file).FRETpairs(pairchoice) = pair;
        mainhandles.settings = currentSettings;
        updatemainhandles(mainhandles)
    end

    function updateTraceAxes(ax)
        % Shortcuts to axes handles
        if ax==1
            DDaxes = integrationwindowHandles.DDaxes1;
            ADaxes = integrationwindowHandles.ADaxes1;
            Eaxes = integrationwindowHandles.Eaxes1;
        elseif ax==2
            DDaxes = integrationwindowHandles.DDaxes2;
            ADaxes = integrationwindowHandles.ADaxes2;
            Eaxes = integrationwindowHandles.Eaxes2;
        end
        
        % Plot in trace axes
        x = 1:length(DDtrace);
        if integrationwindowHandles.settings.view.plotBackground==0 % Plot traces

            % Plot background-corrected traces only
            plot(DDaxes, x,DDtrace, 'Color','green') % DD trace
            plot(ADaxes, x,ADtrace, 'Color','red') % AD trace
            
        elseif integrationwindowHandles.settings.view.plotBackground==1 
            
            % Plot raw traces + background
            plot(DDaxes, x,DDtrace+DDback, 'Color','green') % DD trace
            plot(ADaxes, x,ADtrace+ADback, 'Color','red') % AD trace
            
            % Background
            hold(DDaxes,'on'),  hold(ADaxes,'on'),  hold(Eaxes,'on')
            plot(DDaxes, x,DDback, 'Color','black') % DD background
            plot(ADaxes, x,ADback, 'Color','black') % AD background
            hold(DDaxes,'off'),  hold(ADaxes,'off'),  hold(Eaxes,'off')
            
        elseif integrationwindowHandles.settings.view.plotBackground==2 
            
            % Plot background traces only
            plot(DDaxes, x,DDback, 'Color','black') % DD trace
            plot(ADaxes, x,ADback, 'Color','black') % AD trace
            
        end
        plot(Eaxes, x,Etrace, 'Color','blue') %  trace
        
        % Axes limits
        setYlim(DDaxes)
        setYlim(ADaxes)
        ylim(Eaxes,[-.1 1.1])
        
        % Axes
        if ax==1
            ylabel(DDaxes,'D - D')
            ylabel(ADaxes,'A - D')
            ylabel(Eaxes,'PR')
        else
            ylabel(DDaxes,'')
            ylabel(ADaxes,'')
            ylabel(Eaxes,'')
        end
        set([DDaxes ADaxes], 'XTickLabel','')
        xlabel(Eaxes,'Time /frames')
        
        % Ui context menus
        updateUIcontextMenus(mainhandles.figure1,[DDaxes ADaxes Eaxes])
    end

    function clearAxes(ax)
        % Clear selected axes
        if strcmpi(ax,'Axes1') || strcmpi(ax,'all')
            cla(integrationwindowHandles.DDaxes1)
            cla(integrationwindowHandles.ADaxes1)
            cla(integrationwindowHandles.Eaxes1)
        end
        if strcmpi(ax,'Axes2') || strcmpi(ax,'all')
            cla(integrationwindowHandles.DDaxes2)
            cla(integrationwindowHandles.ADaxes2)
            cla(integrationwindowHandles.Eaxes2)
        end
        if strcmpi(ax,'psf') || strcmpi(ax,'all')
            cla(integrationwindowHandles.PSFaxes)
        end
    end

end

function setYlim(ax)
% Zooms the y-axes to fit the data
ydata = get( findall(ax,'type','line') ,'ydata');
if iscell(ydata)
    ydata = [ydata{:}];
end
if ~isempty(ydata)
    ymax = max(max(ydata));
    ymin = min(min(ydata));
    try
        ylim(ax, [ymin ymax])
    end
end
end
