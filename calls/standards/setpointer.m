function pointer = setpointer(h,choice)
% Set pointer in figure h to choice and return the current pointer
%
%   Input:
%    h      - figure handle
%    choice - 'watch', 'arrow',...
%
%   Output:
%    pointer - previous pointer state
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

% Default is thinking
if nargin<2
    choice = 'watch';
end

% Current pointer
pointer = get(h,'pointer'); % e.g 'arrow'

% New pointer
try
    set(h, 'pointer', choice)
    drawnow
catch err
    err.message
end