#!/usr/bin/env python3
"""Evaluate linked-source coverage for a deep research report.

The evaluator is intentionally conservative. A sentence is covered only when it
contains a markdown link, a bare http(s) URL, or a source tag that resolves to a
linked URL in the same report or an optional source registry file.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


LINK_RE = re.compile(r"\[[^\]]+\]\(https?://[^)\s]+(?:\s+\"[^\"]*\")?\)")
URL_RE = re.compile(r"https?://[^\s)<>\]]+")
SRC_RE = re.compile(r"\[(SRC[_-]?\d+)\]", re.IGNORECASE)
HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s+(.+?)\s*$")
SOURCE_DEF_RE = re.compile(
    r"\[(SRC[_-]?\d+)\][^\n]*(https?://[^\s)<>\]]+)", re.IGNORECASE
)
SENTENCE_RE = re.compile(r"[^.!?\n]+[.!?](?=\s|$)")


def read_text(path: str) -> str:
    if path == "-":
        return sys.stdin.read()
    return Path(path).read_text(encoding="utf-8")


def slug_section(title: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")


def source_map_from_text(text: str) -> dict[str, str]:
    sources: dict[str, str] = {}
    for match in SOURCE_DEF_RE.finditer(text):
        sources[normalise_src(match.group(1))] = match.group(2)
    return sources


def normalise_src(tag: str) -> str:
    digits = re.search(r"\d+", tag)
    if not digits:
        return tag.upper().replace("-", "_")
    return f"SRC_{int(digits.group(0)):03d}"


def strip_code_blocks(text: str) -> str:
    return re.sub(r"```.*?```", "", text, flags=re.DOTALL)


def section_for_line(line: str, current: str) -> str:
    match = HEADING_RE.match(line)
    if match:
        return slug_section(match.group(1))
    return current


def sentences_by_section(text: str) -> list[dict[str, str]]:
    clean = strip_code_blocks(text)
    current = ""
    out: list[dict[str, str]] = []
    for line in clean.splitlines():
        current = section_for_line(line, current)
        stripped = line.strip()
        if not stripped or HEADING_RE.match(line):
            continue
        if current in {"sources", "bibliography", "source-registry", "source-registry-md"}:
            continue
        for match in SENTENCE_RE.finditer(stripped):
            sentence = " ".join(match.group(0).split())
            if len(sentence.split()) < 5:
                continue
            out.append({"section": current, "sentence": sentence})
    return out


def sentence_has_linked_source(sentence: str, sources: dict[str, str]) -> bool:
    if LINK_RE.search(sentence) or URL_RE.search(sentence):
        return True
    for tag in SRC_RE.findall(sentence):
        if normalise_src(tag) in sources:
            return True
    return False


def evaluate(
    report_text: str,
    registry_text: str = "",
    *,
    min_sentence_coverage: float,
    require_key_findings: bool,
) -> dict:
    sources = source_map_from_text(report_text)
    sources.update(source_map_from_text(registry_text))
    sentences = sentences_by_section(report_text)

    evaluated = [
        {
            **item,
            "covered": sentence_has_linked_source(item["sentence"], sources),
        }
        for item in sentences
    ]

    total = len(evaluated)
    covered = sum(1 for item in evaluated if item["covered"])
    uncovered = [item for item in evaluated if not item["covered"]]
    key_items = [
        item
        for item in evaluated
        if item["section"] in {"key-findings", "executive-summary", "core-thesis"}
    ]
    key_uncovered = [item for item in key_items if not item["covered"]]
    coverage = covered / total if total else 0.0

    failures: list[str] = []
    if total == 0:
        failures.append("No evaluable report sentences found.")
    if coverage < min_sentence_coverage:
        failures.append(
            f"Sentence source coverage {coverage:.1%} is below required "
            f"{min_sentence_coverage:.1%}."
        )
    if require_key_findings and key_uncovered:
        failures.append(
            f"{len(key_uncovered)} key/executive finding sentence(s) lack linked sources."
        )
    if not sources:
        failures.append("No linked source registry entries found.")

    return {
        "passed": not failures,
        "coverage": round(coverage, 4),
        "covered_sentences": covered,
        "total_sentences": total,
        "source_count": len(sources),
        "uncovered_sentences": uncovered,
        "key_uncovered_sentences": key_uncovered,
        "failures": failures,
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Evaluate whether a research report has linked-source coverage."
    )
    parser.add_argument("report", help="Report markdown path, or '-' for stdin.")
    parser.add_argument(
        "--registry",
        help="Optional source registry markdown path.",
        default="",
    )
    parser.add_argument(
        "--min-sentence-coverage",
        type=float,
        default=0.85,
        help="Minimum share of evaluable sentences with linked sources.",
    )
    parser.add_argument(
        "--allow-uncited-key-findings",
        action="store_true",
        help="Do not require key/executive findings to be fully sourced.",
    )
    parser.add_argument("--json", action="store_true", help="Print JSON output.")
    args = parser.parse_args()

    report_text = read_text(args.report)
    registry_text = read_text(args.registry) if args.registry else ""
    result = evaluate(
        report_text,
        registry_text,
        min_sentence_coverage=args.min_sentence_coverage,
        require_key_findings=not args.allow_uncited_key_findings,
    )

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        status = "PASS" if result["passed"] else "FAIL"
        print(f"{status}: linked-source coverage {result['coverage']:.1%}")
        print(
            f"Sentences: {result['covered_sentences']}/"
            f"{result['total_sentences']} covered"
        )
        print(f"Linked sources registered: {result['source_count']}")
        for failure in result["failures"]:
            print(f"- {failure}")
        for item in result["uncovered_sentences"][:10]:
            section = item["section"] or "(no section)"
            print(f"UNCOVERED [{section}]: {item['sentence']}")

    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
