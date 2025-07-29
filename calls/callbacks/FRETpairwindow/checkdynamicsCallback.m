function mainhandles = checkdynamicsCallback(fpwHandles)
% Callback for the check dynamics function in the FRETpairwindow
%
%    Input:
%     fpwHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles - handles structure of the main window
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

mainhandles = getmainhandles(fpwHandles);

selectedPairs = getPairs(mainhandles.figure1,'all');
if isempty(selectedPairs)
    return
end

% Pair selection dialog
if size(selectedPairs,1)>50
    [choices ok] = listdlg(...
        'ListString',getFRETpairString(mainhandles.figure1,fpwHandles.figure1),...
        'Name', 'Check background',...
        'PromptString', 'Select FRET pairs:',...
        'InitialValue', get(fpwHandles.PairListbox,'Value'),...
        'SelectionMode','multiple',...
        'ListSize', [400 300]);
    if ~ok
        return
    end
    selectedPairs = selectedPairs(choices,:);
end

% Get traces
traces = getTraces(mainhandles.figure1,selectedPairs,'noDarkStates',1);

% Initialize
h = ones(size(selectedPairs,1),1);
p = h;
ccP = h;
alpha = 1e-4;

%% Calculate Anderson-Darling test scores

warning off
for i = 1:size(selectedPairs,1)
%     file = allPairs(i,1);
%     pair = allPairs(i,2);
%     
%     [h(i), p(i)] = adtest(traces(i).E, 'alpha',alpha);
    
    % Cross correlation
    try
        [R, P] = corrcoef(traces(i).DD,traces(i).AD);
        p(i) = P(2);
    end        
    
end
warning on
% figure
% plot(traces(2).E)


%% Plot

h = find(p<alpha);
if isempty(h)
    mymsgbox('No dynamic traces found.')
    return
end

%% Make new group

mainhandles = createNewGroup(mainhandles,selectedPairs(h,:),'Dynamics (auto)');

% Check if a group is now empty
mainhandles = checkemptyGroups(mainhandles.figure1);

% Update
mainhandles = updateGUIafterNewGroup(mainhandles.figure1);

%% Plot

% Plot is only for internal use
return

p = 1-p;
maxlab = 1-alpha;
% fh = figure;
% set(fh,'name','Anderson-Darling test results','numbertitle','off')
% updatelogo(fh)

plotP(1:length(p),p,1,'adtest on FRET efficiency')
plotP(1:length(p),ccP,1,'corrcoef scores')

%% Nested

    function plotP(x,y,ax,tit)
%         subplot(3,1,ax)
        figure
        bar(x,y)
        
        title(tit)
        ylabel('P value')
        xlabel('FRETpair')
        
        % Bar labels
        for i = 1:length(y)
            if y(i)<maxlab
                txtlab = '';
            else
                txtlab = sprintf('(%i,%i)',selectedPairs(i,1),selectedPairs(i,2));
            end
            
            text(x(i),y(i), txtlab,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom')
        end
        
        hold on
        plot(get(gca,'xlim'),[maxlab maxlab],'-r')
        zoom reset
        ylim([1-2*(1-maxlab) 1.002])
    end

end