#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="build-cursorignore"
CURSOR_SKILLS_DIR="${HOME}/.cursor/skills"
INSTALL_DIR="${CURSOR_SKILLS_DIR}/${SKILL_NAME}"
REPO_URL="https://github.com/owner/${SKILL_NAME}.git"

uninstall() {
  if [ -d "${INSTALL_DIR}" ]; then
    rm -rf "${INSTALL_DIR}"
    echo "Removed ${INSTALL_DIR}"
  else
    echo "Not installed: ${INSTALL_DIR}"
  fi
  exit 0
}

if [ "${1:-}" = "--uninstall" ]; then
  uninstall
fi

mkdir -p "${CURSOR_SKILLS_DIR}"

if [ -d "${INSTALL_DIR}" ]; then
  rm -rf "${INSTALL_DIR}"
  echo "Removed existing installation"
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

if command -v git &>/dev/null; then
  git clone --depth 1 "${REPO_URL}" "${TMPDIR}/${SKILL_NAME}"
  cp -r "${TMPDIR}/${SKILL_NAME}" "${INSTALL_DIR}"
else
  echo "Error: git is required. Install git and try again."
  exit 1
fi

echo "Installed to ${INSTALL_DIR}"
echo "Run /build-cursorignore in Cursor Agent to use."
