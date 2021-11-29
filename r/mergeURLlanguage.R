repos <- read.csv(file = '/Users/blouderchung/Desktop/ecs 260/ecs260brookslaw-master/prod1.csv')
langs <- read.csv(file = '/Users/blouderchung/Desktop/ecs 260/ecs260brookslaw-master/apache.csv')
repoURL <- unique(repos[1]) #get different repo URLs
# repos$language <- langs$Language[repos$Repository == langs$URL ]
colnames(repos)[1] <- 'URL'

newrepos <- merge(repos, langs, by='URL')
temp <- newrepos[-5]
write.csv(temp,file='/Users/blouderchung/Desktop/ecs 260/ecs260brookslaw-master/wizlantest.csv')
# df1$value <- df2$value[match(df1$name,df2$name)]
rm(list=ls())

