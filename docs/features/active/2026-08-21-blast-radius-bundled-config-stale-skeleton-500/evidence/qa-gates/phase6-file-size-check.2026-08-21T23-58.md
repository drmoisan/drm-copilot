# Phase 6 file-size ceiling check (Issue #500)

Timestamp: 2026-08-21T23:58:00Z
Issue: #500
Task: [P6-T13]

Command:

```
wc -l tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/dev_tools/blast_radius_parity_test_support.py
```

(working directory: worktree root)

EXIT_CODE: 0

Output Summary:

| File | Lines | Headroom to 500 |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 387 | 113 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 353 | 147 |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 172 | 328 |

Every count is at or under the 500-line ceiling in `.claude/rules/general-code-change.md`.

## A split was required and was performed

Before the split, `tests/scripts/dev_tools/test_blast_radius_config_parity.py` measured **510**
lines once the three-class gate, the umbrella denylist, the separator-free assertion, the
non-vacuity floor, and the parse-and-version case were added to the two Phase 1 regression tests.
That is 10 lines over the ceiling, so the split branch [P6-T13] authorizes was taken.

**What moved:** the declared constants and the read-only key accessors. Specifically
`BUNDLED_CONFIG`, `SELF_HOSTED_CONFIG`, `SELF_HOSTED_CONFIG_LABEL`, `ROOT_SURFACE_FILENAME`,
`PORTABLE_SHARED_SURFACES`, `UMBRELLA_MODULE_NAMES`, `PAYLOAD_MODULE_NAMES`, `BYTE_EQUAL_KEYS`, and
the four accessors `config_key`, `module_names`, `shared_surfaces`, and `shared_surface_globs`.

**Where it moved to:** the new module `tests/scripts/dev_tools/blast_radius_parity_test_support.py`.
The name follows the `*_test_support.py` convention already established in this directory by
`parallel_drift_test_support.py`, `epic_planner_launch_evidence_test_support.py`,
`parallel_orchestrator_permission_seam_support.py`, and
`parallel_orchestrator_surface_test_support.py`. The prefix keeps pytest from collecting it as a
test module.

**What did NOT move:** every assertion. All 14 test cases remain in
`test_blast_radius_config_parity.py`, so **every test node ID is unchanged** by the split. That
matters because the fail-before artifact
`evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md` cites the two
regression tests by their full node IDs, and the pass-after artifact must pair with it against the
same identifiers.

**What was not touched:** `tests/scripts/dev_tools/test_blast_radius_config.py` remains unmodified
at 499 lines. The plan does not edit it, and the shared helpers `load_config_file`,
`load_module_globs`, `COMMITTED_CONFIGS`, `CONFIG_PATH`, `BUNDLED_CONFIG_PATH`, and
`BUNDLED_CONFIG_LABEL` are imported from it rather than duplicated.
