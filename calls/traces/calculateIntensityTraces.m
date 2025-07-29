function [mainhandles FRETpairwindowHandles] = calculateIntensityTraces(mainhandle, selectedPairs, updateCorrectionFactorWindow, nfirst, showMessage, channels)
% Calculates intensity and background traces of selectedPairs and stores
% the calculated traces in the mainhandles structure.
%
%    Input:
%     mainhandle     - handle to main window (sms)
%     selectedPairs  - choice of FRET-pair: all pairs in all files ([] or
%                      'all'), a selected subset of FRET-pairs ([filechoice
%                      pairchoice; ;...])
%     updateCorrectionFactorWindow - 0/1 determines whether to update the
%                      correctionfactorwindow in the end. This is 0 if the
%                      calculated traces are not gonna be stored, but just
%                      used for simulation purposes.
%     nfirst         - first n frames used in calculation. Default: all
%     showMessage    - 0/1 whether to show message about missing data
%     channels       - 'all', 'DD', 'AD', 'AA', 'FRET'
%
%
%    Output:
%     mainhandles           - handles structure of the main window
%     FRETpairwindowHandles - handles structure of the FRETpair window
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

% Default input parameters
if nargin<2 || isempty(selectedPairs)
    selectedPairs = 'all'; % Calculate all FRETpairs
end
if nargin<3 || isempty(updateCorrectionFactorWindow)
    updateCorrectionFactorWindow = 1; % Update the correction factor window
end
if nargin<4 || isempty(nfirst)
    nfirst = []; % Calculate full movies
end
if nargin<5 || isempty(showMessage)
    showMessage = 1;
end
if nargin<6 || isempty(channels)
    channels = 'all';
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    mainhandles = [];
    FRETpairwindowHandles = [];
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
if isempty(mainhandles.data)
    FRETpairwindowHandles = [];
    return
end
if ~isempty(mainhandles.FRETpairwindowHandle) && ishandle(mainhandles.FRETpairwindowHandle)
    FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
end

% If calculating all FRET pairs, make an "all" choice matrix
if (isempty(selectedPairs)) || ((ischar(selectedPairs)) && (strcmpi(selectedPairs,'all')))
    selectedPairs = getPairs(mainhandle, 'All');
end

% If there are no FRET-pairs, return
if isempty(selectedPairs)
    return
end

% Remove duplicate pairs
selectedPairs = unique(selectedPairs,'rows');

% Prepare all movies in one structure (for better code overview)
[mainhandles ROImovies message] = prepareROImovies(mainhandles, selectedPairs); % Returns relevant ROI movies in a structure with fields DD, AD and AA

% Open progressbar
[ppm, progressStepSize] = startProgressbar(1);

%% Calculate raw traces

% Loop all FRET pairs
for i = 1:size(selectedPairs,1)
    
    % Prepare calculation
    file = selectedPairs(i,1); % File
    pair = selectedPairs(i,2); % Pair
    
    if isempty(ROImovies.DD{file})
        % Continue to next if ROI movie does not exist
        startProgressbar(2);
        continue
    end
    
    % Calculate D and A traces
    if ~strcmpi(channels,'AD') && ~strcmpi(channels,'AA')
        [mainhandles] = calculateTrace(mainhandles,'DD');
    end
    if ~strcmpi(channels,'DD') && ~strcmpi(channels,'AA')
        [mainhandles] = calculateTrace(mainhandles,'AD');
    end    
    
    % Calculate AA trace
    if ~strcmpi(channels,'FRET')
        [mainhandles] = calculateTrace(mainhandles,'AA');
    end
    
    % Update progressbar
    if mainhandles.settings.integration.type==1 && size(selectedPairs,1)>1        
        progressbar(i/size(selectedPairs,1))
    end
    
end

% Update handles structure
updatemainhandles(mainhandles) % Update handles structure

%% Close progressbar, if it's not already closed

startProgressbar(0);

%% Show message about deleted ROI movies

if showMessage && ~isempty(message)
    
    % Dialog about missing raw data
    message = sprintf(...
        '%s\n\nYou can reload raw movies from the Memory menu of the main iSMS window.\n',message);
    h = mymsgbox(message,'Deleted data');
