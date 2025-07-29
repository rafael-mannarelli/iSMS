function updatelogo(h)
% Updates the window logo of figure handle h
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

try
    if nargin<1 || ~ishandle(h)
        h = gcf; % Default is current figure
    end
    
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jframe = get(h,'javaframe');
    
    mainhandles = guidata(getappdata(0,'mainhandle'));    
    jIcon = javax.swing.ImageIcon(fullfile(mainhandles.workdir,'resources','logo.PNG'));
    jframe.setFigureIcon(jIcon);
    
    
end
