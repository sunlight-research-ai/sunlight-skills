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

supports_color() {
  if [[ -n "${FORCE_COLOR:-}" && "${FORCE_COLOR:-}" != "0" ]]; then
    return 0
  fi
  [[ -z "${NO_COLOR:-}" ]] && has_tty
}

style() {
  local code="$1"
  local text="$2"
  if supports_color; then
    printf '\033[%sm%s\033[0m' "$code" "$text"
  else
    printf '%s' "$text"
  fi
}

heading() {
  style "1;36" "$1"
}

accent() {
  style "36" "$1"
}

muted() {
  style "2" "$1"
}

success() {
  style "32" "$1"
}

warn() {
  style "33" "$1"
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

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-Y}"
  local answer=""
  local suffix="[y/N]"
  if [[ "$default" == "Y" ]]; then
    suffix="[Y/n]"
  fi

  while true; do
    tty_print "$(accent "$prompt") $(muted "$suffix") "
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
        tty_println "$(warn "Please answer y or n.")"
        ;;
    esac
  done
}

prompt_secret() {
  local __var="$1"
  local prompt="$2"
  local secret_value=""
  tty_print "$(accent "$prompt")"
  tty_read secret_value
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
  tty_println "$(heading "$provider")"
  tty_println "$(muted "$description")"
  tty_println "$(muted "Get a key: $url")"
  tty_println ""

  if [[ -n "$existing" ]]; then
    if prompt_yes_no "Use existing $env_var ($(redacted_preview "$existing"))?" "Y"; then
      tty_println "$(success "Saved $provider.")"
      printf -v "$__var" '%s' "$existing"
      return
    fi
  elif ! prompt_yes_no "Set up $provider now?" "Y"; then
    tty_println "$(warn "Skipped $provider.")"
    printf -v "$__var" ''
    return
  fi

  prompt_secret value "Enter $env_var: "
  if [[ -z "$value" ]]; then
    tty_println "$(warn "Skipped $provider.")"
    printf -v "$__var" ''
    return
  fi

  tty_println "$(success "Saved $provider.")"
  printf -v "$__var" '%s' "$value"
}

