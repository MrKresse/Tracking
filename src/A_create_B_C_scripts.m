function A_create_B_C_scripts(output_script,script_name)
    % Function to copy a script, replacing a specific line with a new command
    
    % Define the line to replace (the target line to be substituted)
    targetLine = 'exec_A_detect_local_max_v2(xstart, xend, ystart, yend, fluo_cutoff, del, base_str, "./incoming/", "./processed/", Ndim, xdim, ydim);';
    create_script_line_B = 'A_create_B_C_scripts("./AB_main.m","exec_B_link_events_LAP_v2(""./processed/"")", base_str, dist_cutoff)';
    create_script_line_C = 'A_create_B_C_scripts("./AC_main.m", "exec_C_subpix_det_Gauss_v2(xstart, xend, ystart, yend, del, base_str, ""./incoming/"", ""./processed/"", xdim, ydim)")';
    % Open the input and output files
    fid_in = fopen("AA_main.m", 'r');
    fid_out = fopen(output_script, 'w');
    
    % Check if files opened correctly
    if fid_in == -1
        error('Could not open input script file.');
    end
    if fid_out == -1
        fclose(fid_in);
        error('Could not open output script file.');
    end
    
    % Read each line and write it to the new file with substitution
    while ~feof(fid_in)
        line = fgetl(fid_in);
        
        % Check if the line matches the target line
        if strcmp(line, targetLine)
            % Replace target line with script_name
            fprintf(fid_out, '%s\n', script_name);
        elseif strcmp(line,create_script_line_B)
            %skip
        elseif  strcmp(line,create_script_line_C)
            %skip
        else
            % Copy the original line
            fprintf(fid_out, '%s\n', line);
        end
    end
    
    % Close files
    fclose(fid_in);
    fclose(fid_out);
end