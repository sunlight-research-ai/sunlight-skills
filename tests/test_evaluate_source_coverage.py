import importlib.util
import unittest
from pathlib import Path


SCRIPT = (
    Path(__file__).resolve().parents[1]
    / "skills"
    / "sunlight-deepresearch"
    / "scripts"
    / "evaluate-source-coverage.py"
)


def load_module():
    spec = importlib.util.spec_from_file_location("evaluate_source_coverage", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class EvaluateSourceCoverageTest(unittest.TestCase):
    def test_unsourced_report_fails(self):
        evaluator = load_module()
        report = """
# Report

## Key Findings
Figma should own product context. It should avoid unsupported claims.
"""
        result = evaluator.evaluate(
            report,
            min_sentence_coverage=0.85,
            require_key_findings=True,
        )
        self.assertFalse(result["passed"])
        self.assertEqual(result["coverage"], 0)
        self.assertTrue(result["key_uncovered_sentences"])


    def test_source_tag_with_linked_registry_passes(self):
        evaluator = load_module()
        report = """
# Report

## Key Findings
Figma filed an S-1 describing its platform and business model [SRC_001].

## Analysis
The strategy recommendation is grounded in linked evidence [SRC_001].
"""
        registry = """
| Source ID | Title | URL |
|-----------|-------|-----|
| [SRC_001] | Figma S-1 | https://www.sec.gov/Archives/edgar/data/1572398/000119312525153203/d700454ds1.htm |
"""
        result = evaluator.evaluate(
            report,
            registry,
            min_sentence_coverage=0.85,
            require_key_findings=True,
        )
        self.assertTrue(result["passed"])
        self.assertEqual(result["coverage"], 1)
        self.assertEqual(result["source_count"], 1)

    def test_trailing_source_tag_after_sentence_punctuation_passes(self):
        evaluator = load_module()
        report = """
# Report

## Executive Summary
Figma should own product context. [SRC_001]

## Key Findings
- Figma Make can use design references. [SRC_001]
"""
        registry = """
| Source ID | Title | URL |
|-----------|-------|-----|
| [SRC_001] | Figma Make | https://www.theverge.com/news/712995/figma-make-ai-general-availability-announcement |
"""
        result = evaluator.evaluate(
            report,
            registry,
            min_sentence_coverage=0.85,
            require_key_findings=True,
        )
        self.assertTrue(result["passed"])
        self.assertEqual(result["coverage"], 1)


if __name__ == "__main__":
    unittest.main()
