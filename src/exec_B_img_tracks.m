% version with empty frames

min_tl=10;          % lower limit for tracklength
border=25;          % border around the explored FOV
show_subpixel=0;    % 0 = use pixel information, 1 = use sub-pixel information

%load tracks
file_str=strcat('./processed/',base_str,'.tracks_v2_merged.',num2str(dist_cutoff),'.dat.mat');
if exist(file_str,'file')==0
    file_str=strcat('./processed/',base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
    if exist(file_str,'file')==0
        file_str=strcat('./processed/',base_str,'.tracks_v2.',num2str(dist_cutoff),'.dat.mat');
    end
end
tmp=load(file_str,'-mat');
xy_schw=tmp.data;

%%calculate track-images
for iX=1:max(xy_schw(:,6))
    iarr=find(xy_schw(:,6)==iX);
    display(strcat('writing: ',num2str(iX),':',num2str(max(xy_schw(:,6)))));
    
    if length(iarr)>min_tl
        x_min=min(xy_schw(iarr,3));
        x_max=max(xy_schw(iarr,3));
        y_min=min(xy_schw(iarr,4));
        y_max=max(xy_schw(iarr,4));
        N_min=min(xy_schw(iarr,2));
        N_max=max(xy_schw(iarr,2));
        dx=x_max-x_min;
        
        if x_min>border+1
            x_min=x_min-border;
        else
            x_min=1;
        end
        if y_min>border+1
            y_min=y_min-border;
        else
            y_min=1;
        end
        if x_max<xdim-border
            x_max=x_max+border;
        else
            x_max=xdim;
        end
        if y_max<xdim-border
            y_max=y_max+border;
        else
            y_max=ydim;
        end
        
        if N_min>5+1
            N_min_e=N_min-5;
        else
            N_min_e=1;
        end
        if N_max<Ndim-5+1
            N_max_e=N_max+5;
        else
            N_max_e=Ndim;
        end
        
        track_image=0*ones(2*(x_max-x_min+1),y_max-y_min+1,N_max_e-N_min_e+1);
        
        for iXX=N_min_e:N_max_e
            tmp=imread(strcat('./incoming/',base_str),iXX);
            FCSimag=double(tmp)';
            track_image(1:x_max-x_min+1,1:y_max-y_min+1,iXX-N_min_e+1)=FCSimag(x_min:x_max,y_min:y_max);
            iarr2=find(and(xy_schw(:,6)==iX,xy_schw(:,2)==iXX));
            if length(iarr2)==1
                if show_subpixel==1
                    tmpX=round(xy_schw(iarr2,10));
                    tmpY=round(xy_schw(iarr2,11));
                else
                    tmpX=xy_schw(iarr2,3);
                    tmpY=xy_schw(iarr2,4);
                end if
                if and(and(tmpX>=x_min,tmpX<=x_max),and(tmpY>=y_min,tmpY<=y_max))
                    track_image(x_max-x_min+1+tmpX-x_min+1,tmpY-y_min+1,iXX-N_min_e+1)=xy_schw(iarr2,5);
                end
            end
        end
                
        for iN=1:N_max_e-N_min_e+1
            if iN==1
                imwrite(uint16(track_image(:,:,iN))',strcat('./processed/track_v2_',base_str,'.',num2str(dist_cutoff),'_',num2str(iX),'_',num2str(xy_schw(iarr(1),2)),'_',num2str(xy_schw(iarr(end),2)),'_',num2str(dx),'.tif'),'WriteMode','overwrite');
            else
                imwrite(uint16(track_image(:,:,iN))',strcat('./processed/track_v2_',base_str,'.',num2str(dist_cutoff),'_',num2str(iX),'_',num2str(xy_schw(iarr(1),2)),'_',num2str(xy_schw(iarr(end),2)),'_',num2str(dx),'.tif'),'WriteMode','append');
            end
        end
    end
end