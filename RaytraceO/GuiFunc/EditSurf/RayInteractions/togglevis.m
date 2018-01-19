%toggles varargin visibility solely based on the value of hobj
function togglevis(hobj,~,varargin)
poss={'off','on'};
state=poss{hobj.Value+1};
for n=1:length(varargin)
    varargin{n}.Visible=state;
end
end