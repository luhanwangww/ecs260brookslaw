#different grouping NCommits
#small:'/smallrepo.csv' ,  length = 7304
#mid:'/midrepo.csv' , length = 98519
#large:'/largerepo.csv', length = 51389

repos <- read.csv(file = '/Users/blouderchung/Desktop/projectfolder/ecs260brookslaw/largerepo.csv')
head(repos)
#len(repos) = 170925 rows

summary(repos$Code_Churn)
summary(repos$Code_Churn/repos$TeamSize)
repos$Code_Churn[repos$Code_Churn <= 1] <- NA
cleanedrepos <-repos[complete.cases(repos$Code_Churn),]
cleanedrepos$SLOClog = log(cleanedrepos$Code_Churn)
rm(repos)

boxplot(cleanedrepos$Code_Churn)
boxplot(cleanedrepos$Code_Churn/cleanedrepos$TeamSize)



boxplot(cleanedrepos$SLOClog)
summary(cleanedrepos$SLOClog)
boxplot(cleanedrepos$TeamSize, main = "LargeSize Repo Teamsize")
plot(SLOClog ~ TeamSize, data = cleanedrepos,main = "SLOClog~TeamSize")
boxlang = boxplot(SLOClog ~ Language, data = cleanedrepos,main = "SLOClog~Language")

library(ggplot2)
(prelim_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = Code_Churn)) +
    geom_point() +
    geom_smooth(method = "lm"))
(colour_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = SLOClog, colour = Language)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))
(split_plot <- ggplot(aes(TeamSize, SLOClog), data = cleanedrepos) + 
    geom_point() + 
    facet_wrap(~ Language) + # create a facet for each language
    xlab("TeamSize") + 
    ylab("SLOClog"))

#comparing linear models
templm <- lm(Code_Churn ~ TeamSize, data = cleanedrepos)
basic.lm.tz <- lm(SLOClog ~ TeamSize, data = cleanedrepos)
summary(templm)
summary(basic.lm.tz)
#thus the need of logging SLOC

basic.lm.tzage <- lm(SLOClog ~ TeamSize + WindowID, data = cleanedrepos)
basic.lm.full <- lm(SLOClog ~ TeamSize + WindowID + Language, data = cleanedrepos)
cc.full <- lm(Code_Churn ~ TeamSize + WindowID + Language, data = cleanedrepos)
anova(basic.lm.tz,basic.lm.tzage)#tzage is better
anova(basic.lm.tzage,basic.lm.full)#full is better
summary(cc.full)
summary(basic.lm.tzage)
summary(basic.lm.full)
tab_model(basic.lm.full)
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)               7.9311741  0.0945217  83.909  < 2e-16 ***
#   TeamSize                  0.0131235  0.0001173 111.909  < 2e-16 ***
#   WindowID                 -0.0017492  0.0000271 -64.552  < 2e-16 ***
# Residual standard error: 2.473 on 165212 degrees of freedom
# Multiple R-squared:  0.1268,	Adjusted R-squared:  0.1266 
# F-statistic: 666.5 on 36 and 165212 DF,  p-value: < 2.2e-16
plot(basic.lm.full, which = 1)#residual plot
plot(basic.lm.full, which = 2)#qqplot
library(sjPlot)
library(lme4)

#model with fixed slope for teamsize
model.full <- lmer(SLOClog ~ TeamSize + WindowID + (1|Language) , data=cleanedrepos, REML=FALSE)
model.tz <- lmer(SLOClog ~ TeamSize + (1|Language) , data=cleanedrepos, REML=FALSE)
model.fullest  <- lmer(SLOClog ~ TeamSize + WindowID + (1|Repository) + (1|Language) , data=cleanedrepos, REML=FALSE)
#null model to compare the effect of teamsize
model.null <- lmer(SLOClog ~ (1|Language), data=cleanedrepos, REML=FALSE)
summary(model.null)
summary(model.fullest)
tab_model(model.fullest)
anova(model.null,model.tz)
anova(model.full,model.tz)
#full model with random slope
model.random.full <- lmer(SLOClog ~ TeamSize + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)
model.random.fuller <- lmer(SLOClog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)

#anova mixed models
tab_model(model.full)
tab_model(model.random.full)
tab_model(model.random.fuller)
anova(model.full,model.random.full)
anova(model.random.full,model.random.fuller)
## the AIC of model.random.fuller is the smallest
# NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language) is the best model
# among the compared ones

AIC(basic.lm.full,model.random.full)
# use REML = TRUE as the final model
# model.final <- lmer(SLOClog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=TRUE)
model.final <- lmer(SLOClog ~ TeamSize + WindowID + (1|Repository) + (1|Language) , data=cleanedrepos, REML=TRUE)
plot(model.final, which = 1)#residual plot
plot(model.final, which = 2)#qqplot
summary(model.final)
tab_model(model.final,p.style = "stars", digits = 3)
# rm(list=ls())

