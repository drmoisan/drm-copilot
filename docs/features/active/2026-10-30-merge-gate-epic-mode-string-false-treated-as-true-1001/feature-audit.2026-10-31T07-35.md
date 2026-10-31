# Feature Audit: Strict epic_mode in three enforcement hooks (#1001), reaudit after remediation cycle 1

---

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001`
**Base Branch:** `main`
**Head Branch:** `bug/merge-gate-epic-mode-string-false-1001`
**Work Mode:** `full-bug`
**Audit Type:** Re-review after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `ccec4eba82e272d27f7d81c0e0657a93110de5fb`)
- **Head branch/commit:** `bug/merge-gate-epic-mode-string-false-1001` (commit `45827a64c91d648bff71be0bf41c04cf31aebfe7`)
- **Merge base:** `ccec4eba82e272d27f7d81c0e0657a93110de5fb`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-31 07:22:31 UTC for the head SHA above)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/evidence/**`
  - Additional evidence: direct inspection by this review of `artifacts/pester/powershell-coverage.xml`, `cmp` of each source/mirror pair, `git diff --name-only` against the merge base and against the prior review head, and `validate_evidence_locations.py`
- **Feature folder used:** `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only AC source; no `user-story.md` exists or is required.
- **Scope note:** The audit covers the full branch diff against `main`. No acceptance criterion in `spec.md` depends on CI on the PR head. Since the prior review (head `efa4259525e592dcc42a52a03bb0e938821d774e`) only documentation and evidence files inside the feature folder changed, so the prior per-criterion verification of hook, mirror, and suite content carries over; criteria touched by the remediation (AC-11, AC-14) were re-verified.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/spec.md` — only source

### Acceptance criteria

Criteria are numbered AC-1 to AC-14 in source order; full text is in `spec.md` `## Acceptance Criteria`.

