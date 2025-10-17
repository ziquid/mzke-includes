# base variables

CURDIR_NAME := $(lastword $(subst /, ,$(CURDIR)))

HOST_OS := $(shell uname)
# $(info HOST_OS is $(HOST_OS))

MAKE_USER_COMMAND ?= $(notdir $(MAKE))
RUN_MAKE := $(MAKE) -f $(firstword $(MAKEFILE_LIST))
MAKEVARS = $(shell echo '$(.VARIABLES)' | tr \  \\n | grep -i m.ke)

# $(info ARGS is $(ARGS), MAKECMDGOALS is $(MAKECMDGOALS))
$(MAKECMDGOALS)_ARGS := $(ARGS)
# $(info MAKECMDGOALS_ARGS is $(MAKECMDGOALS)_ARGS is $($(MAKECMDGOALS)_ARGS))

# check git branch -- are we on PROD?
GIT_BRANCH := $(shell git branch --show-current)
PROD_BRANCHES := $(call set_create,main master)
IS_PROD := $(if $(call set_is_member,$(GIT_BRANCH),$(PROD_BRANCHES)),Y,)

ifeq ($(HOST_OS),Darwin)
IS_MAC := Y
endif

ifeq ($(HOST_OS),Linux)
IS_LINUX := Y
endif

# Default verbosity
DEBUG ?= 0

# Functions with levels (must be called via $(call ...))
debug  = $(if $(shell [ $(DEBUG) -ge 1 ] && echo y),$(info $(1)))
debug2 = $(if $(shell [ $(DEBUG) -ge 2 ] && echo y),$(info $(1)))
debug3 = $(if $(shell [ $(DEBUG) -ge 3 ] && echo y),$(info $(1)))

$(foreach var,$(MAKEVARS),$(call debug3,"$(var) = $($(var))"))
