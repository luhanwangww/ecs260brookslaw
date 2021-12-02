#best model:  NCommitlog ~ TeamSize + WindowID + (1|Language) 
repos <- read.csv(file = '/Users/ecs 260/ecs260brookslaw-master/test_prod.csv')
head(repos)

# length(repos[,1]) = 170925
repos$NCommitslog = log(repos$NCommits)
# length(cleanedrepos[,1]) = 166593, after dropping rows(Language == “”)
repos$Language[repos$Language == ""] <- NA
cleanedrepos <-repos[complete.cases(repos$Language),]
rm(repos)

# comparing the boxplot of before-after logging NCommits, thus the need of logging
box_ncom = boxplot(cleanedrepos$NCommits,main = "NCommits")
box_ncomlog = boxplot(cleanedrepos$NCommitslog,main = "NCommitslog")
summary(cleanedrepos$NCommitslog)
box1 = boxplot(NCommitslog ~ TeamSize, data = cleanedrepos,main = "NCommitslog~TeamSize")
box2  = boxplot(NCommitslog ~ WindowID, data = cleanedrepos,main = "NCommitslog~WindowID")
box3 = boxplot(NCommitslog ~ Language, data = cleanedrepos,main = "NCommitslog~Language")

library(ggplot2)
(prelim_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = NCommitslog)) +
    geom_point() +
    geom_smooth(method = "lm"))
(colour_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = NCommitslog, colour = Language)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))
(split_plot <- ggplot(aes(TeamSize, NCommitslog), data = cleanedrepos) + 
    geom_point() + 
    facet_wrap(~ Language) + # create a facet for each language
    xlab("TeamSize") + 
    ylab("NCommitslog"))

#comparing linear models
templm <- lm(NCommits ~ TeamSize, data = cleanedrepos)
basic.lm.tz <- lm(NCommitslog ~ TeamSize, data = cleanedrepos)
basic.lm.tzage <- lm(NCommitslog ~ TeamSize + WindowID, data = cleanedrepos)
basic.lm.tzlan <- lm(NCommitslog ~ TeamSize + Language, data = cleanedrepos)
basic.lm.full <- lm(NCommitslog ~ TeamSize + WindowID + Language, data = cleanedrepos)

anova(basic.lm.tz,basic.lm.tzage)#tzage is better
anova(basic.lm.tzage,basic.lm.tzlan)#tzlan is better
anova(basic.lm.tzlan,basic.lm.full)#fll is better

summary(basic.lm.full)
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)               2.584e+00  4.534e-02  56.978  < 2e-16 ***
#   TeamSize                  8.098e-03  5.634e-05 143.744  < 2e-16 ***
#   WindowID                 -5.261e-04  1.298e-05 -40.536  < 2e-16 ***
#   
# Residual standard error: 1.189 on 166556 degrees of freedom
# Multiple R-squared:   0.16,	Adjusted R-squared:  0.1598 
# F-statistic: 881.2 on 36 and 166556 DF,  p-value: < 2.2e-16

plot(basic.lm.full, which = 1)#residual plot
plot(basic.lm.full, which = 2)#qqplot

####conclusion:  c(TeamSize,WindowID,Language) is stronger, 
#however, the effect of Language should be set as random effect 
#according to the definition
####


##
library(lme4)
#model with fixed slope for teamsize
model.full <- lmer(NCommitslog ~ TeamSize + WindowID + (1|Language) , data=cleanedrepos, REML=FALSE)
model.tz <- lmer(NCommitslog ~ TeamSize + (1|Language) , data=cleanedrepos, REML=FALSE)
model.age <- lmer(NCommitslog ~ WindowID + (1|Language) , data=cleanedrepos, REML=FALSE)
#null model to compare the effect of teamsize
model.null <- lmer(NCommitslog ~ (1|Language), data=cleanedrepos, REML=FALSE)
anova(model.age,model.null)
anova(model.null,model.tz)
anova(model.tz,model.age)
anova(model.full,model.age)
#full model with random slope
model.random.full <- lmer(NCommitslog ~ TeamSize + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)
model.random.fuller <- lmer(NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)
#anova mixed models
anova(model.null,model.full)
anova(model.full,model.random.full)
anova(model.full,model.random.fuller)

# NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language) is the best model
# among the compared ones

AIC(basic.lm.full,model.random.full)
# use REML = TRUE as the final model
model.final <- lmer(NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=TRUE)
summary(model.final)

#case study for single language
langs = box3[["names"]]
subrepo = cleanedrepos[cleanedrepos$Language == langs[24], ]# langs[24] == "Python"
subbox_logncom = boxplot(subrepo$NCommitslog,main="NCommitslog~TeamSize in Python")
plot(NCommitslog~TeamSize, data=subrepo,main=langs[24])
sublm <- lm(NCommitslog ~ TeamSize + WindowID, data=subrepo)  
summary(sublm)
#shows that in Python's case, there is also a positive relationship
#between TeamSize and NCommitslog
plot(sublm)

rm(list=ls())
