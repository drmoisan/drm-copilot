# Committed-config Consumer Inventory (P0-T33)

Timestamp: 2026-09-27T15-25
Command: git grep -l -F -e blast-radius.json -- tests/scripts ; git grep -l -w -F -e derive_blast_radius -e normalize_declared_radius -e validate_blast_radius -e Get-BlastRadius -e Get-NormalizedDeclaredRadius -e Test-BlastRadius -- tests/scripts
EXIT_CODE: 0
Output Summary: Both commands exited 0. The intersection of the two file lists is fourteen files, identical to the planning-time candidate set (no difference). Nineteen tests in seven of the fourteen files (sixteen Python, three Pester) read a committed config copy and call a derive, normalize, or validate function on it; the other seven files contain no such test. Exactly three tests are classified "requires helper update", and they are the three named in the plan Preamble's scoped-test-update section. Stop condition not reached.

## Command 1 output (git grep -l -F -e blast-radius.json -- tests/scripts)

```text
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
tests/scripts/dev_tools/blast_radius_parity_test_support.py
tests/scripts/dev_tools/parallel_drift_test_support.py
tests/scripts/dev_tools/test_blast_radius_config.py
tests/scripts/dev_tools/test_blast_radius_config_parity.py
tests/scripts/dev_tools/test_blast_radius_extraction.py
tests/scripts/dev_tools/test_blast_radius_mandate_reads.py
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py
tests/scripts/dev_tools/test_blast_radius_normalization.py
tests/scripts/dev_tools/test_blast_radius_validation.py
tests/scripts/dev_tools/test_blast_radius_verification_integrity.py
tests/scripts/dev_tools/test_claude_rules_frontmatter.py
tests/scripts/dev_tools/test_compute_blast_radius.py
tests/scripts/dev_tools/test_parallel_mergeable_cohort.py
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py
```

## Command 2 output (git grep -l -w -F ... -- tests/scripts)

```text
tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
tests/scripts/dev_tools/test_blast_radius_config.py
tests/scripts/dev_tools/test_blast_radius_config_parity.py
tests/scripts/dev_tools/test_blast_radius_extraction.py
tests/scripts/dev_tools/test_blast_radius_extraction_rules.py
tests/scripts/dev_tools/test_blast_radius_invariants.py
tests/scripts/dev_tools/test_blast_radius_mandate_reads.py
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py
tests/scripts/dev_tools/test_blast_radius_normalization.py
tests/scripts/dev_tools/test_blast_radius_parity.py
tests/scripts/dev_tools/test_blast_radius_validation.py
tests/scripts/dev_tools/test_blast_radius_verification_integrity.py
tests/scripts/dev_tools/test_compute_blast_radius.py
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py
```

## Candidate set (intersection; fourteen files)

Under tests/scripts/dev_tools: test_parallel_planner_surface_contracts_landed, test_compute_blast_radius,
test_blast_radius_verification_integrity, test_blast_radius_validation, test_blast_radius_normalization,
test_blast_radius_mergeable_paths, test_blast_radius_mandate_reads, test_blast_radius_extraction,
test_blast_radius_config_parity, test_blast_radius_config.

Under tests/scripts/claude-lib/blast-radius: BlastRadiusNormalization.Tests, BlastRadius.TruthTable.Tests,
BlastRadius.Tests, BlastRadius.Parity.Tests.

Difference from the planning-time set: none.

## Classification basis (Part B config)

The Part B committed config sets write_intent_extraction to true and carries path_roots (self-hosted:
the seventeen tracked top-level directories recorded by P0-T28; bundled: empty, so W4 is disabled for
the bundled copy), and adds the .github Copilot instructions file to mandate_reads. Under that config,
derivation and validation apply W1 through W6, and normalization applies W1, W4, W6, and the mandate
list. Every W rule only removes tokens. A test is "unchanged pass" when every token its assertions
depend on survives all six rules (or when its assertion is an absence or a non-conflict that removal
cannot falsify); it is "requires helper update" when an asserted token is removed.

## Per-test table

