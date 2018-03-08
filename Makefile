
## Todo: make private (bitbucket) repo for mark tracking

# Tests
## Includes test and marking machinery (because both depend on scramble stuff)
## Give this some thought
## It's basically terrible, since we're routinely pushing to web from a directory that has confidential info

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

Sources += material
mdirs += material

material:
	git submodule add -b master https://github.com/Bio3SS/Evaluation_materials $@

material/%: 
	$(MAKE) material
	$(makethere)

## Make this more init-y.
Sources += assign
mdirs += assign
assign:
	git submodule add -b master https://github.com/Bio3SS/Assignments $@

assign/%: 
	$(MAKE) assign
	$(makethere)

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

final.bank: final.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank material/pred.bank material/disease.bank
	$(cat)

## %.bank.test: %.bank null.tmp bank.select.fmt $(ms)/talk/lect.pl
##	$(PUSH)

######################################################################

midterm2.1.mc:

# MC selection

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

######################################################################

# Test key
.PRECIOUS: %.ssv

Ignore += *.ssv
midterm%.ssv: midterm%.mc key.pl
	$(PUSH)

# Make a special answer key for scantron processing
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

midterm2.3.key.pdf: material/structure.short

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
	## Did I actually do that or not? -- No.
## Add manual coding (unreadable) scantron
Ignore += *.responses.tsv
midterm1.responses.tsv: pulldir/m1disk/BIOLOGY3SS315FEB2018.dlm pulldir/m1.manual.tsv
	$(cat)

## Student scores from scantron ofice
## Use WebCT file for scores instead of rounded proportions
Ignore += midterm1.office.csv
midterm1.office.csv: pulldir/m1disk/StudentScoresWebCT.csv Makefile
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## Re-score here (gives us control over version errors)
	## Also confidence to do analysis later
## midterm1.scores.Rout: midterm1.responses.tsv midterm1.ssv midterm1.orders scores.R
%.scores.Rout: %.responses.tsv %.ssv %.orders scores.R
	$(run-R)

## Compare

## All comparisons match for everyone with a version…
## This means we should just use bestScore, for everyone with a version 
## midterm1.scorecomp.Rout: midterm1.office.csv midterm1.scores.Rout scorecomp.R
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)

## Patch scantron issues
## midterm1.patch.Rout: midterm1.patch.csv midterm1.scorecomp.Rout idpatch.R
## One person left a number out of their idnum
Sources += midterm1.patch.csv
%.patch.Rout: %.patch.csv %.scorecomp.Rout idpatch.R
	$(run-R)

## Merge SA, MSAF and MC information
## This needs to be rethought when we attempt to record version info
## systematically
## Check again that there are no version issues before using bestScore
## If versions are recorded systematically, we can match upstream and use score
midterm1.merge.Rout: pulldir/marks1.tsv midterm1.patch.Rout merge1.R
	$(run-R)

## Make a file for Avenue
Sources += avenue.csv 

midterm1.avenue.Rout: midterm1.merge.Rout avenue1.R
	$(run-R)

midterm1.avenue.Rout.csv: avenue1.R

######################################################################

## Question analysis

## Need to unscramble and other nonsense; there is still stuff in content

######################################################################

pushdir = web/materials

web:
	git submodule add -b master https://github.com/Bio3SS/Bio3SS.github.io.git $@

mdirs += web

######################################################################

midterm1.1.exam.pdf:

## Print versions and printing

Sources += $(wildcard *.front.tex)

## Add cover pages and such
Ignore += *.exam.tex *.exam.pdf *.front.pdf
midterm1.%.exam.pdf: midterm.front.pdf midterm1.%.test.pdf
	$(pdfcat)

midterm2.%.exam.pdf: midterm.front.pdf midterm2.%.test.pdf
	$(pdfcat)

final.%.exam.pdf: final.front.pdf final.%.final.pdf
	$(pdfcat)

## http://printpal.mcmaster.ca/
## account # 206000301032330000

midterm1.3.test.pdf:

midterm1_ship: midterm1.1.exam.pdf midterm1.2.exam.pdf midterm1.3.exam.pdf midterm1.4.exam.pdf midterm1.5.exam.pdf

midterm1_post: midterm1.1.test.pdf.pd midterm1.2.test.pdf.pd midterm1.3.test.pdf.pd midterm1.4.test.pdf.pd midterm1.5.test.pdf.pd

midterm1_keys: midterm1.1.key.pdf.pd midterm1.2.key.pdf.pd midterm1.3.key.pdf.pd midterm1.4.key.pdf.pd midterm1.5.key.pdf.pd

######################################################################

-include $(ms)/texdeps.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
