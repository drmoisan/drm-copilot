# Acceptance Criteria Verification (Issue #1011)

Timestamp: 2026-10-31T02-07
Source: docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/spec.md `## Acceptance Criteria` (work mode full-bug; AC-01 to AC-18 in document order)
Evidence root: FEATURE = docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011

| AC | Criterion (abbreviated) | Status | Evidence |
|---|---|---|---|
| AC-01 | Merge `origin/main`; #1009 module, export, manifest entry, and #1010 gate present before any edit | PASS | `FEATURE/evidence/baseline/dependency-check.2026-10-31T01-18.md` (DEPENDENCIES: PRESENT); `FEATURE/evidence/other/resolver-contract.2026-10-31T01-18.md` |
| AC-02 | Allow rows for `git worktree list --porcelain`, POSIX and drive-letter absolute `sha256sum`; fail-before recorded; pass after | PASS | `FEATURE/evidence/regression-testing/fail-before.2026-10-31T01-38.md` (AL-50, AL-51, AL-52 failing); `FEATURE/evidence/qa-gates/allowlist-suites.2026-10-31T01-40.md` (passing) |
| AC-03 | Deny rows with the `PR_AUTHOR_COMMAND_NOT_ALLOWED:` prefix for every listed case | PASS | AL-53 to AL-66 in `FEATURE/evidence/qa-gates/allowlist-suites.2026-10-31T01-40.md` |
| AC-04 | Relative form still allowed; pre-existing rows unchanged; Issue824Regression rows pass | PASS | `FEATURE/evidence/qa-gates/allowlist-suites.2026-10-31T01-40.md` (AL-01 to AL-49, AL-07, Issue824 suites) |
| AC-05 | Form text names both forms; AL-34 proves every documented form allowed | PASS | AL-67 and AL-34 in `FEATURE/evidence/qa-gates/allowlist-suites.2026-10-31T01-40.md`; AL-34 re-run against the edited documents in `FEATURE/evidence/qa-gates/text-contracts.2026-10-31T01-44.md` |
| AC-06 | TargetResolution rows prove shared resolver invocation and the four mappings; fail-before recorded | PASS | TR-01 to TR-09 in `FEATURE/evidence/regression-testing/fail-before.2026-10-31T01-38.md` and `FEATURE/evidence/qa-gates/gate-suites.2026-10-31T01-42.md` |
| AC-07 | A path-derived source does not select the worktree (issue #673) | PASS | TR-07 (and TR-06) in `FEATURE/evidence/qa-gates/gate-suites.2026-10-31T01-42.md` |
| AC-08 | Existing gate suites pass with unchanged expectations, including the three ItemArtifactRoot rows | PASS | `FEATURE/evidence/qa-gates/gate-suites.2026-10-31T01-42.md` (531 passed, 0 failed) |
| AC-09 | No change to the named functions; receipt checks unchanged | PASS | `FEATURE/evidence/qa-gates/scope-check.2026-10-31T01-50.md` (sibling files and `.claude/lib/` exit 0; FUNCTIONS_UNCHANGED: 2/2) |
| AC-10 | Coordinator-topology contract suite exists and passes for the agent and skill | PASS | CT-01 to CT-06 in `FEATURE/evidence/qa-gates/text-contracts.2026-10-31T01-44.md` |
| AC-11 | Contract suite proves the orchestrate handoff text | PASS | CT-07 in `FEATURE/evidence/qa-gates/text-contracts.2026-10-31T01-44.md` |
| AC-12 | `pr-author-issue-link-contract.Tests.ps1` passes without modification | PASS | PC-01 to PC-07 in `FEATURE/evidence/qa-gates/text-contracts.2026-10-31T01-44.md`; the file is absent from the scope-check changed list |
| AC-13 | Bundle copies byte-identical; four push-down contract tests pass | PASS | `FEATURE/evidence/qa-gates/mirror-parity.2026-10-31T01-45.md`; `FEATURE/evidence/qa-gates/python-dev-tools.2026-10-31T01-46.md` |
| AC-14 | Dependency-guard and no-Python suites pass with the new import | PASS | `FEATURE/evidence/qa-gates/runtime-contracts.2026-10-31T01-48.md` |
| AC-15 | Line coverage at or above 85% per hook file with no changed-line regression | PASS | `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-31T02-06.md` (100% and 97.73%) |
| AC-16 | Invoke-Formatter no changes; PSScriptAnalyzer zero findings | PASS | `FEATURE/evidence/qa-gates/ps-format.2026-10-31T01-48.md`; `FEATURE/evidence/qa-gates/pssa.2026-10-31T01-48.md` |
| AC-17 | Seeded shuffled runs and the full `tests/scripts` run pass | PASS | `FEATURE/evidence/regression-testing/isolation.2026-10-31T01-50.md` (seeds 11, 23, 47); `FEATURE/evidence/regression-testing/pester-full.2026-10-31T02-06.md` |
| AC-18 | No `.codex/`, `.agents/` (other than the brief), `.github/agents/`, resolver, or manifest change; brief sentence updated byte-identically in six copies | PASS | `FEATURE/evidence/qa-gates/brief-parity.2026-10-31T01-46.md`; `FEATURE/evidence/qa-gates/python-dev-tools.2026-10-31T01-46.md`; `FEATURE/evidence/qa-gates/scope-check.2026-10-31T01-50.md` |

## Pending-CI criteria

None. Every criterion is verified by local runs recorded above. CI on the PR head will additionally run the claude-hooks suites on `ubuntu-latest` in `poshqc / PowerShell hook suites (Linux)` and the coverage shards in `poshqc / PowerShell QC`. That run confirms the local results, but no criterion's check-off depends on it.

## Deferred post-merge verification (not claimed)

An end-to-end coordinator-session `gh pr create` by a pr-author for a worktree item cannot be shown before merge, because isolated subagents run `main`'s hooks. After this item merges, with #1009 and #1010 on `main`, a coordinator-session pr-author run for a worktree item must confirm that `gh pr create` is allowed, and the result must be recorded under `FEATURE/evidence/`. This verification belongs to this item's remediation and is not claimed here.

## Acceptance Criteria Status

- Source: FEATURE/spec.md
- Total AC items: 18
- Checked off (delivered): 18
- Remaining (unchecked): 0
- Items remaining: none
