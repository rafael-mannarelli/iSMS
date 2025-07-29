function [imageData, back] = importSpecializedFormat(filepath)
% Importing movies using specialized file readers
%
%    Input:
%     filepath    - path+filename
%
%    Output:
%     imageData   - image
%     back        - background image, if any
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
back = [];

% try
    if strcmpi(filepath(end-2:end),'sif')
        
        [temp, back] = sifread(filepath);
        imageData = temp.imageData;
        if ~isempty(back) && myIsField(back,'imageData')
            back = back.imageData;
        end
        
    elseif strcmpi(filepath(end-2:end),'spe')
        
        movObj = SpeReader(filepath); % User tag set to videofile
        imageData = read(movObj); % Read in all video frames
        imageData = fliplr(imageData); % Our spe data are inverted compared to sif
        
    elseif strcmpi(filepath(end-3:end),'fits') || strcmpi(filepath(end-2:end),'fts')
        
        imageData = fitsread(filepath);
        
    else
        mymsgbox('Format no recognized')
        return
        
    end
    
    if isempty(imageData)
        return
    end
    
%     % Set frames as 4th dimension
%     if size(imageData,3)~=1 && size(imageData,3)~=3
%         imageData = permute(imageData,[1 2 4 3]);
%     end
    
    % Set data type
%     if max(imageData(:))<=255
%         imageData = uint8(imageData);
%         
%     elseif max(imageData(:))<=65535
%         imageData = uint16(imageData);
%     end
% end
