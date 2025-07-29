function hasTB = checkforParTB()
% Special check for parallel computing toolbox
%
%    Output:
%     hasTB   - 0/1
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

% Initialize
hasTB = 1;
if isdeployed
    return
end

% get all installed toolbox names
v = ver;

% collect the names in a cell array
[installedToolboxes{1:length(v)}] = deal(v.Name);

% check
hasTB = ismember('Parallel Computing Toolbox',installedToolboxes);
