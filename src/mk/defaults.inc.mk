# Defaults file.  For app file, copy to <dir-name>.inc.mk and change relevant vars
# do not put any recipes in here!

# App Name, defaults to dir name
APP := $(lastword $(subst /, ,$(CURDIR)))

# Default container name, defaults to app name
CONTAINER_NAME := $(APP)

# Docker Image needed for this app?  Specify which here.
IMAGE :=

# Feature flags.  Will include mk/<feature>.inc.mk and set
FEATURES := # certs docker drupal image

# CERTS, set the domains for local and dev.  Make sure FEATURES includes "certs".
CERTS_LOCAL_DOMAINS :=
CERTS_DEV_DOMAINS :=

ALL_TARGET := run
