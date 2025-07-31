function mainhandles = autorunSettingsCallback(mainhandles)
% Callback for autorun settings in main window
%
%    Input:
%     mainhandles    - handles structure of the main window
%
%    Output:
%     mainhandles    - ..
%

%% Initialize

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar

%% Dialog box

name = 'Settings';

% Make prompt structure
prompt = {...
    'Run auto analysis on:' 'AllFiles';...
    'Auto align ROIs as a first step' 'autoROI';...
    'Auto-detect bleaching times' 'autoBleach';...
    'Run DeepFRET classification at the end' 'deepFRET';...
    'Filter-settings are set in: ''Settings->Molecule filter''.' '';...
    'Use molecule-filter 1 (intensity based)' 'filter1';...
    'Use molecule-filter 2 (density based)' 'filter2';...
    'Use molecule-filter 3 (bleaching based)' 'filter3';...
    'Group molecules:' '';...
    'Create groups for molecules with bleaching' 'groupbleach'};

% formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type = 'list';
formats(2,1).style = 'popupmenu';
formats(2,1).items = {'All files' 'Only selected'};
formats(4,1).type = 'check';
formats(5,1).type = 'check';
formats(6,1).type = 'check';
formats(8,1).type = 'text';
formats(9,1).type = 'check';
formats(10,1).type = 'check';
formats(11,1).type = 'check';
formats(13,1).type = 'text';
formats(14,1).type = 'check';

% Make DefAns structure
DefAns.AllFiles = mainhandles.settings.autorun.AllFiles;
DefAns.autoROI = mainhandles.settings.autorun.autoROI;
DefAns.autoBleach = mainhandles.settings.autorun.autoBleach;
DefAns.deepFRET = mainhandles.settings.autorun.deepFRET;
DefAns.filter1 = mainhandles.settings.autorun.filter1;
DefAns.filter2 = mainhandles.settings.autorun.filter2;
DefAns.filter3 = mainhandles.settings.autorun.filter3;
DefAns.groupbleach = mainhandles.settings.autorun.groupbleach;

% Open dialog box
[answer, cancelled] = myinputsdlg(prompt, name, formats, DefAns);
if cancelled == 1
    return
end

%% Update settings

mainhandles = savesettingasDefaultDlg(mainhandles,...
    'autorun',...
    {'AllFiles' 'autoROI' 'autoBleach' 'deepFRET' 'filter1' 'filter2' 'filter3' 'groupbleach'},...
    {answer.AllFiles, answer.autoROI, answer.autoBleach, answer.deepFRET, answer.filter1, answer.filter2, answer.filter3, answer.groupbleach});
