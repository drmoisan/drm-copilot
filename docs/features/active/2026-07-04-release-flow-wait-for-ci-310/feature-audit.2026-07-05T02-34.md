# Feature Audit — Issue #310 (release-flow-wait-for-ci)

- Timestamp: 2026-07-05T02-34
- Work mode: `full-bug`
- AC source resolution: Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves to `spec.md` only. `spec.md`'s `## Acceptance Criteria` section (lines 109–117) is the unfilled generic bug-report template — every field under Context, Environment, Repro Steps, and Acceptance Criteria is still placeholder text (`One or two sentences on what is broken.`, `1. ...`, etc.). Per this delegation's explicit instruction, `plan.md`'s `## Acceptance Criteria` section (lines 14–23, `AC1`–`AC8`) is treated as the authoritative, feature-specific AC source in place of the unfilled template, and is the primary evaluation table below. The generic `spec.md` template checklist is evaluated secondarily for completeness.

## Primary AC Evaluation — `plan.md` AC1–AC8

| AC | Criterion | Verdict | Evidence |
|---|---|---|---|
| AC1 | Flow waits (bounded) for required checks to **register** before treating an empty/not-yet-reported set as failure | **PASS** | `Wait-ForPullRequestChecks` registration loop (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1` lines 220–232); unit-tested in `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` "waits through the registration race then merges" and "returns failure on registration timeout" |
| AC2 | Flow waits (bounded) for registered checks to **complete** before evaluating pass/fail | **PASS** | Completion loop (lines 236–257); unit-tested in "waits through pending checks then completes" and "returns failure on completion timeout" |
| AC3 | `gh pr merge ... --merge --delete-branch` runs only after every required check reports `pass`/`skipping` | **PASS** | Wiring at lines 364–369 gates the merge call on `$checksResult -eq 0`; "successful automated flow" test in `Invoke-FullReleaseFlow.Tests.ps1` asserts the exact gh-call sequence `pr view → pr checks ... --required --json bucket → pr merge` |
| AC4 | Genuine check failure (`fail`/`cancel`) returns 1, no merge, no tag push | **PASS** | `Wait-ForPullRequestChecks` returns 1 immediately on `fail`/`cancel` without further polling (lines 238–241, confirmed by "returns failure immediately on a genuine check failure..." asserting `Invoke-GhExe` called exactly once); integration-level "stops before merge, pull, and tag push when checks fail" test in `Invoke-FullReleaseFlow.Tests.ps1` confirms no merge/checkout/pull/tag-push occurs |
| AC5 | Registration timeout or completion timeout returns 1, no merge, no tag push | **PASS** | Unit-tested directly on `Wait-ForPullRequestChecks` (both timeout paths return 1 with a distinct stderr message); wiring (`if ($checksResult -ne 0) { return 1 }`) is exercised generically by the checks-fail integration test, which proves the same code path used for both a genuine failure and a timeout halts before merge |
| AC6 | New/updated tests use the dot-source + `Mock` seam pattern; no real git/gh/network/sleep | **PASS** | Verified by inspection of all three touched test files: `Invoke-GhExe`, `Invoke-GitExe`, `Invoke-ChildPowerShellScript`, `Invoke-Sleep`, and `Write-StderrLine` are the only mocked seams; no `Start-Sleep` outside the production wrapper body; `Invoke-Sleep` mocked in every `BeforeEach` that reaches it |
| AC7 | Full PowerShell toolchain (format → analyze → test-with-coverage) passes in a single clean pass, no line/branch coverage regression | **PASS**, with a documented tooling caveat | `evidence/qa-gates/format-final.2026-07-04T22-35.md`, `lint-final.2026-07-04T22-36.md`, `test-final.2026-07-04T22-40.md` all EXIT_CODE 0; `coverage-delta.2026-07-04T22-42.md` shows line coverage improved 93.75% → 94.26% (no regression). Branch coverage is not numerically emitted by this repository's Pester/JaCoCo exporter for any PowerShell file (pre-existing, repo-wide tooling limitation, also documented under issue #298); see `policy-audit.2026-07-05T02-34.md` for full detail |
| AC8 | Production file and every touched test file remain <= 500 lines | **PASS** | `Invoke-FullReleaseFlow.ps1` 401 lines; `Invoke-FullReleaseFlow.Tests.ps1` 426 lines; `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` 99 lines; `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` 141 lines — all confirmed via direct `wc -l` |

All eight AC1–AC8 items were already marked `[x]` in `plan.md` by the executor; this audit independently re-verified each against the code, tests, and evidence artifacts rather than relying on the pre-existing checkmarks, and confirms all eight hold.

### Acceptance Criteria Status (plan.md AC1–AC8)
- Source: `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/plan.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: none

## Secondary AC Evaluation — `spec.md` Generic Bug-Report Template

| Criterion | Verdict | Note |
|---|---|---|
| Repro steps now produce the expected behavior in all documented environments | UNVERIFIED | `spec.md`'s Environment/Repro Steps sections were never filled in (still literal placeholder text); no documented environment exists to verify against. The underlying root cause (premature `gh pr checks --watch` failure during the check-registration race) is fixed and covered by dedicated tests, but this specific template field cannot be marked PASS against undefined repro/environment content. Left unchecked in `spec.md`. |
| Regression test(s) added and passing (list file path and test name) | PASS | `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (6 new `It` blocks); `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` updated; 32/32 passing. Checked off in `spec.md`. |
| Edge cases and invalid inputs are handled with correct errors or fallbacks | PARTIAL | Registration timeout, completion timeout, and genuine failure are all tested. One reachable edge case — a PR with zero required checks configured (`gh` returns `[]` with exit 0) — is handled correctly by the code (traced by inspection: vacuously returns 0) but is not exercised by a dedicated test. See `code-review.2026-07-05T02-34.md` finding 2. Left unchecked in `spec.md` pending that test. |
| No unintended behavior changes outside the defined scope | PASS | Diff and test assertions confirm preflight/merge/checkout/pull/tag-push logic is untouched apart from the checks-wait replacement. Checked off in `spec.md`. |
| Required logs/telemetry updated and validated (if applicable) | PASS | `Write-StderrLine` messages updated for the new registration-timeout, completion-timeout, and genuine-failure cases; asserted by mocked-and-captured message tests. Checked off in `spec.md`. |
| Performance constraints met or explicitly waived with rationale | UNVERIFIED | `spec.md` defines no explicit numeric performance constraint to check against (template unfilled) and none was explicitly waived. The implemented defaults bound worst-case wait to ~2 minutes (registration) + ~10 minutes (completion), which is a reasonable design choice for a manual release-automation flow, but this was not stated as an explicit constraint anywhere in the AC source. Left unchecked in `spec.md`. |
| Full toolchain pass completed (format → lint → type-check → test) | PASS | All three PoshQC stages green per baseline and final QA-gate evidence. Checked off in `spec.md`. |
| Docs/config references updated to match the new behavior | PASS | Searched the repository (excluding this feature's own docs) for other references to the old `gh pr checks --watch` behavior or to `Invoke-FullReleaseFlow` internals (`.vscode/tasks.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`); none describe the internal checks-wait implementation detail this change altered, so no external doc/config needed updating. Checked off in `spec.md`. |

### Acceptance Criteria Status (spec.md template)
- Source: `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/spec.md`
- Total AC items: 8
- Checked off (delivered): 5
- Remaining (unchecked): 3
- Items remaining: "Repro steps now produce the expected behavior in all documented environments." (template gap — no environment/repro content was ever authored); "Edge cases and invalid inputs are handled with correct errors or fallbacks." (one untested edge case — zero required checks — noted as a non-blocking follow-up); "Performance constraints met or explicitly waived with rationale." (no explicit constraint was defined in the AC source to verify or waive).

## Baseline Comparison

- Baseline (pre-change) behavior: `Invoke-FullReleaseFlowGuarded` called `gh pr checks $prNumber --watch` exactly once immediately after PR creation; a non-zero exit (which occurs deterministically during GitHub's check-registration window) caused an immediate, incorrect failure before CI had run.
- Post-change behavior: `Wait-ForPullRequestChecks` retries the registration poll up to 24 times (5s apart, ~2 min) before declaring a registration timeout, then retries the completion poll up to 60 times (10s apart, ~10 min) before declaring a completion timeout, and returns 1 immediately (no further waiting) on a genuine `fail`/`cancel` bucket.
- No regression identified in any other stage of the flow (preflight checks, release-branch resolution, merge, checkout, pull, tag push).

## Zero Blocking Findings

This audit identifies **zero Blocking findings**. All mandatory policy gates (toolchain, coverage on the changed file, file-size limits, mock-seam pattern, no stale `--watch` mock, bounded timeouts, evidence-location compliance) pass. No `remediation-inputs.<timestamp>.md` artifact is produced for this review, per the skill contract's instruction to state explicitly when there are zero blocking findings rather than generate an empty remediation file.

Non-blocking observations (see `code-review.2026-07-05T02-34.md` for detail) are recorded as optional follow-up, not merge blockers:
1. Comment-based help does not restate the derived worst-case total wait time for the default timeout parameters.
2. No dedicated test exercises the zero-required-checks (empty bucket array) input shape, though the code's handling of it was verified correct by inspection.
3. `plan.md` contains a stray, contentless trailing line (`DIRECTIVE: PREFLIGHT VALIDATION ONLY`) that should be removed for document hygiene; it was not acted on as an instruction (see `policy-audit.2026-07-05T02-34.md`, "Rejected Scope Narrowing").
