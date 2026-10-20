# Remediation Plan — Issue #984, Cycle 1 (2026-10-20T15-44)

Remediation-Mode: proportionate

Scope: fix 1 of `remediation-inputs.md` only (strengthen `test_scanned_source_floor`). Minor finding 2 is accepted without change. Requirement sources: `spec.md` and `issue.md` in the feature folder; original plan `plan.2026-10-20T07-56.md`. Tool routes, launchers, and command-text restrictions are owned by the `execution-environment` skill and are not restated here. `<FEATURE>` is `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`. Evidence filenames follow `<name>.<timestamp>.md` with the write-time UTC stamp.

## Design

Verified against the current tree:

- `Surface.powershell_sources()` in `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` returns, per manifest, that manifest's `.ps1`/`.psm1` paths, plus the virtual-resource PowerShell destinations under the core pack. The union of those lists therefore equals the distinct `.ps1`/`.psm1` entries across `Surface.manifests` plus the `.ps1`/`.psm1` keys of `Surface.virtual`. This is the count relation the scanner satisfies: equality of the scanned set with an independently derived expected set (not `>=`, not a constant).
- Claude anchor: `.claude/hooks/enforce-completion-consistency.ps1` is listed in the Claude `core.json` manifest and dot-sources `enforce-completion-helpers.ps1` through `$PSScriptRoot`.
- Codex anchor: `.codex/hooks/enforce-completion-consistency.ps1` is listed in the Codex `core.json` manifest and uses `$PSScriptRoot` dependencies. The Codex surface has no source_prefix pack listing PowerShell, so the anchor is scanned.

Change: add a pure helper `_scan_floor_gaps(label, scanned, expected, anchor)` returning messages that name the surface label and either the missing anchor or the count mismatch (with the missing and extra members). `test_scanned_source_floor` is rewritten to call it for each surface with the data-derived expected set and the surface anchor. An in-module test narrows the scan by monkeypatching `Surface.powershell_sources` and asserts `test_scanned_source_floor` then raises `AssertionError`. No production file, manifest, hook, bundle file, or existing assertion changes.

Existing tests asserting the changed behavior: only `test_scanned_source_floor` in the same file (updated: it is the subject of the fix). `test_every_psscriptroot_occurrence_is_recognized`, `test_claude_manifest_powershell_dependency_closure`, and `test_codex_manifest_powershell_dependency_closure` read `powershell_sources()` but are unchanged and unaffected. `test_pack_manifest_dependency_scan.py` and `test_push_down_claude_pack_manifest_completeness.py` do not import the changed symbol and are unaffected.

## Pre-Mortem

- Review checklists: the final phase self-review walks the policy-audit, code-review, and feature-audit templates against the branch diff, and the Python docstring and loop-intent-comment rules apply to the new helper and tests.
- Coverage: not applicable. Only a test file changes and no production file changes; the strengthened floor is itself exercised by the named tests, and the positive and negative paths of the new helper are both asserted.
- Mirror parity: not applicable. No mirrored, bundled, or generated file is edited, and no fact stated by the execution-environment brief changes, so no brief-update task is needed.
- File size: the test file is 348 lines today; P2-T3 records its physical line count and asserts it stays at or under 500.
- Test isolation: the new tests use only in-memory sets and `monkeypatch` (reverted after each test), no temporary files. P2-T5 runs the three modules in reversed order in one process and records the order. Jest and Pester are not touched, so no shuffled run applies.
- CI-only behavior: the tests read only tracked bundle manifests and tracked sources, so they do not depend on gitignored `artifacts/` state; paths are POSIX relative strings with no drive letters.
- Evidence: every command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, is written under `<FEATURE>/evidence/<kind>/`, and the fail-before artifact records the expected non-zero exit with `ExpectedExitCode:` in its own file.

## Phases

### Phase 0 — Policy reads and baseline

