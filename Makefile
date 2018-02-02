
# Tests
### Hooks for the editor to set the default target
-include target.mk

##################################################################

## Notes

## Experimenting with makestuff as a submodule
## Building final stuff first (no SA)
  ## Need to get somewhere in time for grading

######################################################################

# Crib

Crib = ~/hybrid/3SS/content

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

##################################################################

### Directories

Makefile: talk lect

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

# Make a skeleton to track how questions are scrambled
final.skeleton midterm1.skeleton midterm2.skeleton: %.skeleton: %.test skeleton.pl
	$(PUSH)

# Make files showing the order for versions of a test
midterm1.%.order: midterm2.skeleton scramble.pl
	$(PUSHSTAR)

midterm2.%.order: midterm2.skeleton scramble.pl
	$(PUSHSTAR)

final.%.order: final.skeleton scramble.pl
	$(PUSHSTAR)

.PRECIOUS: %.orders
%.orders: %.1.order %.2.order %.3.order %.4.order %.5.order orders.pl
	$(PUSH)

final.orders:

# Test key
.PRECIOUS: %.ssv
%.ssv: %.test key.pl
	$(PUSH)

######################################################################

## Short answers

# Make combined SA lists for each test
Ignore += *.short.test
midterm1.short.test: material/linear.short material/nonlinear.short 
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
midterm1.1.test.pdf:

## Latex outputs

Sources += test.tmp
%.test.tex: %.test test.tmp test.test.fmt talk/lect.pl
	$(PUSH)

######################################################################

-include $(ms)/texdeps.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
