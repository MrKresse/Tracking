function exec_B_link_events_NN_v4(path_processed,base_str,dist_cutoff,del)
%pre-condition: exec_A_detect_particles was called before or array matching
%               the xy_schw scheme is in /processed/. 
%--------------------------------------------------------------------------
%brief:         Nearest neighbor linking starting with the pair of closest 
%               particles (usually immobile particles) removing them from 
%               the available linking possibilites (greedy algorithm). 
%               If unambigous closest, not linked particles  are linked. 
%               Else it links the particles which have the highest 
%               distance to their second closest particle iteratively. 
%               Results are saved to xy_schw.
%--------------------------------------------------------------------------
%param:         
%               path_processed: string path to where detection data can be 
%                               found and linking data should be saved.
%               base_str:       string of the current movie tracks.
%               dist_cutoff:    The highest distance in pixels squared to
%                               particles can have and still be linked.
%               del:            del: int [pixel] size of box in which local 
%                               maxima get detected ~ PSF size
%               
%--------------------------------------------------------------------------
%returns:       nothing.
    
    validateattributes(del, {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'}, mfilename, 'del', 1);
    validateattributes(dist_cutoff, {'numeric'}, {'scalar', 'nonempty', 'integer', 'nonnegative'}, mfilename, 'dist_cutoff', 1);

    file_str=strcat(path_processed,base_str,'.tracks_raw.dat.mat');
    tmp=load(file_str,'-mat');
    xy_schw=[tmp.data zeros(size(tmp.data, 1), 3)];
    
    %loop over frames 
    for iN1=2:max(xy_schw(:,2))
      %extract rows for particles that correspond to the frame iN1  
      %and have TrackID 0 
      iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
      tmp_xy_schw=xy_schw(iarr,:);
      dist_arr=[];
      
      %indices of rows for particles corresponding to the frame before iN1
      iarr=find(and(xy_schw(:,2)==iN1-1,xy_schw(:,9)==0));
      if length(iarr)>1
          %loop over particles HELPER
          for iN2=1:length(tmp_xy_schw(:,1))
              iX=tmp_xy_schw(iN2,3);
              iY=tmp_xy_schw(iN2,4);
    
              %col1: Particle ID of the particle in the frame before 
              %col2: Squared displacement to the current particle
              tmp_dist=[xy_schw(iarr,1) power(xy_schw(iarr,3)-iX,2)+power(xy_schw(iarr,4)-iY,2)];
              %sort in ascending order of squared displacement (iy)
              %ik is an index vector: tmp_dist(ik) would return the sorted array
              [iy,ik]=sort(tmp_dist(:,2));
    
              %extract flourescense intensity of the two closest previous particles
              tmp_flou=xy_schw(tmp_dist(ik(1:2),1),5);
              %%dist_array:
                %col1: Particle ID of current particle
                %col2: Intensity of current particle 
                %col3: particle ID of closest particle in frame before
                %col4: sq displacement of closest particle 
                %col5: Intensity of closest particle 
                %col6: particle ID of 2nd closest particle in frame before
                %col7: sq displacement of 2nd closest particle 
                %col8: Intensity of 2nd closest particle 
              dist_arr=[dist_arr; tmp_xy_schw(iN2,1) tmp_xy_schw(iN2,5) tmp_dist(ik(1),1) tmp_dist(ik(1),2) tmp_flou(1) tmp_dist(ik(2),1) tmp_dist(ik(2),2) tmp_flou(2)];
          end
          
          if length(dist_arr)>0
              %display(strcat('tracking: ',num2str(iN1),'_',num2str(length(dist_arr))));
              %sort dist_arr according to the sq displacement of the closest
              %particle
              [iy,ik]=sort(dist_arr(:,4));
              dist_arr=dist_arr(ik,:);
    
              %find indices of rows that match particles with a sq displacement
              %smaller than del sq (usually immobile particles) 
              iarr=find(dist_arr(:,4)<min([del.*del dist_cutoff]));
    
              %loop over particles smaller then min(del sq, cutoff)
              for iN3=1:length(iarr)
                 %check if only one particle from the frame before matches
                 %the current particle
                 iarr2=find(dist_arr(iarr,3)==dist_arr(iarr(iN3),3));
                 if length(iarr2)==1
                     %assign Track ID, sq displacement and fluorescense intensity
                     %of closest particle from previous frame
                     %to current particle (linking)
                     xy_schw(dist_arr(iarr(iN3),1),6)=xy_schw(dist_arr(iarr(iN3),3),6); %part-ID
                     xy_schw(dist_arr(iarr(iN3),1),7:8)=dist_arr(iarr(iN3),4:5);        %dist, fluores_int 
                     xy_schw(dist_arr(iarr(iN3),3),9)=1;                                %detected flag
                 end
              end
          end
      end
      %extract rows of particles of the current frame not yet linked
      iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
      tmp_xy_schw=xy_schw(iarr,:);
      dist_arr=[];
    
      %indices of particles from frame before, where the track has terminated
      iarr=find(and(xy_schw(:,2)==iN1-1,xy_schw(:,9)==0));
      if length(iarr)>1
          %loop over non linked particles of current frame HELPER
          for iN2=1:length(tmp_xy_schw(:,1))
              iX=tmp_xy_schw(iN2,3);
              iY=tmp_xy_schw(iN2,4);
              %calculate sq displacement of current particle to terminated
              %particles from frame before POSSIBLY REDUNDANT TO dist_arr
              tmp_dist=[xy_schw(iarr,1) power(xy_schw(iarr,3)-iX,2)+power(xy_schw(iarr,4)-iY,2)];
              
              %sort in ascending order of sq displacement (iy)
              %ik is an index vector: tmp_dist(ik) would return the sorted array
              [iy,ik]=sort(tmp_dist(:,2));
    
              %fluo intensity of two closest particles in previous frame
              tmp_flou=xy_schw(tmp_dist(ik(1:2),1),5);
              %see above
              dist_arr=[dist_arr; tmp_xy_schw(iN2,1) tmp_xy_schw(iN2,5) tmp_dist(ik(1),1) tmp_dist(ik(1),2) tmp_flou(1) tmp_dist(ik(2),1) tmp_dist(ik(2),2) tmp_flou(2)];
          end
          
          while length(dist_arr)>0
              %display(strcat('tracking: ',num2str(iN1),'_',num2str(length(dist_arr))));
              %sort by ascending sq displacement of closest particle
              [iy,ik]=sort(dist_arr(:,4));
              dist_arr=dist_arr(ik,:);
              %extract rows where the sq displacement is as low as 
              %the lowest sq displacement overall
              iarr=find(dist_arr(:,4)==dist_arr(1,4));
              dist_arr_tmp=dist_arr(iarr,:);
              %sort by descending sq displacement of second closest particle
              [iy,ik]=sort(dist_arr_tmp(:,7),1,'descend');
              dist_arr_tmp=dist_arr_tmp(ik,:);
              
              %check if sq displacement of closest particle, (which has the
              %highest sq displacement to its second closest particle) < cutoff
              if dist_arr_tmp(1,4)<dist_cutoff
                 %linking
                 xy_schw(dist_arr_tmp(1,1),6)=xy_schw(dist_arr_tmp(1,3),6); %part-ID
                 xy_schw(dist_arr_tmp(1,1),7:8)=dist_arr_tmp(1,4:5);        %dist, fluores_int
                 xy_schw(dist_arr_tmp(1,3),9)=1;                            %detected flag
                 
                 %find particles with highest sq displacement to closest or
                 %second closest particle
                 rep_id_arr=[];
                 rep_id_arr=find(or(dist_arr(:,3)==dist_arr_tmp(1,3),dist_arr(:,6)==dist_arr_tmp(1,3)));         %has to be extended, if > first is regarded
                 
                 %particles from frame before where the track has terminated
                 iarr=find(and(xy_schw(:,2)==iN1-1,xy_schw(:,9)==0));
                 
                 if and(length(rep_id_arr)>0,length(iarr)>1)
                     %loop over particles with highest sq disp HELPER/REDUNDANT
                     for iN3=1:length(rep_id_arr)
                         %calculate sq displacement to particles where the
                         %track terminated
                         iX=xy_schw(dist_arr(rep_id_arr(iN3),1),3);
                         iY=xy_schw(dist_arr(rep_id_arr(iN3),1),4);
                         tmp_dist=[xy_schw(iarr,1) power(xy_schw(iarr,3)-iX,2)+power(xy_schw(iarr,4)-iY,2)];
    
                         [iy,ik]=sort(tmp_dist(:,2));
            
                         tmp_flou=xy_schw(tmp_dist(ik(1:2),1),5);
                         %see above
                         dist_arr(rep_id_arr(iN3),:)=[dist_arr(rep_id_arr(iN3),1) dist_arr(rep_id_arr(iN3),2) tmp_dist(ik(1),1) tmp_dist(ik(1),2) tmp_flou(1) tmp_dist(ik(2),1) tmp_dist(ik(2),2) tmp_flou(2)];
                     end
                 else
                     %no alternatives, discard in next iteration
                     dist_arr(rep_id_arr,4)=dist_cutoff*1000;     
                 end
                 
                 %remove assigned particle (highest sq displacement to second
                 %closest)??why not directly in the linking step???
                 iarr=find(dist_arr(:,1)==dist_arr_tmp(1,1));
                 if iarr==1 
                     dist_arr=dist_arr(2:end,:);
                 %unambigous remove last 
                 elseif iarr==length(dist_arr)
                     dist_arr=dist_arr(1:end-1,:);
                 else 
                     dist_arr=dist_arr([1:iarr-1 iarr+1:end],:);
                 end
              %particle with lowest sq disp to closest doesn´t pass dist cutoff
              else
                  %link last one, if possible
                  iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
                  if length(iarr)>0
                      tmp_xy_schw=xy_schw(iarr,:);
                      dist_arr=[];
                      iarr=find(and(xy_schw(:,2)==iN1-1,xy_schw(:,9)==0));
                      if length(iarr)==1
                          for iN2=1:length(tmp_xy_schw(:,1))%HELPER/REDUNDANT
                              iX=tmp_xy_schw(iN2,3);
                              iY=tmp_xy_schw(iN2,4);
                              tmp_dist=[xy_schw(iarr,1) power(xy_schw(iarr,3)-iX,2)+power(xy_schw(iarr,4)-iY,2)];
                              [iy,ik]=sort(tmp_dist(:,2));
                              tmp_flou=xy_schw(tmp_dist(ik(1),1),5);
                              dist_arr=[dist_arr; tmp_xy_schw(iN2,1) tmp_xy_schw(iN2,5) tmp_dist(ik(1),1) tmp_dist(ik(1),2) tmp_flou(1)];
                          end
                          
                          if length(dist_arr)>0
                              [iy,ik]=sort(dist_arr(:,4));
                              dist_arr_tmp=dist_arr(ik,:);
                              if dist_arr_tmp(1,4)<dist_cutoff
                                  xy_schw(dist_arr_tmp(1,1),6)=xy_schw(dist_arr_tmp(1,3),6); %part-ID
                                  xy_schw(dist_arr_tmp(1,1),7:8)=dist_arr_tmp(1,4:5);        %dist, fluores_int
                                  xy_schw(dist_arr_tmp(1,3),9)=1;
                              end
                          end
                      end
                  end
                  
                  iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
                  xy_schw(iarr,6)=max(xy_schw(:,6))+(1:length(iarr));
                  dist_arr=[];
              end
           end      
       else
          iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
          xy_schw(iarr,6)=max(xy_schw(:,6))+(1:length(iarr));
       end   
       
       %link last one, if possible REDUNDANT/HELPER
       iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
       if length(iarr)>0
           tmp_xy_schw=xy_schw(iarr,:);
           dist_arr=[];
           iarr=find(and(xy_schw(:,2)==iN1-1,xy_schw(:,9)==0));
           if length(iarr)==1
               for iN2=1:length(tmp_xy_schw(:,1))
                   iX=tmp_xy_schw(iN2,3);
                   iY=tmp_xy_schw(iN2,4);
                   tmp_dist=[xy_schw(iarr,1) power(xy_schw(iarr,3)-iX,2)+power(xy_schw(iarr,4)-iY,2)];
                   [iy,ik]=sort(tmp_dist(:,2));
                   tmp_flou=xy_schw(tmp_dist(ik(1),1),5);
                   dist_arr=[dist_arr; tmp_xy_schw(iN2,1) tmp_xy_schw(iN2,5) tmp_dist(ik(1),1) tmp_dist(ik(1),2) tmp_flou(1)];
               end
                   
               if length(dist_arr)>0
                   [iy,ik]=sort(dist_arr(:,4));
                   dist_arr_tmp=dist_arr(ik,:);
                   if dist_arr_tmp(1,4)<dist_cutoff
                       xy_schw(dist_arr_tmp(1,1),6)=xy_schw(dist_arr_tmp(1,3),6); %part-ID
                       xy_schw(dist_arr_tmp(1,1),7:8)=dist_arr_tmp(1,4:5);        %dist, fluores_int
                       xy_schw(dist_arr_tmp(1,3),9)=1;
                   end
               end
           end
       end
       
       iarr=find(and(xy_schw(:,2)==iN1,xy_schw(:,6)==0));
       xy_schw(iarr,6)=max(xy_schw(:,6))+(1:length(iarr));
       %failsafe write tracks every 50 frames
       if mod(iN1,50)==0
          %display('writing tracks');
          file_str=strcat(path_processed,base_str,'.tracks_v2.',num2str(dist_cutoff),'.dat.mat');
          data=xy_schw(:,[1, 6, 7, 8, 9]);
          save(file_str,'data','-mat')
       end
    end
    
    file_str=strcat(path_processed,base_str,'.tracks_v2.',num2str(dist_cutoff),'.dat.mat');
    data=xy_schw(:,[1, 6, 7, 8, 9]);
    save(file_str,'data','-mat')
end
