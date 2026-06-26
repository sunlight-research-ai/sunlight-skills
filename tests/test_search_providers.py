import importlib.util
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = (
    Path(__file__).resolve().parents[1]
    / "skills"
    / "sunlight-deepresearch"
    / "scripts"
    / "search-providers.py"
)


def load_module():
    spec = importlib.util.spec_from_file_location("search_providers", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class SearchProvidersTest(unittest.TestCase):
    def test_canonicalize_matches_backend_dedupe_rules(self):
        providers = load_module()
        self.assertEqual(
            providers.canonicalize_url(
                "http://www.Example.com/path/?utm_source=x&gclid=y#section"
            ),
            "https://example.com/path",
        )
        self.assertEqual(
            providers.canonicalize_url("https://example.com/search?page=2&q=figma"),
            "https://example.com/search?page=2&q=figma",
        )

    def test_dedupe_merges_provider_provenance(self):
        providers = load_module()
        results = providers.dedupe_results(
            [
                {
                    "provider": "linkup",
                    "providers": ["linkup"],
                    "title": "Pricing",
                    "url": "https://www.example.com/pricing?utm_source=a",
                    "canonical_url": providers.canonicalize_url(
                        "https://www.example.com/pricing?utm_source=a"
                    ),
                    "snippet": "",
                },
                {
                    "provider": "exa",
                    "providers": ["exa"],
                    "title": "Pricing duplicate",
                    "url": "http://example.com/pricing#plans",
                    "canonical_url": providers.canonicalize_url(
                        "http://example.com/pricing#plans"
                    ),
                    "snippet": "Useful snippet",
                },
            ]
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["providers"], ["linkup", "exa"])
        self.assertEqual(results[0]["snippet"], "Useful snippet")

    def test_all_provider_path_attempts_every_configured_provider(self):
        providers = load_module()
        calls = []

        def fake_search(provider):
            def run(query, key, max_results, timeout):
                calls.append((provider, query, key, max_results, timeout))
                return [
                    {
                        "provider": provider,
                        "providers": [provider],
                        "title": f"{provider} result",
                        "url": f"https://example.com/{provider}",
                        "canonical_url": f"https://example.com/{provider}",
                        "snippet": "",
                    }
                ]

            return run

        with patch.dict(
            providers.SEARCHERS,
            {
                "linkup": fake_search("linkup"),
                "exa": fake_search("exa"),
                "tavily": fake_search("tavily"),
            },
        ), patch.object(
            providers,
            "load_keys",
            return_value=(
                {
                    "LINKUP_API_KEY": "linkup-key",
                    "EXA_API_KEY": "exa-key",
                    "TAVILY_API_KEY": "",
                },
                {},
            ),
        ), patch.object(
            providers.sys,
            "argv",
            [
                "search-providers.py",
                "test query",
                "--provider",
                "all",
                "--max-results",
                "2",
                "--json",
            ],
        ):
            self.assertEqual(providers.main(), 0)

        self.assertEqual([call[0] for call in calls], ["linkup", "exa"])
        self.assertEqual({call[3] for call in calls}, {2})


if __name__ == "__main__":
    unittest.main()
