install.packages("ggplot2")
install.packages()
library(ggplot2)
library(scales)
library(tidyr)

chol <- read.csv("D:/src/python/pydriller/author_intervals1.csv", header = TRUE, )
df <- data.frame(x = chol$Interval)
p  <- ggplot(df, aes(x)) + stat_ecdf()
pg <- ggplot_build(p)$data[[1]]
p1 <- ggplot(pg, aes(x = x/60/60/24, y = 1-y))
pg1 <- ggplot_build(p1)$data[[1]]
ggplot(pg1, aes(x, y))+ scale_x_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000, 10000), labels = expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4)) + scale_y_log10(breaks = c(0.001, 0.01, 0.1, 1), labels = expression(10^-3, 10^-2, 10^-1, 10^0)) + geom_step() + xlab("Commit Interval (Days)") + ylab("Complementary CDF")
quantile(chol$Interval/60/60/24, 0.90)

prod <- read.csv("D:/src/python/pydriller/prod.csv", header = TRUE)
df <- data.frame(productivity = prod$NCommits, teamsize = prod$TeamSize)
p <- ggplot(data = df, aes(teamsize, productivity))
p + geom_point() + xlab("Team Size") + ylab("Productivity")

chol <- read.csv("D:/src/python/pydriller/interval1.csv", header = TRUE, )
df <- data.frame(x = chol$Interval)
p  <- ggplot(df, aes(x)) + stat_ecdf()
pg <- ggplot_build(p)$data[[1]]
ggplot(pg, aes(x = x/60/60/24, y = 1-y )) + geom_step()
+scale_y_log10()+scale_x_log10()
quantile(chol$Interval/60/60/24, 0.90)

