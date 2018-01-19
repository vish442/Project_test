function addparams(hobj,~)
strout=inputdlg('Specify additional arguments for your function that come after the required arguments (one argument per line):','Additional Parameters',2,{hobj.String});
if ~isempty(strout),    hobj.String=char(strout);    end
end