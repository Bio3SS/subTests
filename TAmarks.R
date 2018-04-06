
library(readr)
library(dplyr)

sheet <- (read_tsv(input_files[[1]])
)

tutMark <- (select(sheet, contains("Tutorial "))
	%>% rowMeans(na.rm=TRUE)
)

print(tutMark)
