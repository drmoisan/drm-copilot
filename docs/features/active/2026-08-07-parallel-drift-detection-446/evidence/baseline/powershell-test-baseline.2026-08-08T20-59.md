# Baseline — PowerShell Tests and Coverage (PoshQC / Pester v5)

Timestamp: 2026-08-08T20-59

Task: [P0-T8]
Feature: 2026-08-07-parallel-drift-detection-446 (issue #446)
Branch: feature/parallel-drift-detection-446
Integration head at execution: c939b5b8
Host: MEGALODON4, Microsoft Windows 11 Pro 10.0.26200
Run started: 2026-08-08 21:06:55 local; Pester wall time 102.376s

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
(no `scan_folders` argument; the scan set is resolved from `config/poshqc-scan.json`
`test.scanFolders` = `["scripts", "tests/powershell", "tests/scripts"]`)

EXIT_CODE: 1

Output Summary: FAIL (1 pre-existing failure, not caused by this feature). Pester counts:
**2031 tests, 2021 passed, 1 failed, 0 errored, 9 skipped**, wall time 102.376s. Numeric
baseline coverage headline values from the run's own JaCoCo report
(`artifacts/pester/powershell-coverage.xml`, report-level counters):
**line coverage = 94.34% (3148 covered, 189 missed, 3337 total)**; **branch coverage = not
emitted by the toolchain — the nearest numeric analogue Pester produces is INSTRUCTION
coverage = 93.95% (4316 covered, 278 missed, 4594 total)**. See "Branch-Coverage
Availability" below for the verification that no BRANCH counter exists in the PowerShell
toolchain output. Line coverage meets the uniform policy threshold (>= 85%).

The single failure is a **pre-existing baseline failure that is explicitly out of scope for
this feature and must not be fixed here**:
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ->
`allowed commands / allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
(expected `allow`, actual `deny`, at line 142). Root cause: the suite exercises
`.claude/hooks/enforce-pr-author-skill.ps1`, which reads the real gitignored
`artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so the assertion
depends on live orchestration state and fails whenever an orchestrated run is in flight — as
it is during this baseline capture. The second suite named as fragile for the same reason,
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, shares that unmocked
real-checkpoint dependency and is equally out of scope; in this particular run it passed all
6 of its tests, so it is recorded here as a known-fragile, out-of-scope suite rather than as
an observed baseline failure. Neither suite, and no other existing test or production file,
was modified during Phase 0.

## Numeric Coverage Detail (report-level JaCoCo counters)

| Counter | Covered | Missed | Total | Percent | Policy threshold | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| LINE (line coverage) | 3148 | 189 | 3337 | 94.34% | >= 85% | meets |
| INSTRUCTION (branch analogue) | 4316 | 278 | 4594 | 93.95% | n/a | see note |
| METHOD | 240 | 26 | 266 | 90.23% | n/a | informational |
| CLASS | 39 | 2 | 41 | 95.12% | n/a | informational |
| BRANCH | not emitted | not emitted | not emitted | not emitted | >= 75% | not measurable by this toolchain |

## Branch-Coverage Availability (verification of a negative claim)

SearchScope: `artifacts/pester/powershell-coverage.xml` (the JaCoCo report emitted by this
baseline run, per `CodeCoverage.OutputPath` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), plus
`scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` (the repository's coverage conversion
step) and the repo-root `coverage.xml`.

SearchPatterns: `type="[A-Z]*"` counter-type enumeration over the coverage report; a
case-insensitive `branch` search over the conversion script.

SearchResult: The coverage report contains exactly four counter types and no BRANCH counter:
`90 type="CLASS"`, `356 type="INSTRUCTION"`, `356 type="LINE"`, `356 type="METHOD"`. The
conversion script contains zero occurrences of `branch`. The repo-root `coverage.xml` is a
stale JaCoCo report dated `Pester (07/10/2026 22:16:37)` that this run did not regenerate
(unchanged mtime `2026-08-08 20:54:15`, predating this run) and it likewise carries no BRANCH
counter.

Conclusion: Pester v5 does not measure branch coverage for PowerShell, and the repository's
PoshQC pipeline emits no branch metric. The branch-coverage figure is therefore unavailable
from the toolchain rather than unrecorded by choice. INSTRUCTION coverage (93.95%) is recorded
as the finest-grained numeric metric the toolchain does produce and is the value the Phase 7
coverage-delta task should compare against for the PowerShell surface. This is a measurement
limitation of the toolchain, not a policy waiver: the uniform branch threshold (>= 75%)
remains in force wherever it is measurable.

## Files In This Feature's Production Scope (baseline state)

The PowerShell production file this feature will add does not exist at baseline and therefore
has no baseline coverage row:

- `.claude/hooks/enforce-parallel-drift-gate.ps1` — absent at baseline, and consequently absent
  from the `CodeCoverage.Path` list in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Plan task [P5-T4] appends it to
  that list so it enters the coverage denominator.

## Pre-Existing Failures Recorded (out of scope; NOT to be fixed by this feature)

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — 46 tests, 1 failure.
   Failing test: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
   Assertion: `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'` at
   `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`; expected `'allow'`,
   actual `'deny'`. Cause: unmocked read of the real gitignored
   `artifacts/orchestration/orchestrator-state.json`. Status: pre-existing, environment-dependent,
   out of scope.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — 6 tests, 0 failures in
   this run. Shares the same unmocked real-checkpoint dependency and fails whenever an
   orchestrated run is live. Status: pre-existing fragility, out of scope; passed at this
   baseline capture.

Phase 7's final-QC PowerShell test task is expected to reproduce the same environment-dependent
failure in item 1 while the orchestrated run remains live. That residual failure is baseline
noise and must be reported against this artifact, not treated as a regression introduced by
this feature.

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
<testsuites name="Pester" tests="2031" errors="0" failures="1" disabled="9" time="102.376">
```

Failing test case:

```xml
<testcase name="enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists" status="Failed" ...>
  <failure message="Expected strings to be the same, but they were different.
Expected length: 5
Actual length:   4
Strings differ at index 0.
Expected: 'allow'
But was:  'deny'">at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:142</failure>
</testcase>
```

JaCoCo report-level counters (`artifacts/pester/powershell-coverage.xml`):

```xml
<counter type="INSTRUCTION" missed="278" covered="4316" />
<counter type="LINE" missed="189" covered="3148" />
<counter type="METHOD" missed="26" covered="240" />
<counter type="CLASS" missed="2" covered="39" />
```
