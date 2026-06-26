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
    print("\n## Evidence Artifacts")
    print("- Run folder: research-runs/<topic-slug>/")
    print("- Source registry: research-runs/<topic-slug>/source-registry.md")
    print("- Per-source evidence files: research-runs/<topic-slug>/sources/SRC_NNN.md")
    print("- Subagent raw notes: research-runs/<topic-slug>/subagents/<track>-raw.md")
    print("- Subagent compressed findings: research-runs/<topic-slug>/subagents/<track>-compressed.md")
    print("- Evaluator outputs: research-runs/<topic-slug>/evaluators/*.md")
    print("- Final report: research-runs/<topic-slug>/final-report.md")
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

            Artifact paths:
            - Run folder:
            - Source registry:
            - Per-source files:
            - Raw notes file:
            - Compressed findings file:

            Research requirements:
            - Treat this as thorough research.
            - Do not stop after a few obvious sources.
            - Aim for 12-20 unique useful sources for broad tracks when available.
            - Register every useful fetched link in the source registry.
            - Create or update one per-source evidence file for every cited source.
            - Do not include factual findings without a source tag that resolves to a URL.

            Questions to answer:
            1. <Question>
            2. <Question>
            3. <Question>

            Query plan:
            - Orientation:
            - Official/source-of-truth:
            - Fresh/current:
            - User voice/community:
            - Metrics/benchmarks:
            - Criticism/counterevidence:

            Output format:
            - Queries and sources used:
            - Coverage matrix:
              - Query type:
              - Queries attempted:
              - Sources found:
              - Source class:
              - Gaps remaining:
            - Source registry updates:
              - Source ID:
              - URL:
              - Claims supported:
            - Key findings:
            - Evidence and sources:
            - Conflicts or uncertainty:
            - Inferences:
            - Open questions:
            - Confidence:

            Budget:
            - Maximum search/tool iterations:
            - Optional provider budget:
            - Minimum useful sources: 12-20 unique useful sources for broad tracks when available.
            - Stop condition: all relevant query-plan categories attempted, source classes checked, counterevidence searched, contradictions documented, and additional searching unlikely to change the answer.

            Search provider guidance:
            - Start with default web_search.
            - Before dispatch, check configured providers:
              python3 skills/sunlight-deepresearch/scripts/search-providers.py --check
            - Create provider-appropriate query variants instead of sending the same wording to every provider.
            - If optional provider tools are not exposed directly, use the bundled provider script:
              python3 skills/sunlight-deepresearch/scripts/search-providers.py "<query>" --provider all --json
            - Use Tavily for exact/fresh/official keyword searches when available.
            - Use Exa for semantic, community, sentiment, and quote-discovery searches when available.
            - Use Linkup as an additional recall/fetch path for high-value queries when available.
            - Merge provider outputs and deduplicate sources before reporting findings.
            - Continue with default web_search if optional provider keys are unavailable.

            Evaluator gate:
            - Run citation, source-quality, coverage, and contradiction audits before final delivery.
            - When files are available, run:
              python3 skills/sunlight-deepresearch/scripts/evaluate-source-coverage.py final-report.md --registry source-registry.md
            """
        ).strip()
    )


if __name__ == "__main__":
    main()
