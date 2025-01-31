function C = constructCostMatrix(frame1,frame2,dist_cutoff)
    % INPUT:
    % xy_schw - An array with columns:
    %    [Particle ID | Frame number | X-coordinate | Y-coordinate | Track ID]
    
    % Number of particles in each frame
    num_particles1 = size(frame1, 1);
    num_particles2 = size(frame2, 1);
    
    % Initialize the cost matrix with large values (infinity)
    C = zeros(num_particles1 + num_particles2, num_particles1 + num_particles2);
    
    % Fill in the cost matrix with Euclidean distances
    dx = frame1(:, 3) - frame2(:, 3)'; % Difference in X-coordinates (broadcasting)
    dy = frame1(:, 4) - frame2(:, 4)'; % Difference in Y-coordinates (broadcasting)
    
    % Calculate the squared distance
    squared_distances = dx.^2 + dy.^2;
    
    % Assign to cost matrix
    C(1:num_particles1, 1:num_particles2) = squared_distances;
    
    % Fill in the asymmetric costs for disappearing particles
    for i = 1:num_particles1
        C(i, num_particles2+1:end) = dist_cutoff;
    end
    
    % Fill in the asymmetric costs for appearing particles
    for j = 1:num_particles2
        C(num_particles1+1:end, j) = dist_cutoff;
    end
end

