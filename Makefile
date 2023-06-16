SHELL = bash
UUID = wireless-hid@chlumskyvaclav.gmail.com

BUILD_DIR ?= build
UI_FILES = $(wildcard ./extension/ui/gtk3/*.ui)
PNG_FILES = $(wildcard ./docs/*.png)
RAW_PATH = "$(BUILD_DIR)/$(UUID).shell-extension.zip"
BUNDLE_PATH = "$(BUILD_DIR)/$(UUID).zip"

.PHONY: build package check release gtk4 install uninstall clean

build: clean
	@mkdir -p $(BUILD_DIR)
	glib-compile-schemas --strict extension/schemas --targetdir $(BUILD_DIR)
	$(MAKE) package
	@mv -v $(RAW_PATH) $(BUNDLE_PATH)
package:
	@mkdir -p $(BUILD_DIR)
	@echo "Packing files..."
	@cd "extension"; \
	gnome-extensions pack --force \
	--extra-source=../LICENSE \
	--extra-source=../CHANGELOG.md \
	--extra-source=../README.md \
	--extra-source=ui/ \
	--extra-source=wirelesshid.js \
	--extra-source=prefs.css \
	-o ../$(BUILD_DIR)/
check:
	@if [[ ! -f $(BUNDLE_PATH) ]]; then \
	  echo -e "\nWARNING! Extension zip couldn't be found"; exit 1; \
	elif [[ "$$(stat -c %s $(BUNDLE_PATH))" -gt 4096000 ]]; then \
	  echo -e "\nWARNING! The extension is too big to be uploaded to the extensions website, keep it smaller than 4096 KB"; exit 1; \
	fi
gtk4:
	gtk4-builder-tool simplify --3to4 extension/ui/prefs-gtk3.ui > extension/ui/prefs-gtk4.ui
install:
	@if [[ ! -f $(BUNDLE_PATH) ]]; then \
	  $(MAKE) build; \
	fi
	gnome-extensions install $(BUNDLE_PATH) --force
uninstall:
	gnome-extensions uninstall "$(UUID)"
clean:
	@rm -rfv $(BUILD_DIR)
	@rm -rfv "$(UUID).zip"
	@rm -rfv extension/ui/*.ui~ extension/ui/*.ui#
