% clean up cascade, localization, and options

clear;
% % 
base_str='008-2022-08-02_nonCF-61_apical treatment.lif - 3h-C1.tif';
dist_cutoff=10;

% file_str=strcat('./processed/',base_str,'.tracks_v2_sub_drift.',num2str(dist_cutoff),'.dat.mat');
% file_str=strcat('./processed/',base_str,'.tracks_v2_merged.',num2str(dist_cutoff),'.dat.mat');
% file_str=strcat('./processed/',base_str,'.tracks_v2_sub_int.',num2str(dist_cutoff),'.dat.mat');
file_str=strcat('./processed/',base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
% file_str=strcat('./processed/',base_str,'.tracks_v2.',num2str(dist_cutoff),'.dat.mat');
tmp=load(file_str,'-mat');
xy_schw=tmp.data;

if size(xy_schw,2)>11
    tmp=xy_schw(1:100,15);
    tmp=tmp(isnan(tmp)==0);
    if tmp(1)==0
        % no drift correction
        tmp=sqrt(power(xy_schw(:,3)-xy_schw(:,10),2)+power(xy_schw(:,4)-xy_schw(:,11),2));
        iarr=find(tmp>4);
        xy_schw(iarr,10:11)=xy_schw(iarr,3:4);
%         xy_schw(iarr,10:11)=NaN;
    else
        % drift correction
        tmp=sqrt(power(xy_schw(:,3)-xy_schw(:,14),2)+power(xy_schw(:,4)-xy_schw(:,15),2));
        iarr=find(tmp>4);
        xy_schw(iarr,10:11)=xy_schw(iarr,3:4);
%         xy_schw(iarr,10:11)=NaN;
    end
else
    xy_schw(:,10:11)=xy_schw(:,3:4);
end

tr_length_arr=[];
maxD_arr=[];

figure
hold on

for iX=1:max(xy_schw(:,6))
    iarr=find(xy_schw(:,6)==iX);
    
    if length(iarr)>5
%     if length(iarr)>1
%         tmp=xy_schw(iarr,16);
%         tmp=tmp(isnan(tmp)==0);
%         tmpD=power(xy_schw(iarr(1:end-1),10)-xy_schw(iarr(2:end),10),2)+power(xy_schw(iarr(1:end-1),11)-xy_schw(iarr(2:end),11),2);
%         tmpD=tmpD*0.130*0.130/4/0.0604;
%         tr_length_arr=[tr_length_arr; iX length(iarr) xy_schw(iarr(1),2) median(tmp) mean(tmpD(isnan(tmpD)==0))];
%         tr_length_arr=[tr_length_arr; iX length(iarr) xy_schw(iarr(1),2) mean(tmpD(isnan(tmpD)==0))];
%         tr_length_arr=[tr_length_arr; iX xy_schw(iarr([1 end]),2)' min(xy_schw(iarr,3)) max(xy_schw(iarr,3)) min(xy_schw(iarr,4)) max(xy_schw(iarr,4)) mean(tmpD(isnan(tmpD)==0))];
%         maxD_arr=[maxD_arr; iX max(sqrt(power(abs(xy_schw(iarr,10)-median(xy_schw(iarr,10))),2)+power(abs(xy_schw(iarr,11)-median(xy_schw(iarr,11))),2))) length(iarr)];
        plot(xy_schw(iarr,10),-xy_schw(iarr,11),'-');
%         plot(xy_schw(iarr,10),'.');
%         tmp=find(isnan(xy_schw(iarr,10))==0);
%         if length(tmp)>29
%             mean(xy_schw(iarr(tmp(end-10:end)),10))-mean(xy_schw(iarr(tmp(1:10)),10))
%             tr_length_arr=[tr_length_arr mean(xy_schw(iarr(tmp(end-10:end)),10))-mean(xy_schw(iarr(tmp(1:10)),10))];
%             tr_length_arr=[tr_length_arr mean(xy_schw(iarr(tmp(end-10:end)),11))-mean(xy_schw(iarr(tmp(1:10)),11))];
%         end
%         plot(xy_schw(iarr,2),xy_schw(iarr,16),'.');
%         plot(xy_schw(iarr,2),xy_schw(iarr,13),'.');
%         pause
%         close gcf
    end
end

hist(tr_length_arr(abs(tr_length_arr)<1),15)

% figure
% tmp=[];for iX=1:2000;iarr=find(and(tr_length_arr(:,2)<=iX,tr_length_arr(:,3)>=iX));tmp=[tmp length(iarr)];end
% plot(tmp,'.')
% median(tmp)/(1016*1016*0.13e-6*0.13e-6*1.2e-6)/6e23/1000

% figure
% tmp=1.38e-23*300./3/pi/1e-3./tr_length_arr(tr_length_arr(:,3)-tr_length_arr(:,2)>8,8)/1e-12/1.5;
% hist(tmp(tmp<0.5e-6),40)

% figure
% [b,a]=hist(tr_length_arr(:,2),50);
% bar(a,b/sum(b)*100)

% tmp_on=[];for iP=min(tr_length_arr(:,3)):max(tr_length_arr(:,3));tmptmp=find(tr_length_arr(:,3)==iP);tmp_on=[tmp_on length(tmptmp)];end
% tmp_on(2,:)=tmp_on(1,:);
% for iP=1:length(tmp_on);tmp_on(2,iP)=sum(tmp_on(1,1:iP));end
% 
% figure
% plot(tmp_on(2,:),'.')
% 
% pp=polyfit((0:150)/4,tmp_on(2,end-150:end)-tmp_on(2,end-150),1)