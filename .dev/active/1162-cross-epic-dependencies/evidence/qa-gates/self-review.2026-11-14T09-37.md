# Self-Review — Remediation Cycle 1, P2-T8 (Issue 1162)

Timestamp: 2026-11-14T09-37
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against the branch diff from the merge base of origin/main and HEAD (the merge base equals origin/main after the P2-T1 merge; 140 files, all of which belong to #1162), with this cycle's delta read from the Phase 0 commit to HEAD; git diff --name-only of the merge base and HEAD over .claude/hooks, .codex/hooks, .claude/settings.json, .codex/config.toml, and .codex/hooks.json
EXIT_CODE: 0
Output Summary: 0 FAIL rows. F1 and F2 are closed. No hook file or hook registration changed: the hook-scope diff listed no path. One advisory note: `.claude/lib/epic-wave/EpicCrossDependency.psm1` stays at 769 lines (advisory tier, below the 800-line hard limit; non-blocking). A second note: the adapter test file grew by 37 lines rather than the plan's estimate of under 30, and it remains at 240 lines.

Scope: issue #1162, branch feature/cross-epic-dependencies-1162, remediation cycle 1 (inputs remediation-inputs.2026-11-14T07-20.md, findings F1 and F2). Gate evidence: evidence/qa-gates/powershell-static.2026-11-14T09-09.md, python-static.2026-11-14T09-10.md, pester.2026-11-14T09-30.md, pytest.2026-11-14T09-34.md, jest.2026-11-14T09-35.md, jest-root.2026-11-14T09-35.md, coverage-comparison.2026-11-14T09-36.md, phase-gate.P1.2026-11-14T08-57.md.

## Finding closure

| Finding | Result | Evidence |
|---|---|---|
| F1 stale remote-tracking ref | PASS | `Get-EpicCrossReadinessResult` fetches with `fetch`, `-q`, `--prune`, `origin`. The stale-ref adapter test failed before the fix (stale-ref-fail-before.2026-11-14T08-20.md: `merge_required`) and passes after it (stale-ref-pass-after.2026-11-14T08-22.md: `release|PREREQ_IN_MAIN`, exactly one pruning fetch). The three module copies share blob b7f1eb4d44c34c157e5fc8da1159358e97af4201. |
| F2 decision-to-status mapping | PASS | The **Status mapping (D7).** paragraph is in both epic-orchestrate skills, the epic-orchestrator agent, the Codex toml, and the four bundle copies. The CES-STATUS-MAPPING cases failed before the text change (status-mapping-fail-before.2026-11-14T08-23.md) and pass after it (status-mapping-pass-after.2026-11-14T08-24.md). The mapping agrees with `CROSS_EPIC_INTEGRATED_STATUSES` (`integrated`, `in_main`) and with the completion check that requires `cross_epic_main_gate` status `released`. |
| Digest and ledger refresh | PASS | The frozen digests were recomputed from the merged bytes (frozen-digests.2026-11-14T09-02.md). PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS pass, and so does test_frozen_epic_surface_matches_pinned_baseline_digest. |

## Policy audit template

| Section | Item | Result | Evidence |
|---|---|---|---|
| 1.1 | Independence | PASS | The new tests keep their state in module script scope and clear it in a `finally` block. The parallel Pester gate passed (8 shards), and the leak scan is clean. |
| 1.1 | Isolation | PASS | The stale-ref test targets one decision path; each CES-STATUS-MAPPING case targets one surface. |
| 1.1 | Fast Execution | PASS | The two task checks ran 141 and 23 tests in seconds; no slow test was added. |
| 1.1 | Determinism | PASS | git and gh go through mocked wrappers; the clock is mocked; no sleep. |
| 1.1 | Readability & Maintainability | PASS | The It name states the scenario and outcome; the contract rows quote the asserted sentences verbatim. |
| 1.2 | Baseline Coverage Documented | PASS | evidence/remediation-baseline/pester.2026-11-14T08-14.md, pytest.2026-11-14T08-18.md, jest.2026-11-14T08-19.md, jest-root.2026-11-14T08-19.md. |
| 1.2 | No Coverage Regression | PASS | coverage-comparison.2026-11-14T09-36.md: the changed file is unchanged at 98.03%; the repository figures are equal at reported precision. The four-decimal Pester difference comes from lines added by the #1156 merge (decision D-3). |
| 1.2 | Changed Files Meet Thresholds | PASS | EpicCrossDependency.psm1 98.03% line coverage, at or above 85%. |
| 1.2 | New Code Coverage >= 90% | PASS | The changed line is covered (1 of 1). |
| 1.2 | Comprehensive Coverage | PASS | F1 has a positive release path and keeps the existing failed-fetch and thrown-wrapper rows; F2 covers all four surfaces. |
| 1.2 | Positive Flows | PASS | The stale-ref release path, and every mapping surface present. |
| 1.2 | Negative Flows | PASS | The `'a failed fetch'` row and the thrown-wrapper rows still give PREREQ_UNVERIFIABLE with the new argument array. |
| 1.2 | Edge Cases | PASS | A stale ref that a non-pruning fetch would read is modelled explicitly. |
| 1.2 | Error Handling | PASS | The fail-closed fetch path is unchanged and covered. |
| 1.2 | Concurrency | N/A | No concurrent code path. |
| 1.2 | State Transitions | PASS | The mapping text defines held, released, integrated, and in_main transitions; the validators are unchanged. |
| 1.3 | Clear Failure Messages | PASS | `-Because` text on the mapping rows; the decision string is compared exactly. |
| 1.3 | Arrange-Act-Assert Pattern | PASS | Table setup, one command call, then assertions. |
| 1.3 | Document Intent | PASS | Intent comments above the mapping tokens and the stale-ref mock. |
| 1.4 | Avoid External Dependencies | PASS | No real git or gh; wrapper mocks use the matching `GitArgs` and `GhArgs` names. |
| 1.4 | Use Mocks/Stubs | PASS | Only the two process wrappers and the clock are mocked. |
| 1.4 | Environment Stability | PASS | No temporary files; in-memory text only. |
| 1.5 | Pre-submission Review | PASS | This file, plus a diff review before each push. |
| 2.1 | Clarify the objective | PASS | remediation-inputs F1 and F2. |
| 2.1 | Read existing change plans | PASS | The remediation plan was executed in order after single-pass preflight. |
| 2.1 | Document the plan | PASS | remediation-plan.2026-11-14T07-20.md with check-offs. |
| 2.2 | Simplicity first | PASS | One argument added for F1; one appended paragraph per surface for F2. |
| 2.2 | Reusability | PASS | The new contract case reuses the existing section, collapse, and token helpers. |
| 2.2 | Extensibility | PASS | No interface change. |
| 2.2 | Separation of concerns | PASS | The fetch stays in the gather path; the pure decision rows are unchanged. |
| 2.3 | Cohesive modules | PASS | No new module. |
| 2.3 | At or below the 800-line hard limit | PASS | EpicCrossDependency.psm1 769 (advisory tier); adapter tests 240; contract tests 152. |
| 2.3 | Public vs internal | PASS | No export change. |
| 2.3 | No circular dependencies | PASS | No import change. |
| 2.4 | Descriptive names | PASS | `CES-STATUS-MAPPING`, `$script:MappingRow`. |
| 2.4 | Docs/docstrings | PASS | The skill and agent text documents the mapping. |
| 2.4 | Comment why, not what | PASS | The mock comment explains the one-clone stale-ref model. |
| 2.5 | 1. Formatting | PASS | Invoke-PoshQCFormat 0 reformatted; Black 1065 unchanged. |
| 2.5 | 2. Linting | PASS | Invoke-PoshQCAnalyze 0; Ruff 0; leak scan 0. |
| 2.5 | 3. Type checking | PASS | Pyright 0 errors. |
| 2.5 | 4. Testing | PASS | Pester 25005/0 failed, pytest 16822/0 failed, Jest 5629/0 and 5646/0 failed. |
| 2.5 | Full toolchain loop | PASS | P1 phase gate in one clean pass; the final loop in one clean pass after the merge. |
| 2.5 | Explicit reporting | PASS | Every command, exit code, and count is in the gate artifacts. |
| 2.6 | Summarize changes | PASS | Commit messages per phase and for the merge. |
| 2.6 | Design choices explained | PASS | autonomous-decisions.2026-11-14T09-36.md (D-1 to D-3). |
| 2.6 | Update supporting documents | PASS | Skills, agent, toml, bundle copies, digest pins, 0010 patch. |
| 2.6 | Provide next steps | PASS | Re-review and S9 CI on the PR head. |
| 3A | Python items | PASS | The only Python change is the expectations constants module (digests and comments); Black, Ruff, and Pyright are clean. |
| 3B.1 | Formatting with Invoke-Formatter | PASS | powershell-static.2026-11-14T09-09.md. |
| 3B.1 | Linting with PSScriptAnalyzer | PASS | 0 findings. |
| 3B.1 | Fix all findings | PASS | None open. |
| 3B.1 | PowerShell 5.1 & 7.6+ compatible | PASS | Repository policy requires PowerShell 7+. |
| 3B.2 | Advanced functions | PASS | Unchanged function signatures. |
| 3B.2 | Parameter validation | PASS | Unchanged. |
| 3B.2 | Avoid global state | PASS | Test state lives in module script scope only and is cleared; leak scan clean. |
| 3B.2 | Error handling | PASS | Fail-closed fetch unchanged. |
| 3B.3 | Cohesive and at or below the 800-line hard limit | PASS | See 2.3. |
| 3B.3 | Approved verbs | PASS | No new function. |
| 3B.3 | Comment why | PASS | See 2.4. |
| 3B.4 | Steps 1, 2, 4 | PASS | Format, analyze, and test are clean. |
| 3B.4 | Step 3: Type check | N/A | Not applicable for PowerShell. |
| 3B.4 | Rerun loop if needed | PASS | No rerun needed. |
| 3C | Bash items | N/A | No bash file changed. |
| 3D | JSON items | N/A | No JSON changed in this cycle. |
| 4A | Python unit test items | N/A | No Python test file added or changed. |
| 4B | PowerShell unit test items | PASS | Pester 6.2.0; test paths mirror production; It names describe behavior. |
| 7 | Code quality checks | PASS | Static artifacts above. |
| CI cross-check | CI result on the PR head | N/A | Owned by the orchestrator at S9. |

## Code review template

| Item | Result | Evidence |
|---|---|---|
| Findings table | PASS | F1 and F2 are closed with fail-before and pass-after evidence; no new finding is open. |
| PowerShell implementation audit | PASS | Wrapper seam unchanged; argument array only. |
| Python implementation audit | PASS | Constants and comments only. |
| TypeScript implementation audit | N/A | No TypeScript change in this cycle. |
| C# implementation audit | N/A | No C# change. |
| Test quality audit | PASS | See 1.x. |
| No secrets in code | PASS | None added. |
| No unsafe subprocess or command construction | PASS | `--prune` is a literal element of the splatted array. |
| Input validation at boundaries | PASS | Unchanged. |
| Error handling remains explicit | PASS | A non-zero fetch exit and a thrown wrapper still fail closed. |
| Configuration / path handling is safe | PASS | No path change; no absolute path in any artifact. |
| Hook files and registrations | PASS | The hook-scope diff from the merge base lists no path. |
| Verdict | PASS | |

## Feature audit template

| Item | Result | Evidence |
|---|---|---|
| Scope and baseline | PASS | The Phase 0 baselines of this cycle and both main syncs are recorded. |
| Acceptance criteria inventory | PASS | spec.md `## Acceptance Criteria` 25, user-story.md 8, issue.md 6; unchanged by this cycle. |
| Acceptance criteria evaluation | PASS | The F1 test strengthens the spec edge flow for a deleted prerequisite branch (PREREQ_IN_MAIN); the F2 rows pin the D7 records mapping. |
| Acceptance criteria check-off | PASS | 39 of 39 checked in the AC sources. The six unchecked items in spec.md are under `## Definition of Done`, not `## Acceptance Criteria`, and are outside AC tracking. |
| AC status summary | PASS | No unchecked AC; CI on the PR head is pending and owned by the orchestrator at S9. |
