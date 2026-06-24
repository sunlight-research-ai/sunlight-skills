# Citation Audit

PASS

## Automated Evaluator
Command:

```bash
python3 skills/sunlight-deepresearch/scripts/evaluate-source-coverage.py research-runs/figma-ai-strategy-2026-06-24/final-report.md --registry research-runs/figma-ai-strategy-2026-06-24/source-registry.md --min-sentence-coverage 0.85
```

Output:

```text
PASS: linked-source coverage 100.0%
Sentences: 36/36 covered
Linked sources registered: 12
```

## Decision
The report meets the linked-source coverage goal.
