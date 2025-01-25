#1. Set up your environment
#Ensure the required libraries are installed
install.packages(c("dplyr", "ggplot2", "lubridate", "tidyr", "scales"))

#Load the library
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(scales)

#2. Import the data
#Import the data 
file_paths <- list.files(path = "/Users/qianweisoh/Desktop/Portfolio/Cyclistic Case Study/CSV file", full.names = TRUE, pattern = "*.csv")
cyclistic_data <- do.call(rbind, lapply(file_paths, read.csv))

#Inspect the data
str(cyclistic_data)
head(cyclistic_data)

#3. Clean the data 
#Ensure Correct Data Types: Convert start_time and end_time to datetime format
cyclistic_data <- cyclistic_data %>%
  mutate(start_time = as.POSIXct(started_at, format = "%Y-%m-%d %H:%M:%S"),
         end_time = as.POSIXct(ended_at, format = "%Y-%m-%d %H:%M:%S"))

#Add New Columns: Add ride_length, month, day_of_week
cyclistic_data <- cyclistic_data %>%
  mutate(ride_length = as.numeric(difftime(end_time, start_time, units = "mins")),
         month = month(start_time, label = TRUE, abbr = TRUE),
         day_of_week = wday(start_time, label = TRUE, abbr = TRUE),
         hour = hour(start_time))

#Remove rides with negative or zero ride lengths
cyclistic_data <- cyclistic_data %>%
  filter(ride_length > 0)

#4. Perform Analysis
# Calculate the average ride length for members and casual riders
summary_stats <- cyclistic_data %>%
  group_by(member_casual) %>%
  summarize(average_ride_length = mean(ride_length),
            median_ride_length = median(ride_length),
            total_rides = n())
print(summary_stats)

#Export
write.csv(summary_stats, "summary_statistics.csv", row.names = FALSE)

# Analyse usage by day of week 
day_of_week_analysis <- cyclistic_data %>%
  group_by(member_casual, day_of_week) %>%
  summarize(average_ride_length = mean(ride_length),
            total_rides = n())
print(day_of_week_analysis)

#Export
write.csv(day_of_week_analysis, "day_of_week_analysis.csv", row.names = FALSE)

# Analyse usage by month
monthly_analysis <- cyclistic_data %>%
  group_by(member_casual, month) %>%
  summarize(average_ride_length = mean(ride_length),
            total_rides = n())
print(monthly_analysis)

#Export
write.csv(monthly_analysis, "monthly_analysis.csv", row.names = FALSE)

#Analyse usage by hour
hourly_analysis <- cyclistic_data %>%
  group_by(member_casual, hour) %>%
  summarize(average_ride_length = mean(ride_length),
            total_rides = n())

print(hourly_analysis)

#Export
write.csv(hourly_analysis, "hourly_analysis.csv", row.names = FALSE)

#5.Visualise the Data
#Average Ride Length by User Type
ggplot(summary_stats, aes(x = member_casual, y = average_ride_length, fill = member_casual)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Ride Length by User Type", x = "User Type", y = "Average Ride Length (minutes)") +
  theme_minimal()

ggsave("average_ride_length.png", plot = last_plot(), width = 8, height = 6)

#Usage by Day of Week
ggplot(day_of_week_analysis, aes(x = day_of_week, y = total_rides, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Rides by Day of Week", x = "Day of Week", y = "Number of Rides") +
  theme_minimal()

ggsave("usage_by_day_of_week.png", plot = last_plot(), width = 8, height = 6)

#usage by Month
ggplot(monthly_analysis, aes(x = month, y = total_rides, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Rides by Month", x = "Month", y = "Number of Rides") +
  theme_minimal()

ggsave("usage_by_Month.png", plot = last_plot(), width = 8, height = 6)

#usage by Hour
ggplot(hourly_analysis, aes(x = hour, y = total_rides, fill = member_casual)) +
  geom_line(stat = "identity", position = "identity") +
  labs(title = "Rides by Hour", x = "Hour", y = "Number of Rides") +
  theme_minimal()

ggsave("usage_by_Hour.png", plot = last_plot(), width = 8, height = 6)