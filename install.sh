#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/sunlight-research-ai/sunlight-skills.git"
RAW_URL="https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main"
TARGET="auto"

usage() {
  cat <<'EOF'
Install Sunlight Skills.

Usage:
  install.sh [--target auto|codex|claude|opencode|all]

Targets:
  auto      Install into detected skill directories, or all defaults if none exist
  codex     ${CODEX_HOME:-$HOME/.codex}/skills
  claude    $HOME/.claude/skills
  opencode  $HOME/.config/opencode/skills
  all       all supported targets
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$TARGET" in
  auto|codex|claude|opencode|all) ;;
  *)
    echo "Invalid target: $TARGET" >&2
    usage >&2
    exit 1
    ;;
esac

codex_dir="${CODEX_HOME:-$HOME/.codex}/skills"
claude_dir="$HOME/.claude/skills"
opencode_dir="$HOME/.config/opencode/skills"

targets_for() {
  case "$TARGET" in
    codex) printf '%s\n' "codex:$codex_dir" ;;
    claude) printf '%s\n' "claude:$claude_dir" ;;
    opencode) printf '%s\n' "opencode:$opencode_dir" ;;
    all)
      printf '%s\n' "codex:$codex_dir" "claude:$claude_dir" "opencode:$opencode_dir"
      ;;
    auto)
      found=0
      if [[ -d "$codex_dir" ]]; then printf '%s\n' "codex:$codex_dir"; found=1; fi
      if [[ -d "$claude_dir" ]]; then printf '%s\n' "claude:$claude_dir"; found=1; fi
      if [[ -d "$opencode_dir" ]]; then printf '%s\n' "opencode:$opencode_dir"; found=1; fi
      if [[ "$found" -eq 0 ]]; then
        printf '%s\n' "codex:$codex_dir" "claude:$claude_dir" "opencode:$opencode_dir"
      fi
      ;;
  esac
}

download_repo() {
  if [[ -n "${SUNLIGHT_SKILLS_SOURCE_DIR:-}" ]]; then
    printf '%s\n' "$SUNLIGHT_SKILLS_SOURCE_DIR"
    return
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 "$REPO_URL" "$tmp_dir/repo" >/dev/null 2>&1
  else
    archive="$tmp_dir/sunlight-skills.tar.gz"
    curl -fsSL "https://codeload.github.com/sunlight-research-ai/sunlight-skills/tar.gz/refs/heads/main" -o "$archive"
    mkdir -p "$tmp_dir/repo"
    tar -xzf "$archive" -C "$tmp_dir/repo" --strip-components 1
  fi

  printf '%s\n' "$tmp_dir/repo"
}

copy_skills() {
  src_root="$1"
  dest_root="$2"

  mkdir -p "$dest_root"

  for skill_path in "$src_root"/skills/*; do
    [[ -d "$skill_path" ]] || continue
    skill_name="$(basename "$skill_path")"
    dest="$dest_root/$skill_name"

    if [[ -e "$dest" ]]; then
      backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
      mv "$dest" "$backup"
      echo "Backed up existing $skill_name to $backup"
    fi

    cp -R "$skill_path" "$dest"
    echo "Installed $skill_name -> $dest"
  done
}

main() {
  repo_path="$(download_repo)"
  installed_any=0

  while IFS=: read -r label dir; do
    [[ -n "$label" && -n "$dir" ]] || continue
    echo "Installing for $label..."
    copy_skills "$repo_path" "$dir"
    installed_any=1
  done < <(targets_for)

  if [[ "$installed_any" -eq 0 ]]; then
    echo "No install targets selected." >&2
    exit 1
  fi

  cat <<'EOF'

Done.

Try:
  Use the sunlight-deepresearch skill to run deep research on a topic.
EOF
}

main
