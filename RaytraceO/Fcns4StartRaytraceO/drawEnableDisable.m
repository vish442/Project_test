    function drawEnableDisable(checbx_hndl,EnvO)
        if checbx_hndl.Value, EnvO.rayDrawingEnabled=true; else EnvO.rayDrawingEnabled=false; end
    end