| # | File | Test | Config copy | Function | Expected outcome | Reason |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | test_blast_radius_config.py | test_disjoint_items_do_not_contend_through_the_committed_map | self-hosted | derive | unchanged pass | Asserts no conflict; W6 drops the foo.ts token from the extension item, which can only remove overlap. |
| 2 | test_blast_radius_config.py | test_items_sharing_a_benchmarks_file_contend_on_path_and_module | self-hosted | derive | unchanged pass | Edit task, single-token span, scripts root tracked, stem example_shared is not a placeholder stem. |
| 3 | test_blast_radius_config.py | test_items_sharing_only_a_test_file_contend_on_the_path_level | self-hosted | derive | unchanged pass | Edit task; tests root tracked; stem test_example_shared retained. |
| 4 | test_blast_radius_config.py | test_items_sharing_the_truth_table_contend_on_three_levels | self-hosted | derive | unchanged pass | Edit task; config root tracked; stem blast-radius retained. |
| 5 | test_blast_radius_config_parity.py | test_unrelated_claude_citations_do_not_contend_under_the_bundled_table | bundled | derive | unchanged pass | Asserts no conflict; rules only remove tokens. |
| 6 | test_blast_radius_config_parity.py | test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table | bundled | derive | unchanged pass | Regenerate task (not a read verb); single token package-lock.json; W4 disabled for the bundled copy; stem not a placeholder. |
| 7 | test_blast_radius_mandate_reads.py | test_derive_excludes_mandate_read_citations_from_every_level | self-hosted | derive | unchanged pass | Asserts absence of the read citations (also removed by W3/W4) and presence of the Edit-task token scripts/dev_tools/compute_blast_radius.py, which survives. |
| 8 | test_blast_radius_mandate_reads.py | test_derive_without_the_mandate_reads_key_includes_the_citations | self-hosted (mandate_reads removed) | derive | requires helper update | Asserts .claude/rules/python.md and quality-tiers.yml are present; both sit in a Read task, so W3 drops them once only mandate_reads is removed. |
| 9 | test_blast_radius_mandate_reads.py | test_derive_with_an_absent_key_matches_an_empty_mandate_read_list | self-hosted | derive | unchanged pass | Compares two derivations under the same W rules; they remain identical. |
| 10 | test_blast_radius_mandate_reads.py | test_derive_excludes_an_artifacts_path_through_the_subtree_glob | self-hosted | derive | unchanged pass | Asserts absence of artifacts paths; W4 also drops the untracked artifacts root. |
| 11 | test_blast_radius_mandate_reads.py | test_derived_radius_validates_clean_against_its_own_mandate_citing_plan | self-hosted | derive, validate | unchanged pass | Derivation and validation select the same extractor from the same flag (spec invariant), so V1 and V2 stay clean. |
| 12 | test_blast_radius_mergeable_paths.py | test_validate_blast_radius_findings_are_identical_with_and_without_the_key | self-hosted | derive, validate | requires helper update | Asserts QuickFiler.Test/QuickFiler.Test.csproj is in both derived radii; its first segment is not a tracked top-level directory, so W4 drops it. |
| 13 | test_blast_radius_mergeable_paths.py | test_derive_blast_radius_keeps_a_cited_csproj_in_paths | self-hosted | derive | requires helper update | Same token; W4 drops it. |
| 14 | test_blast_radius_verification_integrity.py | test_after_state_yields_only_the_genuine_conflict_edge | self-hosted | normalize | unchanged pass | The surviving 486-487 overlap extensions/drm-copilot/src/mcp-tools.ts is concrete, under a tracked root, with a non-placeholder stem, so it survives W1/W4/W6; removal cannot add an edge. |
| 15 | test_blast_radius_verification_integrity.py | test_after_state_surviving_edge_cites_the_shared_mcp_tool_surface | self-hosted | normalize | unchanged pass | The asserted single path_overlap detail is the surviving token above; removal cannot add a smaller overlap or a new reason. |
| 16 | test_blast_radius_verification_integrity.py | test_after_state_colours_into_two_cohorts | self-hosted | normalize | unchanged pass | Edge set unchanged (rows 14-15), so the coloring is unchanged. |
| 17 | BlastRadius.TruthTable.Tests.ps1 | Committed blast-radius truth table shape / Disjoint work items / reports no contention between two items with disjoint paths | self-hosted | Get-BlastRadius | unchanged pass | Mirror of row 1. |
| 18 | BlastRadius.Parity.Tests.ps1 | Verification-integrity regression / After state / reports only the genuine 486-487 conflict after normalization | self-hosted | Get-NormalizedDeclaredRadius | unchanged pass | Mirror of row 14. |
| 19 | BlastRadius.Parity.Tests.ps1 | Verification-integrity regression / After state / cites the shared MCP tool surface as the surviving path overlap | self-hosted | Get-NormalizedDeclaredRadius | unchanged pass | Mirror of row 15. |

Rows 1-16 are Python tests and rows 17-19 are Pester tests: nineteen tests across seven files
(test_blast_radius_config, test_blast_radius_config_parity, test_blast_radius_mandate_reads,
test_blast_radius_mergeable_paths, test_blast_radius_verification_integrity, BlastRadius.TruthTable.Tests,
BlastRadius.Parity.Tests).

## Candidates with no qualifying test

| File | Finding |
| --- | --- |
| test_parallel_planner_surface_contracts_landed.py | Asserts skill-document text only; reads no config copy and calls no derive, normalize, or validate function. |
| test_compute_blast_radius.py | Uses literal in-test configs only; no file read. |
| test_blast_radius_validation.py | Uses literal in-test configs only; no file read. |
| test_blast_radius_normalization.py | Uses literal in-test configs only; no file read. |
| test_blast_radius_extraction.py | Uses literal in-test configs only; the config path appears only as plan text. |
| BlastRadius.Tests.ps1 | Uses literal hashtable configs only; no config file read. |
| BlastRadiusNormalization.Tests.ps1 | Uses literal hashtable configs only; the facade Describe states its config is a literal so a change to the committed file cannot affect it. |
| BlastRadius.Parity.Tests.ps1 (fixture-driven Describes) | Derivation and conflict fixtures embed their own config; only the verification-integrity After-state tests (rows 18-19) read the committed copy. |
| test_blast_radius_config.py, test_blast_radius_config_parity.py, test_blast_radius_mergeable_paths.py, BlastRadius.TruthTable.Tests.ps1 (shape tests) | Shape and key-set tests read the committed copies but call no derive, normalize, or validate function; they are outside this inventory's scope (key-set changes are Backward-compatibility exception 1). |

## Result

Tests classified "requires helper update": exactly three, and they are the three named in the plan
Preamble:

1. test_derive_without_the_mandate_reads_key_includes_the_citations (test_blast_radius_mandate_reads.py)
2. test_derive_blast_radius_keeps_a_cited_csproj_in_paths (test_blast_radius_mergeable_paths.py)
3. test_validate_blast_radius_findings_are_identical_with_and_without_the_key (test_blast_radius_mergeable_paths.py)

No other test is classified "requires helper update", so the stop condition is not reached.

## Method limit

Part B is not implemented at Phase 0, so the classification is by reading each qualifying test against
the W1-W6 rule definitions in the spec, not by execution. Phase 9 (P9-T8 through P9-T10) and the Phase 15
and 16 QA loops execute these tests under the Part B config and will confirm or refute the table.
