#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/sunlight-research-ai/sunlight-skills.git"
RAW_URL="https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main"
TARGET="auto"
API_KEY_SETUP="auto"

usage() {
  cat <<'EOF'
Install Sunlight Skills.

Usage:
  install.sh [--target auto|codex|claude|opencode|all] [--no-api-key-setup]
  install.sh --api-key-setup-only

Targets:
  auto      Install into detected skill directories, or all defaults if none exist
  codex     ${CODEX_HOME:-$HOME/.codex}/skills
  claude    $HOME/.claude/skills
  opencode  $HOME/.config/opencode/skills
  all       all supported targets

Options:
  --no-api-key-setup   Skip interactive Linkup, Exa, and Tavily key setup
  --api-key-setup-only Run only interactive API key setup
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
    --no-api-key-setup)
      API_KEY_SETUP="skip"
      shift
      ;;
    --api-key-setup-only)
      API_KEY_SETUP="only"
      shift
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

tty_path() {
  printf '%s\n' "${SUNLIGHT_SKILLS_TTY:-/dev/tty}"
}

has_tty() {
  local tty
  tty="$(tty_path)"
  [[ -r "$tty" && -w "$tty" ]] || [[ -t 0 && -t 1 ]]
}

tty_print() {
  local tty
  tty="$(tty_path)"
  if [[ -r "$tty" && -w "$tty" ]]; then
    printf '%s' "$1" >"$tty"
  else
    printf '%s' "$1" >&2
  fi
}

tty_println() {
  local tty
  tty="$(tty_path)"
  if [[ -r "$tty" && -w "$tty" ]]; then
    printf '%s\n' "$1" >"$tty"
  else
    printf '%s\n' "$1" >&2
  fi
}

tty_read() {
  local __var="$1"
  local tty
  local value=""
  tty="$(tty_path)"
  if [[ -r "$tty" && -w "$tty" ]]; then
    IFS= read -r value <"$tty" || value=""
  else
    IFS= read -r value || value=""
  fi
  printf -v "$__var" '%s' "$value"
}

tty_read_secret() {
  local __var="$1"
  local tty
  local value=""
  local char=""
  tty="$(tty_path)"
  if [[ -r "$tty" && -w "$tty" ]]; then
    while IFS= read -r -s -n 1 char <"$tty"; do
      case "$char" in
        $'\n'|$'\r')
          break
          ;;
        $'\177'|$'\b')
          if [[ -n "$value" ]]; then
            value="${value%?}"
            tty_print $'\b \b'
          fi
          ;;
        *)
          value+="$char"
          tty_print "*"
          ;;
      esac
    done
  else
    IFS= read -r value || value=""
  fi
  printf -v "$__var" '%s' "$value"
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-Y}"
  local answer=""
  local suffix="[y/N]"
  if [[ "$default" == "Y" ]]; then
    suffix="[Y/n]"
  fi

  while true; do
    tty_print "$prompt $suffix "
    tty_read answer
    case "$answer" in
      "")
        [[ "$default" == "Y" ]]
        return
        ;;
      y|Y|yes|YES|Yes)
        return 0
        ;;
      n|N|no|NO|No)
        return 1
        ;;
      *)
        tty_println "Please answer y or n."
        ;;
    esac
  done
}

prompt_secret() {
  local __var="$1"
  local prompt="$2"
  local secret_value=""
  tty_print "$prompt"
  tty_read_secret secret_value
  tty_println ""
  printf -v "$__var" '%s' "$secret_value"
}

redacted_preview() {
  local value="$1"
  local length="${#value}"
  if [[ "$length" -le 8 ]]; then
    printf 'set'
  else
    printf '%s...%s' "${value:0:4}" "${value: -4}"
  fi
}

shell_quote() {
  local value="$1"
  printf "'%s'" "${value//\'/\'\\\'\'}"
}

profile_path() {
  case "$(basename "${SHELL:-}")" in
    zsh) printf '%s\n' "$HOME/.zshrc" ;;
    bash) printf '%s\n' "$HOME/.bashrc" ;;
    *)
      if [[ -e "$HOME/.zshrc" ]]; then
        printf '%s\n' "$HOME/.zshrc"
      elif [[ -e "$HOME/.bashrc" ]]; then
        printf '%s\n' "$HOME/.bashrc"
      else
        printf '%s\n' "$HOME/.profile"
      fi
      ;;
  esac
}

