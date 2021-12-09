#different grouping NCommits
#small:'/smallrepo.csv' ,  length = 7304
#mid:'/midrepo.csv' , length = 99631
#large:'/largerepo.csv', length = 51527
cleanedrepos <- read.csv(file = '/Users/blouderchung/Desktop/projectfolder/ecs260brookslaw/midrepo.csv')
head(cleanedrepos)

cleanedrepos$NCommitslog = log(cleanedrepos$NCommits)

# comparing the boxplot of before-after logging NCommits, thus the need of logging
box_ncom = boxplot(cleanedrepos$NCommits,main = "Medium Teams NCommits")
box_ncomlog = boxplot(cleanedrepos$NCommitslog,main = "Medium Teams NCommitslog")
summary(cleanedrepos$NCommitslog)
plot(NCommitslog ~ TeamSize, data = cleanedrepos,main = "NCommitslog~TeamSize")

library(ggplot2)
(prelim_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = NCommitslog)) +
    geom_point() +
    geom_smooth(method = "lm"))
(colour_plot <- ggplot(cleanedrepos, aes(x = TeamSize, y = NCommits, colour = Language)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))
(split_plot <- ggplot(aes(TeamSize, NCommits), data = cleanedrepos) + 
    geom_point() + 
    facet_wrap(~ Language) + # create a facet for each language
    xlab("TeamSize") + 
    ylab("NCommits"))

#comparing linear models
templm <- lm(NCommits ~ TeamSize, data = cleanedrepos)
basic.lm.tz <- lm(NCommitslog ~ TeamSize, data = cleanedrepos)
summary(templm)
summary(basic.lm.tz)

basic.lm.tzage <- lm(NCommitslog ~ TeamSize + WindowID, data = cleanedrepos)
basic.lm.full <- lm(NCommitslog ~ TeamSize + WindowID + Language, data = cleanedrepos)

anova(basic.lm.tz,basic.lm.tzage)#tzage is better
anova(basic.lm.tzage,basic.lm.full)#full is better

summary(basic.lm.full)
plot(basic.lm.full, which = 1)#residual plot
plot(basic.lm.full, which = 2)#qqplot

library(lme4)
library(sjPlot)
#model with fixed slope for teamsize
model.full <- lmer(NCommitslog ~ TeamSize + WindowID + (1|Language) , data=cleanedrepos, REML=FALSE)
model.tz <- lmer(NCommitslog ~ TeamSize + (1|Language) , data=cleanedrepos, REML=FALSE)
tab_model(model.full)
#null model to compare the effect of teamsize
model.null <- lmer(NCommitslog ~ (1|Language), data=cleanedrepos, REML=FALSE)
summary(model.full)
anova(model.null,model.tz)
anova(model.full,model.tz)
#full model with random slope
model.random.full <- lmer(NCommitslog ~ TeamSize + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)
model.random.fuller <- lmer(NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=FALSE)
tab_model(model.random.full)
model.fullest  <- lmer(NCommitslog ~ TeamSize + WindowID + (1|Repository) + (1|Language) , data=cleanedrepos, REML=FALSE)
summary(model.fullest)
tab_model(model.fullest)

# anova(model.null,model.full)
anova(model.full,model.random.full)
anova(model.random.full,model.random.fuller)
## the AIC of model.random.fuller is the smallest
# NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language) is the best model
# among the compared ones

AIC(basic.lm.full,model.random.full)
# use REML = TRUE as the final model
# model.final <- lmer(NCommitslog ~ TeamSize + WindowID + (1+TeamSize|Language), data=cleanedrepos, REML=TRUE)
# model.final <- lmer(NCommitslog ~ TeamSize + WindowID + (1|Language) , data=cleanedrepos, REML=TRUE)
model.final <- lmer(NCommitslog ~ TeamSize + WindowID + (1|Repository) + (1|Language) , data=cleanedrepos, REML=TRUE)
plot(model.final, which = 1)#residual plot
plot(model.final, which = 2)#qqplot
summary(model.final)
tab_model(model.final,p.style = "stars", digits = 3)










