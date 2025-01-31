% clean up localization correction
% low track count may lead to NaN in the displacement, fixed here by setting 0 displacement

file_str=strcat('./processed/',base_str,'.tracks_v2_sub_int.',num2str(dist_cutoff),'.dat.mat');
if exist(file_str,'file')==0
    file_str=strcat('./processed/',base_str,'.tracks_v2_merged.',num2str(dist_cutoff),'.dat.mat');
    if exist(file_str,'file')==0
        file_str=strcat('./processed/',base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
    end
end
tmp=load(file_str,'-mat');
xy_schw=tmp.data;

xy_schw(:,14:15)=xy_schw(:,10:11);
tmp=sqrt(power(xy_schw(:,3)-xy_schw(:,10),2)+power(xy_schw(:,4)-xy_schw(:,11),2));
iarr=find(tmp>1);
%xy_schw(iarr,10:11)=xy_schw(iarr,3:4);
xy_schw(iarr,10:11)=NaN;

shiftx_all=[];
shifty_all=[];

for iN=2:max(xy_schw(:,2))
    iarr=find(xy_schw(:,2)==iN);
    
    Dx=[];
    Dy=[];
    
    for iP=1:length(iarr)
        iarr_P=find(and(xy_schw(:,6)==xy_schw(iarr(iP),6),xy_schw(:,2)==iN-1));
        if length(iarr_P)==1
            Dx=[Dx xy_schw(iarr(iP),10)-xy_schw(iarr_P,10)];
            Dy=[Dy xy_schw(iarr(iP),11)-xy_schw(iarr_P,11)];
        end
    end
    
    Dx=Dx(isnan(Dx)==0);
    Dy=Dy(isnan(Dy)==0);
    
    if length(Dx)==0
        Dx=0;
        Dy=0;
    end
    
    shiftx_all=[shiftx_all; median(Dx) std(Dx) length(Dx)];
    shifty_all=[shifty_all; median(Dy) std(Dy) length(Dy)];
end

shiftx_cul=[0];
shifty_cul=[0];

for iN=2:max(xy_schw(:,2))
    shiftx_cul=[shiftx_cul; shiftx_cul(end)+shiftx_all(iN-1,1)];
    shifty_cul=[shifty_cul; shifty_cul(end)+shifty_all(iN-1,1)];
    xy_schw(xy_schw(:,2)==iN,10)=xy_schw(xy_schw(:,2)==iN,14)-shiftx_cul(end);
    xy_schw(xy_schw(:,2)==iN,11)=xy_schw(xy_schw(:,2)==iN,15)-shifty_cul(end);
end

file_str=strcat('./processed/',base_str,'.tracks_v2_sub_drift.',num2str(dist_cutoff),'.dat.mat');
data=xy_schw;
save(file_str,'data','-mat')

file_str=strcat('./processed/',base_str,'.',num2str(dist_cutoff),'.drift.dat.mat');
data=[shiftx_cul shifty_cul];
save(file_str,'data','-mat')

file_str=strcat('./processed/',base_str,'.',num2str(dist_cutoff),'.drift_all.dat.mat');
data=[shiftx_all shifty_all];
save(file_str,'data','-mat')