---
name: sunlight-deepresearch
description: "Use when running, designing, or adapting a deep research workflow driven by subagents: planning research questions, dispatching parallel investigators, synthesizing findings, checking evidence quality, resolving conflicts, and producing a final report. Works with Codex, Claude Code, OpenCode, or other agentic coding assistants; LangGraph is optional."
---

# Sunlight Deep Research

## Overview
Run deep research as a disciplined subagent orchestration workflow: decompose the question, send focused investigators, collect evidence, resolve conflicts, synthesize, and verify before final delivery.

## When to Use
- The user asks for deep research on a broad, ambiguous, technical, market, product, academic, or strategic topic.
- The user wants a reusable research process rather than a one-pass answer.
- The user asks to compare options, investigate claims, map a domain, produce a sourced report, or find risks and unknowns.
- The user wants to run the workflow in Codex, Claude Code, OpenCode, or another agentic assistant.
- The user wants to implement the workflow in an application; LangGraph may be used, but is not required.

## When NOT to Use
- Do not use for simple factual questions that can be answered directly with one reliable source.
- Do not use when the user explicitly wants a direct answer without a research process.
- Do not require LangGraph, a codebase, a database, or a hosted backend unless the user asks to build a durable app.

## Contract
- Do not answer broad research questions from a single pass when subagents are available.
- Treat every `sunlight-deepresearch` run as thorough research; do not offer lighter modes.
- Create file-backed research artifacts as the run progresses: brief, plan, source registry, per-source evidence files, subagent notes, evaluator audits, and final report.
- Break the objective into independent research tracks before dispatching work.
- Give each subagent a narrow brief, explicit output shape, and source/evidence requirements.
- Require each investigator to complete a full query sweep and coverage check before stopping.
- Register every useful fetched link in a source registry and create a per-source evidence file before using it in findings.
- Ask subagents to separate evidence, inference, uncertainty, and open questions.
- Synthesize only after reviewing the returned findings.
- Run citation, source-quality, coverage, and contradiction evaluators against the actual final report before final delivery.
- Resolve conflicts with targeted follow-up research instead of smoothing them over.
- Before dispatching investigators, run `python3 skills/sunlight-deepresearch/scripts/search-providers.py --check` from the user's project or run folder to detect configured Linkup, Exa, and Tavily keys. If the skill path differs, use the installed skill's script path.
- Run a final verifier or critic pass before presenting the final report.
- Block final delivery when key findings or factual sentences lack linked sources.
- State limitations, confidence, and unresolved questions in the final output.

## Thoroughness Rules
- Default to thorough coverage whenever this skill is used.
- Do not stop because the first sources are obvious or because a few sources agree.
- Aim for 12-20 unique useful sources per broad track when available; use fewer only when the investigator documents scarcity and the searches attempted.
- Require source diversity where relevant: official or primary sources, reputable secondary sources, user/community sources, data or benchmark sources, and counterevidence.
- If results are too obvious, repetitive, or vendor/SEO-heavy, change query framing, source type, timeframe, geography, or provider before synthesizing.
- Stop only after the track's query sweep is attempted, source diversity is adequate, contradictions are checked, and further searches are unlikely to change the answer.

