function mainhandles = correctionfactorEditboxCallback(FRETpairwindowHandles, choice)
% Callback for change in correction factor editboxes in the FRET pair
% window
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
%     choice                 - 'gamma', 'Adirect', 'Dleakage'
%
%    Output:
%     mainhandles            - handles structure of the main window
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

% Turn of integration ROIs and get mainhandles
FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles);
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% SelectedPairs
if mainhandles.settings.corrections.molspec
    selectedPairs = getPairs(FRETpairwindowHandles.main,'Selected');
end

%% Callback

if strcmpi(choice,'gamma')
    
    mainhandles = update(mainhandles, FRETpairwindowHandles.GammaEditbox);
    
elseif strcmpi(choice,'Adirect')
    
    mainhandles = update(mainhandles, FRETpairwindowHandles.AdirectEditbox);
    
elseif strcmpi(choice,'Dleakage')
    
    mainhandles = update(mainhandles, FRETpairwindowHandles.DleakEditbox);
    
end

%% Nested

    function mainhandles = update(mainhandles,hEdit)
        
        % Entered value
        val = str2num(get(hEdit,'String'));
        
        if mainhandles.settings.corrections.molspec
            
            % Molecule-specific values
            if val>=0
                
                % Change value for all selected pairs
                for i = 1:size(selectedPairs,1)
                    file = selectedPairs(i,1);
                    pair = selectedPairs(i,2);
                    mainhandles.data(file).FRETpairs(pair).(choice) = val;
                end
                
                % Update
                mainhandles = updateGUIs(mainhandles);
                
                % Update the SE plot only if pair is plotted
                plottedPairs = getPairs(FRETpairwindowHandles.main,'Plotted');
                if ismember(1,ismember(selectedPairs,plottedPairs,'rows','legacy'))
                    mainhandles = updateSEplot(FRETpairwindowHandles.main,...
                        FRETpairwindowHandles.figure1, ...
                        mainhandles.histogramwindowHandle,...
                        'all');
                end
                
            else
                set(hEdit, 'String',mainhandles.settings.corrections.(choice))
            end
            
        else
            
            % Global values
            if ~isequal(val, mainhandles.settings.corrections.(choice)) ...
                    && val>=0
                
                % Update handles structure and GUI
                mainhandles.settings.corrections.(choice) = val;
                mainhandles = updateGUIs(mainhandles);
                
                % Update the SE plot
                mainhandles = updateSEplot(FRETpairwindowHandles.main,...
                    FRETpairwindowHandles.figure1, ...
                    mainhandles.histogramwindowHandle,...
                    'all');
                
            else
                set(hEdit, 'String',mainhandles.settings.corrections.(choice))
            end
            
        end
    end

    function mainhandles = updateGUIs(mainhandles)
        
        % Update handles structure
        updatemainhandles(mainhandles)
        
        % Calculate new traces
        mainhandles = correctTraces(mainhandles.figure1, 'all');
        
        % Update plots
        if mainhandles.settings.excitation.alex
            FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1, 'traces','ADcorrect');
        else
            FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1, 'traces','all');
        end
        
        % Update the SE plot
        mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1, mainhandles.histogramwindowHandle,'all');
        
    end
end