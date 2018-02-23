
library(readr)
library(dplyr)

## Read stuff in
responses <- read_tsv(grep("tsv", input_files, value=TRUE)
	, col_names=FALSE
	, na = c("NA") ## Space needs to mismatch, not NA 
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
orders <- orders[-1]

allScores <- apply(answers, 1, function(a){
	vs <- sapply(orders, function(v){
		return(sum(a[order(v)]==key))
	})
	return((vs))
})

print(allScores)

## Pick out best version and highest score
## which.max makes a confusing object for an unclear reason
bestScore <- apply(allScores, 2, max)
bestVer <- unlist(apply(allScores, 2, which.max))

summary(bestScore)
summary(bestVer)

## Try to instead get a score for the bubbled version
verScore <- sapply(1:ncol(allScores), function(i){
	return(allScores)
})

scores <- (responses
	%>% transmute(idnum=X1
		, version=X2
		, bestScore
		, bestVer
	)
)

print(scores
	%>% filter (version != bestVer)
)
