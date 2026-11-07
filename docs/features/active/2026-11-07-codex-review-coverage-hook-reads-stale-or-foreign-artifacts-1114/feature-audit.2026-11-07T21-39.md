# Feature Audit: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

**Audit Date:** 2026-11-07
**Work Mode:** full-bug (from `issue.md`); AC source: `spec.md` `## Acceptance Criteria`.
**Review Type:** Re-audit after remediation cycle 2

## Scope and Baseline

- Branch `bug/codex-coverage-hook-freshness` at `eb20091a7891728d6455578f4376801a04bde37f`; base `main`, merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e` (equal to `origin/main`).
- Scope: full branch diff (66 paths). PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, which record head `eb20091a7891728d6455578f4376801a04bde37f`.
- Baseline: Phase 0 artifacts under `evidence/baseline/` (Pester 15881 tests, 0 failed; PowerShell 94.06% lines). Cycle 2 reference: `evidence/baseline/scope-check.2026-11-07T20-55.md` (cycle 1 final gate 16066 tests, 0 failed; 94.13%; target file 98.70%).
- Verification sources used by this review: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (written 21:21 UTC, after the last production commit at 21:10 UTC), the cycle 2 evidence files, `git diff`, SHA-256 comparison, a re-run of the pytest contract set and the Codex generator check, and direct calls of the head and pre-cycle extractors.
- Prior review: `remediation-inputs.2026-11-07T20-40.md` (PASS) and the cycle 2 inputs `remediation-inputs.2026-11-07T20-49.md` (CR-3, Low); remediation plan `remediation-plan.2026-11-07T20-49.md` (all tasks checked).

## Acceptance Criteria Inventory

| # | Criterion (abridged) | Source state |
|---|---|---|
| 1 | Foreign-audit selection fixed; row `1114: judges the audit named by the reviewer when another item's audit is newer`; fail-before evidence | [x] |
| 2 | Recency selection removed; `Get-LatestPolicyAudit` gone; no `docs/features/active` enumeration; two rows replaced | [x] |
| 3 | Stale report in an item worktree blocks; reason names language and item root; fail-before evidence | [x] |
| 4 | Absent report in an item worktree blocks; reason names language, expected path, item root | [x] |
| 5 | Integration scenario row passes | [x] |
| 6 | D2 rows: block once; `continue = false` when the stop hook is active | [x] |
| 7 | Ambiguous or invalid audit paths block (target suite rows) | [x] |
| 8 | Extraction and selection rows (shapes, separators, labels, relative, absolute, greatest timestamp) | [x] |
| 9 | Freshness scope D1 no-probe rows | [x] |
| 10 | Freshness twin parity rows | [x] |
| 11 | Single-item fresh behaviour unchanged; parity suites pass | [x] |
| 12 | Runtime isolation: E4-ST7 and E4-ST3 pass | [x] |
| 13 | Dependency-load failures: `B1` rows pass | [x] |
| 14 | No Claude production change; no Python in hooks; Claude suites pass | [x] |
| 15 | Mirror and manifest parity (`legacy-codex-hook-contracts.Tests.ps1`) | [x] |
| 16 | Bundle contract tests and generator check | [x] |
| 17 | Brief parity and brief contract tests | [x] |
| 18 | Coverage >= 85% for the three hook files | [x] |
| 19 | Full toolchain single pass, no new failures | [x] |
| 20 | CI-dependent: `poshqc / PowerShell hook suites (Linux)` passes on the PR head | [ ] |

## Acceptance Criteria Evaluation

| # | Status | Evidence |
|---|---|---|
| 1 | PASS | Row passes in the merged JUnit (16067 tests, 0 failures); `fail-before.2026-11-07T19-37.md` records it failing with the foreign audit judged. Cycle 2 did not touch the hook. |
| 2 | PASS | The hook file is unchanged since the initial review, which verified the absence of `Get-LatestPolicyAudit` and of any `docs/features/active` enumeration; the replacement rows pass. |
| 3 | PASS | Row passes; fail-before recorded. |
| 4 | PASS | Row passes. |
| 5 | PASS | Row passes. |
| 6 | PASS | Both rows pass in the merged JUnit. |
| 7 | PASS | Target suite 42 of 42 pass, including `AUDIT_AMBIGUOUS`, `TARGET_WORKTREE_AMBIGUOUS`, the three `AUDIT_PATH_TRAVERSAL` rows, `AUDIT_NOT_FOUND`, and null or non-string rows. This review's probes confirm policy-audit `..` paths still block after the cycle 2 narrowing. |
| 8 | PASS | All extraction rows pass, including the cycle 2 row selecting a valid audit beside a non-audit `..` path. |
| 9 | PASS | No-probe rows pass in the twin suite (21 of 21). |
| 10 | PASS | Parity rows pass; twin file unchanged since the initial review. |
| 11 | PASS | Named rows and both parity suites pass in the merged JUnit (narrowing parity 66 of 66, floor parity 4 of 4). |
| 12 | PASS | `E4-ST7` and `E4-ST3` rows pass. |
| 13 | PASS | `hook-dependency-failure.Codex.Tests.ps1` 93 of 93, including four `B1` rows for the Codex hook. |
| 14 | PASS | `git diff --name-only` from the merge base lists no path under `.claude/hooks`, `.claude/lib`, `.codex/config.toml`, `.codex/hooks/hook-target-worktree.ps1`, or the Claude bundle mirrors; no `.py` under `.codex/hooks`; the four Claude suites pass (18, 28, 21, and 73 tests, 0 failures). |
| 15 | PASS | `legacy-codex-hook-contracts.Tests.ps1` 43 of 43; SHA-256 of all three hook files equals their bundle copies. |
| 16 | PASS | This review re-ran the bundle, manifest, and dependency-closure contract tests (within 50 passed) and `generate_codex_agent_variants.py --check` (exit 0). |
| 17 | PASS | Brief copies unchanged by cycle 2; the four brief contract tests pass in this review's run. |
| 18 | PASS | This review's parse: hook 100.00%, twin 97.96%, target 98.73%. |
| 19 | PASS | Cycle 2 format, analyze, leak scan (21-11), Pester (21-21), and pytest (21-22) gates report no failures; Pester went from 0 failures in the Phase 0 baseline to 0 failures at the final gate. |
| 20 | PENDING-CI | No PR exists yet (`gh pr list --head bug/codex-coverage-hook-freshness --state all` returns none); the S9 gate owns the check-off. |

## Summary

- 19 of 20 criteria PASS on verified evidence; criterion 20 is pending CI and carries no finding.
- CR-3 from the cycle 1 re-audit is resolved. No new finding is introduced by cycle 2.
- No base drift: the merge base equals `origin/main`.

## Acceptance Criteria Check-off

Criteria 1 to 19 were already checked off in `spec.md`. This review verified each one at the current head and made no change to the file. Criterion 20 stays unchecked for the S9 gate.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: CI-dependent: the `poshqc / PowerShell hook suites (Linux)` job passes on the PR head, including the three named codex-hooks suites.
