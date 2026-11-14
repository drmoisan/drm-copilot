# Pass-After — Contract Weight (Phase 2 gate)

Timestamp: 2026-10-31T15-29
Command: poetry run pytest <the twelve P0-T6 modules> tests/scripts/dev_tools/test_blast_radius_contract_weight.py -q -p no:cacheprovider --no-cov; sh SCRATCH/issue-1013-pester-run.sh p2t10 (branch-current PowerShell 7 Invoke-Pester over tests/scripts/claude-lib/blast-radius and tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1); sh SCRATCH/issue-1013-jest.sh p2t10 test/lib/push-down
EXIT_CODE: 0
Output Summary: zero failures in all three runtimes. Python 339 passed, 5 skipped; Pester JUnit tests=732 failures=0 errors=0 skipped=1; Jest 30 suites, 472 tests passed.

## Per-runtime detail

- Python: 339 passed, 5 skipped (the five `manifest_m1_*` accessor-expectation skips of `test_parallel_manifest_bash_parity.py`), 0 failed. Includes `test_blast_radius_contract_weight.py` and `test_ac16_corpus_composition_matches_expected` over the ten corpus files, including `conflict-tolerance-contract-weight.json` and the edited `shared-surfaces-demote-already-append-only.json`.
- Pester (from the JUnit file): tests=732, failures=0, errors=0, skipped=1. `BlastRadiusScheduling.ContractWeight.Tests.ps1` tests=33 failures=0; `ParallelDrift.Parity.Tests.ps1` tests=20 failures=0.
- Jest: Test Suites 30 passed of 30; Tests 472 passed of 472. `claude-blast-radius-overlay-parity.test.ts` ran 11 tests: the discovery row plus one `composes %s to its expected text` row per corpus file (ten files, including `conflict-tolerance-contract-weight.json`).
