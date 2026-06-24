#!/usr/bin/env python3
"""Create a starter deep research plan from a topic.

This script intentionally stays lightweight. It gives an agent a structured
starting point; the agent should still adapt the tracks to the user's context.
"""

from __future__ import annotations

import argparse
import textwrap


DEFAULT_TRACKS = [
    ("Background and definitions", "Establish the domain, terms, and baseline context."),
    ("Current state and recent developments", "Find recent developments and current conditions."),
    ("Evidence for the main claims", "Gather support and counterevidence for the core claims."),
    ("Risks, constraints, and failure modes", "Identify limitations, risks, and failure modes."),
    ("Alternatives and comparisons", "Compare competing options, entities, or approaches."),
    ("Source quality and fact-checking", "Evaluate source reliability and verify important claims."),
]


def main() -> None:
    parser = argparse.ArgumentParser(description="Create a starter deep research plan.")
    parser.add_argument("topic", help="Research topic or objective")
    parser.add_argument(
        "--tracks",
        type=int,
        default=6,
        help="Number of starter tracks to print, up to the built-in maximum",
    )
    args = parser.parse_args()

    track_count = max(1, min(args.tracks, len(DEFAULT_TRACKS)))
    tracks = DEFAULT_TRACKS[:track_count]

    print(f"# Deep Research Plan: {args.topic}\n")
    print("## Classification")
    print("<entity_comparison | market_analysis | claim_check | technical_scan | mixed>")
    print("\n## User Intent")
    print(args.topic)
    print("\n## Constraints")
    print("- Recency:")
    print("- Required sources:")
    print("- Excluded sources:")
    print("- Output format:")
    print("- Named entities:")
    print("- Geography / market:")
    print("- Evaluation dimensions:")
    print("\n## Research Tracks")
    for index, (title, objective) in enumerate(tracks, start=1):
        print(f"\n### Track {index}: {title}")
        print(f"- Objective: {objective}")
        print("- Dimension:")
        print("- Named entities:")
        print("- Source hints:")
        print("- Questions to answer:")
        print("- Expected output:")
    print("\n## Subagent Brief Skeleton")
    print(
        textwrap.dedent(
            """\
            Research track: <track name>

            Objective:
            <What this subagent should investigate.>

            Questions to answer:
            1. <Question>
            2. <Question>
            3. <Question>

            Output format:
            - Queries and sources used:
            - Key findings:
            - Evidence and sources:
            - Conflicts or uncertainty:
            - Inferences:
            - Open questions:
            - Confidence:

            Budget:
            - Maximum search/tool iterations:
            - Optional provider budget:
            - Minimum useful sources:
            - Stop condition:

            Search provider guidance:
            - Start with default web_search.
            - Use Tavily, Exa, or Linkup only when available.
            - Continue with default web_search if optional provider keys are unavailable.
            """
        ).strip()
    )


if __name__ == "__main__":
    main()
