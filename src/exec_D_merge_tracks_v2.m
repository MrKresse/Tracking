%pre-condition: exec_A_detect_local_max, exec_B_link_events_NN_v4 was
%               called.
%brief:         Merge tracks where particles end in coordinates close to
%               starting coordinates of other tracks, seperated by few
%               frames. 
%param:         dist_cutoff_merge: int [pixel] maximum distance of end and
%                                  starting point of different tracks to be
%                                  considered one track.
%               N_cutoff_merge:    int [#] maximum amount of frames between
%                                  tracks to be considered one track.
%returns:       nothing.


if exist('dist_cutoff_merge','var')==0
    dist_cutoff_merge=dist_cutoff;
end
if exist('N_cutoff_merge','var')==0
    N_cutoff_merge=5;
end

file_str=strcat(path_processed,base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
%     file_str_no_sub=strcat(path_processed,base_str,'.tracks_v2.',num2str(dist_cutoff),'.dat.mat');
% end
tmp=load(file_str,'-mat');
xy_schw=tmp.data;

track_stat_arr=[];

%loop over tracks
for iX=1:max(xy_schw(:,6))
    iarr=find(xy_schw(:,6)==iX);
    
    %extract N, x, y for longer tracks CONSIDER UNIQUE()
    if length(iarr)>3
        track_stat_arr=[track_stat_arr; iX xy_schw(iarr(1),2) xy_schw(iarr(end),2) (xy_schw(iarr(1),3)) (xy_schw(iarr(end),3)) (xy_schw(iarr(1),4)) (xy_schw(iarr(end),4))];
    end
end

%loop over extracted tracks
for iX=1:size(track_stat_arr,1)
    %calculate sq displacement of start of current track and end of other
    %tracks and frame "distance" of those tracks
    tmp=[track_stat_arr(:,1) power(track_stat_arr(iX,7)-track_stat_arr(:,6),2)+power(track_stat_arr(iX,5)-track_stat_arr(:,4),2) track_stat_arr(:,2)-track_stat_arr(iX,3)];
    %extract tracks with sq displacement < dist_cutoff and frame distance < N_cutoff
    tmp=tmp(and(and(tmp(:,3)>0,tmp(:,2)<dist_cutoff_merge),tmp(:,3)<=N_cutoff_merge),:);
    if size(tmp,1)>0
        %sort ascending by track displacement
        [yi,ii]=sort(tmp(:,2));
        %extract all tracks with shortest displacement
        iarr_tmp=find(xy_schw(:,6)==tmp(ii(1),1));
        %merge tracks
        if size(iarr_tmp)>0
            display(strcat('merging: (',num2str(track_stat_arr(iX,5)),',',num2str(track_stat_arr(iX,7)),',',num2str(track_stat_arr(iX,3)),',',num2str(track_stat_arr(iX,1)),')=(',num2str((xy_schw(iarr_tmp(1),3))),',',num2str((xy_schw(iarr_tmp(1),4))),',',num2str(xy_schw(iarr_tmp(1),2)),',',num2str(xy_schw(iarr_tmp(1),6)),')'))
            xy_schw(xy_schw(:,6)==tmp(ii(1),1),6)=track_stat_arr(iX,1);
            track_stat_arr(track_stat_arr(:,1)==tmp(ii(1),1),[1 2 4 6])=track_stat_arr(iX,[1 2 4 6]);
        end
    end
end

file_str=strcat(path_processed,base_str,'.tracks_v2_merged.',num2str(dist_cutoff),'.dat.mat');
data=xy_schw;
save(file_str,'data','-mat')
