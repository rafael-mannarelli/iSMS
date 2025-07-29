function I = avgSmoothFilter(I,nf)
% Mean trace filter
%
%    Input:
%     I    - input trace
%     nf   - number of frames for averaging
%
%    Output:
%     I    - smoothed trace
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

nb = round((nf-1)/2); % Number of frames on either side
if nb<=0
    return
end

%% Smooth

temp = I;
L = length(I);
for k = 1:L
    if k < 1+nb
        
        % The beginning of the trace
        if k+nb<=L
            I(k) = sum(temp(1:k+nb))/nf;
        else
            I(k) = sum(temp(1:end))/nf;
        end
        
    elseif k > L-nb
        
        % The end of the trace
        if k-nb<1
            I(k) = sum(temp(1:end))/nf;
        else
            I(k) = sum(temp(k-nb:end))/nf;
        end
        
    else
        % The middle of the trace
        I(k) = sum(temp(k-nb:k+nb))/nf;
    end
end
