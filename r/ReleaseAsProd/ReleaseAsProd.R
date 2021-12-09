# smallrelease: 387->346
# midrelease: 9346-> 4678
# largerelease: 3045

releaserepos <- read.csv(file = '/Users/blouderchung/Desktop/projectfolder/ecs260brookslaw/largerelease.csv')
head(releaserepos)
summary(releaserepos$ReleaseInterval)
# releaserepos$Language[releaserepos$Language == ""] <- NA
releaserepos$ReleaseInterval = releaserepos$ReleaseInterval/60/60
releaserepos$ReleaseInterval[releaserepos$ReleaseInterval <= 1] <- NA
cleanedrepos <-releaserepos[complete.cases(releaserepos$ReleaseInterval),]
cleanedrepos$ReleaseIntervallog = log(cleanedrepos$ReleaseInterval)
summary(cleanedrepos$ReleaseInterval)
summary(cleanedrepos$ReleaseIntervallog)
plot1 = plot(ReleaseInterval ~ TeamSize, data = cleanedrepos,main = "ReleaseInterval~TeamSize")
plot2 = plot(ReleaseIntervallog ~ TeamSize, data = cleanedrepos,main = "ReleaseIntervallog~TeamSize")
plot3 = boxplot(ReleaseInterval ~ Language, data = cleanedrepos,main = "ReleaseInterval~Language")
boxplot(cleanedrepos$ReleaseInterval)
library(ggplot2)
(prelim_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = ReleaseInterval), main = "ReleaseInterval~TeamSize") +
    geom_point() +
    geom_smooth(method = "lm"))
(colour_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = ReleaseInterval, colour = Language)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))
(split_plot <- ggplot(aes(TeamSize, ReleaseInterval), data = cleanedrepos) + 
    geom_point() + 
    facet_wrap(~ Language) + # create a facet for each language
    xlab("TeamSize") + 
    ylab("SLOClog"))

releaseTS<- lm(ReleaseInterval ~ TeamSize, data = cleanedrepos)
releaseTSlog <- lm(ReleaseIntervallog ~ TeamSize, data = cleanedrepos)
releaseTWL <- lm(ReleaseIntervallog ~ TeamSize + WindowID + Language, data = cleanedrepos)

summary(releaseTS)
summary(releaseTSlog)
summary(releaseTWL)
anova(releaseTS,releaseTW)#TW is better
anova(releaseTW,releaseTWL)#TWL is better
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)              13.9742804  0.3783385  36.936  < 2e-16 ***
#   TeamSize                  0.0069853  0.0007066   9.885  < 2e-16 ***
#   WindowID                 -0.0072357  0.0001567 -46.166  < 2e-16 ***
#   Residual standard error: 3.635 on 12734 degrees of freedom
# Multiple R-squared:  0.312,	Adjusted R-squared:  0.3105 
# F-statistic: 206.2 on 28 and 12734 DF,  p-value: < 2.2e-16


library(sjPlot)
library(lme4)
#model with fixed slope for teamsize
rl.lmer.fixed <- lmer(ReleaseIntervallog ~ TeamSize + WindowID + (1|Language) , data=cleanedrepos, REML=FALSE)
rl.lmer.tz <- lmer(ReleaseInterval ~ TeamSize + (1|Language) , data=cleanedrepos, REML=FALSE)

#null model to compare the effect of teamsize
rl.null.fixed <- lmer(ReleaseInterval ~ (1|Language), data=cleanedrepos, REML=FALSE)

anova(rl.null.fixed,rl.lmer.tz)
anova(rl.lmer.tz,rl.lmer.fixed)
summary(rl.lmer.fixed)
tab_model(rl.lmer.fixed)# conditional R2 = 0.3
tab_model(rl.lmer.tz)
#full model with random slope
rl.random.full <- lmer(ReleaseIntervallog ~ TeamSize + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)
rl.random.fuller <- lmer(ReleaseIntervallog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)

model.fullest  <- lmer(ReleaseIntervallog ~ TeamSize + WindowID + (1|Repository) , data=cleanedrepos, REML=FALSE)
summary(model.fullest)
tab_model(model.fullest,p.style = "stars")
#anova mixed models
# anova(model.null,model.full)
anova(rl.lmer.fixed,rl.random.full)
anova(rl.lmer.fixed,rl.random.fuller)
tab_model(rl.random.full)
tab_model(rl.random.fuller)
## the AIC of model.random.fuller is the smallest


# rm(list=ls())

