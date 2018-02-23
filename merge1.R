
library(readr)
library(dplyr)

sheet <- (read_tsv(input_files[[1]])
	%>% transmute(idnum=idnum, macid=macid
		, sa=`Exam 1 SA`, manVer = `Exam 1 Version`
	)
)

scores <- left_join(scores, sheet)

## Version validation

## This code is cumbersome, but I'm trying to remember to use NAs 
## in a principled fashion
scores <- (scores
	%>% mutate(version = ifelse(version==-1, NA, version)
		, version = ifelse(is.na(version), manVer, version)
	)
)

## Need to check bestVer again, because we've supplemented
mismatch <- filter(scores, 
	(!is.na(manVer) && manVer != version)
	|| (!is.na(version) && bestVer != version)
	|| (!is.na(score)) && (score>0) && (score != bestScore)
)

print(mismatch)
stopifnot(nrow(mismatch)==0)

good <- (scores 
	%>% filter(!is.na(version))
	%>% mutate(total = bestScore+sa)
)

print(filter(good, is.na(bestScore)))
print(filter(good, is.na(sa)))

grades <- pull(good, total)
mean(grades)
sd(grades)
