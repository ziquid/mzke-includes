# feature/traefik.inc.mk
FEATURE_TRAEFIK := Y

# Is this the actual traefik app?
IS_TRAEFIK := $(filter traefik,$(CONTAINER_NAME))

# Traefik proxy directory (relative to current app)
TRAEFIK_DIR := ../traefik-tests

TRAEFIK_RUNNING := $(shell docker ps -f 'name=traefik' --format '{{.Names}}' \
  | grep -qs '^traefik$$' && echo Y || echo N)

.PHONY: show-traefik-certs
show-traefik-certs: traefik-running ## Show certificates actually served by Traefik
	$(info === Certificates actually served by Traefik ===)
	@curl -k -s -u "$(TRAEFIK_USER):$(TRAEFIK_PASS)" \
      https://$(TRAEFIK_HOST)/api/rawdata 2>/dev/null | \
      jq -r '.routers | to_entries[] | select(.value.tls) | (.value.rule | scan("Host\\(`([^`]*)`\\)") | .[] | split(",")) | .[] | gsub("`"; "")' \
      | sort -u \
	  | while read DOMAIN; do \
	    CERT_INFO=$$(openssl s_client -connect 127.0.0.1:443 \
	      -servername $$DOMAIN </dev/null 2>/dev/null); \
	    if [ $$? -eq 0 ]; then \
	      SUBJECT=$$(echo "$$CERT_INFO" | openssl x509 -subject -noout 2>/dev/null \
	        | sed -e 's,^subject=,,' | tr , \\n | grep -v @ | head -n 1); \
	      [ "$$SUBJECT" = "O=mkcert development certificate" ] && SUBJECT="mkcert"; \
	      [ "$$SUBJECT" = "CN=TRAEFIK DEFAULT CERT" ] && SUBJECT="traefik"; \
	      ISSUER=$$(echo "$$CERT_INFO" | openssl x509 -issuer -noout 2>/dev/null \
	        | sed -e 's,^issuer=,,' -e 's/, /,/g' | tr , \\n | grep ^O= | sed -e 's,^O=,,'); \
		  [ "$$ISSUER" = "mkcert development CA" -a "$$SUBJECT" = "mkcert" ] && ISSUER= ; \
	      printf "%-8s %s (%s)\n" "$$SUBJECT:" "$$DOMAIN" "$$ISSUER"; \
	    fi; \
	  done | sort -u

.PHONY: show-traefik-hosts
show-traefik-hosts: traefik-running ## Show all enabled hosts on Traefik server
	$(info === All enabled hosts on Traefik server ===)
	@curl -k -s -u "$(TRAEFIK_USER):$(TRAEFIK_PASS)" \
	  https://$(TRAEFIK_HOST)/api/rawdata 2>/dev/null | \
	  jq -r '.routers | to_entries[] | select(.value.status == "enabled") | (.value.rule | scan("Host\\(`([^`]*)`\\)") | .[] | split(",")) | .[] | gsub("`"; "")' \
	  | sort -u

.PHONY: traefik-running
traefik-running:
	$(call debug,Traefik is running? $(TRAEFIK_RUNNING))
ifeq ($(TRAEFIK_RUNNING),N)
	$(error Please start Traefik and try again)
endif
