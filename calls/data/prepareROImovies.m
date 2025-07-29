function [mainhandles, ROImovies, message] = prepareROImovies(mainhandles, selectedPairs)
% Prepares all ROI movies of selectedPairs in a structure ROImovies. This
% returns drift-corrected movies if using drift-correction or raw movies
% if not.
%
%    Input:
%     mainhandles   - handles structure of the main figure window
%     selectedPairs - [file pair;...] pairs of which the corresponding ROI
%                     movies are saved
%
%    Output:
%     mainhandles   - handles structure of the main window
%     ROImovies     - Structure with fields DD, AD and AA
%     message       - Message about missing ROI movies
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

% Initialize
ROImovies = struct('DD',[],'AD',[],'AA',[]);
message = '';
if isempty(mainhandles)
    return
end

% Defaults
if nargin<2
    selectedPairs = getPairs(mainhandles.figure1, 'all');
end

% Initialize
message = sprintf('Traces in the following files were not calculated because the corresponding ROI movie is deleted:\n'); % Initialize message
run = 0; % Running parameter
ok = 0; % Determining whether to show message about deleted ROI movies

% Prepare ROI movie structures
filechoices = unique(selectedPairs(:,1)); % All files to be analysed
ROImovies.DD = cell(1,max(filechoices));
ROImovies.AD = cell(1,max(filechoices));
ROImovies.AA = cell(1,max(filechoices));

%% Get all movies

for i = filechoices(:)' % Loop over all files
    run = run+1;
    file = filechoices(run);
    
    % Get ROI movie data
    if mainhandles.data(file).drifting.choice ...
            && ~isempty(mainhandles.data(file).DD_ROImovieDriftCorr) 
        
        % Use drift-corrected movie
        ROImovies.DD{i} = mainhandles.data(file).DD_ROImovieDriftCorr; % All D-ROI D-exc frames
        ROImovies.AD{i} = mainhandles.data(file).AD_ROImovieDriftCorr; % All A-ROI D-exc frames
        ROImovies.AA{i} = mainhandles.data(file).AA_ROImovieDriftCorr; % All A-ROI A-exc frames
        
    else
        
        % Make ROI movie, if not saved already
        if isempty(mainhandles.data(file).DD_ROImovie) ...
                && ~isempty(mainhandles.data(file).imageData) 
            
            mainhandles = saveROImovies(mainhandles, file);
        
        elseif isempty(mainhandles.data(file).DD_ROImovie) ...
                && isempty(mainhandles.data(file).imageData) 
            
            % If ROI movie and raw movie have been deleted
            message = sprintf('%s\n- %s',message,mainhandles.data(file).name); % update message string
            ok = 1;
            continue
        end
        
        ROImovies.DD{i} = mainhandles.data(file).DD_ROImovie; % All D-ROI D-exc frames
        ROImovies.AD{i} = mainhandles.data(file).AD_ROImovie; % All A-ROI D-exc frames
        ROImovies.AA{i} = mainhandles.data(file).AA_ROImovie; % All A-ROI A-exc frames
        
    end
    
end

%% Message

if ok == 0
    message = '';
end
