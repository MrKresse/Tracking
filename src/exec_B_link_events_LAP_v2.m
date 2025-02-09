function exec_B_link_events_LAP_v2(path_processed, base_str, dist_cutoff)
    % exec_B_link_events_LAP_v2 links detections across consecutive frames using
    % the LAPJV algorithm.
    %
    % It loads detection data from:
    %   [path_processed, base_str, '.tracks_raw.dat.mat']
    % Expected columns in the detection file (xy_schw):
    %   [Particle ID | Frame number | X-coordinate | Y-coordinate | Intensity | Track ID]
    %
    % The output linking matrix (linkings) has 5 columns:
    %   Col1: Particle ID
    %   Col2: Track ID (propagated from frame to frame or newly assigned)
    %   Col3: Squared displacement (Δx² + Δy²) for the link
    %   Col4: (unused)
    %   Col5: Continuation flag (1 if the track continues; 0 if it terminates)
    
    %% Load detection data
    tmp = load(fullfile(path_processed, strcat(base_str, '.tracks_raw.dat.mat')));
    xy_schw = tmp.data;
    
    % Initialize linking array.
    % Copy Particle ID (col1) and initial Track ID (col6) from detections.
    linkings = zeros(size(xy_schw,1), 5);
    linkings(:,1) = xy_schw(:,1);
    linkings(:,2) = xy_schw(:,6);
    % Columns 3 and 5 (squared displacement and continuation flag) will be updated.
    
    frames = unique(xy_schw(:,2));
    
    %% Loop over consecutive frames to link detections.
    for i = 1:length(frames)-1
        % Get detections for consecutive frames.
        frame1 = xy_schw(xy_schw(:,2)==frames(i), :);
        frame2 = xy_schw(xy_schw(:,2)==frames(i+1), :);
        num_particles1 = size(frame1, 1);
        num_particles2 = size(frame2, 1);
        
        % --- Build the cost matrix ---
        % Compute the squared Euclidean distances between frame1 and frame2.
        dx = frame1(:,3) - frame2(:,3)';  % (num_particles1 x num_particles2)
        dy = frame1(:,4) - frame2(:,4)';  % (num_particles1 x num_particles2)
        squared_distances = dx.^2 + dy.^2;
        
        % Create a square cost matrix with dummy cost = dist_cutoff.
        n = max(num_particles1, num_particles2);
        % All entries are initially set to dist_cutoff.
        C = repmat(dist_cutoff, n, n);
        % Fill the top-left block with the actual squared distances.
        C(1:num_particles1, 1:num_particles2) = squared_distances;
        % --- End cost matrix construction ---
        
        % Solve the assignment problem with LAPJV.
        [rowsol, ~, ~, ~, ~] = lapjv(C);
        
        assigned_cols = [];
        % Process assignments for detections in frame1 (rows 1:num_particles1).
        for r = 1:num_particles1
            assignedCol = rowsol(r);
            % Check that the assigned column is a real detection (not a dummy)
            % and that the cost is below the threshold.
            if assignedCol <= num_particles2 && C(r, assignedCol) < dist_cutoff
                % Valid assignment.
                pid1 = frame1(r, 1);
                pid2 = frame2(assignedCol, 1);
                % Propagate track ID from frame1 to frame2.
                linkings(linkings(:,1)==pid2, 2) = linkings(linkings(:,1)==pid1, 2);
                % Mark that the track from frame1 continues (flag = 1).
                linkings(linkings(:,1)==pid1, 5) = 1;
                % Store the squared displacement.
                linkings(linkings(:,1)==pid2, 3) = C(r, assignedCol);
                assigned_cols = [assigned_cols; assignedCol];
            else
                % No valid link for this frame1 detection: mark track termination.
                linkings(linkings(:,1)==frame1(r, 1), 5) = 0;
            end
        end
        
        % For each detection in frame2 that was not assigned, treat it as a new track.
        for c = 1:num_particles2
            if ~ismember(c, assigned_cols)
                newTrackId = max(linkings(:,2)) + 1;
                linkings(linkings(:,1)==frame2(c, 1), 2) = newTrackId;
            end
        end
    end
    
    %% Save the linking results.
    file_str = fullfile(path_processed, strcat(base_str, '.tracks_v2.', num2str(dist_cutoff), '.dat.mat'));
    data = linkings;
    save(file_str, 'data', '-mat');
end
