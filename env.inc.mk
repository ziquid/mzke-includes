# .env support
ENV := local

ifneq (,$(wildcard ./.env))
  include ./.env

  # fix the vars whose value is in double quotes
  ENV_QUOTED_VARS := $(shell grep -E '=".*"' .env | cut -d= -f1)
  $(foreach v,$(ENV_QUOTED_VARS),$(eval $(v) := $(subst ",,$($(v)))))

  DOCKER_RUN_ENV_FILE_SUPPORT := --env-file .env
  export ENV
  FEATURES += $(ENV_FEATURES)
endif
