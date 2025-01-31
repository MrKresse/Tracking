%pre-condition: Steps A-C were run before.
%------------------------------------------------------------------
%brief: Creates the default xy_schw layout with 15 columns from the
%       detection, 2nd linking iteration and subpixel detection data. 
%       Saves it as 'name_of_movie'.tracks_v2_sub.'dist_cutoff'.dat.mat.
%------------------------------------------------------------------
%param: base_str: String name of movie.
%       path_processed: String path to the analysis results.
%------------------------------------------------------------------
%returns: nothing.
    linking_dir = dir(strcat(path_processed,base_str,'.tracks_v2.*'));
    %loop over different dist_cutoffs
    for i = 1:length(linking_dir)
        file_name = linking_dir(i).name;
        %Use regular expression to extract the dist_cutoff
        pattern = 'tracks_v2\.(\d+)\.dat\.mat';
        number = regexp(file_name, pattern, 'tokens');
        dist_cutoff = str2double(number{1}{1});
        %load all arrays
        load(strcat(path_processed,file_name),'-mat','data');
        linking_data =  data(:,2:5);
        load(strcat(path_processed,base_str,'.tracks_raw.dat.mat'),'-mat','data');
        detection_data = data(:,1:5);
        load(strcat(path_processed,base_str,'.tracks_v2_sub.dat.mat'),'-mat','data');
        subpixel_data = data(:,2:5);
        
        file_str=strcat(path_processed,base_str,'.tracks_v2_sub.',num2str(dist_cutoff),'.dat.mat');
        data=[detection_data linking_data subpixel_data zeros(size(detection_data, 1), 2)];
        save(file_str,'data','-mat')
        disp(strcat('Concatenated arrays',file_str))
    end

