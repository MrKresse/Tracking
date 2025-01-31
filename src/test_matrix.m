clear;
% Define the particles array: [Particle ID | Frame number | X-coordinate | Y-coordinate | Track ID]
xy_schw = [
    1, 1, 10, 10, 1;  % Particle 1 in Frame 1
    2, 1, 20, 20, 2;  % Particle 2 in Frame 1
    3, 1, 30, 30, 3;  % Particle 3 in Frame 1
    4, 2, 12, 10, NaN; % Particle 4 in Frame 2
    5, 2, 22, 22, NaN; % Particle 5 in Frame 2
    6, 2, 25, 30, NaN; % Particle 6 in Frame 2 (new)
    7, 2, 35, 35, NaN  % Particle 7 in Frame 2 (new)
];

frames = unique(xy_schw(:, 2));
frame1 = xy_schw(xy_schw(:, 2) == frames(1), :);
frame2 = xy_schw(xy_schw(:, 2) == frames(2), :);

% Construct the asymmetric cost matrix for frame 1 and frame 2
dist_cutoff = 30000;
C = constructCostMatrix(frame1,frame2, dist_cutoff);

% Display the resulting cost matrix
disp(C);


[ROWSOL,COST,v,u,rMat] = lapjv(C);
disp(rMat);
