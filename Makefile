VERSION = $(patsubst "%",%, $(word 3, $(shell grep version Cargo.toml)))
BUILD_TIME = $(shell date +"%Y/%m/%d %H:%M:%S")
GIT_REVISION = $(shell git log -1 --format="%h")
RUST_VERSION = $(word 2, $(shell rustc -V))
LONG_VERSION = "$(VERSION) ( rev: $(GIT_REVISION), rustc: $(RUST_VERSION), build at: $(BUILD_TIME) )"
BIN_NAME = svls

export LONG_VERSION

.PHONY: all test clean release_lnx release_win release_mac

all: test

test:
	cargo test

watch:
	cargo watch test

clean:
	cargo clean

release_lnx:
	cargo build --release --target=x86_64-unknown-linux-musl
	zip -j ${BIN_NAME}-v${VERSION}-x86_64-lnx.zip target/x86_64-unknown-linux-musl/release/${BIN_NAME}

release_win:
	cargo build --release --target=x86_64-pc-windows-msvc
	7z a ${BIN_NAME}-v${VERSION}-x86_64-win.zip target/x86_64-pc-windows-msvc/release/${BIN_NAME}.exe

release_mac_x86_64:
	cargo build --release --target=x86_64-apple-darwin
	zip -j ${BIN_NAME}-v${VERSION}-x86_64-mac.zip target/x86_64-apple-darwin/release/${BIN_NAME}

release_mac_arm64:
	cargo build --release --target=aarch64-apple-darwin
	zip -j ${BIN_NAME}-v${VERSION}-arm64-mac.zip target/aarch64-apple-darwin/release/${BIN_NAME}

release_mac: release_mac_x86_64 release_mac_arm64
	mkdir -p target/apple-darwin/release
	lipo -create -output target/apple-darwin/release/${BIN_NAME} target/x86_64-apple-darwin/release/${BIN_NAME} target/aarch64-apple-darwin/release/${BIN_NAME}
	zip -j ${BIN_NAME}-v${VERSION}-mac.zip target/apple-darwin/release/${BIN_NAME}
