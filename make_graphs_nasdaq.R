source("fred_and_charts.R")

# load key
key <- readChar(con = "api_key",nchars = 200)

# get series
WageSalaryShareGDI <- GetFredSeries(api_key = key, series_id = "W270RE1A156NBEA")
LeaversAsPercentOfUnemployed <- GetFredSeries(api_key = key, series_id = "LNS13023706")
AverageWeeksUnemployed <- GetFredSeries(api_key = key, series_id = "LNU03008275")
NewEntrantsAsPercentUnemployed <- GetFredSeries(api_key = key, series_id = "LNS13023570")
PerUnemployedLess5 <- GetFredSeries(api_key = key, series_id = "LNS13008397")
PerUnemployedLess5to14 <- GetFredSeries(api_key = key, series_id = "LNS13025701")
PerUnemployedLess15to26 <- GetFredSeries(api_key = key, series_id = "LNS13025702")
PerUnemployedLessMore27 <- GetFredSeries(api_key = key, series_id = "LNU03025703")

# Stack the unemployment statistics
Stack <- cbind(PerUnemployedLess5,PerUnemployedLess5to14,PerUnemployedLess15to26,PerUnemployedLessMore27)
names(Stack) <- c("Less Than 5 Weeks","5 to 14 Weeks","15 to 26 Weeks","More Than 27 Weeks")
Stack <- Stack[,1:3]


makeChart(series = WageSalaryShareGDI,
          title = "Wages as a Percentage of Gross Domestic Income",
          ylabel = "Wages as a Percentage of GDI",
          sourcetext = "Source: Bureau of Economic Analysis",
          filename = "WageSalaryShareGDI.png",
          ypt = 0.42,
          axisadj = 100,
          axistype=percent,
          startdatestring='1989-01-01')

makeChart(series = LeaversAsPercentOfUnemployed,
          title = "Leavers as a Percentage of All Unemployed",
          ylabel = "Leavers as Percentage Unemployed",
          sourcetext = "Source: Bureau of Labor Statistics",
          filename = "LeaversAsPercentOfUnemployed.png",
          ypt = 0.05,
          axisadj = 100,
          axistype=percent)

makeChart(series = NewEntrantsAsPercentUnemployed,
          title = "New Entrants as a Percentage of All Unemployed",
          ylabel = "New Entrants as Percentage Unemployed",
          sourcetext = "Source: Bureau of Labor Statistics",
          filename = "NewEntrantsAsPercentUnemployed.png",
          ypt = 0.05,
          axisadj = 100,
          axistype=percent)

makeChart(series = AverageWeeksUnemployed,
          title = "Average Unemployment Duration",
          ylabel = "Weeks",
          sourcetext = "Source: Bureau of Labor Statistics",
          filename = "AverageWeeksUnemployed.png",
          ypt = 5,
          axisadj = 1,
          axistype=waiver())

UnemploymentDeviationFromNaturalRate

makeChart2(series = Stack,
           title = "Unemployed by Duration of Unemployment",
           ylabel = "Percent of Unemployed",
           sourcetext = "Source: Bureau of Labor Statistics",
           filename = "Stack.png",
           ypt = 0.03,
           axisadj = 100,
           axistype=percent)