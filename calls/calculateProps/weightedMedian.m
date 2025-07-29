function wMed = weightedMedian(D,W)
% Function for calculating the weighted median 
%
%    Input:
%     D      - matrix of observed values
%     W      - matrix of weights, W = ( w_ij )
% 
%    Output:   
%     wMed   - weighted median                   
%

% --- Copyrights (C) ---
%
% This file is adapted for:
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

if nargin ~= 2
    error('weightedMedian:wrongNumberOfArguments', ...
      'Wrong number of arguments.');
end

if size(D) ~= size(W)
    error('weightedMedian:wrongMatrixDimension', ...
      'The dimensions of the input-matrices must match.');
end

% normalize the weights, such that: sum ( w_ij ) = 1
% (sum of all weights equal to one)

WSum = sum(W(:));
W = W / WSum;

% (line by line) transformation of the input-matrices to line-vectors
d = reshape(D',1,[]);   
w = reshape(W',1,[]);  

% sort the vectors
A = [d' w'];
ASort = sortrows(A,1);

dSort = ASort(:,1)';
wSort = ASort(:,2)';

sumVec = [];    % vector for cumulative sums of the weights
for i = 1:length(wSort)
    sumVec(i) = sum(wSort(1:i));
end

wMed = [];      
j = 0;         

while isempty(wMed)
    j = j + 1;
    if sumVec(j) >= 0.5
        wMed = dSort(j);    % value of the weighted median
    end
end


% final test to exclude errors in calculation
if ( sum(wSort(1:j-1)) > 0.5 ) & ( sum(wSort(j+1:length(wSort))) > 0.5 )
     error('weightedMedian:unknownError', ...
      'The weighted median could not be calculated.');
end