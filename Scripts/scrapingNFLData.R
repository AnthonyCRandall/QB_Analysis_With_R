# Install and load in the packages that we will need

install.packages("rvest")
install.packages("tidyverse")

library(rvest)
library(tidyverse)

# Grab the URL that we want to scrape data from and assign it to a variable

url <- "https://www.pro-football-reference.com/years/2023/passing.htm"

# Use read_html() from the 'rvest' package to read an HTML webpage and its content

webpage <- read_html(url)

# I am using the Chrome extension 'SelectorGadget' to extract ONLY the data that I want
# In this case for example, to grab the NFL players names, I will use the following CSS selector:

Player <- html_nodes(webpage, "th+ .left") %>% html_text() # The piping part is included because
                                                                  # I want only the HTML text, not the HTML tags

# To extract any other data, the same procedure can be followed

Age <- html_nodes(webpage, ".right:nth-child(3)") %>% html_text()
Team <- html_nodes(webpage, ".left:nth-child(4)") %>% html_text()
Games_Played <- html_nodes(webpage, ".left~ .left+ .right") %>% html_text()
Completions <- html_nodes(webpage, ".right:nth-child(9)") %>% html_text()
Pass_Attempts <- html_nodes(webpage, ".right:nth-child(10)") %>% html_text()
Yards <- html_nodes(webpage, ".right:nth-child(12)") %>% html_text()
TD <- html_nodes(webpage, ".right:nth-child(13)") %>% html_text()
Int <- html_nodes(webpage, ".right:nth-child(15)") %>% html_text()
Passer_Rating <- html_nodes(webpage, ".right:nth-child(24)") %>% html_text()
Times_Sacked <- html_nodes(webpage, ".right:nth-child(26)") %>% html_text()

# It looks like there is 135 values in each vector so we should be good to go
# Lets combine our vectors into a data frame using the data.frame() function

NFL_df <- data.frame(
                    Player = Player,
                    Age = Age,
                    Team = Team,
                    Games_Played = Games_Played,
                    Completions = Completions,
                    Pass_Attempts = Pass_Attempts,
                    Yards = Yards,
                    TD = TD,
                    Int = Int,
                    Passer_Rating = Passer_Rating,
                    Times_Sacked = Times_Sacked
                    )

# I could have renamed my column names here but I did that when I was storing the HTML nodes
# For example, if I kept the 'Yards' vector as 'Yds' (as seen on the website) when I was extracting the data, 
# I could have done Yards = Yds here to get my desired colname

# Lets view our data frame / table to make sure everything looks good

view(NFL_df)

# Ah, perfect! It worked! We have now successfully scraped our NFL QB data










