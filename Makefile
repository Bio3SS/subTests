
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

# Combined test banks

## Templates
# null is made; list .tmp files here if necessary
# Sources += $(wildcard *.tmp)

## Formulas
Sources += $(wildcard *.formulas)

Ignore += midterm1.bank
midterm1.bank: midterm1.formulas material/linear.bank material/nonlinear.bank material/structure.bank
	$(cat)

Ignore += midterm2.bank
midterm2.bank: midterm2.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank
	$(cat)

final.bank: final.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank material/pred.bank material/disease.bank
	$(cat)

######################################################################

### Formats

Ignore += null.tmp
null.tmp:
	touch $@

%.test.fmt: $(ms)/lect/test.format $(ms)/lect/fmt.pl
	$(PUSHSTAR)

Ignore += *.select.fmt
%.select.fmt: $(ms)/lect/select.format $(ms)/lect/fmt.pl
	$(PUSHSTAR)

######################################################################

%.bank.test: %.bank null.tmp bank.select.fmt $(ms)/talk/lect.pl
	$(PUSH)

final.bank.test:

######################################################################

# Select the multiple choice part of a test
.PRECIOUS: %.mc
Ignore += *.mc
%.mc: %.bank null.tmp %.select.fmt $(ms)/newtalk/lect.pl
	$(PUSH)

######################################################################

# Make combined short lists for each test
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

midterm1.1.test:

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

.PRECIOUS: %.orders
%.orders: %.1.order %.2.order %.3.order %.4.order %.5.order orders.pl
	$(PUSH)

final.orders:

# Test key
.PRECIOUS: %.ssv
%.ssv: %.test key.pl
	$(PUSH)

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk

# -include $(ms)/oldlatex.mk
