source("scrapingNFLData.R")

library(tidyverse)
library(rvest)

# Cool, lets move onto cleaning this data now
# Lets first start by making sure we only have data on QBs 
# Wait...there's no vector that shows the positions of the players...dang
# Looks like we have to add that to our data frame!

Position <- html_nodes(webpage, ".left+ .left") %>% html_text()

NFL_df %>%
  mutate(Position) -> NFL_df1

view(NFL_df1)

# Perfect! Now we can FINALY make sure all the players are QB's

unique(NFL_df1$Position)

# Oh no...we have other positions in this data frame too
# Lets try adjusting it to where only QB's records are available

NFL_df1 %>%
  filter(Position == "QB") -> QB_df

view(QB_df)

# Nicee, now we only have data on the QB position 
# I could have used the "subset" command to do this (QB_df <- subset(NFL_df1, Position == "QB"))
# Or base R (QB_df <- NFL_df1[NFL_df1$Position == QB, ])
# But dplyr is just sooooo much easier so thats why I did it like that
# And no...I will not be including Taysom Hill in this project, he is a weird exception

# Looks like we have some duplicate QBs in the dataframe, lets get that situated

QB_df <- QB_df[!duplicated(QB_df$Player), ]
view(QB_df)

# Lets now just check and make sure that the data in its respected vector has the intended data type

class(QB_df$Age)  

# You gotta be kidding me...thats okay! Lets see what other vectors we might have to convert 
  
str(QB_df)  

# Oh wow, every single record are characters, time to fix it up

QB_df$Age <- as.integer(QB_df$Age)
QB_df$Games_Played <- as.integer(QB_df$Games_Played)
QB_df$Completions <- as.integer(QB_df$Completions)
QB_df$Pass_Attempts <- as.integer(QB_df$Pass_Attempts)
QB_df$Yards <- as.integer(QB_df$Yards)
QB_df$TD <- as.integer(QB_df$TD)
QB_df$Int <- as.integer(QB_df$Int)
QB_df$Passer_Rating <- as.numeric(QB_df$Passer_Rating)
QB_df$Times_Sacked <- as.integer(QB_df$Times_Sacked)

# Okay lets check and make sure that the data frame is structured correctly now

str(QB_df)

# Looking goodddddd, I have a question. Is there any missing data in the data frame???
# Hmmm lets take a look

QB_df %>%
  filter(!complete.cases(.))

# So we do have missing values, it looks like 2 of the QBs dont have Passer_Ratings
# Lets fill in that data for these records ONLY

# Here is the formula for passer rating:
#     - Formula 1: (Completions/Attempts - 0.3) x 5
#     - Formula 2: (Passing Yards/Attempts - 3) x 0.25
#     - Formula 3: Touchdowns/Attempts x 20
#     - Formula 4: 2.375 - (Interceptions/Attempts x 25)
# Add the results of the 4 formulas
# Divide the sum by 6
# Multiply the result by 100

# Note, all the variables in the 2 QBs records that are needed for the Passer_Rating is 0
# Therefore, they will end up having a 0 QB rating but ill still go through how i woild approach this

QB_df %>%
  filter(is.na(Passer_Rating)) %>%
  group_by(Player) %>%
  summarise(
    formula1 = ((Completions / Pass_Attempts) - 0.3) * 5,
    formula2 = ((Yards / Pass_Attempts) - 3) * 0.25,
    formula3 = (TD / Pass_Attempts) * 20,
    formula4 = 2.375 - ((Int / Pass_Attempts) * 25),
    summ = formula1 + formula2 + formula3 + formula4
  )
  
# Both QBs pass attempts are 0 so I got NaN for my formulas and summ because im diving by 0 in all 4
# Because of this, by default, these QBs will have a 0 passer rating. Lets substitute 0s for both
# That sounds great and all but where are these QBs in the data frame? Hmmm
# One way of finding this out is by using the which() function

malikCunninhamIndex <- which(QB_df$Player == "Malik Cunningham")
nathanPetermanIndex <- which(QB_df$Player == "Nathan Peterman")

# Lets see where they are located at now

malikCunninhamIndex  
nathanPetermanIndex  
  
# Looks like its at index 76 and 77, NOW we can fill in 0's for the passer rating

QB_df[76, "Passer_Rating"] <- 0.0
QB_df[77, "Passer_Rating"] <- 0.0

# Lets see if there are any non-completed records now

QB_df %>%
  filter(!complete.cases(.))

# Looks like there's no rows that are not completed now, but lets for good measures check the whole data frame

view(QB_df)

# There we go! We are making some progress!
# Since i'm anal, I wanna switch some of the team names to things that I can remember instead
# In this case i'm going to use the replace function()

QB_df$Team <- replace(QB_df$Team, QB_df$Team == "GNB", "GB")
QB_df$Team <- replace(QB_df$Team, QB_df$Team == "SFO", "SF")
QB_df$Team <- replace(QB_df$Team, QB_df$Team == "KAN", "KC")
QB_df$Team <- replace(QB_df$Team, QB_df$Team == "TAM", "TB")
QB_df$Team <- replace(QB_df$Team, QB_df$Team == "NOR", "NO")
QB_df$Team <- replace(QB_df$Team, QB_df$Team == "NWE", "NE")

# Okay, this data frame contains QB's that have played for multiple teams in the same season
# I only want to have a QB show up once in this data frame
# Lets modify the data frame to do this
# Well first, which players played for multiplt teams in the same year

QB_df %>%
  filter(Team == "2TM")

# Looks like it was only Joshua Dobbs in 2023
# Where is he in this df?

joshuaDobbsIndex <- which(QB_df$Player == "Joshua Dobbs")
joshuaDobbsIndex

# One more thing...let me change his team from "2TM" to the ones he actually played for

QB_df$Team <- replace(QB_df$Team, QB_df$Team == "2TM", "ARI/MIN")
view(QB_df)

# Perfect!









