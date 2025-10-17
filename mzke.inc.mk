# mzke.inc.mk - Configuration for mzke project

# App Name
APP := mzke

# Feature flags - including our new local-install feature
FEATURES := local-install

# Local installation entries for mzke
LOCAL_INSTALL_ENTRIES := \
    src/bin/mzke:/usr/local/bin:0755

# Default target
ALL_TARGET := help