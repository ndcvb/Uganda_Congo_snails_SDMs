
library(dplyr)
library(lubridate)
library(ggplot2)


# Read data files 
data_tot = read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_20m_snails.csv", sep = ",", header = TRUE)
data_guide <-  data_tot


df_st <- read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/Modis_output_EE.csv", sep = ",", header = TRUE)

# Convert temperature values to Celsius
values <- df_st[,2:1113] * 0.02 - 273.15
new_df <- data.frame(Watercontactsite = df_st$Watercontactsite, values)

# Clean column names in new_df to match date format
names(new_df) <- gsub("^X", "", names(new_df))
names(new_df) <- gsub("_", "", names(new_df))
names(new_df) <- gsub("LSTDay1km", "", names(new_df))

# Ensure proper date formats
data_guide$today <- dmy(data_guide$today)
new_df_dates <- as.Date(names(new_df)[-1], format = "%Y%m%d")

# Create a new column in data_guide for temperature
data_guide$temp_modis <- NA

# Iterate over each row in data_guide to match temperature
for (i in 1:nrow(data_guide)) {
  site <- data_guide$Watercontactsite[i]
  sample_date <- data_guide$today[i]
  
  # Filter new_df for the matching Watercontactsite
  site_temps <- new_df %>% filter(Watercontactsite == site)
  
  if (nrow(site_temps) > 0) {
    # Find the closest previous date
    available_dates <- new_df_dates[!is.na(site_temps[-1])]
    closest_date <- max(available_dates[available_dates <= sample_date], na.rm = TRUE)
    
    if (!is.na(closest_date)) {
      col_index <- which(new_df_dates == closest_date) + 1
      data_guide$temp_modis[i] <- site_temps[1, col_index]
    }
  }
}


# Create density plot of temperature
ggplot(data_guide, aes(x = temp_modis)) +
  geom_density(fill = "red", color = "darkred", alpha = 0.5) +
  labs(
    x = "Temperature",
    y = "Density") + theme_bw()


summary(data_guide$temp_modis)

write.csv(data_guide, "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_20m_snails_temp.csv", row.names = FALSE)

