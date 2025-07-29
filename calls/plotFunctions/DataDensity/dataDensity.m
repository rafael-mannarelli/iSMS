function [ dmap ] = dataDensity( x, y, width, height, limits, fudge )
%DATADENSITY Get a data density image of data 
%   x, y - two vectors of equal length giving scatterplot x, y co-ords
%   width, height - dimensions of the data density plot, in pixels
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
%   fudge - the amount of smear, defaults to size of pixel diagonal
%
% By Malcolm McLean
%
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

    if(nargin == 4)
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    deltax = (limits(2) - limits(1)) / width;
    deltay = (limits(4) - limits(3)) / height;
    if(nargin < 6)
        fudge = sqrt(deltax^2 + deltay^2);
    end
    dmap = zeros(height, width);
    
    progressbar('Calculating densities...')
    run =1;
    total = length(0:height-1)*length(0:width-1)*length(1:length(x));
    for ii = 0: height - 1
        yi = limits(3) + ii * deltay + deltay/2;
        for jj = 0 : width - 1
            xi = limits(1) + jj * deltax + deltax/2;
            dd = 0;
            for kk = 1: length(x)
                dist2 = (x(kk) - xi)^2 + (y(kk) - yi)^2;
                dd = dd + 1 / ( dist2 + fudge); 

                progressbar(run/total)
                run = run+1;

            end
            dmap(ii+1,jj+1) = dd;
        end
    end
    progressbar(1)
            

end