- [x] [P0-T1] Read the policy files in the order of the `policy-compliance-order` skill, including `.claude/rules/python.md` and `.claude/rules/python-suppressions.md`, and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, and the list of files read. Acceptance: the artifact exists with all three fields.
- [x] [P0-T2] Run Pytest over `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py`, and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and write `<FEATURE>/evidence/baseline/remediation-pytest.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the passed count. Acceptance: `EXIT_CODE: 0` and a recorded passed count.
- [x] [P0-T3] Record the physical line count of `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` with `wc -l` in `<FEATURE>/evidence/baseline/remediation-file-size.<timestamp>.md` (schema fields as above). Acceptance: the artifact records a count at or under 500.

### Phase 1 — Strengthen the non-vacuity floor

- [x] [P1-T1] [expect-fail] In `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, add `test_scanned_source_floor_rejects_narrowed_scan`: for each of `claude_surface()` and `codex_surface()`, monkeypatch `Surface.powershell_sources` to return a single pack mapped to one non-anchor source, and assert that calling `test_scanned_source_floor()` raises `AssertionError`. Run only this test against the unchanged weak floor and write `<FEATURE>/evidence/regression-testing/fail-before-floor.<timestamp>.md` with the four schema fields. Acceptance: the test fails (the weak floor does not raise, so pytest reports `DID NOT RAISE`) with a non-zero `EXIT_CODE`.
- [x] [P1-T2] In `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, add the pure helper `_scan_floor_gaps(label, scanned, expected, anchor)` returning one message per defect: a message naming `label` and `anchor` when the anchor is not in `scanned`, and a message naming `label`, the missing members, and the extra members when `scanned != expected`. Add one test of the helper with in-memory sets covering the clean case, the missing-anchor case, and the count-mismatch case. Acceptance: the helper test passes and asserts each message names the surface label and the anchor or the mismatch.
- [x] [P1-T3] In the same file, add module constants for the two anchors (`.claude/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-consistency.ps1`) and rewrite `test_scanned_source_floor` to call `_scan_floor_gaps` per surface, with `expected` derived from `Surface.manifests` and `Surface.virtual` by taking the distinct `.ps1`/`.psm1` entries, and to assert the combined result is an empty list. The `len(scanned) >= 1` assertion is replaced because the new check subsumes it. Acceptance: `test_scanned_source_floor` passes on the real surfaces.
- [x] [P1-T4] Run the three modules named in P0-T2 and write `<FEATURE>/evidence/regression-testing/pass-after-floor.<timestamp>.md` with the four schema fields. Acceptance: `EXIT_CODE: 0`, with `test_scanned_source_floor_rejects_narrowed_scan` and `test_scanned_source_floor` both reported as passed and the passed count greater than the P0-T2 count.

### Phase 2 — Final QA loop

Run each step in order; if a step fails or changes a file, fix it and restart from P2-T1. Each step writes `<FEATURE>/evidence/qa-gates/<name>.<timestamp>.md` with the four schema fields.

- [x] [P2-T1] Run `poetry run black --check` on `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (artifact `remediation-format`). Acceptance: `EXIT_CODE: 0` and the output reports the file would be left unchanged.
- [x] [P2-T2] Run `poetry run ruff check` on `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (artifact `remediation-lint`). Acceptance: `EXIT_CODE: 0` and `All checks passed!`.
- [x] [P2-T3] Run `poetry run pyright` on `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (artifact `remediation-types`) and record its physical line count with `wc -l` (artifact `remediation-file-size`). Acceptance: `0 errors` and a line count at or under 500.
- [x] [P2-T4] Run Pytest over `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py`, and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (artifact `remediation-tests`). Acceptance: `EXIT_CODE: 0`, no failures, and the passed count equals the P1-T4 count.
- [x] [P2-T5] Run Pytest over the same three modules in reversed order in one process, recording the order, and write `<FEATURE>/evidence/regression-testing/python-reversed-order-remediation.<timestamp>.md`. Acceptance: `EXIT_CODE: 0` and the passed count equals the P2-T4 count.
- [x] [P2-T6] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. A FAIL row is fixed and the loop re-run from P2-T1 before the file is rewritten. Acceptance: the artifact exists with no FAIL row and records that the diff adds no hook, manifest, bundle, or CHANGELOG change.
