
## Todo: make private (bitbucket) repo for mark tracking

# Tests
## Includes test and marking machinery (because both depend on scramble stuff)
## Give this some thought

### Hooks for the editor to set the default target
-include target.mk

##################################################################

## Notes

# Crib

Crib = ~/hybrid/3SS/content/Makefile
Crib = ~/hybrid/3SS/content/

.PRECIOUS: %.pl
%.pl:
	$(CP) $(Crib)/$@ .

######################################################################

# make files

Sources = Makefile .ignore README.md sub.mk LICENSE.md
include sub.mk
-include $(ms)/perl.def

##################################################################

## Submodules

## Test material is here
Sources += material
mdirs += material

material:
	git submodule add -b master https://github.com/Bio3SS/Evaluation_materials $@

material/%: 
	$(MAKE) material
	$(makethere)

## This submodule seems like a legacy. What is used?
## Probably some diagrams and stuff
## How does it differ from material (both are private)?
Sources += assign
mdirs += assign
assign:
	git submodule add -b master https://github.com/Bio3SS/Assignments $@

assign/%: 
	$(MAKE) assign
	$(makethere)

## There is also a private repo called Grading_scripts (out of date)
## and a public successor called Grading
## It might be good to farm the grading scripts out to Grading,
## and to use Grading_scripts to keep grade files that we might want to diff

## Grading has poll everywhere stuff
## It used to be a submodule of Tests, but I'm trying to reverse that

##################################################################

### Directories

Makefile: talk lect material

Ignore += talk lect

talk: dir=$(ms)/newtalk
talk:
	$(linkdirname)

lect: dir=$(ms)
lect:
	$(linkdir)

### Formats

Ignore += null.tmp
null.tmp:
	touch $@

Ignore += *.fmt
%.test.fmt: lect/test.format lect/fmt.pl
	$(PUSHSTAR)

%.select.fmt: lect/select.format lect/fmt.pl
	$(PUSHSTAR)

######################################################################

## Multiple choice banks

# Combined test banks

## Templates
# null is made; list .tmp files here if necessary
# Sources += $(wildcard *.tmp)

## Formulas
Sources += $(wildcard *.formulas)
Sources += $(wildcard formula*.tex)

Ignore += midterm1.bank
midterm1.bank: midterm1.formulas material/linear.bank material/nonlinear.bank material/structure.bank
	$(cat)

Ignore += midterm2.bank
midterm2.bank: midterm2.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank
	$(cat)

Ignore += final.bank
final.bank: final.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank material/pred.bank material/disease.bank
	$(cat)

final.1.test.pdf: final.formulas
final.test.pdf: final.formulas
final.key.pdf: final.formulas

## %.bank.test: %.bank null.tmp bank.select.fmt $(ms)/talk/lect.pl
##	$(PUSH)

######################################################################

midterm2.mc:

# MC selection
# Use lect/select.format

.PRECIOUS: %.mc
Ignore += *.mc
%.mc: %.bank null.tmp %.select.fmt $(ms)/newtalk/lect.pl
	$(PUSH)

# Scramble

Sources += $(wildcard *.pl)

midterm1.%.mc: midterm1.mc scramble.pl
	$(PUSHSTAR)

midterm2.%.mc: midterm2.mc scramble.pl
	$(PUSHSTAR)

final.%.test: final.mc scramble.pl
	$(PUSHSTAR)

final.test: final.mc
	$(copy)

 
######################################################################

# Test key
.PRECIOUS: %.ssv

Ignore += *.ssv
midterm%.ssv: midterm%.mc key.pl
	$(PUSH)

final.%.ssv: final.%.test key.pl
	$(PUSH)

# Make a special answer key for scantron processing
# To allow multiple answers, use KEY in the .bank file
Ignore += *.sc.csv
%.sc.csv: %.ssv scantron.pl
	$(PUSH)

