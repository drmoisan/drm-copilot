# PowerShell Test Baseline — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P0-T8]
HEAD: `bcf2de15`
Host: MEGALODON4, Microsoft Windows 11 Pro 10.0.26200

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
(no `scan_folders` argument; the scan set resolves from `config/poshqc-scan.json` `test.scanFolders`)

EXIT_CODE: 1

Supplementary Command (see `## Coverage-Denominator Divergence` below for why it was necessary):
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

Supplementary EXIT_CODE: 1 (same single pre-existing failure)

## Output Summary

- Pester counts, identical in both invocations: **2090 tests, 2080 passed, 1 failed, 0 errored,
  9 skipped**, wall time 100.9s (MCP) / 102.66s (repo-root). This reproduces the plan's absolute
  suite-outcome floor exactly: **2080 passed / 1 failed / 9 skipped**. No discrepancy on test
  outcome.
- Report-level coverage, from the repo-root invocation's JaCoCo report
  (`artifacts/pester/powershell-coverage.xml`), which measures the full 47-file denominator the
  repository's `CodeCoverage.Path` declares:
  - **LINE coverage = 94.96% (3714 covered, 197 missed, 3911 total)**
  - **INSTRUCTION coverage = 94.60% (5081 covered, 290 missed, 5371 total)**
  - METHOD 91.98% (298/324), CLASS 95.74% (45/47) — informational.
- **Per-file LINE coverage of `.claude/hooks/enforce-parallel-drift-gate.ps1` = 96.53%
  (139 covered, 5 missed, 144 total)**; its INSTRUCTION coverage is 96.57% (197 covered, 7 missed,
  204 total). Both reproduce the plan's benchmark figure exactly.
- **No `BRANCH` counter is emitted.** Verified below.
- Observed failures: exactly one, and it is one of the two named pre-existing suites.

## Branch-Counter Absence (verification of a negative claim)

SearchScope: `artifacts/pester/powershell-coverage.xml` (the JaCoCo report emitted by this baseline
run).
SearchPatterns: enumeration of every distinct `counter` element `type` attribute in the whole report.
SearchResult: exactly four counter types exist — `CLASS`, `INSTRUCTION`, `LINE`, `METHOD`. There is
**no `BRANCH` counter anywhere in the report**, at report level, package level, class level, or
sourcefile level.

Conclusion: Pester v5 and the PoshQC conversion step do not emit a branch metric for PowerShell, so
no PowerShell branch-coverage figure exists to record and none was invented. INSTRUCTION coverage is
the recorded analogue. This reproduces the identical negative result recorded at the original Phase 0
baseline and is finding F8-I2 — a toolchain measurement limitation, not a threshold waiver.

## Observed Failures, Named, With Pre-Existing Comparison

Exactly one failure was observed, in both invocations:

- File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Test: `allowed commands / allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`,
  `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`; expected `'allow'`,
  observed `'deny'`.
- Root cause: the suite exercises `.claude/hooks/enforce-pr-author-skill.ps1`, which reads the real
  gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so it fails
  whenever an orchestrated run is live — as one is during this capture.

Comparison against the two named pre-existing suites:

| Suite | Status at this baseline | Disposition |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | **1 failure**, the test above, same assertion and same line 142 as the original Phase 0 baseline (`evidence/baseline/powershell-test-baseline.2026-08-08T20-59.md`) and the post-implementation final QC (`evidence/qa-gates/powershell-test-final.2026-08-08T23-24.md`) | Pre-existing and out of scope. Recorded as F8-I3. This file must not be edited, and the hook must not be edited to force a green gate. The entire non-zero exit code of this stage is attributable to it. |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | **0 failures** in this run | Shares the same unmocked real-checkpoint dependency and is equally environment-dependent. Recorded as known-fragile and out of scope so a future failure from it is attributed correctly rather than read as a regression. |

No other suite failed. The failed count is therefore **1**, matching the floor.

## Coverage-Denominator Divergence (recorded, pre-existing, not caused by this cycle)

The MCP invocation and the repo-root invocation produced **identical test outcomes** but **different
coverage denominators**: the MCP run measured **41** source files, the repo-root run measured **47**.
The six files present in the repository's `CodeCoverage.Path` but absent from the MCP run's report are
the five `.claude/lib/blast-radius/*.psm1` modules (added by issue #447) and
`.claude/hooks/enforce-parallel-drift-gate.ps1` (added by issue #446).

Cause, verified by reading the invocation path: `mcp__drm-copilot__run_poshqc_test` executes the
bundled template `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`, which imports
PoshQC from `$PSScriptRoot/../powershell/PoshQC/PoshQC.psd1` — the **installed extension's** bundled
resources, not this worktree's. `Invoke-PoshQCTest`'s `$SettingsPath` defaults to
`$script:PesterSettings`, resolved relative to the imported module, so the MCP run reads the installed
bundle's `pester.runsettings.psd1`, which predates the issue #447 and issue #446
`CodeCoverage.Path` entries. Both suites did execute under the MCP run (the JUnit report contains 60
`enforce-parallel-drift-gate` test cases and 329 `BlastRadius` test cases), so the omission is a
coverage-denominator effect only, not a missing test run.

Corroboration that this is pre-existing and not introduced by this cycle: the original Phase 0
baseline artifact records the same 41-file report-level counters (LINE 3148/3337, INSTRUCTION
4316/4594), while the post-implementation final QC records the 47-file counters. The worktree's own
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` are
byte-identical (SHA-256 `3ebf24c925dd242235a7c909d74d6e573e3caf95af0a46f3d94ca7f537b6caab`) and both
list all six files, so the repository sources are correct and no repository fix is implied.

Disposition: the MCP invocation remains the mandated command and is recorded as such with its
`EXIT_CODE: 1`. The repo-root invocation is recorded as a supplementary measurement whose only
purpose is to obtain the per-file figures against the repository's declared denominator, which the
plan's acceptance criteria require. It uses the repository's own PoshQC module and the repository's
own runsettings — the configuration `.claude/rules/powershell.md` names — and changes no assertion,
no test, and no threshold. It is reported as a newly discovered environmental finding rather than
fixed inside this cycle.

## Raw Output

MCP tool result:

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a16d115637b38dd44",
  "summary": "Command exited with code 1."
}
```

JUnit root element (`artifacts/pester/pester-junit.xml`):

```xml
<testsuites name="Pester" tests="2090" errors="0" failures="1" disabled="9" time="100.933">
```

Repo-root invocation tail:

```
Tests completed in 102.66s
Tests Passed: 2080, Failed: 1, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 94.6% / 0%. 5,371 analyzed Commands in 47 Files.
```

JaCoCo report-level counters (`artifacts/pester/powershell-coverage.xml`, 47-file denominator):

```xml
<counter type="INSTRUCTION" missed="290" covered="5081" />
<counter type="LINE" missed="197" covered="3714" />
<counter type="METHOD" missed="26" covered="298" />
<counter type="CLASS" missed="2" covered="45" />
```

Per-file counters for the Layer-1 hook:

```
enforce-parallel-drift-gate.ps1   LINE 139/144=96.53%  INSTRUCTION 197/204=96.57%
                                  METHOD 15/15=100.00%  CLASS 1/1=100.00%
```
