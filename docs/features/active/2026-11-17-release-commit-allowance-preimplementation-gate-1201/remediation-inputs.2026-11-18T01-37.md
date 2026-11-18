# Remediation Inputs (Cycle 1) - Issue #1201

- Timestamp: 2026-11-18T01-37
- Source: CI run 44214588875 on PR #1202, head 89d0e58610eac3b66504ca2ba27a6d22a8f15312
- Opened by: CI failure after the PASS review at the same head (review_outcomes entry 1)
- Remediation-Mode: proportionate

## Finding CI-1 (Blocking)

- Check: `poshqc / PowerShell hook suites (Linux)` (job 134501283713), which feeds `CI Required Gate`.
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/44214588875/job/134501283713
- Result: Tests Passed 15529, Failed 1, Skipped 8.
- Failing test: `hook-release-allowance-context.ps1 (Claude).baseline mock interception probe` in `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1`.
- Failure text: `Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 time exactly, but was called 0 times`.
- Observation: the same suite passed in the local parallel Pester gate on Windows, and the shard jobs on `windows-latest` passed. The Linux job runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on a case-sensitive file system, and files in one job share a process, so the cause is a Linux-only path or case difference in the probe setup of this suite, or cross-file state (leak) that this suite is sensitive to. The probe helper is `Invoke-EpicStateProbeEpicScope` in `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`; other suites that call the same probe pass on Linux.
- Required outcome: diagnose the root cause; fix it in the new suite (and, when the cause is a leak, in the suite that leaks state as well, per the test-isolation policy); prove the fix under conditions that reproduce the Linux job (case-sensitive paths, shared process with the other hook suites) as far as the local environment allows; never weaken or delete the probe, and do not edit any existing suite unless it is the proven leaker.
- Remediability: autonomous
- Finding-Scope: contained

## Finding CI-2 (Blocking, non-remediable in this repository)

- Checks: `NPM Audit Gate / npm audit (.)` (job 134501284100) and `NPM Audit Gate / npm audit (extensions/drm-copilot)` (job 134501284086).
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/44214588875/job/134501284100
- Cause: advisory GHSA-fc5q-39xc-vjpf (picomatch ReDoS, severity high), updated 2026-11-17T15:56:44Z to cover picomatch `<= 4.0.7` with no first patched version. The latest published picomatch is 4.0.7. The last green CI on `main` (run 44020176252) predates the advisory update, so `main` is affected identically; this branch changes no package manifest or lockfile.
- No in-repository remediation keeps the audit gate intact: there is no patched version to pin or override, and suppressing the advisory or lowering the audit level weakens a CI gate, which is a refused class for this run (gate bypass, policy or settings edit).
- Remediability: external_dependency
- Finding-Scope: design
- Action in this cycle: none. Re-check the advisory and re-run the audit job after cycle 1; if a patched picomatch has been published, the fix becomes an autonomous finding of a new cycle.
