function exec_C_subpix_det_Gauss_v2(xstart, xend, ystart, yend, ...
                                    del, base_str, ...
                                    path_incoming, path_processed, xdim, ydim)
%pre-condition: exec_A_detect_local_max_v2 was called or array matching
%               xy_schw scheme is in /processed/ .
%--------------------------------------------------------------------------
%brief:         Calls fit_gauss on first 1000 particles to estimate initial
%               guess for fit parameters. Then calls fit gauss with refined
%               values on remaining particles. Saves sub-pix x coord., 
%               sub-pix y coord, peak intensity, psf radius to  
%               $Name_of_movie.tracks_v2_sub.xxx.dat.mat. 
%--------------------------------------------------------------------------
%param:         xstart, xend, ystart, yend: int [pixel] part of image to 
%                                           be analysed
%               del: int [pixel] size of box in which local maxima get detected
%               base_str: string name of movie
%               path_incoming: string path to preprocessed movie
%               path_processed: string path to where data should be saved
%               xdim, ydim: int [pixel] dimensions of the movie.
%--------------------------------------------------------------------------
% returns:      nothing.
%--------------------------------------------------------------------------
    validateattributes(xstart, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'xstart', 1);
    validateattributes(xend, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'xend', 1);
    validateattributes(ystart, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'ystart', 1);
    validateattributes(yend, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'yend', 1);
    validateattributes(del, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'del', 1);
    
% determine psf_size
%display('determine psf_size');
    psf_size=del;
    
    file_str=strcat(path_processed,base_str,'.tracks_raw.dat.mat');
    tmp=load(file_str,'-mat');
    xy_schw=tmp.data;
    xy_schw(:,7:15)=0;
    
    frame_load=0;
    %loop over particles of first 1000 frames for better inital guess of psf. 
    for iN1=1:min([1000 size(xy_schw,1)])
        frame_act=xy_schw(iN1,2);
        x0_raw=xy_schw(iN1,3);
        y0_raw=xy_schw(iN1,4);
        F0_raw=xy_schw(iN1,5);
        
        %convert imagedata to linear array
        if frame_load~=frame_act
            tmp=imread(strcat(path_incoming,base_str),frame_act);
            tmp=reshape(double(tmp)',xdim,ydim);
            tmp_back=tmp(xstart:xend,ystart:yend);
            tmp_background=median(reshape(tmp_back,1,prod(size(tmp_back))));
            tmp=tmp-tmp_background;
            frame_load=frame_act;
        end
    
        %Create box around local maximum according to del, start and end param
        xarr=(x0_raw-del:x0_raw+del);
        xarr=xarr(xarr>=xstart);
        xarr=xarr(xarr<=xend);
        yarr=(y0_raw-del:y0_raw+del);
        yarr=yarr(yarr>=ystart);
        yarr=yarr(yarr<=yend);
    
        %Fit first 1000 particles.
        F0=tmp(xarr,yarr);
        [fittedparam, model, exitflag]=fitGauss(xarr,yarr,F0,[F0_raw-tmp_background psf_size x0_raw y0_raw]);
        
        %regression converged
        if exitflag==1
            Ffit=fittedparam(1);
            psffit=fittedparam(2);
            x0=fittedparam(3);
            y0=fittedparam(4);
    
            xy_schw(iN1,10:13)=[x0 y0 Ffit psffit];
        else
            xy_schw(iN1,10:15)=NaN;
        end
    end
    
    tmp=xy_schw(:,13);
    tmp=tmp(tmp>0);
    tmp=tmp(tmp~=psf_size);
    psf_size=median(tmp);
    display(strcat('psf_size=',num2str(psf_size),' pixels'));
    
    % subpixel detection
    file_str=strcat(path_processed,base_str,'.tracks_v2_sub.dat.mat');
    if exist(file_str)==0
        file_str=strcat(path_processed,base_str,'.tracks_raw.dat.mat');
        tmp=load(file_str,'-mat');
        xy_schw=tmp.data;
        xy_schw(:,7:15)=0;
        iN1start=1;
    else
        %extract particles with fluorescense intensity zero
        tmp=load(file_str,'-mat');
        xy_schw=tmp.data;
        tmp=xy_schw(xy_schw(:,4)==0,1);
        if length(tmp)==0
            return
        else
            iN1start=min(tmp);
        end
    end
    
    frame_load=0;
    
    %subpixel detection of all particles starting with first particle where
    %Fluo intensity was evaluated to zero POSSIBLE BIAS OF FIRST 1000 PARTICLES
    for iN1=iN1start:length(xy_schw)
        frame_act=xy_schw(iN1,2);
        x0_raw=xy_schw(iN1,3);
        y0_raw=xy_schw(iN1,4);
        F0_raw=xy_schw(iN1,5);
        
        if frame_load~=frame_act
            tmp=imread(strcat(path_incoming,base_str),frame_act);
            tmp=reshape(double(tmp)',xdim,ydim);
            tmp_back=tmp(xstart:xend,ystart:yend);
            tmp_background=median(reshape(tmp_back,1,prod(size(tmp_back))));
            tmp=tmp-tmp_background;
            frame_load=frame_act;
        end
        
        %Create box around local maximum according to del, start and end param
        xarr=(x0_raw-del:x0_raw+del);
        %xarr=xarr(xarr>=xstart);
        %xarr=xarr(xarr<=xend);
        yarr=(y0_raw-del:y0_raw+del);
        %yarr=yarr(yarr>=ystart);
        %yarr=yarr(yarr<=yend);
        F0=tmp(xarr,yarr);
        [fittedparam, model, exitflag]=fitGauss(xarr,yarr,F0,[F0_raw-tmp_background psf_size x0_raw y0_raw]);
        
        %regression converged
        if exitflag==1
            Ffit=fittedparam(1);
            psffit=fittedparam(2);
            x0=fittedparam(3);
            y0=fittedparam(4);
            
            xy_schw(iN1,10:13)=[x0 y0 Ffit psffit];%!!!!!!!!!!
            if mod(iN1,1000)==1
                display(strcat('subpix detected: ',num2str(iN1),', x0=',num2str(x0),', x0_raw=',num2str(x0_raw),', y0=',num2str(y0),', y0_raw=',num2str(y0_raw)));
                %pause(0.1);
            end
        else
            xy_schw(iN1,10:15)=NaN;
        end
        
        if mod(iN1,10000)==0
            display('writing');
            file_str=strcat(path_processed,base_str,'.tracks_v2_sub.dat.mat');
            data=xy_schw(:,[1,10,11,12,13]);
            save(file_str,'data','-mat')
        end
    end
    
    file_str=strcat(path_processed,base_str,'.tracks_v2_sub.dat.mat');
    data=xy_schw(:,[1,10,11,12,13]);
    save(file_str,'data','-mat')
end