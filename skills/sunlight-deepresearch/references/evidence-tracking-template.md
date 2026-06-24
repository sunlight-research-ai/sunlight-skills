# Evidence Tracking Template

Use this reference for every deep research run. File-backed evidence is mandatory. If the runtime cannot write files, create equivalent markdown artifacts in the conversation and state that persistence is unavailable.

## Run Folder
Create a run folder before dispatching investigators:

```text
research-runs/<topic-slug>/
  research-brief.md
  research-plan.md
  source-registry.md
  sources/
    SRC_001.md
    SRC_002.md
  subagents/
    track-01-raw.md
    track-01-compressed.md
  evaluators/
    citation-audit.md
    source-quality-audit.md
    coverage-audit.md
    contradiction-audit.md
  final-report.md
```

## Source Registry
Append a row to `source-registry.md` immediately after opening or fetching a useful source.

| Source ID | Title | URL | Provider/query | Source class | Fetched date | Used for | Quality notes |
|-----------|-------|-----|----------------|--------------|--------------|----------|---------------|
| [SRC_001] | <title> | <https://...> | <provider + query> | <official / reputable secondary / user voice / data / counterevidence> | <date> | <claims supported> | <notes> |

Rules:
- One canonical source ID per URL, even if multiple providers return it.
- Deduplicate by canonical URL first; if no URL exists, use normalized title, source name, and domain.
- Do not cite a source ID unless it resolves to a real URL in `source-registry.md` or a per-source file.

## Per-Source Evidence Files
Create one file under `sources/` for every source used in findings.

```md
# [SRC_001] <Source Title>

- URL:
- Provider/query:
- Source class:
- Fetched date:
- Relevance:
- Quality:

## Evidence Extracted
- <Claim or excerpt this source supports.>
- <Claim or excerpt this source supports.>

## Limitations
- <Bias, age, weak methodology, missing data, or uncertainty.>
```

## Subagent Files
Each investigator writes:
- raw notes with query plan, coverage matrix, opened sources, rejected sources, and source IDs.
- compressed findings with source IDs attached to every factual claim.

## Evaluator Files
Before final synthesis, run evaluator passes and write their outputs:
- `citation-audit.md`: every factual sentence and every key finding has a linked source.
- `source-quality-audit.md`: source type is appropriate for the claim type.
- `coverage-audit.md`: required tracks, query categories, and source classes were attempted.
- `contradiction-audit.md`: conflicts and weak evidence are surfaced.

The final report is blocked until evaluator files say `PASS`. If any evaluator says `FAIL`, dispatch follow-up research or revise the report before delivery.

## Final Report Gate
The final report must:
- use inline source IDs or markdown links on factual sentences.
- use linked sources on every key finding sentence.
- include a `Sources` section where every cited source ID resolves to a URL.
- avoid vague source labels such as "SEC filings" or "developer survey" without a link.
- output a pipeline failure note instead of a polished report when linked evidence is missing.
