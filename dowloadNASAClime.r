#the function requires

library(RCurl)
library(utils)
library(RJSONIO)
library(parallel)
library(data.table)

# call working directory

setwd('/home/sergio/clima')

#  call spatial point data in this case is data.table
dt_points<-read.table('dt_points.txt', sep=';', header=T)

# Create the links for the download. its important here to define the data types: userscommunity in this example is AG with parameters PRECTOT,RH2M,T2M,T2M_MAX,T2M_MIN,T2M_RANGE and time
# startDate=20190101  and endDate=20200624 latitude (lat) and longitude (lon) column in data base


LINK<-sapply(1:618146, function(i) paste0('https://power.larc.nasa.gov/cgi-bin/v1/DataAccess.py?request=execute&identifier=SinglePoint&parameters=PRECTOT,RH2M,T2M,T2M_MAX,T2M_MIN,T2M_RANGE&startDate=20190101&endDate=20200624&userCommunity=AG&tempAverage=DAILY&outputList=JSON&lat=', dt_points[i,1], '&lon=', dt_points[i,2],'&user=anonymous'))
nam.file<-sapply(1:618146, function(i) paste(paste('AG',i,sep='_'), 'csv', sep='.'))

#Create the function

f<-function(i) {
print(i)
L<-fromJSON(LINK[i])
sal<-data.frame(coord=t(L[[1]][[1]][[1]]$coordinates),fec=names(L[[1]][[1]][[2]][[1]][[1]]),data.frame(L[[1]][[1]][[2]][[1]]))
write.csv(sal, file=nam.file[i],row.names=F)

		       }
 
 # call working directory where will you save the files
           
           setwd('/home/sergio/clima/SALIDA_todos3')
           
## Execute the while loop

nn<-618147
i<-1
while(i<nn) { 

n_cores <- 4# number of cores for parallel processing
cl <- try(makeCluster(n_cores), silent=TRUE)
error<-try(clusterEvalQ(cl=cl, library(RJSONIO)), silent=TRUE)
error<-try(clusterExport(cl,list('LINK', 'nam.file')), silent=TRUE)
error<-try(parSapply(cl,vec2,FUN=f), silent=TRUE)
stopCluster(cl)


	if(class(error)=='try-error' || class(cl)[1] == 'try-error') {
					ll<-list.files()
					if(length(ll)==0) { vec2=618146} else {
					vec<-as.numeric(unlist(strsplit(do.call(rbind, strsplit(ll,'_'))[,2], '.csv')))
					vec2<-c(1:618146)[-vec]			
											}
					i<-length(ll)
					}    else { i <- i+1 }

	print(i)
		}
           
  
  ##### Builds data base with files dowloads
  
           
           
           
           
           
           
           
           

