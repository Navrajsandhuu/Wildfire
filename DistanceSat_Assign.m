clc;


startTime= datetime("now")-1/24; % Start Time a week ago
stopTime= datetime("now"); %Simulation Stops at current date and time 
sampleTime= 60*60; % Every Hour 
sc= satelliteScenario(startTime,stopTime,sampleTime);
%viewer= satelliteScenarioViewer(sc,ShowDetails=false); 


numSatellitesPerOrbitalPlane = 11;
numOrbits = 6;

orbitIdx = repelem(1:numOrbits,1,numSatellitesPerOrbitalPlane);
planeIdx = repmat(1:numSatellitesPerOrbitalPlane,1,numOrbits);

RAAN = 180*(orbitIdx-1)/numOrbits;
trueanomaly = 360*(planeIdx-1 + 0.5*(mod(orbitIdx,2)-1))/numSatellitesPerOrbitalPlane;
semimajoraxis = repmat((6371 + 780)*1e3,size(RAAN)); % meters
inclination = repmat(86.4,size(RAAN)); % degrees
eccentricity = zeros(size(RAAN)); % degrees
argofperiapsis = zeros(size(RAAN)); % degrees

iridiumSatellites = satellite(sc,...
    semimajoraxis,eccentricity,inclination,RAAN,argofperiapsis,trueanomaly,...
    Name="Iridium " + string(1:66)');

[position]=states(iridiumSatellites, startTime,"CoordinateFrame","ecef");
positionMatrix = squeeze(position)'; 

%% ECEF Conversion Parameters
a = 6378137;            % Earth's semi-major axis in km (WGS-84)
e = 0.0167;              % Earth's eccentricity
h = 0;                   % Assume altitude = 0 km for surface fire detections

lat = deg2rad(regionCentroids(:,1)); % Convert latitude to radians
lon = deg2rad(regionCentroids(:,2)); % Convert longitude to radians

% Prime vertical radius of curvature
RN = a ./ sqrt(1 - (e^2) * (sin(lat).^2));

% Compute ECEF coordinates
x = (RN + h) .* cos(lat) .* cos(lon);
y = (RN + h) .* cos(lat) .* sin(lon);
z = ((1 - e^2) .* RN + h) .* sin(lat);

fire_ecefCoords = [x, y, z];  % [n x 3] matrix

%%
% Assume 'fire_ecefCoords' [N x 3], 'positionMatrix' [66 x 3], and 'binaryOut' [N x 6] already exist
nClusters = size(fire_ecefCoords, 1);
nSats = size(positionMatrix, 1);


% binaryOut is assumed to be a string array of size [N x M]
combinedBinary = strings(size(binaryOut, 1), 1);

for i = 1:size(binaryOut, 1)
    combinedBinary(i) = join(binaryOut(i, :), "");
end

% Preallocate cell array for each satellite
satelliteBinaryData = cell(nSats, 1);

% Compute distances and assign
for i = 1:nClusters
    fireXYZ = fire_ecefCoords(i, :);
    
    % Compute distances to all satellites
    diffs = positionMatrix - fireXYZ;
    dists = vecnorm(diffs, 2, 2);
    
    % Find closest satellite
    [~, satIdx] = min(dists);
    
    % Append binary row to that satellite’s data
    satelliteBinaryData{satIdx} = [satelliteBinaryData{satIdx}; combinedBinary(i, :)];
end

% binaryOut is assumed to be a string array of size [N x M]
combinedBinary = strings(size(binaryOut, 1), 1);


% Display number of clusters assigned per satellite
for s = 1:nSats
    fprintf("Satellite %d: %d clusters assigned\n", s, size(satelliteBinaryData{s}, 1));
end

% Precompute and save this in a .mat file
save('satelliteData.mat', 'satelliteBinaryData');


