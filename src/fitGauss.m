%brief:   Approximates a local minimum of expfun (local minimum of sse)
%param:   xarr:        int [pixel] width of box around particle.
%         yarr:        int [pixel] height of box around partilce
%         F0:          2D-array float [a.U.] intensity values in box.
%         start_point: initial guesses for params of expfun.
%returns: est:         estimation of local min value.
%         model:       fit function.
%         exitFlag:    logical about convergence argument see fminsearch 
%                      documentation.

function [est, model, exitflag]=fitGauss(xarr,yarr,F0,start_point)
    
    %searches for a local min of expfun
    model=@expfun;
    [est, fval, exitflag]=fminsearch(model,start_point,optimset('TolX',1e-8));
    
    %brief:   Calculates the sum of square errors (sse) between a fit
    %         function and the data.
    %param:   Ffit:        float Intensity of maximum of fit-function.
    %         psffit:      float radius of fit-function.
    %         x0:          float x-coord of maximum of fit-function
    %         y0:          float y-coord of maximum of fit-function
    %returns: sse:         float sum of square errors between
    %                      fit-function vales and data.
    %         FittedCurve: 2D array [pixels] function values of fit
    %                      function on (xarr,yarr) grid.
    function [sse,FittedCurve]=expfun(params)
        Ffit=params(1);
        psffit=params(2);
        x0=params(3);
        y0=params(4);
        
        [xarr_tmp,yarr_tmp]=ndgrid(xarr,yarr);
        
        FittedCurve=Ffit*exp(-2*((xarr_tmp-x0).*(xarr_tmp-x0)+(yarr_tmp-y0).*(yarr_tmp-y0))./power(psffit,2));

        ErrorVector=F0-FittedCurve;
        sse=sum(sum(ErrorVector.*ErrorVector));
    end
end