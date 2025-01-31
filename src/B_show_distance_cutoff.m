function B_show_distance_cutoff(path_processed,max_dist_cutoff)
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
    dir_cont=dir(strcat(path_processed,'*.30000.dat.mat'));
    figure
    
    for iF=1:length(dir_cont)
        base_str=dir_cont(iF).name;
    
        file_str=strcat(path_processed,base_str);
        tmp=load(file_str,'-mat');
        xy_schw=tmp.data;
        
        if max(xy_schw(:,4))>0
            % for matrices that have been imported from other SPT implement.
            iarr=find(and(xy_schw(:,3)<max_dist_cutoff,xy_schw(:,4)>0));
        else
            iarr=find(xy_schw(:,3)<max_dist_cutoff);
        end
        
        [b,a]=hist(xy_schw(iarr,3),200);
        figure
        plot(a,log(b),'.')
        
        display(strcat(base_str,'-',num2str(length(xy_schw)/max(xy_schw(:,2)))))
    end
end