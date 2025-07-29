function mainhandles = fit2DgaussSEcallback(histogramwindowHandles,predict)
% Callback for fitting a 2D gauss to the E-S plot
%
%    Input:
%     histogramwindowHandles   - handles structure of the histogramwindow
%     predict                  - 0/1 whether to predict (1) of fit gaussian
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

mainhandles = getmainhandles(histogramwindowHandles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Get data from SEplot
h = findobj(histogramwindowHandles.SEplot,'type','line');
xSEplot = get(h,'xdata');
ySEplot = get(h,'ydata');
if isempty(xSEplot) || isempty(ySEplot)
    return
elseif size(xSEplot,1)>1 % If there is more than one data-set plotted (e.g. Gaussian mixture)
    xSEplot = [xSEplot{:}];
    ySEplot = [ySEplot{:}];
end

% Limits
xlimSE = get(histogramwindowHandles.SEplot,'xlim');
ylimSE = get(histogramwindowHandles.SEplot,'ylim');

if isinf(mainhandles.settings.SEplot.EdataGaussianFit(1))
    minvalE = ylimSE(1);
else
    minvalE = mainhandles.settings.SEplot.EdataGaussianFit(1);
end
if isinf(mainhandles.settings.SEplot.EdataGaussianFit(2))
    maxvalE = ylimSE(2);
else
    maxvalE = mainhandles.settings.SEplot.EdataGaussianFit(2);
end
if isinf(mainhandles.settings.SEplot.SdataGaussianFit(1))
    minvalS = xlimSE(1);
else
    minvalS = mainhandles.settings.SEplot.SdataGaussianFit(1);
end
if isinf(mainhandles.settings.SEplot.SdataGaussianFit(2))
    maxvalS = xlimSE(2);
else
    maxvalS = mainhandles.settings.SEplot.SdataGaussianFit(2);
end

% Remove points outside the SEplot limits
idx = [find(ySEplot<minvalE) find(ySEplot>maxvalE) find(xSEplot<minvalS) find(xSEplot>maxvalS)];
xSEplot(idx) = [];
ySEplot(idx) = [];
if isempty(xSEplot) || isempty(ySEplot)
    return
end

%% Fit to Gaussian mixture distribution model

hWaitbar = [];
if predict
    % Predict Gaussians mixture
    
    % Input dialog for max components
    answer = myinputdlg('Select max. number of Gaussians in 2D plot: ','Predict',1,{num2str(mainhandles.settings.SEplot.maxGaussians2D)});
    if isempty(answer)
        return
    end
    mainhandles = savesettingasDefault(mainhandles,'SEplot','maxGaussians2D', round(abs(str2num(answer{1}))) );
    
    % Turn on waitbar
    hWaitbar = mywaitbar(0.5,'Predicting 2D Gaussian components...','name','iSMS');
    movegui(hWaitbar,'north')
    
    % Predict using vbgm
    [label, model, L]  = vbgm([xSEplot; ySEplot],mainhandles.settings.SEplot.maxGaussians2D); % Performs variational Bayesian inference for Gaussian mixture.
    
    % Number of mixed Gaussians
    nGaussians = max(label);
    
else
    % Fit Gaussians mixture
    
    % Turn on waitbar
    if length(xSEplot)>10000 % Turn on waitbar
        hWaitbar = mywaitbar(0.5,'Fitting Gaussian mixture...','name','iSMS');
        movegui(hWaitbar,'north')
    end
    
    % Number of Gaussians
    nGaussians = mainhandles.settings.SEplot.nGaussians;
end

% Obtains the maximum likelihood estimation of a Gaussian mixture model by
% expectation maximization (EM). We like emgm because it also gives us the
% coordinates of each component. Note to self: This can also be achieved
% using gmdistribution.cluster
[label, model, ~] = emgm([xSEplot; ySEplot],nGaussians); 

% Fitted parameters
mu = model.mu'; % Means
sigma = model.Sigma; % Widths
weight = model.weight(:); % Weights

% Sort Gaussians according to weight
[weight,ix] = sort(weight,'descend');
mu = mu(ix,:);
sigma = sigma(:,:,ix);

if ~isempty(hWaitbar) % Delete waitbar
    try delete(hWaitbar), end
end

% Make new label indices following the order of Gaussian weights
ix = ix(1:max(label));
temp = label;
for i = 1:max(label)
    idx = find(ix==min(ix)); % Find the lowest value in the ix vector (for i=1 this is the component with highest weight)
    label(temp==i) = idx; % Change label value
    
    ix(ix==min(ix)) = max(ix)+1; % Change ix vector so the lowest value is now the highest
end

%% Update

% Update Gaussians structure
Gaussians = mainhandles.settings.SEplot.Gaussians;
Gaussians(:) = [];

colorOrder = mainhandles.settings.SEplot.colorOrder; % E.g. 'rgmcykbrgmc'. Up to 11 Gaussians in red, green, magenta, cyano, yellow, black, blue, etc.

for i = 1:max(label)
    Gaussians(i).x = xSEplot(label==i);
    Gaussians(i).y = ySEplot(label==i);
    Gaussians(i).color = colorOrder(i);
    Gaussians(i).mu = mu(i,:);
    Gaussians(i).sigma = sigma(:,:,i);
    Gaussians(i).weight = weight(i)/sum(weight); % Normalize weights
end

% Update handles structure
mainhandles.settings.SEplot.Gaussians = Gaussians;
mainhandles.settings.SEplot.GaussianType = 2; % 2D plot
updatemainhandles(mainhandles)

% Update plot
mainhandles = updateSEplot(histogramwindowHandles.main,mainhandles.FRETpairwindowHandle,histogramwindowHandles.figure1,'all',0,1);

%% Make E histogram fit
if isempty(Gaussians)
    return
end

muE = mu(:,1); % mu = [E S;...]
sigmaE = sigma(1,1,:);
weightE = weight/sum(weight);

data = getBarplotData(histogramwindowHandles.Ehist); % Histogram data
data = data{:};
data(data(:,1) < minvalE,:) = [];
data(data(:,1) > maxvalE,:) = [];
if length(data(:))<1
    % No bins in data range
    mymsgbox('No bins in data range')
    return
end
gmobj = gmdistribution(muE,sigmaE,weightE);
Ytemp = pdf(gmobj,data(:,1)); % Make normal distribution vector based on fit
C = data(:,2)\Ytemp(:); % Multiplication factor
C = 1/C;
amplitudeE = weightE*C; % Amplitudes of each component

% Create total distribution vector
[minmu, idxmin] = min(muE);
[maxmu, idxmax] = max(muE);
xi = linspace(minmu-3.5*sqrt(sigmaE(1,1,idxmin)),maxmu+3.5*sqrt(sigmaE(1,1,idxmax)),100)'; % Make x-grid for Gaussian
Ytot = pdf(gmobj,xi); % Make normal distribution vector based on fit
Ytot = Ytot*C;
EGaussTot = [xi(:) Ytot(:)];

% Update Gaussians structure
EGaussians = mainhandles.settings.SEplot.EGaussians;
EGaussians(:) = [];
mainhandles.settings.SEplot.EGaussTot = EGaussTot;
for i = 1:nGaussians
    
    obj = gmdistribution(muE(i),sigmaE(1,1,i));
    Y = pdf(obj,xi); % Make normal distribution vector based on fit
    Y = Y*C*weight(i);
    
    EGaussians(i).x = xi;
    EGaussians(i).y = Y;
    EGaussians(i).color = colorOrder(i);
    EGaussians(i).mu = muE(i);
    EGaussians(i).sigma = sigmaE(1,1,i);
    EGaussians(i).weight = weightE(i)/sum(weightE); % Normalize weights
    EGaussians(i).amplitude = amplitudeE(i);
    
end

%% Make S histogram fit

muS = mu(:,2); % mu = [E S;...]
sigmaS = sigma(2,2,:);
weightS = weight/sum(weight);

data = getBarplotData(histogramwindowHandles.Shist); % Histogram data
data = data{:};
data(data(:,1) < minvalS,:) = [];
data(data(:,1) > maxvalS,:) = [];
if length(data(:))<1
    % No bins in data range
    mymsgbox('No bins in data range')
    return
end
gmobj = gmdistribution(muS,sigmaS,weightS);
Ytemp = pdf(gmobj,data(:,1)); % Make normal distribution vector based on fit
C = data(:,2)\Ytemp(:); % Multiplication factor
C = 1/C;
amplitudeS = weightS*C; % Amplitudes of each component

% Create total distribution vector
[minmu, idxmin] = min(muS);
[maxmu, idxmax] = max(muS);
xi = linspace(minmu-3.5*sqrt(sigmaS(1,1,idxmin)),maxmu+3.5*sqrt(sigmaS(1,1,idxmax)),100)'; % Make x-grid for Gaussian
Ytot = pdf(gmobj,xi); % Make normal distribution vector based on fit
Ytot = Ytot*C;
SGaussTot = [xi(:) Ytot(:)];

% Update Gaussians structure
SGaussians = mainhandles.settings.SEplot.SGaussians;
SGaussians(:) = [];
mainhandles.settings.SEplot.SGaussTot = SGaussTot;

for i = 1:nGaussians
    
    obj = gmdistribution(muS(i),sigmaS(1,1,i));
    Y = pdf(obj,xi); % Make normal distribution vector based on fit
    Y = Y*C*weight(i);
    
    SGaussians(i).x = xi;
    SGaussians(i).y = Y;
    SGaussians(i).color = colorOrder(i);
    SGaussians(i).mu = muS(i);
    SGaussians(i).sigma = sigmaS(1,1,i);
    SGaussians(i).weight = weightS(i)/sum(weightS); % Normalize weights
    SGaussians(i).amplitude = amplitudeS(i);
    
end

%% Update

% Update handles structure
mainhandles.settings.SEplot.EGaussians = EGaussians;
mainhandles.settings.SEplot.SGaussians = SGaussians;

% Delete the waitbar
if ~isempty(hWaitbar)
    try delete(hWaitbar), end
end

% Update number of Gaussians
if predict

    mainhandles.settings.SEplot.nGaussians = nGaussians;

    % Set number of Gaussians in the slider, the editbox and handles structure
    set(histogramwindowHandles.GaussiansSlider,'Value', nGaussians)
    set(histogramwindowHandles.GaussiansEditbox,'String', nGaussians)
end

% Make fits visible
if ~mainhandles.settings.SEplot.plotEfit && ~mainhandles.settings.SEplot.plotEfitTot
    mainhandles.settings.SEplot.plotEfit = 1;
    mainhandles.settings.SEplot.plotEfitTot = 1;
end
if ~mainhandles.settings.SEplot.plotSfit && ~mainhandles.settings.SEplot.plotSfitTot
    mainhandles.settings.SEplot.plotSfit = 1;
    mainhandles.settings.SEplot.plotSfitTot = 1;
end

% Update plot
updatemainhandles(mainhandles)
updateEhistGauss(histogramwindowHandles.main, histogramwindowHandles.figure1);
updateShistGauss(histogramwindowHandles.main, histogramwindowHandles.figure1);

% Update Gaussian components window
updateGaussianComponentsWindow(mainhandles.figure1, histogramwindowHandles.figure1, mainhandles.GaussianComponentsWindowHandle)





% % Create total distribution
% mu = [];
% sigma = [];
% for i = 1:length(Gaussians)
%     mu = [mu Gaussians(i).mu(1)];
%     sigma = [sigma Gaussians(i).sigma(1,1,1)];
% end
% [minmu, idxmin] = min(mu)
% [maxmu, idxmax] = max(mu)
% xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)' % Make x-grid for Gaussian
%
% % Fit distribution to each of the precicted Gaussian components
% mu = [];
% sigma = [];
% for i = 1:length(Gaussians)
%     % S data points of component i
%     xEhist = Gaussians(i).x;
%
%     % Remove points outside the SEplot limits
%     xEhist(xEhist < xlimSE(1)) = [];
%     xEhist(xEhist > xlimSE(2)) = [];
%
%     % If all points are outside the window, continue to next component
%     if length(xEhist(:))<=1
%         continue
%     end
%
%     % Fit E-data to distribution model
%     GMFIT = gmdistribution.fit(xEhist(:),1); % Fit Gaussian mixture model to the E-data
%     %         xi = linspace(GMFIT.mu-3.5*sqrt(GMFIT.Sigma),GMFIT.mu+3.5*sqrt(GMFIT.Sigma),100)'; % Make x-grid for Gaussian
%     Y = pdf(GMFIT,xi); % Make normal distribution vector based on fit
%     if i==1
%         Ytot = Y;
%     else
%         Ytot = Ytot+weight(i)*Y;
%     end
%
%     % Get parameters from GMFIT obj
%     mu = [mu GMFIT.mu];
%     sigma = [sigma GMFIT.Sigma(:,:,1)];
%
%     %         % Set height of fitted distribution so that it matches histogram
%     %         [n,xout] = hist(ySEplot,nBins); % n is frequency of bin centred at xout
%     %         idx = find(xout<min(xShist) | xout>max(xShist));
%     %         nBins2 = nBins - length(idx); % Number of bins in Shist covering Gaussian component i
%     %         [n,xout] = hist(xShist,nBins2); % n is frequency of bin centred at xout
%     %         Y = Y/trapz(xi,Y)*trapz(xout,n); % mean(n); % Set as approx. same size as histogram
%     %
%     %         % Plot fitted distribution
%     %         plot(histogramwindowHandles.Shist,xi,Y,Gaussians(i).color,'LineWidth',2)
% end
% Ytot = real(Ytot)
%
%
% % Determine multiplication factor for overlaying fit on
% % plotted bar histogram
% data = getBarplotData(histogramwindowHandles.Ehist); % Histogram data
% if isempty(data)
%     return
% end
% data = data{:}
%
% %     Ytemp = pdf(GMFIT,data(:,1)); % Make normal distribution vector based on fit
% Ytemp = interp1(xi(:),Ytot(:),data(:,1));
% figure(1)
% plot(data(:,1),Ytemp)
% figure(2)
% plot(data(:,1),data(:,2))
% %
% %     whos Ytemp
% %     whos data
% C = data(:,2)\Ytemp(:) % Multiplication factor
% C = 1/C
% amplitude = weight*C; % Amplitudes of each component
%
% %     Ytot = pdf(GMFIT,xi); % Make normal distribution vector based on fit
% Ytot = Ytot*C;
% %     whos xi
% %     whos Ytot
% EGaussTot = [xi(:) Ytot(:)];
%
% %% Update GUI
%
% % Update Gaussians structure
% EGaussians = mainhandles.settings.SEplot.EGaussians;
% EGaussians(:) = [];
% mainhandles.settings.SEplot.EGaussTot = EGaussTot;
%
% % % Colors
% % if mainhandles.settings.SEplot.GaussColorChoice % If plotting Gaussian components in different colors
% %     colorOrder = mainhandles.settings.SEplot.colorOrder; % E.g. 'rgmcykbrgmc'. Up to 11 Gaussians in red, green, magenta, cyano, yellow, black, blue, etc.
% % else % If plotting Gaussian components in identical colors
% %     colorOrder = repmat(mainhandles.settings.SEplot.colorOrder(1),1,11);% E.g. 'rrrrrrrrrrr'. Up to 11 Gaussians in red
% % end
% mu
% sigma
% weight
% for i = 1:nGaussians
%
%     obj = gmdistribution(mu(i),sigma(i),weight(i));
%     %     xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian i
%     Y = pdf(obj,xi); % Make normal distribution vector based on fit
%     Y = Y*C*weight(i);
%
%     EGaussians(i).x = xi;
%     EGaussians(i).y = Y;
%     EGaussians(i).color = colorOrder(i);
%     EGaussians(i).mu = mu(i);
%     EGaussians(i).sigma = sigma(i);
%     EGaussians(i).weight = weight(i)/sum(weight); % Normalize weights
%     EGaussians(i).amplitude = amplitude(i);
%
% end
%
% % Update handles structure
% mainhandles.settings.SEplot.EGaussians = EGaussians;
% % mainhandles.settings.SEplot.GaussianType = 1; % 1D plot
% updatemainhandles(mainhandles)
%
% % Delete the waitbar
% if ~isempty(hWaitbar)
%     try delete(hWaitbar), end
% end
%
% % Update plot
% updateEhistGauss(histogramwindowHandles.main, histogramwindowHandles.figure1);




