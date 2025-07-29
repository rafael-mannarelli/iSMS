function [mainhandles ok] = peaksliderWarningDlg(mainhandles)
% Opens a warning dialog when using peak sliders when raw data is missing
%
%    Input:
%     mainhandles    - handles structure of the main window
%
%    Output:
%     mainhandles    - ..
%     ok             - 0/1 whether to continue
%

%% Initialize

ok = 1;

% Filechoice
file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

if ~isempty(mainhandles.data(file).imageData) || ~isempty(mainhandles.data(file).DD_ROImovie)
    return
end

%% Show dialog
mainhandles.settings.infobox.peaksliderWarning
if mainhandles.settings.infobox.peaksliderWarning
    
    % Simulate button release
    import java.awt.Robot;
    import java.awt.event.*;
    mouse = Robot;
    mouse.mouseRelease(InputEvent.BUTTON1_MASK);
    
    % String to show
    str = sprintf(['The raw image data is missing for the selected file. '...
        'You can therefore localize peaks, but you can''t calculate the traces until the raw image data is reloaded.\n\n'...
        'All FRET-pairs in the file will be removed until the raw data is reloaded.\n\n'...
        'Raw image data is reloaded from the ''Performance->Memory menu.\n\n\n'...
        '  Are you sure you want to continue?\n\n ']);
    
    % Open dialog
    answer = myquestdlg(...
        str,...
        'Raw data missing',...
        ' Cancel ',...
        ' Continue ',...
        ' Continue, don''t ask again ',...
        ' Continue ');
    
    % Answer
    ok = 0;
    if strcmpi(answer,' Continue ') || strcmpi(answer, ' Continue, don''t ask again ')
        ok = 1;
        
        if strcmpi(answer, ' Continue, don''t ask again ')
            mainhandles.settings.infobox.peaksliderWarning = 0;
            updatemainhandles(mainhandles)
        end
    end
    
    if ~ok
        return
    end
end
