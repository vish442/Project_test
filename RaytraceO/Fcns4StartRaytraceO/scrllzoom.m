    function scrllzoom(evd,ax)
        if (-evd.VerticalScrollCount/15+1>0)
            camzoom(ax,-evd.VerticalScrollCount/15+1);
        end
    end