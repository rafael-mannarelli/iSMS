function mysplashScreen()
% Updates splash screen when starting up program
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

try
    s = getappdata(0,'smsSplashHandle');
    if isempty(s)
        try rmappdata(0,'dontupdatesplashISMS'), end
    end
    
    if isempty(getappdata(0,'dontupdatesplashISMS'))
        % Only update when starting up the GUI
        
        % Open splash screen
        if isempty(s) %&& ~isdeployed
            s = SplashScreen('iSMS','splash.png',...
                'ProgressBar', 'on', ...
                'ProgressPosition', 5, ...
                'ProgressRatio', 0.0 );
            s.addText( 300, 375, 'Loading...', 'FontSize', 18, 'Color', 'white' )
            
            setappdata(0,'smsSplashHandle',s) % Point to splashScreen handle in order to delete it when GUI opens
        end
        
        % Set progressbar of splash screen
        % Total number of times the main function is being called upon
        % startup. Application and matlab version dependent.        
        v = ver('matlab');
        if str2num(v.Version)>8.3
            progTot = 3;
        else
            progTot = 4; 
        end
        
        % Running parameter counting how many times the main function has been called
        prog = getappdata(0,'smsSplashCounter');
        if isempty(prog)
            prog = 1;
        else
            prog = prog+1;
        end
        
        % Ratio used for progressbar of splashScreen
        if prog/progTot>1
            progbar = 0;
            prog = 0;
        else
            progbar = prog/progTot;
        end
        
        % Update
        set(s,'ProgressRatio', progbar) % Update progress bar
        setappdata(0,'smsSplashCounter',prog) % Update counter
    end
end
