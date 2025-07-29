function mainhandles = fit1DgaussCallback(hwHandles,predict, axchoice)
% Callback for fitting a 1D gauss to the S histogram
%
%    Input:
%     histogramwindowHandles   - handles structure of the histogramwindow
%     predict                  - determines whether to predict number of
%                                Gaussians (0/1)
%     axchoice                 - 'E','S'
%
%    Output:
%     mainhandles              - handles structure of the main window
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
    predict = 0;
end
if nargin<3 % Default
    axchoice = 'E';
end

% Get handles
mainhandles = getmainhandles(hwHandles); % Get handles structure of main window
if isempty(mainhandles) || isempty(mainhandles.data)
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Fit

% Callback depend on scheme
if ~alex
    axchoice = 'E';
end

if alex
    % Get data from SEplot
    h = findobj(hwHandles.SEplot,'type','line');
    if strcmpi(axchoice,'E')
        ax = hwHandles.Ehist;
        histdata = get(h,'xdata');
        limSE = get(hwHandles.SEplot,'xlim');
    else
        ax = hwHandles.Shist;
        histdata = get(h,'ydata');
        limSE = get(hwHandles.SEplot,'ylim');
    end
    
    if isempty(histdata)
        return
    elseif size(histdata,1)>1 % If there is more than one data-set plotted (e.g. Gaussian mixture)
        histdata = [histdata{:}];
    end
    
else
    % Get data from traces
    selectedPairs = getPairs(mainhandles.figure1,'plotted');
    traces = getTraces(mainhandles.figure1,selectedPairs,'SEplot');
    
    % All data to plot
    histdata = [traces(:).E]; % Denotes the combined E/PR coordinates of the pairs to be plotted
    
    % Limits
    limSE = mainhandles.settings.SEplot.xlim;
    ax = hwHandles.Ehist;
end

if strcmpi(axchoice,'E')
    minVal = mainhandles.settings.SEplot.EdataGaussianFit(1);
    maxVal = mainhandles.settings.SEplot.EdataGaussianFit(2);
else
    minVal = mainhandles.settings.SEplot.SdataGaussianFit(1);
    maxVal = mainhandles.settings.SEplot.SdataGaussianFit(2);
end

if isinf(minVal)
    minVal = limSE(1);
end
if isinf(maxVal)
    maxVal = limSE(2);
end

% Remove points outside the SEplot limits
histdata(histdata < minVal) = [];
histdata(histdata > maxVal) = [];
if length(histdata(:))<=1
    return
end

%% Fit to Gaussian mixture distribution model

% Predict E-data to distribution model
hWaitbar = [];
if predict
    % Predict Gaussians mixture
    
    % Input dialog for max components
    answer = myinputdlg('Select max. number of Gaussians: ','Predict Gaussian components',1,{num2str(mainhandles.settings.SEplot.maxGaussians1D)});
    if isempty(answer)
        return
    end
    mainhandles = savesettingasDefault(mainhandles,'SEplot','maxGaussians1D', round(abs(str2num(answer{1}))) );
    
    % Turn on waitbar
    hWaitbar = mywaitbar(0.5,'Predicting 1D Gaussian components...','name','iSMS');
    movegui(hWaitbar,'north')
    
    % Predict using vbgm
    [label, model, L]  = vbgm(histdata,mainhandles.settings.SEplot.maxGaussians1D); % Performs variational Bayesian inference for Gaussian mixture.
    nGaussians = max(label);
    
else
    
    % Input dialog for start guesses
    [mainhandles, cancelled] = startDlg(mainhandles);
    if cancelled
        return
    end
    
    nGaussians = mainhandles.settings.SEplot.nGaussians;
    
    % Turn on waitbar
    if length(histdata)>10000 % Turn on waitbar
        hWaitbar = mywaitbar(0.5,sprintf('Fitting %i Gaussians mixture...',nGaussians),'name','iSMS');
        movegui(hWaitbar,'north')
    end
    
end

