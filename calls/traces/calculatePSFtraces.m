function mainhandles = calculatePSFtraces(mainhandle, selectedPairs, channel)
% Calculates the FRET pair DD, AD, DA and AA intensity traces and puts them
% in the mainhandle.data.DDtrace/ADtrace..etc structure fields. Also
% calculates the background traces.
%
%    Input:
%     mainhandle    - handle to main window (sms)
%     selectedPairs - choice of FRET-pair: all pairs in all files ([] or
%                    'all'), a selected subset of FRET-pairs ([filechoice
%                    pairchoice; filechoice pairchoice;...])
%     channel       - 'DD', 'AD', 'AA', or 'all'
%
%    Output:
%     mainhandles   - handles structure of the main window

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

%% Check input

if nargin<2
    selectedPairs = 'all'; % Default: Calculate all FRETpairs
end
if nargin<3
    channel = 'AA'; % Default: Calculate AA channel only
end

% Check handle
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    mainhandles = [];
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
if isempty(mainhandles.data)
    return
end

% If calculating all FRET pairs, make an "all" choice matrix
if (isempty(selectedPairs)) || ((ischar(selectedPairs)) && (strcmpi(selectedPairs,'all')))
    selectedPairs = getPairs(mainhandle, 'All');
end

% If there are no FRET-pairs, return
if isempty(selectedPairs)
    return
end

% Prepare all movies in one structure (for better code overview)
[mainhandles ROImovies message] = prepareROImovies(mainhandles, selectedPairs); % Returns relevant ROI movies in a structure with fields DD, AD and AA

% Initiate progressbar
if size(selectedPairs,1)==1 && strcmpi(channel,'all')
    myprogressbar(sprintf('Calculating PSF traces of %i pair',size(selectedPairs,1)),'Progress of current pair')
elseif size(selectedPairs,1)==1 && ~strcmpi(channel,'all')
    myprogressbar(sprintf('Calculating PSF trace of %i pair',size(selectedPairs,1)),'Progress of current pair')
else
    myprogressbar(sprintf('Calculating PSF traces of %i pairs',size(selectedPairs,1)),'Progress of current pair')
end
if strcmpi(channel,'all')
    cbar = 3; % Counter for the progressbar
else
    cbar = 1; % Counter for the progressbar
end
runbar1 = 0; % Running counter for progressbar 1

%% Calculate

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    % Get psf images used for generating initial guess
    nframes = 1:50;
    [DDimage, DidxInt] = getPSFimages(mainhandles, [file pair], nframes, 'DD');
    [ADimage, AidxInt] = getPSFimages(mainhandles, [file pair], nframes, 'AD');
    AAimage = getPSFimages(mainhandles, [file pair], nframes, 'AA');
%     [DDimage, ADimage, AAimage, DidxInt, AidxInt] = getPSFimages(mainhandles, [file pair], nframes);
    
    % Progressbar counters
    runbar2 = 0;
    
    % Calculate
    if strcmpi(channel,'DD') || strcmpi(channel,'all')
        mainhandles.data(file).FRETpairs(pair).DDGaussianTrace = getPSFtrace(DDimage, DidxInt, ROImovies.DD{file});        
    end
    if strcmpi(channel,'AD') || strcmpi(channel,'all')
        mainhandles.data(file).FRETpairs(pair).ADGaussianTrace = getPSFtrace(ADimage, AidxInt, ROImovies.AD{file});
    end
    if strcmpi(channel,'AA') || strcmpi(channel,'all')        
        mainhandles.data(file).FRETpairs(pair).AAGaussianTrace = getPSFtrace(AAimage, AidxInt, ROImovies.AA{file});
    end
    
end

% Close progressbar
progressbar(1)

% Update
updatemainhandles(mainhandles)
updatePSFwindowPairList(mainhandle, mainhandles.psfwindowHandle) % Update pair listbox in psf window for boldfacing purposes

% Show message about deleted ROI movies
if ~isempty(message)
    message = sprintf(...
        '%s\n\nYou can reload raw movies from the Memory menu of the main iSMS window.\n',message);
    mymsgbox(message,'Deleted data')
    pause(1)
end

%% Subroutines

    function GaussianTrace = getPSFtrace(startImage, idxInt, ROImovie)
        % Initiate
        msize = size(ROImovie,3); % Movie length
        sizeROI = [size(ROImovie,1) size(ROImovie,2)]; % Frame size
        
        % Get start guess + lower and upper bounds (lb, ub)
        [initialguess, lb, ub] = initialGuessGaussian(startImage);
        
        % Preallocate array for Gaussian parameters
        GaussianTrace = zeros(msize,7);
        
        % Progressbar counters, total
        bar1tot = msize*cbar*size(selectedPairs,1); 
        bar2tot = msize*cbar;
        
        % Fit
        for j = 1:msize % Loop over all frames
            
            % idxInt2 are the indices defining the pixels of interest
            % within the ROI movie
            idxInt2 = idxInt+prod(sizeROI)*(j-1); % Shift linear indices to match next array dimension (frame)
            
            % Images to fit
            image = double( ROImovie(idxInt2)' ); % Flip because of the linear index format
            
            % Optimization threshold
            threshold = mainhandles.settings.integration.threshold;
            
            if mainhandles.settings.psfWindow.type==1 % Gaussian maximum likelihood estimator (default for 
                
                % Parameters = [x0 y0 sx sy theta background amplitude]
                [params, count, grid, imgFit] = MLEwG(image, initialguess, lb, ub, threshold);
                
            elseif mainhandles.settings.psfWindow.type==2 % Gaussian mask estimator / least squares fit
                
                % Parameters = [x0 y0 sx sy theta background amplitude]
                [params, count, grid, imgFit] = GME(image, initialguess, lb, ub, threshold);
                
            end
            
            % Optimized parameters
            GaussianTrace(j,:) = params;
            
            % Update progressbar
            runbar1 = runbar1+1;
            runbar2 = runbar2+1;
            progressbar(runbar1/bar1tot, runbar2/bar2tot)
        end
    end

end