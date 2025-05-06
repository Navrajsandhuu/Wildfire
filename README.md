# Global Wildfire Clustering and Area Estimation (MODIS - May 3, 2025)

This MATLAB-based project analyzes NASA MODIS active fire data for May 3, 2025. It identifies spatial clusters of wildfire activity, calculates the area of each region in hectares, and visualizes the results on a global map using geospatial tools.

## Key Results

- Date analyzed: May 3, 2025  
- Fire regions identified: 592  
- Estimated total area affected: 171,248 hectares

## Methods

- DBSCAN clustering (epsilon = 0.02°) to group nearby fire detections  
- Convex hulls (`convhull`) to define cluster boundaries  
- Area estimation using `areaint()` with the WGS84 ellipsoid  
- Geospatial visualization using `geoplot` and `geopolyshape`

## Future Plans

- Integrate with `satelliteScenario` to simulate satellite coverage over active fire zones  
- Add time-based analysis 
- Full satcom architecture with brightness adjustments
- Data downlinks based off of priority
- Full BPSK data conversion with longitude and latitude locations
- RF signal link budgeting 