Ignore += *.scantron.csv
midterm1.scantron.csv:
midterm2.scantron.csv:
final.scantron.csv:

# Combine a bunch of scantron keys into a file for the processors
final.scantron.csv midterm1.scantron.csv midterm2.scantron.csv: %.scantron.csv: %.1.sc.csv %.2.sc.csv %.3.sc.csv %.4.sc.csv %.5.sc.csv
	$(cat)

######################################################################

# Make a skeleton to track how questions are scrambled
# Will be used later for marking
Ignore += final.skeleton midterm1.skeleton midterm2.skeleton
final.skeleton midterm1.skeleton midterm2.skeleton: %.skeleton: %.mc skeleton.pl
	$(PUSH)

# Make files showing the order for versions of a test
midterm1.%.order: midterm1.skeleton scramble.pl
	$(PUSHSTAR)

midterm2.%.order: midterm2.skeleton scramble.pl
	$(PUSHSTAR)

final.%.order: final.skeleton scramble.pl
	$(PUSHSTAR)

.PRECIOUS: %.orders
Ignore += *.orders
%.orders: %.1.order %.2.order %.3.order %.4.order %.5.order orders.pl
	$(PUSH)

midterm1.orders:

######################################################################

## Short answers

# Make combined SA lists for each test
Ignore += *.short.test
Sources += sahead.short
midterm1.short.test: sahead.short material/linear.short material/nonlinear.short 
	$(cat)

midterm2.short.test: material/linear.short material/nonlinear.short material/structure.short material/life_history.short
	$(cat)

# Select the short-answer part of a test

.PRECIOUS: %.sa
Ignore += *.sa
%.sa: %.short.test null.tmp %.select.fmt $(ms)/newtalk/lect.pl
	$(PUSH)

######################################################################

## SA processing
## Not scrambling (afraid of format problems)
	## Maybe these can be solved by always having a page per question
## Not sure where the scramble markers are going!

Ignore += *.vsa
midterm1.%.vsa: midterm1.sa testselect.pl
	$(PUSHSTAR)

midterm2.%.vsa: midterm2.sa testselect.pl
	$(PUSHSTAR)

midterm2.vsa: midterm2.sa
	$(cat)

## Convert versioned sa to rmd style
Ignore += *.rsa
%.rsa: %.vsa lect/knit.fmt $(ms)/newtalk/lect.pl
	$(PUSH)

Ignore += *.ksa
## and finally knit
knit = echo 'knitr::knit("$<", "$@")' | R --vanilla
%.ksa: %.rsa
	$(knit)

######################################################################


## Put the test together

### Separator for MC and SA on the same test
Sources += end.dmu

Ignore += *.test
%.test: %.mc end.dmu %.ksa
	$(cat)

## Instructions added for 1M strictness; not sure whether to copy them over
Sources += sa_inst.tex

## This should be done better
Sources += copy.tex

######################################################################

