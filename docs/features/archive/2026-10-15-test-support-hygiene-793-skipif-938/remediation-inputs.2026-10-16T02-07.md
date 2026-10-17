# Remediation Inputs: Test-support hygiene and stale skipif (#938), cycle 2

Review-Verdict: REMEDIATION_REQUIRED

Timestamp: 2026-10-16T02-07
Branch: `bug/test-support-hygiene-793-skipif-938` (HEAD at cycle entry is the merge of `origin/main` into `48aeb4060`)
Origin: coordinator decision D4 (operator policy: related follow-ups are fixed inside the item before merge). The cycle 1 re-audit (`*.2026-10-16T01-50.md`) was PASS with 0 blocking; the items below were classified unrelated in cycle 1 and are reclassified as related because they sit in files this item already changes.

## Blocking findings

### RI-2: Dispatch test imports shared builders from two modules

Remediability: autonomous
Remediability-Evidence: Test-only import consolidation inside a file this item already edits; no production code, no external dependency, no policy hold.

File: `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py`

Required outcome: the file imports every shared builder only from `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py` (module path `tests.scripts.dev_tools.validate_orchestration_artifacts_test_support`), with no import from `tests.scripts.dev_tools.test_validate_orchestration_artifacts`.

### RI-3: Three builders remain in test_validate_orchestration_artifacts.py

Remediability: autonomous
Remediability-Evidence: Mechanical move matching the #793 builder move already delivered in this item; all importers are in-repo test files.

Builders: `build_valid_orchestrator_state`, `build_valid_policy_audit_text`, `build_complete_large_orchestrator_state`, currently defined in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.

Required outcome:
1. The three builders are defined in `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py` with unchanged bodies and signatures.
2. They are removed from `test_validate_orchestration_artifacts.py`, which imports the ones it uses (for example `build_valid_policy_audit_text`) from the support module.
3. Every importer of these three names is repointed to the support module (known: `test_validate_orchestration_artifacts_dispatch.py`, `test_validate_orchestration_artifacts_state_shape.py`; the planner must enumerate all importers by repository search). No re-export remains in the old module.
4. No file exceeds 500 lines; the support module stays under the limit (a split into a second support module is acceptable only if required to hold the limit, and must be recorded).
5. Full Python toolchain loop passes (Black, Ruff, Pyright, Pytest with coverage) with pass counts equal to the cycle 1 baseline (full suite 7094 passed, 6 skipped).

## Non-blocking findings

None.
