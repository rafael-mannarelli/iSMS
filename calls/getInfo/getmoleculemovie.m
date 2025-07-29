function [DD_molmovie, AD_molmovie, AA_molmovie] = getmoleculemovie(mainhandle,selectedPairs,imagechoice)
% Calculates the averaged molecule images of DD, AD and AA and stores them
% in the mainhandles structure
%
%     Input:
%      mainhandle    - handle to the main sms window
%      selectedPair  - [file pair] (only one molecule)
%      imagechoice   - 'DD', 'AD', 'AA', 'all'
%
%     Output:
%      DD_molmovie   - DD molecule movie
%      AD_molmovie   - ...
%      AA_molmovie   - ..
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

DD_molmovie = [];
AD_molmovie = [];
AA_molmovie = [];

if isempty(mainhandle) || ~ishandle(mainhandle)
    mainhandles = [];
    return
end

mainhandles = guidata(mainhandle);
if isempty(selectedPairs)
    return
end

if nargin<3
    imagechoice = 'all';
end

%% Calculate images

file = selectedPairs(1,1);
pair = selectedPairs(1,2);

% DD movie
if (strcmpi(imagechoice,'DD') || strcmpi(imagechoice,'all')) ...
        && ~isempty(mainhandles.data(file).DD_ROImovie)
    xrange = mainhandles.data(file).FRETpairs(pair).Dxrange;
    yrange = mainhandles.data(file).FRETpairs(pair).Dyrange;
    DD_molmovie = mainhandles.data(file).DD_ROImovie(xrange, yrange,:);
end

% AD movie
xrange = mainhandles.data(file).FRETpairs(pair).Axrange;
yrange = mainhandles.data(file).FRETpairs(pair).Ayrange;
if (strcmpi(imagechoice,'AD') || strcmpi(imagechoice,'all')) ...
        && ~isempty(mainhandles.data(file).AD_ROImovie)
    AD_molmovie = mainhandles.data(file).AD_ROImovie(xrange, yrange,:);
end

% AA movie
if mainhandles.settings.excitation.alex ...
        && (strcmpi(imagechoice,'AA') || strcmpi(imagechoice,'all')) ...
        && ~isempty(mainhandles.data(file).AA_ROImovie)
    AA_molmovie = mainhandles.data(file).AA_ROImovie(xrange, yrange,:);
end
