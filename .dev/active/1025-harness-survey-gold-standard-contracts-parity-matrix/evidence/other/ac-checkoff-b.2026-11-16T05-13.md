# Acceptance Criteria Check-Off, Plan B (P2-T6)

Timestamp: 2026-11-16T05-13
Command: pwsh -NoProfile -File SCRATCH/issue-1025-ac-checkoff.ps1 (changes `- [ ]` to `- [x]` under `## Acceptance Criteria` of spec.md and user-story.md, except the criterion beginning `**Required CI check.**` and the criterion beginning `The completeness gate fails on`)
EXIT_CODE: 0
Output Summary: spec.md 25 checked, 1 unchecked (Required CI check); user-story.md 16 checked, 1 unchecked (The completeness gate fails on, CI-dependent, checked off by the orchestrator at S9). Criteria checked by plan A stay checked.

## spec.md criteria checked by plan B

| Criterion | Evidence |
| --- | --- |
| Per-skill records | plan A batch files and survey-completeness; plan B evidence/other/diff-id-reconciliation.2026-11-16T04-16.md (eight counts 0) and owner-decisions-applied.2026-11-16T04-16.md |
| Classification and approval artifact | evidence/other/diff-id-reconciliation.2026-11-16T04-16.md (Missing 0, Duplicated 0, Unknown 0, InvalidClass 0, InvalidPortDirection 0) |
| Owner decision recorded | evidence/baseline/phase0b-resume.2026-11-16T03-56.md (approved-with-overrides, 19 of 19 decided, Q1 to Q8 answered) |
| Matrix | evidence/other/matrix-violations-post-decision.2026-11-16T04-19.md (Violations 0); evidence/qa-gates/phase-gate.P1.2026-11-16T04-54.md and final-pester-b.2026-11-16T05-10.md (RepoGate 7 passed) |
| Contracts | evidence/other/contracts-post-decision.2026-11-16T04-22.md (ContractSetMismatch 0, Violations 0); RepoGate It `every shared codex skill has a conforming contract` passed |
| Bundle copies | contracts-post-decision (BundleMismatch 0); evidence/qa-gates/final-contract-checks-b.2026-11-16T05-11.md (resource contracts 9 passed, issue 824 follow-ups 62 passed) |
| Completeness unit tests: pass case | evidence/qa-gates/final-pester-b.2026-11-16T05-10.md (HarnessParityMatrix.Tests.ps1 76 passed, RepoGate 7 passed) |
| Coverage | evidence/qa-gates/final-pester-b.2026-11-16T05-10.md and coverage-delta-b.2026-11-16T05-10.md (100.00%, 99.25%, 100.00%) |
| Runbook results | evidence/baseline/phase0b-resume.2026-11-16T03-56.md (five deferrals); matrix-violations-post-decision (314 provisional entries held by a deferred runbook, DeferredRefMismatch 0) |
| Owner stop recorded | evidence/other/owner-stop.2026-11-16T03-50.md; phase0b-resume (blocked_reason human_decision_required, six requirements) |
| No new Python | evidence/qa-gates/no-new-python-b.2026-11-16T05-12.md (AddedPy 0) |
| File size | plan A evidence/qa-gates/file-size.2026-11-16T03-41.md; final-pester-b (file-size It passed); plan B changes JSON and Markdown only |
| Excluded paths untouched | evidence/qa-gates/excluded-paths-b.2026-11-16T05-12.md (ExcludedTouched 0, SpecExcludedTouched 0, OutsideEditSet 0) |

## user-story.md criteria checked by plan B

| Criterion (opening words) | Evidence |
| --- | --- |
| skill-survey.md has exactly one row | plan A survey-completeness.2026-11-16T01-21.md (Missing 0, Extra 0) |
| Every recorded difference has a class | diff-id-reconciliation.2026-11-16T04-16.md |
| difference-approval.md records my decision | phase0b-resume.2026-11-16T03-56.md |
| Every dropped entry has a non-empty reason | final-pester-b (HarnessParityMatrix.Tests.ps1 and RepoGate passed); matrix-violations-post-decision (Violations 0) |
| The E5 result is recorded | plan A e5 record and runbooks (pre-stop-readiness.2026-11-16T03-42.md) |
| Each of E1 to E6 has a recorded result or deferral | phase0b-resume; matrix-violations-post-decision |
| Execution stopped once for owner input | owner-stop.2026-11-16T03-50.md |
| No new .py file, no file over 800 lines, no excluded path | no-new-python-b, plan A file-size, excluded-paths-b |
| matrix and schema exist; agreement test passes | final-pester-b (RepoGate 7 passed) |
| Every entry carries the required fields | RepoGate It `committed matrix has no violation against the live inventory` passed |
| For every codex:skill shared entry, the contract satisfies Contract Format | final-pester-b (HarnessSkillContract.Tests.ps1 25 passed, RepoGate passed) |
| Each contract has a byte-identical bundle copy | contracts-post-decision (BundleMismatch 0); final-contract-checks-b |
| Each per-skill survey record uses the shape | diff-id-reconciliation (SequenceGaps 0, RecordsWithoutTable 0) |
| Every copilot:* entry approved or provisional with a decision_ref | matrix-violations-post-decision (E3DispositionMismatch 0, DeferredRefMismatch 0; copilot:agent entries provisional with the E3 runbook decision_ref, copilot:skill entries approved dropped with the issue-keyed decision_ref) |
| Coverage of the three modules | final-pester-b, coverage-delta-b |

Remaining unchecked: spec.md `Required CI check`; user-story.md `The completeness gate fails on ...` (both CI-dependent, orchestrator S9).
