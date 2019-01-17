library(tidyverse)
install.packages("RColorBrewer")

#Conflict Ukraine as df
Conflicts_Ukraine <- read.csv('Ukraine.csv', stringsAsFactors = FALSE)

#adjusting datatypes 
head(Conflicts_Ukraine)
Conflicts_Ukraine <- transform(Conflicts_Ukraine, 
                               year = as.integer(year),
                               early.estimate.of.date = as.Date(early.estimate.of.date, format="%Y-%m-%d"),
                               late.estimate.of.date = as.Date(late.estimate.of.date, format="%Y-%m-%d"),
                               active.year = as.logical(active.year),
                               type.of.violence = as.factor(type.of.violence),
                               side.a.name = as.factor(side.a.name),
                               side.b.name = as.factor(side.b.name)
                               )

print(mean(Conflicts_Ukraine$total.deaths))

#plot of deaths by date 
ggplot(data = Conflicts_Ukraine) +
  geom_point(aes(x=early.estimate.of.date, y=total.deaths, color=type.of.violence))

#seeing whether the early and late estimate of date correspond
Datesame <- Conflicts_Ukraine$early.estimate.of.date == Conflicts_Ukraine$late.estimate.of.date 
Conflicts_Ukraine$Datesame <- Datesame

ggplot(data = Conflicts_Ukraine) +
  geom_point(aes(x=early.estimate.of.date, y=late.estimate.of.date, color=Datesame))

#determining whether something happened before or after elections
date_election <- "2014-05-25"
date_election <- as.Date(date_election, format="%Y-%m-%d")
Conflicts_Ukraine$after_election <- as.factor(Conflicts_Ukraine$early.estimate.of.date > date_election)     
#giving better names 
levels(Conflicts_Ukraine$after_election)[levels(Conflicts_Ukraine$after_election)=="TRUE"] <- "After elections"
levels(Conflicts_Ukraine$after_election)[levels(Conflicts_Ukraine$after_election)=="FALSE"] <- "Before elections"

#shortening names of side a 
levels(Conflicts_Ukraine$side.a.name)
levels(Conflicts_Ukraine$side.a.name) <- list('Government'="Government of Ukraine", 'Independence fighters'="Supporters of independence for Eastern Ukraine")
levels(Conflicts_Ukraine$side.b.name)



library(RColorBrewer)

#plotting who causes conflicts before and after elections 
ggplot(data = Conflicts_Ukraine) +
  geom_bar(aes(x=side.a.name, fill=side.b.name), stat="count", position='fill') +
  scale_fill_brewer(palette="Set3") +
  facet_grid(.~after_election) + 
  labs(y='percentage of conflicts', x='side A', fill='side B') +
  theme(legend.text=element_text(size=8), axis.text.x = element_text(angle = 90, hjust = 1))

Conflicts_Ukraine$month <- as.character(Conflicts_Ukraine$early.estimate.of.date, format="%m-%Y")
Conflicts_Ukraine$monthfactor <- as.factor(Conflicts_Ukraine$month)
