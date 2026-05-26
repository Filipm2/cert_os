#!/usr/bin/env bash
# Compute SHA-256 of every file in dist/ and write dist/SHA256SUMS.txt.
#
# Run from the build/ directory after build_mac.sh:
#   ./make_checksums.sh

set -euo pipefail

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$BUILD_DIR/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"
OUTPUT="$DIST_DIR/SHA256SUMS.txt"

if [ ! -d "$DIST_DIR" ]; then
    echo "dist/ does not exist at $DIST_DIR. Run a build first." >&2
    exit 1
fi

if command -v shasum >/dev/null 2>&1; then
    HASH_CMD=(shasum -a 256)
elif command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD=(sha256sum)
else
    echo "Need shasum or sha256sum on PATH." >&2
    exit 1
fi

cd "$DIST_DIR"
# List every file under dist/ except the checksums file itself, hash it,
# and write relative paths to SHA256SUMS.txt.
find . -type f ! -name 'SHA256SUMS.txt' -print0 |
    sort -z |
    xargs -0 "${HASH_CMD[@]}" > "$OUTPUT"

echo "Wrote $OUTPUT"
cat "$OUTPUT"
