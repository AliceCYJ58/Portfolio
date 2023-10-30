#Final Project
#Alice Cai
#US and World Map for Density
#2022/12/10

setwd("~/Desktop/BIS 679/FinalProject")
library("readxl")
library(dplyr)
library(ggplot2)
library(devtools)
library(stringr)
library(maps)
library(mapdata)
library(ggmap)
location <- read_excel("Location_Glioma_registry_2022.xlsx", col_names =FALSE)
states<-map_data("state")
world <- map_data("world")

#Clean data to only the second column, without NAs 
loc_1 <- na.omit(location[,2])

#Changing all the names to consistent ones
typo_1 <- c("Australia","NSW, Australia","Queensland Australia")
loc_1[loc_1$...2 %in% typo_1,] <- "Australia"
typo_2 <- c("Bermuda","BERMUDA")
loc_1[loc_1$...2 %in% typo_2,] <- "Bermuda"
typo_3 <- c("Canada","CANADA","Ontario Canada")
loc_1[loc_1$...2 %in% typo_3,] <- "Canada"
typo_4 <- c("CA","Ontario, CA")
loc_1[loc_1$...2 %in% typo_4,] <- "CA"
typo_5 <- c("England","London, UK","Manchester, UK","Sussex, UK","UK","United Kingdom")
loc_1[loc_1$...2 %in% typo_5,] <- "UK"
typo_6 <- c("DE","Delaware")
loc_1[loc_1$...2 %in% typo_6,] <- "DE"
typo_7 <- c("OR","Oregon")
loc_1[loc_1$...2 %in% typo_7,] <- "OR"
typo_8 <- ("Hong Kong")
loc_1[loc_1$...2 %in% typo_8,] <- "China"
typo_9 <- ("COLOMBIA")
loc_1[loc_1$...2 %in% typo_9,] <- "Colombia"

#Check consistency
table(loc_1)
table(world$region)
table(states$region)

#Create density number for states and combine with initial dataset
US_Den <- c(3,7,1,16,7,23,2,0,8,6,1,12,3,1,3,2,2,27,9,367,8,9,1,5,2,1,1,39,6,3,
            27,4,0,14,1,5,11,23,1,1,2,14,2,8,5,11,1,6,1)
US_R<-names(table(states$region))
density_US<-data.frame(region=US_R, density=as.numeric(US_Den))
us_map<-inner_join(states, density_US, by="region")

#Create for loop for density labels
for (i in 1:nrow(us_map)){
  if (us_map[i,7] == 0){
    us_map[i,8] = "NA"
  }
  else if (us_map[i,7] <= 5){
    us_map[i,8] = "1-5"
  }
  else if (us_map[i,7] <= 10){
    us_map[i,8] = "6-10"
  }
  else if(us_map[i,7] <= 20){
    us_map[i,8] = "11-20"
  }
  else if (us_map[i,7] <= 50){
    us_map[i,8] = "21-50"
  }
  else {
    us_map[i,8] = ">50"
  }
 
}
colnames(us_map)[8] <- "Participation"

#Plot US map
#US Mainland doesn't contain Alaska and Hawaii
US_plot<-ggplot(data = us_map, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = NA) 

US_plot +
  geom_polygon(data = us_map, aes(fill = Participation), color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_void() +
  ggtitle("LGG Registry Participant Place of Residence in US Mainland")


#Firstly delete all states data
loc_2 <- loc_1
loc_2$N <- nchar(loc_2$...2)
loc_World <- subset(loc_2, N!=2)

#Create density number for the world map and combine with initial dataset
den_world <- table(loc_World$...2)
den_world <- as.data.frame(den_world)
colnames(den_world)[1] <- "region"
USA_d <- data.frame(c("USA","UK"),c(712,9))
names(USA_d) <- c("region","Freq")
den_world_new <- rbind(den_world, USA_d)

#Create for loop for density labels
table(world_map$Freq)
for(j in 1: nrow(den_world_new)){
  if (den_world_new[j,2] <= 5){
    den_world_new[j,3] = "1-5"
  }
  else if(den_world_new[j,2] <= 10){
    den_world_new[j,3] = "6-10"
  }
  else if (den_world_new[j,2] <= 20){
    den_world_new[j,3] = "11-20"
  }
  else{
    den_world_new[j,3] = ">20"
  }
}
colnames(den_world_new)[3] <- "Participation"
world_map<-merge(world, den_world_new, by=c("region"),all = TRUE)
world_map <- world_map[,-6]
world_map <- world_map[order(world_map$order),]

#Plot World Map
world_1 <- world[,-6]
World_plot<-ggplot(data = world_map, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "blue", fill = NA) 

World_plot +
  geom_polygon(data = world_map, aes(fill = Participation), color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_void() +
  ggtitle("Worldwide LGG Registry Participant Place of Residence")
  

