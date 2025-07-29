function mainhandles = savesettingasDefaultDlg(mainhandles,id1,id2,val)
% Prompts a dialog for saving setting as default
%
%    Input:
%     mainhandles   - handles structure of the main window
%     id1           - setting fieldname 1
%     id2           - setting fieldname 2
%     val           - setting value
%
%    Output:
%     mainhandles   - ..
%

% --- Copyrights (C) ---
%
% Copyright (C)  Søren Preus, FluorTools.com
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

%% Initialize

if ~iscell(id2)
    id2 = {id2};
end
if ~iscell(id1) || length(id1)~=length(id2)
    id1 = repmat({id1},1,length(id2));
end
if ~iscell(val)
    val = {val};
end

%% Save as current setting

for i = 1:length(val)
    
    % Setting i
    field1 = id1{i};
    field2 = id2{i};
    value  = val{i};
    
    % Save as current setting
    mainhandles.settings.(field1).(field2) = value;
    
end

% Update settings
updatemainhandles(mainhandles)

if ~mainhandles.settings.settings.askdefault
    % Setting set not to ask for default
    return
end

%% Check if any new setting is different from default

% Current default settings structure
defsettings = loadDefaultSettings(mainhandles, mainhandles.settings);

% Check new settings
ok = 0;
for i = 1:length(val)
    
    % Setting i
    field1 = id1{i};
    field2 = id2{i};
    value  = val{i};
    
    % Check
    if ~isequal(value,defsettings.(field1).(field2))
        
        % Dialog
        answer = myquestdlg('Do you wish to set the new setting as the default?',...
            'Save as default setting',...
            'Yes',' No, only for current session ', ' No, don''t ask again ',' No, only for current session ');
        
        % Save as default
        if strcmpi(answer,'Yes')
            ok = 1;
            
        elseif strcmpi(answer,' No, don''t ask again ')
            mainhandles.settings.settings.askdefault = 0;
            updatemainhandles(mainhandles)
            updatemainGUImenus(mainhandles)
        end
        
        break
    end
end

if ~ok
    return
end

%% Set all settings as default

for i = 1:length(val)
    
    % Setting i
    field1 = id1{i};
    field2 = id2{i};
    value  = val{i};
    
    % Save as default
    if ok && ~isequal(value,defsettings.(field1).(field2))
        mainhandles = savesettingasDefault(mainhandles,field1,field2,value);
    end
    
end
