function mainhandles = openFRETpairbinCallback(FRETpairwindowHandles)
% Callback for opening the FRETpair bin in the FRETpair windowh
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRET pair window
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

% Get mainhandles structure
mainhandles = getmainhandles(FRETpairwindowHandles);
if isempty(mainhandles)
    return
end

%% Open close bin

if ~mainhandles.settings.bin.open
    
    % Open bin
    mainhandles.settings.bin.open = 1;
    updatemainhandles(mainhandles)
    mainhandles = openBin(mainhandles,FRETpairwindowHandles);
    
else
    % Close bin
    mainhandles.settings.bin.open = 0;
    updatemainhandles(mainhandles)
    mainhandles = closeBin(mainhandles);
end

%% UpdateGUI windows

updatemainhandles(mainhandles) % Update mainhandles structure
mainhandles = updateGUIafterNewGroup(mainhandles.figure1); % Update plots, lists, etc
updateFRETpairwindowGUImenus(mainhandles,FRETpairwindowHandles) % Updates the menu checkmark

%% Subroutines

    function mainhandles = openBin(mainhandles, FRETpairwindowHandles)
        
        % Display userguide info box
        textstr = howstuffworksStr('bin');
        mainhandles = myguidebox(mainhandles, 'Open recycle bin', textstr, 'openFRETpairBin',1,'http://isms.au.dk/documentation/recycle-bin/');
        
        % Make new group called 'Recycle bin'
        mainhandles.groups(end+1).name = 'Recycle bin'; % New group name
        mainhandles.groups(end).color = [0 0 0]; % Assign a black color to new group
        
        % Add binned molecules to new group
        for i = 1:length(mainhandles.data)
            
            % All pairs in the bin of file i
            FRETpairsBin = mainhandles.data(i).FRETpairsBin;
            if isempty(FRETpairsBin)
                continue
            end
            
            % Assign binned molecules to recycle group (only)
            for j = 1:length(FRETpairsBin)
                FRETpairsBin(j).group = length(mainhandles.groups);
            end
            
            % Add pairs in bin to data
            n = length(FRETpairsBin);
            if isempty(mainhandles.data(i).FRETpairs)
                mainhandles.data(i).FRETpairs = FRETpairsBin;
                
            else
                mainhandles.data(i).FRETpairs(end+1:end+n) = FRETpairsBin;
            end
            
            % Delete data from bin field structure
            mainhandles.data(i).FRETpairsBin(:) = [];
        end
        updatemainhandles(mainhandles)
        
        % Calculate traces and images
        binPairs = getPairs(mainhandles.figure1,'group','Recycle bin');
        idx = [];
        for i = 1:size(binPairs,1)
            file = binPairs(i,1);
            pair = binPairs(i,2);
            if isempty(mainhandles.data(file).FRETpairs(pair).DDtrace) ...
                    || isempty(mainhandles.data(file).FRETpairs(pair).Etrace)
                idx = [idx i];
            end
        end
        
        % Calculate
        calcPairs = binPairs(idx,:);
        if ~isempty(calcPairs)
            mainhandles = calculateIntensityTraces(mainhandles.figure1,binPairs(idx,:),0);
            mainhandles = calculateMoleculeImages(mainhandles.figure1,binPairs(idx,:),'all');
        end
    end

    function mainhandles = closeBin(mainhandles)
        % Close down bin
        
        % Delete group called, must be positioned before delete group
        binnedPairs = getPairs(mainhandles.figure1,'bin');
        
        % Delete recycle bin group, must be positioned before return
        groupnumber = getbingroup(mainhandles.figure1);
        mainhandles.groups(groupnumber) = [];
        updatemainhandles(mainhandles)
        
        % If there are no pairs in the bin just return now
        if isempty(binnedPairs)
            return
        end
        
        % Delete pairs in the bin group
        mainhandles = deletePairs(mainhandles.figure1,binnedPairs);
        
    end
end
