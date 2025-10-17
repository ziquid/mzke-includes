# feature/local-install.inc.mk - Install files to specified directories with permissions
#
# Usage:
# Include this file in your Makefile to add local installation capabilities.
# Define LOCAL_INSTALL_ENTRIES to specify files to install.
#
# Format:
# LOCAL_INSTALL_ENTRIES := source_pattern:destination_directory:permissions
#
# Examples:
# LOCAL_INSTALL_ENTRIES := \
#   src/bin/*:/usr/local/bin:0755 \
#   src/config/*.conf:/etc/myapp:0644 \
#   src/data/*:/usr/local/share/myapp:0644
#
# Features:
# - Supports glob patterns in source files
# - Creates destination directories automatically
# - Sets specified permissions on installed files
# - Provides dry-run capability

FEATURE_LOCAL_INSTALL := Y

# Default entries (empty)
LOCAL_INSTALL_ENTRIES ?=

# Function to process a single installation entry
# Format: source_pattern:destination_directory:permissions
define process-install-entry
	@$(eval SOURCE_PATTERN := $(word 1,$(subst :, ,$1)))
	@$(eval DEST_DIR := $(word 2,$(subst :, ,$1)))
	@$(eval PERMISSIONS := $(word 3,$(subst :, ,$1)))
	
	@echo "Processing entry: $(SOURCE_PATTERN) -> $(DEST_DIR) ($(PERMISSIONS))"
	
	@if [ ! -d "$(DEST_DIR)" ]; then \
		echo "Creating directory $(DEST_DIR)"; \
		mkdir -p "$(DEST_DIR)" 2>/dev/null || echo "Warning: Failed to create directory $(DEST_DIR)"; \
	fi
	
	@for file in $(SOURCE_PATTERN); do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			dest_path="$(DEST_DIR)/$$filename"; \
			echo "Installing $$file to $$dest_path with permissions $(PERMISSIONS)"; \
			cp -f "$$file" "$$dest_path" 2>/dev/null || echo "Warning: Failed to copy $$file to $$dest_path"; \
			chmod "$(PERMISSIONS)" "$$dest_path" 2>/dev/null || echo "Warning: Failed to set permissions $(PERMISSIONS) on $$dest_path"; \
		else \
			echo "Warning: Source file $$file not found"; \
		fi; \
	done
endef

# Function to show what would be installed without actually installing
define show-install-entry
	@$(eval SOURCE_PATTERN := $(word 1,$(subst :, ,$1)))
	@$(eval DEST_DIR := $(word 2,$(subst :, ,$1)))
	@$(eval PERMISSIONS := $(word 3,$(subst :, ,$1)))
	
	@echo "Would process entry: $(SOURCE_PATTERN) -> $(DEST_DIR) ($(PERMISSIONS))"
	
	@for file in $(SOURCE_PATTERN); do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file"); \
			dest_path="$(DEST_DIR)/$$filename"; \
			echo "  Would install $$file to $$dest_path with permissions $(PERMISSIONS)"; \
		else \
			echo "  Warning: Source file $$file not found"; \
		fi; \
	done
endef

# Main installation target
.PHONY: local-install
local-install: ## Install files to local filesystem according to LOCAL_INSTALL_ENTRIES
	@echo "Installing files to local filesystem..."
ifeq ($(LOCAL_INSTALL_ENTRIES),)
	@echo "No installation entries defined. Define LOCAL_INSTALL_ENTRIES in your Makefile."
	@echo "Format: source_pattern:destination_directory:permissions"
	@echo "Example: LOCAL_INSTALL_ENTRIES := src/bin/*:/usr/local/bin:0755"
else
	@$(foreach entry,$(LOCAL_INSTALL_ENTRIES),$(call process-install-entry,$(entry));)
endif
	@echo "Local installation complete."

# Generic install target that delegates to local-install
# This makes 'make install' work when local-install feature is included
.PHONY: install
install: local-install ## Install files to local filesystem (delegates to local-install)

# Dry-run target to preview installations
.PHONY: local-install-dry-run
local-install-dry-run: ## Show what files would be installed without installing them
	@echo "Dry run - would install the following files:"
ifeq ($(LOCAL_INSTALL_ENTRIES),)
	@echo "No installation entries defined. Define LOCAL_INSTALL_ENTRIES in your Makefile."
else
	@$(foreach entry,$(LOCAL_INSTALL_ENTRIES),$(call show-install-entry,$(entry));)
endif
	@echo "Dry run complete."