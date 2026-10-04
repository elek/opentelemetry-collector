#!/usr/bin/env bash
# Usage: ./release.sh <version>   (e.g. ./release.sh 1.9.0)
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="${1#v}"
TAG="v$VERSION"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN is not set" >&2
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: $VERSION (expected X.Y.Z)" >&2
  exit 1
fi

if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
  echo "Not on main branch" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean" >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "Tag $TAG already exists" >&2
  exit 1
fi

# update version in the manifest and regenerate code (main.go embeds the version)
sed -i -E "s/^(  version: ).*/\1$VERSION/" manifest.yaml
./update.sh

git add -A
git commit -m "release: $TAG"
git tag "$TAG"

git push origin main
git push origin "$TAG"

goreleaser release --clean
