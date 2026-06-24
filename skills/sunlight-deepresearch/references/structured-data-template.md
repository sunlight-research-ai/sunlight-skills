# Structured Data Template

Use this template when the research contains metrics, dates, entities, or facts that would help tables, charts, comparisons, or precise evidence review.

```md
# Structured Data

| Claim | Value | Unit | Metric | Dimension | Entity | Source Tag | Source URL or Name | Notes |
|-------|-------|------|--------|-----------|--------|------------|--------------------|-------|
| <claim> | <value> | <unit> | <metric> | <dimension> | <entity> | [SRC_1] | <source> | <notes> |
```

## Extraction Rules
- Extract only facts present in compressed findings or source-backed notes.
- Keep source tags tied to each row.
- Use `unknown` instead of guessing a value.
- Preserve units and dates.
- Normalize comparable metrics when safe, and state assumptions when normalization is needed.

