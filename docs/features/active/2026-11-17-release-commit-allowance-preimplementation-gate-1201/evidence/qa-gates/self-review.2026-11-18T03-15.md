# Self-review - issue #1201 remediation cycle 1 (Finding CI-1), rewritten after the QA loop restart

Timestamp: 2026-11-18T03-15
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff <cycle-0 PR head recorded in remediation-inputs.2026-11-18T01-37.md>` (19 test files, 90 lines added, 0 deleted, plus feature-folder docs and evidence) and `git diff <merge base of origin/main and HEAD> --name-only` (52 paths outside docs/); sha256sum of the four copies of each new hook file; `git diff <cycle-0 PR head> --name-status` over spec.md, issue.md, the approved plan, and evidence/
EXIT_CODE: 0
Output Summary: no FAIL row. The previous self-review (self-review.2026-11-18T02-50.md) had a FAIL in substance on the both-sides rule: a pre-push sweep found three more in-process leakers. They were fixed (evidence/other/ci1-diagnosis.2026-11-18T02-52.md), the QA loop re-ran from format, and this review replaces that one. One non-blocking deviation remains: a pre-existing 536-line leaker suite is now 539 lines.

## Cycle-specific checks

| Checklist item | Result | Evidence |
|---|---|---|
| Finding CI-1 root cause evidenced from code | PASS | evidence/other/ci1-diagnosis.2026-11-18T02-06.md (mechanism; cites `Resolve-EpicScopeCheckpoint` with its `NoTarget` early return, `Resolve-WorktreeEpicTarget`, the `-Force` import in `validate-orchestrator-output.ps1`, `Reset-EpicStateProbeModuleBinding`, and Pester `Find-FileInDirectory`) and ci1-diagnosis.2026-11-18T02-52.md (full leaker list). |
| Probe not skipped or weakened | PASS | The diff of hook-release-allowance-context.Tests.ps1 against the cycle-0 head adds 3 lines in the outer `BeforeAll`, and 0 diff lines name the probe. EpicStateIsolation.Baseline.Helpers.ps1 is unchanged. |
| Leak fixed on both sides | PASS | Victim: reset before mock registration. Leakers: all 18 suites that run validate-orchestrator-output.ps1 in-process (dot-source or `&`) or force-import WorktreeRunResolution.psm1 now carry a `Reset-EpicStateProbeModuleBinding` teardown. The sweep covered every suite in both Linux folders that names the validator or runs hooks through `Get-HookInvocationPath` or `& $HookPath`. The diff deletes no line. |
| No production or bundle file changed in cycle 1 | PASS | `git diff <cycle-0 PR head> --name-only -- .claude/hooks .codex/hooks extensions` lists 0 paths. |
| Four-copy hook hashes unchanged | PASS | hook-release-allowance-context.ps1: 4 copies, one SHA-256 (597f46fa...d526). enforce-orchestration-preimplementation-gate-release.ps1: 4 copies, one SHA-256 (0f461b40...d832). The parity suite passed in both folder runs. |
| Spec AC check-offs and approved plan unchanged | PASS | `git diff <cycle-0 PR head> --name-status` over spec.md, issue.md, and plan.2026-11-17T14-05.md lists nothing. |
| Evidence append-only | PASS | No M or D entry under evidence/ against the cycle-0 head; all cycle-1 evidence files are new, with stamps read from the clock. The supplement and the re-run artifacts are new files; no earlier cycle-1 artifact was edited. No artifact records an absolute path or host name. |
| Finding CI-2 | N/A | `external_dependency` (GHSA-fc5q-39xc-vjpf, no patched picomatch); no package manifest, lockfile, or audit configuration changed. |
| Linux CI confirmation | N/A | Orchestrator-owned at S9; a local run cannot reproduce the single-process order (ci1-folder-proof.2026-11-18T03-02.md). |

## Policy audit template

| Checklist item | Result | Evidence |
|---|---|---|
| 1.1 Independence | PASS | The order dependence is removed on both sides. Folder run (15526 tests) and final gate (28105 tests) pass in parallel with 0 failures. |
| 1.1 Isolation | PASS | No test body changed; the reset removes only a stale fixture-root EpicScopeResolution instance. |
| 1.1 Fast execution | PASS | Final gate wall-clock 721.33 s against the baseline 732.5 s. |
| 1.1 Determinism | PASS | No clock, randomness, network, or file access added. |
| 1.1 Readability | PASS | Each teardown carries a comment naming the cause. |
| 1.2 Baseline coverage documented | PASS | evidence/remediation-baseline/pester.2026-11-18T02-04.md. |
| 1.2 No coverage regression | PASS | evidence/qa-gates/coverage-comparison.2026-11-18T03-14.md: repo-wide 96.08% to 96.08%; four hook files 100% to 100%. |
| 1.2 Changed files meet thresholds | N/A | Only test files changed (outside the coverage population). |
| 1.2 New code coverage >= 90% | N/A | No production code changed in cycle 1. |
| 1.2 Positive / negative / edge / error / concurrency / state-transition scenarios | N/A | No behavior under test changed. |
| 1.3 Clear failure messages, AAA, intent | PASS | No assertion changed. |
| 1.4 External dependencies and environment stability | PASS | No temporary file, process, or git call; leak scan 0 failures. |
| 1.5 Pre-submission review | PASS | This review, after one correction round. |
| 2.1 Objective and plan | PASS | remediation-plan.2026-11-18T01-37.md; preflight fixes in evidence/other/preflight-fixes.2026-11-18T01-50.md. |
| 2.2 Simplicity / reusability | PASS | Reuses `Reset-EpicStateProbeModuleBinding` and the established `AfterAll` form. |
| 2.3 File size limits | PASS | All 19 files are below 700 lines and 18 are below 500. hook-import-failure-exemptions.FailClosed.Tests.ps1 went from 536 to 539 lines (guidance tier only), recorded as a non-blocking deviation in final-qc-static-powershell.2026-11-18T03-02.md. |
| 2.4 Naming, docs, comments | PASS | No new symbol. |
| 2.5 Toolchain | PASS | final-qc-static-powershell.2026-11-18T03-02.md (format 0, PSScriptAnalyzer 0, leak scan 0 failures over 19 files); final-qc-pester.2026-11-18T03-14.md. |
| 2.6 Summarize and document | PASS | Diagnosis, supplement, task check, folder proofs, final QC, and coverage comparison. |
| 3A Python, 3C Bash, 3D JSON | N/A | Not changed. |
| 3B.1 PowerShell tooling and baseline | PASS | evidence/remediation-baseline/static-powershell-format.2026-11-18T01-51.md, static-powershell-pssa.2026-11-18T01-51.md, leak-scan.2026-11-18T01-51.md. |
| 3B.2 PowerShell design and safety | PASS | Teardown only; the reset is `SupportsShouldProcess` and path-scoped. |
| 3B.3 Structure, naming, comments | PASS | Teardown at file level, or in the Describe that runs the hook. |
| 3B.4 Running the toolchain | PASS | Through the launcher and the SCRATCH static scripts; no MCP summary used for any count. |

## Code review template

| Checklist item | Result | Evidence |
|---|---|---|
| Findings table | PASS | No Blocking or Warning finding. Info: no static guard covers module-table replacement (the leak scan has no module kind), so a future suite that loads validate-orchestrator-output.ps1 in-process without a teardown would reintroduce the class. Recorded in the diagnosis, section 5. |
| PowerShell implementation audit | PASS | Additive teardowns matching validate-orchestrator-output.Envelope.Tests.ps1 and enforce-parallel-cohort-barrier.Tests.ps1. |
| Python / TypeScript / C# audit | N/A | Not changed. |
| Test quality audit | PASS | The probe is the regression test; it failed on Linux before the fix (CI run 44214588875) and is unchanged. |
| No secrets; no unsafe command construction | PASS | None added. |
| Input validation at boundaries | N/A | No boundary changed. |
| Error handling remains explicit | PASS | No catch added. |
| Configuration / path handling is safe | PASS | `Join-Path` from `$PSScriptRoot`; tracked case confirmed with `git ls-files`. |

## Feature audit template

| Checklist item | Result | Evidence |
|---|---|---|
| Scope and baseline | PASS | Finding CI-1 only; remediation baseline before any change. |
| Acceptance criteria inventory and check-offs | PASS | spec.md unchanged from cycle 0. |
| Finding CI-1 required outcome | PASS | Diagnosed, fixed in the new suite and in all 18 proven leakers, folder-proven locally, probe unchanged; Linux CI confirmation pending S9. |
| AC status summary | PASS | Unchanged from cycle 0. |
