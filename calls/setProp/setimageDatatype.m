function imageout = setimageDatatype(imagein,imgclass)
% Sets the data class of imagein to imgclass
%
%    Input:
%     imagein    - input image to be converted
%     imgclass   - 'int16', 'uint16', 'uint8', 'single', 'double'
%
%    Output:
%     imageout   - output image
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

% Default
imageout = imagein;

if strcmpi(imgclass,'int16') && size(imageData,3)==1
    % RGBs can't be int 16
    imageout = im2int16(imagein);

elseif strcmpi(imgclass,'uint16')

    imageout = im2uint16(imagein);

elseif strcmpi(imgclass,'uint8')

    imageout = im2uint8(imagein);

elseif strcmpi(imgclass,'single')
    
    imageout = im2single(imagein);
end
