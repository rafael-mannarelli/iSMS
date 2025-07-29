function updateCorrectionFactors(mainhandle,FRETpairwindowHandle)
% Updates the values of the gamma, A-direct and D-leakage editboxes of the
% FRETpairwindow
%
%    Input:
%     mainhandle           - handle to the main figure window
%     FRETpairwindowHandle - handle to the FRETpairwindow
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
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
FRETpairwindowHandles = guidata(FRETpairwindowHandle); % Handles to the FRET pair window

%% Update

if mainhandles.settings.corrections.molspec
    
    % Checkbox
    set(FRETpairwindowHandles.molspecCheckbox,'Value',1)
    
    % Selected FRETpairs
    selectedPairs = getPairs(mainhandle,'selected',[],FRETpairwindowHandle);
    if isempty(selectedPairs)
        setDefaults()
        return
    end
    
    % Check selection of multiple pairs
    temp = nan(size(selectedPairs,1));
    gamma = temp;
    Adirect = temp;
    Dleakage = temp;
    for i = 1:size(selectedPairs,1)
        file = selectedPairs(i,1);
        pair = selectedPairs(i,2);
        
        % Saved correction factors for this molecule
        if ~isempty(mainhandles.data(file).FRETpairs(pair).gamma)
            gamma(i) = mainhandles.data(file).FRETpairs(pair).gamma;
        end
        if ~isempty(mainhandles.data(file).FRETpairs(pair).Adirect)
            Adirect(i) = mainhandles.data(file).FRETpairs(pair).Adirect;
        end
        if ~isempty(mainhandles.data(file).FRETpairs(pair).Dleakage)
            Dleakage(i) = mainhandles.data(file).FRETpairs(pair).Dleakage;
        end
        
    end
    
    % Default for empty fields
    gamma(isnan(gamma)) = mainhandles.settings.corrections.gamma;
    Adirect(isnan(Adirect)) = mainhandles.settings.corrections.Adirect;
    Dleakage(isnan(Dleakage)) = mainhandles.settings.corrections.Dleakage;
    
    % Finalize
    gamma = unique(gamma);
    Adirect = unique(Adirect);
    Dleakage = unique(Dleakage);
    
    % If there are more than one factor for the selected molecules
    if length(gamma)>1
        gamma = [];
    end
    if length(Adirect)>1
        Adirect = [];
    end
    if length(Dleakage)>1
        Dleakage = [];
    end
    
    % Update editbox
    set(FRETpairwindowHandles.GammaEditbox, 'String',gamma)
    set(FRETpairwindowHandles.AdirectEditbox, 'String',Adirect)
    set(FRETpairwindowHandles.DleakEditbox, 'String',Dleakage)
else
    
    % Checkbox
    set(FRETpairwindowHandles.molspecCheckbox,'Value',0)
    
    setDefaults();
end

%% Nested

    function setDefaults()
        set(FRETpairwindowHandles.GammaEditbox,'String',mainhandles.settings.corrections.gamma)
        set(FRETpairwindowHandles.AdirectEditbox,'String',mainhandles.settings.corrections.Adirect)
        set(FRETpairwindowHandles.DleakEditbox,'String',mainhandles.settings.corrections.Dleakage)
    end
end