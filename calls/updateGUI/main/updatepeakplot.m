function mainhandles = updatepeakplot(mainhandles,channel,updatepairsChoice,updateFRETpairwindowChoice)
% Updates plot of D and A peak positions. Also updates the FRET pairs (by
% running updateFRETpairs and updateFRETpairlist)
%
%    Input:
%     mainhandles  - handles structure of the main window (sms)
%     channel      - 'donor', 'acceptor', 'both, 'all'
%     updatepairsChoice - 0/1 whether to run updateFRETpairs
%     updateFRETpairwindowChoice - 0/1 whether to update FRETpairwindow
%
%    Output:
%     mainhandles  - ..
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

if nargin<2 || isempty(channel)
    channel = 'all';
end
if nargin<3 || isempty(updatepairsChoice)
    updatepairsChoice = 1;
end
if nargin<4 || isempty(updateFRETpairwindowChoice)
    updateFRETpairwindowChoice = 1;
end

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Update DA-peaks and FRET-pairs
mainhandles = updateDApeaks(mainhandles); % Removes DA peaks listed twice
if updatepairsChoice
    mainhandles = updateFRETpairs(mainhandles,file); % Removes FRETpairs listed twice or consisting of deleted
end

% Update peak counters
updatepeakcounter(mainhandles)

% Update FRET-pair window
if updateFRETpairwindowChoice
    updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle); % Update the FRET pair list of the FRET-pair window (if open)
    updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
end

% Color setting
[Dcolor,Acolor,Ecolor] = getColors(mainhandles);
% if mainhandles.matver>8.3
% else
%     if mainhandles.settings.view.colorblind
%         Dcolor = [0 1 0];%'green''blue';
%         Acolor = [1 0 1];%'magenta''yellow';
%         Ecolor = [1 1 1];%'white';
%     else
%         Dcolor = [0 1 0];%'green';
%         Acolor = [1 0 0];%'red';
%         Ecolor = [1 1 0];%'yellow';
%     end
% end

% Remove temporary markers and previous FRET-pairs
% VERSION DEPENDENT SYNTAX
if mainhandles.matver>8.3
    h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','flat');%'CData',Dcolor);
    delete(h)
%     h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','flat');%,'CData',Acolor);
%     delete(h)
%     h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','flat');%,'CData',Ecolor);
%     delete(h)
else
    h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor',Dcolor);
    delete(h)
    h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor',Acolor);
    delete(h)
    h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor',Ecolor);
    delete(h)
end
h = findobj(mainhandles.ROIimage,'Type','Text');
delete(h)

% If no data is loaded
if isempty(mainhandles.data)
    return
end

hold(mainhandles.ROIimage,'on')

%% Donors and acceptor

% Donors
if strcmp(channel,'donor') || strcmp(channel,'both')  || strcmp(channel,'all')
    [mainhandles Dpeaks] = plotPeaks(mainhandles,'D',Dcolor);
end

% Acceptors
if strcmp(channel,'acceptor') || strcmp(channel,'both') || strcmp(channel,'all')
    [mainhandles Apeaks] = plotPeaks(mainhandles,'A',Acolor);
end

%% FRET-pairs

if ~isempty(mainhandles.data(file).FRETpairs) && strcmp(get(mainhandles.Toolbar_EPeaksToggle,'State'),'on')
    
    % Determine average of D and A coordinates
    Dpeaks = [mainhandles.data(file).FRETpairs(:).Dxy];
    Dpeaks = reshape(Dpeaks,2,length(Dpeaks)/2)';
    Apeaks = [mainhandles.data(file).FRETpairs(:).Axy];
    Apeaks = reshape(Apeaks,2,length(Apeaks)/2)';
    Epeaks = double((Dpeaks+Apeaks)./2); % Converting from single to double is required for the text function
    
    % Update scatter plot
    if isempty(mainhandles.EpeaksHandle) || ~ishandle(mainhandles.EpeaksHandle)
        
        % Delete previous
        deleteMarkers(Ecolor)
%         h = findobj(mainhandles.ROIimage,'Marker','o','MarkerEdgeColor',Ecolor);
%         delete(h)
        
        % New plot
        mainhandles.EpeaksHandle = scatter(mainhandles.ROIimage,Epeaks(:,1),Epeaks(:,2), 'MarkerEdgeColor',Ecolor); % Scatter points
    else
        % Update plot
        set(mainhandles.EpeaksHandle,'XData',Epeaks(:,1)) % This is faster than above
        set(mainhandles.EpeaksHandle,'YData',Epeaks(:,2)) % This is faster than above
    end
    
    % Update text labels
    labels = cellstr( num2str((1:size(Epeaks,1))') );  % Text labels of FRET-pair ID's
    text(Epeaks(:,1), Epeaks(:,2), labels,...
        'Parent', mainhandles.ROIimage,...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','right',...
        'Color','white');
    
else
    
    % Delete previous
    deleteMarkers(Ecolor)
%     h = findobj(mainhandles.ROIimage,'Marker','o','MarkerEdgeColor',Ecolor);
%     delete(h)
    mainhandles.EpeaksHandle = [];
    h = findobj(mainhandles.ROIimage,'type','text');
    delete(h)
end
hold(mainhandles.ROIimage,'off')

%% Update

% Update mainhandles structure
updatemainhandles(mainhandles)

% Highlight pairs selected in the FRETpairwindow
highlightFRETpair(mainhandles.figure1, mainhandles.FRETpairwindowHandle)

%% Nested

    function [mainhandles, xy] = plotPeaks(mainhandles,type,col)
        xy = [];
        
        ok = 0;
        if strcmp(get(mainhandles.(['Toolbar_' type 'PeaksToggle']),'State'),'on')
            xy = mainhandles.data(file).([type 'peaks']);
            if isempty(xy)
                ok = 1;
                
            elseif isempty(mainhandles.([type 'peaksHandle'])) || ~ishandle(mainhandles.([type 'peaksHandle']))
%                 % Delete previous
        deleteMarkers(col)
%                 h = findobj(mainhandles.ROIimage,'Marker','o','MarkerEdgeColor',col);
%                 delete(h)
                
                % Plot
                mainhandles.([type 'peaksHandle']) = scatter(mainhandles.ROIimage,xy(:,1),xy(:,2),'MarkerEdgeColor',col);
                
            else
                % Plot
                set(mainhandles.([type 'peaksHandle']),'XData',xy(:,1),'YData',xy(:,2)) % This is faster than above
            end
        else
            ok = 1;
        end
        
        % Delete all previous
        if ok
%             h = findobj(mainhandles.ROIimage,'Marker','o','MarkerEdgeColor',col);
%             delete(h)
            mainhandles.([type 'peaksHandle']) = [];
        end
    end

    function deleteMarkers(col)
        
        % VERSION DEPENDENT SYNTAX
        if mainhandles.matver>8.3
            h = findobj(mainhandles.ROIimage,'Marker','o','CData',col);%'MarkerEdgeColor','flat',
            delete(h)
        else
            h = findobj(mainhandles.ROIimage,'Marker','o','MarkerEdgeColor',col);
            delete(h)
        end
    end
end