% Start guess
options = statset('MaxIter',1000);
if (strcmpi(axchoice,'E') && mainhandles.settings.SEplot.Estart_random) || ...
        (strcmpi(axchoice,'S') && mainhandles.settings.SEplot.Sstart_random)
    
    % Fit with nGaussians components
    GMFIT = gmdistribution.fit(histdata(:),nGaussians,'Options',options); % Fit Gaussian mixture model to the E-data
    
else
    
    if strcmpi(axchoice,'E')
        
        % Mean is kx1
        mu = mainhandles.settings.SEplot.Estart_mu(1:nGaussians)'; %[0.2 0.5 0.83]';% 0.7]';
        
        % Sigma is 1x1xk
        Sigma = mainhandles.settings.SEplot.Estart_mu(1:nGaussians);
        Sigma = reshape(Sigma ,1,1,length(Sigma));% cat(3,0.01,0.01,0.01);%,0.01);
        
        % Weight is kx1
        PComponents = mainhandles.settings.SEplot.Estart_weight(1:nGaussians); %[0.2 0.1 1];% 1];
        
    elseif strcmpi(axchoice,'S')
        
        % Mean is kx1
        mu = mainhandles.settings.SEplot.Sstart_mu(1:nGaussians)'; %[0.2 0.5 0.83]';% 0.7]';
        
        % Sigma is 1x1xk
        Sigma = mainhandles.settings.SEplot.Sstart_mu(1:nGaussians);
        Sigma = reshape(Sigma ,1,1,length(Sigma));% cat(3,0.01,0.01,0.01);%,0.01);
        
        % Weight is kx1
        PComponents = mainhandles.settings.SEplot.Sstart_weight(1:nGaussians); %[0.2 0.1 1];% 1];
        
    end
    
    % Start guess structure
    startg = struct('mu',mu, 'Sigma',Sigma, 'PComponents',PComponents);
    
    % Fit with nGaussians components
    
    try
        GMFIT = gmdistribution.fit(histdata(:),nGaussians,'Options',options,'Start',startg); % Fit Gaussian mixture model to the E-data
    catch err
        mymsgbox('Prediction failed. Try another set of start guesses.')
        try delete(hWaitbar), end
        return
    end
end

% Get parameters from GMFIT obj
mu = GMFIT.mu;
sigmatemp = GMFIT.Sigma;
sigma = [];
for i = 1:nGaussians
    sigma = [sigma; sigmatemp(:,:,i)];
end
weight = GMFIT.PComponents;

% Sort Gaussians according to weight
[weight,ix] = sort(weight,'descend');
mu = mu(ix);
sigma = sigma(ix);

% Determine multiplication factor for overlaying fit on
% plotted bar histogram
data = getBarplotData(ax); % Histogram data
data = data{:};
data(data(:,1) < minVal,:) = [];
data(data(:,1) > maxVal,:) = [];
if length(data(:))<1
    % No bins in data range
    mymsgbox('No bins in data range')
    return
end
Ytemp = pdf(GMFIT,data(:,1)); % Make normal distribution vector based on fit
C = data(:,2)\Ytemp(:); % Multiplication factor
C = 1/C;
amplitude = weight*C; % Amplitudes of each component

% Create total distribution
[minmu, idxmin] = min(mu);
[maxmu, idxmax] = max(mu);
xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian
Ytot = pdf(GMFIT,xi); % Make normal distribution vector based on fit
Ytot = Ytot*C;
GaussTot = [xi(:) Ytot(:)];

if ~isempty(hWaitbar) % Delete waitbar
    try delete(hWaitbar), end
end

%% Update GUI

% Update Gaussians structure
if strcmpi(axchoice,'E')
    Gaussians = mainhandles.settings.SEplot.EGaussians;
    mainhandles.settings.SEplot.EGaussTot = GaussTot;
else
    Gaussians = mainhandles.settings.SEplot.SGaussians;
    mainhandles.settings.SEplot.SGaussTot = GaussTot;
end
Gaussians(:) = [];

