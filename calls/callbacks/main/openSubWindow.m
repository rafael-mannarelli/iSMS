function handles = openSubWindow(handles, fcn, field)

% Bring attn
if ~isempty(handles.(field)) && ishandle(handles.(field))
    figure(handles.(field))
    return
end

handles.(field) = fcn();
updatemainhandles(handles)