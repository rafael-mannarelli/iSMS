function mainhandles = storeGeoTransformAfterCut(mainhandles,file,frames)
% Creates an transform id when cutting raw movie data
%
%    Input:
%     mainhandles  - handles structure of the main window
%     file         - file to store
%
%    Output:
%     mainhandles  - ..

% Id
if size(mainhandles.data(file).filepath,1)>1
    tstr = 'cuttimeMerged';
else
    tstr = 'cuttime';
end

% Create new field
geoTransform = mainhandles.data(file).geoTransformations;
if isempty(geoTransform)
    if isempty(mainhandles.data(file).filepath)
        geoTransform = cell(1,1);
    else
        geoTransform = cell(1,size(mainhandles.data(file).filepath,1));
    end
end

% Store transform
geoTransform{1,1}{end+1,1} = tstr;
geoTransform{1,1}{end,2} = frames;
mainhandles.data(file).geoTransformations = geoTransform;