% Colors
colorOrder = mainhandles.settings.SEplot.colorOrder; % E.g. 'rgmcykbrgmc'. Up to 11 Gaussians in red, green, magenta, cyano, yellow, black, blue, etc.
for i = 1:nGaussians
    
    obj = gmdistribution(mu(i),sigma(i),weight(i));
    Y = pdf(obj,xi); % Make normal distribution vector based on fit
    Y = Y*C*weight(i);
    
    Gaussians(i).x = xi;
    Gaussians(i).y = Y;
    Gaussians(i).color = colorOrder(i);
    Gaussians(i).mu = mu(i);
    Gaussians(i).sigma = sigma(i);
    Gaussians(i).weight = weight(i)/sum(weight); % Normalize weights
    Gaussians(i).amplitude = amplitude(i);
    
end

% Update handles structure
mainhandles.settings.SEplot.GaussianType = 1; % 1D plot
if strcmpi(axchoice,'E')
    
    if ~mainhandles.settings.SEplot.plotEfit && ~mainhandles.settings.SEplot.plotEfitTot
        % Turn on plot
        mainhandles.settings.SEplot.plotEfit = 1;
        mainhandles.settings.SEplot.plotEfitTot = 1;
    end
    
    mainhandles.settings.SEplot.EGaussians = Gaussians;
    %     mainhandles.settings.SEplot.SGaussians(:) = [];
    updatemainhandles(mainhandles)
    updateEhistGauss(hwHandles.main, hwHandles.figure1);
    
else
    
    if ~mainhandles.settings.SEplot.plotSfit && ~mainhandles.settings.SEplot.plotSfitTot
        % Turn on plot
        mainhandles.settings.SEplot.plotSfit = 1;
        mainhandles.settings.SEplot.plotSfitTot = 1;
    end
    
    mainhandles.settings.SEplot.SGaussians = Gaussians;
    %     mainhandles.settings.SEplot.EGaussians(:) = [];
    updatemainhandles(mainhandles)
    updateShistGauss(hwHandles.main, hwHandles.figure1);
end

% Delete the waitbar
if ~isempty(hWaitbar)
    try delete(hWaitbar), end
end

% Update number of Gaussians
if predict
    
    mainhandles.settings.SEplot.nGaussians = nGaussians;
    updatemainhandles(mainhandles)
    
    % Set number of Gaussians in the slider, the editbox and handles structure
    set(hwHandles.GaussiansSlider,'Value', nGaussians)
    set(hwHandles.GaussiansEditbox,'String', nGaussians)
end

% Update Gaussian components window
updateGaussianComponentsWindow(mainhandles.figure1, hwHandles.figure1, mainhandles.GaussianComponentsWindowHandle)

%% Subroutines

    function [mainhandles, cancelled] = startDlg(mainhandles)
        % Opens a dialog for specifying start guesses
        
        % Initialize
        cancelled = 0;
        nGaussians = mainhandles.settings.SEplot.nGaussians;
        
        % Shows a dialog for specifying start guesses for Gaussian fit
        if (strcmpi(axchoice,'E') && ~mainhandles.settings.SEplot.EGaussStartDlg) ||...
                (strcmpi(axchoice,'S') && ~mainhandles.settings.SEplot.SGaussStartDlg)
            return
        end
        
        % Prepare dialog
        name = 'Start guesses';
        prompt = {sprintf('Enter start guesses for the %i Gaussians fit. Separate Gaussians by space.',nGaussians) '';...
            'Non-specified components will be assigned a default start guess.' '';...
            'Mean: ' 'mean';...
            'Sigma: ' 'sigma';...
            'Weight: ' 'weight';...
            'Use random start guess' 'startRandom';...
            'Show this dialog everytime' 'showdlg'};
        
        % Formats structure
        formats = prepareformats();
        formats(1,1).type = 'text';
        formats(2,1).type = 'text';
        formats(4,1).type = 'edit';
        formats(4,1).size = 300;
        formats(5,1).type = 'edit';
        formats(5,1).size = 300;
        formats(6,1).type = 'edit';
        formats(6,1).size = 300;
        
        formats(8,1).type = 'check';
        formats(10,1).type = 'check';
        
        if strcmpi(axchoice,'E')
            
            % E start guesses
%             temp = mat2str( mainhandles.settings.SEplot.Estart_mu(1:nGaussians) )
            DefAns.mean = mat2str( mainhandles.settings.SEplot.Estart_mu(1:nGaussians) );%temp(2:end-1);
