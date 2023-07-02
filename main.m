% Create object to read video
vidReader = vision.VideoFileReader('La La Land low.avi');
vidReader.VideoOutputDataType = 'double';

% Create structural element for morphological operations to remove disturbances
diskElem = strel('disk',3);
diskElem2 = strel('disk',3);
se = strel('disk',10);
se2 = strel('disk',13);

% Create a BlobAnanlysis object to calculate detected objects area, centroid, major axis length and label matrix. 
hBlob = vision.BlobAnalysis('MinimumBlobArea',500,'MaximumBlobArea',12000);

% Create VideoPlayer
vidPlayer = vision.DeployableVideoPlayer;

%% Run the algorithm in a loop
while ~isDone(vidReader)
    
    % Read Frame
    vidFrame = step(vidReader);
  
    % Convert RGB image to chosen color space
    Ihsv = rgb2hsv(vidFrame);
    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.067;
    channel1Max = 0.208;

    channel1Min2 = 0.534;
    channel1Max2 = 0.620;
    
    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.385;
    channel2Max = 1.000;

    channel2Min2 = 0.202;
    channel2Max2 = 0.638;
    
    % Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.000;
    channel3Max = 1.000;

    channel3Min2 = 0.387;
    channel3Max2 = 0.833;

    % Create mask based on chosen histogram thresholds
    Ibw = (Ihsv(:,:,1) >= channel1Min ) & (Ihsv(:,:,1) <= channel1Max) & ...
        (Ihsv(:,:,2) >= channel2Min ) & (Ihsv(:,:,2) <= channel2Max) & ...
        (Ihsv(:,:,3) >= channel3Min ) & (Ihsv(:,:,3) <= channel3Max);

    Ibw2 = (Ihsv(:,:,1) >= channel1Min2 ) & (Ihsv(:,:,1) <= channel1Max2) & ...
    (Ihsv(:,:,2) >= channel2Min2 ) & (Ihsv(:,:,2) <= channel2Max2) & ...
    (Ihsv(:,:,3) >= channel3Min2 ) & (Ihsv(:,:,3) <= channel3Max2);
    
    % Use morphological operations to remove disturbances
    Ibwopen = imopen(Ibw,diskElem);
    Ibwopen2 = imopen(Ibw2,diskElem2);

    Ibwdilate=imdilate(Ibwopen,se);
    Ibwdilate2=imdilate(Ibwopen2,se2);

    % Extract the blobs from the frame 
    [areaOut,centroidOut,bboxOut] = step(hBlob, Ibwdilate);
    [areaOut2,centroidOut2,bboxOut2] = step(hBlob, Ibwdilate2);
    
    % Draw a box around the detected objects
    Ishape = insertShape(vidFrame,'Rectangle',bboxOut,'Color','magenta');
    Ishape2 = insertShape(Ishape,'Rectangle',bboxOut2,'Color','green');
    
    %Play in the video player
    step(vidPlayer,Ishape2);
    pause(0.009);
end
%% Cleanup
release(vidReader)
release(hBlob)
release(vidPlayer)