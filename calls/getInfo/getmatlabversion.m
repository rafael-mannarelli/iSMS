function matlabVersion = getmatlabversion
% Returns the current release version of MATLAB: 
%
%   Input:
%    none
%  
%   Output:
%    version    - double 8.3 for R2014a, 8.4 for R2014b, ...

% Get version info
matlabVersion = ver( 'MATLAB' );

% Return release number
matlabVersion = str2num(matlabVersion.Version);
