# features.inc.mk

# Loop over FEATURES
$(foreach f,$(FEATURES), \
  $(eval FEATURES_INCLUDES += features/$f) \
  $(call debug,FEATURE_$(call uc,$f) := Y) \
  $(eval FEATURE_$(call uc,$f) := Y) \
)

$(call F_INCLUDE_FILES,$(FEATURES_INCLUDES))
