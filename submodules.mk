EDIT = pico
Drop = ./Dropbox
-include local.mk

Makefile: makestuff/Makefile
Sources += makestuff
makestuff/Makefile: %/Makefile:
	git submodule init $*
	git submodule update $*

export ms = ./makestuff
-include $(ms)/os.mk

