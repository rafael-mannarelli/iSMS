function imageData = importBioformat(filepath)
% Importing files using bfopen (OME reader). The bioformats reader is
% developed by the open microscopy team
%
%    Input:
%     filepath    - path+filename
%
%    Output:
%     imageData   - image
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

imageData = [];
% colmap = [];

data = bfopen(filepath);

imageData = cat(3,data{1,1}{:,1});

if isempty(imageData)
    return
end

% % Set frames as 4th dimension
% if size(imageData,3)~=1 && size(imageData,3)~=3
%     imageData = permute(imageData,[1 2 4 3]);
% end
% 
% % Set data type
% if max(imageData(:))<=255
%     if ~strcmpi(class(imageData),'uint8')
%         imageData = uint8(imageData);
%     end
% elseif max(imageData(:))<=65535
%     if ~strcmpi(class(imageData),'uint16')
%         imageData = uint16(imageData);
%     end
% end
