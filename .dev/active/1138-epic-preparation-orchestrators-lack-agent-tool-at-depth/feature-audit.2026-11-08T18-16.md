# Feature Audit: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
**Base Branch:** `main`
**Head Branch:** `bug/epic-subagent-nesting-depth`
**Work Mode:** `full-bug`
**Audit Type:** First review

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `bug/epic-subagent-nesting-depth` (commit `08e400844373251892289ce0c7562b1daff6af0e`)
- **Merge base:** `a90d522c6ac239bca858d7bc800d52860e823219` (equal to `origin/main` after fetch)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/` under the feature folder
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info` parsed directly; a real-process probe of the head hook (16 caller/target/limit cases); `cmp` and SHA-256 parity checks; Codex generator `--check`
- **Feature folder used:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source.
- **Scope note:** Full branch diff (57 paths) against the merge base of `origin/main` and HEAD.

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
| AC1 | Agent-tool preflight first | PASS | Lead paragraph of `## Startup Protocol` in all five agents and bundle copies; contract `It` passed in `pester-final.2026-11-08T18-06.md` | `git diff` of `.claude/agents` | |
| AC2 | Coordinators halt on child line | PASS | "When a child returns a line beginning `AGENT_TOOL_UNAVAILABLE:`, halt with the same reason" in the four coordinators | `git diff` of `.claude/agents` | Code review F1: the hook-deny signal is not covered by the same rule (outside the AC text) |
| AC3 | Both remedies | PASS | Preflight names raise-or-unset and the main-session fallback | `git diff` of `.claude/agents` | |
| AC4 | Helper and guarded import | PASS | `Get-SubagentSpawnDepthSetting` defined; guarded dot-source at line 52 of the origin hook; "guarded import failure denies" and B1 row passed | Read both hooks | |
| AC5 | Unset and at least 3 allow | PASS | Tests passed; reviewer probe: unset, whitespace, and `3` allow | real-process probe | |
| AC6 | Below 3 denies with remedies | PASS | Tests passed for 2, 1, 0, -1; probe at `2` denies with the reason | real-process probe | |
| AC7 | Non-integer denies | PASS | Tests passed for `two`, `2.5`; probe `abc` denies | real-process probe | Low finding: values above Int32 range also get the parse message |
| AC8 | Caller and target matrix | PASS | Helper matrix 8 applying, 4 non-applying; probe confirmed orchestrator-to-specialist and main-to-orchestrator allow at limit 2 | real-process probe | |
| AC9 | No env mutation, no temp files | PASS | Local `Invoke-PoshQCLeakScan -Root`: 0 failures (`poshqc-static-final.2026-11-08T17-53.md`); test source sets no variable and writes no file | Read test source | Pending-CI: confirmation by the `poshqc / PowerShell QC static` job on the PR head at S9; no PR exists yet |
| AC10 | Helper coverage at least 90% | PASS | Coverage XML: helper 19/19 (100%); origin hook 69/76 (90.79%) vs 90.41%; repo 95.64% vs 95.62% | parse `artifacts/pester/powershell-coverage.xml` | |
| AC11 | Existing suites unchanged in assertions | PASS | Origin suite diff adds only a `Mock` in `BeforeAll`; Pester final 0 failures | `git diff` of the origin suite | |
| AC12 | Coordinator skills Nesting Depth | PASS | Six sections present with `Preparation mode: true`; contract `It` passed | `git diff` of `.claude/skills` | |
| AC13 | `orchestrate` Nesting Depth | PASS | Section states "needs depth 1 only" and "at its own depth" | `git diff` of `.claude/skills/orchestrate` | |
| AC14 | Brief byte-identical | PASS | Six copies share one SHA-256 | `sha256sum` over the six copies | |
| AC15 | Bundle mirrors | PASS | `cmp` identical for 15 files; push-down resource parity test passed | `cmp` | |
| AC16 | `core.json` entry | PASS | Entry after the origin hook; manifest completeness and dependency-closure tests passed | `git diff` of `core.json` | |
| AC17 | Pin re-baseline | PASS | Digests equal the head files' SHA-256; #1138 comment block present; test passed | `sha256sum` | |
| AC18 | No new Python, no `.codex/` | PASS | Diff: 0 added `.py`, 0 `.codex/` paths; Codex generator `--check` exit 0 | `git diff --name-status` | |
| AC19 | Full toolchain | PASS | Static artifacts 0 findings; Pester 20119 tests 0 failed; pytest 16560 passed 0 failed | read QA-gate evidence | |

---

## Summary

**Overall Feature Readiness:** PASS on acceptance criteria; review verdict REMEDIATION_REQUIRED because of code-review finding F1.

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Code review F1: the coordinator agents do not state how to respond to a `NESTING_DEPTH_INSUFFICIENT:` deny of their own `Agent(orchestrator)` call (light remediation).

**Recommended follow-up verification steps:**

1. After F1 is fixed, confirm the coordinator contract `It` asserts the new literal and the pin test passes with the new `epic-orchestrator.md` digest.
2. At S9, confirm AC9 through the `poshqc / PowerShell QC static` job on the PR head.

---

## Acceptance Criteria Check-off

All 19 criteria were already checked in `spec.md` by the executor and were independently re-evaluated as PASS. No source-file change was made by this review. AC9 remains checked on local evidence produced by the same leak-scan function the CI job runs; CI confirmation is recorded as pending-CI.

### AC Status Summary

- Source: `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/spec.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 19 | 19 | 0 | Checkbox-backed |
