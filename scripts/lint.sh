#!/usr/bin/env bash
# Same static checks as CI (non-zero exit on failure).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

if ! command -v swiftformat >/dev/null 2>&1; then
  echo "error: swiftformat not found. Install: brew install swiftformat" >&2
  exit 1
fi
if ! command -v swiftlint >/dev/null 2>&1; then
  echo "error: swiftlint not found. Install: brew install swiftlint" >&2
  exit 1
fi

swiftformat . --lint --config .swiftformat
swiftlint lint --strict --config .swiftlint.yml
echo "==> lint OK"
