function exec_B_link_events_LAP_v2(path_processed, base_str, dist_cutoff)
%pre-condition: exec_A_detect_particles was called before or array matching
%               the xy_schw scheme is in /processed/. 
%--------------------------------------------------------------------------
%brief:         LAPJV linking of particles. See also lapjv.m version 3.0 by Yi Cao 
%               at Cranfield University on 10th April 2013.
%--------------------------------------------------------------------------
%param:         
%               path_processed: string path to where detection data can be 
%                               found and linking data should be saved.
%               base_str:       string of the current movie tracks.
%               dist_cutoff:    The highest distance in pixels squared to
%                               particles can have and still be linked.              
%--------------------------------------------------------------------------
%returns:       nothing.
    % Load data
    tmp = load(fullfile(path_processed, strcat(base_str, '.tracks_raw.dat.mat')));
    xy_schw = tmp.data;
    
    % Initialize result array with particle ID and frame number (Track ID initially set as frame number)
    linkings = zeros(size(xy_schw, 1), 5);
    linkings(:,1) = xy_schw(:,1);
    linkings(:,2) = xy_schw(:,6);
    
    frames = unique(xy_schw(:, 2));
    
    % Loop over frames
    for i = 1:length(frames)-1
        % Separate xy_schw into two consecutive frames
        frame1 = xy_schw(xy_schw(:, 2) == frames(i), :);
        frame2 = xy_schw(xy_schw(:, 2) == frames(i+1), :);
        
        % Build cost matrix
        C = constructCostMatrix(frame1, frame2,dist_cutoff);
        % C = constructAsymetricCostMatrix(frame1, frame2);
        % Solve LAP
        %ROWSOL indexes each row to the matching column
        %!!! THE MATRIX IS SQUARE OPTIMIZE BY SETTING MAX OVER FRAME NO IF
        [ROWSOL, ~, ~, ~, ~] = lapjv(C);
        %frame1 indexes to frame 2
        if length(frame1) >= length(frame2)
            for j = 1:length(frame2)
                if ROWSOL(j) <= length(frame1)
                    % Update Track ID in frame2 using ROWSOL
                    linkings(linkings(:, 1) == frame2(j, 1), 2) = linkings(linkings(:, 1) == frame1(ROWSOL(j), 1), 2);
                    % Track continues
                    linkings(linkings(:, 1) == frame1(ROWSOL(j), 1), 5) = 1;
                    % Fill squared displacement with cost matrix
                    linkings(linkings(:, 1) == frame2(j, 1), 3) = C(ROWSOL(j), j);
                else
                    % Handle emerging particles
                    linkings(linkings(:, 1) == frame2(j, 1), 2) = max(linkings(:, 2)) + 1;
                end
            end
            % Handle disappearing particles in frame1
            for k = 1:length(frame1)
                if ~ismember(k, ROWSOL(1:length(frame1)))
                % if ~ismember(k, ROWSOL)
                    linkings(linkings(:, 1) == frame1(k, 1), 5) = 0;
                end
            end
        else
            for j = 1:length(frame1)
                if ROWSOL(j) <= length(frame2)
                    % Update Track ID in frame2 using ROWSOL
                    linkings(linkings(:, 1) == frame2(ROWSOL(j), 1), 2) = linkings(linkings(:, 1) == frame1(j, 1), 2);
                    % Track continues
                    linkings(linkings(:, 1) == frame1(j, 1), 5) = 1;
                    % Fill squared displacement with cost matrix
                    linkings(linkings(:, 1) == frame2(ROWSOL(j), 1), 3) = C(j, ROWSOL(j));
                else
                    % Handle emerging particles
                    linkings(linkings(:, 1) == frame2(j, 1), 2) = max(linkings(:, 2)) + 1;
                end
            end
            % Handle disappearing particles in frame1
            for k = 1:length(frame1)
                if ~ismember(k, ROWSOL(1:length(frame2)))
                % if ~ismember(k, ROWSOL)
                    linkings(linkings(:, 1) == frame1(k, 1), 5) = 0;
                end
            end
        end
    end
    
    % Save the results
    file_str = strcat(path_processed, base_str, '.tracks_v2.', num2str(dist_cutoff), '.dat.mat');
    data = linkings;
    save(file_str, 'data', '-mat');
end
