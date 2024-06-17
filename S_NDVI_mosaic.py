import os
from os.path import join
from rasterio.merge import merge
from rasterio.plot import show
from rasterio import open as rasterio_open
from datetime import datetime
import numpy as np

# Path to the folder containing all GeoTIFF files with the NDVI data
folder_path = "/Users/u0150402/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/NDVI"

# List all GeoTIFF files in the folder
tiff_files = [join(folder_path, f) for f in os.listdir(folder_path) if f.endswith("_NDVI.tif")]

# Extract dates from file names
date_str = [os.path.basename(tiff).split("_")[0] for tiff in tiff_files]

# Get unique dates
unique_dates = list(set(date_str))

# Create a list to store file names for each date
date_file_list = {date: [] for date in unique_dates}

for tiff, date in zip(tiff_files, date_str):
    date_file_list[date].append(tiff)

# Iterate through each unique date
for idx, (date, date_files) in enumerate(date_file_list.items(), start=1):
    print(f"Processing Mosaic {idx} for date: {date}")

    # Create a list of raster objects
    rasters = [rasterio_open(tiff) for tiff in date_files]

    # Merge the rasters into a single raster with a nodata value
    mosaic, out_trans = merge(rasters, nodata=np.nan)

    # Set output file path
    output_path = f"/Users/u0150402/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/NDVI_mosaic/new_mosaic_by_date_{date}.tif"

    # Write the mosaic to a GeoTIFF file, this writes one of the two values (not average, just overwrite)
    with rasterio_open(output_path, 'w', driver='GTiff', height=mosaic.shape[1], width=mosaic.shape[2], count=mosaic.shape[0], dtype=mosaic.dtype, crs=rasters[0].crs, transform=out_trans, nodata=np.nan) as dest:
        dest.write(mosaic)

    # Optionally, you can plot the mosaic
    # show(mosaic, cmap='terrain', title=f'Mosaic for {date}')

    # Close the raster files
    for raster in rasters:
        raster.close()

    print(f"Mosaic {idx} for date {date} created at: {output_path}")
    print("=============================================")
