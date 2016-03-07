function object_tracking()
% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);


reDetect = false;

% Create the webcam object.
cam = webcam();

% Capture one frame to get its size.

for i=1:5
    videoFrame = snapshot(cam);
end

frameSize = size(videoFrame);
videoFrameGray = rgb2gray(videoFrame);

% display a single frame capratured and let user select a region.
figure;

imshow(videoFrame);

disp('Select a region to be tracked')

% wait until region is selected.
position = wait(imrect);

%remeber region selected
object_image = imcrop(videoFrame,position);

object_image_grey = rgb2gray(object_image);

object_points = detectSURFFeatures(object_image_grey);

% get features
[object_features,object_points] = extractFeatures(object_image_grey,object_points);

region = round(position);

if region(1,1)+region(1,3)>frameSize(1,2)
    region(1,3) = frameSize(1,2)-region(1,1);
end
if region(1,2)+region(1,4)>frameSize(1,1)
    region(1,4) = frameSize(1,1)-region(1,2);
end

selectedImage = insertShape(videoFrame,'Rectangle',region,'Color','red');

figure;

imshow(selectedImage);
disp('region selected')


% show interesting points within selected region.
points = detectMinEigenFeatures(rgb2gray(videoFrame),'ROI',region);

pointImage = insertMarker(videoFrame, points.Location, '+', 'Color', 'white');

character_pos = mean(points.Location);

figure;

imshow(pointImage);
disp('please wait...')


% Create the video player object.

initialize(pointTracker,points.Location,videoFrameGray);

xyPoints = points.Location;

oldPoints = xyPoints;

bboxPoints = bbox2points(region);

videoPlayer = vision.VideoPlayer('Position', [300 50 [frameSize(2)*0.7, frameSize(1)*0.7]+30]);
runLoop = true;


while runLoop
    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrameGray = rgb2gray(videoFrame);
    try
        [xyPoints,isFound] = step(pointTracker,videoFrameGray);
        visiblePoints = xyPoints(isFound,:);
        oldInliers = oldPoints(isFound,:);

        numPts = size(visiblePoints, 1);
    catch 
        reDetect = true;
    end
        
    

    if numPts >= 10 && reDetect==false;
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the face being tracked.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display tracked points.
            videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

            % Reset the points.
            oldPoints = visiblePoints;
            
            new_character_pos = mean(oldPoints);
            shift = new_character_pos-character_pos;
            factor = shift./[frameSize(2),frameSize(1)];
            gui_interface(factor)
            setPoints(pointTracker, oldPoints);
    else
        frame_points = detectSURFFeatures(videoFrameGray);
        [frame_features,frame_points] = extractFeatures(videoFrameGray,frame_points);
        boxPairs = matchFeatures(object_features,frame_features);
        if isempty(boxPairs) || size(boxPairs,1)<3
            step(videoPlayer, videoFrame);
            runLoop = isOpen(videoPlayer);
            continue;
        end
        matchedBoxPoints = object_points(boxPairs(:,1),:);
        matchedScenePoints = frame_points(boxPairs(:,2),:);
        try
            xform= ...
            estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'similarity');
        catch
            step(videoPlayer, videoFrame);
            runLoop = isOpen(videoPlayer);
            continue;
        end
        
        
        
        object_polygon = [1,1;size(object_image_grey,2),1;size(object_image_grey,2),size(object_image_grey,1);1,size(object_image_grey,1)];
        bboxPoints = transformPointsForward(xform, object_polygon);
        
        bboxPolygon = reshape(bboxPoints', 1, []);
        x_min = min(bboxPoints(:,1));
        x_max = max(bboxPoints(:,1));
        y_min = min(bboxPoints(:,2));
        y_max = max(bboxPoints(:,2));
        if x_max>frameSize(1,2)
            x_max = frameSize(1,2);
        end
        if y_max>frameSize(1,1)
            y_max = frameSize(1,1);
        end
        
        if x_min<0
            x_min = 0;
        end
        
        if y_min<0
            y_min = 0;
        end
        region = [x_min,y_min,x_max-x_min,y_max-y_min];
        round(region);
      
        try
            points = detectMinEigenFeatures(rgb2gray(videoFrame),'ROI',round(region));
        catch
            step(videoPlayer, videoFrame);
            runLoop = isOpen(videoPlayer);
            continue;
        end
        xyPoints = points.Location;       
        
        release(pointTracker);
        try        
            initialize(pointTracker,points.Location,videoFrameGray);
        catch
            step(videoPlayer, videoFrame);
            runLoop = isOpen(videoPlayer);
            continue;
        end            

        numPts = size(xyPoints,1);

        oldPoints = xyPoints;
        character_pos = mean(oldPoints);
       
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
        videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
        
        
    
      
    end
     % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
end

clear cam
        