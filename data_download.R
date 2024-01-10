# Install necessary packages ####
#install.packages('rNOMADS')
#install.packages('ncdf4')
#install.packages('chron')

# Call additional packages ####
library('rNOMADS')
library("raster")
library("ncdf4")
library(chron)
library(lattice)
library(RColorBrewer)
library(dplyr)

# Open data ####
#nc_data = nc_open('C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2000_2005.nc')  
#nc_data = nc_open('C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2018_2020.nc')  
#nc_data = nc_open('C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2020.nc')  
#nc_data = nc_open('C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_2012_2017.nc')  
nc_data = nc_open('C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2017.nc')  

print(nc_data)

# Extract Longitud and Latitud ####
lon = ncvar_get(nc_data,"longitude")
lon
lat = ncvar_get(nc_data,"latitude")
lat

# Extract Time ####
time    = ncvar_get(nc_data,"time")
tunits  = ncatt_get(nc_data,"time","units")
tustr   = strsplit(tunits$value, " ")
tdstr   = strsplit(unlist(tustr)[3], "-")
tmonth  = as.integer(unlist(tdstr)[2])
tday    = as.integer(unlist(tdstr)[3])
tyear   = as.integer(unlist(tdstr)[1])

# Format Time vector  ####
time.final = (chron(time/24,origin=c(tmonth, tday, tyear)))
time.final

Day        = as.numeric(days(time.final))
Month      = as.numeric(months(time.final))
Year       = as.character(years(time.final))
Hour       = hours(time.final)
  
# Extract Variables ####
soil_temp = ncvar_get(nc_data,"stl1")
#soil_temp = t(soil_temp)
#soil_temp = replace(soil_temp, is.na(soil_temp), 0)
#soil_temp = soil_temp[,1]+soil_temp[,2]

soil_mois = ncvar_get(nc_data,"swvl1")
#soil_mois = t(soil_mois)
#soil_mois = replace(soil_mois, is.na(soil_mois), 0)
#soil_mois = soil_mois[,1]+soil_mois[,2]

# Final vector ####
final_array = as.data.frame(cbind(Year,Month,Day,Hour,soil_temp,soil_mois))
#write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2000_2005.csv')
#write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2018_2020.csv')
#write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2020.csv')
#write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_2012_2017.csv')
write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2017.csv')

# Get historical data ####

SP01_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2023_2018.csv",dec=".")
SP01_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2012_2017.csv",dec=".")
SP01_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2006_2011.csv",dec=".")
SP01_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2000_2005.csv",dec=".")

SP01_temp = rbind(SP01_1,SP01_2,SP01_3,SP01_4)

final_mean = SP01_temp %>% group_by(Month,Day) %>% 
  summarise(mean_temp=mean(as.numeric(soil_temp)),
            mean_mois=mean(as.numeric(soil_mois)),
            .groups = 'drop')
