PACKAGE_HASH := $(shell cat "${PWD}/script/sandbox.sha256sum")
PACKAGE_NAME := vorpal-sandbox-$(PACKAGE_HASH).package
PACKAGE_PATH := /var/lib/vorpal/store/$(PACKAGE_NAME)

build: clean
	"${PWD}/script/sandbox.sh"

clean:
	rm -rf $(PACKAGE_PATH)
	rm -rf $(PACKAGE_PATH).tar.zst
	rm -rf "${PWD}/dist"

dist: build
	mkdir -p "${PWD}/dist"
	tar -cvf - -C "$(PACKAGE_PATH)" "${PWD}" | zstd -o "$(PACKAGE_PATH).tar.zst"
	cp $(PACKAGE_PATH).tar.zst "${PWD}/dist/."

list:
	@grep '^[^#[:space:]].*:' Makefile

test-vagrant:
	vagrant destroy --force || true
	vagrant up --provider "vmware_desktop"

update-sha256sum:
	"${PWD}/script/hash_path.sh" "${PWD}" > "${PWD}/script/sandbox.sha256sum"
