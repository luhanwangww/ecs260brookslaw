releaserepos <- read.csv(file = '/Users/blouderchung/Desktop/ecs 260/ecs260brookslaw-master/test_release.csv')
head(releaserepos)
releaserepos$ReleaseInterval = releaserepos$ReleaseInterval/60/60/24
releasebox = boxplot(releaserepos$ReleaseInterval/60/60/24)
mean = mean(releaserepos$ReleaseInterval)
releaseLM <- lm(log(ReleaseInterval) ~ log(TeamSize) + WindowID, data = releaserepos)
print(releaseLM)
summary(releaseLM)
