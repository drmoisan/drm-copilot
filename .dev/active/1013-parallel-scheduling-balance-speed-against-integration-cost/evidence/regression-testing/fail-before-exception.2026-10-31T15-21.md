# Fail-Before Exception Dossier — AC-01 Default Tolerance Pin

Timestamp: 2026-10-31T15-21
Command: none (exception dossier; no failing run is possible)
EXIT_CODE: 0
Output Summary: AC-01 asserts a value the published truth table already ships at the branch base, so a fail-before run of the `tolerance_percent` half cannot fail; the alternative proof is P4-T5 and P4-T6.

WhyFailingRunImpossible: The published truth table `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` already ships `conflict_tolerance.tolerance_percent` 100 at the branch base (recorded in `evidence/baseline/line-counts.*.md` through `COMMITTED_CONFLICT_TOLERANCE`, and read from `config/blast-radius.json` during Phase 0). An in-memory push with no overlay therefore already writes 100, and no pre-change run of that assertion can fail. D-1 makes no value change; the behavior is pinned, not introduced.

## Alternative proof

- P4-T5 creates `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py`, which derives and composes the destination document in memory from the committed bundled truth table with no overlay and asserts `conflict_tolerance.tolerance_percent == 100` and `conflict_tolerance.combination_threshold_percent == 400`. The `combination_threshold_percent` half is introduced by P4-T1, so that half of the assertion would fail against the branch base.
- P4-T6 creates `extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts`, which runs the same in-memory scenario through `deriveDestinationModuleMap` and `composeBlastRadiusOverlay` with a null overlay and asserts the same two values.
- Absence-of-test proof: before this change no test pinned the destination `tolerance_percent` after an overlay-free push. SearchScope: `tests/scripts/dev_tools/`, `extensions/drm-copilot/test/lib/push-down/`. SearchPatterns: `default_tolerance`, `default-tolerance`. SearchResult: none at the branch base.
