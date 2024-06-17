# Libraries
library(sf)
library(raster)
library(lubridate)

# Extract DEM

# This is normal coordinates not UTM 

df_excel <- read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_utm_coordinates.csv", sep = ",", header = TRUE) 

coordinates_csv <- data.frame(lon = df_excel$longitude, lat = df_excel$latitude)

# Path to the folder containing the single DEM image file
image_file <- "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/WorldDEMNeo_DSM_015_N00_87_E030_50_DEM.tif"

image_raster <- raster(image_file)

# Create an empty column 'DEM_value' in the Excel file
df_excel$DEM_value <- NA

# Iterate through each row in the Excel file
for (i in 1:nrow(df_excel)) {
  
  # Read the single DEM image file
  image_raster <- raster(image_file)
  
  # Extract the DEM value at the given coordinates
  df_excel$DEM_value[i] <- raster::extract(image_raster, coordinates_csv[i,])
  }

summary(df_excel$DEM_value)

# Create density plot of temperature
ggplot(df_excel, aes(x = DEM_value)) +
  geom_density(fill = "brown2", color = "brown", alpha = 0.5) +
  labs(
    x = "DEM",
    y = "Density") + theme_bw()



# Print or save the updated Excel file
write.csv(df_excel, "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/D_Uganda_20m_snails_DEM.csv", row.names = FALSE)

