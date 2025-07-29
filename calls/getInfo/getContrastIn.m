function in = getContrastIn(c,L)
% c   - contrast values
% L   - limits

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

% Normalized contrast values
in = (c-L(1))/diff(L);

% Correct interval
in(in<0) = 0;
in(in>1) = 1;

% Correct for equal lower and upper value
if in(1)>=in(2)
    in(2) = in(1)+1;
end

end
