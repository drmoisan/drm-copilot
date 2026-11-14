# Feature Audit: Preimplementation Gate Blocks Post-Fan-In Integration Writes (Issue #1136)

- **Branch:** `bug/preimpl-gate-post-fanin-writes` @ `caa0879c1fa046b154e6c75af6bd2b46ff7160ff`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`, confirmed by `artifacts/pr_context.summary.txt` (`origin/main` @ `a90d522c6ac239bca858d7bc800d52860e823219`, generated for head `caa0879c1`).
- Merge base: `a90d522c6ac239bca858d7bc800d52860e823219`, equal to `origin/main` after fetch. HEAD merges current `origin/main`.
- Range audited: `a90d522c6..caa0879c1`, 43 files.
- Work mode: `full-bug` (`- Work Mode: full-bug` in `issue.md`), so the AC source is `spec.md` `## Acceptance Criteria`.
- Baseline behavior (fail before): `evidence/regression-testing/fail-before.2026-11-08T17-19.md` records that, before any production change, a Write of `artifacts/pr_body_7.receipt.json` and a pathless `git commit -m` in epic scope with fan-in complete were denied naming `'merge-in-progress'`.
- Accepted scope (coordinator, consistent with the spec): the fix covers the operations denied before the change (receipt Write, pathless `git commit -m`, `git commit -F`, add chained to a pathless commit). Body Write, status-doc Write, `git add` of the status doc, and commit with `-- <status doc>` were already allowed. Findings 3 and 9 are non-goals; only the reuse seam is owed.

## Acceptance Criteria Inventory