% %% Make
% GMFIT = gmdistribution(mu,sigma,weight);
%
%
% %% Determine multiplication factor
% [minmu, idxmin] = min(mu);
% [maxmu, idxmax] = max(mu);
% xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian
% for i = 1:nGaussians
%     obj = gmdistribution(mu(i),sigma(i),weight(i));
% %     xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian i
%     Y = pdf(obj,xi); % Make normal distribution vector based on fit
%     if i==1
%         Ytot = Y;
%     else
%         Ytot = Ytot+Y;
%     end
% end
%
% %%
% % Determine multiplication factor for overlaying fit on
% % plotted bar histogram
% data = getBarplotData(histogramwindowHandles.Ehist); % Histogram data
% data = data{:};
% Ytemp = pdf(GMFIT,data(:,1)); % Make normal distribution vector based on fit
% C = data(:,2)\Ytemp(:); % Multiplication factor
% C = 1/C;
% amplitude = weight*C; % Amplitudes of each component
%
% % Create total distribution
% [minmu, idxmin] = min(mu);
% [maxmu, idxmax] = max(mu);
% xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian
% Ytot = pdf(GMFIT,xi); % Make normal distribution vector based on fit
% Ytot = Ytot*C;
% EGaussTot = [xi(:) Ytot(:)];
%
% if ~isempty(hWaitbar) % Delete waitbar
%     try delete(hWaitbar), end
% end
%
% %% Update Gaussians structure
% EGaussians = mainhandles.settings.SEplot.EGaussians;
% EGaussians(:) = [];
% mainhandles.settings.SEplot.EGaussTot = EGaussTot;
%
% for i = 1:nGaussians
%
%     obj = gmdistribution(mu(i),sigma(i),weight(i));
%     xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian i
%     Y = pdf(obj,xi); % Make normal distribution vector based on fit
%     Y = Y*C*weight(i);
%
%     EGaussians(i).x = xi;
%     EGaussians(i).y = Y;
%     EGaussians(i).color = colorOrder(i);
%     EGaussians(i).mu = mu(i);
%     EGaussians(i).sigma = sigma(i);
%     EGaussians(i).weight = weight(i)/sum(weight); % Normalize weights
%     EGaussians(i).amplitude = amplitude(i);
%
% end
%
% % Update handles structure
% mainhandles.settings.SEplot.EGaussians = EGaussians;
% updatemainhandles(mainhandles)
%
% % Delete the waitbar
% if ~isempty(hWaitbar)
%     try delete(hWaitbar), end
% end
%
% % Update plot
% updateEhistGauss(histogramwindowHandles.main, histogramwindowHandles.figure1);
%
% end
%
% %                 figure(2)
% %                 plot(xi,Ytot)
% %                 hold on
% %                 scatter(data(:,1),data(:,2),'r')
% %
% %                 colr = 'rbgkm';
% %                 test = [];
% %                 for i = 1:nGaussians
% %
% %                     obj = gmdistribution(mu(i),sigma(i),weight(i));
% %                     xi = linspace(minmu-3.5*sqrt(sigma(idxmin)),maxmu+3.5*sqrt(sigma(idxmax)),100)'; % Make x-grid for Gaussian
% %                     Y = pdf(obj,xi); % Make normal distribution vector based on fit
% %                     Y = Y*C*weight(i);
% %                     figure(2)
% %                     plot(xi,Y,colr(i))
% %
% %                     if i==1
% %                         test = Y(:);
% %                     else
% %                         test = test+Y(:);
% %                     end
% %                 end
% %                 figure
% %                 plot(xi,Ytot,'r','linewidth',3)
% %                 hold on
% %                 plot(xi,test,'k')
%
%
%
% %
% %                 % Set height of fitted distribution so that it matches histogram
% %                 [n,xout] = hist(xSEplot,nBins); % n is frequency of bin centred at xout
% %                 idx = find(xout<min(xSEplot) | xout>max(xSEplot));
% %                 nBins2 = nBins - length(idx); % Number of bins in Ehist covering Gaussian component i
% %                 [n,xout] = hist(xSEplot,nBins2); % n is frequency of bin centred at xout
% %                 Y = Y/trapz(xi,Y)*trapz(xout,n); % mean(n); % Set as approx. same size as histogram
% %
% %                 % Plot fitted distribution
% %                 plot(histogramwindowHandles.Ehist,xi,Y,Gaussians(i).color,'LineWidth',2)
