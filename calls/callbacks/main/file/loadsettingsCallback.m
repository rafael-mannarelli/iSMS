function mainhandles = loadsettingsCallback(mainhandles)
% Callback for loading settings from main menu
%
%   Input:
%    mainhandles   - handles structure of the main window
%
%   Output:
%    mainhandles   - ..
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

% Open a dialog for specifying file
fileformats = {'*.iSMSsettings', 'iSMS settings files'; '*.mat', 'Old settings files'; '*.*', 'All files'};
[FileName,PathName,chose] = uigetfile3(mainhandles,'settings',fileformats,'Load settings','name.iSMSsettings','off');
if chose == 0
    return
end

% Load settings file
filepath = fullfile(PathName,FileName);
settings_old = mainhandles.settings;
[settings_new, message, err] = loadSettings(settings_old, filepath)

% Display message in message board
if ~isempty(message)
    set(mainhandles.mboard, 'String',message)
end

%% Update settings structure

if ~isempty(settings_new)
    mainhandles.settings = settings_new;
end

%% Update GUI with new settings

% Update images
ok = 0;
if (~isequal(settings.view.rotate,prev.view.rotate)) % Rotate 90 deg.
    for i = 1:length(mainhandles.data)
        mainhandles.data(i).imageData = permute(mainhandles.data(i).imageData,[2 1 3]); % Raw images
        mainhandles.data(i).avgimage = permute(mainhandles.data(i).avgimage,[2 1]); % Avg. image
        mainhandles.data(i).avgDimage = permute(mainhandles.data(i).avgDimage,[2 1]); % Avg. image
        mainhandles.data(i).avgAimage = permute(mainhandles.data(i).avgAimage,[2 1]); % Avg. image
        mainhandles.data(i).Droi = mainhandles.data(i).Droi([2 1 4 3]); %  [x y width height]
        mainhandles.data(i).Aroi = mainhandles.data(i).Aroi([2 1 4 3]); %  [x y width height]
    end
    
    ok = 1; % OK to update
end
if (~isequal(settings.view.flipud,prev.view.flipud)) % Flip movie vertical
    for i = 1:length(mainhandles.data)
        for j = 1:size(mainhandles.data(i).imageData,3)
            mainhandles.data(i).imageData(:,:,j) = fliplr(mainhandles.data(i).imageData(:,:,j)); % Raw images
        end
        mainhandles.data(i).avgimage = fliplr(mainhandles.data(i).avgimage); % Avg. image
        mainhandles.data(i).avgDimage = fliplr(mainhandles.data(i).avgDimage); % Avg. image
        mainhandles.data(i).avgAimage = fliplr(mainhandles.data(i).avgAimage); % Avg. image
    end
    
    ok = 1; % OK to update
end
if (~isequal(settings.view.fliplr,prev.view.fliplr)) % Flip movie horizontal
    for i = 1:length(mainhandles.data)
        for j = 1:size(mainhandles.data(i).imageData,3)
            mainhandles.data(i).imageData(:,:,j) = flipud(mainhandles.data(i).imageData(:,:,j)); % raw images
        end
        mainhandles.data(i).avgimage = flipud(mainhandles.data(i).avgimage); % avg. image
        mainhandles.data(i).avgDimage = flipud(mainhandles.data(i).avgDimage); % avg. image
        mainhandles.data(i).avgAimage = flipud(mainhandles.data(i).avgAimage); % avg. image
    end
    
    ok = 1; % OK to update
end
if ok
    updatemainhandles(mainhandles)
    mainhandles = updateframesliderHandle(mainhandles);
    mainhandles = updaterawimage(mainhandles);
    mainhandles = updateROIhandles(mainhandles);
    mainhandles = updateROIimage(mainhandles);
    mainhandles = updatepeakplot(mainhandles,'all');
end

if (~isequal(settings.averaging,prev.averaging))
    mainhandles = updateavgimages(mainhandles,channel,1:length(mainhandles.data));
    mainhandles = updaterawimage(mainhandles);
    mainhandles = updateframesliderHandle(mainhandles);
    mainhandles = updateROIimage(mainhandles);
end

% Update intensity traces and plots
ok1 = 1;
ok2 = 1;
if (~isequal(settings.integration,prev.integration)) || (~isequal(settings.background,prev.background)) || (~isequal(settings.corrections,prev.corrections))
    if strcmp(get(mainhandles.Toolbar_FRETpairwindow,'state'),'on')
        updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
        mainhandles = calculateIntensityTraces(mainhandles.figure1,'all'); % Re-calculate intensity traces
        FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1, mainhandles.FRETpairwindowHandle,'all'); % Update FRET pair plots
        ok1 = 0;
        
        if strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')
            mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle); % Update SE histogram
            ok2 = 0;
        end
    end
end

% Update FRET pair plots
if (~isequal(settings.FRETpairplots,prev.FRETpairplots)) && (strcmp(get(mainhandles.Toolbar_FRETpairwindow,'state'),'on')) && ok1
    FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1, mainhandles.FRETpairwindowHandle,'all'); % Update FRET pair plots
end

% Update E-S histogram plot
if (~isequal(settings.SEplot,prev.SEplot)) && (strcmp(get(mainhandles.Toolbar_histogramwindow,'state'),'on')) && ok2
    mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle); % Update SE histogram
end

% Update groups
if (~isequal(settings.grouping,prev.grouping)) && (settings.grouping.choice)
    updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
    updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
end