1. `Test-ChildCheckpointAllowsEpicMerge` returns `$true` only for JSON `true` (with `step9_status: "passed"`); the seven other matrix rows return `$false`.
2. `Invoke-EpicMergeGateDecision` denies `gh pr merge <N> --merge` with `EPIC_MERGE_GATE_BLOCKED` for `"false"`/`"true"`, allows for JSON `true`; an otherwise-green standalone checkpoint with `"false"` denies and never calls `Get-EpicMergeGateLivePrHeadSha`.
3. `Test-EpicBaseBranchOverride` returns `EPIC_BASE_BRANCH_MISMATCH` only for JSON `true`; seven other rows return `$null`.
4. `Get-ModelRoutingAuthorAssertedReason` waives the line only for JSON `true`; `-eq $true` replaced by a `-is [bool]` test; seven other rows return `AUTHOR_ASSERTED_AUTOCLOSE_MISSING`.
5. Fail-before and pass-after evidence under `evidence/regression-testing/` with the stated failing rows, required fields, and no absolute paths.
6. Comment-based help in the named five locations states the JSON-boolean requirement and cites the issue.
7. Deny and reason message text unchanged; named existing suites pass without edits.
8. Bundled mirrors byte-identical; `test_push_down_claude_resource_contracts.py` passes and is recorded.
9. Existing Pester suites for the in-scope hooks pass without edits.
10. Formatter and PSScriptAnalyzer clean for every touched `.ps1`; recorded under `evidence/qa-gates/`.
11. Pester over `tests/scripts/claude-hooks` passes with coverage; per-file line coverage of the three hooks meets the governing threshold and is not below baseline.
12. Every touched file passes the hard file-size limit; no `config/file-size-baseline.json` addition.
13. New suites create no files; seeded shuffled runs under multiple recorded seeds pass.
14. Branch diff touches only in-scope files; no `.codex/`, `.claude/rules/`, `.github/instructions/`, `.claude/skills/execution-environment/`, or validator change.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `Test-ChildCheckpointAllowsEpicMerge` strict | PASS | Hook uses `(($Checkpoint.epic_mode -is [bool]) -and $Checkpoint.epic_mode)`; the suite carries the eight rows with only JSON `true` expecting `$true`; `pass-after.2026-10-31T06-22.md` 31/31; the full-suite run reports 0 failures. | `git diff ccec4eba8..HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1`; Pester over `*.EpicModeStrict.Tests.ps1` | Hook file unchanged since the prior review. |
| 2 | Merge-gate decision rows | PASS | Suite rows: JSON `true` allow; `"false"`/`"true"` deny matching `EPIC_MERGE_GATE_BLOCKED`; otherwise-green row asserts `Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly`; fail-before shows these rows returned `allow` before the fix. | same | |
| 3 | `Test-EpicBaseBranchOverride` strict | PASS | Hook uses the strict idiom; eight suite rows; fail-before shows `"false"`, `"true"`, `1` returned `EPIC_BASE_BRANCH_MISMATCH` before the fix. | same | |
| 4 | `Get-ModelRoutingAuthorAssertedReason` strict | PASS | Hook replaces `-eq $true` with `($Checkpoint.epic_mode -is [bool]) -and $Checkpoint.epic_mode`; eight suite rows; fail-before shows `"true"` and `1` returned `$null` before the fix. | same | |
| 5 | Fail-before and pass-after evidence | PASS | `fail-before.2026-10-31T06-20.md`: 31 tests, 11 failures matching the stated rows, fields `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`; `pass-after.2026-10-31T06-22.md` 31 passed; no absolute paths in the evidence records. | `Read` of both files | |
| 6 | Help text in five locations | PASS | Diff adds the statement to merge-gate `.DESCRIPTION` condition 1 and `Test-ChildCheckpointAllowsEpicMerge`; `Test-EpicBaseBranchOverride`; model-routing script `.DESCRIPTION` author-asserted paragraph and `Get-ModelRoutingAuthorAssertedReason`; each cites issue #1001. | `git diff ccec4eba8..HEAD -- .claude/hooks` | |
| 7 | Deny and reason text unchanged | PASS | Hook diff hunks touch only predicate lines and help text; `deny-text-unchanged.2026-10-31T06-34.md`; the four named suites pass without edits (`existing-suites.2026-10-31T06-23.md`). | same | |
| 8 | Mirrors byte-identical; contract pytest | PASS | `cmp` by this review: 3 of 3 identical; `mirror-contracts.2026-10-31T06-24.md` SHA-256 pairs equal and 34 passed including `test_push_down_claude_resource_contracts.py`. | `cmp` | |
| 9 | Existing suites pass without edits | PASS | No existing test file in `git diff --name-only ccec4eba8 HEAD`; `existing-suites.2026-10-31T06-23.md` EXIT_CODE 0; the full-suite run reports 0 failures. | `git diff --name-only` | |
| 10 | Format and analysis clean | PASS | `format.2026-10-31T06-25.md` 9 files, 0 would change; `pssa.2026-10-31T06-25.md` 9 files, 0 findings; no covered file changed since. | `Invoke-Formatter`; `Invoke-ScriptAnalyzer` | |
| 11 | Coverage per hook meets threshold, no regression | PASS | `artifacts/pester/powershell-coverage.xml` (full-suite run, generated 07:17:22) read by this review: 132/132 = 100.00%, 29/31 = 93.55%, 81/84 = 96.43%, identical to baseline; the same artifact reports repo-wide 93.53%; `pester-coverage-full.2026-10-31T07-21.md` records 13518 tests, 0 failures. | JaCoCo read | The criterion names `evidence/coverage/`, which is not a canonical evidence kind; records sit under the canonical `evidence/qa-gates/`. The substance of the criterion is met. |
| 12 | File-size limit | PASS | Logical line counts: hooks and mirrors 482, 146, 352; suites 109, 71, 60; `config/file-size-baseline.json` not in the diff; `file-size.2026-10-31T06-34.md`. | Logical line count | |
| 13 | Test isolation and seeded shuffles | PASS | No file-creating cmdlet or `TestDrive:` in the suites (`no-file-creation.2026-10-31T06-34.md`); seeds 1001, 2718, 31415 each 660/660. | `Read` of suites and shuffle evidence | |
| 14 | No change outside scope | PASS | `git diff --name-only ccec4eba8 HEAD`: 3 hooks, 3 mirrors, 3 new suites, 39 feature-folder files; no `.codex/`, `.claude/rules/`, `.github/`, `.claude/skills/execution-environment/`, `config/`, or validator path; `scope-check.2026-10-31T07-22.md`. | `git diff --name-only` by this review | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. The policy-audit finding raised in the prior review (PA-1, repo-wide PowerShell coverage figure) is closed at 93.53%.

**Recommended follow-up verification steps:**

1. After the PR exists, confirm the Linux hook-suite job and the PowerShell QC job pass on the PR head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/spec.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 14 | 14 | 0 | Checkbox-backed; all 14 were already checked and are confirmed here. |

No source-file checkbox change was made by this review: every criterion evaluated PASS was already checked.
