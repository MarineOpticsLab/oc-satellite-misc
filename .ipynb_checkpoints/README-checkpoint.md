# oc-satellite-misc

A repo miscellaneous pieces of code (scripts, notebooks, etc) for working with ocean colour satellite data

## File Descriptions:
1. `OCSatelliteFileLoading.ipynb` - load and plot level 2 ocean colour data from NASA OBPG
2. `searchOBPG-L1A.ipynb` and `searchOBPG-L2.ipynb` - perform searches for OBPG L1A and L2 satellite granule download links based on a list of field observation times and locations. The L1 script crawls the oceancolorweb, the L2 script uses the EarthData CMR. We have updated versions of these integrated into our matchup workflows. 
3. `PACE_RGB_spectra_visualization.ipynb` - loads (streams) PACE data, makes RGBs using rhos, and plots Rrs spectra from specified pixels for OCI
4. `PACE_earthaccess_tips.ipynb` - a place to note tips and tricks for working with PACE via earthaccess
5. `GNATS_PACE_RGB_visualization.ipynb` - makes RGB and chl images for the Gulf of Maine and includes the GNATS stations.