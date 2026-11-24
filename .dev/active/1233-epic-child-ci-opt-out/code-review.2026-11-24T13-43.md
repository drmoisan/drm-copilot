# Code Review: Epic Child CI Opt-Out (#1233)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1233-epic-child-ci-opt-out/`
**Feature Folder Selection Rule:** named by the caller and matching issue #1233 and the branch name
**Base Branch:** `main` (merge base `23458fade99f40e81b95ce86ed90805258479782`)
**Head Branch:** `feature/epic-child-ci-opt-out-1233` (head `0fc83af8b03b74deed2615238faa8c203df942dd`; no pull request yet)
**Review Type:** Initial review

---

## Executive Summary

The branch adds an epic-level opt-out, `child_ci: integration_only`, under which an epic child merges into its integration branch on verified local final-QC evidence and a current concurrent review instead of a green `CI` run on its own head. It changes the byte-identical child-CI merge-gate helper (new stages B, R, L1, L2, L3 and a `-GitRoot` parameter), the byte-identical completion helpers and both completion-consistency hooks, the three completion validators (Python inline, a new TypeScript module, and the PowerShell completion-checks module), the orchestrate, epic-orchestrate, epic-run, epic-plan, and execution-environment skills, the orchestrator-state rule (through its harness source), the epic manifest template, and every bundle copy. It records the reduction in ledger entry `0014`.

