function mainhandles = checkScreenResolution(mainhandles)
% Checks the screen resolution registered by MATLAB. If screenpixelsperinch
% is 116 in win7, it is likely because zooming is activated unintensionally
%
%    Input:
%     mainhandles    - handles structure of the main window. Must contain a
%                      field settings.startup.zoomMessage and an editbox
%                      with handle handles.mboard  
%
%    Output:
%     mainhandles     - ..
%

% --- Copyrights (C) ---
%
% Copyright (C)  S�ren Preus, FluorTools.com
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

if ~ispc
    return
end

currentScreenResolution = get(0,'ScreenPixelsPerInch');

if ispc && currentScreenResolution==116 && mainhandles.settings.startup.zoomMessage
    
    % Prompt dialog
    choice = myquestdlg(sprintf('%s\n\n%s\n\n%s\n ',...
        'OBS: You might have, unintentionally, activated text zooming in Windows. ',...
        'This setting will cause anormalities in the GUI layout - such as missing text and odd object sizes.',...
        'It is highly recommended you turn off text zooming in Windows and restart the program. For instructions follow the link below.'),...
        mainhandles.name,...
        ' How to turn off zooming ' , ' Please don''t tell me again ' , ' Continue ', ' How to turn off zooming ');
    
    % Put attention back to GUI. This is important in order not to
    % crash in some versions of MATLAB
    state = get(mainhandles.figure1,'Visible');
    figure(mainhandles.figure1)
    set(mainhandles.figure1,'Visible',state)
    
    % If user pressed button
    if strcmpi(choice,' How to turn off zooming ')
        
        URL = 'http://www.fluortools.com/misc/textzooming'; % Link to website
        try
            state = web(URL,'-browser'); % try opening the url in the default browser
            if state~=0 % If unsuccessfull
                try
                    set(mainhandles.mboard,'String',sprintf('Internet action unsuccessful. Open page manually in your browser:\n\n%s',URL))
                end
            end
            
        catch err % If there was an error trying to open browser
            try
                set(mainhandles.mboard,'String',sprintf('Internet action unsuccessful. Open page manually in your browser:\n\n%s',URL))
            end
        end
        
        
    elseif strcmpi(choice, ' Please don''t tell me again ')
        
        % Update handles structure
        mainhandles.settings.startup.zoomMessage = 0;
        saveSettings(mainhandles); % Saves settings structure to .mat file
    end
end