## Workflow
1. Create a run folder and evidence ledger using `references/evidence-tracking-template.md`.
2. Create a research brief using `references/research-brief-template.md`: objective, audience, decision context, entities, timeframe, source requirements, exclusions, output format, and success criteria. If the request is not clear enough to decompose, ask one concise clarifying question before dispatching subagents.
3. Convert the research brief into a research plan using `references/research-plan-template.md`: classify the request type, preserve the user's intent, extract constraints, and create one focused track per independently researchable unit.
4. Dispatch focused investigator subagents using `references/subagent-brief-template.md`, with explicit budgets, artifact paths, and source requirements.
5. Have each investigator run iterative research: create a provider-appropriate query pack, use the model's default `web_search` first, use all available Linkup, Exa, and Tavily providers for relevant query variants when their API keys/tools are available, merge and deduplicate sources, inspect sources, write each useful fetched link to `source-registry.md` and `sources/SRC_NNN.md`, capture source-tagged findings, reflect on missing evidence, then stop when coverage or budget is reached. When provider tools are not exposed directly, run `scripts/search-providers.py "<query>" --provider all --json` and use the returned `provider`, `title`, `url`, and `snippet` fields as candidate sources to inspect and register.
6. Compress each investigator's raw findings into a clean, source-preserving summary using `references/compression-template.md`.
7. Run a wave checkpoint using `references/wave-checkpoint-template.md`; dispatch follow-up subagents only for material gaps, contradictions, weak evidence, or missing citation coverage.
8. Extract structured facts, metrics, entities, and source metadata using `references/structured-data-template.md` when tables, charts, or precise comparisons are useful.
9. Synthesize the findings into the requested report shape using `references/report-template.md`.
10. Run evaluator agents: citation audit, source-quality audit, coverage audit, and contradiction audit. Use `scripts/evaluate-source-coverage.py` against `final-report.md` for the citation coverage check when files are available, and save the command/output in `evaluators/citation-audit.md`.
11. If any evaluator fails, revise the report or dispatch follow-up research; do not deliver a polished final report.
12. Add strategic implications, recommendations, and "so what" analysis only when grounded in linked evidence.
13. Persist or package the final report, sources, evaluator outputs, and limitations in the format the user needs.

## Bundled Resources
- Read `references/orchestration-pattern.md` for the full operating model and quality gates.
- Use `references/research-brief-template.md` before dispatching subagents.
- Use `references/research-plan-template.md` to preserve user intent and decompose the brief into tracks.
- Use `references/subagent-brief-template.md` when preparing investigator prompts.
- Use `references/search-providers.md` when deciding how default web search and optional search APIs should be used.
- Use `references/evidence-tracking-template.md` before the first search and before final synthesis.
- Use `references/compression-template.md` to distill raw subagent findings.
- Use `references/wave-checkpoint-template.md` before deciding the research is complete.
- Use `references/structured-data-template.md` when extracting numbers, entities, and named facts.
- Use `references/report-template.md` when producing a final research artifact.
- Use `references/persistence-and-runtime.md` when designing a durable implementation or setting budgets.
- Use `scripts/create-research-plan.py` to draft a starter decomposition when the topic is broad.
- Use `scripts/search-providers.py --check` before investigator dispatch and `scripts/search-providers.py "<query>" --provider all --json` during provider sweeps when Linkup, Exa, or Tavily are configured.
- Use `scripts/evaluate-source-coverage.py` to verify the final report has linked-source coverage.

## Optional LangGraph Use
Use LangGraph only when the user wants to build a durable product workflow with persisted state, resumable runs, retries, cancellation, or audit trails. The deep research pattern itself does not require LangGraph; it can be run manually by an agent using subagents.

## Stop Conditions
Stop and ask the user when:
- The research objective is too vague to decompose into useful tracks.
- The answer depends on paid, private, or unavailable sources.
- The user needs a professional judgment in a high-stakes domain and the available evidence is insufficient.
- The user wants implementation details for a specific runtime that is not available in the current environment.

## Anti-Patterns
- Producing a polished report without independent evidence collection.
- Producing a report with vague "key sources" instead of linked citations.
- Validating a sample, draft, or source registry instead of the actual `final-report.md`.
- Citing a source label that does not resolve to a URL.
- Giving every subagent the same broad prompt.
- Treating search snippets as evidence without opening and evaluating sources.
- Hiding contradictions between sources.
- Using LangGraph terminology when the user only needs a manual or agent-native research workflow.
- Mixing evidence and inference without labeling the difference.

## Output Format
For research execution, report:
- Research objective.
- Tracks investigated.
- Key findings with sources.
- Conflicts or uncertainty.
- Final synthesis.
- Confidence and limitations.
- Recommended next steps.

For workflow design, report:
- Proposed research stages.
- Subagent roles and prompts.
- Evidence and quality gates.
- Optional persistence/runtime choices.
- What is intentionally out of scope.
