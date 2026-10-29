# Feature Audit: Parallel run leaves uncommitted records and worktrees (#995)

---

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after a proportionate remediation cycle

---

## Scope and Baseline

- **Base branch:** `main` (merge base `972e4083c59fefd1d40984929503c9956eed7137`; `origin/main` now resolves to `52587a0eeaa04a0519801452235608a72b5eba5c`, three commits ahead, clean merge per `git merge-tree`)
- **Head branch/commit:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995` (commit `7dec2f9a0a0f4ef8f30b225462dac19f4a4a604b`)
- **Merge base:** `972e4083c59fefd1d40984929503c9956eed7137`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 13:14:41 UTC for head `7dec2f9a0a0f4ef8f30b225462dac19f4a4a604b`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/evidence/**`
  - Additional evidence: reviewer full `tests/scripts` Pester run with coverage; reviewer parse of `artifacts/pester/powershell-coverage.xml`; PSScriptAnalyzer over 26 changed PowerShell files; Black, Ruff, Pyright; four Python contract modules; Codex generator `--check`; `check_quality_tiers`; `cmp` mirror parity; evidence-location validator; logical line counts
- **Feature folder used:** `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (authoritative for `full-bug`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source and no `user-story.md` applies.
- **Scope note:** PR context was current for the head SHA and was not regenerated. The full branch diff (105 files) was reviewed, not only the remediation delta.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/spec.md`: only authoritative source (full-bug); 20 checkbox items, numbered AC-1 to AC-20 in list order

### From spec.md