%     movegui(h,'top')
%     pause(1) % Wait for user to see it
    
end

%% Calculate corrected traces

mainhandles = correctTraces(mainhandle, selectedPairs);

%% Update correction factors

if updateCorrectionFactorWindow
    
    % Make pairs re-applicable for correction factor calculation. Reset the
    % correction factors stored for each pair
    for i = 1:size(selectedPairs,1)
        mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).Dleakage = [];
        mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).Adirect = [];
        mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).gamma = [];
    end
    updatemainhandles(mainhandles)
    
    % Pairs listed in the correction factor window
    listedPairs = getPairs(mainhandle, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle);
    
    if ismember(1,ismember(selectedPairs,listedPairs,'rows','legacy'))
        % Update correction factor window listbox
        updateCorrectionFactorPairlist(mainhandle,mainhandles.correctionfactorwindowHandle)
        
        plottedPairs = getPairs(mainhandle, 'correctionSelected', [],[],[], mainhandles.correctionfactorwindowHandle);
        if ismember(1,ismember(selectedPairs,plottedPairs,'rows','legacy'))
            % Update correction factor plots
            updateCorrectionFactorPlots(mainhandle,mainhandles.correctionfactorwindowHandle)
        end
    end
end

%% Filter pairs

[mainhandles, FRETpairwindowHandles] = filterPairs(mainhandle,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,selectedPairs);

