function updateGaussianComponentsWindow(mainhandle,hwHandle,GaussianComponentsWindowHandle)
% Updates the Gaussian components tables of the GaussianComponentsWindow
% associated with the histogramwindow.
%
%    Input:
%     mainhandle                     - handle to the main figure window
%     hwHandle                       - handle to the histogramwindow
%     GaussianComponentsWindowHandle - handle to the Gaussian components
%                                      window
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

% If one of the windows is closed
if (isempty(mainhandle)) || (isempty(hwHandle)) ||...
        (~ishandle(mainhandle)) || (~ishandle(hwHandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
hwHandles = guidata(hwHandle);

if mainhandles.settings.excitation.alex
    updateforALEX(mainhandles,hwHandles,GaussianComponentsWindowHandle)
else
    updateforSC(mainhandles,hwHandles)
end

end

function updateforALEX(mainhandles,hwHandles,GaussianComponentsWindowHandle)
if (isempty(GaussianComponentsWindowHandle)) || (~ishandle(GaussianComponentsWindowHandle))
    return
end

GaussianComponentsWindowHandles = guidata(GaussianComponentsWindowHandle);
h = findobj(hwHandles.SEplot,'type','line'); % Plotted data
if (isempty(mainhandles.data)) || (isempty(mainhandles.settings.SEplot.EGaussians) && isempty(mainhandles.settings.SEplot.SGaussians)) || (isempty(h))
    set(GaussianComponentsWindowHandles.Etable,'data',[]) % Update the FRET-pairs listbox
    set(GaussianComponentsWindowHandles.Stable,'data',[])
    set(GaussianComponentsWindowHandles.Etable,'RowName',{})
    set(GaussianComponentsWindowHandles.Stable,'RowName',{})
    return
end

%% Make E table array

EGaussians = mainhandles.settings.SEplot.EGaussians;
if isempty(EGaussians)
    Etable = [];
else
    Etable = zeros(length(EGaussians),3);
    ok = 0;
    for i = length(EGaussians):-1:1
        Etable(i,1) = EGaussians(i).mu;
        Etable(i,2) = EGaussians(i).sigma*2.3548;
        Etable(i,3) = EGaussians(i).weight;
    end
end

%% Make S table array

SGaussians = mainhandles.settings.SEplot.SGaussians;
if isempty(SGaussians)
    Stable = [];
else
    Stable = zeros(length(SGaussians),3);
    ok = 0;
    for i = length(SGaussians):-1:1
        Stable(i,1) = SGaussians(i).mu;
        Stable(i,2) = SGaussians(i).sigma*2.3548;
        Stable(i,3) = SGaussians(i).weight;
    end
end

%% Update window

set(GaussianComponentsWindowHandles.Etable,'data',Etable)
set(GaussianComponentsWindowHandles.Stable,'data',Stable)
set(GaussianComponentsWindowHandles.Etable,'RowName',{EGaussians(:).color})
set(GaussianComponentsWindowHandles.Stable,'RowName',{SGaussians(:).color})
end

function updateforSC(mainhandles,hwHandles)
% h = findobj(histogramwindowHandles.Ehist,'type','line'); % Plotted data
if isempty(mainhandles.data) || isempty(mainhandles.settings.SEplot.EGaussians)% || (isempty(h))
    set(hwHandles.GaussTable,'data',[]) % Update the FRET-pairs listbox
    set(hwHandles.GaussTable,'RowName',{})
    return
end

%% Make E table array

EGaussians = mainhandles.settings.SEplot.EGaussians;
if isempty(EGaussians)
    Etable = [];
else
    Etable = zeros(length(EGaussians),3);
    ok = 0;
    for i = length(EGaussians):-1:1
        Etable(i,1) = EGaussians(i).mu;
        Etable(i,2) = EGaussians(i).sigma*2.3548;
        Etable(i,3) = EGaussians(i).weight;
    end
end

%% Update window

set(hwHandles.GaussTable,'data',Etable)
set(hwHandles.GaussTable,'RowName',{EGaussians(:).color})

end