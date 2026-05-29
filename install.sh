#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="build-cursorignore"
CURSOR_SKILLS_DIR="${HOME}/.cursor/skills"
INSTALL_DIR="${CURSOR_SKILLS_DIR}/${SKILL_NAME}"
REPO_URL="https://github.com/Tlkh201313/Build-cursorignore-skill-v2.git"

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

# Check git
if ! command -v git &>/dev/null; then
  echo "Error: git is required. Install git and try again." >&2
  exit 1
fi

mkdir -p "${CURSOR_SKILLS_DIR}"

if [ -d "${INSTALL_DIR}" ]; then
  rm -rf "${INSTALL_DIR}"
  echo "Removed existing installation"
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

git clone --depth 1 "${REPO_URL}" "${TMPDIR}/${SKILL_NAME}" 2>/dev/null

if [ ! -f "${TMPDIR}/${SKILL_NAME}/SKILL.md" ]; then
  echo "Error: Clone succeeded but SKILL.md not found" >&2
  exit 1
fi

cp -r "${TMPDIR}/${SKILL_NAME}" "${INSTALL_DIR}"
echo "Installed to ${INSTALL_DIR}"
echo "Run /build-cursorignore in Cursor Agent to use."
