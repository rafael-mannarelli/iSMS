function updateCorrectionFactorPairlist(mainhandle,correctionfactorwindowHandle)
% Updates the trace list in the correction factor window.
%
%    Input:
%     mainhandle                   - handle to the main window (sms)
%     correctionfactorwindowHandle - handle to the correction factor window
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

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(correctionfactorwindowHandle))
    return
elseif (~ishandle(mainhandle)) || (~ishandle(correctionfactorwindowHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
correctionfactorwindowHandles = guidata(correctionfactorwindowHandle); % Handles to the dynamics window

% If there is no data, clear all axes and return
if (isempty(mainhandles.data))
    set(correctionfactorwindowHandles.PairListbox,'String','')
    set(correctionfactorwindowHandles.PairListbox,'Value',1)
    set(correctionfactorwindowHandles.PairCounter,'String','Applicable traces: 0')
    return
end

% Get pairs to list
applicablePairs = getPairs(mainhandle, 'correctionListed', [],[],[], correctionfactorwindowHandle);

%% Update listbox string

npairs = size(applicablePairs,1);
namestr = cell(npairs,1);
for i = 1:npairs
    file = applicablePairs(i,1);
    pair = applicablePairs(i,2);
    
    if mainhandles.settings.correctionfactorplot.factorchoice == 1 
        
        % Donor leakage        
        [mainhandles str] = getnamestr(mainhandles,'Dleakage');
        namestr{i} = str;
        
    elseif mainhandles.settings.correctionfactorplot.factorchoice == 2 
        
        % Direct A pairs
        [mainhandles str] = getnamestr(mainhandles,'Adirect');
        namestr{i} = str;

    elseif mainhandles.settings.correctionfactorplot.factorchoice == 3 
        
        % Gamma factor pairs
        [mainhandles str] = getnamestr(mainhandles,'gamma');
        namestr{i} = str;

    end
end

%% Finalize

% Update handles 
updatemainhandles(mainhandles)

% Set listbox name string
set(correctionfactorwindowHandles.PairListbox,'String', namestr)

% If there are less FRET-pairs than listbox value, set value to last
% FRET-pair and update all plots
selectedPair = get(correctionfactorwindowHandles.PairListbox,'Value');
if npairs < max(selectedPair)
    set(correctionfactorwindowHandles.PairListbox,'Value',npairs)
    updateCorrectionFactorPlots(mainhandle,mainhandles.correctionfactorwindowHandle,'all')
end

% Update counter
set(correctionfactorwindowHandles.PairCounter,'String',sprintf('Applicable traces: %i',npairs))

%% Nested

    function [mainhandles str] = getnamestr(mainhandles, choice)
        
        % If correction factor has not been calculated yet, do it now
        if isempty(mainhandles.data(file).FRETpairs(pair).(choice)) || isempty(mainhandles.data(file).FRETpairs(pair).([choice 'Var']))
            mainhandles = calculateCorrectionFactors(mainhandle,[file pair],choice);
        end
        
        % Standard dev.
        stddev = sqrt( mainhandles.data(file).FRETpairs(pair).([choice 'Var']) );
        
        % String
        str = sprintf('%i,%i  (%.3f+-%.3f)', file, pair, ...
            mainhandles.data(file).FRETpairs(pair).(choice), stddev ); % Change listbox string
        
    end

end