function show_detection(path_processed, path_incoming, base_str)
%pre-condition: detect_local_max was called before.
%brief: loads movie from incoming/base_str adds blue markers for pixel
%       detection and red markers for subpixel detection. Saves as tif to
%       path_processed.
%param: path_processed: string, Path to analysis results.
%       path_incoming:  string, Path to movies.
%       base_str:       string, movie name.
%returns: nothing.

% Load pixel detection data
    file_str_pixel = fullfile(path_processed, strcat(base_str, '.tracks_raw.dat.mat'));
    tmp_pixel = load(file_str_pixel, '-mat');
    xy_schw = tmp_pixel.data;

    % Load subpixel detection data
    file_str_subpixel = fullfile(path_processed, strcat(base_str, '.tracks_v2_sub.dat.mat'));
    is_subpixel = exist(file_str_subpixel);
    if(is_subpixel)
        tmp_subpixel = load(file_str_subpixel, '-mat');
        xy_subpix = tmp_subpixel.data(:, 2:3);
        zer = zeros(length(xy_schw), 3);
        xy_schw = [xy_schw zer tmp_subpixel.data(:, 2:3)];
    end

    % Update column 6 for those entries where column 2 equals 1
    iarr = find(xy_schw(:, 2) == 1);
    %xy_schw(iarr, 6) = xy_schw(iarr, 1);

    % Initialize output file path for the TIF file
    output_file = fullfile(path_processed, strcat(base_str, '.detection.tif'));

    % Loop over frames (in this case, the first 100 frames)
    for iX = 1:100
        % Find indices where the second column matches the current frame
        iarr = find(xy_schw(:, 2) == iX);
        
        % Read the current frame from the video
        %img_frame = video_frames(:, :, iX);  % Extract the ith frame
        % img_frame = imread(fullfile(path_incoming, base_str), iX);
        % img_frame = reshape(double(img_frame)', xdim, ydim);
        % % 
        % % Overlay pixel and subpixel detections
        % figure;  % Ensure the figure does not pop up in a new window
        % imshow(uint8(img_frame)');
        % hold on
        % plot(xy_schw(iarr, 10), xy_schw(iarr, 11), 'ro');  % Subpixel detection (red)
        % plot(xy_schw(iarr, 3), xy_schw(iarr, 4), 'bo');    % Pixel detection (blue)
        % hold off
        % 
        % % Capture the frame
        % Image = getframe(gca);
        % 
        % % Save the frame to the output TIFF file
        % if iX == 1
        %     imwrite(Image.cdata, output_file, 'WriteMode', 'overwrite');
        % else
        %     imwrite(Image.cdata, output_file, 'WriteMode', 'append');
        % end

        img_frame = imread(fullfile(path_incoming, base_str), iX);
        blue_marker_pos = [xy_schw(iarr, 3), xy_schw(iarr, 4)];% Pixel detection (blue)
        img_frame = insertMarker(img_frame, blue_marker_pos, 'o', 'Color', 'blue', 'Size', 5);
        if(is_subpixel)
            red_marker_pos = [xy_schw(iarr, 10), xy_schw(iarr, 11)];  % Subpixel detection (red)
            red_marker_pos = red_marker_pos(~any(isnan(red_marker_pos), 2), :);
            img_frame = insertMarker(img_frame, red_marker_pos, '+', 'Color', 'red', 'Size', 5);
        end

      if iX==1
          imwrite(uint8(img_frame),output_file,'WriteMode','overwrite');
      else
          imwrite(uint8(img_frame),output_file,'WriteMode','append');          
      end

    end
end
