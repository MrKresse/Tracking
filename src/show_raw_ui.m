function show_raw_ui(path_incoming, base_str)
    % show_raw_ui displays raw .tif image frames with brightness/contrast adjustment.
    % Additionally, it allows you to measure the size (in pixels) of particles by
    % clicking on the displayed image (first click sets the first point and the second
    % click sets the second point, after which the distance is computed and displayed).
    %
    % INPUTS:
    %   path_incoming : folder containing the .tif file
    %   base_str      : name of the .tif file (including extension)
    %
    % Usage example:
    %   show_raw_ui('C:\data\', 'my_movie.tif');

    % Full path to the TIFF file
    full_path = fullfile(path_incoming, base_str);
    
    % Get image metadata (number of frames)
    img_meta = imfinfo(full_path);
    numFrames = numel(img_meta);
    disp(['Number of frames: ', num2str(numFrames)]);

    % Create the UI figure
    fig = uifigure('Name', 'Raw Image Viewer with Brightness/Contrast', ...
                   'Position', [100, 100, 800, 600]);

    % Create axes for displaying the image
    ax = uiaxes(fig, 'Position', [50, 150, 700, 400]);
    
    % Create a slider for frame selection (moved up)
    frameSlider = uislider(fig, ...
        'Position', [50, 120, 300, 3], ...
        'Limits', [1, numFrames], ...
        'Value', 1);
    frameSlider.MajorTicks = round(linspace(1, numFrames, 10));
    
    % Create sliders for brightness/contrast adjustment.
    brightnessMinSlider = uislider(fig, ...
        'Position', [400, 120, 300, 3], ...
        'Limits', [0, 255], ...
        'Value', 0);
    brightnessMaxSlider = uislider(fig, ...
        'Position', [400, 30, 300, 3], ...
        'Limits', [0, 255], ...
        'Value', 255);

    % Create labels for the sliders with updated positions
    uilabel(fig, 'Position', [50, 140, 100, 22], 'Text', 'Frame');
    uilabel(fig, 'Position', [400, 140, 100, 22], 'Text', 'Min Intensity');
    uilabel(fig, 'Position', [400, 50, 100, 22], 'Text', 'Max Intensity');
    
    % Create a label for measurement results
    measurementLabel = uilabel(fig, 'Position', [50, 0, 300, 22], ...
        'Text', 'Measurement: none');

    % All sliders call the same update function on change
    frameSlider.ValueChangedFcn = @(src,event) updateFrame();
    brightnessMinSlider.ValueChangedFcn = @(src,event) updateFrame();
    brightnessMaxSlider.ValueChangedFcn = @(src,event) updateFrame();

    % Variables to store measurement state
    firstClick = [];         % stores the first click coordinate for measurement
    measurementLine = [];      % handle for the drawn measurement line

    % Nested function to update the display
    function updateFrame()
        % Reset measurement state on frame update
        firstClick = [];
        if ~isempty(measurementLine) && isvalid(measurementLine)
            delete(measurementLine);
            measurementLine = [];
        end
        measurementLabel.Text = 'Measurement: none';
        
        % Ensure the max slider value is always at least as high as the min slider value.
        if brightnessMaxSlider.Value < brightnessMinSlider.Value
            brightnessMaxSlider.Value = brightnessMinSlider.Value+1;
        end

        % Get current frame number (round to nearest integer)
        frameNum = round(frameSlider.Value);
        % Read the selected frame from the TIFF file
        img_frame = imread(full_path, frameNum);
        
        % Get current brightness/contrast slider values
        lowVal = brightnessMinSlider.Value;
        highVal = brightnessMaxSlider.Value;
        
        % Display the frame with the specified display range.
        if lowVal == highVal
            whiteImg = uint8(255 * ones(size(img_frame)));
            hImage = imshow(whiteImg, 'Parent', ax);
        else
            hImage = imshow(img_frame, [lowVal, highVal], 'Parent', ax);
        end
        
        % Enable clicking on the image by setting its ButtonDownFcn.
        % (Also set the axes ButtonDownFcn so clicks on any blank area trigger measurement.)
        set(hImage, 'ButtonDownFcn', @imageClickCallback, 'PickableParts','all');
        ax.ButtonDownFcn = @imageClickCallback;
    end

    % Nested function to handle image clicks for measurement.
    function imageClickCallback(~, ~)
        % Get click coordinates (in data units) from the axes current point.
        clickPoint = ax.CurrentPoint(1, 1:2);
        if isempty(firstClick)
            % Record the first click and update the label.
            firstClick = clickPoint;
            measurementLabel.Text = sprintf('First point: (%.1f, %.1f)', firstClick(1), firstClick(2));
        else
            % On the second click, compute the Euclidean distance.
            secondClick = clickPoint;
            distance = sqrt(sum((secondClick - firstClick).^2));
            measurementLabel.Text = sprintf('Measurement: %.2f pixels', distance);
            hold(ax, 'on');
            measurementLine = plot(ax, [firstClick(1), secondClick(1)], [firstClick(2), secondClick(2)], 'r-', 'LineWidth', 2);
            hold(ax, 'off');
            % Reset to allow a new measurement.
            firstClick = [];
        end
    end

    % Initialize by displaying the first frame
    updateFrame();
end
