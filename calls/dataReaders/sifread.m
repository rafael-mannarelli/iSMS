function [data,back,ref,comment]=sifread(file)
%Read Andor SIF multi-channel image file.
%
%Synopsis:
%
%  [data,back,ref]=sifread(file)
%     Read the image data, background and reference from file.
%     Return the image data, background and reference in named
%     structures as follows:
%
%  .temperature            CCD temperature [°C]
%  .exposureTime           Exposure time [s]
%  .cycleTime              Time per full image take [s]
%  .accumulateCycles       Number of accumulation cycles
%  .accumulateCycleTime    Time per accumulated image [s]
%  .stackCycleTime         Interval in image series [s]
%  .pixelReadoutTime       Time per pixel readout [s]
%  .detectorType           CCD type
%  .detectorSize           Number of read CCD pixels [x,y]
%  .fileName               Original file name
%  .shutterTime            Time to open/close the shutter [s]
%  .frameAxis              Axis unit of CCD frame
%  .dataType               Type of image data
%  .imageAxis              Axis unit of image
%  .imageArea              Image limits [x1,y1,first image;
%                                        x2,y2,last image]
%  .frameArea              Frame limits [x1,y1;x2,y2]
%  .frameBins              Binned pixels [x,y]
%  .timeStamp              Time stamp in image series
%  .imageData              Image data (x,y,t)

%Note:
%
%  The file format was reverse engineered by identifying known
%  information within the corresponding file. There are still
%  non-identified regions left over but the current summary is
%  available on request.
%

%        Marcel Leutenegger © November 2006
%

% --- Copyrights (C) ---
%
% This file was adapted for of:
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

f = fopen(file,'r');
if f < 0
    error('Could not open the file.');
end
if ~isequal(fgetl(f),'Andor Technology Multi-Channel File')
    fclose(f);
    error('Not an Andor SIF image file.');
end
skipLines(f,1);

[data,next] = readSection(f);

if nargout > 1 && next == 1
    [back,next] = readSection(f);
    if nargout > 2 && next == 1
        ref = back;
        back = readSection(f);
    else
        ref = struct([]);
    end
else
    back = struct([]);
    ref = back;
end
fclose(f);

function [info,next] = readSection(f)
%Read a file section.
%
% f      File handle
% info   Section data
% next   Flags if another section is available
%
info = struct(...
    'temperature', [],...
    'exposureTime', [],...
    'cycleTime', [],...
    'accumulateCycles', [],...
    'accumulateCycleTime', [],...
    'stackCycleTime', [],...
    'pixelReadoutTime', [],...
    'gainDAC', [],...
    'softwareVersion', [],...
    'detectorType', [],...
    'detectorSize', [],...
    'fileName', '',...
    'shutterTime', [],...
    'frameAxis', [],...
    'dataType', [],...
    'imageAxis', [],...
    'imageArea', [],...
    'frameArea', [],...
    'frameBins', [],...
    'numberOfFrames', [],...
    'resolution', [],...
    'pixelPerFrame', [],...
    'timeStamps', [],...
    'imageData',[],...
    'parameter', []);

o = fscanf(f,'%d',6);
if length(o) >= 6
    info.temperature = o(6);
end
skipBytes(f,10);
o = fscanf(f,'%f',5);
if length(o) >= 5
    info.exposureTime = o(2);
    info.cycleTime = o(3);
    info.accumulateCycles = o(5);
    info.accumulateCycleTime = o(4);
end
skipBytes(f,2);
o = fscanf(f,'%f',2);
if length(o) >= 2
    info.stackCycleTime = o(1);
    info.pixelReadoutTime = o(2);
end
o = fscanf(f,'%d',3);
if length(o) >= 3
    info.gainDAC = o(3);
end
fscanf(f,'%f',5);                 %
skipBytes(f,4);                   % 
o = fscanf(f,'%f',29);              %  
if length(o) >= 29
    info.softwareVersion = o(26:29)'; % Added by Asger to get software version.
end
skipLines(f,1);
info.detectorType = readLine(f);
info.detectorSize = fscanf(f,'%d',[1 2]);
info.fileName = readString(f);
skipLines(f,3);
skipBytes(f,14);
info.shutterTime = fscanf(f,'%f',[1 2]);
% Change by ACK

