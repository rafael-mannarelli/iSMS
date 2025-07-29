function plotEhistCallback(histogramwindowHandles)
% Callback for exporting E histogram to new isolated window
%
%    Input:
%     histogramwindowHandles   - handles structure of the histogram window
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

mainhandles = getmainhandles(histogramwindowHandles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

%% Dialog

% Prepare dialog box
prompt = {'Plot data within:' '';...
    'E min:  ' 'Emin';...
    'E max:  ' 'Emax';...
    'S min:  ' 'Smin';...
    'S max:  ' 'Smax';...
    'Gaussians: ' 'nGaussiansEexport'};
name = 'Specify data-range';

% Handles formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type   = 'text';
formats(3,1).type   = 'edit';
formats(3,1).format = 'float';
formats(3,1).size = 80;
formats(3,2).type   = 'edit';
formats(3,2).format = 'float';
formats(3,2).size = 80;
formats(4,1).type   = 'edit';
formats(4,1).format = 'float';
formats(4,1).size = 80;
formats(4,2).type   = 'edit';
formats(4,2).format = 'float';
formats(4,2).size = 80;
formats(6,1).type   = 'edit';
formats(6,1).format = 'integer';
formats(6,1).size = 40;

% Default answers:
DefAns.Emin = mainhandles.settings.SEplot.xlimEexport(1);
DefAns.Emax = mainhandles.settings.SEplot.xlimEexport(2);
DefAns.Smin = mainhandles.settings.SEplot.ylimEexport(1);
DefAns.Smax = mainhandles.settings.SEplot.ylimEexport(2);
DefAns.nGaussiansEexport = mainhandles.settings.SEplot.nGaussiansEexport;

% Open input dialogue and get answer
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns); % Open dialog box
if cancelled == 1
    return
end

%% Interpret answer and update defaults

Es = sort([answer.Emin answer.Emax]);
Ss = sort([answer.Smin answer.Smax]);
mainhandles.settings.SEplot.xlimEexport = Es;
mainhandles.settings.SEplot.ylimEexport = Ss;
mainhandles.settings.SEplot.nGaussiansEexport = abs(answer.nGaussiansEexport);
updatemainhandles(mainhandles)

%--- Plot E-histogram in new figure: ---
% Get number of bins from the slider
nBins = get(histogramwindowHandles.EbinsizeSlider,'Value');

% Get data from SEplot
h = findobj(histogramwindowHandles.SEplot,'type','line');
xSEplot = get(h,'xdata');
ySEplot = get(h,'ydata');

if isempty(xSEplot) % If there are no plotted data points
    mymsgbox('No data points in specified interval');
    return
elseif size(xSEplot,1)>1 % If there is more than one data-set plotted (e.g. Gaussian mixture)
    xSEplot = [xSEplot{:}];
    ySEplot = [ySEplot{:}];
end

% Remove points outside the chosen limits
idx = [find(xSEplot<Es(1)) find(xSEplot>Es(2)) find(ySEplot<Ss(1)) find(ySEplot>Ss(2))]; % Indices of points to remove
xSEplot(idx) = [];
ySEplot(idx) = [];

% Plot histogram
fh = figure;
updatelogo(fh)
mainhandles.figures{end+1} = fh;
set(gcf,'name','FRET-histogram')
ax = gca;
[n,xout] = hist(xSEplot,nBins); % n is frequency of bin centred at xout

% VERSION DEPENDENT SYNTAX
if mainhandles.matver>8.3
    b = bar(ax,xout,n,'hist'); % Same as hist(histogramwindowHandles.Shist,y,nBins)
else
    b = bar(ax,xout,n,'style','hist'); % Same as hist(histogramwindowHandles.Shist,y,nBins)
end

% Set bar colors and labels
set(b, 'EdgeColor',mainhandles.settings.SEplot.binEdgeColor,'FaceColor',mainhandles.settings.SEplot.binFaceColor)
xlabel('FRET efficiency')
ylabel('Counts')
xlim(get(histogramwindowHandles.SEplot,'ylim'))

%% Plot distribution fit in E-hist

hold on
if answer.nGaussiansEexport>0
    
    % Turn on waitbar
    if length(xSEplot)>10000 % Turn on waitbar
        hWaitbar = mywaitbar(0.5,'Fitting Gaussian mixture...','name','iSMS');
    end
    
    nGaussians = answer.nGaussiansEexport; % Number of components
    
    % Fit with nGaussians components
    options = statset('MaxIter',1000);
    GMFIT = gmdistribution.fit(xSEplot(:),nGaussians,'Options',options); % Fit Gaussian mixture model to the E-data
    
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
%     data = getBarplotData(gca); % Histogram data
%     data = data{:};
%     data = [n(:) xout(:)];
    Ytemp = pdf(GMFIT,xout(:)); % Make normal distribution vector based on fit
    C = n(:)\Ytemp(:); % Multiplication factor
    C = 1/C;
    amplitude = weight*C; % Amplitudes of each component
    
    % Create total distribution
    [minmu, idxmin] = min(mu);
    [maxmu, idxmax] = max(mu);
    xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian
    Ytot = pdf(GMFIT,xi); % Make normal distribution vector based on fit
    Ytot = Ytot*C;
    GaussTot = [xi(:) Ytot(:)];
    
    try delete(hWaitbar), end
    
    %% Update GUI

    % Lines to plot
    plotEfit = mainhandles.settings.SEplot.plotEfit;
    plotEfitTot = mainhandles.settings.SEplot.plotEfitTot;
    if ~plotEfit && ~plotEfitTot
        plotEfit = 1;
        plotEfitTot = 1;
    end
    
    % Colors
    colorOrder = mainhandles.settings.SEplot.colorOrder; % E.g. 'rgmcykbrgmc'. Up to 11 Gaussians in red, green, magenta, cyano, yellow, black, blue, etc.
    
    % Plot total fit
    if plotEfitTot
        plot(ax, GaussTot(:,1),GaussTot(:,2), 'k', 'LineWidth',2)
    end
    
    if plotEfit
        % Plot individual components
        for i = 1:nGaussians
            
            obj = gmdistribution(mu(i),sigma(i),weight(i));
            Y = pdf(obj,xi); % Make normal distribution vector based on fit
            Y = Y*C*weight(i);
            
            % Plot fitted distribution
            if mainhandles.settings.SEplot.GaussColorChoiceHist
                gausscolor = colorOrder(i);
            else
                gausscolor = colorOrder(1);
            end
            
            plot(ax, xi, Y, gausscolor, 'LineWidth',2)
            
        end
    end

end
hold off
