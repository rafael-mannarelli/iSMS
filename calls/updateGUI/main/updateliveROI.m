function updateliveROI(p)  
% Runs when the live-ROI position is changed. p = [xmin ymin width height]
% (position of the live-ROI within the D/A ROI image)
%
%      Input:
%       p     - position ROI
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

handles = guidata(getappdata(0,'mainhandle')); % Get handles structure like this because this is an automatic function handle signed by MATLAB, not by the GUI
file = get(handles.FilesListbox,'Value');
if (isempty(handles.data)) || (isempty(handles.liveROIhandle))
    try delete(handles.liveROIhandle),  end
    return
end

% Check raw data
if isempty(handles.data(file).DD_ROImovie)
    mymsgbox('Raw movie data is missing. Reload from the memory menu and try again.')
    return
end

p = round(p); % Position of the live ROI-ellipse handle [xmin ymin width height]

%% Cut movies from the new ROI position

% ROI data (sent by updateliveROIhandle)
DD_ROImovie = handles.data(file).DD_ROImovie; % All D-ROI D-exc frames
AD_ROImovie = handles.data(file).AD_ROImovie; % All A-ROI D-exc frames

% Cut out rectangular movies within the live ROI-ellipse position
DD_movie = DD_ROImovie(p(1):sum(p([1 3]))-1, p(2):sum(p([2 4]))-1,:);
AD_movie = AD_ROImovie(p(1):sum(p([1 3]))-1, p(2):sum(p([2 4]))-1,:);

%% Integrated intensity traces within live ROI

DD_trace = zeros(size(DD_movie,3),1); % Summed donor intensity (green emission channel) in donor excitation frames (green excitation)
AD_trace = zeros(size(AD_movie,3),1); % Summed acceptor intensity (red emission channel) in donor excitation frames (green excitation)
for i = 1:length(DD_trace)
    % D intensity D exc.
    temp = DD_movie(:,:,i);
    b = [temp(1,:) temp(end,:) temp(:,1)' temp(:,end)'];
%     DD_trace(i) = sum(temp(:))-median(b)*numel(temp);
    DD_trace(i) = sum(temp(:))-sum(b)/length(b)*numel(temp);
    
    % A intensity D exc.
    temp = AD_movie(:,:,i);
%     AD_trace(i) = sum(temp(:))-median([temp(1,:) temp(end,:) temp(:,1)' temp(:,end)'])*numel(temp);
    b = [temp(1,:) temp(end,:) temp(:,1)' temp(:,end)'];
    AD_trace(i) = sum(temp(:))-sum(b)/length(b)*numel(temp);
end

% Corrected trace
Dleakage = handles.settings.corrections.Dleakage; % Factor for donor emission leakage into acceptor emission channel
gamma = handles.settings.corrections.gamma; % Gamma factor: QY_A/QY_D * n_A/n_D
AD_traceCorr = AD_trace - Dleakage*DD_trace; % Corrected A_emission D_excitation trace (signal only due to FRET)

%% Initialize plot window

% If plot window does not already exist, create it
ok = 0;
if (isempty(handles.liveROIwindowHandle)) || (~ishandle(handles.liveROIwindowHandle))
    handles.liveROIwindowHandle = figure;
    updatemainhandles(handles)
    
    % Window properties
    updatelogo(handles.liveROIwindowHandle)
    set(handles.liveROIwindowHandle,...
        'name','Live integration region',...
        'numbertitle','off',...
        'CloseRequestFcn',{@closeLiveROI,handles.liveROIhandle})
    
    ok = 1;
end

fh = handles.liveROIwindowHandle;
figure(fh)

% Sub-plot axes
axDD1 = subplot(4,4,1:3,'Parent',fh);
axDD2 = subplot(4,4,4,'Parent',fh);
axAD1 = subplot(4,4,5:7,'Parent',fh);
axAD2 = subplot(4,4,8,'Parent',fh);
axE1 = subplot(4,4,9:11,'Parent',fh);
axE2 = subplot(4,4,13:15,'Parent',fh);
if ok
    linkaxes([axDD1 axAD1 axE1],'x')
end

% Make x-data vector
x = 1:length(DD_trace);

%% D intensity with D exc.

% Trace
plot(axDD1,x,DD_trace)
if strcmp(get(get(axDD1,'ylabel'),'string'),'')
    ylabel(axDD1,'D - D.exc')
    set(axDD1, 'XTickLabel','')
end

% Image
imagesc(mean(DD_movie,3)','Parent',axDD2)
axis(axDD2,'image')
set(axDD2,'YDir','normal')
if ~strcmp(get(axDD2,'XTickLabel'),'')
    set(axDD2, 'XTickLabel','')
    set(axDD2, 'YTickLabel','')
end

%% A intensity with D exc.

% Trace
plot(axAD1,x,AD_trace)
if strcmp(get(get(axAD1,'ylabel'),'string'),'')
    ylabel(axAD1,'A - D.exc')
    set(axAD1, 'XTickLabel','')
end

% Image
imagesc(mean(AD_movie,3)','Parent',axAD2)
axis(axAD2,'image')
set(axAD2,'YDir','normal')
if ~strcmp(get(axAD2,'XTickLabel'),'')
    set(axAD2, 'XTickLabel','')
    set(axAD2, 'YTickLabel','')
end

%% E trace

% Trace
E_trace = AD_traceCorr./(gamma*DD_trace+AD_traceCorr);
plot(axE1,x,E_trace)
if strcmp(get(get(axE1,'ylabel'),'string'),'')
    xlabel(axE1,'Time /frame')
    ylabel(axE1,'E')
end
ylim(axE1,[-0.1 1.1])

%% E histogram

% Remove outliers
E_trace(E_trace<-0.1) = [];
E_trace(E_trace>1.1) = [];

hist(axE2,E_trace(:),100)
if strcmp(get(get(axE2,'ylabel'),'string'),'')
    xlabel(axE2,'E')
    ylabel(axE2,'Frames')
end
xlim(axE2,[-0.1 1.1])

%% Nested

    function closeLiveROI(hObject,event,imrectHandle)
        try delete(imrectHandle), end
        try delete(hObject), end
    end

end