1. AC-1: `WorktreeRunRecordPath.psm1` exists and exports `Test-WorktreeRunPathEqual`, `Test-WorktreeRunRecordedPathMatchesTarget`, and `Get-WorktreeRunMainCheckoutRoot`; `Test-WorktreeRunPathEqual` is no longer defined in `WorktreeRunResolution.psm1`.
2. AC-2: Pester cases show a relative record joined to the main checkout root matches, and a rooted record matches as before.
3. AC-3: Pester cases show blank, `.`, `..`, dot-segment, and `:`-bearing records never match, including the main checkout root.
4. AC-4: Every matcher-family site calls the shared matcher; no inline `worktree_path` normalise-and-compare remains outside the module.
5. AC-5: Both gates allow an absolute target whose relative record has `merged` or `worktree_removed`.
6. AC-6: Both gates still deny `pr_open`, `worktree_created`, absent status, a different agent, and an ambiguous two-root record.
7. AC-7: A `CleanupWorktreeManifestGateMatrix.Tests.ps1` case keeps a manifest entry denied for a relatively recorded target with an unsafe status.
8. AC-8: The `merge_status` predicate and fail-closed ordering are unchanged, evidenced by pre-existing suites passing without edits to their existing assertions.
9. AC-9: The skill carries a `Run Closing` section with every specified substep, referenced from Completion Requirements.
10. AC-10: The agent carries the same procedure, lists `Agent(pr-author)` in `tools:`, and references the closing step from its completion conditions.
11. AC-11: A content test or documented search shows every staging or commit example in Run Closing uses only literal `docs/features/` or `artifacts/orchestration/` paths.
12. AC-12: Every changed Claude file has a byte-identical bundle copy; `core.json` lists the new module; push-down, completeness, and dependency-closure tests pass.
13. AC-13: No production or test file added or changed exceeds 500 lines.
14. AC-14: Merge-gate hooks, the #670 authorization branch, and the Codex hooks are unchanged.
15. AC-15: Non-goals record D8 (standalone merge-on-green) as out of scope, tracked separately.
16. AC-16: Live-Verification Items are each labelled with a deferral behavior; no AC asserts their outcome.
17. AC-17: Line coverage is at least 85% for each changed or added PowerShell file.
18. AC-18: The local toolchain passes in a single pass, with three seeded shuffled runs and one single-process full run.
19. AC-19: Docs and config references (`parallel-orchestration.md` line, stale agent-memory note) match the new behavior.
20. AC-20: (pending-CI) Named Pester suites pass in CI on the PR head with `ci_gate.conclusion` `success` and `ci_gate.head_sha` equal to the final head.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: new module and exports; function moved | PASS | The module exports the three named functions plus `Get-WorktreeRunRecordBaseRoot` (X1 expects four); `Test-WorktreeRunPathEqual` is not defined in `WorktreeRunResolution.psm1` | `git diff 972e4083c..HEAD -- .claude/lib/worktree-resolution/`; reviewer full Pester run (X1 pass) | The fourth export comes from the remediation (prior Minor finding 4). AC-1 names the required exports and does not limit the export set. |
| 2 | AC-2: relative join and rooted pass-through | PASS | M1, M2, M4 in `WorktreeRunRecordPath.Tests.ps1` | reviewer full `tests/scripts` Pester run | — |
| 3 | AC-3: unsafe relative records never match | PASS | M7 (eight forms against six candidate targets including the main root), M8, M10 | same run | — |
| 4 | AC-4: all family sites use the shared matcher | PASS | Six call sites (`evidence/other/matcher-family-search.2026-10-29T10-58.md`); the remediation's case-parity clause calls the same matcher; base-root derivation is now one shared function | `grep -rn "Test-WorktreeRunRecordedPathMatchesTarget\|Get-WorktreeRunRecordBaseRoot" .claude/` | `Find-CleanupWorktreeManifestRemovalRecord` compares manifest records, not checkpoint records, and is outside the named family; its case rule is now mirrored by the exclusion. |
| 5 | AC-5: both gates allow relative `merged`/`worktree_removed` | PASS | RP1, RE1 (both topologies) | reviewer full Pester run | — |
| 6 | AC-6: both gates still deny unsafe statuses, other agent, ambiguity | PASS | RP2, RP3, RE2, RE2b (epic `features[]` branch, added by remediation), RE3 | reviewer full Pester run | The prior gap (no `features[]` deny row) is closed. |
| 7 | AC-7: manifest matrix relative-record deny | PASS | "denies the relative-record case when <Case>" rows for both gates in `CleanupWorktreeManifestGateMatrix.Tests.ps1` | reviewer full Pester run | — |
| 8 | AC-8: predicate and ordering unchanged | PASS | `evidence/qa-gates/assertion-preservation.2026-10-29T11-42.md`; the remediation did not edit any pre-existing assertion in the named suites (its test diff only adds rows and narrows the content test the branch itself introduced); `$script:AllowedMergeStatuses` and decision order unchanged | `git diff bed21939d..HEAD -- tests/ .claude/hooks` | — |
| 9 | AC-9: skill Run Closing section | PASS | `### Run Closing` with substeps 1-5; Completion Requirements reference; RC1-RC5 pass for both copies | reviewer read of the section; reviewer full Pester run | — |
| 10 | AC-10: agent procedure and tool grant | PASS | `tools:` lists `Agent(pr-author)`; `### Run Closing`; completion condition reference; RA1-RA5 pass; Python allowlist test passes | `poetry run pytest --no-cov -q tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | — |
| 11 | AC-11: staging examples use only allowed literal paths | PASS | RC4 now accepts only `docs/features/` spans, a subset of what AC-11 permits; RC5 and RA5 assert the `artifacts/orchestration/` alternative is absent | reviewer full Pester run | The spec's `## Proposed Fix` text still names both prefixes (code review, Info). |
| 12 | AC-12: mirror parity, `core.json`, push-down tests | PASS | `cmp` nine of nine identical; `core.json` lists the module; 70 contract tests pass (four modules); generator `--check` exit 0 | `cmp <file> extensions/drm-copilot/resources/claude-customizations/<file>`; `poetry run pytest --no-cov -q <four modules>` | — |
| 13 | AC-13: no changed file over 500 lines | PASS | Reviewer logical counts over 33 changed covered files: largest 495 (`test_parallel_orchestrator_surface_contracts.py`); `enforce-parallel-worktree-removal-gate.ps1` shrank to 467 | logical line split equivalent to `@(Get-Content -LiteralPath <path>).Count` | — |
| 14 | AC-14: merge gates, #670 branch, Codex hooks unchanged | PASS | `git diff --name-status` lists no `enforce-epic-merge-gate*`, `.codex/`, `.agents/`, or `.github/` path | `git diff --name-status 972e4083c..HEAD` | — |
| 15 | AC-15: D8 recorded as out of scope | PASS | `spec.md` `## Scope & Non-Goals` D8 bullet; promoted record for #997 | read of `spec.md` | — |
| 16 | AC-16: LV items labelled with deferral; no AC asserts them | PASS | `## Live-Verification Items` LV1-LV4 each state a deferral | read of `spec.md` | — |
| 17 | AC-17: per-file PowerShell line coverage at least 85% | PASS | Reviewer parse of the regenerated artifact: `WorktreeRunRecordPath.psm1` 100.00%, `WorktreeRunResolution.psm1` 100.00%, `CleanupWorktreeManifest.psm1` 92.79%, `enforce-parallel-worktree-removal-gate.ps1` 95.54%, `enforce-epic-worktree-removal-gate.ps1` 95.61%, `enforce-epic-worktree-removal-gate-resolution.ps1` 100.00% | reviewer JaCoCo parse of `artifacts/pester/powershell-coverage.xml` | Figures identical in the executor's artifact and the reviewer's full-run artifact. |
| 18 | AC-18: single-pass toolchain, shuffles, full run | PASS | `poshqc-format.2026-10-29T13-11.md`, `pssa.2026-10-29T13-11.md`, `pester-final.2026-10-29T13-11.md` (8724, 0 failed), `isolation.2026-10-29T13-11.md` (3 seeds, 496 each); reviewer PSScriptAnalyzer 0 findings and reviewer full `tests/scripts` run (policy audit Section 6) | reviewer runs | — |
| 19 | AC-19: docs and config references updated | PASS | `.claude/rules/parallel-orchestration.md` `## Enforcement` bullet names the shared matcher; agent-memory note updated in the executing checkout (gitignored) | read of rule diff | — |
| 20 | AC-20: CI passes on the PR head | UNVERIFIED | No pull request exists for the branch yet | — | Pending CI; CI-dependent criterion owned by the item's own orchestrator run at S9. Not a review defect. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 19 criteria (AC-1 to AC-19)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-20, pending CI by design)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. AC-20 is a CI-dependent criterion that cannot be verified before the pull request exists.

**Recommended follow-up verification steps:**

1. Bring the branch up to date with `origin/main` (three unrelated commits, clean merge) before opening the pull request.
2. At S9, confirm `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head, then check off AC-20 from the item's own run.
3. Run LV1-LV4 on the next two-cohort parallel run and record the output under `evidence/regression-testing/`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: AC-20 "(pending-CI) The Pester suites named in Test Strategy pass in CI on the pull request head, with `ci_gate.conclusion` `success` and `ci_gate.head_sha` equal to the final PR head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 20 | 19 | 1 | AC-1 to AC-19 were already checked and each evaluated PASS in this re-audit. AC-20 is pending CI and remains unchecked. |

No source-file checkbox change was made in this review, because every PASS criterion was already checked and the one unchecked criterion is pending CI.
