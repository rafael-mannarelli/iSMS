function mainhandles = updateMemorybar(mainhandles)
% Update the text of the memory textbox in the lower right corner of the
% main window
%
%     Input:
%      mainhandles  - handles structure of the main window
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

% Not supported for macs
if ismac
    set(mainhandles.MemoryTextbox,'String','')
    return
end

% Get memory info
[userview systemview] = memory; % Get info structure
memusage = (systemview.PhysicalMemory.Total - systemview.PhysicalMemory.Available)/systemview.PhysicalMemory.Total; % In bytes
memusage = round(memusage*100); % In percent

% Update memory bar
set(mainhandles.MemoryTextbox,'String',sprintf('Memory usage: %i%%',memusage))
if memusage<80
    set(mainhandles.MemoryTextbox,'ForegroundColor','black')
else
    set(mainhandles.MemoryTextbox,'ForegroundColor','red')
end

% Check memory
if memusage>80 && ~isempty(mainhandles.data)
    
    % Show infobox on memory
    message = sprintf(['OBS: You are approaching your RAM memory limits (%i%%).\n'...
        'Memory is occupied mainly by the raw images which are not needed after traces have been calculated.\n\n'...
        'TIPS for handling RAM problems:\n\n'...
        '  1) Clear the raw image data from RAM of loaded files when intensity traces have been calculated (molecules are not deleted).\n'...
        '      This is done from the ''Performance->Memory'' menu or using the buttons next to the files listbox.\n'...
        '      The raw image data can be reloaded at any time later should it be needed.\n\n'...
        '  2) Load a few movies at a time and then use step 1 before loading more movies.\n\n'...
        '  3) Get more RAM. 16 Gb or more is recommended.\n\n'...
        'A program restart is recommended only in extreme situations.'],memusage);
    mainhandles = myguidebox(mainhandles,'RAM tips',message,'memory',1,'http://isms.au.dk/documentation/memory-management/');
end
