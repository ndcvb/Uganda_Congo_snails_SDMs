
library(dplyr)
library(lubridate)
library(ggplot2)


# Read data files 
data_tot = read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_20m_snails.csv", sep = ",", header = TRUE)
data_guide <-  data_tot


df_st <- read.csv("~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/CHIRPS_output_EE.csv", sep = ",", header = TRUE)

# Convert temperature values to Celsius
values <- df_st[,2:(ncol(df_st)-2)]
new_df <- data.frame(Watercontactsite = df_st$Watercontactsite, values)

# Clean column names in new_df to match date format
names(new_df) <- gsub("^X", "", names(new_df))
names(new_df) <- gsub("_", "", names(new_df))
names(new_df) <- gsub("precipitation", "", names(new_df))

# Ensure proper date formats
data_guide$today <- dmy(data_guide$today)
new_df_dates <- as.Date(names(new_df)[-1], format = "%Y%m%d")

# Create a new column in data_guide for precipitation

data_guide$oneweek = data_guide$today - 7

data_guide$pp_oneweek <- NA

for (i in 1:nrow(data_guide)) {
  site <- data_guide$Watercontactsite[i]
  sta_date = data_guide$oneweek[i]
  end_date = data_guide$today[i]
  
  # Filter new_df for the matching Watercontactsite
  site_temps <- new_df %>% filter(Watercontactsite == site)
  
  period =   seq(sta_date,end_date, by='days')
  period = gsub("-", "", period)
  
  matching_period = colnames(site_temps) %in% period
  
  data_guide$pp_oneweek[i] <- rowSums(site_temps[1, matching_period], na.rm = TRUE)
  
}

summary(data_guide$pp_oneweek)

# Create density plot of temperature
ggplot(data_guide, aes(x = pp_oneweek)) +
  geom_density(fill = "blue", color = "darkblue", alpha = 0.5) +
  labs(
    x = "Precipitation",
    y = "Density") + theme_bw()



write.csv(data_guide, "~/Library/CloudStorage/OneDrive-KULeuven/Uganda_Congo/Data/Uganda/D_Uganda_20m_snails_pp.csv", row.names = FALSE)

