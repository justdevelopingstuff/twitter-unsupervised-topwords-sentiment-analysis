#!/usr/bin/Rscript
arguments <- commandArgs()
country1 <- arguments[6]
country2 <- arguments[7]

#for testing purposes
#country1 <- "germany"
#country2 <- "france"

#READ IN DATA 
#create an index dataframe to refer to for other functions
country <- c(country1, country2, paste0(country1, country2))
emotions <- c("neu", "neg", "pos", "all")
emotion <- c("Neutral", "Negative", "Positive", "All")
m <- data.frame(country = rep(country, each = 4),
                emotions = rep(emotions, 3), emotion = rep(emotion, 3))
m["label"] <- paste(m[,1], m[,2], sep = "_")

#checking for empty parsed tweet "dates_" files
m["numberofrows"] <- NA 
emptychecker <- function(meta) {
    for (i in 1:dim(meta)[1]) {
        dat <- read.table(paste0("dates_", meta[i,4], ".txt"), header = FALSE, nrows = 2)
        meta[i,"numberofrows"] <- dim(dat)[1]
    }
    meta <- subset(meta, subset = numberofrows > 1)
    return(meta)
}
m <- emptychecker(m)

#define a function to format the raw tweet files
dater <- function(tab) {
    tab <- tab[,c(3:4)]
    tab["year"] <- "2016"
    tab["month"] <- "07"
    tab["thedate"] <- paste(tab$year, tab$month, sep = "-")
    tab["thedate"] <- paste(tab$thedate, as.character(tab$V3), sep = "-")
    tab["thedate"] <- as.POSIXct(paste(tab$thedate, tab$V4, sep = " "), 
                                 format = "%Y-%m-%d %H:%M:%S")
    tab["emocount"] <- "emocount"
    tab <- tab[,c(5:6)]
    return(tab)
}

#finally read in all the non-empty raw tweet files
for (i in 1:dim(m)[1]) {
    dat <- read.table(paste0("dates_", m[i,4], ".txt"), header = FALSE)
    dat <- dater(dat)
    dat <- dat[-1,]
    dat$emocount <- paste(as.character(m[i,1]), as.character(m[i,3]), sep = " ")
    assign(as.character(m[i,4]), dat)
}

#NON-SENTIMENT ANALYSIS
#combine non-emotion aka 'noise' related tweets into single data frame
rbindingtables <- function(m, selection) {
    if (selection == "noise") {
        selection.m <- subset(m, subset = emotions ==  "all")
    }
    if (selection == "emotion") {
        selection.m <- subset(m, subset = emotions !=  "all")
    }
    lengthofnoisetables <- dim(selection.m)[1]
    if (lengthofnoisetables > 1) {
        tweets <- rbind(get(selection.m[1,4]), get(selection.m[2,4]))
        if (lengthofnoisetables > 2)
            for (i in 3:lengthofnoisetables) {
                tweets <- rbind(tweets, get(selection.m[i,4]))
            }   
    }
    else {
        tweets <- get(selection.m[1,4])
    }
    tweets$emocount <- as.factor(tweets$emocount)
    return(tweets)
}
tweets.noise <- rbindingtables(m, "noise")

#generating frequencies
tweets.noise.freq <- as.data.frame(table(tweets.noise))

#create bins per minute
tweets.noise.freq["adj.date"] <- strftime(tweets.noise.freq$thedate, "%Y-%m-%d %H-%M")

##not grouped by countries to generate total tweet graph
tweets.noise.freq.all <- tweets.noise.freq
tweets.noise.freq.all["emocount"] <- "All All"

#combine into single dataframe
tweets.noise.sum <- rbind(tweets.noise.freq, tweets.noise.freq.all)
#tallying tweets by minute
tweets.noise.peaks <- aggregate(tweets.noise.sum$Freq, 
                         by = list(emocount = tweets.noise.sum$emocount, 
                                   adj.date = tweets.noise.sum$adj.date), FUN = sum)
tweets.noise.peaks$adj.date <- as.POSIXct(tweets.noise.peaks$adj.date, format = "%Y-%m-%d %H-%M")
ordered.tweets.noise.peaks <- tweets.noise.peaks[order(-tweets.noise.peaks$x),]

#labelling
ordered.tweets.noise.peaks["country"] <- as.factor(gsub(' [A-z]*', '', as.character(ordered.tweets.noise.peaks$emocount))) 
ordered.tweets.noise.peaks["emotion"] <- as.factor(gsub('[A-z]* ', '', as.character(ordered.tweets.noise.peaks$emocount)))
ordered.tweets.noise.peaks["emocount"] <- as.factor(toupper(ordered.tweets.noise.peaks$emocount))
ordered.tweets.noise.peaks["emocount"] <- as.factor(gsub(' ALL', '', ordered.tweets.noise.peaks$emocount))

