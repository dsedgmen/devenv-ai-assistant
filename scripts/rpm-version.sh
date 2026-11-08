#!/usr/bin/env bash
# Derive RPM Version / Release / channel from git ref / GitHub Actions env.
#
# Channels:
#   stable  — tag vX.Y.Z or X.Y.Z
#   rc      — tag vX.Y.Z-rc.N / X.Y.Z-rc.N  OR  branch release/* / release-*
#   beta    — branch main / untagged commits / no-git fallback (COPR SCM)
#
# Usage:
#   ./scripts/rpm-version.sh              # human-readable
#   ./scripts/rpm-version.sh --shell      # VERSION=... RELEASE=... CHANNEL=...
#   ./scripts/rpm-version.sh --github-env # append to $GITHUB_OUTPUT
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="$(tr -d '[:space:]' < "$ROOT/VERSION")"
[[ "$BASE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "VERSION file must be X.Y.Z, got: $BASE" >&2
  exit 1
}

DATE="$(date -u +%Y%m%d)"

# Default = beta snapshot (never silent 1.1.0-1 unless on a stable tag).
VERSION="$BASE"
CHANNEL="beta"
SHORT="unknown"
RELEASE="0.${DATE}git${SHORT}.beta"
DIST_VERSION="$VERSION"

git_ok() {
  command -v git >/dev/null 2>&1 &&
    git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

on_main_line() {
  local name="$1"
  [[ "$name" == main || "$name" == master ]] && return 0
  git -C "$ROOT" rev-parse --verify -q origin/main >/dev/null 2>&1 &&
    git -C "$ROOT" merge-base --is-ancestor HEAD origin/main 2>/dev/null &&
    [[ "$(git -C "$ROOT" rev-parse HEAD)" == "$(git -C "$ROOT" rev-parse origin/main)" ]] &&
    return 0
  git -C "$ROOT" rev-parse --verify -q main >/dev/null 2>&1 &&
    [[ "$(git -C "$ROOT" rev-parse HEAD)" == "$(git -C "$ROOT" rev-parse main)" ]] &&
    return 0
  return 1
}

# Apply REF / REF_NAME / SHORT → VERSION, RELEASE, CHANNEL
apply_ref() {
  local REF="$1" REF_NAME="$2"

  if [[ "$REF" == refs/tags/* ]]; then
    local TAG="${REF_NAME:-${REF#refs/tags/}}"
    if [[ "$TAG" =~ ^v?([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
      CHANNEL="stable"
      VERSION="${BASH_REMATCH[1]}"
      RELEASE="1"
    elif [[ "$TAG" =~ ^v?([0-9]+\.[0-9]+\.[0-9]+)-rc\.([0-9]+)$ ]]; then
      CHANNEL="rc"
      VERSION="${BASH_REMATCH[1]}"
      RELEASE="0.${BASH_REMATCH[2]}.rc${BASH_REMATCH[2]}git${SHORT}"
    else
      echo "Unsupported tag '$TAG' (use X.Y.Z, vX.Y.Z, or …-rc.N)" >&2
      exit 1
    fi
  elif [[ "$REF" == refs/heads/release/* || "$REF_NAME" == release/* || "$REF_NAME" == release-* ]]; then
    CHANNEL="rc"
    VERSION="$BASE"
    RELEASE="0.${DATE}git${SHORT}.rc"
  elif [[ "$REF_NAME" == main || "$REF_NAME" == master ]]; then
    CHANNEL="beta"
    VERSION="$BASE"
    RELEASE="0.${DATE}git${SHORT}.beta"
  elif git_ok && on_main_line "$REF_NAME"; then
    CHANNEL="beta"
    VERSION="$BASE"
    RELEASE="0.${DATE}git${SHORT}.beta"
  else
    CHANNEL="beta"
    VERSION="$BASE"
    local SAFE_BRANCH
    SAFE_BRANCH="$(echo "$REF_NAME" | tr '/_' '-' | tr -cd '[:alnum:].-' | cut -c1-32)"
    RELEASE="0.${DATE}git${SHORT}.${SAFE_BRANCH:-snap}"
  fi
  DIST_VERSION="$VERSION"
}

REF="${GITHUB_REF:-}"
REF_NAME="${GITHUB_REF_NAME:-}"
SHA="${GITHUB_SHA:-}"

if git_ok; then
  SHA="${SHA:-$(git -C "$ROOT" rev-parse HEAD)}"
  SHORT="$(echo "$SHA" | cut -c1-7)"
  RELEASE="0.${DATE}git${SHORT}.beta"

  if [[ -z "$REF" ]]; then
    if git -C "$ROOT" describe --exact-match --tags HEAD >/dev/null 2>&1; then
      REF_NAME="$(git -C "$ROOT" describe --exact-match --tags HEAD)"
      REF="refs/tags/$REF_NAME"
    else
      REF_NAME="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
      if [[ "$REF_NAME" == HEAD ]]; then
        if on_main_line HEAD; then
          REF_NAME="main"
        elif git -C "$ROOT" rev-parse --verify -q origin/main >/dev/null 2>&1 &&
          git -C "$ROOT" merge-base --is-ancestor HEAD origin/main 2>/dev/null; then
          REF_NAME="main"
        else
          REF_NAME="$(
            git -C "$ROOT" for-each-ref --format='%(refname:short)' --contains HEAD \
              refs/heads refs/remotes 2>/dev/null |
              sed -e 's#^origin/##' |
              grep -Ev '^(HEAD|origin)$' |
              head -n1 || true
          )"
          REF_NAME="${REF_NAME:-snap}"
        fi
      fi
      REF="refs/heads/$REF_NAME"
    fi
  fi
  apply_ref "$REF" "$REF_NAME"
elif [[ -n "$REF" ]]; then
  # GitHub Actions container checkout without .git still sets GITHUB_REF
  if [[ -n "$SHA" ]]; then
    SHORT="$(echo "$SHA" | cut -c1-7)"
  fi
  REF_NAME="${REF_NAME:-${REF##*/}}"
  echo "rpm-version.sh: no .git; using GITHUB_REF=$REF" >&2
  apply_ref "$REF" "$REF_NAME"
else
  echo "rpm-version.sh: no git metadata and no GITHUB_REF; beta snapshot ${VERSION}-${RELEASE}" >&2
fi

case "${1:-}" in
  --shell)
    printf 'VERSION=%q\nRELEASE=%q\nCHANNEL=%q\nDIST_VERSION=%q\n' \
      "$VERSION" "$RELEASE" "$CHANNEL" "$DIST_VERSION"
    ;;
  --github-env)
    {
      echo "version=$VERSION"
      echo "release=$RELEASE"
      echo "channel=$CHANNEL"
      echo "dist_version=$DIST_VERSION"
      echo "rpm_evr=${VERSION}-${RELEASE}"
    } >> "${GITHUB_OUTPUT:?GITHUB_OUTPUT not set}"
    echo "channel=$CHANNEL version=$VERSION-$RELEASE"
    ;;
  *)
    echo "channel=$CHANNEL"
    echo "version=$VERSION"
    echo "release=$RELEASE"
    echo "evr=${VERSION}-${RELEASE}"
    ;;
esac
