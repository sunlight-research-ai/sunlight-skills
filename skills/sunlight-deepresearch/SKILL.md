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
- Do not use when the user explicitly asks for a quick answer and does not want a research process.
- Do not require LangGraph, a codebase, a database, or a hosted backend unless the user asks to build a durable app.

## Contract
- Do not answer broad research questions from a single pass when subagents are available.
- Break the objective into independent research tracks before dispatching work.
- Give each subagent a narrow brief, explicit output shape, and source/evidence requirements.
- Ask subagents to separate evidence, inference, uncertainty, and open questions.
- Synthesize only after reviewing the returned findings.
- Resolve conflicts with targeted follow-up research instead of smoothing them over.
- Run a final verifier or critic pass before presenting the final report.
- State limitations, confidence, and unresolved questions in the final output.

## Workflow
1. Create a research brief using `references/research-brief-template.md`: objective, audience, decision context, entities, timeframe, source requirements, exclusions, output format, and success criteria. If the request is not clear enough to decompose, ask one concise clarifying question before dispatching subagents.
2. Convert the research brief into a research plan using `references/research-plan-template.md`: classify the request type, preserve the user's intent, extract constraints, and create one focused track per independently researchable unit.
3. Dispatch focused investigator subagents using `references/subagent-brief-template.md`, with explicit budgets and source requirements.
4. Have each investigator run iterative research: use the model's default `web_search` first, optionally augment with Tavily, Exa, or Linkup when those API keys/tools are available, inspect sources, capture source-tagged findings, reflect on missing evidence, then stop when coverage or budget is reached.
5. Compress each investigator's raw findings into a clean, source-preserving summary using `references/compression-template.md`.
6. Run a wave checkpoint using `references/wave-checkpoint-template.md`; dispatch follow-up subagents only for material gaps, contradictions, or weak evidence.
7. Extract structured facts, metrics, entities, and source metadata using `references/structured-data-template.md` when tables, charts, or precise comparisons are useful.
8. Synthesize the findings into the requested report shape using `references/report-template.md`.
9. Add strategic implications, recommendations, and "so what" analysis only when grounded in the evidence.
10. Persist or package the final report, sources, and limitations in the format the user needs.

## Bundled Resources
- Read `references/orchestration-pattern.md` for the full operating model and quality gates.
- Use `references/research-brief-template.md` before dispatching subagents.
- Use `references/research-plan-template.md` to preserve user intent and decompose the brief into tracks.
- Use `references/subagent-brief-template.md` when preparing investigator prompts.
- Use `references/search-providers.md` when deciding how default web search and optional search APIs should be used.
- Use `references/compression-template.md` to distill raw subagent findings.
- Use `references/wave-checkpoint-template.md` before deciding the research is complete.
- Use `references/structured-data-template.md` when extracting numbers, entities, and named facts.
- Use `references/report-template.md` when producing a final research artifact.
- Use `references/persistence-and-runtime.md` when designing a durable implementation or setting budgets.
- Use `scripts/create-research-plan.py` to draft a starter decomposition when the topic is broad.

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
