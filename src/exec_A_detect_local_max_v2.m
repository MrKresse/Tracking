function exec_A_detect_local_max_v2(xstart, xend, ystart, yend, ...
                                    fluo_cutoff, del, ...
                                    base_str, path_incoming, path_processed, ... 
                                    Ndim, xdim, ydim)%Ndim,xdim,ydim,basestr could be inferred from incoming
%pre-condition: Movie with preprocessed contrast in .tif format is in
%               path_incoming .
%------------------------------------------------------------------------------------
%brief:         Detects all local maxima within a (2*del+1) square as
%               potential particles. Saves particle ID, frame number, x-y
%               coord, intensity, track ID (first frame) of local
%               maxima to $Name_of_movie.tracks_raw.dat.mat.
%------------------------------------------------------------------------------------
%param:         xstart, xend, ystart, yend: int [pixel] part of image to be analysed
%               fluo_cutoff: int [a.U.] lowest fluorescense intensity to be detected
%               del: int [pixel] size of box in which local maxima get detected
%               base_str: string name of movie
%               path_incoming: string path to preprocessed movie
%               path_processed: string path to where data should be saved
%               Ndim, xdim, ydim: int [pixel] dimensions of the movie.
%------------------------------------------------------------------------------------
%returns:       nothing.
    validateattributes(xstart, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'xstart', 1);
    validateattributes(xend, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'xend', 1);
    validateattributes(ystart, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'ystart', 1);
    validateattributes(yend, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'yend', 1);
    validateattributes(fluo_cutoff, {'numeric'}, {'scalar', 'nonempty', 'nonnegative'}, mfilename, 'fluo_cutoff', 1);
    validateattributes(del, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'del', 1);
    
    xy_schw=[];
    xy_schw_count=0;
    
    [xc,yc]=ndgrid(xstart+del:xend-del,ystart+del:yend-del);
    xc_lin=reshape(xc,1,numel(xc));
    yc_lin=reshape(yc,1,numel(xc));
    
    %loop over frames
    for iN=1:Ndim
        %display(strcat('detecting: ',num2str(iN),', length: ',num2str(length(xy_schw))));
        %convert imagedata to 2D array
        tmp=imread(strcat(path_incoming,base_str),iN);
        tmp=reshape(double(tmp)',xdim,ydim);
        %convert 2D array to linear array
        tmp_lin=reshape(tmp(xstart+del:xend-del,ystart+del:yend-del),1,numel(xc));
        %find indices of pixels with values > fluo cutoff (possible particles)
        iarr_events=find(tmp_lin>fluo_cutoff);
        tmp_xy_schw=[];
        
        %loop over possible particles
        for iP=1:length(iarr_events)
            %acces the linear array at the index of the particle 
            iX=xc_lin(iarr_events(iP));
            iY=yc_lin(iarr_events(iP));
            %check if pixel at iX,iY is a local max in the rectangle around iX,iY 
            %defined by the del paramater 
            if tmp(iX,iY)==max(max(tmp(iX-del:iX+del,iY-del:iY+del)))
                if ~isempty(tmp_xy_schw)
                    %calculate euclidian distance between current local
                    %maxima and previously detected local maxima
                    tmp_dist=sqrt(power(tmp_xy_schw(:,3)-iX,2)+power(tmp_xy_schw(:,4)-iY,2));
                    iarr=find(tmp_dist<del, 1);
                    
                    %distance to all previosly detected particles is > del
                    if isempty(iarr)
                        tmp_xy_schw=[tmp_xy_schw;xy_schw_count+1 iN iX iY tmp(iX,iY) 0];
                        xy_schw_count=xy_schw_count+1;
                    end
                else
                    tmp_xy_schw=[tmp_xy_schw;xy_schw_count+1 iN iX iY tmp(iX,iY) 0];
                    xy_schw_count=xy_schw_count+1;
                end
            end
        end
        
        xy_schw=[xy_schw;tmp_xy_schw];
    end
    
    %assign track ID
    iarr=find(xy_schw(:,2)==1);
    xy_schw(iarr,6)=xy_schw(iarr,1);

    file_str=strcat(path_processed,base_str,'.tracks_raw.dat.mat');
    data=xy_schw;
    save(file_str,'data','-mat')

end