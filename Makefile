BIN_PATH = /usr/bin
PIXMAP_PATH = /usr/share/pixmaps

BIN_FILE = bd.rb
ICON_FILE = bd.svg
BIN_NAME = bd

BINUTILS_FILE = bdutils.rb
BINUTILS_NAME = bdutils

install:
	@echo "I guess you want to install some module in ~/.bd"
	@cp $(BIN_FILE) $(BIN_PATH)/$(BIN_FILE)
	@cp $(BINUTILS_FILE) $(BIN_PATH)/$(BINUTILS_FILE)
	@mkdir -p $(PIXMAP_PATH)/$(BIN_NAME)
	@cp $(ICON_FILE) $(PIXMAP_PATH)/$(BIN_NAME)/$(ICON_FILE)
	@ln -s $(BIN_PATH)/$(BIN_FILE) $(BIN_PATH)/$(BIN_NAME)
	@ln -s $(BIN_PATH)/$(BINUTILS_FILE) $(BIN_PATH)/$(BINUTILS_NAME)
