% Load MODIS Fire Data
C = readtable("MODIS_C6_1_Global_24h.csv"); % Update to current data set using
% url: https://firms.modaps.eosdis.nasa.gov/active_fire/

lat = C.latitude;
lon = C.longitude;

% Combine coordinates
coords = [lat, lon];

% Cluster fires based on 0.02° spatial proximity
epsilon = 0.02;  % Adjust eplison as needed degrees
minPts = 3;     % minimum points to form a cluster
clusterLabels = dbscan(coords, epsilon, minPts);

% Create figure with base map
figure
geobasemap streets
hold on
title("Filled MODIS Fire Clusters (0.02° spatial tolerance)")

% Colormap setup
numClusters = max(clusterLabels);
colors = lines(numClusters);

% Loop through each cluster
for k = 1:numClusters
    idx = clusterLabels == k;
    if sum(idx) < 3, continue; end

    latk = lat(idx);
    lonk = lon(idx);

    % Compute convex hull
    K = convhull(lonk, latk);
    latHull = latk(K);
    lonHull = lonk(K);

    % Compute area in hectares using spherical geometry
    wgs84 = wgs84Ellipsoid("km");
    [area_km2] = areaint(latHull, lonHull, wgs84);
    regionAreasHa(k) = area_km2 * 100;  % Convert to hectares

    % Create filled polygon
    shp = geopolyshape(latHull, lonHull);

    % Plot filled cluster
    geoplot(shp, ...
        'FaceColor', colors(k,:), ...
        'FaceAlpha', 0.5, ...
        'EdgeColor', 'k', ...
        'LineWidth', 0.8);
end
%%
numRegions = max(clusterLabels);  % Exclude noise points (-1)
disp("Number of fire regions: " + numRegions);

totalHa = sum(regionAreasHa, 'omitnan');
disp("Total estimated hectares burned: " + totalHa + " ha");



