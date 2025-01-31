clear;

dist_cutoff=20;
base_str='20220713_POPC-PEG2k-Zan-Fc_wash-X31R18-010.nd2';
base_str='20220713_POPC-PEG2k-Zan-Fc_wash-X31R18-011.nd2';
dF=500;

iF=1;
dir_cont=dir(strcat('./processed/',base_str,'.',num2str(iF),'.*tif.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat'));
xy_schw=[];

while length(dir_cont)>0   
    file_str=strcat('./processed/',dir_cont(1).name);
    tmp=load(file_str,'-mat');
    tmp_xy_schw=tmp.data;
    
    if length(xy_schw)==0
        xy_schw=[xy_schw;tmp_xy_schw];
    else
        tmp_xy_schw(:,[1 2 6])=tmp_xy_schw(:,[1 2 6])+max(xy_schw(:,[1 2 6]));
        xy_schw=[xy_schw;tmp_xy_schw];
    end
    
    iF=iF+dF;
    dir_cont=dir(strcat('./processed/',base_str,'.',num2str(iF),'.*tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat'));
end

file_str=strcat('./processed/',base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
data=xy_schw;
save(file_str,'data','-mat')
