# Feature Audit: Epic-Level Checkpoint Seam for Enforcement Gates (#663) - Remediation Cycle 1 Re-Audit

**Audit Date:** 2026-09-25
**Feature Folder:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663`
**Base Branch:** `origin/main`
**Head Branch:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (prior audit `feature-audit.2026-09-25T20-26.md`)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `d754f83f`)
- **Head branch/commit:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663` (commit `3371d937`)
- **Merge base:** `d754f83f714b087e404577cb7a1b02f48d2023bb`
- **Audit scope:** the full branch diff `git diff origin/main...HEAD` (151 files). The cycle-1 range `71e6e594..HEAD` received close reading.
- **Evidence sources:**
  - Primary: `git diff origin/main...HEAD` and `git diff 71e6e594..HEAD`. The PR context summary and appendix are absent from the worktree, and the collector is not in this reviewer's toolset (code review CR-9).
  - Feature evidence: `evidence/remediation-baseline/rem1-*`, `evidence/regression-testing/rem1-fail-before-rb1.md`, `rem1-fail-before-rb2.md`, and `evidence/qa-gates/rem1-*`.
  - Reviewer checks:
    - SHA-256 over the four helpers copies and two module copies
    - `git ls-files --eol`
    - a parse of `artifacts/pester/powershell-coverage.xml`
    - `validate_evidence_locations.py --root .` (exit 0)
    - a function-level diff of the helpers parser against `origin/main`
    - a hand trace of the post-fix scanner
- **Feature folder used:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663`
- **Requirements source:** `spec.md` only (`## Acceptance Criteria`, lines 222-277).
- **Work mode resolution note:** `issue.md:3` reads `- Work Mode: full-bug`.
- **Scope note:** Operator-approved D1-D5 were treated as binding and not reopened. Pester results come from the executor's recorded evidence. The reviewer could not execute PowerShell in this worktree (the isolation guard denies `pwsh`), and instead confirmed coverage by parsing the coverage XML directly.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md` (only source)

### Acceptance criteria

The 25 criteria are enumerated verbatim in `feature-audit.2026-09-25T20-26.md` (AC-1 to AC-25, spec lines 226-277). The text in `spec.md` has not changed since that audit: `git diff 71e6e594..HEAD -- spec.md` is empty. The short labels below are used in the evaluation table.

