function show_detection_ui(path_processed, path_incoming, base_str)
%brief: 
    % Load pixel detection data
    file_str_pixel = fullfile(path_processed, strcat(base_str, '.tracks_raw.dat.mat'));
    tmp_pixel = load(file_str_pixel, '-mat');
    xy_schw = tmp_pixel.data;

    % Load subpixel detection data
    file_str_subpixel = fullfile(path_processed, strcat(base_str, '.tracks_v2_sub.dat.mat'));
    is_subpixel = exist(file_str_subpixel);
    if(is_subpixel)
        tmp_subpixel = load(file_str_subpixel, '-mat');
        zer = zeros(length(xy_schw), 3);
        xy_schw = [xy_schw zer tmp_subpixel.data(:, 2:3)];
    end

    img_meta = imfinfo(fullfile(path_incoming, base_str));
    numFrames = length(img_meta);

    % Display number of frames
    disp(['Number of frames: ', num2str(numFrames)]);

    % Create a UI figure with a slider
    fig = uifigure('Name', 'Video with Detections');
    ax = uiaxes(fig, 'Position', [50, 100, 600, 400]);
    slider = uislider(fig, 'Position', [100, 50, 500, 3], 'Limits', [1 numFrames], 'Value', 1);
    slider.MajorTicks = 1:10:numFrames;  % Adjust based on the number of frames

    % Function to update the frame based on the slider position
    function updateFrame(~, event)
        frameNum = round(event.Value);
        disp(['Displaying frame: ', num2str(frameNum)]);
        iarr = find(xy_schw(:, 2) == frameNum);
        img_frame = imread(fullfile(path_incoming, base_str), frameNum);
        blue_marker_pos = [xy_schw(iarr, 3), xy_schw(iarr, 4)];    % Pixel detection (blue)
        img_frame = insertMarker(img_frame, blue_marker_pos, 'o', 'Color', 'blue', 'Size', 5);
        if(is_subpixel)
            red_marker_pos = [xy_schw(iarr, 10), xy_schw(iarr, 11)];  % Subpixel detection (red)
            red_marker_pos = red_marker_pos(~any(isnan(red_marker_pos), 2), :);
            img_frame = insertMarker(img_frame, red_marker_pos, '+', 'Color', 'red', 'Size', 5);
        end

        imshow(uint8(img_frame), 'Parent', ax);
      
    end

    % Set the callback for the slider
    slider.ValueChangedFcn = @updateFrame;

    % Initialize with the first frame
    updateFrame([], struct('Value', 1));
end
