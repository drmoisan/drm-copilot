# Code Review: Parallel Run Closing records PR blocked by the routing receipt (#1182)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182`
**Feature Folder Selection Rule:** named by the caller; matches branch `bug/parallel-close-records-pr-routing-receipt` and issue #1182
**Base Branch:** `main` (resolved `origin/main`; merge base `add7d747886ce893356b63de2941435f2895b345`)
**Head Branch:** `bug/parallel-close-records-pr-routing-receipt` at `06cc8b03d215460418d7d5e881e007c1b18c8d0d`
**Review Type:** Initial review in concurrent mode (PR #1183 open, PR CI running)

---

## Executive Summary

The review covers the full branch diff from the merge base `add7d7478` to the head `06cc8b03d` (70 files, 3598 insertions, 33 deletions). Production logic is confined to three new Claude hook files and two call sites:

- `hook-parallel-records-context.ps1` (pure): `Get-ParallelRecordsSlug` (case-sensitive `^parallel/(?<slug>[A-Za-z0-9][A-Za-z0-9._-]*)-plan$`) and `Get-ParallelRecordsCheckpointDecision` (parse, identity, closed, receipt present, receipt valid, in that order). It reads no file, starts no process, and reads no clock; its outer `catch` maps any error to `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE`.
- `enforce-model-routing-receipt-parallel.ps1`: P1 requires exactly one `branch:` line whose value is a plan branch and equals `Find-WorktreeResolutionBranchSignal`; P2 a non-blank root; P3 the shared decision on the parallel checkpoint text. Every P1 or P2 failure declines with an empty suffix before any seam call.
- `enforce-orchestration-preimplementation-gate-parallel-records.ps1`: Q1 `Write` shape and exact case-sensitive `artifacts/pr_body_[0-9]+\.receipt\.json` (relative, or relative to the enclosing registered root); Q3 no item checkpoint; Q4 HEAD is a plan branch; Q5 the shared decision.
- The model-routing call site sits inside the existing `pr-author` and `$null -eq $checkpoint` region after the cleanup leg and before the docs-estate leg; the preimplementation call site sits after the docs-estate leg. Each appends its suffix before (model-routing) or after (preimplementation) the docs suffix as the spec states.

Focus-area results:

1. Narrow legs: every AC-1 and AC-9 condition is enforced in code (checked line by line against the spec). Non-matching cases keep today's text: the model-routing leg returns an empty suffix for any prompt that fails P1 or P2, and the preimplementation leg returns an empty suffix for any call that fails Q1 to Q4, so `+ $parallelSuffix` and `+ $parallel.DenySuffix` append an empty string. Both public legs never throw. No new file contains `orchestrator-state.json` (grep); all imports and dot-sources use the guarded pattern; no Python invocation.
2. Executor deviation in [P2-T4]: adjudicated below as meeting AC-12 (CR-1, Minor, non-blocking).
3. Test isolation: seams are mocked; the real session-root parallel checkpoint is unreachable through the hook-scope `Get-WorktreeRunCheckpointText` mock plus the baseline mocks and the interception probe row; no temporary file; synthetic forward-slash roots. The five pre-existing suites gained only mock lines (diff verified); no assertion changed.
4. Mirror parity: nine `.claude/` pairs equal by `cmp`; six brief copies equal; `core.json` lists the three new hooks.
5. Coverage: 100% on each new file; edited hooks up against the `Phase 0 baseline`; no covered file at or above 700 lines; no `.codex/` path.
6. AC check-off: 24 of 25 checked, each verified; AC-25 correctly unchecked (PR CI running).

**What changed:**
Three new hook files (426 logical lines in total) and their bundle copies; 19 added lines in `enforce-model-routing-receipt.ps1` (406 to 425) and 4 in `enforce-orchestration-preimplementation-gate.ps1` (487 to 491); four new Pester suites; mock lines in five existing suites; one Python validator test; documentation in the parallel-orchestrate skill, the parallel-orchestrator agent, the parallel rule, and six brief copies.

**Top 3 risks:**
1. The receipt check is consistency-only; the delegation could use another model (documented limitation, same as every path of this gate) (Info).
2. Same-session forgery of the parallel checkpoint (disclosed in each header as a policy-level control) (Info).
3. The fix reaches the session root only after merge plus a main sync of the coordinator branch (spec `## Post-Merge Verification`) (Info).

**PR readiness recommendation:** **Ready** pending PR CI completion; no blocking finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1` | `AC-12 never throws`, row "declines with an empty suffix when the worktree listing throws, and the gate keeps its own target-resolution deny" | Executor deviation in [P2-T4], disclosed in the task check but made without a plan revision: the gate-level assertion is `deny` plus no `*Parallel records leg*` text, not an exact reason. Adjudication: AC-12 is met. The leg-level assertions (`Allowed` false, empty suffix) are exact, and for this payload `Resolve-OrchestrationGateTarget` sets `OrchestrationGateWorktreeListFailed` and returns `NoTarget` before the deny tail (epic-scope file, lines 271-281), so the gate never reaches the leg and its text is today's by construction. The assertion is weaker than its two sibling rows, which use `Should -BeExactly`. | Optionally tighten the row to assert the resolver's NoTarget reason code prefix, so a future change that lets this payload reach the deny tail is detected. Not required for merge. | AC-12 asks that the gate return today's deny text; the code path guarantees it, and the row would still fail if a parallel suffix appeared. | Diff inspection; `evidence/other/task-check.P2-T4.2026-11-14T13-00.md`; `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 271-281 |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1` | `Get-OrchestrationParallelRecordsRoot`, lines 67-72 | For any absolute implementation-path `Write` that reaches the deny tail (for example `<root>/scripts/x.ps1`), the leg calls `Get-OrchestrationCleanupListingRecord` (one `git worktree list` process) before it checks that the path ends in the receipt file name. The spec's performance bullet allows one checkpoint read and one HEAD-branch read on a would-deny path. Outcome and deny text are unchanged (AC-11 (b) absolute row). | Optionally add a prefilter such as a case-sensitive `/artifacts/pr_body_[0-9]+\.receipt\.json$` suffix match before the listing call. Not required for merge. | Deny-path latency only; no allow path that exists today gains a process. | Diff inspection; spec `#### Performance constraints` |
| Info | `.claude/hooks/hook-parallel-records-context.ps1` | `Get-ParallelRecordsReceiptFailure` | A `model_routing_receipts` value that is a single object with `agent` `pr-author` yields `PARALLEL_RECORDS_RECEIPT_INVALID` with the validator's first error; a non-object value yields `PARALLEL_RECORDS_RECEIPT_MISSING`. Both match the spec's ordered conditions 4 and 5 and the AC-5 "not a list" row. | No change required. | Behavior recorded for completeness. | Diff inspection; AC-5 row |
| Info | `tests/scripts/claude-hooks/parallel-records-workflow.EndToEnd.Tests.ps1` | `BeforeAll` | The suite re-imports the receipt module after dot-sourcing four gates, because a `-Force` import chain of `enforce-pr-author-skill.ps1` replaces it in the shared test scope; production hooks run one script per process. | No change required. | Test-scope artifact disclosed by the executor. | `evidence/other/task-check.P3-T1.2026-11-14T13-38.md` |

No Blocker or Major finding. No covered file is at or above 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- One appended test in `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py` validates a closed fixture carrying both new keys, plain and with `require_complete=True`; no Python production file changed.

#### Typing and API notes

- The test is annotated; Pyright reports 0 errors.

#### Error handling and logging

- Not applicable to the test-only change.

### TypeScript implementation audit

#### What changed well

- No TypeScript file is in the branch diff.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- One implementation of the identity, closed, and receipt predicates, called by both legs and pinned by the AC-13 AST rows.
- Receipt validity delegates to `Get-OrchestratorStateModelRoutingReceiptError` on a one-element list per entry, so no model formula is re-implemented and an invalid entry does not hide a later valid one.
- Case-sensitive property lookup (`-cnotcontains` on property names) and case-sensitive comparisons (`-ceq`, `-cmatch`) throughout, matching the Linux CI file system and the spec.
- `ConvertFrom-Json -NoEnumerate` keeps one-element arrays as arrays and rejects a top-level JSON array as unreadable (AC-6).
- The model-routing leg checks the prompt before any seam call, so every existing pr-author delegation that is not a plan-branch delegation pays no extra I/O.

#### API and safety notes

- Both legs are allow-only additions evaluated where the gate would otherwise deny; no existing allow path changes.
- The preimplementation leg derives R from the session root for a relative path and from the enclosing registered root for an absolute path, and rejects non-local path forms through `$script:OrchestrationTargetNonLocalPattern`.

#### Error handling and logging

- Each public leg has one `try`/`catch` that writes a debug line and returns a decline; this is the spec's never-throw contract and matches the cleanup and docs-estate legs. A dependency load failure fails closed through `Add-HookDependencyFailure`.

---

## Test Quality Audit

Discrimination was judged by inspecting each row against the code (the caller's standing rule excludes local suite runs). The fail-before evidence shows the AC-1 and both AC-9 allow rows failing against the unfixed hooks with the generic deny texts, so the allow rows discriminate. Each sub-code row sets exactly one failing condition on an otherwise valid fixture and asserts the specific sub-code after the unchanged base text, so a reordered or dropped condition fails at least one row. The AC-7 and AC-11 rows assert the exact deny text with `Should -BeExactly` and assert zero calls of the parallel checkpoint seam, so a leg that read the checkpoint or appended a suffix on those inputs would fail. The withdrawn-item row reproduces the harness-learnings-2026-11-09 shape. The `--head` row covers a prompt where `Find-WorktreeResolutionBranchSignal` disagrees with the `branch:` line.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-model-routing-receipt.ParallelRecords.Tests.ps1` — 355 logical lines.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1` — 280 logical lines.
- `tests/scripts/claude-hooks/hook-parallel-records-context.Tests.ps1` — 267 logical lines.
- `tests/scripts/claude-hooks/parallel-records-workflow.EndToEnd.Tests.ps1` — 193 logical lines.
- Diffs of the five pre-existing suites and `enforcement-hooks-checkpoint-path-explicit.Tests.ps1`.
- `evidence/regression-testing/fail-before.2026-11-14T12-42.md`, `evidence/qa-gates/phase-gate.P1.2026-11-14T12-41.md`, `phase-gate.P2.2026-11-14T13-24.md`, `phase-gate.P3.2026-11-14T14-07.md`, `final-qc-pester.2026-11-14T14-36.md`, `coverage-comparison.2026-11-14T14-36.md`, `final-qc-pytest.2026-11-14T14-38.md`, `non-goal-diff-check.2026-11-14T14-39.md`, `ci-dispatch.2026-11-14T15-07.md`, `self-review.2026-11-14T15-08.md`.
- `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info` — parsed by the reviewer; figures match the evidence.

### Quality assessment prompts

- **Determinism:** synthetic roots, in-memory checkpoint text, models from `Resolve-DelegationModel`.
- **Isolation:** one failing condition per row.
- **Speed:** no process start in any new row.
- **Diagnostics:** `-Because` carries the returned reason.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token literal in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | No new process start in the helper; the legs reuse existing seams (`Get-OrchestrationGateWorktreeList`, `Get-EpicScopeWorktreeHeadBranch`); no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Case-sensitive label and path patterns; exactly one `branch:` line; non-local path forms rejected; checkpoint must parse to an object. |
| Error handling remains explicit | ✅ PASS | Named `PARALLEL_RECORDS_*` sub-codes after the unchanged base text; never-throw legs decline on error. |
| Configuration / path handling is safe | ✅ PASS | Checkpoint paths come only from `Get-WorktreeRunCheckpointPath -Kind parallel` or `-Kind item`; no literal checkpoint file name in a string expression of the new files. |

---

## Research Log

No external research was required. The AC-12 adjudication was confirmed by reading `Resolve-OrchestrationGateTarget` in `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`.

---

## Verdict

The branch implements both parallel records legs as specified, with every non-matching case unchanged, full coverage of the new files, mirror parity, and no change to Codex surfaces, the pr-author command gate, or the merge gate. The two Minor rows and two Info rows are non-blocking. The branch is ready to merge once PR CI on the head completes green.
