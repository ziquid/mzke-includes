# .env support
ENV := local

ifneq (,$(wildcard ./.env))
    include .env
    DOCKER_RUN_ENV_FILE_SUPPORT := --env-file .env
    export ENV
    FEATURES += $(ENV_FEATURES)
endif


