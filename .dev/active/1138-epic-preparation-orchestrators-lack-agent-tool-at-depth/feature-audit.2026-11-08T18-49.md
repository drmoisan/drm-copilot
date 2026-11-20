# Feature Audit: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
**Base Branch:** `main`
**Head Branch:** `bug/epic-subagent-nesting-depth`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after light remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `bug/epic-subagent-nesting-depth` (commit `88cbdb8eaf22197b1e74ba262affcbeb019e9b12`)
- **Merge base:** `a90d522c6ac239bca858d7bc800d52860e823219` (`origin/main` is now `72e8b299c8ce99adce7db335e936974e8119493b`, 31 commits ahead)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-08 18:44:29 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/` (cycle-1 stamp `2026-11-08T18-42`), `evidence/regression-testing/`, `evidence/other/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info` parsed directly; coverage JSON comparison across the three pytest runs; a real-process probe of the head helper; `cmp` parity; `git merge-tree` against `origin/main`
- **Feature folder used:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source.
- **Scope note:** Full branch diff (65 paths) against the merge base of `origin/main` and HEAD.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/spec.md` - only source (checkbox-backed, AC1 to AC19)

### Acceptance criteria

1. AC1: Agent-tool preflight as the first startup step in the five agent files, naming `spawn_agent_unavailable` and `AGENT_TOOL_UNAVAILABLE:`.
2. AC2: Coordinator agents halt on a child `AGENT_TOOL_UNAVAILABLE:` line with the same reason.
3. AC3: Preflight names both remedies.
4. AC4: Helper exists, defines the seam, is dot-sourced inside a guard; a failed import denies.
5. AC5: Unset and integers of 3 or more allow.
6. AC6: Integers below 3 deny with `NESTING_DEPTH_INSUFFICIENT:` and both remedies.
7. AC7: A set non-integer value denies with a parse message.
8. AC8: Check applies to main thread to coordinator and coordinator to `orchestrator` only.
9. AC9: Tests set no environment variable and create no temp file (leak scan in the CI static job).
10. AC10: Helper at least 90% line coverage; no existing file drops.
11. AC11: Origin and PreToolUse schema suites pass unchanged in assertions.
12. AC12: Six coordinator skills carry `## Nesting Depth` with the fallback and `Preparation mode: true`.
13. AC13: `orchestrate` skill carries `## Nesting Depth` with the depth-1 and own-depth statements.
14. AC14: Brief line byte-identical across six copies.
15. AC15: Bundle mirrors match live files.
16. AC16: `core.json` lists the helper.
17. AC17: Pin re-baselined with a #1138 comment block; test passes.
18. AC18: No new Python file; no `.codex/` change.
19. AC19: Full toolchain pass.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1 | Agent-tool preflight first | PASS | Lead paragraph of `## Startup Protocol` in all five agents and bundle copies; contract `It` passed in `pester-final.2026-11-08T18-42.md` | `git diff` of `.claude/agents` | |
| AC2 | Coordinators halt on child line | PASS | Child-halt sentence retained; cycle 1 added the `NESTING_DEPTH_INSUFFICIENT:` deny-halt sentence (F1 closed) with its own contract `It` | `git show 88cbdb8ea`; `cmp` | |
| AC3 | Both remedies | PASS | Unchanged; contract `It` passed | `git diff` of `.claude/agents` | |
| AC4 | Helper and guarded import | PASS | Unchanged in cycle 1; import-failure test passed | Read both hooks | |
| AC5 | Unset and at least 3 allow | PASS | Cycle 1 added `99999999999`; probe: `3`, `99999999999`, `9223372036854775807` allow | real-process probe | Closes the first review's Low item |
| AC6 | Below 3 denies with remedies | PASS | Tests for 2, 1, 0, -1, -99999999999 passed; probe `2` and `-99999999999` deny with the below-3 reason | real-process probe | |
| AC7 | Non-integer denies | PASS | Tests for `two`, `2.5` passed; probe `1e3`, `0x10`, and an above-Int64 value deny with the parse message | real-process probe | |
| AC8 | Caller and target matrix | PASS | Unchanged; probe `epic-orchestrator` to `orchestrator` at `2` denies | real-process probe | |
| AC9 | No env mutation, no temp files | PASS | Cycle-1 `Invoke-PoshQCLeakScan -Root`: 0 failures | read `poshqc-static-final.2026-11-08T18-42.md` | Pending-CI: confirmation by the `poshqc / PowerShell QC static` job on the PR head at S9 |
| AC10 | Helper coverage at least 90% | PASS | Coverage XML: helper 19/19 (100%), edited lines 113 and 114 covered; origin hook 69/76; repo 95.64% vs 95.62% | parse `artifacts/pester/powershell-coverage.xml` | AC10 measures PowerShell line coverage; the Python one-branch difference lies in an untouched file and is not attributable (policy audit 1.2.1) |
| AC11 | Existing suites unchanged in assertions | PASS | Cycle 1 did not edit the origin suite; Pester 0 failures | `git show 88cbdb8ea --stat` | |
| AC12 | Coordinator skills Nesting Depth | PASS | Unchanged in cycle 1; contract `It` passed | `git diff` of `.claude/skills` | |
| AC13 | `orchestrate` Nesting Depth | PASS | Unchanged in cycle 1 | `git diff` | |
| AC14 | Brief byte-identical | PASS | Unchanged in cycle 1; six copies share one blob at head and in the merged tree with `origin/main` | `git rev-parse` per copy | |
| AC15 | Bundle mirrors | PASS | `cmp` identical for the five agent files and the helper after cycle 1; contract parity `It` (14 files) passed | `cmp` | |
| AC16 | `core.json` entry | PASS | Unchanged; manifest tests passed | `git diff` | |
| AC17 | Pin re-baseline | PASS | At head, both pins equal the SHA-256 of the head files and the test passed in the cycle-1 gate; comment block extended | `sha256sum` | F2: after merging `origin/main`, the skill digest must be re-derived; the criterion holds at the reviewed head |
| AC18 | No new Python, no `.codex/` | PASS | Diff: 0 added `.py`, 0 `.codex/` paths; Codex generator `--check` exit 0 in the cycle-1 artifact | `git diff --name-status` | |
| AC19 | Full toolchain | PASS | Cycle-1 static artifacts 0 findings; Pester 20120 tests 0 failed; pytest 16560 passed 0 failed | read QA-gate evidence | |

---

## Summary

**Overall Feature Readiness:** PASS on acceptance criteria at the reviewed head; review verdict REMEDIATION_REQUIRED because of code-review finding F2 (merge conflict with `origin/main`).

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Code review F2: the branch conflicts with `origin/main` in the pin module, so a PR would receive no CI checks; the merged skill digest must be recomputed.

**Recommended follow-up verification steps:**

1. After the merge, confirm `test_frozen_epic_surface_matches_pinned_baseline_digest` passes with the merged skill digest and the branch's agent digest, and that the brief and bundle parity tests pass at the merged head.
2. At S9, confirm AC9 through the `poshqc / PowerShell QC static` job on the PR head.

---

## Acceptance Criteria Check-off

All 19 criteria were already checked in `spec.md` and were independently re-evaluated as PASS at the reviewed head. No source-file change was made by this review. AC9 remains checked on local evidence produced by the same leak-scan function the CI job runs; CI confirmation is recorded as pending-CI.

### AC Status Summary

- Source: `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/spec.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 19 | 19 | 0 | Checkbox-backed |
