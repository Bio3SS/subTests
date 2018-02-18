
library(readr)
library(dplyr)


## Read stuff in
responses <- read_tsv(grep("tsv", input_files, value=TRUE)
	, col_names=FALSE
)

key <- read_delim(grep("ssv", input_files, value=TRUE)
	, delim = " "
	, col_names=FALSE
)

orders <- read_tsv(grep("orders", input_files, value=TRUE)
	, col_names=FALSE
)

## Scary calculation code
## Redo some day with purrr
## Match each version key to each slate of responses
answers <- as.matrix(responses[-(1:2)])
allScores <- apply(answers, 1, function(a){
	vs <- sapply(orders, function(v){
		return(sum(a[order(v)]==key))
	})
	return((vs))
})

## Pick out best version and highest score
## Best version is a disaster: which.max picks only one thing, but makes a confusing object
bestScore <- apply(allScores, 2, max)

## Try to instead get a score for the bubbled version
verScore <- sapply(1:ncol(allScores), function(i){
	return(allScores
})

scores <- (responses
	%>% transmute(idnum=X1
		, version=X2
		, bestScore
		, bestVer
	)
)

print(scores)
