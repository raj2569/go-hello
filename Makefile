PROGRAM_NAME := hello.go
BIN_NAME := go-hello
VERSION := $(shell git rev-list --count main)
COMMIT_HASH := $(shell git rev-parse --short main)
ARCH := amd64
BUILD_DIR := build
BIN_DIR := /usr/bin
CHANGES_FILE := changelog
DEB_FILE := $(BIN_NAME)_$(VERSION).$(COMMIT_HASH)_$(ARCH).deb
REPO_PATH := dists/stable/main/binary

deb: $(DEB_FILE)
	dpkg-deb --build $(BUILD_DIR) $(DEB_FILE)

$(DEB_FILE): $(BUILD_DIR) $(CHANGES_FILE)
	mkdir -p $(BUILD_DIR)/DEBIAN
	mkdir -p $(BUILD_DIR)$(BIN_DIR)
	cp $(BIN_NAME) $(BUILD_DIR)$(BIN_DIR)/$(BIN_NAME)
	cp $(CHANGES_FILE) $(BUILD_DIR)/DEBIAN/changelog
	echo "Package: $(BIN_NAME)" > $(BUILD_DIR)/DEBIAN/control
	echo "Version: $(VERSION)" >> $(BUILD_DIR)/DEBIAN/control
	echo "Architecture: $(ARCH)" >> $(BUILD_DIR)/DEBIAN/control
	echo "Maintainer: mettle mettle@mail.com" >> $(BUILD_DIR)/DEBIAN/control
	echo "Description: A simple go program that prints hello world to stdout" >> $(BUILD_DIR)/DEBIAN/control

$(BUILD_DIR):
	go build -o $(BIN_NAME) $(PROGRAM_NAME)

$(CHANGES_FILE):
	echo "$(BIN_NAME) ($(VERSION).$(COMMIT_HASH)) main;" > $(CHANGES_FILE)
	echo "" >> $(CHANGES_FILE)
	git log -1 --pretty=%B >> $(CHANGES_FILE)
	echo "" >> $(CHANGES_FILE)
	echo "-- mettle mettle@mail.com $(shell date "+%a, %d %b %Y %H:%M:%S %z")" >> $(CHANGES_FILE)


sign: deb
	mkdir -p $(REPO_PATH)
	dpkg-sig --sign builder $(DEB_FILE)
	mv $(DEB_FILE) $(REPO_PATH)
	cd $(REPO_PATH) && apt-ftparchive packages . > Packages && gzip -c Packages > Packages.gz && apt-ftparchive release . > Release && gpg --clearsign -o InRelease Release && gpg -abs -o Release.gpg Release


publish:
	rm -rfv /var/www/html/repo/dists
	cp -r dists /var/www/html/repo/

clean:
	rm -rf dists $(BUILD_DIR) $(DEB_FILE) $(BIN_NAME) $(CHANGES_FILE)

