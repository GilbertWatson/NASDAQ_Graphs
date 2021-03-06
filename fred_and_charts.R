# function that returns FRED data series using the FRED api
GetFredSeries <- function(api_key,
                          series_id,
                          realtime_start="",
                          realtime_end="",
                          limit="100000",
                          offset="0",
                          sort_order="asc",
                          observation_start="1776-07-04",
                          observation_end="9999-12-31",
                          units="lin",
                          frequency="",
                          aggregation_method="avg",
                          output_type="1",
                          vintage_dates="") {
  
  # set file_type argument
  file_type = "json"
  
  # check that api_key and series_id are not missing
  if(any(missing(api_key),
         missing(series_id))) {
    stop("missing api_key and series_id")
  }
  
  # load http request library
  library(httr)
  
  # make the GET request from FRED
  data <- GET(url = "http://api.stlouisfed.org/fred/series/observations",
              query = list(api_key = api_key,
                           file_type = file_type,
                           series_id = series_id,
                           realtime_start = realtime_start,
                           realtime_end = realtime_start,
                           limit = limit,
                           offset = offset,
                           sort_order = sort_order,
                           observation_start = observation_start,
                           observation_end = observation_end,
                           units = units,
                           frequency = frequency,
                           aggregation_method = aggregation_method,
                           output_type = output_type,
                           vintage_dates = vintage_dates))
  
  # check to see if the response is valid
  if(data$status_code != 200) {
    stop("Bad Request: see documentation at http://api.stlouisfed.org/docs/fred/series_observations.html")
  }
  
  # JSON to R object
  library(jsonlite)
  data <- content(data)
  
  # R list to xts object
  library(xts)
  library(plyr)
  data <- ldply(lapply(data$observations,as.data.frame))
  suppressWarnings(data <- xts(x = as.numeric(as.character(data$value)),
                               order.by = as.POSIXct(data$date)))
  
  # return the xts object
  return(data)
}

