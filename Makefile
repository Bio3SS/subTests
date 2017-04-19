# Tests
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: final.orders 

##################################################################

## Notes

## Experimenting with makestuff as a submodule
## Building final stuff first (no SA)
  ## Need to get somewhere in time for grading

######################################################################

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
include $(ms)/perl.def

##################################################################

## Submodules

Sources += material

material:
	git submodule add git@github.com:Bio3SS/Evaluation_materials.git $@

Sources += makestuff
makestuff:
	git submodule add git@github.com:dushoff/$@.git

##################################################################

# Combined test banks

## Templates
# null is made; list .tmp files here if necessary
# Sources += $(wildcard *.tmp)

## Formulas
Sources += $(wildcard *.formulas)

midterm1.bank: midterm1.formulas material/linear.bank material/nonlinear.bank material/structure.bank
	$(cat)

midterm2.bank: midterm2.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank
	$(cat)

final.bank: final.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank material/pred.bank material/disease.bank
	$(cat)

######################################################################

### Formats

null.tmp:
	touch $@

%.test.fmt: $(ms)/lect/test.format $(ms)/lect/fmt.pl
	$(PUSHSTAR)

%.select.fmt: $(ms)/lect/select.format $(ms)/lect/fmt.pl
	$(PUSHSTAR)

######################################################################

%.bank.test: %.bank null.tmp bank.select.fmt $(ms)/talk/lect.pl
	$(PUSH)

final.bank.test:

######################################################################

# Select the multiple choice part of a test
.PRECIOUS: %.mc
%.mc: %.bank null.tmp %.select.fmt $(ms)/talk/lect.pl
	$(PUSH)

######################################################################

# Missing SA rules

######################################################################

### Separator for MC and SA on the same test
Sources += end.dmu

### Combine mc and sa to make the real test

final.test: final.mc
	$(copy)

%.test: %.mc end.dmu %.ksa
	$(cat)

######################################################################

# Scramble

Sources += $(wildcard *.pl)

final.%.test: final.mc scramble.pl
	$(PUSHSTAR)

######################################################################

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

%.orders: %.1.order %.2.order %.3.order %.4.order %.5.order orders.pl
	$(PUSH)

final.orders:

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk

# -include $(ms)/oldlatex.mk
