function str = howstuffworksStr(choice)
% Returns strings that are used in more than one place in the program
%
%    Input:
%     choice    - 'bin'
%
%    Output:
%     str       - string
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

str = '';

%% Bin
if strcmpi(choice,'bin')
    
    str = sprintf(['How the open recycle bin works:\n\n'...
        '  - When the recycle bin is open binned pairs are added to a new group called ''Recycle bin''.\n'...
        '      (Note you can sort pairs according to group from the ''Sort''-menu.)\n\n'...
        '  - The pairs in the recycle bin group can be browsed and used as any other pair while the bin is open.\n\n'...
        '  - To reuse pairs from the bin move them to a different group.\n\n'...
        '  - To permanently delete pairs from the bin delete them from the pair listbox.\n\n'...
        '  - To close the bin go to the Bin menu. This removes all pairs in the ''Recycle bin'' group from the FRET-pair list.\n ']);
    
    return
end
%% Grouping
if strcmpi(choice,'grouping')
    
    str = sprintf(['How grouping works:\n\n\n'...
        'Grouping allows molecules to be grouped into subpopulations that can be analysed and plotted separately.\n\n',...
        ' - First, activate grouping in the toolbar of the FRET-pair window. '...
        'This activates the groups-listbox below the FRET-pair listbox. '...
        'By default, all molecules are initially put in the default group ''A''.\n\n',...
        ' - Then, create new groups either manually or automatically from the Grouping menu. ',...
        'There is no limit on the number of groups.\n\n',...
        ' - To add molecules to a group, select the molecules in the FRET-pair listbox and the target group in the group listbox. '...
        'Then go to ''Grouping->Put selected molecules in selected groups''. '...
        'Molecules can belong to more than group\n\n',...
        ' - FRET-pairs can be sorted according to group. '...
        'The order is determined from the group-order in the groups-listbox which can be set from the ''Grouping->Sort groups'' menu.\n']);
    
    return
end