makeChart <- function (series,
                       startdatestring='1990-01-01',
                       title,
                       ylabel,
                       sourcetext="",
                       savelocation="",
                       filename,
                       ypt,
                       axisadj=100,
                       axistype=percent) {
    
    # load libraries
    library(ggplot2)
    library(latticeExtra)
    library(scales)
    
    # turn xts object into data frame for plotting
    xtsToDataFrame <- function(xtsObj) {
      df <- as.data.frame(xtsObj)
      df$Date <- as.Date(index(xtsObj))
      return(df)
    }
    
    # make recessions dataset
    recessions.df = read.table(textConnection(
      "Peak, Trough
      1857-06-01, 1858-12-01
      1860-10-01, 1861-06-01
      1865-04-01, 1867-12-01
      1869-06-01, 1870-12-01
      1873-10-01, 1879-03-01
      1882-03-01, 1885-05-01
      1887-03-01, 1888-04-01
      1890-07-01, 1891-05-01
      1893-01-01, 1894-06-01
      1895-12-01, 1897-06-01
      1899-06-01, 1900-12-01
      1902-09-01, 1904-08-01
      1907-05-01, 1908-06-01
      1910-01-01, 1912-01-01
      1913-01-01, 1914-12-01
      1918-08-01, 1919-03-01
      1920-01-01, 1921-07-01
      1923-05-01, 1924-07-01
      1926-10-01, 1927-11-01
      1929-08-01, 1933-03-01
      1937-05-01, 1938-06-01
      1945-02-01, 1945-10-01
      1948-11-01, 1949-10-01
      1953-07-01, 1954-05-01
      1957-08-01, 1958-04-01
      1960-04-01, 1961-02-01
      1969-12-01, 1970-11-01
      1973-11-01, 1975-03-01
      1980-01-01, 1980-07-01
      1981-07-01, 1982-11-01
      1990-07-01, 1991-03-01
      2001-03-01, 2001-11-01
      2007-12-01, 2009-06-01"), sep=',',
      colClasses=c('Date', 'Date'), header=TRUE)
    
    # convert series
    df <- xtsToDataFrame(series)
    df$axisadj <- axisadj
    df <- df[df$Date > as.Date(startdatestring),] # truncate
    recessions.trim = subset(recessions.df, Peak >= min(as.Date(df$Date)) )
    g <- ggplot(data=df) # make plot
    g + 
      theme_minimal() + xlab("") + 
      ylab(ylabel) + 
      ggtitle(title) + 
      scale_y_continuous(labels=axistype) + 
      geom_rect(data=recessions.trim, 
                aes(xmin=Peak, 
                    xmax=Trough, 
                    ymin=-Inf, 
                    ymax=+Inf), 
                fill="gray", alpha=0.3) + 
      theme(text = element_text(size = 30),
            axis.title.y = element_text(hjust = 1,vjust=0.3,face="bold"), 
            title = element_text(vjust = 1,size=28),
            legend.position="none") +
      geom_line(aes(x=Date,y = V1/axisadj,size=5),colour="darkcyan") + 
      annotate(geom = "text",
               x = as.Date("1997-01-01"),
               y = ypt,
               label = sourcetext,
               size = 8)
    ggsave(filename = paste0(savelocation,filename), # save
           width = 14,
           height = 12,
           units = "in")
}

  # function to make area charts out of stacked xts
makeChart2 <- function (series,
                        startdatestring='1990-01-01',
                        title,
                        ylabel,
                        sourcetext="",
                        savelocation="",
                        filename,
                        ypt,
                        axisadj=100,
                        axistype=percent) {
    
    # load libraries
    library(ggplot2)
    library(latticeExtra)
    library(scales)
    
    # turn xts object into data frame for plotting
    xtsToDataFrame <- function(xtsObj) {
      df <- as.data.frame(xtsObj)
      df$Date <- as.Date(index(xtsObj))
      return(df)
    }
    
    # make recessions dataset
    recessions.df = read.table(textConnection(
      "Peak, Trough
      1857-06-01, 1858-12-01
      1860-10-01, 1861-06-01
      1865-04-01, 1867-12-01
      1869-06-01, 1870-12-01
      1873-10-01, 1879-03-01
      1882-03-01, 1885-05-01
      1887-03-01, 1888-04-01
      1890-07-01, 1891-05-01
      1893-01-01, 1894-06-01
      1895-12-01, 1897-06-01
      1899-06-01, 1900-12-01
      1902-09-01, 1904-08-01
      1907-05-01, 1908-06-01
      1910-01-01, 1912-01-01
      1913-01-01, 1914-12-01
      1918-08-01, 1919-03-01
      1920-01-01, 1921-07-01
      1923-05-01, 1924-07-01
      1926-10-01, 1927-11-01
      1929-08-01, 1933-03-01
      1937-05-01, 1938-06-01
      1945-02-01, 1945-10-01
      1948-11-01, 1949-10-01
      1953-07-01, 1954-05-01
      1957-08-01, 1958-04-01
      1960-04-01, 1961-02-01
      1969-12-01, 1970-11-01
      1973-11-01, 1975-03-01
      1980-01-01, 1980-07-01
      1981-07-01, 1982-11-01
      1990-07-01, 1991-03-01
      2001-03-01, 2001-11-01
      2007-12-01, 2009-06-01"), sep=',',
      colClasses=c('Date', 'Date'), header=TRUE)
    
    # convert series
    df <- xtsToDataFrame(series)
    library(reshape2)
    df <- melt(df,id.vars = c("Date"))
    names(df) <- c("Date","Group","Value")
    df$axisadj <- axisadj
    df <- df[df$Date > as.Date(startdatestring),] # truncate
    recessions.trim = subset(recessions.df, Peak >= min(as.Date(df$Date)) )
    g <- ggplot(data=df) # make plot
    g + 
      theme_minimal() + xlab("") + 
      ylab(ylabel) + 
      ggtitle(title) + 
      scale_y_continuous(labels=axistype) + 
      geom_rect(data=recessions.trim, 
                aes(xmin=Peak, 
                    xmax=Trough, 
                    ymin=-Inf, 
                    ymax=+Inf), 
                fill="gray", alpha=0.3) + 
      theme(text = element_text(size = 30),
            axis.title.y = element_text(hjust = 1,vjust=0.3,face="bold"), 
            title = element_text(vjust = 1,size=28),
            legend.position="top") +
      geom_area(aes(x=Date,y = Value/axisadj,fill=Group),alpha=0.5) + 
      annotate(geom = "text",
               x = as.Date("1997-01-01"),
               y = ypt,
               label = sourcetext,
               size = 8)
    ggsave(filename = paste0(savelocation,filename), # save
           width = 14,
           height = 12,
           units = "in")
}