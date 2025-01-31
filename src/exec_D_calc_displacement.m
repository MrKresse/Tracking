function exec_D_calc_displacement(path_processed,base_str,dist_cutoff)
    %pre-condition: exec_B_link_events_NN_v4, exec_C_subpix_det_Gauss_v2,
    %               merge_arrays, exec_D_merge_tracks_v2 were called. 
    %brief:         Calculates the mean squared displacements of tracks in consecutive
    %               frames, saves as
    %               *base_str*.displacement.dat.mat
    %param:         path_processed: string, path to analysis results
    %               base_str:       string, movie name.
    %               dist_cutoff:    int, maximum distance to particles
    %                               still get linked just for naming here.
    %returns:       nothing.
    file_str=strcat(path_processed,base_str,'.tracks_v2.',num2str(dist_cutoff),'.dat.mat');
    tmp=load(file_str,'-mat');
    xy_schw=tmp.data;
    file_str=strcat(path_processed,base_str,'.tracks_v2_sub.dat.mat');
    tmp=load(file_str,'-mat');
    xy_subpix =  tmp.data;
    num_trajectories = max(xy_schw(:,2));
    md_array = [];

    %loop over trajectories
    for i=1:num_trajectories
        %extract trajectory
        iarr=xy_schw(:,2)==i;
        tmp_xy_schw=xy_subpix(iarr,:);
        %calculate based on subpixel resolution
        if(length(tmp_xy_schw)>10)
            %calculate mean sq displacements of one trajectory
            mean_displacement = mean( diff(tmp_xy_schw(:,2)).^2 + diff(tmp_xy_schw(:,3)).^2);
            md_array= [md_array mean_displacement];
        end
    end
    file_str=strcat(path_processed,base_str,'displacement','.dat.mat');
    data=md_array ;
    save(file_str,'data','-mat')
end
