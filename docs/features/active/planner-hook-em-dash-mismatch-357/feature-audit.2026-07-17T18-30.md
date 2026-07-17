# Feature Audit: planner-hook-em-dash-mismatch-357 (#357)

**Audit Date:** 2026-07-17T18-30
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `f3da03a242641fcef1f6e1c0892be7fe6fa14489`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit following remediation cycle 3 (triggered by a required-CI-check failure on PR #358, not by a local review finding)

---

## Scope and Baseline

- **Base branch:** `main`, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`.
- **Head branch/commit:** `drm-copilot-wt-2026-07-17T10-05` @ `f3da03a242641fcef1f6e1c0892be7fe6fa14489` (includes `f3e15904` initial implementation, `6e7bc63c` remediation cycle 1, `67cd49a6` remediation cycle 2, `5d1431ae` prior clean-reaudit record, and `f3da03a2` remediation cycle 3).
- **Evidence sources:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/**` (all four cycles' baseline, remediation-baseline, qa-gates, and regression-testing subtrees), direct `git diff 67c871eb..HEAD` inspection, direct SHA-256 comparison of the canonical hook file and its bundled mirror (computed by this audit), direct re-run of `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and the full suite `python -m pytest -q`, and direct `git log` inspection confirming the canonical hook and test files are unchanged since remediation cycle 2.
- **Requirements source:** `issue.md` `## Acceptance Criteria` section only (work mode `minor-audit`).
- **Scope note:** No caller-supplied scope narrowing was detected or accepted; this audit evaluates the full branch diff (`67c871eb..HEAD`) against `main`. The re-audit framing note describing cycle 3's trigger (a bundled-mirror parity CI failure) is background context, not a scope instruction, and was independently confirmed rather than assumed.

---

## Acceptance Criteria Inventory

**Authoritative AC source file:** `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`

1. `Get-PlanStructureValidationReport` in `.claude/hooks/validate-planner-output.ps1` accepts `### Phase N — <Title>` (em dash) phase headings.
2. A new/updated Pester test in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` proves a plan using the em-dash heading format passes validation (regression test, written to fail against the pre-fix regex).
3. Existing fixtures are updated to use the em dash so the suite reflects the real contract rather than masking the mismatch.
4. PoshQC format, analyze, and Pester toolchain all pass with no regressions.

All four items are marked `[x]` in `issue.md` at the time of this audit. This audit independently re-verifies each item before confirming any check-off, consistent with prior cycles' practice.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Notes |
|---|-----------|--------|----------|-------|
| 1 | `Get-PlanStructureValidationReport` accepts `### Phase N — <Title>` (em dash) phase headings | **PASS** (unchanged since cycle 0) | Direct read of `.claude/hooks/validate-planner-output.ps1` line 121 confirms `$phasePattern = '^### Phase (?<Phase>\d+)\s+—\s+(?<Title>.+)$'` (em dash, U+2014). `git log --oneline -- .claude/hooks/validate-planner-output.ps1` confirms no commit has touched this file since `67cd49a6` (remediation cycle 2); cycle 3 touched only the bundled mirror. | Independently re-verified via direct file read and git history for this audit. |
| 2 | New/updated Pester test proves em-dash plan passes; written to fail against pre-fix regex | **PASS** (unchanged since cycle 0) | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` unchanged since `67cd49a6`; confirmed via `git log`. `evidence/regression-testing/em-dash-fail-before.md` / `em-dash-pass-after.md` document the original fail-before/pass-after regression proof, unaffected by cycle 3. | Not touched by cycle 3. |
| 3 | Existing fixtures updated to use em dash | **PASS** (unchanged since cycle 0) | Same unchanged-file basis as item 2. | Not touched by cycle 3. |
| 4 | PoshQC format, analyze, and Pester toolchain all pass with no regressions | **PASS** (re-confirmed this cycle; the CI-check failure that triggered cycle 3 was a separate repo-hygiene gate — bundled-mirror byte parity — not the PoshQC format/analyze/Pester toolchain itself, but this audit verifies both) | PoshQC toolchain: format exit 0, analyze exit 0/zero findings, Pester 21/21 pass, all scoped to the unchanged canonical files (`evidence/qa-gates/poshqc-{format,analyze,test}-remediation3-final.md`) — this audit independently re-confirms these files are unchanged since the 17-15 audit's approval. Coverage: 93.86% line coverage carried forward unchanged (canonical file content provably identical via SHA-256 and git history). Separately, the required CI check that actually failed on PR #358 (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, a Python repo-hygiene test, not part of the PoshQC PowerShell toolchain) is now resolved: this audit independently re-ran it (1 passed) and the full suite (1533 passed, 0 failed). | The bundled-mirror byte-parity fix is necessary for the branch's CI to go green overall, even though it is not literally "the PoshQC toolchain" named in AC 4's text. This audit treats AC 4 as satisfied on its literal PowerShell-toolchain scope (which was never broken) and separately confirms the CI-check failure that blocked merge readiness is resolved, so the feature's overall CI-readiness is intact. |

---

## Summary

**Overall Feature Readiness:** **READY TO MERGE** (unchanged disposition from the 17-15 audit; the intervening CI failure was resolved by remediation cycle 3 without altering any AC-covered file's content)

**Criteria summary:**
- **PASS:** 4 criteria (1, 2, 3, 4)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Resolution of the cycle-3 trigger:** The required CI check `quality-checks7 / Code Quality & Tests (3.10)` failed on PR #358 due to `test_bundled_claude_payload_contains_all_repo_runtime_contracts` detecting that the bundled mirror of `.claude/hooks/validate-planner-output.ps1` had drifted from the canonical copy. This is a repo-hygiene parity gate distinct from the PoshQC PowerShell toolchain AC 4 literally names, but it is a required CI check and therefore a real blocker to merge. Remediation cycle 3 fixed it via a single, minimal, byte-for-byte `Copy-Item` sync, verified by this audit through independent SHA-256 comparison (identical hash, 9829 bytes both files) and by directly re-running both the targeted and full pytest suites (1 passed targeted; 1533 passed, 0 failed full suite).

**No AC-covered file's content changed in cycle 3.** `git log --oneline -- .claude/hooks/validate-planner-output.ps1` and the same for the test file both show no commit since `67cd49a6` (remediation cycle 2) — the state already fully verified by the 17-15 audit. This audit's re-verification of AC 1-3 is therefore a confirmation of unchanged, previously-approved state, not a new finding.

**Remaining non-blocking follow-up (not a condition of this feature's merge):** The `mcp__drm-copilot__run_poshqc_test` MCP tool's own resolution of a stale, npx-cached, separately-published package (independent of this workspace) remains a genuine but separate tooling defect, unchanged from prior cycles' disposition, recommended for a new issue.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules: criteria evaluated as PASS may be checked off if not already checked; criteria evaluated as PARTIAL, FAIL, or UNVERIFIED must remain unchecked.

All four items in `issue.md` are already marked `[x]`. This audit's independent re-verification confirms all four criteria remain correctly PASS. No un-checking is warranted.

### AC Status Summary

- Source: `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`
- Total AC items: 4
- Checked off (delivered, confirmed by this audit's independent verification): 4 (items 1, 2, 3, 4)
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS, this audit) | Unchecked (this audit) | Notes |
|-------------|----------|------------------------------|--------------------------|-------|
| `issue.md` | 4 | 4 | 0 | Checkbox-backed, authoritative for `minor-audit`; all four items confirmed PASS and correctly marked `[x]` in the source file. Unaffected by remediation cycle 3, which touched only a non-AC-covered bundled resource mirror. |

---

**Audit Completed By:** feature-review (Claude Code subagent)
**Audit Date:** 2026-07-17T18-30
