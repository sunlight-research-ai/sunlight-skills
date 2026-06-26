#!/usr/bin/env python3
"""Run optional sunlight-deepresearch search providers when configured.

The script intentionally uses only the Python standard library so it can run
inside Codex, Claude Code, OpenCode, or a plain shell without package setup.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any
from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse


PROVIDER_KEYS = {
    "linkup": "LINKUP_API_KEY",
    "exa": "EXA_API_KEY",
    "tavily": "TAVILY_API_KEY",
}

TRACKING_PARAMS = frozenset(
    {
        "msclkid",
        "gclid",
        "fbclid",
        "ref",
        "yclid",
        "dclid",
        "mc_cid",
        "mc_eid",
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content",
        "utm_id",
        "utm_name",
        "utm_brand",
        "utm_social",
        "utm_referrer",
        "__hstc",
        "__hssc",
        "__hsfp",
        "_hsenc",
        "_hsmi",
        "hsctatracking",
        "vero_id",
        "vero_conv",
        "_branch_match_id",
        "wbraid",
        "gbraid",
    }
)


def canonicalize_url(url: str) -> str:
    """Match sunlight-platform SourceRegistry URL dedupe semantics."""
    if not url:
        return url
    try:
        parsed = urlparse(url.strip())
    except ValueError:
        return url
    netloc = parsed.netloc.lower()
    if netloc.startswith("www."):
        netloc = netloc[4:]
    path = parsed.path or "/"
    if len(path) > 1:
        path = path.rstrip("/")
    query_pairs = [
        (key, value)
        for key, value in parse_qsl(parsed.query, keep_blank_values=True)
        if key.lower() not in TRACKING_PARAMS
    ]
    query_pairs.sort()
    query = urlencode(query_pairs)
    return urlunparse(("https", netloc, path, "", query, ""))


def parse_env_line(line: str) -> tuple[str, str] | None:
    line = line.strip()
    if not line or line.startswith("#"):
        return None
    if line.startswith("export "):
        line = line[len("export ") :].strip()
    if "=" not in line:
        return None
    key, raw_value = line.split("=", 1)
    key = key.strip()
    if key not in PROVIDER_KEYS.values():
        return None
    value = raw_value.strip()
    if not value:
        return key, ""
    try:
        parts = shlex.split(value, posix=True)
        return key, parts[0] if parts else ""
    except ValueError:
        return key, value.strip("\"'")


def candidate_env_files() -> list[Path]:
    files: list[Path] = []
    explicit = os.environ.get("SUNLIGHT_SEARCH_ENV")
    if explicit:
        files.append(Path(explicit).expanduser())

    cwd = Path.cwd().resolve()
    for directory in [cwd, *cwd.parents]:
        files.extend(
            [
                directory / ".env",
                directory / ".env.local",
                directory / ".sunlight.env",
            ]
        )

    home = Path.home()
    files.extend(
        [
            home / ".sunlight-skills.env",
            home / ".zshrc",
            home / ".bashrc",
            home / ".profile",
        ]
    )
    seen: set[Path] = set()
    unique: list[Path] = []
    for path in files:
        try:
            resolved = path.resolve()
        except OSError:
            resolved = path
        if resolved not in seen:
            seen.add(resolved)
            unique.append(path)
    return unique


def load_keys() -> tuple[dict[str, str], dict[str, str]]:
    values = {key: os.environ.get(key, "") for key in PROVIDER_KEYS.values()}
    sources = {key: "process environment" for key, value in values.items() if value}

    for path in candidate_env_files():
        if not path.exists() or not path.is_file():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except OSError:
            continue
        for line in text.splitlines():
            parsed = parse_env_line(line)
            if not parsed:
                continue
            key, value = parsed
            if value and not values.get(key):
                values[key] = value
                sources[key] = str(path)

    return values, sources


def redact(value: str) -> str:
    if not value:
        return "missing"
    if len(value) <= 8:
        return "configured"
    return f"{value[:4]}...{value[-4:]}"


def request_json(url: str, headers: dict[str, str], payload: dict[str, Any], timeout: int) -> dict[str, Any]:
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:500]
        raise RuntimeError(f"HTTP {exc.code}: {body}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(str(exc.reason)) from exc


def normalize_result(provider: str, item: dict[str, Any]) -> dict[str, Any]:
    title = item.get("title") or item.get("name") or item.get("id") or ""
    url = item.get("url") or item.get("id") or ""
    snippet = item.get("content") or item.get("text") or item.get("summary") or item.get("snippet") or ""
    if isinstance(snippet, list):
        snippet = " ".join(str(part) for part in snippet)
    snippet = re.sub(r"\s+", " ", str(snippet)).strip()
    return {
        "provider": provider,
        "providers": [provider],
        "title": str(title).strip(),
        "url": str(url).strip(),
        "canonical_url": canonicalize_url(str(url).strip()),
        "snippet": snippet[:500],
    }


def search_linkup(query: str, key: str, max_results: int, timeout: int) -> list[dict[str, Any]]:
    data = request_json(
        "https://api.linkup.so/v1/search",
        {
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        {
            "q": query,
            "depth": "standard",
            "outputType": "searchResults",
            "maxResults": max_results,
        },
        timeout,
    )
    return [normalize_result("linkup", item) for item in data.get("results", [])]


def search_exa(query: str, key: str, max_results: int, timeout: int) -> list[dict[str, Any]]:
    data = request_json(
        "https://api.exa.ai/search",
        {
            "x-api-key": key,
            "Content-Type": "application/json",
        },
        {
            "query": query,
            "numResults": max_results,
            "contents": {"highlights": True},
        },
        timeout,
    )
    return [normalize_result("exa", item) for item in data.get("results", [])]


def search_tavily(query: str, key: str, max_results: int, timeout: int) -> list[dict[str, Any]]:
    data = request_json(
        "https://api.tavily.com/search",
        {
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        {
            "query": query,
            "search_depth": "basic",
            "max_results": max_results,
        },
        timeout,
    )
    return [normalize_result("tavily", item) for item in data.get("results", [])]


SEARCHERS = {
    "linkup": search_linkup,
    "exa": search_exa,
    "tavily": search_tavily,
}


def dedupe_results(results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_key: dict[str, dict[str, Any]] = {}
    deduped: list[dict[str, Any]] = []
    for result in results:
        url_key = result.get("canonical_url", "")
        title_key = result.get("title", "").strip().lower()
        key = url_key or f"{title_key}|{result.get('provider', '')}"
        if not key:
            continue
        existing = by_key.get(key)
        if existing:
            provider = result.get("provider")
            if provider and provider not in existing["providers"]:
                existing["providers"].append(provider)
            if not existing.get("snippet") and result.get("snippet"):
                existing["snippet"] = result["snippet"]
            continue
        by_key[key] = result
        deduped.append(result)
    return deduped


def print_check(values: dict[str, str], sources: dict[str, str]) -> None:
    print(json.dumps(
        {
            provider: {
                "configured": bool(values.get(env_key)),
                "key": redact(values.get(env_key, "")),
                "source": sources.get(env_key, ""),
            }
            for provider, env_key in PROVIDER_KEYS.items()
        },
        indent=2,
    ))


def main() -> int:
    parser = argparse.ArgumentParser(description="Search optional deep research providers.")
    parser.add_argument("query", nargs="?", help="Search query")
    parser.add_argument(
        "--provider",
        choices=["all", *PROVIDER_KEYS.keys()],
        default="all",
        help="Provider to use; default uses every configured provider",
    )
    parser.add_argument("--max-results", type=int, default=5, help="Results per provider, 1-20")
    parser.add_argument("--timeout", type=int, default=20, help="HTTP timeout seconds")
    parser.add_argument("--check", action="store_true", help="Only print configured providers")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON")
    args = parser.parse_args()

    values, sources = load_keys()
    if args.check:
        print_check(values, sources)
        return 0
    if not args.query:
        parser.error("query is required unless --check is used")

    providers = list(PROVIDER_KEYS) if args.provider == "all" else [args.provider]
    max_results = max(1, min(args.max_results, 20))
    all_results: list[dict[str, Any]] = []
    failures: dict[str, str] = {}

    for provider in providers:
        env_key = PROVIDER_KEYS[provider]
        key = values.get(env_key, "")
        if not key:
            failures[provider] = f"{env_key} is not configured"
            continue
        try:
            all_results.extend(SEARCHERS[provider](args.query, key, max_results, args.timeout))
        except RuntimeError as exc:
            failures[provider] = str(exc)

    output = {
        "query": args.query,
        "providers_attempted": providers,
        "providers_configured": [
            provider for provider, env_key in PROVIDER_KEYS.items() if values.get(env_key)
        ],
        "failures": failures,
        "results": dedupe_results(all_results),
    }

    if args.json:
        print(json.dumps(output, indent=2))
    else:
        print(f"Query: {args.query}")
        print(f"Configured providers: {', '.join(output['providers_configured']) or 'none'}")
        for provider, error in failures.items():
            print(f"- {provider}: {error}", file=sys.stderr)
        for index, result in enumerate(output["results"], start=1):
            print(f"\n[{index}] {result['provider']}: {result['title']}")
            print(result["url"])
            if result["snippet"]:
                print(result["snippet"])
    return 0 if output["results"] or failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