| ID | Criterion (abridged) |
|---|---|
| AC1 | Fail-before receipt Write row recorded denying with `'merge-in-progress'` before the fix, with evidence, and allowing after. |
| AC2 | `hook-epic-fan-in.ps1` at four paths, defines the five named functions, byte-identity parity test. |
| AC3 | `Get-OrchestrationEpicScopeDecision` (both surfaces and bundles) allows only for exact `'merge-in-progress'` plus `Test-EpicFanInComplete` plus `Get-EpicFanInAllowance`; guarded dot-source with `Add-HookDependencyFailure`. |
| AC4 | Positive rows on both surfaces: receipt relative and absolute, body, add of status doc, `-C` commit `-m`, `-F` without pathspec with exact index, `-F -- <status doc>`. |
| AC5 | Negative rows with unchanged deny text: non-terminal status, empty features, out-of-allowlist paths. |
| AC6 | Generic single-feature deny unchanged when HEAD is not `integration_branch`, and when the epic checkpoint is missing or unparseable. |
| AC7 | Deny rows for staged-index variants, reader throw, `--amend`, `-a`, blank or non-plain slug, disagreeing `epic_status_doc_path`. |
| AC8 | Unit suite pins the terminal status set and shows agreement with `Get-EpicPrCreationReadinessFailure`. |
| AC9 | Existing suites pass unchanged; main gate files and the cleanup file do not grow. |
| AC10 | New hook file meets the line threshold; PSScriptAnalyzer zero findings; leak scan clean without allowlist changes. |
| AC11 | Epic-orchestrate skill (Claude, Codex variant, bundles) documents the allowance; every brief copy carries a #1136 bullet. |
| AC12 | Pin re-baselined with `RE-BASELINED by issue #1136`; both `core.json` list the new file; Python contract tests pass. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC1 | PASS | `fail-before.2026-11-08T17-19.md`: two rows failed with the `'merge-in-progress'` deny before production code changed (shard JUnit 19861 tests, 2 failed). `pester-final.2026-11-08T17-42.md`: the EpicFanIn suite (29 tests) has 0 failures. |
| AC2 | PASS | Four copies share SHA-256 `b15ea69a...4784fd9` (reviewer). The file defines the five functions (reviewer read). Row `keeps the four copies of hook-epic-fan-in.ps1 byte-identical` in `hook-epic-fan-in.Tests.ps1`. |
| AC3 | PASS | Diff of both epic-scope gates: the condition is `$failure -ceq 'merge-in-progress' -and (Test-EpicFanInComplete ...) -and (Get-EpicFanInAllowance ...).Allowed`; the dot-source is `try { . (...) } catch { Add-HookDependencyFailure -Name 'hook-epic-fan-in.ps1' ... }`. Bundle copies hash-equal. The `epic_manifest_path` row on both surfaces shows no other failure is allowed. |
| AC4 | PASS | Claude `allows` context (7 rows) and Codex `allows` context (9 rows, including `apply_patch`) pass in the final gate. The `-C` row uses `git -C /synthetic-worktrees/epic-coordinator commit -m status`. |
| AC5 | PASS | Claude rows: `pr_open` feature (`merge-in-progress`), empty features (`features`), `artifacts/pr_body_7.json`, `scripts/powershell/Sample.ps1`, each asserting the exact deny text. Another slug's `epic-status.md` is exercised by the staged-index row (`other-epic`) and by unit allowlist rows; a Write of a `.md` path is not classified by the gate, so the staged-index route is the discriminating form. Codex deny rows for non-terminal status and a production path. |
| AC6 | PASS | Claude `outside epic scope` context (HEAD mismatch, absent, unparseable) asserts `-BeExactly` the single-feature reason; Codex HEAD-mismatch row. |
| AC7 | PASS | Claude deny rows: extra path, empty, exit 128, no NUL terminator, throwing reader, `--amend`, `-a`, blank slug, `../sample-epic`, disagreeing `epic_status_doc_path`; unit rows repeat them at function level. |
| AC8 | PASS | Rows `restates the terminal merge statuses of EpicScopeReadiness` and `agrees with Get-EpicPrCreationReadinessFailure over the fixture matrix`. |
| AC9 | PASS | `pester-final.2026-11-08T17-42.md` lists the named suites with 0 failures (EpicScope 22, CommandExemption 120, Cleanup 41, EpicScopeTargets 22, Parity 93, EpicScopeHelperParity 5, hook-dependency-guard-completeness 731, Codex epic-scope suites). The two main gate files and the cleanup file are not in the branch diff; `powershell-static.2026-11-08T17-31.md` records 473, 493, and 481 lines, equal to Phase 0. |
| AC10 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: each `hook-epic-fan-in.ps1` copy 91 of 91 lines. PSScriptAnalyzer 0 findings on 12 files; leak scan 0 failures with `config/poshqc-leak-allowlist.json` unchanged (static artifact). |
| AC11 | PASS | Paragraph `Post-fan-in allowance (issue #1136)` in `.claude/skills/epic-orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md`, each equal to its bundle copy; bullet `Post-fan-in allowance (#1136)` under `## Hook Execution Context` in all six brief copies (one SHA-256). |
| AC12 | PASS | Pin comment `RE-BASELINED by issue #1136`; pinned digest `73d5c859...0033ed7e` equals the skill SHA-256 at HEAD after the main merge. Both `core.json` list the new file. Reviewer post-merge run of the surface-contract, both resource-contract, both pack-manifest completeness, and dependency-closure modules: 83 passed. |

## Summary

All twelve criteria pass at `caa0879c1`. No blocking finding. CR1 to CR5 in the code review are non-blocking. CI on the PR head is pending-CI: no PR exists yet, and the S9 gate owns that result.

Verdict: PASS, no blocking finding.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-08-preimpl-gate-blocks-post-fanin-integration-writes-1136/spec.md`
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

- All twelve criteria are already `- [x]` in `spec.md` at `caa0879c1`, checked by the executor. Each evaluates as PASS above, so the checked state is correct and no change to `spec.md` was made in this review.
- No criterion was added and no criterion text was changed.
- The `## Test Strategy` checkboxes in `spec.md` and the `issue.md` checkboxes are seeded template items, not acceptance criteria, and were left as they are.
