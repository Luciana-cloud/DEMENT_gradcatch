# Install necessary packages ####
install.packages('rNOMADS')
install.packages('ncdf4')
install.packages('chron')

# Call additional packages ####
library('rNOMADS')
library("raster")
library("ncdf4")
library(chron)
library(lattice)
library(RColorBrewer)

# Open data ####
nc_data = nc_open('test.nc')  
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
tdstr.1 = strsplit(unlist(tustr)[4], "-")
thour   = as.integer(unlist(unlist(tdstr.1)))

# Format Time vector  ####
time.final = (chron(time/24,origin=c(tmonth, tday, tyear)))
time.final

Day        = as.character(days(time.final))
Month      = as.character(months(time.final))
Year       = as.character(years(time.final))
Hour       = hours(time.final)
  
# Extract Variables ####

soil_temp = ncvar_get(nc_data,"stl1")
soil_mois = ncvar_get(nc_data,"swvl1")

# Final vector ####

final_array = as.data.frame(cbind(Year,Month,Day,Hour,tmp_array,svm_array))


