function mainhandles = vbFRETsettings(mainhandle)
% Opens a dialog for specifying settings associated with vbFRET analysis
%
%    Input:
%     mainhandle   - handle to main GUI window
%
%    Output:
%     mainhandles  - handles structure of the main window
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

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    mainhandles = [];
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)

%% Prepare dialog box

prompt = {'No. of FRET states possible: ' '';...
    'Min: ' 'minStates';...
    'Max: ' 'maxStates';...
    'Guess some states (comma-separated): ' '';...
    'E: ' 'startGuess';...
    'Use the manual start guesses' 'useStartGuess';...
    'Optimization Options: ' '';...
    'Fitting attempts per trace: ' 'attempts';...
    'Max iterations per VBEM: ' 'maxIter';...
    'Convergence threshold: ' 'threshold';...
    'Hyperparameter Priors: ' '';...
    'upi: ' 'upi';...
    'mu: ' 'mu';...
    'beta: ' 'beta';...
    'W: ' 'W';...
    'v: ' 'v';...
    'ua: ' 'ua';...
    'uad: ' 'uad'};
name = 'vbFRET Settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% No. of states options
formats(2,1).type = 'text';
formats(2,2).type = 'edit';
formats(2,2).size = 50;
formats(2,2).format = 'integer';
formats(3,2).type = 'edit';
formats(3,2).size = 50;
formats(3,2).format = 'integer';
% start guess
formats(4,1).type = 'text';
formats(4,2).type = 'edit';
formats(4,2).size = 150;
formats(5,2).type = 'check';
% Optimization options
formats(7,1).type = 'text';
formats(7,2).type = 'edit';
formats(7,2).size = 50;
formats(7,2).format = 'integer';
formats(8,2).type = 'edit';
formats(8,2).size = 50;
formats(8,2).format = 'integer';
formats(9,2).type = 'edit';
formats(9,2).size = 50;
formats(9,2).format = 'float';
% Hyperparameter priors
formats(11,1).type = 'text';
formats(11,2).type = 'edit';
formats(11,2).size = 50;
formats(11,2).format = 'float';
formats(12,2).type = 'edit';
formats(12,2).size = 50;
formats(12,2).format = 'float';
formats(13,2).type = 'edit';
formats(13,2).size = 50;
formats(13,2).format = 'float';
formats(14,2).type = 'edit';
formats(14,2).size = 50;
formats(14,2).format = 'float';
formats(15,2).type = 'edit';
formats(15,2).size = 50;
formats(15,2).format = 'float';
formats(16,2).type = 'edit';
formats(16,2).size = 50;
formats(16,2).format = 'float';
formats(17,2).type = 'edit';
formats(17,2).size = 50;
formats(17,2).format = 'float';

% formats(17,2).type = 'check';

% Default choices
if isempty(mainhandles.settings.vbFRET.startGuess)
    DefAns.startGuess = [];
else
    startGuessString = sprintf('%.2f',mainhandles.settings.vbFRET.startGuess(1));
    if length(mainhandles.settings.vbFRET.startGuess)>1
        for i = 2:length(mainhandles.settings.vbFRET.startGuess)
            startGuessString = sprintf('%s, %.2f',startGuessString,mainhandles.settings.vbFRET.startGuess(i));
        end
    end
    DefAns.startGuess = startGuessString;
end
DefAns.useStartGuess = mainhandles.settings.vbFRET.useStartGuess;
DefAns.minStates = mainhandles.settings.vbFRET.minStates;
DefAns.maxStates = mainhandles.settings.vbFRET.maxStates;
DefAns.attempts = mainhandles.settings.vbFRET.attempts;
DefAns.maxIter = mainhandles.settings.vbFRET.maxIter;
DefAns.threshold = mainhandles.settings.vbFRET.threshold;
DefAns.upi = mainhandles.settings.vbFRET.upi;
DefAns.mu = mainhandles.settings.vbFRET.mu;
DefAns.beta = mainhandles.settings.vbFRET.beta;
DefAns.W = mainhandles.settings.vbFRET.W;
DefAns.v = mainhandles.settings.vbFRET.v;
DefAns.ua = mainhandles.settings.vbFRET.ua;
DefAns.uad = mainhandles.settings.vbFRET.uad;
% DefAns.runchoice = 0;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)
    return
end

%% Set new settings

stateLim = sort([abs(answer.minStates) abs(answer.maxStates)]); % Maks sure minStates is smaller than max states
mainhandles.settings.vbFRET.useStartGuess = answer.useStartGuess; % Choice of whether to use the manually specified start guesses
mainhandles.settings.vbFRET.startGuess = str2num(answer.startGuess); % Manual FRET state start guesses
mainhandles.settings.vbFRET.minStates = stateLim(1); % Min. no. of FRET states
mainhandles.settings.vbFRET.maxStates = stateLim(2); % Max. no. of FRET states
mainhandles.settings.vbFRET.attempts = abs(answer.attempts); % Stop after vb_opts iterations if program has not yet converged
mainhandles.settings.vbFRET.maxIter = abs(answer.maxIter); % Stop after vb_opts iterations if program has not yet converged
mainhandles.settings.vbFRET.threshold = abs(answer.threshold); % Stop when two iterations have the same evidence to within this
mainhandles.settings.vbFRET.upi = answer.upi; % Probability of first state being state k
mainhandles.settings.vbFRET.mu = answer.mu; % Mean of FRET Gaussian distribution of state k
mainhandles.settings.vbFRET.beta = answer.beta; % Spread of Gaussian of state k
mainhandles.settings.vbFRET.W = answer.W; % Gamma-distribution parameter of state k
mainhandles.settings.vbFRET.v = answer.v; % Gamma-distribution parameter of state k
mainhandles.settings.vbFRET.ua = answer.ua; % Related to transition probability between states
mainhandles.settings.vbFRET.uad = answer.uad; % Related to transition probability between state

%% Update GUI

updatemainhandles(mainhandles)

% % Run vbFRET analysis
% if answer.runchoice
%     Toolbar_vbAnalysis_ClickedCallback(handles.Toolbar_vbAnalysis, [], handles)
% end

