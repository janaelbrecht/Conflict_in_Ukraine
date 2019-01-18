library(tidyverse)
library(RColorBrewer)
library(ggthemes)
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
                               side.b.name = as.factor(side.b.name),
                               conflict.name = as.factor(conflict.name)
                               )

#statistics
print(mean(Conflicts_Ukraine$total.deaths))
print(sum(Conflicts_Ukraine$total.deaths))

#frequency table
table_by_actors <- table(Conflicts_Ukraine$side.a.name, Conflicts_Ukraine$side.b.name)
table_by_actors


#plot of deaths by date 
ggplot(data = Conflicts_Ukraine) +
  geom_point(aes(x=early.estimate.of.date, y=total.deaths, color=type.of.violence))

#seeing whether the early and late estimate of date correspond
Datesame <- Conflicts_Ukraine$early.estimate.of.date == Conflicts_Ukraine$late.estimate.of.date 
Conflicts_Ukraine$Datesame <- Datesame

ggplot(data = Conflicts_Ukraine) +
  geom_point(aes(x=early.estimate.of.date, y=late.estimate.of.date, color=Datesame)) +
  labs (x='Earliest estimate of date', y='Latest estimate of date', color='Dates are the same') +
  ggtitle('Accuracy of estimated dates of violent events') +
  theme(legend.text=element_text(size=8), legend.title = element_text(size = 8), legend.position = 'bottom')

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

#plotting the type of conflict before and after elections
ggplot(data = Conflicts_Ukraine) +
  geom_bar(aes(x=side.b.name, fill=conflict.name), stat="count", position='fill') +
  scale_fill_brewer(palette="Set2") +
  facet_grid(.~after_election) + 
  labs(y='percentage of conflicts', x='Adversary of the government', fill='Conflict') +
  theme(legend.text=element_text(size=8), axis.text.x = element_text(angle = 90, hjust = 1))

#per month
Conflicts_Ukraine_months <- Conflicts_Ukraine %>%
  mutate(
    month = format(early.estimate.of.date, format='%Y-%m-01'),
    month = ifelse(month == '2014-05-01' & after_election==T, '2014-05-15', month),
    month = as.Date(month)
  )

mean_deaths <- Conflicts_Ukraine_months %>%
  group_by(month) %>%
  summarise(mean(total.deaths), na.rm=TRUE)

mean_deaths <- transform(mean_deaths,
                         Mean_deaths = mean(total.deaths)
                         )
mean_deaths$mean_total_deaths = mean_deaths$`mean(total.deaths)`


Conflicts_Ukraine$month <- as.character(Conflicts_Ukraine$early.estimate.of.date, format="%Y-%m")
Conflicts_Ukraine$monthfactor <- as.factor(Conflicts_Ukraine$month)

ggplot() +
  geom_bar(data = Conflicts_Ukraine_months, aes(x=month), fill='darkblue', stat="count") +
  geom_vline(xintercept=date_election, color='red') +
  labs(y='Number of violent events', x='Month') +
  ggtitle('Violence in Ukraine before and after the 2014 elections') +
  theme_classic() +
  theme(legend.text=element_text(size=8), axis.text.x = element_text(angle = 90, hjust = 1))

ggplot() +
  geom_area(data = mean_deaths, aes(x=month, y=mean_total_deaths)) +
  geom_vline(xintercept=date_election, color='red') +
  ggtitle('Fatality of violent events in Ukraine') + 
  labs(y='Mean number of deaths per violent event', x='Month') +
  theme(legend.text=element_text(size=8), axis.text.x = element_text(angle = 90, hjust = 1))

