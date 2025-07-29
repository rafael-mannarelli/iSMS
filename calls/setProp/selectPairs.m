function selectPairs(mainhandles, fpwHandles, selectedPairs)
% Selects 'selectedPairs' [file pair;...] in the FRET-pair window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     fpwHandles    - handles structure of the FRET-pair window
%     selectedPairs - [file pair;...]
%

% Get pairs listed
listedPairs = getPairs(mainhandles.figure1,'listed',[],fpwHandles.figure1);

% Find where the selected pairs are
idx = find( ismember(listedPairs,selectedPairs,'rows','legacy') );

% Set new selection
set(fpwHandles.PairListbox, 'Value',idx)
