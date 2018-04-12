
library(readr)
library(dplyr)

sheet <- (read_tsv(input_files[[1]])
	%>% anti_join(
		read_csv(input_files[[2]])
		%>% mutate(idnum=as.numeric(idnum))
	)
)

asnMark <- (select(sheet, contains("Assignment "))
	%>% setNames(gsub(pattern="$", replacement=" Points Grade" , names(.)))
)

summary(asnMark)

(sheet %>% 
	transmute(
		OrgDefinedId=(
			sprintf("%9d", idnum) 
			%>% gsub(pattern=" ", replacement="0")
		)
		, Username=macid
		, `Attendance Points Grade`= 2*(
			select(sheet, contains("Tutorial ")) %>% rowMeans(na.rm=TRUE)
		)
	) %>% bind_cols(asnMark)
	%>% mutate(
		`End-of-Line Indicator` = "#" 
	)
) %>% write_csv(csvname)

