#!/usr/bin/env bash
# Build a GitHub Release ZIP from the release .app and root LICENSE.
# Usage:
#   ./scripts/package_github_release.sh 1.2.3
#   VERSION=1.2.3 ./scripts/package_github_release.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

VERSION="${1:-${VERSION:-}}"
if [[ -z "${VERSION}" ]]; then
  echo "usage: $0 <version>" >&2
  echo "  example: $0 1.2.3" >&2
  echo "  or: VERSION=1.2.3 $0" >&2
  exit 1
fi

if [[ ! -f "${ROOT_DIR}/LICENSE" ]]; then
  echo "error: LICENSE not found at repo root" >&2
  exit 1
fi

echo "==> Building .app"
"${ROOT_DIR}/scripts/build_macos_app.sh"

APP_PATH="${ROOT_DIR}/dist/MenuCalendar.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "error: app bundle not found: ${APP_PATH}" >&2
  exit 1
fi

ZIP_NAME="MenuCalendar-${VERSION}.zip"
ZIP_PATH="${ROOT_DIR}/dist/${ZIP_NAME}"

echo "==> Creating ${ZIP_PATH}"
rm -f "${ZIP_PATH}"
(
  cd "${ROOT_DIR}/dist"
  zip -r -y "${ZIP_NAME}" MenuCalendar.app
)
zip -u "${ZIP_PATH}" LICENSE

echo "==> SHA256 (paste into Release notes if you like):"
shasum -a 256 "${ZIP_PATH}"

echo "==> Done: ${ZIP_PATH}"
