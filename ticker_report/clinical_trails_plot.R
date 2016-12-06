if (file.exists(args[2])) {
    packages <- c("timelineS","stringr", "ggplot2")
    if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
        install.packages(setdiff(packages, rownames(installed.packages())))
    }
    library(timelineS)
    library(stringr)
    setwd("/Users/xieliang12/ruby/stock_analysis_app")
    clinicals <- read.table(args[2],
                            sep=",", header=TRUE, stringsAsFactors = FALSE)

    clinicals[,c("Start.Date", "Completion.Date","Last.Updated", "Primary.Completion.Date")] <- 
        lapply(clinicals[,c("Start.Date", "Completion.Date","Last.Updated", "Primary.Completion.Date")], function(x) as.Date(x, "%Y-%m-%d"))
    clinicals$Phases <- ifelse(clinicals$Phases == "", "preclinical", clinicals$Phases)
    #clinicals[, c("Phases")] <- clinicals[,c("Phases")]
    clinicals$Title <- str_wrap(clinicals$Title, width = 40)
    clinicals$Progress <- ""
    for (i in 1:nrow(clinicals)) {
        if (!is.na(clinicals$Completion.Date[i])) {
            clinicals$Progress[i] <- ifelse(clinicals$Completion.Date[i] > as.Date(Sys.time()), "ongoing", "completed")
        } else
            clinicals$Progress[i] <- ifelse(clinicals$Primary.Completion.Date[i] > as.Date(Sys.time()), "ongoing", "completed")
    }
    png(filename=paste0(args[1],"/", args[3], ".png"), width=900, height=600)
    timelineG(df=clinicals, start="Start.Date", end="Last.Updated", names="Title",
              group1="Phases", group2="Progress", color="blue", width=5)
    dev.off()
  }
