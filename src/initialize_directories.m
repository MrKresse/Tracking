function initialize_directories(subdirs,selected_path,scriptDir)
    for i = 1:length(subdirs)
        subdirPath = fullfile(selected_path, subdirs{i});
        if ~exist(subdirPath, 'dir')
            mkdir(subdirPath);
            disp(['Created directory: ', subdirPath]);
        else
            disp(['Directory already exists: ', subdirPath]);
        end
    end
    % Copy .tif files and delete original after confirming copy
    tif_dir = dir(fullfile(selected_path, '*.tif'));
    for i = 1:length(tif_dir)
        base_str = tif_dir(i).name;
        src_file = fullfile(selected_path, base_str);
        dest_file = fullfile(selected_path, 'incoming', base_str);
        
        try
            copyfile(src_file, dest_file);
            if exist(dest_file, 'file') == 2
                delete(src_file);
            else
                error('File copy failed: %s', base_str);
            end
        catch ME
            fprintf('Error occurred: %s. File was not deleted: %s\n', ME.message, base_str);
        end
    end
    
    % Copy .tiff files and delete original after confirming copy
    tiff_dir = dir(fullfile(selected_path, '*.tiff'));
    for i = 1:length(tiff_dir)
        base_str = tiff_dir(i).name;
        src_file = fullfile(selected_path, base_str);
        dest_file = fullfile(selected_path, 'incoming', base_str);
        
        try
            copyfile(src_file, dest_file);
            if exist(dest_file, 'file') == 2
                delete(src_file);
            else
                error('File copy failed: %s', base_str);
            end
        catch ME
            fprintf('Error occurred: %s. File was not deleted: %s\n', ME.message, base_str);
        end
    end
    
    % Copy .nd2 files to 'raw' and delete original after confirming copy
    nd2_dir = dir(fullfile(selected_path, '*.nd2'));
    for i = 1:length(nd2_dir)
        base_str = nd2_dir(i).name;
        src_file = fullfile(selected_path, base_str);
        dest_file = fullfile(selected_path, 'raw', base_str);
        
        try
            copyfile(src_file, dest_file);
            if exist(dest_file, 'file') == 2
                delete(src_file);
            else
                error('File copy failed: %s', base_str);
            end
        catch ME
            fprintf('Error occurred: %s. File was not deleted: %s\n', ME.message, base_str);
        end
    end
    
    % Copy .m files from scriptDir/src to selected_path/src for reproducibility
    % Get the directory listing and filter out '.' and '..'
    src_dir_listing = dir(fullfile(selected_path, 'src'));
    src_dir_listing = src_dir_listing(~ismember({src_dir_listing.name}, {'.', '..'}));
    
    if isempty(src_dir_listing)
        src_dir = dir(fullfile(scriptDir, 'src', '*.m'));
        for i = 1:length(src_dir)
            base_str = src_dir(i).name;
            src_file = fullfile(scriptDir, 'src', base_str);
            dest_file = fullfile(selected_path, 'src', base_str);
            
            try
                copyfile(src_file, dest_file);
                if exist(dest_file, 'file') ~= 2
                    error('File copy failed: %s', base_str);
                end
            catch ME
                fprintf('Error occurred: %s. File was not copied: %s\n', ME.message, base_str);
            end
        end
    else
        disp("Version of source code at the selected directory will be used for reproducibility. Delete selected_path/src if you wish to use another version.");
    end
end

