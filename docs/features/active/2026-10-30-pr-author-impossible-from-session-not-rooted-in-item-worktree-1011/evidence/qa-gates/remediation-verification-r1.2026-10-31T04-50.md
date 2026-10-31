# Remediation Verification (Issue #1011, Remediation Cycle 1, P4-T9)

Timestamp: 2026-10-31T04-50
Source: `remediation-inputs.2026-10-31T02-17.md` and `code-review.2026-10-31T02-17.md` (findings); `spec.md` `## Acceptance Criteria` (AC-01 to AC-18 in document order; work mode full-bug)
Evidence root: FEATURE = docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011

## Findings

| Finding | Regression row | Fail-before evidence | Post-change evidence | Status |
|---|---|---|---|---|
| F1 (CR-1, Blocking): SessionRoot labelling compared the resolved root with the raw session path only; now delegated to `ConvertTo-WorktreeItemResolvedResult` | TR-10 maps a CommandOperand root that encloses the session path to SessionRoot | `FEATURE/evidence/regression-testing/fail-before-r1.2026-10-31T02-42.md` (TR-10 failed: OtherWorktree instead of SessionRoot) | `FEATURE/evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` (TR-10 passed); `FEATURE/evidence/regression-testing/pester-full-r1.2026-10-31T04-46.md`; `FEATURE/evidence/regression-testing/isolation-r1.2026-10-31T04-48.md` | PASS |
| CR-2 (Minor): a command with a branch signal and a canonical issue line skipped the branch/issue agreement check; the shared resolver now runs only when no issue number is present | TR-11 lets the identity resolver decide when the command also carries a canonical issue line | `FEATURE/evidence/regression-testing/fail-before-r1.2026-10-31T02-42.md` (TR-11 failed: OtherWorktree instead of Ambiguous) | `FEATURE/evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` (TR-11 passed); `FEATURE/evidence/qa-gates/brief-parity-r1.2026-10-31T02-45.md` (brief sentence updated in six copies); `FEATURE/evidence/regression-testing/pester-full-r1.2026-10-31T04-46.md` | PASS |
| CR-3 (Minor): a registered worktree whose directory is gone was selected; a root failing `Test-WorktreeResolutionRootMarker` now yields no selection | TR-12 yields no selection for a resolved root whose directory is gone | `FEATURE/evidence/regression-testing/fail-before-r1.2026-10-31T02-42.md` (TR-12 failed: OtherWorktree object instead of null) | `FEATURE/evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` (TR-12 passed); `FEATURE/evidence/regression-testing/pester-full-r1.2026-10-31T04-46.md` | PASS |
| CR-4 (Info): two `git worktree list` processes on the identity fallback path | none | not applicable | not applicable | OUT_OF_SCOPE: the reviewer requires no action, the spec performance constraint permits the resolver's invocation in place of the replaced resolution, and removing the second listing would require passing resolver state into `Resolve-WorktreeItemTarget`, whose module this item may not edit |
| CR-5 (Info): a worktree root containing a space is denied by the allowlist | none | not applicable | not applicable | OUT_OF_SCOPE: the reviewer requires no action, the denial is fail-safe, the finding lies in `.claude/hooks/enforce-pr-author-command-allowlist.ps1` rather than the files this cycle edits, and repository worktree roots in use contain no spaces |

## Re-confirmed acceptance criteria

| AC | Criterion (abbreviated) | Evidence | Status |
|---|---|---|---|
| AC-06 | TargetResolution rows prove shared resolver invocation and the mappings; fail-before recorded | `FEATURE/evidence/regression-testing/fail-before-r1.2026-10-31T02-42.md`; `FEATURE/evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` (TR-01 to TR-12 passed) | PASS |
| AC-07 | A path-derived source does not select the worktree (issue #673) | TR-06 and TR-07 passed in `FEATURE/evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` | PASS |
| AC-08 | Existing gate suites pass with unchanged expectations, including the three ItemArtifactRoot rows | `FEATURE/evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` (534 tests, 0 failures; the three ItemArtifactRoot rows passed); `FEATURE/evidence/qa-gates/scope-check-r1.2026-10-31T04-48.md` (every AC-08 suite unchanged since REMEDIATION_BASE) | PASS |
| AC-09 | No change to the named functions; receipt checks unchanged | `FEATURE/evidence/qa-gates/scope-check-r1.2026-10-31T04-48.md` (sibling hook files and `.claude/lib/` exit 0; FUNCTIONS_UNCHANGED: 3/3) | PASS |
| AC-12 | `pr-author-issue-link-contract.Tests.ps1` passes without modification | `FEATURE/evidence/qa-gates/runtime-contracts-r1.2026-10-31T04-17.md` (0 failures); `FEATURE/evidence/qa-gates/scope-check-r1.2026-10-31T04-48.md` (exit 0 against MERGE_BASE) | PASS |
| AC-13 | Edited `.claude/` files byte-identical to bundle copies; four push-down contract tests pass | `FEATURE/evidence/qa-gates/mirror-parity-r1.2026-10-31T02-45.md` (cmp exit 0; digest 851f8b6a…, which equals the HELPERS digest in `ps-format-r1.2026-10-31T04-16.md`); `FEATURE/evidence/qa-gates/python-dev-tools-r1.2026-10-31T02-46.md` | PASS |
| AC-14 | Dependency-guard and no-Python suites pass with the import | `FEATURE/evidence/qa-gates/runtime-contracts-r1.2026-10-31T04-17.md` (734 tests, 0 failures) | PASS |
| AC-15 | Line coverage at or above 85% per hook file with no changed-line regression | `FEATURE/evidence/qa-gates/coverage-comparison-r1.2026-10-31T04-46.md` (HELPERS 97.73% (129/132), equal to baseline; allowlist 100%; every changed line executed) | PASS |
| AC-16 | Invoke-Formatter no changes; PSScriptAnalyzer zero findings | `FEATURE/evidence/qa-gates/ps-format-r1.2026-10-31T04-16.md` (FORMAT_CHANGED_COUNT: 0); `FEATURE/evidence/qa-gates/pssa-r1.2026-10-31T04-16.md` (0 findings per file) | PASS |
| AC-17 | Seeded shuffled runs and the full `tests/scripts` run pass | `FEATURE/evidence/regression-testing/isolation-r1.2026-10-31T04-48.md` (seeds 13, 31, 59; 135 passed each); `FEATURE/evidence/regression-testing/pester-full-r1.2026-10-31T04-46.md` (13481 tests, 0 failures, 0 errors) | PASS |
| AC-18 | No `.codex/`, `.github/agents/`, resolver, or manifest change; brief sentence updated byte-identically in six copies | `FEATURE/evidence/qa-gates/scope-check-r1.2026-10-31T04-48.md`; `FEATURE/evidence/qa-gates/brief-parity-r1.2026-10-31T02-45.md` (one digest across six copies); `FEATURE/evidence/qa-gates/python-dev-tools-r1.2026-10-31T02-46.md` | PASS |

## spec.md checkbox state

All 18 criteria under `spec.md` `## Acceptance Criteria` remain checked. Every re-confirmed criterion still holds, so none was unchecked.

## Deferred post-merge verification (not claimed)

An end-to-end coordinator-session `gh pr create` by a pr-author for a worktree item cannot be shown before merge, because isolated subagents run `main`'s hooks. It remains a post-merge verification and is not claimed here.
