## Todo: make private (bitbucket) repo for mark tracking
## Simplify this repo (too-too many submodules, tracked too automatically)

# Tests
## Includes test and marking machinery (because both depend on scramble stuff)

### Hooks for the editor to set the default target
-include target.mk

##################################################################

# make files

Sources = Makefile README.md LICENSE.md

ms = makestuff

Sources += $(ms)
Makefile: $(ms)/Makefile

$(ms)/%.mk: $(ms)/Makefile ;
$(ms)/Makefile:
	git submodule update -i

-include $(ms)/os.mk
-include $(ms)/perl.def

##################################################################

## Submodules

## material is actually a good candidate for a submodule
## Remake tests and keys by setting the clock back from here. I guess.
## Why did it apparently not sync from school on Tue??
Sources += material
mdirs += material

material:
	git submodule add -b master https://github.com/Bio3SS/Evaluation_materials $@

material/%: 
	$(MAKE) material
	$(makethere)

## Make assign into a resting subclone! Don't need to all it. Ever.
## Try not to use it, not to make there, etc. 2019 Feb 04 (Mon)
## Immediately bailed on this plan!!! 2019 Feb 04 (Mon)
## Resuscitated assign as a clone and made:
## pullup; pullup; rmsync; rmsync; all!
clonedirs += assign
assign:
	git clone https://github.com/Bio3SS/Assignments $@
	cd assign && $(MAKE) Makefile && $(MAKE) Makefile

assign/%: ; $(MAKE) assign; $(makethere)

## There is also a private repo called Grading_scripts (out of date)
## and a public successor called Grading
## It might be good to farm the grading scripts out to Grading,
## and to use Grading_scripts to keep grade files that we might want to diff

## Grading has poll everywhere stuff
## It used to be a submodule of Tests, but I'm trying to reverse that
## Or something

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

## Could NOT make this work with -e!
Sources += archive.pl
archiveQuestions:
	perl -pi -f archive.pl material/*.bank

Ignore += midterm1.bank
midterm1.bank: midterm1.formulas material/linear.bank material/nonlinear.bank material/structure.bank
	$(cat)

Ignore += midterm2.bank
midterm2.bank: midterm2.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank
	$(cat)

Ignore += final.bank
final.bank: final.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank material/pred.bank material/disease.bank
	$(cat)

final.5.test.pdf: final.formulas
final.1.key.pdf: final.formulas
final.test.pdf: final.formulas
final.key.pdf: final.formulas
final.5.final.pdf: final.formulas

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

# midterm1.1.ssv:
Ignore += *.ssv
midterm%.ssv: midterm%.mc key.pl
	$(PUSH)

final.%.ssv: final.%.test key.pl
	$(PUSH)

# Make a special answer key for scantron processing
# To allow multiple answers, use KEY in the .bank file
# Does not work yet for self-scoring
# midterm1.1.sc.csv:
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

midterm2.test.pdf: material/structure.bank
midterm2.5.test.pdf: material/life_history.bank
midterm2.3.key.pdf: material/life_history.bank
midterm2.4.rub.pdf: material/structure.short

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

### Moved to Grading 2019

### Deleted apparently outdated stuff 2019 Apr 23 (Tue)

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

pushdir = ../web/materials

######################################################################

midterm2.1.exam.pdf:

## Print versions and printing

## Cover pages handled differently
## This is because the final cover needs to know the number of pages
## so it's part of the main tex document
## (midterms share midterm.front.tex)
Sources += $(wildcard *.front.tex)
Sources += scantron.jpg

## Add cover pages and such
Ignore += *.exam.tex *.exam.pdf *.front.pdf
midterm1.%.exam.pdf: midterm.front.pdf midterm1.%.test.pdf
	$(pdfcat)

midterm2.%.exam.pdf: midterm.front.pdf midterm2.%.test.pdf
	$(pdfcat)

Sources += final.tmp examno.pl final.cover.tex
## final.3.final.pdf: final.tmp 

final.%.tmp: final.tmp examno.pl
	$(PUSHSTAR)

%.final.tex: %.test %.tmp test.test.fmt talk/lect.pl
	$(PUSH)

## http://printpal.mcmaster.ca/
## account # 206000301032330000

## White, orchid, green, salmon 
## Two-sided, stapled

midterm1.5.exam.pdf:
## midterm1.3.key.pdf: material/linear.short material/nonlinear.short

midterm1_ship: midterm1.1.exam.pdf midterm1.2.exam.pdf midterm1.3.exam.pdf midterm1.4.exam.pdf midterm1.5.exam.pdf
	/bin/cp -f $^ ~/Downloads

## Push tests and keys with the same command
midterm1_post: midterm1.1.test.pdf.pd midterm1.2.test.pdf.pd midterm1.3.test.pdf.pd midterm1.4.test.pdf.pd midterm1.5.test.pdf.pd
midterm1_post: midterm1.1.key.pdf.pd midterm1.2.key.pdf.pd midterm1.3.key.pdf.pd midterm1.4.key.pdf.pd midterm1.5.key.pdf.pd

midterm1.rub.zip: midterm1.1.rub.pdf midterm1.2.rub.pdf midterm1.3.rub.pdf midterm1.4.rub.pdf midterm1.5.rub.pdf
	$(ZIP)

midterm2_ship: midterm2.1.exam.pdf midterm2.2.exam.pdf midterm2.3.exam.pdf midterm2.4.exam.pdf midterm2.5.exam.pdf
	/bin/cp -f $^ ~/Downloads

midterm2_post: midterm2.1.test.pdf.pd midterm2.2.test.pdf.pd midterm2.3.test.pdf.pd midterm2.4.test.pdf.pd midterm2.5.test.pdf.pd

midterm2_keys: midterm2.1.key.pdf.pd midterm2.2.key.pdf.pd midterm2.3.key.pdf.pd midterm2.4.key.pdf.pd midterm2.5.key.pdf.pd

midterm2.rub.zip: midterm2.1.rub.pdf midterm2.2.rub.pdf midterm2.3.rub.pdf midterm2.4.rub.pdf midterm2.5.rub.pdf
	$(ZIP)

## Search email for Exam Upload Instructions (or notice when email arrives and do something)
Ignore += $(wildcard Bio_3SS3*.pdf) 
Ignore += $(wildcard final*final.pdf) 
final_ship: final.1.final.pdf final.2.final.pdf final.2.final.pdf final.4.final.pdf ;
final_upload: final_ship Bio_3SS3_C01_V1.pdf Bio_3SS3_C01_V2.pdf Bio_3SS3_C01_V3.pdf Bio_3SS3_C01_V4.pdf
	/bin/cp Bio_3SS3_C01*.pdf ~/Downloads
defer: Bio_3SS3_C01_V5.pdf ;

## Finalizing
## final.1.final.pdf:

Bio_3SS3_C01_V%.pdf: final.%.final.pdf
	$(forcelink)

## 2018 Shipping Screenshot
## downcall pulldir/ship.png ##
## "Forgot" to re-screenshot (uploaded extra files)

######################################################################

Ignore += $(resting)

-include $(ms)/texdeps.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