run_api_key_setup_python() {
  command -v python3 >/dev/null 2>&1 || return 2
  python3 <<'PY'
import os
import re
import select
import shlex
import sys
import termios
import tty


TTY_PATH = os.environ.get("SUNLIGHT_SKILLS_TTY", "/dev/tty")


try:
    tty_in = open(TTY_PATH, "rb", buffering=0)
    tty_out = open(TTY_PATH, "wb", buffering=0)
except OSError:
    sys.exit(2)

tty_fd = tty_in.fileno()


def supports_color() -> bool:
    force = os.environ.get("FORCE_COLOR", "")
    if force and force != "0":
        return True
    return not os.environ.get("NO_COLOR") and os.isatty(tty_fd)


def style(code: str, text: str) -> str:
    if supports_color():
        return f"\033[{code}m{text}\033[0m"
    return text


def heading(text: str) -> str:
    return style("1;36", text)


def accent(text: str) -> str:
    return style("36", text)


def muted(text: str) -> str:
    return style("2", text)


def success(text: str) -> str:
    return style("32", text)


def warn(text: str) -> str:
    return style("33", text)


def println(text: str = "") -> None:
    write(f"{text}\n")


def write(text: str) -> None:
    tty_out.write(text.encode("utf-8"))
    tty_out.flush()


def read_byte() -> bytes:
    return os.read(tty_fd, 1)


def drain_pending_input() -> None:
    while True:
        ready, _, _ = select.select([tty_fd], [], [], 0.03)
        if not ready:
            return
        read_byte()


def prompt_yes_no(prompt: str, default: bool = True) -> bool:
    suffix = "[Y/n]" if default else "[y/N]"
    while True:
        write(f"{accent(prompt)} {muted(suffix)} ")
        old_attrs = termios.tcgetattr(tty_fd)
        try:
            tty.setraw(tty_fd)
            ch = read_byte()
        finally:
            termios.tcsetattr(tty_fd, termios.TCSADRAIN, old_attrs)
        if ch in {b"\r", b"\n", b""}:
            println()
            drain_pending_input()
            return default
        if ch == b"\x03":
            raise KeyboardInterrupt
        if ch in {b"y", b"Y"}:
            println("y")
            drain_pending_input()
            return True
        if ch in {b"n", b"N"}:
            println("n")
            drain_pending_input()
            return False
        println(warn("Please answer y or n."))


def prompt_secret(prompt: str) -> str:
    write(accent(prompt))
    old_attrs = termios.tcgetattr(tty_fd)
    value = bytearray()
    try:
        tty.setraw(tty_fd)
        while True:
            ch = read_byte()
            if ch in {b"\r", b"\n", b""}:
                break
            if ch == b"\x03":
                raise KeyboardInterrupt
            if ch in {b"\x7f", b"\b"}:
                if value:
                    value.pop()
                    write("\b \b")
                continue
            value.extend(ch)
            write("*")
    finally:
        termios.tcsetattr(tty_fd, termios.TCSADRAIN, old_attrs)
        println()
    return value.decode("utf-8", errors="ignore")


def redacted_preview(value: str) -> str:
    if len(value) <= 8:
        return "set"
    return f"{value[:4]}...{value[-4:]}"


def profile_path() -> str:
    home = os.environ.get("HOME", os.path.expanduser("~"))
    shell = os.path.basename(os.environ.get("SHELL", ""))
    if shell == "zsh":
        return os.path.join(home, ".zshrc")
    if shell == "bash":
        return os.path.join(home, ".bashrc")
    zshrc = os.path.join(home, ".zshrc")
    bashrc = os.path.join(home, ".bashrc")
    if os.path.exists(zshrc):
        return zshrc
    if os.path.exists(bashrc):
        return bashrc
    return os.path.join(home, ".profile")


def write_api_key_block(profile: str, values) -> None:
    os.makedirs(os.path.dirname(profile), exist_ok=True)
    existing = ""
    if os.path.exists(profile):
        with open(profile, "r", encoding="utf-8") as f:
            existing = f.read()
    existing = re.sub(
        r"\n?# >>> sunlight-skills api keys >>>\n.*?\n# <<< sunlight-skills api keys <<<\n?",
        "\n",
        existing,
        flags=re.S,
    ).rstrip()
    lines = ["", "# >>> sunlight-skills api keys >>>"]
    for env_var in ["LINKUP_API_KEY", "EXA_API_KEY", "TAVILY_API_KEY"]:
        value = values.get(env_var, "")
        if value:
            lines.append(f"export {env_var}={shlex.quote(value)}")
        else:
            lines.append(f"# {env_var} skipped")
    lines.append("# <<< sunlight-skills api keys <<<")
    next_text = existing + "\n".join(lines) + "\n"
    with open(profile, "w", encoding="utf-8") as f:
        f.write(next_text)


def provider_flow(name: str, env_var: str, description: str, url: str) -> str:
    println()
    println(heading(name))
    println(muted(description))
    println(muted(f"Get a key: {url}"))
    println()
    existing = os.environ.get(env_var, "")
    if existing:
        if prompt_yes_no(f"Use existing {env_var} ({redacted_preview(existing)})?", True):
            println(success(f"Saved {name}."))
            return existing
    elif not prompt_yes_no(f"Set up {name} now?", True):
        println(warn(f"Skipped {name}."))
        return ""
    value = prompt_secret(f"Enter {env_var}: ")
    if not value:
        println(warn(f"Skipped {name}."))
        return ""
    println(success(f"Saved {name}."))
    return value


try:
    println()
    println(heading("Sunlight research setup"))
    println()
    println(muted("Optional search providers make sunlight-deepresearch more thorough."))
    println(muted("You can skip any provider and still use default web_search."))

    values = {
        "LINKUP_API_KEY": provider_flow(
            "Linkup",
            "LINKUP_API_KEY",
            "Additional web search, fetch, and AI-oriented research coverage.",
            "https://app.linkup.so/",
        ),
        "EXA_API_KEY": provider_flow(
            "Exa",
            "EXA_API_KEY",
            "Semantic search, community threads, user sentiment, and quote retrieval.",
            "https://dashboard.exa.ai/",
        ),
        "TAVILY_API_KEY": provider_flow(
            "Tavily",
            "TAVILY_API_KEY",
            "Fresh web, news, product pages, changelogs, and release notes.",
            "https://app.tavily.com/",
        ),
    }

    if not any(values.values()):
        println()
        println(warn("No API keys saved. sunlight-deepresearch will use default web_search."))
        sys.exit(0)

    profile = profile_path()
    write_api_key_block(profile, values)
    println()
    println(success("Saved API key exports to:"))
    println(f"  {profile}")
    println()
    println(heading("Next:"))
    println(f"  source {profile}")
    println()
    println("Then start your agent from that shell.")
    println()
    println(heading("For Codex:"))
    println("  codex --search")
    println()
    println("sunlight-deepresearch will use default web_search plus any configured providers, then merge and deduplicate sources.")
except KeyboardInterrupt:
    println()
    println(warn("API key setup cancelled."))
    sys.exit(1)
PY
}

run_api_key_setup() {
  local linkup_key=""
  local exa_key=""
  local tavily_key=""
  local profile=""
  local setup_status=0

  if ! has_tty; then
    cat <<'EOF'

Skipping interactive API key setup because no terminal is available.
Run later with:
  curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --api-key-setup-only
EOF
    return
  fi

  if run_api_key_setup_python; then
    return
  else
    setup_status=$?
    if [[ "$setup_status" -ne 2 ]]; then
      return "$setup_status"
    fi
  fi

  tty_println ""
  tty_println "$(heading "Sunlight research setup")"
  tty_println ""
  tty_println "$(muted "Optional search providers make sunlight-deepresearch more thorough.")"
  tty_println "$(muted "You can skip any provider and still use default web_search.")"

  prompt_provider_key linkup_key "Linkup" "LINKUP_API_KEY" "Additional web search, fetch, and AI-oriented research coverage." "https://app.linkup.so/"
  prompt_provider_key exa_key "Exa" "EXA_API_KEY" "Semantic search, community threads, user sentiment, and quote retrieval." "https://dashboard.exa.ai/"
  prompt_provider_key tavily_key "Tavily" "TAVILY_API_KEY" "Fresh web, news, product pages, changelogs, and release notes." "https://app.tavily.com/"

  if [[ -z "$linkup_key" && -z "$exa_key" && -z "$tavily_key" ]]; then
    tty_println ""
    tty_println "$(warn "No API keys saved. sunlight-deepresearch will use default web_search.")"
    return
  fi

  profile="$(profile_path)"
  write_api_key_block "$profile" "$linkup_key" "$exa_key" "$tavily_key"

  tty_println ""
  tty_println "$(success "Saved API key exports to:")"
  tty_println "  $profile"
  tty_println ""
  tty_println "$(heading "Next:")"
  tty_println "  source $profile"
  tty_println ""
  tty_println "Then start your agent from that shell."
  tty_println ""
  tty_println "$(heading "For Codex:")"
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
