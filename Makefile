# Tests
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: final.bank 

##################################################################

## Notes

## Experimenting with makestuff as a submodule

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
# include $(ms)/perl.def

##################################################################

## Submodules

Sources += material

material:
	git submodule add git@github.com:Bio3SS/Evaluation_materials.git $@

Sources += makestuff
makestuff:
	git submodule add git@github.com:dushoff/$@.git

	git submodule deinit Evaluation_materials
		git rm Evaluation_materials


##################################################################
# Combined test banks

## Templates
Sources += $(wildcard *.tmp)

## Formulas
Sources += $(wildcard *.formulas)

midterm1.bank: midterm1.formulas material/linear.bank material/nonlinear.bank material/structure.bank
	$(cat)

midterm2.bank.key.pdf:
midterm2.bank: midterm2.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank
	$(cat)

final.bank: final.formulas material/linear.bank material/nonlinear.bank material/structure.bank material/life_history.bank material/comp.bank material/pred.bank material/disease.bank
	$(cat)

%.bank.test: %.bank null.tmp bank.select.fmt $(ms)/talk/lect.pl
	$(PUSH)

final.bank.test:

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk

-include $(ms)/wrapR.mk

# -include $(ms)/oldlatex.mk
