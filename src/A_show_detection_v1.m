clear;
file_str='./processed/sim_mov.multiplicator_3.0180.0001.180.tif.tracks_v2_sub.30000.dat.mat';
base_str = 'sim_mov.multiplicator_3.0180.0001.180.tif';
tmp=load(file_str,'-mat');
xy_schw=tmp.data;

iarr=find(xy_schw(:,2)==1);
xy_schw(iarr,6)=xy_schw(iarr,1);

% file_str='./incoming/standard_sim_tirf_image.0020.0001.20.tif.y-coord.raw.mat';
% tmp=load(file_str,'-mat');
% true_y=tmp.tmpdata/(210e-9);
% 
% file_str='./incoming/standard_sim_tirf_image.0020.0001.20.tif.x-coord.raw.mat';
% tmp=load(file_str,'-mat');
% true_x=tmp.tmpdata/(210e-9);

% for iX=1:max(xy_schw(:,2))
for iX=1:100
    iarr=find(xy_schw(:,2)==iX);
    tmp=imread(strcat('./incoming/',base_str),iX);
    img_meta=imfinfo(strcat('./incoming/',base_str));
    xdim=img_meta(1).Width;
    ydim=img_meta(1).Height;
    tmp=reshape(double(tmp)',xdim,ydim);
%     tmp(tmp>fluo_cutoff)=fluo_cutoff+1;
%     tmp(tmp<=fluo_cutoff)=0;
    imshow(uint8(tmp)');
    hold on
    plot(xy_schw(iarr,10),xy_schw(iarr,11),'ro');
    plot(xy_schw(iarr,3),xy_schw(iarr,4),'bo');
    %plot(true_x(:,iX),true_y(:,iX),'go');
    hold off
    set(gcf,'WindowState','maximize')
    Image = getframe(gca);
                if iX==1
                    imwrite(Image.cdata,strcat('./processed/', base_str, 'detection.tif'),'WriteMode','overwrite')
            else
                    imwrite(Image.cdata,strcat('./processed/', base_str, 'detection.tif'),'WriteMode','append');
                end 
end