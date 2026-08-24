# Feature Audit: PreToolUse hooks parse flat payload and always allow (#501) — Cycle-1 Re-Audit

**Audit Date:** 2026-08-22
**Work Mode:** `full-bug` (persisted marker in `issue.md`, confirmed by direct read)
**AC Source:** `spec.md`, `## Acceptance Criteria` (AC-1 through AC-15; `user-story.md` legitimately absent under `full-bug`)
**Base Branch:** `main @ fb30a9a58b8422e610a09b07361421e97367807a`
**Head Branch:** `bug/pretooluse-hooks-parse-flat-payload-501 @ db3de8314d12d23d82f2fdaafcc0f9e7632f433e`

## Scope and Baseline

This is a re-audit of the full branch diff (`fb30a9a5..db3de831`), not the remediation delta. Three commits landed since the prior audit: `d0c472c3` (AC-15, work-mode-aware `enforce-prd-feature-before-planner.ps1`, authorized scope expansion) and `db3de831` (batch-budget entry-point seam, remediation of the prior cycle's Blocking coverage finding). AC-1 through AC-14 were previously evaluated PASS by the prior audit and are re-confirmed here rather than re-derived from scratch, since none of their governing production files (`HookPayload.psm1`, the 22 other migrated hooks, the mirror set) changed this cycle. AC-15 is new this cycle and is evaluated to the same standard as AC-1 through AC-14.

## Acceptance Criteria Inventory

### Acceptance criteria (spec.md, `## Acceptance Criteria`)

AC-1 through AC-15, all in checkbox format `- [x] **AC-N (...).** ...`. All 15 are checked `[x]` in `spec.md` at the time of this audit.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 transport unit suite | PASS | Unchanged this cycle; re-confirmed present and passing in the executor's final full-repo run (3364/0 failures) | `evidence/qa-gates/2026-08-22T16-13-poshqc-test-final.md` | Not independently re-executed this cycle; governing file unchanged since prior PASS |
| 2 | AC-2 stdin nested differential | PASS | Unchanged this cycle; prior cycle's live re-execution stands, governing hook (`enforce-epic-merge-gate.ps1`) unchanged since | prior cycle's evidence, unchanged | Not re-executed this cycle |
| 3 | AC-3 env nested, empty stdin | PASS | Unchanged this cycle | prior cycle's evidence, unchanged | Not re-executed this cycle |
| 4 | AC-4 fail-closed anomalies | PASS | Unchanged this cycle; both batch-budget hooks' anomaly-handling logic (`Get-ClaudeHookPayloadAnomalyReason` call, deny-on-invalid) is untouched by the entry-point-seam refactor — only the tail wiring around the unchanged decision function changed | reviewer read of `.claude/hooks/enforce-powershell-batch-budget.ps1`, this session: `Resolve-ClaudeHookToolInput` / `Get-*BlockDecision` calls identical to pre-cycle | Confirmed no regression by direct diff of the decision-logic portion vs. `db3de831~1` |
| 5 | AC-5 validate-bash exception | PASS | Unchanged this cycle; `validate-bash.ps1` not touched in this cycle's diff | `git diff d0c472c3~1..db3de831 -- .claude/hooks/validate-bash.ps1` returns empty | Confirmed empty diff this session |
| 6 | AC-6 property-level tolerance | PASS | Unchanged this cycle | prior cycle's evidence, unchanged | Not re-executed this cycle |
| 7 | AC-7 per-hook nested deny tests | PASS | Unchanged this cycle; 24-hook set unchanged | prior cycle's evidence, unchanged | `enforce-prd-feature-before-planner.ps1` was already one of the 24 registered hooks before this cycle (migrated at `c76a2990`, prior to the prior audit) |
| 8 | AC-8 structural regression guard | PASS | Re-run this cycle by the executor (77/77) and cross-checked by this reviewer via direct grep of every changed hook for the two retired env-var literals | `evidence/qa-gates/2026-08-22T14-41-payload-contract-regression-check.md`; reviewer grep this session | Confirms neither batch-budget hook nor the AC-15 hook reintroduced `$env:CLAUDE_TOOL_INPUT`/`$env:CLAUDE_HOOK_INPUT` |
| 9 | AC-9 mirror parity | PASS | Reviewer re-ran the pytest gate this session (1 passed) and independently `diff`-confirmed byte-identity for every one of the 24 changed `.claude/hooks/*.ps1` files, `HookPayload.psm1`, and both `pester.runsettings.psd1` copies | `poetry run pytest ... -k test_bundled_claude_payload_contains_all_repo_runtime_contracts` (this session); `diff` loop (this session) | Zero divergent, zero missing |
| 10 | AC-10 live end-to-end probe | PASS | Unchanged this cycle; governing hook (`enforce-epic-merge-gate.ps1`) untouched | prior cycle's evidence, unchanged | Not re-executed this cycle |
| 11 | AC-11 coverage | PASS | Repo-wide LINE coverage 96.47% (executor final run, `evidence/qa-gates/2026-08-22T16-13-poshqc-test-final.md`), reviewer-corroborated for the specific files that regressed last cycle; runsettings diff for this cycle is empty (no runsettings change in `d0c472c3`/`db3de831` beyond what the prior cycle already added) | reviewer coverage reproduction this session (see Coverage Verification below) | AC-11's repo-wide clause and the per-file floor are both now satisfied with no exception needed |
| 12 | AC-12 file-size ceiling | PASS | Reviewer scan of every changed `.ps1`/`.psm1`/`.psd1` file in the full range: max production file 494 lines (`HookPayload.psm1`), max this-cycle-changed file 349 lines (`enforce-prd-feature-before-planner.ps1`); zero files over 500 | reviewer loop over `git diff --name-only fb30a9a5..db3de831`, this session | Executor evidence `evidence/qa-gates/2026-08-22T16-19-file-size-ceiling-final.md` concurs |
| 13 | AC-13 scope boundaries | PASS | Reviewer re-confirmed this session: `git diff --name-only fb30a9a5..db3de831` contains no `.codex/hooks/` path; the three files matching a `SubagentStop` grep are PreToolUse hooks referencing the term only in explanatory comments about a separate hook event, not SubagentStop validators themselves | reviewer grep this session | AC-15's own text explicitly reaffirms this boundary is held for its scope too |
| 14 | AC-14 toolchain clean pass | PASS | Executor final evidence (`evidence/qa-gates/2026-08-22T15-46/48-*.md`, `2026-08-22T16-13-*.md`): format exit 0 zero-modified, analyze exit 0 zero-findings, test exit 0 3364/0 failures, single sequential pass. Reviewer independently re-ran `Invoke-ScriptAnalyzer` and `Invoke-Formatter` against the six directly-cycle-changed files this session: 0 findings, all already formatted | executor evidence; reviewer re-run this session | Full-tree re-run not repeated by this reviewer (2m timeout on this session's sandbox); targeted files and the executor's full-tree record together establish PASS |
| 15 | AC-15 prd-feature work-mode-aware prerequisites | PASS | (a) full-feature requires both files, block reason names only missing files — confirmed by direct code read of `Get-PrdFeatureRequiredFile`'s `full-feature` case and by the corresponding named test. (b) full-bug requires spec.md only, does not block on a spec.md-only folder — confirmed by code read and by the corresponding named test, and is the exact scenario this feature's own remediation cycle needed to pass through. (c) minor-audit requires neither file — confirmed by code read (`@()` return) and named test. (d) undeterminable marker (absent/unreadable/unrecognized) fails closed to the strictest set with a distinguishable reason string (`$modeDetermined` branch produces two genuinely different literal strings) — confirmed by direct code read of `Invoke-PrdFeatureBeforePlannerDecision`'s reason-construction `if`/`else`, and by four named tests covering all three sub-cases of "undeterminable." Mirror parity: confirmed byte-identical this session. Coverage: 90.32% (executor) / 88.98% (reviewer's narrower single-suite reproduction), both well above 85%, no exclusion added. Scope boundary: confirmed this cycle's diff for AC-15 touches only the hook, its mirror, its test file, and `spec.md`. | reviewer direct code read + independent 47/47 test re-run, this session; `evidence/qa-gates/2026-08-22T14-02-ac15-prd-feature-hook-final.md` | This is the criterion most exposed to a permissive-failure regression given #501's own subject matter; verified at the code level, not merely at the test-pass level, per the task's explicit instruction |

---

## Summary

**Overall Feature Readiness:** READY (PASS)

**Criteria summary:**
- **PASS:** 15 criteria (AC-1 through AC-15)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:** None. Zero Blocking findings remain in this cycle's policy audit or code review. One new Minor finding (a docstring accuracy defect in `enforce-prd-feature-before-planner.ps1`, introduced by the AC-15 edit) is recorded in the code review and does not gate readiness.

**Recommended follow-up verification steps:**

1. Optional, low-risk: fix the duplicated-word/stale-description docstring in `enforce-prd-feature-before-planner.ps1` before or shortly after opening the PR (code-review Minor finding).
2. At PR-creation time, assert only `#501` for autoclose in the PR body/commit trailer, per the prior cycle's Info-finding-2 disposition (still applicable, since the PR has not yet been opened as of this audit).
3. The separately-filed SubagentStop follow-up defect (`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`) remains out of this feature's scope and unaffected by this cycle.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All 15 criteria in `spec.md` were already checked `[x]` prior to this audit (AC-1 through AC-14 by the original executor, AC-15 by the AC-15 delivery task). This audit independently evaluated every criterion as PASS, so the existing check-off state is correct and no source-file change was made by the reviewer.

### AC Status Summary

- Source: `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0

## Coverage Verification (this cycle's re-measurement)

Per the mandatory coverage-verification procedure, PowerShell is the only language with changed files in this cycle's diff (`d0c472c3`, `db3de831`: `.ps1`/`.psd1` only).

- New files this cycle: none (both changed hooks pre-existed at merge-base).
- Modified files this cycle: `enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1`, `enforce-prd-feature-before-planner.ps1`.
- Coverage artifact: `artifacts/pester/powershell-coverage.xml` (executor's final run) — present, inspected. Reviewer independently regenerated two narrower artifacts this session (`artifacts/pester/verify-batch-budget-coverage.xml`, `artifacts/pester/verify-prd-feature-coverage.xml`) rather than trusting the on-disk executor artifact alone, per this project's standing practice of not trusting `artifacts/pester/*.xml` as durable evidence.
- Repo-wide LINE coverage: 96.47% (executor), consistent with the reviewer's per-file reproductions. >= 80% threshold: PASS. >= 85% uniform-tier threshold: PASS.
- Modified-file coverage, all three files: `enforce-powershell-batch-budget.ps1` 95.56%, `enforce-python-batch-budget.ps1` 95.56% (both reviewer-reproduced), `enforce-prd-feature-before-planner.ps1` 90.32%/88.98%. All >= 85%; all above the 80% modified-file floor with no regression from baseline (baseline for the two batch-budget hooks was 96.30%; the 0.74pp gap is assessed as immaterial in the policy audit, section "Assessment: is the 95.56% vs. 96.30% shortfall material?"; baseline for the AC-15 hook was 86.76%, and it improved).
- No branch-coverage threshold applies to PowerShell (Pester measures line/command coverage only); no FAIL recorded for its absence, per `.claude/rules/powershell.md`.
