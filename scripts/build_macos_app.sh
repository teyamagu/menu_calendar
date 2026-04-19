#!/usr/bin/env bash
set -euo pipefail

APP_NAME="MenuCalendar"
BUNDLE_ID="com.teyamagu.menucalendar"
BUILD_DIR=".build/release"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
ICON_SVG="assets/menu_calendar_icon.svg"
ICONSET_DIR=".build/AppIcon.iconset"
ICON_ICNS="assets/AppIcon.icns"

generate_icns_from_svg() {
  if [[ ! -f "${ICON_SVG}" ]]; then
    echo "==> Icon SVG not found. Skip icon generation."
    return
  fi

  echo "==> Generating AppIcon.icns from ${ICON_SVG}"
  rm -rf "${ICONSET_DIR}"
  mkdir -p "${ICONSET_DIR}"

  # Render SVG to PNG at 1024px via QuickLook.
  qlmanage -t -s 1024 -o .build "${ICON_SVG}" >/dev/null 2>&1
  local base_png=".build/$(basename "${ICON_SVG}").png"
  if [[ ! -f "${base_png}" ]]; then
    echo "error: failed to render PNG from SVG: ${ICON_SVG}" >&2
    exit 1
  fi

  cp "${base_png}" "${ICONSET_DIR}/icon_512x512@2x.png"
  sips -z 512 512 "${base_png}" --out "${ICONSET_DIR}/icon_512x512.png" >/dev/null
  sips -z 256 256 "${base_png}" --out "${ICONSET_DIR}/icon_256x256.png" >/dev/null
  sips -z 512 512 "${base_png}" --out "${ICONSET_DIR}/icon_256x256@2x.png" >/dev/null
  sips -z 128 128 "${base_png}" --out "${ICONSET_DIR}/icon_128x128.png" >/dev/null
  sips -z 256 256 "${base_png}" --out "${ICONSET_DIR}/icon_128x128@2x.png" >/dev/null
  sips -z 32 32 "${base_png}" --out "${ICONSET_DIR}/icon_32x32.png" >/dev/null
  sips -z 64 64 "${base_png}" --out "${ICONSET_DIR}/icon_32x32@2x.png" >/dev/null
  sips -z 16 16 "${base_png}" --out "${ICONSET_DIR}/icon_16x16.png" >/dev/null
  sips -z 32 32 "${base_png}" --out "${ICONSET_DIR}/icon_16x16@2x.png" >/dev/null

  iconutil -c icns "${ICONSET_DIR}" -o "${ICON_ICNS}"
  echo "==> Generated ${ICON_ICNS}"
}

echo "==> Building release binary"
swift build -c release --product "${APP_NAME}"
generate_icns_from_svg

BIN_PATH="${BUILD_DIR}/${APP_NAME}"
if [[ ! -f "${BIN_PATH}" ]]; then
  echo "error: binary not found: ${BIN_PATH}" >&2
  exit 1
fi

echo "==> Creating app bundle at ${APP_DIR}"
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"
cp "${BIN_PATH}" "${MACOS_DIR}/${APP_NAME}"

cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>ja</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIconName</key>
  <string>AppIcon</string>
  <key>CFBundleIcons</key>
  <dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
      <key>CFBundleIconFiles</key>
      <array>
        <string>AppIcon</string>
      </array>
    </dict>
  </dict>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
EOF

if [[ -f "${ICON_ICNS}" ]]; then
  cp "${ICON_ICNS}" "${RESOURCES_DIR}/AppIcon.icns"
fi

echo "==> Ad-hoc code signing (bundle integrity / friendlier behavior after unzip)"
codesign --force --deep --sign - "${APP_DIR}"

echo "==> App bundle created: ${APP_DIR}"
echo "Open with: open \"${APP_DIR}\""
