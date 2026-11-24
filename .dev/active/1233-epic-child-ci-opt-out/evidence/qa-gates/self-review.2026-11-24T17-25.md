# Self-review: issue #1233 remediation cycle 1 (P1-T14)

Timestamp: 2026-11-24T17-25
Plan: remediation-plan.2026-11-24T14-21.md
Scope: the branch diff from the merge base of origin/main and HEAD, with the cycle's changes (commit 282b8f50c and the uncommitted cycle evidence) walked against `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md`. Rows for the branch as a whole that this cycle did not change carry forward from self-review.2026-11-24T13-11.md and are re-checked against the cycle diff.
Result: no FAIL row.

## Review findings closed by this cycle

| Finding | Status | Evidence |
| --- | --- | --- |
| F1 (Blocking): PowerShell completion validator read the new keys case-insensitively | PASS | P1-T2: ordinal reads and `Get-MissingOrdinalGateKey`; fail-before evidence/regression-testing/fail-before-f1.2026-11-24T15-25.md (4 OCC-CORPUS rows failed); after the fix the corpus passes in Pester (task-check.R1-P1-T2, r1-final-pester-selection), pytest (78 passed), and Jest (27 passed). |
| Minor: merge-gate opt-out read keys case-insensitively | PASS | P1-T3: `Get-EpicMergeGateChildCiOrdinalProperty` and `Get-EpicMergeGateChildLocalQcReviewedHead`; fail-before evidence/regression-testing/fail-before-merge-gate-ordinal.2026-11-24T15-56.md (12 Claude and 15 Codex new rows failed); all pass in task-check.R1-P1-T3 and r1-final-pester-selection. |
| Nit: `$ciGate =(` spacing | PASS | P1-T2 restored `$ciGate = (`; the 0014 block Current was updated in the same task. |
| Nit: missing blank line between the #1233 and #1234 paragraphs of the Codex gate | PASS | P1-T5; task-check.R1-P1-T5 (blank-line-only diff, bundle identical); the Codex gate now reverts to its merge-base bytes. |
| Sweep of the class | PASS | evidence/other/ordinal-key-sweep.2026-11-24T15-15.md: 35 reads, no read outside the expectation; the completion-helper reads are pinned by P1-T4. |

## Policy audit template

| Item | Status | Evidence |
| --- | --- | --- |
| 1.1 Independence | PASS | New rows build checkpoints from literal JSON or fixtures in memory; per-row gh and git values are reset by `Initialize-OptOutRow`; selections ran in parallel shards (workers=8) and passed. |
| 1.1 Isolation | PASS | One case-variant key per row; one corpus case per fixture. |
| 1.1 Fast execution | PASS | New rows run in milliseconds inside their shards (fail-before logs show 6 to 37 ms per corpus row). |
| 1.1 Determinism | PASS | gh, git, and checkpoint seams mocked by name; no clock, network, or process. |
| 1.1 Readability | PASS | Row ids OPT-ORD-*, CLAUDE-OPT-ORD-*, CH-ORD-*, OCC-CORPUS-<stem>; Arrange/Act/Assert comments. |
| 1.2 Baseline coverage documented | PASS | evidence/remediation-baseline/r1-pester-selection.2026-11-24T15-07.md (selection-scoped under O1). |
| 1.2 No coverage regression | PASS | evidence/qa-gates/r1-coverage-comparison.2026-11-24T17-23.md: no per-file drop. |
| 1.2 Changed files meet thresholds | PASS | 98.69%, 100%, 98.8%, and 99.45% line coverage for the changed PowerShell files. |
| 1.2 New code coverage at least 90% | PASS | Added and changed lines 100% covered (30/30 in the module; 25/25 and 26/26 per helper copy). |
| 1.2 Comprehensive coverage | PASS | Every #1233 key read has a case-variant row (predicate, fallback, L1, L2, accessor) or a corpus fixture. |
| 1.2 Positive flows | PASS | Existing allow rows and CH-ORD control rows pass with the ordinal readers. |
| 1.2 Negative flows | PASS | 8 deny rows per merge-gate suite, 4 corpus fixtures, 6 completion-helper rows. |
| 1.2 Edge cases | PASS | Keys that differ only in letter case; non-object accessor input. |
| 1.2 Error handling | PASS | Unchanged fail-closed paths; the accessor returns `$null` for a non-object. |
| 1.2 Concurrency / state transitions | N/A | Stateless validators and gate helpers. |
| 1.3 Clear failure messages | PASS | `-Because` carries the deny reason or the missing list. |
| 1.3 Arrange-Act-Assert / document intent | PASS | New rows and suite synopsis. |
| 1.4 External dependencies, mocks, environment | PASS | No network, process, or temporary file; leak scan 0 failures (r1-final-powershell-static). |
| 1.5 Pre-submission review | PASS | This file and pre-push-review.R1. |
| 2.1 Before making changes | PASS | Remediation plan preflighted (preflight-fixes.2026-11-24T14-41.md) and executed in order; Phase 0 baselines. |
| 2.2 Design principles | PASS | One private ordinal accessor per surface, reusing `Get-CheckpointObjectOrdinalMember` in the module; `Get-MissingGateKey` and its ci_gate/pr_gate callers unchanged. |
| 2.3 Cohesive modules / file size | PASS | Module 592, helper 629, opt-out suites 455 and 411, Codex gate 461 lines; none at or above 700; the Claude gate is unchanged at 500 (O5). |
| 2.3 Public vs internal | PASS | New functions are private (module export list unchanged; the helper exports nothing). |
| 2.3 No circular dependencies | PASS | No new import or dot-source. |
| 2.4 Names, help, comments | PASS | Comment-based help on all three new functions; one header sentence in the helper. |
| 2.5 Toolchain: formatting | PASS | Invoke-PoshQCFormat no-op seam: 0 "Formatted:" lines; per-file drift 0 (r1-final-powershell-static). |
| 2.5 Toolchain: linting | PASS | PSScriptAnalyzer 0 findings (one PSUseOutputTypeCorrectly finding during P1-T3 was fixed before its check). |
| 2.5 Toolchain: type checking | N/A | PowerShell has no type checker; no Python or TypeScript production change (O2). |
| 2.5 Toolchain: tests | PASS | Set P 3589/3589, Set Y 78/78, Set J 27/27, Set L 149/149 on the committed tree. |
| 2.5 Contract checks | PASS | Harness `-Check` no drift; Codex generator `--check` exit 0; push-down contract tests in Set Y pass (r1-contract-check). |
| 2.6 Summarize and document | PASS | Commit message; ledger 0014 Files Changed and Revert Steps updated. |
| 3A Python | N/A | No Python file changed in this cycle. |
| 3B PowerShell tooling and safety | PASS | Ordinal `-ceq` comparison; no dynamic invocation; no new dot-source. |
| 3D JSON | PASS | Four fixtures parse, LF, `name` equals stem (OCC-CORPUS rows assert it). |
| 4B PowerShell tests | PASS | EpicStateIsolation suites in Set P pass with the edited opt-out suites. |
| 7 Code quality | PASS | Zero static findings. |
| CI cross-check | N/A | The pull request's own CI run is orchestrator-owned (S9). |
| 8 Gaps and exceptions | PASS | No skipped or removed test. |

