function save_dist_cutoff(table_handle, param_names)
%brief: UI Function for the main livescript. Loads the data input in the
%       interactive table to the workspace.
%param: table_handle: Pointer to the interactive table.
%       param_names: Cell with the names of the parameters used for format.
%returns: nothing
    data = table_handle.Data;
    dist_cutoff_array = cell2mat(data(:, strcmp(param_names, 'dist_cutoff')))';
    run_linking_array = cell2mat(data(:, strcmp(param_names, 'run_linking')))';
  
    assignin('base', 'dist_cutoff_array', dist_cutoff_array);
    assignin('base','run_linking_array',run_linking_array);
    disp('Data saved to workspace as arrays');
end

