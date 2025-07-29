function mainhandles = laserspotprofilesSettings(mainhandles)
% Callback for laser spot profile settings menu item
%
%     Input:
%      mainhandles   - handles structure of the main window
%
%     Output:
%      mainhandles   - ..
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

%% Open dialog
prev = mainhandles;

temp_handles = spotprofileSettings(mainhandles.figure1);
if isempty(temp_handles)
    return
end

mainhandles = temp_handles;

%% Update intensity traces

if ~isequal(prev.settings.spot.choice,mainhandles.settings.spot.choice) || mainhandles.settings.spot.choice
    
    % Update the intensity traces, if the FRETpair window is open
    if (strcmp(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on'))
        
        % Identify which files to update
        files = [];
        if ~isequal(prev.settings.spot.choice,mainhandles.settings.spot.choice)
            files = 1:length(mainhandles.data);
        else
            for i = 1:length(mainhandles.data)
                if ~isequal(mainhandles.data(i).GspotProfile,prev.data(i).GspotProfile) || ~isequal(mainhandles.data(i).RspotProfile,prev.data(i).RspotProfile) || ~isequal(mainhandles.data(i).grRatio,prev.data(i).grRatio)
                    files = [files i];
                end
            end
        end
        if isempty(files) % If there is not change in any of the files
            return
        end
        
        % Get pairs of selected files and update traces
        selectedPairs = getPairs(mainhandles.figure1, 'File', files); % Returns all FRET pairs in files chosen to be compensated for drift [file pair;...]
        if isempty(selectedPairs)
            return
        end
%         mainhandles = calculateIntensityTraces(mainhandles.figure1, selectedPairs);
        mainhandles = correctTraces(mainhandles.figure1,selectedPairs);
%         mainhandles = spotCorrect(mainhandles,selectedPairs);
        FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle,'traces');
        FRETpairwindowHandles = updateMoleculeFrameSliderHandles(mainhandles.figure1,mainhandles.FRETpairwindowHandle);
        
    end
    
    % Update the histogramwindow if it's open
    if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on'))
        plottedPairs = getPairs(mainhandles.figure1, 'Plotted', [], mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);
        if ismember(1,ismember(files,plottedPairs(:,1)))
            mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
        end
    end
    
end