#SENTIMENT ANALYSIS
#combine emotions into single data frame
tweets.emo <- rbindingtables(m, "emotion")

#generating frequencies
tweets.emo.freq <- as.data.frame(table(tweets.emo))

#create bins per minute
tweets.emo.freq["adj.date"] <- strftime(tweets.emo.freq$thedate, "%Y-%m-%d %H-%M")

#tallying tweets by minute
tweets.emo.peaks <- aggregate(tweets.emo.freq$Freq, 
                         by = list(emocount = tweets.emo.freq$emocount, 
                                   adj.date = tweets.emo.freq$adj.date), FUN = sum)
tweets.emo.peaks$adj.date <- as.POSIXct(tweets.emo.peaks$adj.date, format = "%Y-%m-%d %H-%M")
ordered.tweets.emo.peaks <- tweets.emo.peaks[order(-tweets.emo.peaks$x),]

#labelling
ordered.tweets.emo.peaks["country"] <- as.factor(gsub(' [A-z]*', '', as.character(ordered.tweets.emo.peaks$emocount))) 
ordered.tweets.emo.peaks["emotion"] <- as.factor(gsub('[A-z]* ', '', as.character(ordered.tweets.emo.peaks$emocount)))
ordered.tweets.emo.peaks["emocount"] <- toupper(ordered.tweets.emo.peaks$emocount)

#printing out file
write.csv(ordered.tweets.noise.peaks, paste0("noise-peaks-", country1, "-", country2, ".csv"), row.names = FALSE)
write.csv(ordered.tweets.emo.peaks, paste0("emo-peaks-", country1, "-", country2, ".csv"), row.names = FALSE)

noiseemo <- rbind(ordered.tweets.noise.peaks, ordered.tweets.emo.peaks)
noiseemo$emocount <- factor(noiseemo$emocount)
#excludelowcounts <- subset(noiseemo, subset = noiseemo$country != paste0(country1, country2) & noiseemo$emotion != "All")
assign(paste0(country1, country2), noiseemo)

#PLOTTING
#making plots
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#000000", "#800000", "#771885", "#28671B", "#28CD4D")
grapher <- function(noisemo) {
png(paste0(country1, country2, ".png"), width = 1920, height = 1080, units = "px")
print(ggplot(noiseemo, aes(adj.date, x, group = emocount, color = emocount)) +
      scale_color_manual(values = cbPalette) +
    geom_line(size = 1.5) +
    ylab("TOTAL TWEETS") +
    scale_x_datetime(labels = date_format("%H:%M:%S", tz = "America/Vancouver"),
                                   breaks = date_breaks("1 hour")) + 
    theme_bw(base_size = 20) + 
    theme(axis.title.x = element_blank(), 
          axis.text.x = element_text(angle = 30, hjust = 1),
          legend.position = "bottom", 
          legend.title = element_blank(),
          legend.key = element_rect(color = "white"),
          legend.key.size = unit(2, "cm"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank()) + 
      guides(colour = guide_legend(override.aes = list(size = 2)))
    )
dev.off()
}

require(ggplot2)
require(scales)
grapher(get(paste0(country1, country2)))

#narrower graph
gameday <- gsub('([0-9]+) .*', '\\1', as.character(noiseemo$adj.date[1]))
nextday <- as.character(as.POSIXct(gameday, tz = " ") + 60*60*24)
noiseemo <- subset(noiseemo, subset = noiseemo$adj.date > paste0(gameday, " 16:00:00") &
                   noiseemo$adj.date < paste0(nextday, " 03:00:00"))
assign(paste0(country1, country2), noiseemo)

#making plots
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#000000", "#800000", "#771885", "#28671B", "#28CD4D")
grapher <- function(noisemo) {
png(paste0(country1, country2, "game.png"), width = 1920, height = 1080, units = "px")
print(ggplot(noiseemo, aes(adj.date, x, group = emocount, color = emocount)) +
      scale_color_manual(values = cbPalette) +
    geom_line(size = 1.5) +
    ylab("TOTAL TWEETS") +
    scale_x_datetime(labels = date_format("%H:%M:%S", tz = "America/Vancouver"),
                                   breaks = date_breaks("15 min")) + 
    theme_bw(base_size = 20) + 
    theme(axis.title.x = element_blank(), 
          axis.text.x = element_text(angle = 30, hjust = 1),
          legend.position = "bottom", 
          legend.title = element_blank(),
          legend.key = element_rect(color = "white"),
          legend.key.size = unit(2, "cm"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank()) + 
      guides(colour = guide_legend(override.aes = list(size = 2)))
    )
dev.off()
}

require(ggplot2)
require(scales)
grapher(get(paste0(country1, country2)))
