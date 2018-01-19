function closeEnvO(EnvO)
if strcmpi(questdlg('Close this system?'),'yes'),
    delete(EnvO.EnvFig);
    delete(EnvO.EnvTTBo.ParentFigure);
    delete(EnvO);
end
end