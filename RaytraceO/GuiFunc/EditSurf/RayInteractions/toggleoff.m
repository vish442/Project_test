function toggleoff(~,~,varargin)
for n=1:length(varargin)
    varargin{n}.Visible='off';
end
end