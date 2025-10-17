# help.inc.mk

ifdef IS_LINUX
  ANSI_ECHO := echo -e
else
  ANSI_ECHO := echo
endif

.PHONY: help
help: ## Show this help message
	@echo "$(MAKE_USER_COMMAND) targets:"
	@LC_ALL=C $(MAKE_USER_COMMAND) -qp $(addprefix -f ,$(MAKEFILE_LIST)) : 2>/dev/null \
	  | awk -v RS= -F: '$$1 ~ /^[^#. ]+$$/ { print $$1 }' \
	  | sort -u \
	  | xargs -I @ grep -E '^@( ?:| [a-zA-Z_ .%-]+:).*?## ' $(MAKEFILE_LIST) \
	  | sort -u \
	  | while read HELP; do \
			DESC=$$(echo $$HELP | awk -F'## ' '{print $$2}'); \
			if [ -n "$$DESC" ]; then \
				FILE=$$(echo $$HELP | awk -F: '{print $$1}' | sed -e 's,^mk/,,' -e 's,^features/,feat/,' -e 's,\.inc\.mk$$,,'); \
				TARGET=$$(echo $$HELP | awk -F: '{print $$2}'); \
				if [ "$$FILE" != "$$FILE_OLD" ]; then \
					[ "$$FILE_OLD" != "" ] && echo; \
					echo From file: $$FILE; \
					FILE_OLD=$$FILE; \
				fi; \
				VAR=$$(echo $$DESC | grep -o -s '\$$([A-Z_][A-Z0-9_]*)' | head -n 1 | sed -e 's/[$$()]*//g'); \
				if [ -n "$$VAR" ]; then \
					[ 0"$$DEBUG" -ge 2 ] && echo "DEBUG: found variable $$VAR in description"; \
					VAR_VAL=$$($(RUN_MAKE) -s show-val-$$VAR); \
					if [ -n "$$VAR_VAL" ]; then \
						[ 0"$$DEBUG" -ge 2 ] && echo "DEBUG: substituting variable $$VAR with value '$$VAR_VAL' in description"; \
						DESC=$$($(ANSI_ECHO) $$(echo $$DESC | sed -e "s@\$$($${VAR})@\\\033[35m$$VAR_VAL\\\033[0m@g")); \
					fi; \
				fi; \
				printf "\033[36m%-30s\033[0m %s\n" "$$TARGET" "$$DESC"; \
			fi; \
		done

show-var-%: ## Show the value of a make variable.  Usage: make show-var-VARIABLE
	$(info $* = $($*))

show-val-%: ## Show ONLY the value of a make variable.  Usage: make -s show-val-VARIABLE
	$(info $(strip $($*)))
