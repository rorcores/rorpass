#!/bin/bash
set -e

APP_NAME="RorPass"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
ARCH=$(uname -m)

echo "Building $APP_NAME for $ARCH..."

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    -target "${ARCH}-apple-macosx14.0" \
    -O \
    Sources/main.swift

cp Info.plist "$APP_BUNDLE/Contents/"
cp AppIcon.icns "$APP_BUNDLE/Contents/Resources/"

echo ""
echo "Built $APP_BUNDLE"
echo ""
echo "  Run:      open $APP_BUNDLE"
echo "  Install:  cp -r $APP_BUNDLE /Applications/"
