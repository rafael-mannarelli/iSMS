function ok = createFolders(mainhandles)
% Creates required folders on first startup of deployed application
%
%   Input
%    mainhandles   - handles structure of the main window
%
%   Output:
%    ok            - folders created 0/1
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

% Initialize
ok = 1;

% Only if deployed
if ~isdeployed
    return
end

% Required folders on path
f = {mainhandles.settingsdir,...
    mainhandles.resourcedir};

% Create the folder if it doesn't exist already.
for i = 1:length(f)
    d = f{i};
    
    % Create directory if it doesn't already exist
    if ~exist(d, 'dir')
        
        try
            mkdir(d);
            
        catch err
            
            % Access denied error
            if strcmpi(err.identifier,'MATLAB:MKDIR:OSError') ...
                    && (isempty(getappdata(0,'administratorMsgbox')) || ~ishandle(getappdata(0,'administratorMsgbox')))
                
                % Message box
                if length(mainhandles.workdir)>16 && strcmpi(mainhandles.workdir(4:16),'Program Files')
                    message = sprintf(['Hi,\n\niSMS is unable to run when installed in your ''Program Files'' folder.\n\n'...
                        'TO FIX THIS ISSUE, simply copy the iSMS installation folder to a different directory outside ''Program Files''.\n\n'...
                        'This is because the software must be able to create and save setup files on startup, which Windows blocks within ''Program Files''.\n\n'...
                        'Thanks.'],mainhandles.workdir);
                    
                else
                    message = sprintf(['Hello,\n\nALL YOU NEED now is to copy the installation folder and files to a location with administrator rights, this may simply be your Documents folder, or login as administrator.\n\n'...
                        'This is because iSMS was not allowed to create necessary folders and files at:\n  %s\n\n'...
                        'You must have administrator rights at the directory of installation.\n\n'...
                        'Remember to update your program shortcuts accordingly.\n'],mainhandles.workdir);
                    
                end
                h = mymsgbox(message,'Use different folder');
                
                % Open installation folder
                try winopen(mainhandles.workdir); end
                
                % Only show box once
                setappdata(0,'administratorMsgbox', h)
                
                
            else
                rethrow(err)
            end
            ok = 0;
            
            % Turn attention back to figure
            figure(mainhandles.figure1)
            
            return
        end
    end
    
    % Move some installation files that is located in the
    % installation folder at first run
    
    % FIX on ver 1.05: Files below are not allowed to be moved from program
    % files installation directory on some systems. Required installation
    % files are now kept at installation dir.
%     if i==1
%         % Move to settings
% %         try movefile(fullfile(mainhandles.workdir,'data.template'), d,'f'), end
%         
%     elseif i==2
%         % Move to resources folder
%         
%         %                 try movefile(fullfile(mainhandles.workdir,'splash.png'),
%         %                 d,'f'), end % Keep splash screen in installation dir
%         
% %         try movefile(fullfile(mainhandles.workdir,'logo.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelClose.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelDock.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelHelp.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelMaximize.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelMenu.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelMenu2.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelMenu3.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelMinimize.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelRun.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelRun1.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'panelUndock.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'ROIchannel.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'overview_zoom_in.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'overview_zoom_out.png'), d,'f'), end
% %         try movefile(fullfile(mainhandles.workdir,'saveIcon.png'), d,'f'), end
%     end
    
end
