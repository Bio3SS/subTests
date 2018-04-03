library(dplyr)
library(readr)

(scores
	%>% transmute(
		OrgDefinedId=(
			sprintf("%9d", idnum) 
			%>% gsub(pattern=" ", replacement="0")
		)
		, Username=macid
		, `Midterm 2 Points Grade` =sa+bestScore
		, `End-of-Line Indicator` = "#" 
	)
	%>% write_csv(csvname)
)
