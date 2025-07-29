function [mainhandles,FRETpairwindowHandles] = correctionfactorSettingsDlg(mainhandle)
% Opens a modal dialog for specifying the settings associated with
% calculating the correction factors
%
%    Input:
%     mainhandle    - handle to the main window
%
%    Output:
%     mainhandles            - handles structure of the main window
%     FRETpairwindowHandles  - handle structure of the FRETpairwindow
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

% Get mainhandle if not provided as input
if nargin<1
    mainhandle = getappdata(0,'mainhandle');
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
try FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
catch err
    FRETpairwindowHandles = [];
end

% Settings type
if ~mainhandles.settings.corrections.FRETmethod
    [mainhandles,cancelled] = settingsdlg1(mainhandles);
else
    [mainhandles,cancelled] = settingsdlg2(mainhandles);
end

%% Update GUI

updateCorrectionFactors(mainhandle, [])
if strcmpi(get(mainhandles.Toolbar_correctionfactorWindow,'State'),'on') ...
        && ((~isequal(DefAns.spacer,answer.spacer) || ~isequal(DefAns.minframes,answer.minframes) || ~isequal(DefAns.gammaframes,answer.gammaframes))...
        || ~isequal(DefAns.medianI,answer.medianI))
    
    allPairs = getPairs(mainhandle, 'All');
    if isequal(DefAns.spacer,answer.spacer) && isequal(DefAns.minframes,answer.minframes) && ~isequal(DefAns.gammaframes,answer.gammaframes)
        mainhandles = calculateCorrectionFactors(mainhandle,allPairs,'gamma',1);
    else
        mainhandles = calculateCorrectionFactors(mainhandle,allPairs,'all',1);
    end
    updateCorrectionFactorPairlist(mainhandle,mainhandles.correctionfactorwindowHandle)
    updateCorrectionFactorPlots(mainhandle,mainhandles.correctionfactorwindowHandle)
    
end

if ~isequal(DefAns.molspec,answer.molspec) ...
        || (~isequal(DefAns.Dleakage,answer.Dleakage) || ~isequal(DefAns.Adirect,answer.Adirect) || ~isequal(DefAns.gamma,answer.gamma))
    mainhandles = correctTraces(mainhandle, 'all');
    FRETpairwindowHandles = updateFRETpairplots(mainhandle,mainhandles.FRETpairwindowHandle,'traces','ADcorrect');
end