write_api_key_block() {
  local profile="$1"
  local linkup_key="$2"
  local exa_key="$3"
  local tavily_key="$4"
  local tmp_file

  mkdir -p "$(dirname "$profile")"
  touch "$profile"
  tmp_file="$(mktemp)"

  awk '
    /^# >>> sunlight-skills api keys >>>$/ { skip = 1; next }
    /^# <<< sunlight-skills api keys <<<$/ { skip = 0; next }
    skip != 1 { print }
  ' "$profile" >"$tmp_file"

  {
    printf '\n# >>> sunlight-skills api keys >>>\n'
    if [[ -n "$linkup_key" ]]; then
      printf 'export LINKUP_API_KEY=%s\n' "$(shell_quote "$linkup_key")"
    else
      printf '# LINKUP_API_KEY skipped\n'
    fi
    if [[ -n "$exa_key" ]]; then
      printf 'export EXA_API_KEY=%s\n' "$(shell_quote "$exa_key")"
    else
      printf '# EXA_API_KEY skipped\n'
    fi
    if [[ -n "$tavily_key" ]]; then
      printf 'export TAVILY_API_KEY=%s\n' "$(shell_quote "$tavily_key")"
    else
      printf '# TAVILY_API_KEY skipped\n'
    fi
    printf '# <<< sunlight-skills api keys <<<\n'
  } >>"$tmp_file"

  mv "$tmp_file" "$profile"
}

prompt_provider_key() {
  local __var="$1"
  local provider="$2"
  local env_var="$3"
  local description="$4"
  local url="$5"
  local existing="${!env_var:-}"
  local value=""

  tty_println ""
  tty_println "$provider"
  tty_println "$description"
  tty_println "Get a key: $url"
  tty_println ""

  if [[ -n "$existing" ]]; then
    if prompt_yes_no "Use existing $env_var ($(redacted_preview "$existing"))?" "Y"; then
      tty_println "Saved $provider."
      printf -v "$__var" '%s' "$existing"
      return
    fi
  elif ! prompt_yes_no "Set up $provider now?" "Y"; then
    tty_println "Skipped $provider."
    printf -v "$__var" ''
    return
  fi

  prompt_secret value "Enter $env_var: "
  if [[ -z "$value" ]]; then
    tty_println "Skipped $provider."
    printf -v "$__var" ''
    return
  fi

  tty_println "Saved $provider."
  printf -v "$__var" '%s' "$value"
}

run_api_key_setup() {
  local linkup_key=""
  local exa_key=""
  local tavily_key=""
  local profile=""

  if ! has_tty; then
    cat <<'EOF'

Skipping interactive API key setup because no terminal is available.
Run later with:
  curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --api-key-setup-only
EOF
    return
  fi

  tty_println ""
  tty_println "Sunlight research setup"
  tty_println ""
  tty_println "Optional search providers make sunlight-deepresearch more thorough."
  tty_println "You can skip any provider and still use default web_search."

  prompt_provider_key linkup_key "Linkup" "LINKUP_API_KEY" "Additional web search, fetch, and AI-oriented research coverage." "https://app.linkup.so/"
  prompt_provider_key exa_key "Exa" "EXA_API_KEY" "Semantic search, community threads, user sentiment, and quote retrieval." "https://dashboard.exa.ai/"
  prompt_provider_key tavily_key "Tavily" "TAVILY_API_KEY" "Fresh web, news, product pages, changelogs, and release notes." "https://app.tavily.com/"

  if [[ -z "$linkup_key" && -z "$exa_key" && -z "$tavily_key" ]]; then
    tty_println ""
    tty_println "No API keys saved. sunlight-deepresearch will use default web_search."
    return
  fi

  profile="$(profile_path)"
  write_api_key_block "$profile" "$linkup_key" "$exa_key" "$tavily_key"

  tty_println ""
  tty_println "Saved API key exports to:"
  tty_println "  $profile"
  tty_println ""
  tty_println "Next:"
  tty_println "  source $profile"
  tty_println ""
  tty_println "Then start your agent from that shell."
  tty_println ""
  tty_println "For Codex:"
  tty_println "  codex --search"
  tty_println ""
  tty_println "sunlight-deepresearch will use default web_search plus any configured providers, then merge and deduplicate sources."
}

main() {
  if [[ "$API_KEY_SETUP" != "only" ]]; then
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

    if [[ -z "${SUNLIGHT_SKILLS_SOURCE_DIR:-}" ]]; then
      rm -rf "$(dirname "$repo_path")"
    fi

    echo ""
    echo "Done."
  fi

  if [[ "$API_KEY_SETUP" != "skip" ]]; then
    run_api_key_setup
  fi

  cat <<'EOF'

Try:
  Use the sunlight-deepresearch skill to run deep research on a topic.
EOF
}

main
