function updateDynamicsList(mainhandle,dynamicswindowHandle,choice)
% Updates FRET-pair trace listbox in the dynamics window
%
%     Input:
%      mainhandle           - handle to the main figure window
%      dynamicswindowHandle - handle to the dynamics window
%      choice               - 'pairs', 'states', or 'all'
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
if nargin<3
    choice = 'all';
end

% If one of the windows is closed
if (isempty(mainhandle)) || (isempty(dynamicswindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(dynamicswindowHandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
dynamicswindowHandles = guidata(dynamicswindowHandle);
if isempty(mainhandles.data)
    set([dynamicswindowHandles.PairListbox dynamicswindowHandles.StateListbox],'String','') % Update the listboxes
    set([dynamicswindowHandles.PairListbox dynamicswindowHandles.StateListbox],'Value',1)
    set(dynamicswindowHandles.pairlistboxBoxPanel, 'Title', sprintf('Traces analysed: 0'))
    return
end

% Get pairs containing idealized traces
selectedPairs = getPairs(mainhandle, 'Dynamics');
npairs = size(selectedPairs,1);

if npairs == 0
    set([dynamicswindowHandles.PairListbox dynamicswindowHandles.StateListbox],'String','') % Update the listboxes
    set([dynamicswindowHandles.PairListbox dynamicswindowHandles.StateListbox],'Value',1)
    set(dynamicswindowHandles.pairlistboxBoxPanel, 'Title', sprintf('Traces analysed: 0'))
    return
end

%% Update pairs listbox

if strcmpi(choice,'pairs') || strcmpi(choice,'all')
    namestr = cell(npairs,1);
    for i = 1:npairs
        filechoice = selectedPairs(i,1);
        pairchoice = selectedPairs(i,2);
        
        namestr{i} = sprintf('%i,%i', filechoice, pairchoice); % Change listbox string
    end
    
    % Set listbox name string
    set(dynamicswindowHandles.PairListbox,'String', namestr)
    
    % If there are less FRET-pairs than listbox value, set value to last
    % FRET-pair and update all plots
    if npairs < get(dynamicswindowHandles.PairListbox,'Value')
        set(dynamicswindowHandles.PairListbox,'Value',npairs)
        updateDynamicsPlot(mainhandle,dynamicswindowHandle,'trace')
    end
    
    % Update analysed traces counter
    set(dynamicswindowHandles.pairlistboxBoxPanel, 'Title', sprintf('Traces analysed: %i',npairs))
%     set(dynamicswindowHandles.BinsTextbox, 'String',sprintf('Bins: %i',npairs))
%     set(dynamicswindowHandles.analysedCounter,'String',npairs)    
end


%% Update states listbox

if strcmpi(choice,'states') || strcmpi(choice,'all')
    states = getStates(mainhandle); % Return all found states as [file pair mu(E);...]
    nstates = size(states,1);
    if nstates==0
        set(dynamicswindowHandles.StateListbox,'String','') % Update the state listbox
        set(dynamicswindowHandles.StateListbox,'Value',1)
        return
    end
    
    % Make name string
    namestr = cell(nstates,1);
    for i = 1:nstates
        filechoice = states(i,1);
        pairchoice = states(i,2);
        E = states(i,3);
        
        namestr{i} = sprintf('E%.2f (%i,%i)',E, filechoice, pairchoice); % Change listbox string
        selectedPairsListbox = get(dynamicswindowHandles.PairListbox,'Value');
        if ismember(states(i,1:2),selectedPairs(selectedPairsListbox,:),'rows','legacy')
            namestr{i} = sprintf('<HTML><b>%s</b></HTML>', namestr{i}); % Change string to HTML code
        end
    end
    
    % Set listbox name string
    set(dynamicswindowHandles.StateListbox,'String', namestr)
    
    % If there are less states than listbox value, set value to last
    % state and update histogram plot
    if nstates < get(dynamicswindowHandles.PairListbox,'Value')
        set(dynamicswindowHandles.StateListbox,'Value',nstates)
        updateDynamicsPlot(mainhandle,dynamicswindowHandle,'hist')
    end
    
    % Update number of states
    set(dynamicswindowHandles.statelistboxBoxPanel, 'Title', sprintf('States: %i',nstates))

end
