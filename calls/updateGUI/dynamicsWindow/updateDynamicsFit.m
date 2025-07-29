function updateDynamicsFit(mainhandle,dynamicswindowHandle)
% Update the fit plot in the dynamics analysis window
%
%    Input:
%     mainhandle            - handle to main GUI window (sms)
%     dynamicswindowHandle  - handle to the FRET-pair GUI window
%     choice                - 'trace', 'hist', 'fit', 'all'. Chooses which
%                              axes to update 
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

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(dynamicswindowHandle))
    return
elseif (~ishandle(mainhandle)) || (~ishandle(dynamicswindowHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
dynamicswindowHandles = guidata(dynamicswindowHandle); % Handles to the dynamics window

% If there is no data, remove previous plot and return
if (isempty(mainhandles.data)) || ~mainhandles.settings.dynamicsplot.fit || get(dynamicswindowHandles.PlotPopupmenu,'Value')~=1
%     cla(dynamicswindowHandles.HistAxes)
    updateDynamicsPlot(mainhandle,dynamicswindowHandle,'hist')
    return
end

% Get bar plot data

% VERSION DEPENDENT SYNTAX
if mainhandles.matver>8.3
    barHandle = findobj(dynamicswindowHandles.HistAxes,'-property','VertexNormalsMode');
else
    barHandle = findobj(dynamicswindowHandles.HistAxes,'-property','Normalmode');
end
if isempty(barHandle) || ~ishandle(barHandle)
    return
end
ydata = get(barHandle,'ydata'); % Y-data of bar plot (size 4xm)
xdata = get(barHandle,'xdata'); % X-data of bar plot (size 4xm)
if isempty(ydata) || isempty(xdata)
    return
end
y = ydata(2,:);
x = mean(xdata(2:3,:));
data = [x(:) y(:)];

% Parameters
start = [max(data(:,2))*1.5 0];
lb = [0 0];
ub = [inf inf];
exponentials = str2num(get(dynamicswindowHandles.ExponentialsEditbox,'String'));
if exponentials == 1
    start = [start 1]; % k
    lb = [lb 0];
    ub = [ub inf];
elseif exponentials == 2
    start = [start 0.1 1 0.2]; % k1, k2, a
    lb = [lb 0 0 0];
    ub = [ub inf inf 1];
end

%% Optimize

[X,ChiSq,res,~,~,~,jacobian] = lsqnonlin(@expfun,start,lb,ub, optimset('MaxFunEvals',5000,'Display','off'),data); % Implicit data weighting using lsqcurvefit

% Get fit
% [res,sim] = expfun(X,data);

%% Update

set(dynamicswindowHandles.parTable,'data',X(:))
set(dynamicswindowHandles.parTable,'UserData',data)
set(dynamicswindowHandles.ChiSqCounter,'String',sprintf('%.2f',sum(res.^2)/length(res)))
updateDynamicsPlot(mainhandle,dynamicswindowHandle,'fit')
