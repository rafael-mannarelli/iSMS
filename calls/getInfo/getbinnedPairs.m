function FRETpairs = getbinnedPairs(mainhandle, choice, subchoice)
% Returns all FRET pairs in the recycle bin according choice
%
%   Input:
%    mainhandle  - handle to the main window
%    choice      - 'all', 'file'
%    subchoice   - filechoice if choice='file'
%
%   Output:
%    FRETpairs   - structure with FRETpairs from the bin
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
if nargin<2
    choice = 'all';
end

% Initialize
FRETpairs = [];
if isempty(mainhandle) || ~ishandle(mainhandle)
    return
end

% Get mainhandles
mainhandles = guidata(mainhandle);
if isempty(mainhandles.data)
    return
end

%% Get pairs

if strcmpi(choice,'all')
    % Return all pairs in bin
    
    filechoices = 1:length(mainhandles.data);
    FRETpairs = getbinnedPairs2(filechoices);
    
elseif strcmpi(choice,'file')
    % Returns all binned pairs from files subchoice
    
    filechoices = subchoice;
    if isempty(filechoices)
        return
    end
    FRETpairs = getbinnedPairs2(filechoices);
end

    function FRETpairs = getbinnedPairs2(filechoices)
        
        % Initialize FRETpairs structure
        FRETpairs = mainhandles.data(1).FRETpairs;
        FRETpairs(:) = [];
        FRETpairs = orderfields(FRETpairs);
        
        
        if mainhandles.settings.bin.open
            % Get binned pairs from the group called 'Recycle bin'
            binnedPairs = getPairs(mainhandles.figure1,'bin'); % [file pair;...]
            if isempty(binnedPairs)
                return
            end
            
            % Collect all binned pairs in one structure
            for j = 1:size(binnedPairs,1)
                file = binnedPairs(j,1);
                pair = binnedPairs(j,2);
                
                if isempty(FRETpairs)
                    FRETpairs = mainhandles.data(file).FRETpairs(pair);
                else
                    FRETpairs(end+1) = mainhandles.data(file).FRETpairs(pair);
                end
                
            end
            
        else
            
            for i = 1:length(filechoices)
                filechoice = filechoices(i);
                % Get binned pairs from the bin structure
                
                % Number of binned pairs
                n = length(mainhandles.data(filechoice).FRETpairsBin);
                if n==0
                    continue
                end
                
                % Sort fields so the match
                FRETpairsBin = orderfields(mainhandles.data(filechoice).FRETpairsBin);
                
                % Binned FRET pairs in file i
                if isempty(FRETpairs)
                    FRETpairs = FRETpairsBin;
                else
                    FRETpairs(end+1:end+n) = FRETpairsBin;
                end
            end
        end
        
    end
end
