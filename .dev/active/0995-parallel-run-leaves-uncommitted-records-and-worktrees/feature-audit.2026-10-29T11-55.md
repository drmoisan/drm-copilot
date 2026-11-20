# Feature Audit: Parallel run leaves uncommitted records and worktrees (#995)

---

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `972e4083c59fefd1d40984929503c9956eed7137`)
- **Head branch/commit:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995` (commit `bed21939d7da24cce0c2100ef619fe3aaa23f19d`)
- **Merge base:** `972e4083c59fefd1d40984929503c9956eed7137`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 11:48:53 UTC for head `bed21939d7da24cce0c2100ef619fe3aaa23f19d`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/evidence/**`
  - Additional evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml`; reviewer re-runs of nine Pester suites, PSScriptAnalyzer, Black, Ruff, Pyright, the full Python suite with branch coverage, the push-down contract tests, the Codex generator `--check`, `check_quality_tiers`, `cmp` mirror parity, the evidence-location validator, and logical line counts
- **Feature folder used:** `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (authoritative for `full-bug`)
- **Work mode resolution note:** `issue.md` carries the marker `- Work Mode: full-bug`; `spec.md` is therefore the only AC source and no `user-story.md` applies.
- **Scope note:** PR context was current for the head SHA and was not regenerated. The full branch diff (85 files) was reviewed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/spec.md` — only authoritative source (full-bug); 20 checkbox items, numbered AC-1 to AC-20 in list order by the spec's own evidence section

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
| 1 | AC-1: new module and exports; function moved | PASS | Module exports exactly three functions (`Export-ModuleMember`, X1); `WorktreeRunResolution.psm1` diff removes the `Test-WorktreeRunPathEqual` definition and imports the new module | `git diff 972e4083c..HEAD -- .claude/lib/worktree-resolution/`; reviewer Pester re-run (X1 pass) | — |
| 2 | AC-2: relative join and rooted pass-through | PASS | M1, M2, M4 in `WorktreeRunRecordPath.Tests.ps1` | reviewer `Invoke-Pester` over nine suites: 332 passed, 0 failed | — |
| 3 | AC-3: unsafe relative records never match | PASS | M7 (eight forms against six candidate targets including `/synthetic-worktrees/main`), M8, M10 | same reviewer run | — |
| 4 | AC-4: all family sites use the shared matcher | PASS | Six call sites in `evidence/other/matcher-family-search.2026-10-29T10-58.md`; reviewer diff review confirms each former inline compare replaced | `grep -rn "ConvertTo-CleanupWorktreeManifestNormalizedPath\|Test-WorktreeRunRecordedPathMatchesTarget" .claude/` | `Find-CleanupWorktreeManifestRemovalRecord` still normalises and compares manifest `removals[].worktree_path`; it is outside the spec's named matcher family (manifest records, not checkpoint records). Its case-rule asymmetry is a Minor code-review finding. |
| 5 | AC-5: both gates allow relative `merged`/`worktree_removed` | PASS | RP1 (parallel gate), RE1 (epic gate, both topologies); fail-before in `evidence/regression-testing/expect-fail.2026-10-29T10-48.md` | reviewer Pester re-run | — |
| 6 | AC-6: both gates still deny unsafe statuses, other agent, ambiguity | PASS | RP2, RP3, RE2, RE3 | reviewer Pester re-run | Epic-gate deny rows use the parallel-item branch; a `features[]` deny row is recommended (code review, Minor). |
| 7 | AC-7: manifest matrix relative-record deny | PASS | "denies the relative-record case when <Case>" rows for both gates in `CleanupWorktreeManifestGateMatrix.Tests.ps1` | reviewer Pester re-run | — |
| 8 | AC-8: predicate and ordering unchanged | PASS | `evidence/qa-gates/assertion-preservation.2026-10-29T11-42.md` (two removed lines across 15 suites, none with `Should`); reviewer diff confirms `$script:AllowedMergeStatuses` and decision order unchanged | `git diff 972e4083c..HEAD -- .claude/hooks` | — |
| 9 | AC-9: skill Run Closing section | PASS | `### Run Closing` under `## Worktree Cleanup` with substeps 1-5; Completion Requirements item 5; RC1-RC4 pass for both copies | reviewer read of the section; reviewer Pester re-run | Rendered as a `###` subsection because contract tests pin the `##` headings (spec deviation). |
| 10 | AC-10: agent procedure and tool grant | PASS | `tools:` lists `Agent(pr-author)`; `### Run Closing` under `## Completion Requirements`; completion condition 5; RA1-RA4 pass; Python `test_agent_tools_allowlist_grants_only_the_records_pr_author_channel` pass | `poetry run pytest --no-cov -q tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | — |
| 11 | AC-11: staging examples use only allowed literal paths | PASS | RC4 tokenizes every backticked `git add`/`git commit` span in both skill copies | reviewer Pester re-run | `artifacts/orchestration/` is ignored by git; wording observation recorded as Minor. |
| 12 | AC-12: mirror parity, `core.json`, push-down tests | PASS | `cmp` nine of nine identical; `core.json` diff adds the module; 52 contract tests pass; generator `--check` exit 0 | `cmp <file> extensions/.../<file>`; `poetry run pytest --no-cov -q <three push-down modules>` | — |
| 13 | AC-13: no changed file over 500 lines | PASS | Reviewer logical counts: largest 495 (`enforce-parallel-worktree-removal-gate.ps1`, `test_parallel_orchestrator_surface_contracts.py`); `evidence/qa-gates/line-counts.2026-10-29T11-43.md` | `@(Get-Content -LiteralPath <path>).Count` per changed covered file | — |
| 14 | AC-14: merge gates, #670 branch, Codex hooks unchanged | PASS | `git diff --name-status` lists no `enforce-epic-merge-gate*`, `.codex/`, `.agents/`, or `.github/` path | `git diff --name-status 972e4083c..HEAD` | — |
| 15 | AC-15: D8 recorded as out of scope | PASS | `spec.md` `## Scope & Non-Goals` D8 bullet; promoted record `2026-10-29-standalone-orchestration-merge-on-green.md` (#997) | read of `spec.md` | — |
| 16 | AC-16: LV items labelled with deferral; no AC asserts them | PASS | `## Live-Verification Items` LV1-LV4 each state a deferral; no AC text references an LV outcome | read of `spec.md` | — |
| 17 | AC-17: per-file PowerShell line coverage at least 85% | PASS | Reviewer parse: 100.00%, 100.00%, 92.52%, 93.10%, 95.61%, 98.18% | reviewer JaCoCo parse of `artifacts/pester/powershell-coverage.xml` | Artifact written after the last production edit. |
| 18 | AC-18: single-pass toolchain, shuffles, full run | PASS | `poshqc-format.2026-10-29T11-21.md`, `pssa.2026-10-29T11-21.md`, `pester-coverage.2026-10-29T11-40.md` (11984 pass, 0 fail), `isolation.2026-10-29T11-44.md` (3 seeds, 474 each) | reviewer PSScriptAnalyzer re-run (0 findings) | — |
| 19 | AC-19: docs and config references updated | PASS | `.claude/rules/parallel-orchestration.md` `## Enforcement` bullet names `Test-WorktreeRunRecordedPathMatchesTarget`; agent-memory note updated in the executing checkout | read of rule diff; read of `.claude/agent-memory/parallel-orchestrator/worktree-removal-gate-path-mismatch.md` | The memory note is gitignored and therefore not in the branch diff (spec deviation). |
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

1. At S9, confirm `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head, then check off AC-20 from the item's own run.
2. Run LV1-LV4 on the next two-cohort parallel run and record the output under `evidence/regression-testing/`.
3. Consider the four Minor code-review findings (manifest case rule, `artifacts/orchestration/` wording, epic `features[]` deny row, shared base-root helper) for a remediation cycle before merge.

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
| `spec.md` | 20 | 19 | 1 | AC-1 to AC-19 were already checked by the executor and each evaluated PASS in this audit. AC-20 is pending CI and remains unchecked. |

No source-file checkbox change was made in this review, because every PASS criterion was already checked and the one unchecked criterion is pending CI.
