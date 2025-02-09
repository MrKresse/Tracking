function show_tracks_ui(path_processed, path_incoming, base_str, dist_cutoff)
    % show_tracks_ui displays raw .tif image frames with overlaid linked tracks.
    %
    % Inputs:
    %   path_processed: directory containing detection and linking data.
    %   path_incoming : directory containing the raw .tif file.
    %   base_str      : base filename (e.g., 'movie.tif') for the raw image.
    %   dist_cutoff   : linking cutoff used in naming the linking data file.
    %
    % Detection matrix (in file base_str.tracks_raw.dat.mat) is assumed to have:
    %   Col1: Particle ID
    %   Col2: Frame number
    %   Col3: x position
    %   Col4: y position
    %   Col5: Intensity value (peak intensity)
    %   Col6: Track ID (only for particles of 1st frame)
    %
    % Linking matrix (in file base_str.tracks_v2.<dist_cutoff>.dat.mat) is assumed to have:
    %   Col1: Particle ID
    %   Col2: Track ID (linked particles across frames share the same Track ID)
    %   Col3: Squared displacement (pixel^2)
    %   Col4: Peak intensity in previous frame
    %   Col5: Continuation flag (1: track continues, 0: track terminates)

    %% Load detection data
    detFile = fullfile(path_processed, strcat(base_str, '.tracks_raw.dat.mat'));
    tmpDet = load(detFile, '-mat');
    xy_schw = tmpDet.data;
    
    %% Load linking data
    linkFile = fullfile(path_processed, strcat(base_str, '.tracks_v2.', num2str(dist_cutoff), '.dat.mat'));
    tmpLink = load(linkFile, '-mat');
    linkData = tmpLink.data;
    
    %% Join detection and linking data (using ismember to preserve order)
    % For each detection (particle ID in col1), find the corresponding linking row.
    [found, idxLink] = ismember(xy_schw(:,1), linkData(:,1));
    if ~all(found)
        warning('Not all detections were found in the linking data.');
    end
    % Create a new matrix with: [Frame, x, y, TrackID] 
    detWithTrack = [xy_schw(found, 2), xy_schw(found, 3:4), linkData(idxLink(found), 2)];
    
    %% Group detections by Track ID
    uniqueTracks = unique(detWithTrack(:,4));
    nTracks = length(uniqueTracks);
    tracks = cell(nTracks, 1);
    for i = 1:nTracks
        tid = uniqueTracks(i);
        % Select rows with this Track ID and sort them by frame number.
        trackRows = detWithTrack(detWithTrack(:,4) == tid, :);
        trackRows = sortrows(trackRows, 1);
        tracks{i} = trackRows;
    end
    % Preassign distinct colors (one per track)
    trackColors = lines(nTracks);
    
    %% Load raw image information
    rawFile = fullfile(path_incoming, base_str);
    imgMeta = imfinfo(rawFile);
    numFrames = numel(imgMeta);
    disp(['Number of frames: ', num2str(numFrames)]);
    
    %% Create UI figure and frame slider (no brightness adjustments)
    fig = uifigure('Name', 'Track Viewer', 'Position', [100,100,900,700]);
    ax = uiaxes(fig, 'Position', [50,200,800,450]);
    
    frameSlider = uislider(fig, ...
        'Position', [50,170,300,3], ...
        'Limits', [1, numFrames], ...
        'Value', 1);
    frameSlider.MajorTicks = round(linspace(1, numFrames, 10));
    uilabel(fig, 'Position', [50,190,100,22], 'Text', 'Frame');
    
    frameSlider.ValueChangedFcn = @(src, event) updateFrame();
    
    %% Nested function to update the displayed frame and overlay tracks
    function updateFrame()
        frameNum = round(frameSlider.Value);
        
        % Read the raw image frame and convert to uint8 (as in your reference)
        imgFrame = imread(rawFile, frameNum);
        imshow(uint8(imgFrame), 'Parent', ax);
        hold(ax, 'on');
        
        % For each track, overlay detections up to the current frame.
        for i = 1:nTracks
            trackPts = tracks{i};  % [Frame, x, y, TrackID]
            validIdx = trackPts(:,1) <= frameNum;
            if any(validIdx)
                pts = trackPts(validIdx, :);
                % Plot a line if at least 2 points exist.
                if size(pts,1) >= 2
                    plot(ax, pts(:,2), pts(:,3), '-', 'Color', trackColors(i,:), 'LineWidth', 2);
                end
                % Mark the detection if one occurs exactly at the current frame.
                curIdx = find(pts(:,1) == frameNum);
                if ~isempty(curIdx)
                    curPoint = pts(curIdx(end), :);
                    plot(ax, curPoint(2), curPoint(3), 'o', 'Color', trackColors(i,:), 'MarkerSize', 8, 'LineWidth', 2);
                end
            end
        end
        
        hold(ax, 'off');
    end

    % Initialize display with the first frame.
    updateFrame();
end
