# Compression Template

Use this template after an investigator subagent returns raw research notes. Compress one track at a time.

```md
# Compressed Findings: <track title>

## Track Objective
<Original objective for this investigator.>

## Queries and Sources Used
- <Query or source path> -> <source tags>
- <Query or source path> -> <source tags>

## Source Files Checked
- [SRC_001] -> `sources/SRC_001.md`
- [SRC_002] -> `sources/SRC_002.md`

## Key Findings

### <Theme>
- <Finding with inline source tag.>
- <Finding with inline source tag.>

### <Theme>
- <Finding with inline source tag.>
- <Finding with inline source tag.>

## Conflicts and Uncertainty
- <Contradiction, weak evidence, missing source, or unresolved question.>

## Partial or Failed Coverage
<State "none" or explain what could not be verified.>

## Confidence
<High, medium, or low, with a short reason.>
```

## Compression Rules
- Preserve source tags exactly.
- Do not invent sources or claims.
- Do not drop important contrary evidence.
- Do not write the final report here.
- Verify every source tag resolves to a linked source registry row or per-source file.
- Every factual sentence in `Key Findings` must carry a source tag.
- If source-backed findings are insufficient, label the output partial.
