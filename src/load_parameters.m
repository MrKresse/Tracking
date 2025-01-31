function load_parameters(path_processed)
%brief: Loads the parameters of the last execution of the detection or
%linking step into the workspace.
%--------------------------------------------------------------------------
%param: path_processed: string path to the analysis result.
%--------------------------------------------------------------------------
%returns: nothing.
    file_name = 'parameter_table.csv';
    full_path = fullfile(path_processed, file_name);
    if exist(full_path,'file')
        % Read the table from the CSV file
        parameter_table = readtable(full_path);
        
        % Extract each column into specific arrays
        base_str_array = string(parameter_table.base_str');
        fluo_cutoff_array = parameter_table.fluo_cutoff'; 
        del_array = parameter_table.del';   
        xstart_array = parameter_table.xstart';
        xend_array = parameter_table.xend';
        ystart_array = parameter_table.ystart';
        yend_array = parameter_table.yend';
        dt_array = parameter_table.dt';
        pix_size_array = parameter_table.pix_size';
          % Check if the dist_cutoff column exists before trying to extract it
        if ismember('dist_cutoff', parameter_table.Properties.VariableNames)
            dist_cutoff_array = parameter_table.dist_cutoff';
            assignin('base', 'dist_cutoff_array', dist_cutoff_array);
        else
            disp('Using the defined dist_cutoff. (parameter_table has no dist_cutoff yet).')
        end
    
        assignin('base', 'base_str_array', base_str_array);
        assignin('base', 'fluo_cutoff_array', fluo_cutoff_array);
        assignin('base', 'del_array', del_array);
        assignin('base', 'xstart_array', xstart_array);
        assignin('base', 'xend_array', xend_array);
        assignin('base', 'ystart_array', ystart_array);
        assignin('base', 'yend_array', yend_array);
        assignin('base', 'dt_array', dt_array);
        assignin('base', 'pix_size_array', pix_size_array);
    else
        disp('No parameter_table.csv in path_processed. Run detect_local_max first.')
    end
end

