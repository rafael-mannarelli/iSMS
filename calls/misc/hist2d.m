%function mHist = hist2d ([vY, vX], vYEdge, vXEdge)
%2 Dimensional Histogram
%Counts number of points in the bins defined by vYEdge, vXEdge.
%size(vX) == size(vY) == [n,1]
%size(mHist) == [length(vYEdge) -1, length(vXEdge) -1]
%
%EXAMPLE
%   mYX = rand(100,2);
%   vXEdge = linspace(0,1,10);
%   vYEdge = linspace(0,1,20);
%   mHist2d = hist2d(mYX,vYEdge,vXEdge);
%
%   nXBins = length(vXEdge);
%   nYBins = length(vYEdge);
%   vXLabel = 0.5*(vXEdge(1:(nXBins-1))+vXEdge(2:nXBins));
%   vYLabel = 0.5*(vYEdge(1:(nYBins-1))+vYEdge(2:nYBins));
%   pcolor(vXLabel, vYLabel,mHist2d); colorbar
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

function mHist = hist2d (mX, vYEdge, vXEdge)
nCol = size(mX, 2);
if nCol < 2
    error ('mX has less than two columns')
end

nRow = length (vYEdge)-1;
nCol = length (vXEdge)-1;

vRow = mX(:,1);
vCol = mX(:,2);

mHist = zeros(nRow,nCol);

for iRow = 1:nRow
    rRowLB = vYEdge(iRow);
    rRowUB = vYEdge(iRow+1);
    
    vColFound = vCol((vRow > rRowLB) & (vRow <= rRowUB));
    
    if (~isempty(vColFound))
        
        
        vFound = histc (vColFound, vXEdge);
        
        nFound = (length(vFound)-1);
        
        if (nFound ~= nCol)
            disp([nFound nCol])
            error ('hist2d error: Size Error')
        end
        
        [nRowFound, nColFound] = size (vFound);
        
        nRowFound = nRowFound - 1;
        nColFound = nColFound - 1;
        
        if nRowFound == nCol
            mHist(iRow, :)= vFound(1:nFound)';
        elseif nColFound == nCol
            mHist(iRow, :)= vFound(1:nFound);
        else
            error ('hist2d error: Size Error')
        end
    end
    
end