1. (spec.md:226) Resolver suite: branch signal, `-C` HEAD, session-root HEAD, not-epic cases, absolute path never from text.
2. (spec.md:230) Gate 1 allow.
3. (spec.md:231) Gate 1 deny with checkpoint and conjunct named.
4. (spec.md:232) Gate 1 standalone unchanged; existing pr-author suites unmodified.
5. (spec.md:236) Gate 2 epic `--base main` allow and mismatch deny with a single resolution.
6. (spec.md:237) Gate 2 existing `epic_mode` rows pass unmodified.
7. (spec.md:241) Gate 3 allow with a `pr-author` receipt.
8. (spec.md:242) Gate 3 deny without the receipt.
9. (spec.md:243) Gate 3 standalone unchanged.
10. (spec.md:247) Gate 4 allow with a ready checkpoint and `MERGE_HEAD`.
11. (spec.md:248) Gate 4 deny: no merge (D2) and each epic-shape conjunct.
12. (spec.md:249) Gate 4 path leg follows the command-leg decision.
13. (spec.md:250) Gate 4 standalone unchanged; existing gate-4 suites unmodified.
14. (spec.md:254) Gate 4b CommandExemption rows (Co-Authored-By and apostrophe exempt, single-quoted `<`/`>` exempt, `'\''` denied, `$(`/`$VAR`/backtick denied, unquoted redirection denied).
15. (spec.md:255) Codex command-exemption suite carries the same rows.
16. (spec.md:256) Four helpers copies SHA-256 identical; parity and legacy-codex suites pass.
17. (spec.md:260) Gate 5 pinning (D3).
18. (spec.md:264) Gate 6 non-regression.
19. (spec.md:268) epic-plan / epic-planner contract.
20. (spec.md:269) epic-orchestrate / epic-orchestrator contract.
21. (spec.md:270) Validator accepts the additive epic fields.
22. (spec.md:274) Mirrors, pack manifest, and manifest test.
23. (spec.md:275) No Python in hooks; PowerShell-authoritative headers (D5).
24. (spec.md:276) 500-line limit; `WorktreeResolution.psm1` and `OrchestratorState.psm1` unchanged.
25. (spec.md:277) Full PowerShell toolchain in one pass; each changed PowerShell production file >= 85% line coverage.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Resolver suite | PASS | The resolver suite now has 23 tests (21 prior plus H1 and H2), all passing (`rem1-final-pester-coverage.md`). The two new rows at `EpicScopeResolution.Tests.ps1:354-383` show that the `-C` selector HEAD decides a head-matched leg whatever the text label says. `rem1-fail-before-rb2.md` shows both new rows failing before the fix. | `git diff 71e6e594..HEAD -- .claude/lib tests/scripts/claude-lib` | Cycle 1 strengthened this criterion; the AC text still holds. The design prose at spec.md:83 is approximate (follow-up 7). |
| 2 | Gate 1 allow | PASS | Unchanged since the prior audit; the gate-1 caller does not pass `-MatchWorktreeHead`, so CR-2 does not affect it (resolver line 316 early return). | resolver trace | |
| 3 | Gate 1 deny | PASS | Unchanged; full run 0 failures. | `rem1-final-pester-coverage.md` | |
| 4 | Gate 1 standalone | PASS | Unchanged; cycle 1 touched no pr-author suite. | `git diff --name-only 71e6e594..HEAD` | |
| 5 | Gate 2 epic scope | PASS | Unchanged; gate 2 reuses the gate-1 scope object. | as above | |
| 6 | Gate 2 existing rows | PASS | Unchanged; full run 0 failures. | as above | |
| 7 | Gate 3 allow | PASS | Unchanged; the gate-3 caller (`enforce-model-routing-receipt.ps1:247`) does not pass `-MatchWorktreeHead`. | resolver trace | |
| 8 | Gate 3 deny | PASS | Unchanged. | | |
| 9 | Gate 3 standalone | PASS | Unchanged. | | |
| 10 | Gate 4 allow (D2) | PASS | G4-1 passed (`rem1-final-pester-coverage.md`, per `evidence/other/ac-checkoff.md` cycle-1 row AC-10). | evidence inspection | |
| 11 | Gate 4 deny | PASS | G4-2, G4-3 (three conjuncts), and G4-4 (two conjuncts) passed. | evidence inspection | RS-2 interpretation from the prior audit is unchanged. |
| 12 | Gate 4 path leg | PASS | G4-6 and G4-7 passed. | evidence inspection | |
| 13 | Gate 4 standalone | PASS | G4-8 to G4-11 passed. The eight existing gate-4 suites each have 0 failures. G4-11 is the new CR-2 row at `...gate.EpicScope.Tests.ps1:228-245`. | evidence inspection | |
| 14 | Gate 4b rows | PASS | The eight prior #663 rows and the D4 row 12c/12d rows passed. Six new deny rows at `CommandExemption.Tests.ps1:467-486` cover the exact CR-1 line, the `;` variant, the CR-3 chain form, an unquoted `\"`, an unquoted `\'`, and a backslash inside a double-quoted message. Fail-before `rem1-fail-before-rb1.md` shows exactly these rows failing before the fix. | reviewer diff and hand trace (helpers lines 131, 148) | The prior audit noted that CR-1 was outside the AC rows; it is now closed and covered. |
| 15 | Codex 4b rows | PASS | Same six rows at the codex suite `:474-493`; all rows passed against the `.codex/hooks` copy. | reviewer diff | |
| 16 | Helper parity | PASS | Reviewer SHA-256 over all four copies gives `5bb872e2de58734d6aaa7ce25343c5c9796839c3eeb8610562db365d17881d7f`. The parity suite (2) and `legacy-codex-hook-contracts.Tests.ps1` (43) passed. | `sha256sum` over the four copies | |
| 17 | Gate 5 pinning (D3) | PASS | Unchanged; cycle 1 touched no gate-5 file. | `git diff --name-only 71e6e594..HEAD` | |
| 18 | Gate 6 non-regression | PASS | Unchanged. | as above | |
| 19 | epic-plan / epic-planner contract | PASS | Unchanged. | | |
| 20 | epic-orchestrate / epic-orchestrator contract | PASS | Unchanged. | | |
| 21 | Validator additive test | PASS | Unchanged; no Python changed in cycle 1. | | |
| 22 | Mirrors and manifests | PASS | Reviewer SHA-256 confirms both `EpicScopeResolution.psm1` copies equal `9ff75eeb...d61ec`. `rem1-final-pytest-contracts.md` records 27 passed, and `WorktreeResolution.Manifest.Tests.ps1` passed (16). | `sha256sum` | |
| 23 | No Python in hooks (D5) | PASS | Reviewer Grep over the added lines of `git diff origin/main...HEAD -- .claude/hooks .claude/lib .codex/hooks` found no `python`, `poetry`, or `.py` invocation. | Grep over saved diff | |
| 24 | 500-line limit | PASS | Helpers 497 (all four copies), `EpicScopeResolution.psm1` 369, suites 487/494/383/329 (`rem1-line-limits.md`, reviewer `wc -l` agrees for the helpers and module). `rem1-unchanged-surfaces.md` shows empty diffs for `WorktreeResolution.psm1` and `OrchestratorState.psm1`. | `wc -l` | The helpers file has 3 lines of headroom. |
| 25 | Toolchain and coverage | PASS | Pass 1 was clean (`rem1-final-seven-stage-loop.md`): format 0 rewrites, analyze 0 findings, 5073 tests with 0 failures. Reviewer parse of the coverage XML: helpers 97.04% (both measured copies), `EpicScopeResolution.psm1` 90.38%, `EpicScopeReadiness.psm1` 95.92%, epic-scope sibling 100.00%, gate 93.42%, pr-author helpers 97.00%, epic-base-branch 93.55%, model-routing receipt 95.52%. No regression (`rem1-final-coverage-delta.md`). | coverage XML parse | `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with <FEATURE>/evidence/qa-gates/` (canonical location; not a finding). |

