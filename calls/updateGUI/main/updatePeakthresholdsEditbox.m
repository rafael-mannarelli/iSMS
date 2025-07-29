function mainhandles = updatePeakthresholdsEditbox(mainhandles,type)
% Updates the peakfinder intensity thresholds editboxes in the main window
%
%     Input:
%      mainhandles   - handles structure of the main window
%      type          - 1/2. 1 if function was called by change in editbox
%                      (so that settings structure must be changed) or 2 if
%                      function was called because settings structure was
%                      changed so that editbox string must be changed
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

%% Initialize

if nargin<2
    type = 1;
end

%% Update

if type==1
    % Update handles structure according to editbox
    
    % Entered values
    Dvalue = str2num(get(mainhandles.DPeakfinderThresholdEditbox,'String'));
    Avalue = str2num(get(mainhandles.APeakfinderThresholdEditbox,'String'));
    
    % Update
    mainhandles.settings.peakfinder.DpeakIntensityThreshold = Dvalue;
    mainhandles.settings.peakfinder.ApeakIntensityThreshold = Avalue;
    updatemainhandles(mainhandles)
    
else
    % Update editbox according to handles structure
    
    % Entered values
    Dvalue = mainhandles.settings.peakfinder.DpeakIntensityThreshold;
    Avalue = mainhandles.settings.peakfinder.ApeakIntensityThreshold;
    
    % Update
    set(mainhandles.DPeakfinderThresholdEditbox, 'String',Dvalue);
    set(mainhandles.APeakfinderThresholdEditbox, 'String',Avalue);
end
