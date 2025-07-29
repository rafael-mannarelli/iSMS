function mainhandles = firstRunDemo(mainhandles)
% Called when the program is opened the first time
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
%

%% Initialize

% Return if not first run
if ~mainhandles.settings.startup.firstrun
    return
end

% The next time is no longer the first time
mainhandles = savesettingasDefault(mainhandles,'startup','firstrun',0);

% Make GUI visible now
set(mainhandles.figure1,'Visible','on')

%% Dialog

% Check file is downloaded
demofile = which('demo.iSMSsession');

% Check it has been downloaded to the resource dir already
if isempty(demofile) && exist(fullfile(mainhandles.resourcedir,'demo.iSMSsession'),'file')
    demofile = fullfile(mainhandles.resourcedir,'demo.iSMSsession');
end

% Ask to open demo session
if ~isempty(demofile)
    str = sprintf(['Hello and welcome to iSMS!\n\n'...
        'If this is the first time you run the program you may wish to load some demo data to get started.'...
        '\n\n'...
        'You have a demo session file located at:\n    %s\n\n\nDo you wish to load this session now? You will not be prompted for this again.\n\n'],demofile);
else
    str = sprintf(['Hello and welcome to iSMS!\n\n'...
        'If this is the first time you run the program you may wish to load some demo data to get started.\n\n'...
        'The demo session file will automatically be downloaded from the internet and loaded from your resource directory at:\n\n   %s'...
        '\n\n\nDo you wish to load a demo session? You will not be prompted for this again.\n\n'],mainhandles.resourcedir);
end

% Dialog
choice = myquestdlg(str,'Open demo session',' Yes ',' No thanks ', ' No thanks ');
if strcmpi(choice,' No thanks ')
    return
end

%% Download session

% Download file
if isempty(demofile) || ~exist(demofile,'file')
    
    try
        hWaitbar = mywaitbar(0.5,'Downloading session, please wait...','name','iSMS');
        
        url = 'http://j.mp/iSMS_demosession'; % Or: 'http://isms.au.dk/fileadmin/isms.au.dk/download/demo.iSMSsession';
        
        % VERSION DEPENDENT SYNTAX
        if mainhandles.matver>8.3
            demofile = websave(fullfile(mainhandles.resourcedir,'demo.iSMSsession'),url);
        else
            demofile = urlwrite(url,fullfile(mainhandles.resourcedir,'demo.iSMSsession'));
        end
        
        % Delete waitbar
        try delete(hWaitbar), end
        
    catch err
        
        % Delete waitbar
        try delete(hWaitbar), end
        
        % Error downloading
        mymsgbox('Unable to download the session file. Please download and open it manually from:\n\n  http://isms.au.dk/download')
        
        return
    end
    
    % Not downloaded
    if isempty(demofile) || ~exist(demofile,'file')
        mymsgbox('Unable to process the session file. Please download and open it manually from:\n\n  http://isms.au.dk/download.')
        return
    end
end

%% Open session

try 
    mainhandles = opensession(mainhandles.figure1,demofile);
catch err
    mymsgbox('Unable to process the session file. Please download and open it manually from http://isms.au.dk/download.')
    return
end