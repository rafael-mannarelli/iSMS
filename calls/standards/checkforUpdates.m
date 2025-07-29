function mainhandles = checkforUpdates(mainhandles, checkURL)
% Checks for a newer version of the software
%
%     Input:
%      mainhandles    - handles structure of the main window. Must
%                       contain fields: name, version, website,
%                       settings.startup.checkforUpdates and
%                       splashScreenHandle
%
%     Output:
%      mainhandles    - ..
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

% Check setting
if ~mainhandles.settings.startup.checkforUpdates
    return
end

% Input
name = mainhandles.name; % Name of software
CurrentVersion = str2double(mainhandles.version); % Current version of software
website = mainhandles.website; % Software's website
splashScreenHandle = mainhandles.splashScreenHandle; % Handle to the splash screen running on startup

% Update splash screen message
if ~isempty(splashScreenHandle) && isvalid(splashScreenHandle)
    splashScreenHandle.addText( 20, 375, 'Checking for updates...', 'FontSize', 18, 'Color', 'white' )
%     splashScreenHandle.addText( 30, 270, 'Checking for updates...', 'FontSize', 18, 'Color', 'white' )
end

% Get latest version
try
    
    % Url to temp file
    file = [tempname '.txt'];
    url = 'http://j.mp/checkversion_iSMS'; % Or: http://isms.au.dk/fileadmin/isms.au.dk/version/version.txt 
    
    % Download temporary text file. VERSION DEPENDENT SYNTAX
    if mainhandles.matver>8.3
        options = weboptions('TimeOut',5);
        file = websave(file,url, options);
    else
        [file,URLstatus] = urlwrite(url,file, 'Timeout',5);
        if URLstatus==0
            return
        end
    end
    
    % Read version from file
    fileID = fopen(file,'r');
    LatestVersion = fscanf(fileID,'%f');
    
    % Close and delete temp file
    fclose(fileID);
    delete(file)
    
catch err
    
    % Don't check next time
    mainhandles = savesettingasDefault(mainhandles,'startup','checkforUpdates',0);
    return
end

if CurrentVersion<LatestVersion % If current version is older than newest version
    
    % Open update dialog
    yesword = {'Woohoo' 'Yes' 'Sweet' 'Awesome' 'Check this out'};
    choice = myquestdlg(sprintf(...
        '%s! There is a newer version of %s available.\n\n  Current version: %s\n  Latest version:  %s\n',...
        yesword{randi(length(yesword),1)}, name, num2str(CurrentVersion), num2str(LatestVersion)), ...
        'Update available', ...
        ' Go to website ',' Please don''t tell me again ', ' Continue ', ' Go to website ');
    
    % Put attention back to GUI. This is important in order not to
    % crash in some versions of MATLAB
    state = get(mainhandles.figure1,'Visible');
    figure(mainhandles.figure1)
    set(mainhandles.figure1,'Visible',state)
    
    % Handle response
    if isempty(choice)
        return
        
    elseif strcmpi(choice,' Go to website ')
        
        try
            state = web(website,'-browser'); % try opening the url in the default browser
            if state~=0 % If unsuccessfull
                mymsgbox(sprintf('Internet action unsuccessful. Open page manually in your browser:\n\n%s',website))
            end
            
        catch err % If there was an error trying to open browser
            mymsgbox(sprintf('Internet action unsuccessful. Open page manually in your browser:\n\n%s',website))
        end
        
    elseif strcmpi(choice,' Please don''t tell me again ')
        
        % Save setting
        mainhandles = savesettingasDefault(mainhandles,'startup','checkforUpdates',0);
        
    end
end
