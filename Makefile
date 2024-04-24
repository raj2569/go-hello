PROGRAM_NAME := hello.go
BIN_NAME := go-hello
VERSION := 1.0
ARCH := amd64
BUILD_DIR := build
BIN_DIR := /usr/bin
DEB_FILE := $(BIN_NAME)_$(VERSION)_$(ARCH).deb

deb: $(DEB_FILE)
	dpkg-deb --build $(BUILD_DIR) $(DEB_FILE)

$(DEB_FILE): $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/DEBIAN
	mkdir -p $(BUILD_DIR)$(BIN_DIR)
	cp $(BIN_NAME) $(BUILD_DIR)$(BIN_DIR)/$(BIN_NAME)
	echo "Package: $(BIN_NAME)" > $(BUILD_DIR)/DEBIAN/control
	echo "Version: $(VERSION)" >> $(BUILD_DIR)/DEBIAN/control
	echo "Architecture: $(ARCH)" >> $(BUILD_DIR)/DEBIAN/control
	echo "Maintainer: mettle mettle@mail.com" >> $(BUILD_DIR)/DEBIAN/control
	echo "Description: A simple go program that prints hello world to stdout" >> $(BUILD_DIR)/DEBIAN/control

$(BUILD_DIR):
	go build -o $(BIN_NAME) $(PROGRAM_NAME)

clean:
	rm -rf $(BUILD_DIR) $(DEB_FILE) $(BIN_NAME)
