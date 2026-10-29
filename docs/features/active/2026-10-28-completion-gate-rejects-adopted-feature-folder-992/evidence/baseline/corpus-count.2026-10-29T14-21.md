# Baseline Corpus Count (P0-T7)

Timestamp: 2026-10-29T14-21
Command: ls tests/fixtures/orchestrator_state_issue_adoption/*.json | wc -l; poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py --collect-only -q -p no:cacheprovider --no-cov (count of `test_corpus_document_reproduces_the_expected_routing_errors[...]` items)
EXIT_CODE: 0

| Enumeration | Count |
| --- | --- |
| Directory listing of `*.json` | 34 |
| Python parity suite parametrized corpus cases | 34 (37 items collected in total; 3 are non-parametrized suite tests) |

Constants at baseline: `MINIMUM_CORPUS_COUNT = 34` (Python and TypeScript parity suites), `$minimumFixtureCount = 34` (Pester parity suite).

Output Summary: Both enumerations agree at 34, matching all three minimum constants.
