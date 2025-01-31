function save_data(table_handle, param_names)
%brief: UI Function for the main livescript. Loads the data input in the
%       interactive table to the workspace.
%param: table_handle: Pointer to the interactive table.
%       param_names: Cell with the names of the parameters used for format.
%returns: nothing
    data = table_handle.Data;
    fluo_cutoff_array = cell2mat(data(:, strcmp(param_names, 'fluo_cutoff')))';
    del_array = cell2mat(data(:, strcmp(param_names, 'del')))';
    xstart_array = cell2mat(data(:, strcmp(param_names, 'xstart')))';
    xend_array = cell2mat(data(:, strcmp(param_names, 'xend')))';
    ystart_array = cell2mat(data(:, strcmp(param_names, 'ystart')))';
    yend_array = cell2mat(data(:, strcmp(param_names, 'yend')))';
    dt_array = cell2mat(data(:, strcmp(param_names, 'dt')))';
    pix_size_array = cell2mat(data(:, strcmp(param_names, 'pix_size')))';

    assignin('base', 'fluo_cutoff_array', fluo_cutoff_array);
    assignin('base', 'del_array', del_array);
    assignin('base', 'xstart_array', xstart_array);
    assignin('base', 'xend_array', xend_array);
    assignin('base', 'ystart_array', ystart_array);
    assignin('base', 'yend_array', yend_array);
    assignin('base', 'dt_array', dt_array);
    assignin('base', 'pix_size_array', pix_size_array);
    
    disp('Data saved to workspace as arrays');
end