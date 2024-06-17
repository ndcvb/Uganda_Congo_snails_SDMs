import os
import re
import rasterio
import numpy
from xml.dom import minidom

# Input folder containing GeoTIFF files , these files are the output from Planet but they should be unzipped and one single folder (All the PSScene)
input_folder = '/Users/u0150402/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/Output_planet/'

# Output folder for NDVI files, this folder should exist in your directory
output_folder = '/Users/u0150402/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/NDVI/'

# Find all GeoTIFF files with the ending "AnalyticMS_SR_harmonized_clip.tif"
tif_files = [f for f in os.listdir(input_folder) if f.endswith('AnalyticMS_SR_harmonized_clip.tif')]

for tif_file in tif_files:
    # Construct the full file paths
    image_file = os.path.join(input_folder, tif_file)
    
    # Get the date and code from the GeoTIFF file name
    date_code = os.path.splitext(tif_file)[0][:18]
    
    # Identify the XML file based on the GeoTIFF file name
    xml_pattern = re.compile(f"{date_code}(.*?)_AnalyticMS_metadata_clip.xml")
    xml_file = next((os.path.join(input_folder, f) for f in os.listdir(input_folder) if xml_pattern.match(f)), None)

    if xml_file is None:
        print(f"XML file not found for {date_code}. Skipping.")
        continue

    # Load red and NIR bands
    with rasterio.open(image_file) as src:
        band_red = src.read(3)
        band_nir = src.read(4)

    # Parse XML metadata
    xmldoc = minidom.parse(xml_file)
    nodes = xmldoc.getElementsByTagName("ps:bandSpecificMetadata")

    # XML parser refers to bands by numbers 1-4
    coeffs = {}
    for node in nodes:
        bn = node.getElementsByTagName("ps:bandNumber")[0].firstChild.data
        if bn in ['1', '2', '3', '4']:
            i = int(bn)
            value = node.getElementsByTagName("ps:reflectanceCoefficient")[0].firstChild.data
            coeffs[i] = float(value)

    # Multiply by corresponding coefficients
    band_red = band_red * coeffs[3]
    band_nir = band_nir * coeffs[4]

    # Allow division by zero
    numpy.seterr(divide='ignore', invalid='ignore')

    # Calculate NDVI
    ndvi = (band_nir.astype(float) - band_red.astype(float)) / (band_nir + band_red)

    # Set spatial characteristics of the output object to mirror the input
    kwargs = src.meta
    kwargs.update(
        dtype=rasterio.float32,
        count=1
    )

    # Specify the output path using the date and code
    output_path = os.path.join(output_folder, f"{date_code}_NDVI.tif")

    # Write the NDVI file
    with rasterio.open(output_path, 'w', **kwargs) as dst:
        dst.write_band(1, ndvi.astype(rasterio.float32))

    print(f"NDVI file for {date_code} saved at: {output_path}")
