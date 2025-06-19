# Wildfire Detection and Satellite Downlink Pipeline

This MATLAB & Simulink project explores how satellite data and signal processing can be combined to track wildfire risk and prioritize data downlink from a satellite constellation. The goal is to simulate a scalable, real-time response system for wildfire monitoring using Earth observation and satellite communications.

---

## Key Features

### Fire Region Detection & Analysis
- Uses **NASA MODIS 24-hour active fire data**
- Clusters fire points using **DBSCAN** (geospatial proximity)
- Calculates region **area using convex hulls** and spherical geometry
- Computes **average brightness** per region
- Maps region centroids to a **Fire Weather Index (FWI)** image for local fire danger context

### Satellite Assignment
- Converts region centroids to **ECEF coordinates**
- Loads a 66-satellite Iridium-like constellation using `satelliteScenario`
- Computes distances to assign each fire region to its **nearest satellite**

### Binary Encoding
- Encodes each region’s data (lat, lon, area, brightness, FWI, priority) into **scaled binary strings**
- Supports **sign-bit encoding** for lat/lon
- Aggregates binary streams per satellite

### Simulink Downlink Simulation
- Selects satellite ID to extract its associated bitstream
- Simulates **BPSK modulation** based on binary data
- Includes a scope to visualize the signal and transmitted bits
- Supports sample-aligned processing with configurable parameters



