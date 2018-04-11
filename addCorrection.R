library(dplyr)

scores <- (envir_list[[1]]$scores
	%>% mutate(
		score = score + envir_list[[2]]$scores$verScore
	)
)

summary(scores)
