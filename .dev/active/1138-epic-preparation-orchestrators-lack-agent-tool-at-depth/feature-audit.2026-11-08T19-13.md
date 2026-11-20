# Feature Audit: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
**Base Branch:** `main`
**Head Branch:** `bug/epic-subagent-nesting-depth`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after full remediation cycle 2 (F2, merge with `origin/main`)

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `bug/epic-subagent-nesting-depth` (commit `039dc51af81cc31f05f27e189843bd9f4506fcdb`)
- **Merge base:** `72e8b299c8ce99adce7db335e936974e8119493b` (equal to `origin/main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-08 19:12:48 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/` (post-merge stamp `2026-11-08T19-12`), `evidence/regression-testing/`, `evidence/other/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info` parsed directly (both written after the merge commit); `git merge-tree` against `origin/main`; `sha256sum` of the pinned files; per-file branch-hunk comparison across the old and new bases; `cmp` parity; reviewer `pytest -n auto` of the surface-contract module (38 passed)
- **Feature folder used:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source.
- **Scope note:** Full branch diff (70 paths) against the merge base of `origin/main` and HEAD. Criteria whose files are unchanged since `88cbdb8ea` apart from the merge are carried forward from the `2026-11-08T18-49` audit after confirming the branch hunks are unchanged.

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
| AC1 | Agent-tool preflight first | PASS | Agent files not changed by the merge; post-merge Pester 0 failures | `git diff 72e8b299c HEAD -- .claude/agents` | Carried forward |
| AC2 | Coordinators halt on child line | PASS | `epic-orchestrator.md` line 55 carries both halt sentences at head | `grep` of the head file | |
| AC3 | Both remedies | PASS | Unchanged; contract `It` passed post-merge | Pester post-merge gate | Carried forward |
| AC4 | Helper and guarded import | PASS | Unchanged | Pester post-merge gate | Carried forward |
| AC5 | Unset and at least 3 allow | PASS | Unchanged | Pester post-merge gate | Carried forward |
| AC6 | Below 3 denies with remedies | PASS | Unchanged | Pester post-merge gate | Carried forward |
| AC7 | Non-integer denies | PASS | Unchanged | Pester post-merge gate | Carried forward |
| AC8 | Caller and target matrix | PASS | Unchanged | Pester post-merge gate | Carried forward |
| AC9 | No env mutation, no temp files | PASS | No test file changed in the delta; prior leak scan 0 failures | read `poshqc-static-final.2026-11-08T18-42.md` | Pending-CI: confirmation by the `poshqc / PowerShell QC static` job on the PR head at S9 |
| AC10 | Helper coverage at least 90% | PASS | Post-merge coverage XML: helper 19/19, origin hook 69/76, repo 95.66% vs 95.62% baseline | parse `artifacts/pester/powershell-coverage.xml` | |
| AC11 | Existing suites unchanged in assertions | PASS | Delta does not touch the origin or schema suites; Pester 0 failures | `git diff 88cbdb8ea HEAD --stat` | |
| AC12 | Coordinator skills Nesting Depth | PASS | `## Nesting Depth` present at line 378 of the merged `epic-orchestrate/SKILL.md`; branch hunks identical across old and new bases | per-file hunk comparison | |
| AC13 | `orchestrate` Nesting Depth | PASS | Not changed by the merge | `git diff` | Carried forward |
| AC14 | Brief byte-identical | PASS | Six copies share blob `5b833e7788ce802ca00e82e4ac669478576fc14a` at head | `git rev-parse HEAD:<path>` | |
| AC15 | Bundle mirrors | PASS | `cmp` identical for `epic-orchestrate/SKILL.md`, the execution-environment brief, and `epic-orchestrator.md` at head | `cmp` | |
| AC16 | `core.json` entry | PASS | Branch hunk identical across old and new bases | per-file hunk comparison | |
| AC17 | Pin re-baseline | PASS | Both pins equal the SHA-256 of the head files; #1138 comment block present after the kept #1136 block; `test_frozen_epic_surface_matches_pinned_baseline_digest` passed (reviewer run, 38 passed) | `sha256sum`; `pytest -n auto` | F2 closed |
| AC18 | No new Python, no `.codex/` | PASS | Branch diff: 0 added `.py`, 0 `.codex/` paths | `git diff --name-status 72e8b299c HEAD` | |
| AC19 | Full toolchain | PASS | Post-merge pytest 16560 passed 0 failed; Pester 0 failures; ruff and black clean on the resolved file; prior static artifacts stand for unchanged files | read QA-gate evidence | |

---

## Summary

**Overall Feature Readiness:** PASS. F2 is closed and all acceptance criteria hold at the merged head.

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. At S9, confirm AC9 through the `poshqc / PowerShell QC static` job on the PR head.

---

## Acceptance Criteria Check-off

All 19 criteria were already checked in `spec.md` and were re-evaluated as PASS at the reviewed head. No source-file change was made by this review. AC9 remains checked on local evidence; CI confirmation is recorded as pending-CI.

### AC Status Summary

- Source: `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/spec.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 19 | 19 | 0 | Checkbox-backed |
