# Libraries
library(sf)
library(raster)
library(lubridate)

# Code to match NDVI with our data

df_excel <- read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_utm_coordinates.csv", sep = ",", header = TRUE) 

df_excel$start <- ymd(as.Date(df_excel$start))

coordinates_csv = data.frame(UTM_x = df_excel$UTM_Easting, UTM_y = df_excel$UTM_Northing)

# Path to the folder containing all merged image files
merged_folder <- "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/NDVI_mosaic/"

# Pattern for matching NDVI image files
pattern <- "new_mosaic_by_date_.*\\.tif$"

# List of NDVI image files
image_files <- list.files(merged_folder, pattern = pattern, full.names = TRUE)

date_str <- substr(basename(image_files), 20, 27)
image_dates <- as.Date(date_str, format = "%Y%m%d")

# Create an empty column 'NDVI_planet' in the Excel file
df_excel$NDVI_planet <- NA

# Iterate through each row in the Excel file
for (i in 1:nrow(df_excel)) {
  
  # Filter data based on date within at least less than 30 days
  date_condition <- (df_excel$start[i] - image_dates) <= 16 & (df_excel$start[i] - image_dates) >= 0
  
  if (any(date_condition)) {
    # Find the closest date
    closest_date <- image_dates[which.min(abs(df_excel$start[i] - image_dates))]
    closest_date_str <- format(closest_date, "%Y%m%d")
    
    matching_files <- grep(paste0(closest_date_str, "\\.tif$"), image_files, value = TRUE)
    
    if (length(matching_files) > 0) {
      # Use the first matching file (you may adjust this based on your requirements)
      image_files1 <- raster(matching_files[1])
      
      # Read the image file
      df_excel$NDVI_planet[i] = image_files1[cellFromXY(image_files1, coordinates_csv[i,])]
      
    } else {
      # Handle the case when no matching file is found
      print("No matching file found for closest_date_str.")
    }
  } else {
    print(paste("No data found for date", df_excel$start[i]))
  }
}

summary(df_excel)

# Libraries
library(sf)
library(raster)
library(lubridate)

# Code to match NDVI with our data

df_excel <- read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_utm_coordinates.csv", sep = ",", header = TRUE)

df_excel$start <- ymd(as.Date(df_excel$start))

coordinates_csv <- data.frame(UTM_x = df_excel$UTM_Easting, UTM_y = df_excel$UTM_Northing)

# Path to the folder containing all merged image files
merged_folder <- "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/NDVI_mosaic/"

# Pattern for matching NDVI image files
pattern <- "new_mosaic_by_date_.*\\.tif$"

# List of NDVI image files
image_files <- list.files(merged_folder, pattern = pattern, full.names = TRUE)

date_str <- substr(basename(image_files), 20, 27)
image_dates <- as.Date(date_str, format = "%Y%m%d")

# Create an empty column 'NDVI_planet' in the Excel file
df_excel$NDVI_planet <- NA

# Iterate through each row in the Excel file
for (i in 1:nrow(df_excel)) {
  
  # Filter data based on date within the 16-day range
  date_condition <- abs(df_excel$start[i] - image_dates) <= 30
  
  if (any(date_condition)) {
    # Get the dates within the range and sort by proximity to the target date
    candidate_dates <- image_dates[date_condition]
    candidate_dates <- candidate_dates[order(abs(df_excel$start[i] - candidate_dates))]
    
    found <- FALSE
    
    for (j in 1:length(candidate_dates)) {
      closest_date_str <- format(candidate_dates[j], "%Y%m%d")
      matching_files <- grep(paste0(closest_date_str, "\\.tif$"), image_files, value = TRUE)
      
      if (length(matching_files) > 0) {
        # Use the first matching file (you may adjust this based on your requirements)
        image_files1 <- raster(matching_files[1])
        
        # Read the image file and extract the NDVI value
        ndvi_value <- image_files1[cellFromXY(image_files1, coordinates_csv[i,])]
        
        if (!is.na(ndvi_value)) {
          df_excel$NDVI_planet[i] <- ndvi_value
          found <- TRUE
          break
        }
      }
    }
    
    if (!found) {
      print(paste("No valid NDVI value found for date", df_excel$start[i]))
    }
  } else {
    print(paste("No data found for date", df_excel$start[i]))
  }
}

summary(df_excel)

# Create density plot of temperature
ggplot(df_excel, aes(x = NDVI_planet)) +
  geom_density(fill = "green", color = "darkgreen", alpha = 0.5) +
  labs(
    x = "NDVI",
    y = "Density") + theme_bw()


# Print or save the updated Excel file
write.csv(df_excel, "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_20m_NDVI.csv", row.names = FALSE)
# Print or save the updated Excel file


