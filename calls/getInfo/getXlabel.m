function str = getXlabel(mainhandles,ax)
% Returns axes xlabel-string
%
%    Input:
%     mainhandles   - handles structure of the main window
%     ax            - string specifying unique axes
%
%    Output:
%     str           - string to put as label
%

%% Initialize

str = 'x'; % Default
alex = mainhandles.settings.excitation.alex; % Shorten

%% FRETpair window

%% Histogramwindow

if strcmpi(ax,'Ehist')
    if alex
        str = '';
    else
        str = 'FRET efficiency (E)';
    end
    return
end