%    This may need tweaking if the format is changed again.
%    The location of the file position must be a the beginning
%    of the line right before the text line that contains the frame axis.
%    See comment in readString below for more info.
% if all(info.softwareVersion == [4 19 30001 0])
%     skipLines(f,23); %    Andor iXon+ -- 2011 file version.
% elseif all(info.softwareVersion == [4 21 30006 0])
%     skipLines(f,32); %    Andor iXon Ultra -- 2012 file version.
% else
%     warning('sifread:unknownsoftwareversion','Unknown software version, will assume header is similar to version 4.21.30006.0')
%     disp(['Actual software version: ', num2str(info.softwareVersion)]);
% %     skipLines(f,32);
% end

% Hack to adapt to variations in lines to skip in version 4.21.30006.0
% Sometimes 3 extra header lines is added to the data block. After skipping 
% 32 lines the additional lines all begin with a number and therfore this 
% works. If a line starting with a letter is inserted then this will fail.
thispos  = ftell(f);
fgetl(f);
nextpos  = ftell(f);
nextline = fgetl(f);
% The following line should be modified to accomodate all frame axis units!
% I cannot do this right now since I do not have the documentation.
while ~strcmp(nextline(1:(min(numel(nextline),12))),'Pixel number') % This will fail if you frame axis is not Pixel number
    thispos  = nextpos;      % and set pointer to the previous line because
    nextpos  = ftell(f);     % this is needed by readString, see below.
    nextline = fgetl(f);
end
fseek(f,thispos,-1);

% continue reading header at the right position.
info.frameAxis=readString(f);
info.dataType=readString(f);
info.imageAxis=readString(f);

% Change by ACK
% changed first number from 65538 to 65541
o = fscanf(f,'65541 %d %d %d %d %d %d %d %d 65538 %d %d %d %d %d %d',14);

info.imageArea = [o(1) o(4) o(6);o(3) o(2) o(5)];
info.frameArea = [o(9) o(12);o(11) o(10)];
info.frameBins = [o(14) o(13)];
s = (1 + diff(info.frameArea))./info.frameBins;
z = 1 + diff(info.imageArea(5:6));
if prod(s) ~= o(8) || o(8)*z ~= o(7)
    fclose(f);
    error('Inconsistent image header.');
end

% Changes by Ulf Kleissinger
info.numberOfFrames = z;
info.resolution = s;
info.pixelPerFrame = prod(s);
skipLines(f,1);
info.timeStamps = fscanf(f,'%d\n', info.numberOfFrames);
%

% Change by ACK
% Remove line containing one zero before the data matrix.
% Have not testet if this works generally.
skipLines(f,1);
%
npol    = 2; % this must be updated if the ROI definitions are changed below.

% read image data and convert it to a rank 3 tensor with size s(1)*s(2)*z
info.imageData = uint16(reshape(fread(f,prod(s)*z,'single=>single'),[s z])); % This hardcodes 16 bit files into the program. Will fail for 32 bit files.
o = readString(f);           % Need to do this to access the next flag below. This will result in inconsistancies!
if numel(o)
    fprintf('%s\n',o);      % ???
end
next = fscanf(f,'%d',1);

function o=readString(f)
%Read a character string.
%
% f      File handle
% o      String
%
% The character count in the next text line is stored at the end of the
% previous line.
n=fscanf(f,'%d',1);
if isempty(n) || n < 0 || isequal(fgetl(f),-1)
    disp(num2str(n));
    sprintf('Could not read string at position %d',ftell(f));
    fclose(f);    
    error('Inconsistent string.');
end
% for iChar = 1:n
%     c = fread(f, 1, 'uint8=>char');
%     while c
% end
o=fread(f,[1 n],'uint8=>char');

function o=readLine(f)
%Read a line.
%
% f      File handle
% o      Read line
%
o=fgetl(f);
if isequal(o,-1)
    fclose(f);
    error('Inconsistent image header.');
end
o=deblank(o);

function skipBytes(f,N)
%Skip bytes.
%
% f      File handle
% N      Number of bytes to skip
%
[~,n] = fread(f,N,'uint8');
if n < N
    fclose(f);
    error('Inconsistent image header.');
end

function skipLines(f,N)
%Skip lines.
%
% f      File handle
% N      Number of lines to skip
%
for n=1:N
    if isequal(fgetl(f),-1)
        fclose(f);
        error('Inconsistent image header.');
    end
end
