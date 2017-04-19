msrepo = https://github.com/dushoff
gitroot = ./gitroot
EDIT = pico
export ms = $(gitroot)/makestuff
Drop = ./Dropbox

-include local.mk
-include $(gitroot)/local.mk
export ms = $(gitroot)/makestuff
-include $(ms)/os.mk
