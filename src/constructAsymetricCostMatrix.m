function C = constructAsymetricCostMatrix(frame1,frame2)    
    % Fill in the cost matrix with Euclidean distances
    dx = frame1(:, 3) - frame2(:, 3)'; % Difference in X-coordinates (broadcasting)
    dy = frame1(:, 4) - frame2(:, 4)'; % Difference in Y-coordinates (broadcasting)
    
    % Calculate the squared distance
    C = dx.^2 + dy.^2;
end