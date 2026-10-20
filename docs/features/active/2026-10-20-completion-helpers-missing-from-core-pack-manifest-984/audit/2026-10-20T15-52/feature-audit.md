# Feature Audit: Completion helpers missing from the Claude core pack manifest (#984) — Remediation Cycle 1 Exit Re-audit

---

**Audit Date:** 2026-10-20
**Feature Folder:** `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
**Base Branch:** `main`
**Head Branch:** `bug/completion-helpers-missing-from-core-pack-manifest-984`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `58e5001c5907d74ee24f205690d891b4352fda23`)
- **Head branch/commit:** `bug/completion-helpers-missing-from-core-pack-manifest-984` (commit `a114539915767e4d9f04fe1c8df3b1debb8b11df` plus the uncommitted cycle 1 working-tree change to `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`)
- **Merge base:** `58e5001c5907d74ee24f205690d891b4352fda23`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-20 15:26:50 UTC for head `a114539915767e4d9f04fe1c8df3b1debb8b11df`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Cycle 1 delta: `git diff 58e5001c5` and `git diff a11453991` (read directly, because the PR context predates the working-tree change)
  - Feature evidence: `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/evidence/**`
  - Additional evidence: reviewer re-runs of Black, Ruff, Pyright, the three manifest Pytest modules (forward and reversed), the full Python suite, the evidence-location validator, and a re-parse of the Python and TypeScript coverage artifacts
- **Feature folder used:** `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
- **Requirements source:** `spec.md` (authoritative for `full-bug`); `issue.md` `## Acceptance Criteria` evaluated as the traceability mirror of spec AC1 to AC4
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug` (line 12); `spec.md` is the authoritative AC source.
- **Scope note:** The PR context covers the committed head only. It was not regenerated, because the PR-context tooling reads committed history and the single uncommitted file was reviewed directly. The full branch diff (109 files) was reviewed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/spec.md` — only authoritative source (full-bug)
- `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/issue.md` — traceability mirror of spec AC1 to AC4

### From spec.md

1. AC1: Claude `core.json` includes `.claude/hooks/enforce-completion-helpers.ps1`, and a fresh push-down into a clean target puts the file in place; the Codex `core.json` still carries `.codex/hooks/enforce-completion-helpers.ps1`.
2. AC2: A manifest dependency-closure test fails if any manifested hook depends on a sibling or lib file absent from the manifest, proven by an in-memory self-test; the exhaustiveness guard fails on an unrecognized `$PSScriptRoot` form. (FR-4, including FR-4.9 non-empty scanned-source floor.)
3. AC3: With the helper removed, a non-checkpoint `Edit` is allowed and an `Edit` of `artifacts/orchestration/orchestrator-state.json` is denied with `COMPLETION_CONSISTENCY_BLOCKED:` naming the helper; a `HookPayload.psm1` load failure denies every call.
4. AC4: CHANGELOG `## [Unreleased]` `### Fixed` entry with the 1.1.19-1.1.21 re-run instruction and the hook behavior statement.
5. AC5: Six further Claude core paths; command-text closure passes for `.claude/settings.json` and agent frontmatter.
6. AC6: Exception sets in the Python and TypeScript completeness tests are empty; "remain absent" replaced by "is empty".
7. AC7: `.codex/scripts/post-codex-worktree-session.ps1` in Codex core; `generate_codex_agent_variants.py --check` passes.
8. AC8: Discovery gate and batch-budget hooks (Claude and Codex) allow out-of-scope and deny in-scope on dependency failure; mirrors equal; Handler entries; guard, structural, and exemption suites pass.
9. AC9: Codex `enforce-completion-consistency.ps1` unchanged with recorded rationale; mirror parity, 500-line limit, and full toolchain pass.

### From issue.md (traceability mirror)

1. `core.json` includes `.claude/hooks/enforce-completion-helpers.ps1`, and a fresh push-down into a clean target puts the file in place.
2. A manifest completeness test fails if any manifested hook depends on a sibling or lib file that is absent from the manifest.
3. With the helper removed, a non-checkpoint `Edit` is allowed, and an `Edit` of `artifacts/orchestration/orchestrator-state.json` is denied with `COMPLETION_CONSISTENCY_BLOCKED`.
4. Release notes tell downstream repositories that received 1.1.19 to re-run push-down.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1: helper in Claude core; core-only push-down publishes it; Codex core still carries its helper | PASS | Unchanged since the prior audit; `test_core_only_selection_publishes_issue_984_path` (7 rows) and the Codex published-path rows pass in the reviewer's cycle 1 run | `poetry run pytest -q --no-cov -p no:randomly <three manifest modules>` (35 passed) | — |
| 2 | AC2: closure test fails on an absent dependency; exhaustiveness guard fails on unrecognized form; non-empty scanned-source floor | PASS | Self-tests unchanged and passing. Cycle 1 strengthens the FR-4.9 floor: anchor plus set equality per surface (`test_scanned_source_floor`), helper self-test, and a narrowed-scan failure test; fail-before `evidence/regression-testing/fail-before-floor.2026-10-20T15-48.md` | Same as row 1; reversed-order run (35 passed) | The new floor exceeds the "non-empty" requirement; equality with a non-empty expected set implies at least one scanned source. |
| 3 | AC3: helper removed: non-checkpoint Edit allowed; checkpoint Edit denied naming helper; HookPayload failure denies all | PASS | No PowerShell change in cycle 1; CH1-CH5 evidence from the prior audit stands (`evidence/qa-gates/ps-tests.2026-10-20T15-00.md`) | `git diff a11453991 --stat` (only the Python test changed) | — |
| 4 | AC4: CHANGELOG `### Fixed` entry | PASS | CHANGELOG unchanged in cycle 1; prior verification stands | `git diff a11453991 --stat` | — |
| 5 | AC5: six further Claude core paths; command-text closure passes | PASS | `test_claude_command_text_closure` passes in the reviewer's cycle 1 run | Same as row 1 | — |
| 6 | AC6: exception sets empty in Python and TypeScript | PASS | `test_pre_existing_exception_set_is_empty` passes in the cycle 1 run; TypeScript unchanged | Same as row 1 | — |
| 7 | AC7: Codex core carries `post-codex-worktree-session.ps1`; generator `--check` passes | PASS | `test_codex_core_selection_publishes_issue_984_path[.codex/scripts/post-codex-worktree-session.ps1]` passes; manifests unchanged in cycle 1 | Same as row 1; prior `generate_codex_agent_variants --check` exit 0 | — |
| 8 | AC8: discovery gate and batch-budget hooks; mirrors equal; Handler entries; suites pass | PASS | No PowerShell or bundle change in cycle 1; prior evidence stands | `git diff a11453991 --stat` | — |
| 9 | AC9: Codex `enforce-completion-consistency.ps1` unchanged; mirror parity; 500-line limit; toolchain pass | PASS | Codex hook still unchanged (`git diff 58e5001c5 --stat` does not list it); changed test file 450 lines; Python toolchain clean in this review; full Python suite 7369 passed, 6 skipped | `wc -l`; Black, Ruff, Pyright, Pytest (policy audit Appendix B) | — |

### Remediation cycle 1 fix verification

| Fix | Status | Evidence |
|---|---|---|
| Fix 1: per-surface named anchor in the scanned set | PASS | `CLAUDE_SCAN_ANCHOR`, `CODEX_SCAN_ANCHOR`; `_scan_floor_gaps` anchor branch; passes on real surfaces. |
| Fix 1: data-derived floor (scanned set equals distinct manifest and virtual `.ps1`/`.psm1` entries) | PASS | `expected` built from `surface.virtual` and `surface.manifests`; equality asserted through `_scan_floor_gaps`. |
| Fix 1: failure messages name the surface and the anchor or the mismatch | PASS | `test_scan_floor_gaps_reports_each_defect` asserts the label, anchor, and absent and additional members appear. |
| Fix 1: fail-before against an in-memory narrowed scan, no temporary files, no production edits | PASS | `fail-before-floor.2026-10-20T15-48.md` ("DID NOT RAISE"); `monkeypatch` only; `git diff a11453991 --stat` lists one test file. |
| Fix 1: verification commands (Black, Ruff, Pyright, Pytest, reversed order) | PASS | Reviewer re-ran each; all clean; 35 passed forward and reversed. |
| Do-not-do list (no hook, manifest, bundle, CHANGELOG, or AC edit; no assertion weakened; file at or under 500 lines; no commit) | PASS | `git diff a11453991 --stat`: one file; `len(scanned) >= 1` replaced by a stricter check; 450 lines; head still `a11453991`. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 9 criteria (spec.md); 4 of 4 traceability items in issue.md
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Commit and push the cycle 1 change, then confirm the S9 CI green gate (`ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head), including the Linux case-sensitive hook suite named in NFR-4.
2. Optional, non-blocking: isolate the two surfaces in `test_scanned_source_floor_rejects_narrowed_scan` (code review Minor finding).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/spec.md` (authoritative); `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/issue.md` (traceability mirror)
- Total AC items: 9 (spec.md); 4 (issue.md)
- Checked off (delivered): 9 (spec.md); 4 (issue.md)
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 9 | 9 | 0 | Lines 278-286, all `- [x]`; each evaluated PASS in this re-audit. |
| `issue.md` | 4 | 4 | 0 | `## Acceptance Criteria` lines 74-77, all `- [x]`; each evaluated PASS. |

No source-file checkbox change was made in this review, because every criterion was already checked and every check-off is supported by the evidence evaluated above.
