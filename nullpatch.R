library(dplyr)

scores <- (scores
	%>% mutate(idnum=as.numeric((idnum)))
)

# rdsave(scores)