Evidence reviewed: the full branch diff `23458fade..0fc83af8b`; the helper, hook, validator, and TypeScript changes in full; the skill and rule diffs; the merge-gate and corpus suites (targeted reading); the executor evidence under `evidence/`, including `evidence/qa-gates/self-review.2026-11-24T13-11.md`, `coverage-comparison.2026-11-24T13-09.md`, and the post-sync records; reviewer re-parses of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`; a reviewer root Jest coverage run; git blob comparison of every mirror; and a reviewer cross-runtime probe of the validators.

Specific checks performed:

- Gate predicate and fallback: `Test-EpicMergeGateChildCiOptOut` requires `epic_mode` as the JSON boolean `true`, `child_ci` ordinally equal to `integration_only`, and an integration branch matching `\Aepic/[A-Za-z0-9][A-Za-z0-9._-]*-integration\z`. A live base that differs from the recorded branch, or equals `main`, returns `Applies = $false` and stages 2 to 6 run with the stage-B head reused, so the opt-out can never admit a merge into `main`.
- Fail-closed stages: every opt-out failure returns the `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` prefix and `Get-EpicMergeGateChildCiDecision` passes it through without the CI prefix; there is no fall-through to later gate branches.
- Evidence binding: L2 compares `local_qc_gate.head_sha` with the last review outcome without a process call, and L3 reads the file at the live head with one `git cat-file -p`. The evidence commit moves the live head, which the existing review guard tolerates only for feature-folder-only paths (guard steps 9 to 12), so the design is consistent with the guard.
- Mirrors: the child-CI helper (blob `48be97927`) and the completion helpers (blob `2573b573a`) are identical in `.claude/hooks/`, `.codex/hooks/`, and both bundle trees; all 21 bundle copies changed on the branch equal their sources.
- Cross-runtime parity: a reviewer probe found that the PowerShell validator accepts a checkpoint whose `local_qc_gate` and `remediation_loop` keys differ only in letter case, while the Python validator rejects it with three errors (finding F1).

**Top 3 risks:**
1. Validator parity: the PowerShell completion check reads the new keys case-insensitively, so the three runtimes disagree on case-variant keys (F1, blocking).
2. `child_ci` is self-declared by the item checkpoint; the live-base check, the concurrent-review requirement, and the evidence file bound it. This is disclosed in the rule section and ledger entry `0014`.
3. Isolated subagents run the default branch's hooks, so the new gate and completion behavior is proven by mocked Pester rows until the branch merges; the pull request's own `CI` run is still to come.

**PR readiness recommendation:** **No-Go** until F1 is remediated. F1 is contained to one PowerShell function, its bundle copy, one corpus fixture, and the matching ledger revert block.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` (and its bundle copy) | `Get-OrchestratorStateCompletionLocalQcGateError` | F1. The function reads `conclusion` and `head_sha` of `local_qc_gate`, `remediation_loop`, `review_outcomes`, and the last outcome's `head_sha` through the case-insensitive `Get-CheckpointObjectMember`, and checks required keys through `Get-MissingGateKey`, which is also case-insensitive. A checkpoint with `"Conclusion"`, `"Head_Sha"`, and `"Remediation_Loop"` gets zero PowerShell errors, while the Python validator reports three (missing fields `conclusion, head_sha`; conclusion must be success; head binding). The TypeScript port uses case-sensitive property access and agrees with Python by inspection. | Read every key of the new check through `Get-CheckpointObjectOrdinalMember` and check the `LOCAL_QC_GATE_KEYS` presence ordinally (a local loop, or an opt-in ordinal switch on `Get-MissingGateKey` that leaves the `ci_gate` and `pr_gate` callers unchanged). Add a corpus fixture with case-variant field keys whose `expected_errors` are the Python output, so all three suites pin it. Re-mirror the bundle copy and update the `0014` revert block for this file. | The spec requires the three runtimes to emit each listed string for its failing condition; the #1097 convention (documented on `Get-CheckpointObjectOrdinalMember`) reads newly introduced keys ordinally to keep the runtimes in agreement. The predicate keys already use the ordinal reader; the field keys do not. | Reviewer probe: `validate_completion_gate_evidence` returned 3 errors; `Get-OrchestratorStateCompletionCiGateError` returned count 0 on the same checkpoint; controls `conclusion-not-success.json` and `opt-out-accepted.json` matched in both runtimes. |
| Minor | `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1` (and its three copies) | `Test-EpicMergeGateChildCiOptOut` | The gate predicate reads `epic_mode`, `child_ci`, `epic_context`, and `local_qc_gate` through `Get-EpicMergeGateChildCiProperty`, whose `PSObject.Properties[$Name]` lookup ignores letter case. A key spelled `Child_CI` activates the opt-out at the merge gate, while the completion hooks (`-cnotcontains`) and the validators (ordinal) treat the same checkpoint as `per_child`. | Optional: read the opt-out keys by ordinal name in the helper, re-mirroring all four copies. | The inconsistency cannot admit a merge into `main` and every opt-out stage still applies, so it does not weaken the reduction's bounds; the accessor is pre-existing and shared with stages 1 to 6. | Inspection of lines 104-107 and the `Test-CompletionChildCiIntegrationOnly` name checks. |
| Nit | `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` (and its bundle copy) | `Get-OrchestratorStateCompletionCiGateError`, line `$ciGate =(Get-CheckpointObjectMember ...` | The branch removed the space after `=` on an existing line. The formatter settings do not enable `PSUseConsistentWhitespace` `CheckOperator`, so the static gate did not report it. | Restore `$ciGate = (Get-CheckpointObjectMember ...` in the F1 edit. | Style consistency; no behavior change. | `git diff 23458fade..HEAD` of the module. |
| Nit | `.codex/hooks/enforce-epic-merge-gate.ps1` (and its bundle copy) | header, between the `Child CI opt-out (issue #1233)` and `Release merge leg (issue #1234)` paragraphs | The main-sync merge left the two header paragraphs without a separating blank line. | Optional: insert a blank line, keeping the bundle copy identical and the `0014` revert block current. | Comment layout only. | Lines 35-39 of the Codex gate at head. |
| Info | `artifacts/pester/powershell-coverage.xml` | whole file | After the main sync, the executor's targeted post-sync Pester run (2082 tests) replaced the final full-gate report; its root counter is 10.94% and is not a repo-wide figure. | None. Repo-wide PowerShell coverage is taken from the final full gate (96.87%); per-file figures for files changed after that gate are re-read from the current report, which ran every merge-gate suite. | Owner-directed targeted runs after the final QC gate. | `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md`; `evidence/qa-gates/post-sync-check.2026-11-24T13-36.md`; reviewer parse. |

No Blocker finding. No covered file is at or above 700 lines (largest: `extensions/drm-copilot/jest.config.cjs`, 689 logical lines), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The opt-out is inserted after stage 1 only when the predicate holds; without it the helper takes the pre-change path and the new seam `Get-EpicMergeGateChildCiLivePullRequest` is never called, which the default rows assert with `Should -Invoke -Times 0`.
- Stage B reuses its head read for stage 3 on a base fallback, so the fallback costs no second `gh pr view` (asserted by `CLAUDE-OPT-COUNT-BASE-MISMATCH-ALLOW` and `OPT-COUNT-BASE-MISMATCH-ALLOW`).
- `Test-EpicMergeGateChildCiEvidencePath` rejects backslashes, empty, `.`, and `..` segments and requires the `<feature-folder>/evidence/qa-gates/` prefix ordinally; the feature folder itself is validated by the existing `Test-EpicMergeGateReviewFeatureFolder`.
- The completion hooks change two conditions and one reason string, and the pre-change reason text is byte-unchanged for checkpoints without the key.

