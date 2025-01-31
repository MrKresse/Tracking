%pre-condition: exec_A_detect_local_max_v2, exec_B_link_events_NN_v4,
%               exec_c_subpix_det_Gauss_v2 were called.
%brief:         Calculates median shift values for linked particles (Should
%               be zero for purely brownian). Extract all shift values
%               exceeding 2 standard deviations and corrects those with the
%               median shift. Saves results to'path_processed',base_str,'.tracks_v2_sub_drift.',num2str(dist_cutoff),'.dat.mat'
%param:         None.
%returns:       Nothing.

% clean up localization correction

file_str=strcat(path_processed,base_str,'.tracks_v2_sub_int.',num2str(dist_cutoff),'.dat.mat');
if exist(file_str,'file')==0
    file_str=strcat(path_processed,base_str,'.tracks_v2_merged.',num2str(dist_cutoff),'.dat.mat');
    if exist(file_str,'file')==0
        file_str=strcat(path_processed,base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
    end
end
tmp=load(file_str,'-mat');
xy_schw=tmp.data;

xy_schw(:,14:15)=xy_schw(:,10:11);
%calculate euclidian distance of pixel and subpixel coordinates
tmp=sqrt(power(xy_schw(:,3)-xy_schw(:,10),2)+power(xy_schw(:,4)-xy_schw(:,11),2));
%set subpixel coord to NaN for distances > 1 pixel
iarr=find(tmp>1);
%xy_schw(iarr,10:11)=xy_schw(iarr,3:4);
xy_schw(iarr,10:11)=NaN;
Ndim=max(xy_schw(:,2));

shiftx_all=[];
shifty_all=[];

%loop over tracks
for iX=1:max(xy_schw(:,6))
    iarr=find(xy_schw(:,6)==iX);
    
    if length(iarr)>Ndim-1
        %shift in x and y over consecutive Frames of track
        Dx=xy_schw(iarr(2:end),10)-xy_schw(iarr(1:end-1),10);
        Dy=xy_schw(iarr(2:end),11)-xy_schw(iarr(1:end-1),11);
        DxDy=Dx.*Dy;
        shiftx_all=[shiftx_all; xy_schw(iarr(isnan(DxDy)==0),2)+1 Dx(isnan(DxDy)==0)];
        shifty_all=[shifty_all; xy_schw(iarr(isnan(DxDy)==0),2)+1 Dy(isnan(DxDy)==0)];
    end
end

if length(shiftx_all)==0
    display('drift correction failed')
    return
end

shiftx=[];
shifty=[];
shiftx_cul=[0];
shifty_cul=[0];

%loop over frames
for iN=2:Ndim
    %extract shift values for current frame
    tmp=shiftx_all(shiftx_all(:,1)==iN,2);
    %extract shift values  values that deviate more than 
    % standard deviations from the median shift value
    mtmp=median(tmp);
    stmp=std(tmp);
    iarr=find(and(tmp>mtmp-2*stmp,tmp<mtmp+2*stmp));
    mtmp=median(tmp(iarr));
    stmp=std(tmp(iarr));
    %drift correction using the median shift 
    shiftx=[shiftx; iN mtmp length(iarr)];
    shiftx_cul=[shiftx_cul; shiftx_cul(end)+mtmp];
    xy_schw(xy_schw(:,2)==iN,10)=xy_schw(xy_schw(:,2)==iN,14)-shiftx_cul(end);
    
    tmp=shifty_all(shifty_all(:,1)==iN,2);
    mtmp=median(tmp);
    stmp=std(tmp);
    iarr=find(and(tmp>mtmp-2*stmp,tmp<mtmp+2*stmp));
    mtmp=median(tmp(iarr));
    stmp=std(tmp(iarr));
    shifty=[shifty; iN mtmp length(iarr)];
    shifty_cul=[shifty_cul; shifty_cul(end)+mtmp];
    xy_schw(xy_schw(:,2)==iN,11)=xy_schw(xy_schw(:,2)==iN,15)-shifty_cul(end);
end

file_str=strcat(path_processed,base_str,'.tracks_v2_sub_drift.',num2str(dist_cutoff),'.dat.mat');
data=xy_schw;
save(file_str,'data','-mat')

file_str=strcat(path_processed,base_str,'.',num2str(dist_cutoff),'.drift.dat.mat');
data=[shiftx_cul shifty_cul];
save(file_str,'data','-mat')