---

## Summary

**Overall Feature Readiness:** READY (pending the operational items below)

All 25 acceptance criteria are satisfied. The two findings that made the prior audit NEEDS REVISION are closed with fail-before and pass-after evidence: CR-1 (Blocker) and CR-2 (Major). No blocking finding remains in the code review or the policy audit.

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None among the acceptance criteria.
2. Operational items outside the AC list: collect PR context against `origin/main`, obtain a green CI run on the branch head, and perform the manual #655-sequence rerun (follow-up 5, `spec.md:292`).
3. Documentation accuracy: correct follow-up 8 (code review N-1) and the spec.md:83 design prose (follow-up 7).

**Recommended follow-up verification steps:**

1. Run `mcp__drm-copilot__collect_pr_context` against `origin/main` before pr-author.
2. Confirm the CI workflow is green on the PR head. CI checks out at depth 1, and no changed test references remote refs.
3. Promote follow-ups 6-8 as issues, with follow-up 8 corrected per N-1.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 25 criteria were already checked, and each was independently re-evaluated as PASS in this re-audit. No checkbox in `spec.md` was changed by this review, and none needed to be unchecked.

### AC Status Summary

- Source: `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md`
- Total AC items: 25
- Checked off (delivered): 25
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md` | 25 | 25 | 0 | Checkbox-backed; no change made by this review |