## Code review template

| Item | Status | Evidence |
| --- | --- | --- |
| PowerShell implementation | PASS | `Get-EpicMergeGateChildCiOrdinalProperty` keeps the comma return of the existing accessor so arrays are preserved; `Get-EpicMergeGateChildLocalQcReviewedHead` keeps the last-entry semantics of `Get-EpicMergeGateLastReviewOutcome`; stages 1 to 6 and the review guard are unchanged. |
| Python / TypeScript implementation | N/A | Unchanged in this cycle. |
| Test quality | PASS | Case-variant rows built from literal JSON or a single-occurrence `-creplace`, never through the case-insensitive ordered-dictionary overrides. |
| No secrets; no unsafe command construction | PASS | None added. |
| Input validation at boundaries | PASS | Keys now match the validators' exact names. |
| Error handling remains explicit | PASS | Every failure still denies with its stage id; no fall-through. |
| Research log | N/A | No external research. |

## Feature audit template: acceptance criteria touched by this cycle

| Criterion | Status | Evidence |
| --- | --- | --- |
| spec S7 / user-story U7: the three validators accept the opt-out and emit the strings in order | PASS | Corpus of 23 fixtures (4 new) passes in pytest, Jest, and Pester; both checkboxes now `[x]`, text unchanged. |
| spec: validator strings byte-identical across runtimes | PASS | The same `expected_errors` asserted by all three suites, including the case-variant fixtures. |
| spec: default behavior unchanged, deny texts unchanged | PASS | Pre-existing default rows and `enforce-epic-merge-gate.ChildCi.Tests.ps1` pass unchanged; case-variant predicate keys now keep the pre-change text. |
| spec: Claude and Codex helper copies byte-identical, bundles match | PASS | cross-tree-helper-identity and the Set Y contract tests pass. |
| spec: ledger entry records the reduction; no earlier region edited | PASS | Set L on the committed tree; only 0014 changed. |
| spec: no file above the hard limit; review guard, workflows, docs lib unchanged | PASS | r1-contract-check scope rows; FileSizePolicy.RepoGate in Set P. |
| spec S19: the pull request's own CI run is green | N/A | Pending CI, orchestrator-owned at S9; left unchecked. |

## Observation outside the checklists

- Ledger 0014 does not restore `.claude/hooks/enforce-epic-merge-gate.ps1` to its merge-base bytes: the post-sync commit 16022bae3 reflowed header condition 4 (#670 text, whitespace only) without a revert block. The Codex gate gap is closed by P1-T5. The Claude gate is outside this cycle's file set (O5) and no template row covers it; reported to the coordinator for a decision (add one 0014 revert block for the condition-4 span, a ledger-only edit).