% If histogram is open update the histogram
if strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')
    mainhandles = updateSEplot(mainhandle,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
end

%% Nested

    function [mainhandles, cancelled] = settingsdlg1(mainhandles)
        
        %% Prepare dialog box
        
        prompt = {...
            'Global correction factors (current session): ' '';...
            'Default correction factors (on startup): ' '';...
            ...
            'Donor leakage: ' 'Dleakage';...
            'Donor leakage: ' 'DleakageDef';...
            ...
            'Direct acceptor excitation: ' 'Adirect';...
            'Direct acceptor excitation: ' 'AdirectDef';...
            ...
            'Gamma factor: ' 'gamma';...
            'Gamma factor: ' 'gammaDef';...
            ...
            'Settings for calculating correction factors: ' '';...
            'Spacer from bleaching time to interval used /frames: ' 'spacer';...
            'Min. #frames used for correction factor: ' 'minframes';...
            'Default #frames pre- and post-A bleaching used for gamma factor: ' 'gammaframes';...
            'Calculate interval intensities using: ' 'medianI';...
            ...
            'OBS: You can use molecule-to-molecule specific correction factors for molecules where this is possible.' '';...
            'For molecules where correction factors are not known, the default (global) values are applied.' '';...
            'Use molecule-dependent correction factors wherever possible' 'molspec'};
        name = 'Correction factors for calculating FRET';
        
        % Formats structure:
        formats = struct('type', {}, 'style', {}, 'items', {}, ...
            'format', {}, 'limits', {}, 'size', {});
        
        % Interpolation choices
        % formats(2,1).type = 'check';
        formats(2,1).type = 'text';
        formats(3,1).type = 'edit';
        formats(3,1).size = 50;
        formats(3,1).format = 'float';
        formats(4,1).type = 'edit';
        formats(4,1).size = 50;
        formats(4,1).format = 'float';
        formats(5,1).type = 'edit';
        formats(5,1).size = 50;
        formats(5,1).format = 'float';
        
        formats(2,2).type = 'text';
        formats(3,2).type = 'edit';
        formats(3,2).size = 50;
        formats(3,2).format = 'float';
        formats(4,2).type = 'edit';
        formats(4,2).size = 50;
        formats(4,2).format = 'float';
        formats(5,2).type = 'edit';
        formats(5,2).size = 50;
        formats(5,2).format = 'float';
        
        formats(8,1).type = 'text';
        formats(9,1).type = 'edit';
        formats(9,1).size = 50;
        formats(9,1).format = 'integer';
        formats(10,1).type = 'edit';
        formats(10,1).size = 50;
        formats(10,1).format = 'integer';
        formats(11,1).type = 'edit';
        formats(11,1).size = 50;
        formats(11,1).format = 'integer';
        formats(12,1).type = 'list';
        formats(12,1).style = 'popupmenu';
        formats(12,1).items = {'Mean intensity';'Median intensity'};
        
        formats(14,1).type = 'text';
        formats(15,1).type = 'text';
        formats(16,1).type = 'check';
        
        % Load default settings
        defsettings = loadDefaultSettings(mainhandles,mainhandles.settings);
        
        % Default choices
        DefAns.Dleakage = mainhandles.settings.corrections.Dleakage;
        DefAns.Adirect = mainhandles.settings.corrections.Adirect;
        DefAns.gamma = mainhandles.settings.corrections.gamma;
        DefAns.DleakageDef = defsettings.corrections.Dleakage;
        DefAns.AdirectDef = defsettings.corrections.Adirect;
        DefAns.gammaDef = defsettings.corrections.gamma;
        
        DefAns.spacer = mainhandles.settings.corrections.spacer;
        DefAns.minframes = mainhandles.settings.corrections.minframes;
        DefAns.gammaframes = mainhandles.settings.corrections.gammaframes;
        DefAns.medianI = mainhandles.settings.corrections.medianI+1;
        DefAns.molspec = mainhandles.settings.corrections.molspec;
        
        options.CancelButton = 'on';
        
        %% Open dialog box
        
        [answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
        if (cancelled==1) || (isequal(DefAns,answer))
            cancelled = 1;
            return
        end
        
        %% Set new settings
        
        % Values
        note = 0;
        [mainhandles.settings.corrections.Dleakage note] = correctValue(answer.Dleakage, note);
        [mainhandles.settings.corrections.Adirect note] = correctValue(answer.Adirect, note);
        [mainhandles.settings.corrections.gamma note] = correctValue(answer.gamma, note);
        [defsettings.corrections.Dleakage note] = correctValue(answer.DleakageDef, note);
        [defsettings.corrections.Adirect note] = correctValue(answer.AdirectDef, note);
        [defsettings.corrections.gamma note] = correctValue(answer.gammaDef, note);
        
        if note
            mymsgbox('Note that only positive correction factors are possible');
        end
        
        % Other settings
        mainhandles.settings.corrections.spacer = answer.spacer;
        mainhandles.settings.corrections.minframes = answer.minframes;
        mainhandles.settings.corrections.gammaframes = answer.gammaframes;
        mainhandles.settings.corrections.medianI = answer.medianI-1;
        mainhandles.settings.corrections.molspec = answer.molspec;
        updatemainhandles(mainhandles)
        
        % Save new default settings
        saveDefaultSettings(mainhandles,defsettings);

    end

    function [mainhandles, cancelled] = settingsdlg2(mainhandles)
        %% Prepare dialog
        formats = prepareformats();
        prompt = {'Epsilon of D at D exc.: ' 'epsDD';...
            'Epsilon of A at A exc.: ' 'epsAA';...
            'Donor leakage: ' 'Dleakage';...
            'Direct acceptor: ' 'Adirect'};
        name = 'Correction factor settings';
        
        formats(3,1).type = 'edit';
        formats(3,1).size = 50;
        formats(3,1).format = 'float';
        formats(4,1).type = 'edit';
        formats(4,1).size = 50;
        formats(4,1).format = 'float';
        formats(5,1).type = 'edit';
        formats(5,1).size = 50;
        formats(5,1).format = 'float';
        formats(6,1).type = 'edit';
        formats(6,1).size = 50;
        formats(6,1).format = 'float';
        
        % Dialog
        [answer,cancelled] = inputsdlg(prompt,name,formats,DefAns);
        if cancelled || isequal(DefAns,answer)
            cancelled = 1;
            return
        end
        
        %% Update
        
        % Values
        note = 0;
        mainhandles.settings.corrections.epsDD = answer.epsDD;
        mainhandles.settings.corrections.epsAA = answer.epsAA;
        [mainhandles.settings.corrections.Dleakage note] = correctValue(answer.Dleakage, note);
        [mainhandles.settings.corrections.Adirect note] = correctValue(answer.Adirect, note);
        
        % Dialog
        if note
            mymsgbox('Note that only positive correction factors are possible');
        end
        
        % Update handles
        updatemainhandles(mainhandles)
    end

end

function [val note] = correctValue(val,note)
if val < 0
    val = 0;
    note = 1;
end
end