#### API and safety notes

- New functions have `[CmdletBinding()]`, `[OutputType()]`, comment-based help, and approved verbs (`Test-`, `Get-`, `ConvertTo-`).
- `-GitRoot` is optional and defaults to `GhRoot`, so the Codex call site is unchanged; the Claude gate passes the item worktree.
- No new script-scope state beyond two constants (`EpicMergeGateChildLocalQcReasonPrefix`, `EpicMergeGateChildCiIntegrationBranchPattern`).

#### Error handling and logging

- `Get-EpicMergeGateChildCiLivePullRequest` returns `$null` on a non-zero exit, unparseable JSON, a malformed head, or a blank base, and stage B denies on `$null`.
- The existing whole-body `try/catch` in `Get-EpicMergeGateChildCiDecision` still converts an unexpected error into a deny.

### Python implementation audit

- The change is inline and key-gated in `scripts/dev_tools/validate_orchestrator_state.py`: two constants, three private helpers, and one public selector `validate_completion_gate_evidence`, called only inside the existing `route_requires_ci_gate` branch. No Python module was added, and the `_orchestrator_state_concurrent_review` import line and the `validate_concurrent_review_completion` line are unchanged.
- Docstrings follow the repository style; `cast` is used for the narrowed mappings; pyright reported 0 errors.

### TypeScript implementation audit

- `orchestrator-state-child-ci.ts` is a pure module that reuses `missingObjectKeys` and `validateCompletionCiGate`, holds the error strings as constants, and has its own `coverageThreshold` entry (85 lines, 75 branches). `orchestrator-state-core.ts` swaps one import and one call.
- No `any`; `unknown` narrowing through `asObject`.

---

## Test Quality Audit

The two new merge-gate suites cover allow rows (40- and 64-character heads), every stage-B to L3 deny row, main-base and base-mismatch fallbacks, integration-branch pattern fallbacks, default rows that assert the pre-change deny text and zero opt-out seam calls, and process-call counts. The shared corpus (19 fixtures) is read by the Python, TypeScript, and PowerShell suites with a count floor. The completion-consistency suites gain allow and deny rows for the opt-out and keep the default reason text pinned. The skill-text contract suite pins the S9 paragraph, the schema and PR-gate sections, the epic-orchestrate kickoff line, and the execution-environment brief.

Gap: the corpus contains a case-variant `child_ci` value and a case-variant conclusion value, but no case-variant key, so it did not detect F1.

### Reviewed test and QA artifacts

- `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md` (29521 tests, 0 failures)
- `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md` (17126 passed, 0 failed)
- `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md` (6730 passed, 0 failed)
- `evidence/qa-gates/coverage-comparison.2026-11-24T13-09.md`
- `evidence/qa-gates/post-sync-check.2026-11-24T13-36.md` and `post-sync-pytest.2026-11-24T13-39.md`
- `evidence/qa-gates/self-review.2026-11-24T13-11.md`

---

## Documentation and Contract Audit

- The orchestrator-state rule change is made in `scripts/harness-generation/sources/rules/orchestrator-state.md` and `.json`; the generated rule and bundle copy are identical, and the executor's `Invoke-HarnessGeneration.ps1 -Check` after the main sync reported no drift.
- The epic-orchestrate skill digest re-baseline carries the `# RE-BASELINED by issue #1233` paragraph.
- `.github/workflows/ci.yml`, `enforce-epic-merge-gate-review.ps1` (both trees), `.codex/scripts/epic-child-launch-contract.ps1`, `.claude/lib/docs`, and the existing child-CI suites are unchanged on the branch.
- Ledger entry `0014` and its README row are present with `## Prior Text`, revert blocks per file, and the residual automatic `CI` run and self-declared-key disclosures.

---

## Verdict

**REMEDIATION_REQUIRED.** One blocking finding (F1, Major, autonomous, contained). The Minor and Nit rows are non-blocking; the `$ciGate =(` Nit sits in the same module as F1 and can be fixed in the same edit.