%             temp = mat2str( mainhandles.settings.SEplot.Estart_sigma(1:nGaussians) );
            DefAns.sigma = mat2str( mainhandles.settings.SEplot.Estart_sigma(1:nGaussians) );%temp(2:end-1);
%             temp = mat2str( mainhandles.settings.SEplot.Estart_weight(1:nGaussians) );
            DefAns.weight = mat2str( mainhandles.settings.SEplot.Estart_weight(1:nGaussians) );%temp(2:end-1);
            DefAns.startRandom = mainhandles.settings.SEplot.Estart_random;
            DefAns.showdlg = mainhandles.settings.SEplot.EGaussStartDlg;
            
        else
            
            % E start guesses
%             temp = mat2str( mainhandles.settings.SEplot.Estart_mu(1:nGaussians) )
            DefAns.mean = mat2str( mainhandles.settings.SEplot.Sstart_mu(1:nGaussians) );%temp(2:end-1);
%             temp = mat2str( mainhandles.settings.SEplot.Estart_sigma(1:nGaussians) );
            DefAns.sigma = mat2str( mainhandles.settings.SEplot.Sstart_sigma(1:nGaussians) );%temp(2:end-1);
%             temp = mat2str( mainhandles.settings.SEplot.Estart_weight(1:nGaussians) );
            DefAns.weight = mat2str( mainhandles.settings.SEplot.Sstart_weight(1:nGaussians) );%temp(2:end-1);
            DefAns.startRandom = mainhandles.settings.SEplot.Sstart_random;
            DefAns.showdlg = mainhandles.settings.SEplot.SGaussStartDlg;
%             % S start guesses
%             temp = mat2str( mainhandles.settings.SEplot.Sstart_mu(1:nGaussians) );
%             DefAns.mean = temp(2:end-1);
%             temp = mat2str( mainhandles.settings.SEplot.Sstart_sigma(1:nGaussians) );
%             DefAns.sigma = temp(2:end-1);
%             temp = mat2str( mainhandles.settings.SEplot.Sstart_weight(1:nGaussians) );
%             DefAns.weight = temp(2:end-1);
%             DefAns.startRandom = mainhandles.settings.SEplot.Sstart_random;
%             DefAns.showdlg = mainhandles.settings.SEplot.SGaussStartDlg;
            
        end
        
        % Dialog
        [answer, cancelled] = inputsdlg(prompt, name, formats, DefAns); % Open dialog box
        if cancelled == 1
            return
        end
        
        % Interpret answer
        mu = str2num( answer.mean) ;
        sigma = abs(str2num( answer.sigma ));
        weight = abs(str2num( answer.weight ));
        if length(mu)>10
            mu = mu(1:10);
        end
        if length(sigma)>10
            sigma = sigma(1:10);
        end
        if length(weight)>10
            weight = weight(1:10);
        end
        
        if strcmpi(axchoice,'E')
            
            % E
            if ~isempty(mu)
                mainhandles.settings.SEplot.Estart_mu(1:length(mu)) = mu;
            end
            if ~isempty(sigma)
                mainhandles.settings.SEplot.Estart_sigma(1:length(sigma)) = sigma;
            end
            if ~isempty(weight)
                mainhandles.settings.SEplot.Estart_weight(1:length(weight)) = weight;
            end
            mainhandles.settings.SEplot.Estart_random = answer.startRandom;
            mainhandles.settings.SEplot.EGaussStartDlg =  answer.showdlg;
            
        else
            
            % S
            if ~isempty(mu)
                mainhandles.settings.SEplot.Sstart_mu(1:length(mu)) = mu;
            end
            if ~isempty(sigma)
                mainhandles.settings.SEplot.Sstart_sigma(1:length(sigma)) = sigma;
            end
            if ~isempty(weight)
                mainhandles.settings.SEplot.Sstart_weight(1:length(weight)) = weight;
            end
            mainhandles.settings.SEplot.Sstart_random = answer.startRandom;
            mainhandles.settings.SEplot.SGaussStartDlg = answer.showdlg;
            
        end
        
        % Update handles structure
        updatemainhandles(mainhandles)
    end

end
