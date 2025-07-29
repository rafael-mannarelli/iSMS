function [Dcolor, Acolor, Ecolor] = getColors(mainhandles)

if mainhandles.settings.view.colorblind
%     Dcolor = [0 0 1];%'blue';
%     Acolor = [1 1 0];%'yellow';
%     Ecolor = [1 1 1];%'white';
    Dcolor = [0 1 0];%'green';
    Acolor = [1 0 1];%'magenta';
    Ecolor = [1 1 1];%'white';
else
    Dcolor = [0 1 0];%'green';
    Acolor = [1 0 0];%'red';
    Ecolor = [1 1 0];%'yellow';
end