%% Nested

    function [ppm, progressStepSize] = startProgressbar(choice,jprog,ntrace,id)
        %% Regular
        
        % Update progressbar or close it down depending on choice
        ppm = [];
        progressStepSize = [];
        
        if strcmpi(channels,'FRET')
            nchannels = 2;
        elseif strcmpi(channels,'DD') || strcmpi(channels,'AD') || strcmpi(channels,'AA')
            nchannels = 1;
        else
            nchannels = 3;
        end
        
        if choice==0
            
            % Close down progressbar and return
            try
                if mainhandles.settings.performance.parallel && mainhandles.settings.integration.type~=1
                    delete(ppm) % Progressbar of parallel computing
                else
                    progressbar(1) % Progressbar of regular computing
                end
            end
            return
            
        elseif choice==1
            % Initialize
            % no return here
            
        elseif choice==2
            
            % Update progressbar due to missing raw data
            try
                if mainhandles.settings.integration.type == 2 % If using Gaussian fitting
                    progressbar(1,i/size(selectedPairs,1))
                else
                    progressbar(i/size(selectedPairs,1))
                end
            end
            return
            
        elseif choice==3
            % Update progressbar within Gaussian fitting routine
            try
                
                if mainhandles.settings.performance.parallel
                    
                    % Correct running indices
                    if strcmpi(id,'AD')
                        jprog = jprog+1;
                    elseif strcmpi(id,'AA') && ~strcmpi(channels,'AA')
                        jprog = jprog+2;
                    end
                    
                    if size(selectedPairs,1)==1
                        progressbar(jprog/nchannels) % A one-bar progressbar
                    else
                        tot = size(selectedPairs,1)*nchannels;
                        cur = jprog+(i-1)*nchannels;
                        progressbar(cur/tot,jprog/nchannels)
                    end
                    
                else
                
                    % Correct running indices
                    nframes = nchannels*ntrace; % total number of frames per molecule (3 channels with ntrace frames)
                    if strcmpi(id,'AD')
                        jprog = jprog+ntrace;
                    elseif strcmpi(id,'AA') && ~strcmpi(channels,'AA')
                        jprog = jprog+2*ntrace;
                    end
                    
                    if size(selectedPairs,1)==1
                        progressbar(jprog/nframes) % A one-bar progressbar
                    else
                        tot = size(selectedPairs,1)*nframes;
                        cur = (jprog+(i-1)*nframes-1);
                        progressbar(cur/tot,jprog/nframes)
                    end
                end
            end
            return
        end
        
            
        %% Gaussian
        
        if mainhandles.settings.integration.type==1
            % Aperture photometry
            if size(selectedPairs,1)>1
                myprogressbar(sprintf('Calculating traces of %i molecules',size(selectedPairs,1))) % A one-bar progressbar
            end
            
        else
            
            % Gaussian PSFs
            if size(selectedPairs,1)==1
                myprogressbar(sprintf('Calculating traces of 1 molecule using Gaussian PSFs',size(selectedPairs,1))) % A one-bar progressbar
            else
                myprogressbar(sprintf('Fitting Gaussian PSFs: Molecule (%i in total)',size(selectedPairs,1)),'Frame') % A two bar progressbar
            end
        end
        
    end

    function mainhandles = calculateTrace(mainhandles,id)        
        %% Initialize
        % id    - 'DD', 'AD', 'AA'
        
        id1 = id(1);
        I = mainhandles.data(file).FRETpairs(pair).([id 'trace']);
        
        % Determine dark state intervals to be used for background
        [backidx, bleachidx, blinkidx] = getbackidx();
        
        % Frames used in the calculation
        nfull = size(ROImovies.(id){file},3);
        
        % ROI movies
        if isempty(ROImovies.(id){file})
            return
        
        elseif isempty(nfirst) || nfirst==nfull  
            
            % Use full movie
            ROImovie = ROImovies.(id){file};
        else
            
            % Don't include frames outside length of movie
            if nfirst>nfull
                nfirst = nfull;
            end 
            ROImovie = ROImovies.(id){file}(:,:,1:nfirst);
        end
        
        % Movie size
        sizeROI = [size(ROImovie,1) size(ROImovie,2)];
        npixels = sizeROI(1)*sizeROI(2);
        n = size(ROImovie,3); % Trace length
        
        % Pair positions
        xy = mainhandles.data(file).FRETpairs(pair).([id1 'xy']); % Center position of peak
        wh = mainhandles.data(file).FRETpairs(pair).([id1 'wh']); % Width and height of the integration area [w h] /pixels
        
        %% Calculate traces
        
        % Check pairs integrity before starting calculation
        mainhandles = checkPairs(mainhandles);
        
        if mainhandles.settings.integration.type==1
            
            % Aperture photometry
            [I, back] = calculateApertureTrace();
            
        else
            % Gaussian PSFs
            [I, back, GaussianTrace] = calculateGaussianTrace();
            
            % Store traces with fitted Gaussian parameters
            mainhandles.data(file).FRETpairs(pair).([id 'GaussianTrace']) = GaussianTrace;
        end
        
        %% Calculate background finally, taking dark states and frame
        % averaging into account
        back = finalizeBackgroundTrace(back);
        
        %% Subtract background from raw traces
        if mainhandles.settings.background.choice && mainhandles.settings.integration.type==1 % Background already taken into account for Gaussian psf traces
            I = I - back;
        end
        
        %% Update handles structure
        mainhandles.data(file).FRETpairs(pair).([id 'trace']) = I; % Intensity trace
        mainhandles.data(file).FRETpairs(pair).([id 'back']) = back; % Background
        
        %% Nested
        
        % Checks if all pairs have all necessary parameters defined
        function mainhandles = checkPairs(mainhandles)
            % Check that masks are the same size as the ROI
            
            % Masks indices
            intMask = mainhandles.data(file).FRETpairs(pair).([id1 'intMask']);
            backMask = mainhandles.data(file).FRETpairs(pair).([id1 'backMask']);
            
            % If mask is different from movie, make a new mask
            if (~isequal(size(intMask),sizeROI)) || (~isequal(size(backMask),sizeROI))
                
                % Get masks for integration
                [intMask, backMask] = getMask(...
                    sizeROI, xy(1), xy(2), wh(1), wh(2),...
                    'both',  mainhandles.data(file).FRETpairs(pair).backwidth,  mainhandles.data(file).FRETpairs(pair).backspace);
                
                % Store new masks
                mainhandles.data(file).FRETpairs(pair).([id1 'intMask']) = intMask;
                mainhandles.data(file).FRETpairs(pair).([id1 'backMask']) = backMask;
            end
            
            % Check that D and A aperture sizes are of the same size
            if mainhandles.settings.integration.equalPixels ...
                    && strcmpi(id,'AD') % Important to only make this check for AD
                
                % Number of D and A pixels within the apertures
                DidxInt = find( mainhandles.data(file).FRETpairs(pair).DintMask );
                AidxInt = find( mainhandles.data(file).FRETpairs(pair).AintMask );
                
                % Correct so the number is the same
                if length(DidxInt)~=length(AidxInt)
                    mainhandles = correctMask(mainhandles, [file pair]);
                end
                
            end
            
        end
        
        % Calculate trace using apertures
        function [I, back] = calculateApertureTrace()
            % Calculates intensity traces using intensity masks. Made as a
            % nested function for code overview
            
            % Initialize
            I = zeros(n,1); % Trace
            back = zeros(n,1);
            
            % Masks indices
            intMask = mainhandles.data(file).FRETpairs(pair).([id1 'intMask']);
            backMask = mainhandles.data(file).FRETpairs(pair).([id1 'backMask']);
            
            % Convert to linear indices
            idxInt = find(intMask);
            idxBack = find(backMask);
            
            % Keep all traces
            keepAllTraces = getappdata(0,'keepalltraces');
            
            allbacks = {};
            allIs = {};
            for j = 1:n % Loop over all frames
                
                % idxInt2 are the indices defining the pixels of interest
                % within the ROI movie
                idxInt2 = idxInt+npixels*(j-1); % Shift linear indices to match next array dimension (frame)
                
                % Counted photons
                I(j) = sum( ROImovie(idxInt2) ); % Sum pixel values
                
                % Background as average of background pixels, if not using
                % intensities after bleaching (the latter is done later)
                idxBack2 = idxBack+npixels*(j-1); % Shift linear indices to match next array dimension
                
                if mainhandles.settings.background.backtype==1
                    back(j) = (sum(ROImovie(idxBack2))/length(idxBack2)) *length(idxInt2); % Mean multiplied to match number of pixels in integration area
                elseif mainhandles.settings.background.backtype==2
                    back(j) = median(ROImovie(idxBack2))*length(idxInt2); % Multiplied to match number of pixels in integration area
                else
                    prct = mainhandles.settings.background.prctile;
                    back(j) = prctile(ROImovie(idxBack2),prct)*length(idxInt2); % Multiplied to match number of pixels in integration area
                end
                
                % Store traces
                if ~isempty(keepAllTraces)
                    allIs{j} = ROImovie(idxInt2);
                    allbacks{j}= ROImovie(idxBack2);
                end
            end
            
            % Send all traces to appdata (used by apertureplotCallback.m)
            if ~isempty(keepAllTraces)
                if strcmpi(id,'DD')
                    setappdata(0,'allIsDD',allIs)
                    setappdata(0,'allbacksDD',allbacks)
                elseif strcmpi(id,'AD')
                    setappdata(0,'allIsAD',allIs)
                    setappdata(0,'allbacksAD',allbacks)
                elseif strcmpi(id,'AA')
                    setappdata(0,'allIsAA',allIs)
                    setappdata(0,'allbacksAA',allbacks)
                end
            end
            
        end
        
        % Calculate trace using Gaussian PSFs
        function [I, back, GaussianTrace] = calculateGaussianTrace()
            % Calculates intensity traces using Gaussian PSFs. Made as a
            % nested function for code overview
            
            % Preallocate
            I = zeros(n,1);
            back = zeros(n,1);
            GaussianTrace = zeros(n,7); % 7 Gaussian parameters for each frame
            
            % Get psf images used for generating initial guess
            [img1, idxInt] = getPSFimages(mainhandles, [file pair], 1:n, id);
            
            % Get start guess + lower and upper bounds (lb, ub)
            [initialguess, lb, ub] = initialGuessGaussian(img1);
            
            % Optimization threshold
            threshold = mainhandles.settings.integration.threshold;
            
            % Optimizer
            if mainhandles.settings.integration.type==2
                % Maximum likelihood estimator
                Gfcn = @MLEwG;
                
                % Options structure for MLEwG fminsearch
                MaxFunEvals = round(threshold^3*10000); % Maximum number of function evaluations
                MaxIter = round(threshold^3*10000); % Maximum number of iterations
                TolFun = 10^(-threshold*10); % Function toleration values
                options = optimset('Display','off', 'MaxFunEvals', MaxFunEvals, 'MaxIter', MaxIter, 'TolFun', TolFun); % Fitting options structure
                
            else
                % Least squares estimator
                Gfcn = @GME;
                
                % Options structure for GME lsqcurvefit
                options = optimset('lsqcurvefit');
                options = optimset(options, 'Jacobian','off', 'Display','off',  'TolX',10^-2, 'TolFun',10^-2, 'MaxPCGIter',1, 'MaxIter',500);
            end
            
            % Calculate trace
            warning off
            if mainhandles.settings.performance.parallel
                
                % Parallel computing: parfor loop and workspace progressbar
                [I, back, GaussianTrace] = calculateGaussianTraceParallel(I, back, GaussianTrace);
                
            else

                % Not parallel: Regular for loop and regular progressbar
                for j = 1:n % Loop over all frames
                    
                    % idxInt2 are the indices defining the pixels of interest
                    % within the ROI movie
                    idxInt2 = idxInt+npixels*(j-1); % Shift linear indices to match next array dimension (frame)
                    
                    % Images to fit
                    img = double( ROImovie(idxInt2)' ); % Flip because of the linear index format
                    
                    % Parameters = [x0 y0 sx sy theta background amplitude]
                    [params, count, grid, imgFit] = Gfcn(img, initialguess, lb, ub, threshold, options);
                    
                    % Counted photons, corrected for background
                    I(j) = count;
                    
                    % Store parameters of each frame
                    GaussianTrace(j,:) = params;
                    
                    % Calculate background
                    back(j) = params(6);%*numel(img); % Constant offset * number of pixels
                    
                    % Update progressbar
                    startProgressbar(3,j,n,id);
                    
                end
                
            end
            warning on
            
            % Multiply background with number of pixels to facilitate
            % comparison with aperture photometry
            back
            mainhandles.data(file).FRETpairs(pair).DintMask
            npix = length(find(mainhandles.data(file).FRETpairs(pair).DintMask))
            back = back*npix
            
            % Nested parallel
            function [I, back, GaussianTrace] = calculateGaussianTraceParallel(I, back, GaussianTrace)
                % Calculates intensity traces using Gaussian PSFs. Made as a
                % nested function for code overview
                
                parfor jj = 1:n % Loop over all frames
                    
                    % idxInt2 are the indices defining the pixels of interest
                    % within the ROI movie
                    idxInt2 = idxInt+npixels*(jj-1); % Shift linear indices to match next array dimension (frame)
                    
                    % Images to fit
                    img = double( ROImovie(idxInt2)' ); % Flip because of the linear index format
                    
                    % Parameters = [x0 y0 sx sy theta background amplitude]
                    [params, count, grid, imgFit] = Gfcn(img, initialguess, lb, ub, threshold, options);
                    
                    % Counted photons
                    I(jj) = count;
                    
                    % Store parameters of each frame
                    GaussianTrace(jj,:) = params;
                    
                    % Calculate background
                    back(jj) = params(6);%*numel(img); % Constant offset * number of pixels

                    % Progressbar (not working in this nested loop)
%                     try
%                         if mod(j,progressStepSize)==0
%                             ppm.increment
%                         end
%                     end
                end
                
                % Update progressbar
                startProgressbar(3,1,[],id);
                
            end
            
        end
        
        % Returns indices used for background
        function [backidx, bleachidx, blinkidx] = getbackidx()
            % Initialize
            bleachidx = [];
            blinkidx = [];
            backidx = []; % Idx of background trace
            
            % Get interval depending on channel
            if strcmpi(id,'AD')
                
                % If AD, use overlapping intervals (both bleached)
                [Dbackidx, Dbleachidx Dblinkidx] = getbackidx2('D');
                if isempty(Dbackidx)
                    return
                end
                
                % Overlapping interval
                [Abackidx, Ableachidx Ablinkidx] = getbackidx2('A');
                backidx = Abackidx(ismember(Abackidx,Dbackidx));
                bleachidx = Ableachidx(ismember(Ableachidx,Dbackidx));
                blinkidx = Ablinkidx(ismember(Ablinkidx,Dbackidx));
                
            else
                
                % Indices for 'DD' and 'AA'
                [backidx, bleachidx blinkidx] = getbackidx2(id(1));
            end
            
            function [backidx bleachidx blinkidx] = getbackidx2(id1)
                % Retreive data indices of dark states in trace
                bleachidx = [];
                blinkidx = [];
                backidx = []; % Idx of background trace
                
                % Return if not using aperture photometry
                if mainhandles.settings.integration.type~=1
                    return
                end
                
                % Bleaching time
                blch = [];
                if mainhandles.settings.background.bleachchoice ...
                        && ~isempty(mainhandles.data(file).FRETpairs(pair).([id1 'bleachingTime'])) ...
                        && mainhandles.data(file).FRETpairs(pair).([id1 'bleachingTime'])<=length(I)
                    blch = mainhandles.data(file).FRETpairs(pair).([id1 'bleachingTime']); % bleaching time
                end
                
                % Blinking time
                blnk = [];
                if mainhandles.settings.background.blinkchoice
                    blnk = mainhandles.data(file).FRETpairs(pair).([id1 'blinkingInterval']); % blinking time
                end
                
                % Bleaching interval
                if ~isempty(blch)
                    bleachidx = blch:length(I);
                end
                
                % Blinking intervals
                if ~isempty(blnk)
                    for j = 1:size(blnk,1)
                        
                        % Check blinking interval is not outside data range
                        if blnk(j,2)<1
                            continue
                        elseif blnk(j,1)<1
                            blnk(j,1) = 1;
                        end
                        
                        if blnk(j,1)>length(I)
                            continue
                        elseif blnk(j,2)>length(I)
                            blnk(j,2) = length(I);
                        end
                        
                        % Back indices of blinkin interval
                        blinkidx = [blinkidx blnk(j,1):blnk(j,2)];
                    end
                end
                
                % Combined indices of blinking and bleaching events
                backidx = unique([bleachidx blinkidx]);
            end
        end
        
        % Calculate background from dark states or averages frames:
        function back = finalizeBackgroundTrace(back)
            
            if length(backidx) > mainhandles.settings.background.minDarkFrames
                %% Use intensity during dark states as background
                
                % Calculate using minimum or mean of bleach and blink
                if mainhandles.settings.background.blinkbleachchoice==1 || mainhandles.settings.background.blinkbleachchoice==2 ...
                        && ~isempty(bleachidx) && ~isempty(blinkidx)
                    
                    % Both bleaching and blinking defined
                    idx = unique(bleachidx);
                    temp1 = sum(I(idx))/length(idx);                    
                    idx = unique(blinkidx);
                    temp2 = sum(I(idx))/length(idx);
                    
                    % Minimum or avg. value
                    if mainhandles.settings.background.blinkbleachchoice==1
                        backval = min([temp1 temp2]);
                    else
                        backval = mean([temp1 temp2]);
                    end
                    
                    back(:) = backval;
                    return
                end
                
                % Calculate using either bleaching or blinking
                idx = [];
                if isempty(blinkidx) || mainhandles.settings.background.blinkbleachchoice==3
                    % Use bleaching interval
                    idx = unique(bleachidx);
                    
                elseif isempty(bleachidx) || mainhandles.settings.background.blinkbleachchoice==4
                    % Use blinking interval
                    idx = unique(blinkidx);
                end
                                
                % Insert background value
                if ~isempty(idx)
                    backval = sum(I(idx))/length(idx);
                    back(:) = backval;
                end
                
            else                
                %% Avg. neighbouring frames in background calculation
                if mainhandles.settings.background.avgchoice==2
                    
                    % Number of neighbours
                    nf = mainhandles.settings.background.avgneighbours; % Number of frames
                    
                    % Average neighbouring frames
                    back = avgSmoothFilter(back,nf);
                    
                elseif mainhandles.settings.background.avgchoice==3
                    
                    % Average all frames
                    back(:) = sum(back)/length(back);
                end
                
            end
            
        end
        
    end

end
