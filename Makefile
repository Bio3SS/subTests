
# Tests
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

# MC selection

.PRECIOUS: %.mc
Ignore += *.mc
%.mc: %.bank null.tmp %.select.fmt $(ms)/newtalk/lect.pl
	$(PUSH)

# Scramble

Sources += $(wildcard *.pl)

midterm1.%.mc: midterm1.mc scramble.pl
	$(PUSHSTAR)

final.%.test: final.mc scramble.pl
	$(PUSHSTAR)

######################################################################

# Test key
.PRECIOUS: %.ssv

midterm%.ssv: midterm%.mc key.pl
	$(PUSH)

# Make a special answer key for scantron processing
midterm1.1.sc.csv:
%.sc.csv: %.ssv scantron.pl
	$(PUSH)

midterm1.scantron.csv:
midterm2.scantron.csv:
final.scantron.csv:

# Combine a bunch of scantron keys into a file for the processors
final.scantron.csv midterm1.scantron.csv midterm2.scantron.csv: %.scantron.csv: %.1.sc.csv %.2.sc.csv %.3.sc.csv %.4.sc.csv %.5.sc.csv
	$(cat)


######################################################################

## Question matching and automatic marking
# Make a skeleton to track how questions are scrambled
final.skeleton midterm1.skeleton midterm2.skeleton: %.skeleton: %.test skeleton.pl
	$(PUSH)

# Make files showing the order for versions of a test
midterm1.%.order: midterm1.skeleton scramble.pl
	$(PUSHSTAR)

midterm2.%.order: midterm2.skeleton scramble.pl
	$(PUSHSTAR)

final.%.order: final.skeleton scramble.pl
	$(PUSHSTAR)

.PRECIOUS: %.orders
%.orders: %.1.order %.2.order %.3.order %.4.order %.5.order orders.pl
	$(PUSH)

final.orders:


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

midterm1.1.test:
midterm1.1.key.pdf:

## Latex outputs

Sources += test.tmp
Ignore += *.test.tex *.test.pdf
%.test.tex: %.test test.tmp test.test.fmt talk/lect.pl
	$(PUSH)

%.key.tex: %.test test.tmp key.test.fmt talk/lect.pl
	$(PUSH)

## Why is rubric different??
%.rub.tex: %.ksa test.tmp rub.test.fmt talk/lect.pl
	$(PUSH)

######################################################################

midterm1.1.exam.pdf:

## Print version

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

midterm1.3.exam.pdf:

midterm1_ship: midterm1.1.exam.pdf midterm1.2.exam.pdf midterm1.3.exam.pdf midterm1.4.exam.pdf midterm1.5.exam.pdf

######################################################################

-include $(ms)/texdeps.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
