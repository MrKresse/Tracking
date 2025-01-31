function show_distance_cutoff_xml(path_processed,max_dist_cutoff)
%pre-condition: exec_A_detect_local_max_v2 and exec_B_link_events_v4 were
%               run.
%--------------------------------------------------------------------------
%brief:         Creates and displays a semilogarithmic plot of squared 
%               displacements based on the first linking iteration.
%--------------------------------------------------------------------------
%param:         path_processed: string path to linking data.
%               max_dist_cutoff: int [pixel] largest square displacement
%               shown.

% limit histogram
    dir_cont=dir(strcat(path_processed,'*tif_log_sub_tracks.xml.mat'));
    figure
    for iF=1:length(dir_cont)
        displacement = [];
        base_str=dir_cont(iF).name;
    
        file_str=strcat(path_processed,base_str);
        tmp=load(file_str,'-mat');
        xy_schw=tmp.data;
        num_trajectories = max(xy_schw(:,6));
        for i=1:num_trajectories
            %extract trajectory
            iarr=xy_schw(:,6)==i;
            tmp_xy_schw=xy_schw(iarr,:);
            %sort by frame
            sort_tmp = sortrows(tmp_xy_schw,2);
            %calculate sq displacements of one trajectory
            displacement = [displacement; diff(sort_tmp(:,3)).^2 + diff(sort_tmp(:,4)).^2];
        end
        
        [b,a]=hist(displacement(displacement<max_dist_cutoff),200);
        figure
        plot(a,log(b),'.')
        
        display(strcat(base_str,'-',num2str(length(xy_schw)/max(xy_schw(:,2)))))
    end
end

