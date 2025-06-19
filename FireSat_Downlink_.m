clc; clear;

%% Load MODIS Fire Data
C = readtable("MODIS_C6_1_Global_24h.csv");  % MODIS fire points

lat = C.latitude;
lon = C.longitude;
brightness = C.brightness;

coords = [lat, lon];

% DBSCAN clustering
epsilon = 0.5;
minPts = 3;
clusterLabels = dbscan(coords, epsilon, minPts);

% Prepare outputs
numClusters = max(clusterLabels);
regionCentroids = zeros(numClusters, 2);
regionAreasHa   = zeros(numClusters, 1);
avgBrightness   = zeros(numClusters, 1);

for k = 1:numClusters
    clusterIdx = find(clusterLabels == k);
    if numel(clusterIdx) < 3 || max(clusterIdx) > numel(lat)
        continue
    end

    latk = lat(clusterIdx);
    lonk = lon(clusterIdx);

    if numel(unique(latk)) < 2 || numel(unique(lonk)) < 2
        continue
    end

    try
        K = convhull(lonk, latk);
    catch
        warning("Skipping cluster %d: Convex hull failed (possibly collinear).", k);
        continue
    end

    brightnessk = brightness(clusterIdx);
    latHull = latk(K);
    lonHull = lonk(K);

    % Compute area (km² → hectares)
    wgs84 = wgs84Ellipsoid("km");
    area_km2 = areaint(latHull, lonHull, wgs84);
    regionAreasHa(k) = area_km2 * 100;

    % Compute centroid and brightness
    regionCentroids(k,:) = [mean(latHull), mean(lonHull)];
    avgBrightness(k) = mean(brightnessk, 'omitnan');
end

%% Load and Convert FWI Map
img = imread("FWI.png");
img = im2double(img);

colorMap = [
    156 255 192;
    234 255 144;
    255 198  63;
    234 118  32;
    171  10  21;
     68   5  24
] / 255;

fwiRanges = [
     0.0, 11.2;
    11.2, 21.3;
    21.3, 38.0;
    38.0, 50.0;
    50.0, 70.0;
    70.0, 100.0
];

[rows, cols, ~] = size(img);
FWI = NaN(rows, cols);

for i = 1:rows
    for j = 1:cols
        pixel = squeeze(img(i,j,:))';
        dists = vecnorm(colorMap - pixel, 2, 2);
        [~, idx] = min(dists);
        FWI(i,j) = mean(fwiRanges(idx,:));
    end
end

%% Map Centroids to FWI Values
latRange = [-90, 90];
lonRange = [-180, 180];
nRegions = size(regionCentroids, 1);
fwiAtCentroids = NaN(nRegions, 1);

for i = 1:nRegions
    lat_i = regionCentroids(i, 1);
    lon_i = regionCentroids(i, 2);
    row = round((latRange(2) - lat_i) / diff(latRange) * rows);
    col = round((lon_i - lonRange(1)) / diff(lonRange) * cols);
    row = max(min(row, rows), 1);
    col = max(min(col, cols), 1);
    fwiAtCentroids(i) = FWI(row, col);
end

%% Compute Priority and Sort Downlink Data
priority = 0.7 * regionAreasHa + 0.3 * avgBrightness + 2 * fwiAtCentroids;
priority = priority(:);  % Ensure column vector

downlink = [regionCentroids, regionAreasHa, avgBrightness, fwiAtCentroids, priority];
downlink = sortrows(downlink, 6, 'descend');

%% Plot FWI Map and Fire Cluster Hulls (no centroids)
scaleFactor = 0.6;
figure('Units', 'pixels', 'Position', [100 100 cols*scaleFactor rows*scaleFactor]);
imagesc([lonRange(1), lonRange(2)], [latRange(2), latRange(1)], FWI); % flipped latitude axis
axis xy
axis image
colormap(gray)
colorbar
title("Fire Weather Index Map with Clustered Fire Regions")
xlabel("Longitude")
ylabel("Latitude")
hold on

% Overlay convex hull polygons only
colors = lines(numClusters);  % Unique color per cluster

for k = 1:numClusters
    clusterIdx = find(clusterLabels == k);
    if numel(clusterIdx) < 3 || max(clusterIdx) > numel(lat)
        continue
    end

    latk = lat(clusterIdx);
    lonk = lon(clusterIdx);

    if numel(unique(latk)) < 2 || numel(unique(lonk)) < 2
        continue
    end

    try
        K = convhull(lonk, latk);
    catch
        warning("Skipping cluster %d: Convex hull failed.", k);
        continue
    end

    latHull = latk(K);
    lonHull = lonk(K);

    fill(lonHull, latHull, colors(k,:), ...
        'FaceAlpha', 1, ...
        'EdgeColor', 'k', ...
        'LineWidth', 0.5);
end