write.csv(final_mean,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_mean_2000_2023.csv')

SP05_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2018_2020.csv",dec=".")
SP05_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2012_2017.csv",dec=".")
SP05_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2006_2011.csv",dec=".")
SP05_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2000_2005.csv",dec=".")

SP05_temp = rbind(SP05_1,SP05_2,SP05_3,SP05_4)

final_mean = SP05_temp %>% group_by(Month,Day) %>% 
  summarise(mean_temp=mean(as.numeric(soil_temp)),
            mean_mois=mean(as.numeric(soil_mois)),
            .groups = 'drop')
write.csv(final_mean,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_mean_2000_2020.csv')

SP02_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2018.csv",dec=".")
SP02_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2019.csv",dec=".")
SP02_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2006_2011.csv",dec=".")
SP02_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2000_2005.csv",dec=".")
SP02_5    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_2020.csv",dec=".")

SP02_temp = rbind(SP02_1,SP02_2,SP02_3,SP02_4,SP02_5)

final_mean = SP02_temp %>% group_by(Month,Day) %>% 
  summarise(mean_temp=mean(as.numeric(soil_temp)),
            mean_mois=mean(as.numeric(soil_mois)),
            .groups = 'drop')

write.csv(final_mean,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_mean_2000_2020.csv')

SP04_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_2018_2020.csv",dec=".")
SP04_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_2012_2017.csv",dec=".")
SP04_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_2006_2011.csv",dec=".")
SP04_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_2000_2005.csv",dec=".")

SP04_temp = rbind(SP04_1,SP04_2,SP04_3,SP04_4)

final_mean = SP04_temp %>% group_by(Month,Day) %>% 
  summarise(mean_temp=mean(as.numeric(soil_temp)),
            mean_mois=mean(as.numeric(soil_mois)),
            .groups = 'drop')
write.csv(final_mean,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_mean_2000_2020.csv')

SP03_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2018_2020.csv",dec=".")
SP03_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2012.csv",dec=".")
SP03_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2006_2011.csv",dec=".")
SP03_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2000_2005.csv",dec=".")
SP03_5    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2013.csv",dec=".")
SP03_6    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2014.csv",dec=".")
SP03_7    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2015.csv",dec=".")
SP03_8    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2016.csv",dec=".")
SP03_9    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2017.csv",dec=".")
SP03_10   = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2021.csv",dec=".")
SP03_11   = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2022.csv",dec=".")
SP03_12   = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_2023.csv",dec=".")

SP03_temp = rbind(SP03_1,SP03_2,SP03_3,SP03_4,SP03_5,SP03_6,SP03_7,SP03_8,SP03_9,
                  SP03_10,SP03_11,SP03_12)

final_mean = SP03_temp %>% group_by(Month,Day) %>% 
  summarise(mean_temp=mean(as.numeric(soil_temp)),
            mean_mois=mean(as.numeric(soil_mois)),
            .groups = 'drop')
write.csv(final_mean,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_mean_2000_2023.csv')

# Conversion to matrix potential ####

#Saxton, K. E., Rawls, W. J., Romberger, J. S., & Papendick, R. I. (1986). 
#Estimating Generalized Soil-water Characteristics from Texture. 
#Soil Science Society of America Journal, 50(4), 1031-1036. 
#https://doi.org/10.2136/sssaj1986.03615995005000040039x

# SP01 ####
SP01_total  = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_mean_2000_2023.csv",dec=".")
sand        = 0.4695*100
clay        = 0.1575*100
A           = exp(-4.396-0.0715*clay-(4.880*10^(-4))*sand^2-(4.285*10^-5)*(sand^2)*clay)*100
B           = -3.140-0.00222*clay^2-(3.484*10^-5)*(sand^2)*clay
SP01_total  = SP01_total %>% mutate(WP = A*(mean_mois)^B)
SP01_total  = SP01_total %>% mutate(Temp = mean_temp-273)
SP01_total  = SP01_total %>% mutate(Psi  = -0.001*WP)
write.csv(SP01_total,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/climate.csv')
plot(SP01_total$Temp)
plot(SP01_total$Psi)
plot(SP01_total$mean_mois,SP01_total$Psi)

# SP05 ####
SP05_total  = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_mean_2000_2020.csv",dec=".")
sand        = 0.238*100
clay        = 0.188*100
A           = exp(-4.396-0.0715*clay-(4.880*10^(-4))*sand^2-(4.285*10^-5)*(sand^2)*clay)*100
B           = -3.140-0.00222*clay^2-(3.484*10^-5)*(sand^2)*clay
SP05_total  = SP05_total %>% mutate(WP = A*(mean_mois)^B)
SP05_total  = SP05_total %>% mutate(Temp = mean_temp-273)
SP05_total  = SP05_total %>% mutate(Psi  = -0.001*WP)
write.csv(SP05_total,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/climate.csv')
plot(SP05_total$Temp)
plot(SP05_total$Psi)
plot(SP05_total$mean_mois,SP05_total$Psi)

# SP02 ####
SP02_total  = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/SP02_mean_2000_2020.csv",dec=".")
sand        = 0.617*100
clay        = 0.06*100
A           = exp(-4.396-0.0715*clay-(4.880*10^(-4))*sand^2-(4.285*10^-5)*(sand^2)*clay)*100
B           = -3.140-0.00222*clay^2-(3.484*10^-5)*(sand^2)*clay
SP02_total  = SP02_total %>% mutate(WP = A*(mean_mois)^B)
SP02_total  = SP02_total %>% mutate(Temp = mean_temp-273)
SP02_total  = SP02_total %>% mutate(Psi  = -0.001*WP)
write.csv(SP02_total,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP02/climate.csv')
plot(SP02_total$Temp)
plot(SP02_total$Psi)
plot(SP02_total$mean_mois,SP02_total$Psi)

# SP04 ####
SP04_total  = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/SP04_mean_2000_2020.csv",dec=".")
sand        = 0.577*100
clay        = 0.1475*100
A           = exp(-4.396-0.0715*clay-(4.880*10^(-4))*sand^2-(4.285*10^-5)*(sand^2)*clay)*100
B           = -3.140-0.00222*clay^2-(3.484*10^-5)*(sand^2)*clay
SP04_total  = SP04_total %>% mutate(WP = A*(mean_mois)^B)
SP04_total  = SP04_total %>% mutate(Temp = mean_temp-273)
SP04_total  = SP04_total %>% mutate(Psi  = -0.001*WP)
write.csv(SP04_total,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP04/climate.csv')
plot(SP04_total$Temp)
plot(SP04_total$Psi)
plot(SP04_total$mean_mois,SP04_total$Psi)

# SP03 ####
SP03_total  = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/SP03_mean_2000_2023.csv",dec=".")
sand        = 0.728*100
clay        = 0.0585*100
A           = exp(-4.396-0.0715*clay-(4.880*10^(-4))*sand^2-(4.285*10^-5)*(sand^2)*clay)*100
B           = -3.140-0.00222*clay^2-(3.484*10^-5)*(sand^2)*clay
SP03_total  = SP03_total %>% mutate(WP = A*(mean_mois)^B)
SP03_total  = SP03_total %>% mutate(Temp = mean_temp-273)
SP03_total  = SP03_total %>% mutate(Psi  = -0.001*WP)
write.csv(SP03_total,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP03/climate.csv')
plot(SP03_total$Temp)
plot(SP03_total$Psi)
plot(SP03_total$mean_mois,SP03_total$Psi)
