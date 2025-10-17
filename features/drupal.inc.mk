# features/drupal.inc.mk
FEATURE_DRUPAL := Y

# Set composer and drush commands
COMPOSER_CMD_EXAMPLE = $(MAKE_USER_COMMAND) \"ARGS=[CMD ...]\" composer\\nex: $(MAKE_USER_COMMAND) \"ARGS=update -W\" composer
DRUSH_CMD_EXAMPLE = \"ARGS=[CMD ...]\" drush\\nex: $(MAKE_USER_COMMAND) \"ARGS=updb -y\" drush
ifeq ($(IS_MZKE),YES)
	COMPOSER_CMD_EXAMPLE = $(MAKE_USER_COMMAND) composer [CMD ...]\\nex: $(MAKE_USER_COMMAND) composer update -W
	DRUSH_CMD_EXAMPLE = $(MAKE_USER_COMMAND) drush [CMD ...]\\nex: $(MAKE_USER_COMMAND) drush updb -y
endif

.PHONY: composer
composer : run ## Run a composer command (composer-help for help)
	docker exec -t -i $(APP)-web-1 /bin/bash -c "composer $($@_ARGS)"

.PHONY: composer-help
composer-help: ## get details about calling composer
	$(info Run Composer commands using the following syntax:)
	@echo $(COMPOSER_CMD_EXAMPLE)

.PHONY: debug-off
debug-off: run ## Disable PHP debugging in the web container
	docker exec -t -i $(APP)-web-1 cp /usr/local/etc/php/php.ini{-production,}
	$(warning "TODO: Disable xdebug in php.ini")
	docker container restart $(APP)-web-1

.PHONY: debug-on
debug-on: run ## Enable PHP debugging in the web container
	docker exec -t -i $(APP)-web-1 cp /usr/local/etc/php/php.ini{-development,}
	$(warning "TODO: Enable xdebug in php.ini")
	docker container restart $(APP)-web-1

.PHONY: drush
drush : run ## Run a drush command (drush-help for help)
	docker exec $(APP)-web-1 /bin/bash -c "cd web; drush $($@_ARGS)"

.PHONY: drush-help
drush-help: ## get details about calling drush
	$(info Drush help)
	@echo $(DRUSH_CMD_EXAMPLE)

.PHONY: sqlc
sqlc: run ## Connect to the MySQL container via the mysql CLI
	docker exec -t -i $(APP)-db-1 mysql -u root -p$(MYSQL_ROOT_PASSWORD) $(APP)

.PHONY: ssh-db
ssh-db: run ## SSH into the db container
	docker exec -t -i $(APP)-db-1 /bin/bash
