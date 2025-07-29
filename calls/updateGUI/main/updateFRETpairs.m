function mainhandles = updateFRETpairs(mainhandles, files)
% Removes FRET-pairs where either donor or acceptor is deleted or where
% either donor or acceptor is also in another FRET-pair
%
%     Input:
%      mainhandles  - handles structure of the main figure window
%      files        - files. default: all
%
%     Output:
%      mainhandles  - ..
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
if nargin<2 || isempty(files)
    files = get(mainhandles.FilesListbox,'Value'); % Selected movie file
end

% Check data
if isempty(mainhandles.data)
    return
end

%% Check pairs

for i = 1:length(files)
    % Initialize index of pairs to delete
    idx = [];
    
    % File
    file = files(i);
    if isempty(mainhandles.data(file).FRETpairs) % If there are no FRET-pairs, just return
        continue
    end
    
    % D and A peaks
    Dpeaks = mainhandles.data(file).Dpeaks; % All donor peaks
    Apeaks = mainhandles.data(file).Apeaks; % All acceptor peaks
    DpeaksGlobal = mainhandles.data(file).DpeaksGlobal; % All donor peaks
    ApeaksGlobal = mainhandles.data(file).ApeaksGlobal; % All acceptor peaks
    
    % ROI positions
    Droi = round(mainhandles.data(file).Droi); %  [x y width height]
    Aroi = round(mainhandles.data(file).Aroi); %  [x y width height]
    for j = 1:length(mainhandles.data(file).FRETpairs)
        
        % Check if FRET-pair is specified with more than one donor or acceptor
        if size(mainhandles.data(file).FRETpairs(j).Dxy,1) > 1
            mainhandles.data(file).FRETpairs(j).Dxy = mainhandles.data(file).FRETpairs(j).Dxy(1,:);
        end
        if size(mainhandles.data(file).FRETpairs(j).Axy,1) > 1
            mainhandles.data(file).FRETpairs(j).Axy = mainhandles.data(file).FRETpairs(j).Axy(1,:);
        end
        pair = mainhandles.data(file).FRETpairs(j);
        
        % Check if a donor or acceptor is in more than one FRET-pair
        if j < length(mainhandles.data(file).FRETpairs)
            
            % Faster
            temp = [mainhandles.data(file).FRETpairs(j+1:end).Dxy];
            temp = reshape(temp,[2 length(temp)/2])'; % [x1 y1;...]
            if ismember(pair.Dxy,temp,'rows')
                idx = [idx j];
            else
                temp = [mainhandles.data(file).FRETpairs(j+1:end).Axy];
                temp = reshape(temp,[2 length(temp)/2])'; % [x1 y1;...]
                if ismember(pair.Axy,temp,'rows')
                    idx = [idx j];
                end
            end
            % Slower for many pairs:
%             for jj = j+1:length(mainhandles.data(file).FRETpairs)
%                 if (isequal(pair.Dxy, mainhandles.data(file).FRETpairs(jj).Dxy)) || (isequal(pair.Axy, mainhandles.data(file).FRETpairs(jj).Axy))
%                     idx = [idx j];
%                 end
%             end
            
        end
        
        % Check if both donor and acceptor still exists
        if (~ismember(pair.DxyGlobal,DpeaksGlobal,'rows')) || (~ismember(pair.AxyGlobal,ApeaksGlobal,'rows'))
            idx = [idx j];
        end
        
        % If FRET-pair has no molecule group number put it, by default, into group 1
        if isempty(pair.group)
%             mainhandles.data(file).FRETpairs(j).group = 1;
        end
        
        % Check if donor or acceptor is outside the ROI window
%         [mainhandles, Droi, Aroi] = getROI(mainhandles,file,mainhandles.data(file).avgimage);
        if (round(pair.Dxy(1))<1) || (round(pair.Dxy(1))>round(Droi(3))) || (round(pair.Dxy(2))<1) || (round(pair.Dxy(2))>round(Droi(4)))
            idx = [idx j];
        end
        if (round(pair.Axy(1))<1) || (round(pair.Axy(1))>round(Aroi(3))) || (round(pair.Axy(2))<1) || (round(pair.Axy(2))>round(Aroi(4)))
            idx = [idx j];
        end
        
        % Integration range
        if isempty( mainhandles.data(file).FRETpairs(j).Dwh )
            mainhandles.data(file).FRETpairs(j).Dwh = mainhandles.settings.integration.wh; % Width and height of the donor integration area [w h] /pixels
        end
        if isempty( mainhandles.data(file).FRETpairs(j).Awh )
            mainhandles.data(file).FRETpairs(j).Awh = mainhandles.settings.integration.wh; % Width and height of the donor integration area [w h] /pixels
        end
        
        % Background ring definitions
        backspace = mainhandles.data(file).FRETpairs(j).backspace; % Space between donor integration area and background ring /pixels
        backwidth = mainhandles.data(file).FRETpairs(j).backwidth; % Width of background ring /pixels
        if isempty(backspace) || isempty(backwidth)
            mainhandles.data(file).FRETpairs(j).backspace = mainhandles.settings.background.backspace;
            mainhandles.data(file).FRETpairs(j).backwidth = mainhandles.settings.background.backwidth;
        end
        
    end
    
    % Delete FRET pairs
    if ~isempty(idx)
        
        % Delete FRET-pairs with indices idx
        mainhandles.data(file).FRETpairs(idx) = [];
    end
end

%% Update

% Update handles
updatemainhandles(mainhandles)

% Check if deleted pairs are currently plotted/listed in other windows
correctionlistedPairs = [];
plottedPairs = [];
if ~isempty(idx)
    correctionlistedPairs = getPairs(mainhandles.figure1, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle);
    plottedPairs = getPairs(mainhandles.figure1, 'plotted', [], mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);
end

% Update windows where removed FRET pairs are listed/plotted
if ismember(1,ismember(idx,correctionlistedPairs))
    updateCorrectionFactorPairlist(mainhandles.figure1,mainhandles.correctionfactorwindowHandle);
    updateCorrectionFactorPlots(mainhandles.figure1,mainhandles.correctionfactorwindowHandle);
end
if ismember(1,ismember(idx,plottedPairs))
    mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
end
