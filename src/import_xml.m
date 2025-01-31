function import_xml(path_xml, base_str)
    xmlFile = strcat(path_xml,base_str);
    % Load the XML file
    xmlData = xmlread(xmlFile);
    
    % Initialize variables
    id = 1;
    trackID = 1;
    data = [];
    
    % Get all <particle> elements
    particles = xmlData.getElementsByTagName('particle');
    
    % Iterate over each particle
    for i = 0:particles.getLength-1
        particle = particles.item(i);
        
        % Get all <detection> elements within the current <particle>
        detections = particle.getElementsByTagName('detection');
        
        % Iterate over each detection
        for j = 0:detections.getLength-1
            detection = detections.item(j);

            % Extract attributes t, x, y
            t = str2double(detection.getAttribute('t'));
            x = str2double(detection.getAttribute('x'));
            y = str2double(detection.getAttribute('y'));
            %if(x < (xend-del) && x > (xstart+del) && y < (yend-del) && y > (ystart +del))
            % Append to data array
                data = [data; id, t+1, x, y, 0, trackID];
            % Increment ID
                id = id + 1;
            %end
        end
        
        % Increment track ID
        trackID = trackID + 1;
    end
    
    % Save to .mat file
    save(strcat(path_xml,base_str,'.mat'), 'data');

end

