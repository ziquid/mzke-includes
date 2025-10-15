# base functions

# F_INCLUDE_FILES -- include the relevate file(s)
F_INCLUDE_FILES = \
  $(foreach f,$(strip $1), \
    $(call debug,will attempt to include mk/$f.inc.mk) \
    $(if $(filter -%,$f), \
      $(eval -include mk/$(patsubst -%,%,$f).inc.mk), \
      $(eval include  mk/$f.inc.mk) \
    ) \
  )