.SECONDEXPANSION:
material.now: %.now: $$(wildcard $$*/*)
	@echo $^

midterm2.test.pdf: material/life_history.bank
midterm2.3.test.pdf: material/life_history.bank

## Latex outputs

Sources += test.tmp
Ignore += *.test.tex *.test.pdf
%.test.tex: %.test test.tmp test.test.fmt talk/lect.pl
	$(PUSH)

Ignore += *.key.*
%.key.tex: %.test test.tmp key.test.fmt talk/lect.pl
	$(PUSH)

## Why are rubric dependencies different??
Ignore += *.rub.*
%.rub.tex: %.ksa test.tmp rub.test.fmt talk/lect.pl
	$(PUSH)

######################################################################

###### Marking ######

Sources += $(wildcard *.R)

Ignore += pulldir
pulldir: dir = /home/dushoff/Dropbox/courses/3SS/2018
pulldir:
	$(linkdirname)
pulldir/%: pulldir

## screen -t pp ~/bin/sdir /home/dushoff/Dropbox/courses/3SS/2018 ##


## Student responses from scantron
## The weird .dlm files are apparently the ones with the raw scans
## Changing space (\s) to NA so that we can use the simple, strict read_table
## 	Did I actually do that or not? -- No.
## Add manual coding (unreadable) scantron
Ignore += *.responses.tsv
midterm1.responses.tsv: pulldir/m1disk/BIOLOGY3SS315FEB2018.dlm pulldir/m1.manual.tsv
	$(cat)

midterm2.responses.tsv: pulldir/m2disk/BIOLOGY3SS323MAR2018.dlm
	$(cat)

final.responses.tsv: pulldir/fdisk/BIOLOGY3SS319APR2018.dlm

## Student scores from scantron ofice
## Use WebCT file for scores instead of rounded proportions
Ignore += midterm1.office.csv midterm2.office.csv

midterm2.office.csv:
midterm%.office.csv: pulldir/m%disk/StudentScoresWebCT.csv Makefile
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## Re-score here (gives us control over version errors)
	## Also confidence to do analysis later
midterm2.scores.Rout: midterm2.responses.tsv midterm2.ssv midterm2.orders scores.R
%.scores.Rout: %.responses.tsv %.ssv %.orders scores.R
	$(run-R)

Sources += midterm2p.ssv
### Correcting an answer (D'oh!)
### Avoid doing it this way; should be able to update the .ssv made from the test
midterm2p.scores.Rout: midterm2.responses.tsv midterm2p.ssv midterm2.orders scores.R
	$(run-R)

## Compare

## All comparisons should match for everyone with a version…
## In this case, use bestScore for everyone with a version 
midterm2.scorecomp.Rout: midterm2.office.csv midterm2.scores.Rout scorecomp.R
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)

## Patch scantron issues (last used 2018M1)
	## One person left a number out of their idnum
## midterm1.patch.Rout: midterm1.patch.csv midterm1.scorecomp.Rout idpatch.R
Sources += $(wildcard midterm.patch.csv)
%.patch.Rout: %.patch.csv %.scorecomp.Rout idpatch.R
	$(run-R)

## Is this robust? Second rule for patch should only be called if there is no .patch.csv?
%.patch.Rout: %.scorecomp.Rout nullpatch.R
	$(run-R)

midterm2.patch.Rout: midterm2.scorecomp.Rout.envir midterm2p.scores.Rout.envir addCorrection.R
	$(run-R)

## Merge SA, MSAF and MC information
## This needs to be rethought when we attempt to record version info
## systematically
## Check again that there are no version issues before using bestScore
## If versions are recorded systematically, we can match upstream and use score
## There are two merge?.R files; this seems stupid

## MSAFs seem to be recorded on the course Google sheet
## https://docs.google.com/spreadsheets/d/1AqC5xwc-GsDTMKM8-hHYeXkLzGC0JN2ZjabL8XmZTdk/edit#gid=0
## marks%.tsv are various downloads from there

midterm%.merge.Rout: pulldir/marks%.tsv midterm%.patch.Rout merge%.R
	$(run-R)

midterm%.merge.Rout: pulldir/marks%.tsv midterm%.patch.Rout merge%.R
	$(run-R)

## Make a file for Avenue
## Looking for grade post site
## https://avenue.cllmcmaster.ca/d2l/home/235353
## Try assesment/grades/enter grades/import

## This is just an example!
Sources += avenue.csv 

midterm%.avenue.Rout: midterm%.merge.Rout avenue%.R
	$(run-R)

midterm2.avenue.Rout.csv: avenue2.R

######################################################################

## Grade sheet scripts ##
## I guess this would be good to have somewhere else, for simplicity

## Principled approach to NAs: add text NA for an MSAF
## Use a perl script to replace blanks with zeroes

## Not clear why I'm keeping different tsvs in pulldir, but it's not hurting much.

## Drops are people marked as not matching by the Avenue import
## Working on obsoleting this in Grading
Ignore += marks.tsv
marks.tsv: pulldir/marks3.tsv zero.pl
	$(PUSH)
TAmarks.Rout: marks.tsv pulldir/drops.csv TAmarks.R
TAmarks.Rout.csv: TAmarks.R

## Not clear if Avenue interprets "-" correctly (or else sets to 0)
Sources += na_fake.pl
Ignore += TAmarks.avenue.csv
TAmarks.avenue.csv: TAmarks.Rout.csv na_fake.pl
	$(PUSH)

######################################################################

## Question analysis

## Need to unscramble and other nonsense; there is still stuff in content

######################################################################

pushdir = web/materials

web:
	git submodule add -b master https://github.com/Bio3SS/Bio3SS.github.io.git $@

mdirs += web

######################################################################

midterm2.1.exam.pdf:

## Print versions and printing

## Cover pages handled differently
## This is because the final cover needs to know the number of pages
## so it's part of the main tex document
Sources += $(wildcard *.front.tex)
Sources += scantron.jpg

## Add cover pages and such
Ignore += *.exam.tex *.exam.pdf *.front.pdf
midterm1.%.exam.pdf: midterm.front.pdf midterm1.%.test.pdf
	$(pdfcat)

midterm2.%.exam.pdf: midterm.front.pdf midterm2.%.test.pdf
	$(pdfcat)

Sources += final.tmp examno.pl final.cover.tex
final.3.final.pdf: final.tmp 

final.%.tmp: final.tmp examno.pl
	$(PUSHSTAR)

%.final.tex: %.test %.tmp test.test.fmt talk/lect.pl
	$(PUSH)

## http://printpal.mcmaster.ca/
## account # 206000301032330000

## White, orchid, green, salmon 

midterm1.3.test.pdf:

midterm1_ship: midterm1.1.exam.pdf midterm1.2.exam.pdf midterm1.3.exam.pdf midterm1.4.exam.pdf midterm1.5.exam.pdf

midterm1_post: midterm1.1.test.pdf.pd midterm1.2.test.pdf.pd midterm1.3.test.pdf.pd midterm1.4.test.pdf.pd midterm1.5.test.pdf.pd

midterm1.rub.zip: midterm1.1.rub.pdf midterm1.2.rub.pdf midterm1.3.rub.pdf midterm1.4.rub.pdf midterm1.5.rub.pdf
	$(ZIP)

midterm2_ship: midterm2.1.exam.pdf midterm2.2.exam.pdf midterm2.3.exam.pdf midterm2.4.exam.pdf midterm2.5.exam.pdf

midterm2_post: midterm2.1.test.pdf.pd midterm2.2.test.pdf.pd midterm2.3.test.pdf.pd midterm2.4.test.pdf.pd midterm2.5.test.pdf.pd

midterm2_keys: midterm2.1.key.pdf.pd midterm2.2.key.pdf.pd midterm2.3.key.pdf.pd midterm2.4.key.pdf.pd midterm2.5.key.pdf.pd

midterm2.rub.zip: midterm2.1.rub.pdf midterm2.2.rub.pdf midterm2.3.rub.pdf midterm2.4.rub.pdf midterm2.5.rub.pdf
	$(ZIP)

## Search email for Exam Upload Instructions (or notice when email arrives and do something)
Ignore += $(wildcard Bio_3SS3*.pdf) 
Ignore += $(wildcard final*final.pdf) 
final_ship: Bio_3SS3_C01_V1.pdf Bio_3SS3_C01_V2.pdf Bio_3SS3_C01_V3.pdf Bio_3SS3_C01_V4.pdf ;

Bio_3SS3_C01_V%.pdf: final.%.final.pdf
	$(forcelink)

## 2018 Shipping Screenshot
## downcall pulldir/ship.png ##
## "Forgot" to re-screenshot (uploaded extra files)

######################################################################

-include $(ms)/texdeps.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
