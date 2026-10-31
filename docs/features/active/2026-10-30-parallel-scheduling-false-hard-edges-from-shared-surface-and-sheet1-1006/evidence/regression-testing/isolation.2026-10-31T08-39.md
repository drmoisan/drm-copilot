# Test Isolation Checks (issue #1006)

Timestamp: 2026-10-31T08-39
Task: P8-T15

## Seeded shuffled Jest run

Command: node run-jest.cjs --randomize --seed=1006 (in extensions/drm-copilot/)
EXIT_CODE: 0
Output Summary: seed 1006; Test Suites 324 passed of 324; Tests 5257 passed of 5257; zero failures.

## Reversed-order Python run

Command: sh SCRATCH/issue-1006-reverse.sh (one pytest process with a SCRATCH plugin `issue_1006_reverse_plugin` that reverses the collected items) over test_blast_radius_config_parity.py, test_blast_radius_config_tolerance_keys.py, test_push_down_claude_overlay_parity.py, test_blast_radius_generic_contracts.py, test_push_down_claude_blast_radius_overlay_demote.py, test_blast_radius_mandate_reads.py, test_blast_radius_extraction.py, and test_push_down_claude_blast_radius_overlay.py (all under tests/scripts/dev_tools/)
EXIT_CODE: 0
Output Summary: 214 tests in reversed order (first `test_push_down_claude_blast_radius_overlay.py::test_ac14_merged_paths_registry_shape`, last `test_blast_radius_config_parity.py::test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`); 214 passed, zero failures.

## Seeded shuffled Pester file order (one process per seed)

Command: sh SCRATCH/issue-1006-ps.sh issue-1006-pester-files.ps1 -Seed <seed> -File BlastRadius.TruthTable.Tests.ps1,BlastRadius.KeyPartition.Tests.ps1,BlastRadiusGenericContract.Tests.ps1,BlastRadiusExtraction.Path.Tests.ps1,BlastRadiusTokenShape.Tests.ps1 (under tests/scripts/claude-lib/blast-radius/; file order shuffled with System.Random(seed), Fisher-Yates)
EXIT_CODE: 0
Output Summary:
- Seed 11: order BlastRadiusExtraction.Path, BlastRadiusTokenShape, BlastRadius.KeyPartition, BlastRadius.TruthTable, BlastRadiusGenericContract; 172 passed, 0 failed.
- Seed 23: order BlastRadius.KeyPartition, BlastRadius.TruthTable, BlastRadiusTokenShape, BlastRadiusGenericContract, BlastRadiusExtraction.Path; 172 passed, 0 failed.
- Seed 47: order BlastRadius.TruthTable, BlastRadiusExtraction.Path, BlastRadiusTokenShape, BlastRadiusGenericContract, BlastRadius.KeyPartition; 172 passed, 0 failed.

The fresh single-process Pester run over tests/scripts is recorded under qa-gates/pester-full (P8-T7).
