function [mainhandles fpwHandles] = updateafterReusePairs(mainhandles, fpwHandles, files)
% Update GUI after some pairs have been re-used
%
%    Input:
%     mainhandles   - handles structure of the main window
%     fpwHandles    - handles structure of the FRET-pair window
%     files         - files witht the reused pairs
%
%    Output:
%     mainhandles   - ..
%     fpwHandles    - ..
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


% Remove FRET pairs potentially listed twice
mainhandles = updateFRETpairs(mainhandles, files);

% Update bin counter
updateFRETpairbinCounter(mainhandles.figure1, fpwHandles.figure1);

% Update peak plot and FRET pair lists and counters
ok = 0;
if ismember(get(mainhandles.FilesListbox,'Value'), files)
    mainhandles = updatepeakplot(mainhandles,'FRET'); % This will also run updateFRETpairs, updateFRETpairlist, updatemainhandles, highlightFRETpair, and updategrouplist
    ok = 1;
    
else
    % These would have been run by updatepeakplot
    updatepeakcounter(mainhandles) % Updates the peak counters in the sms window
    updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle); % Update the FRET pair list of the FRET-pair window (if open)
    updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
end

% Update FRETpairwindowPlots if reusing warrants a new pair selection
[mainhandles, fpwHandles] = FRETpairlistboxCallback(fpwHandles.figure1);
% FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'all'); % Updates the intensity traces and molecule images
% FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);

% Update correction factor window
% updateCorrectionFactorPairlist(FRETpairwindowHandles.main,mainhandles.correctionfactorwindowHandle)

% Reset last binned pairs
mainhandles.settings.bin.lastpair = [];
updatemainhandles(mainhandles)

% Return focus to current window
if ok
    figure(fpwHandles.figure1)
end

