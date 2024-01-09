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
nc_data = nc_open('C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2006_2011.nc')  

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
soil_temp = t(soil_temp)
soil_temp = replace(soil_temp, is.na(soil_temp), 0)
soil_temp = soil_temp[,1]+soil_temp[,2]

soil_mois = ncvar_get(nc_data,"swvl1")
soil_mois = t(soil_mois)
soil_mois = replace(soil_mois, is.na(soil_mois), 0)
soil_mois = soil_mois[,1]+soil_mois[,2]

# Final vector ####
final_array = as.data.frame(cbind(Year,Month,Day,Hour,soil_temp,soil_mois))
#write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2000_2005.csv')
write.csv(final_array,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2006_2011.csv')

# Get historical data ####

#SP01_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2023_2018.csv",dec=".")
#SP01_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2012_2017.csv",dec=".")
#SP01_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2006_2011.csv",dec=".")
#SP01_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_2000_2005.csv",dec=".")

#SP01_temp = rbind(SP01_1,SP01_2,SP01_3,SP01_4)

SP05_1    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2023_2018.csv",dec=".")
SP05_2    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2012_2017.csv",dec=".")
SP05_3    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2006_2011.csv",dec=".")
SP05_4    = read.csv("C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP05/SP05_2000_2005.csv",dec=".")

SP05_temp = rbind(SP05_3,SP05_4)

final_mean = SP05_temp %>% group_by(Month,Day) %>% 
  summarise(mean_temp=mean(as.numeric(soil_temp)),
            mean_mois=mean(as.numeric(soil_mois)),
            .groups = 'drop')

#write.csv(final_mean,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/SP01_mean_2000_2023.csv')
plot(final_mean$mean_temp)
plot(final_mean$mean_mois)

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
SP01_total  = SP01_total %>% mutate(Psi  = -0.1450377377*WP)
write.csv(SP01_total,'C:/luciana_datos/UCI/Project_14 (Anna)/DEMENT_gradcatch/raw_data/SP01/climate.csv')
plot(SP01_total$Temp)
plot(SP01_total$Psi)


