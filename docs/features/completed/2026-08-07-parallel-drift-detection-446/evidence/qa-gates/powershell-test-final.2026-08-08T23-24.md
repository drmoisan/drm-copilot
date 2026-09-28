# PowerShell Tests and Coverage — Final QC ([P7-T7])

- Feature: `2026-08-07-parallel-drift-detection-446` (issue #446)
- Task: `[P7-T7]`
- Language loop: PowerShell, stage 3 of 3 (test, coverage-enabled)
- Host: Microsoft Windows 11 Pro 10.0.26200; Pester 5.6.1
- Pester wall time: 99.238s

Timestamp: 2026-08-08T23-24

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
(no `scan_folders` argument; the scan set is resolved from `config/poshqc-scan.json`
`test.scanFolders` = `["scripts", "tests/powershell", "tests/scripts"]`)

EXIT_CODE: 1

Output Summary:

Pester counts: **2090 tests, 2080 passed, 1 failed, 0 errored, 9 skipped**, wall time
99.238s. The non-zero exit code is caused by **exactly one pre-existing, environment-dependent
failure that predates this feature and is out of scope for it**:

> `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ->
> `allowed commands / allows gh pr create --body-file artifacts/pr_body_12.md when context exists`

That test asserts `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'` at
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`; it observed `'deny'`. The
root cause is that the suite exercises `.claude/hooks/enforce-pr-author-skill.ps1`, which reads
the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam,
so the assertion depends on live orchestration state and fails whenever an orchestrated run is
in flight — as one is during this capture. **It failed identically at the Phase 0 baseline.**
Neither that test file nor the hook it exercises was modified by this feature; forcing the gate
green by editing either would be an out-of-scope change and was not done. `EXIT_CODE: 1` is
recorded truthfully rather than as a false `0`.

All **59** test cases in the new suite
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` ([P5-T3]) passed; zero of
the run's failures come from this feature.

Post-change coverage for `.claude/hooks/enforce-parallel-drift-gate.ps1`:
**line coverage = 96.53% (139 covered, 5 missed, 144 total)**; INSTRUCTION coverage = 96.57%
(197 covered, 7 missed, 204 total). **Branch coverage is not emitted by the PowerShell
toolchain** — see "Branch-Coverage Availability" below, which carries the same documented
limitation and search evidence as the Phase 0 baseline artifact. Line coverage exceeds the
uniform policy threshold (>= 85%).

## Pass/Fail/Skip Delta Versus Baseline

| Metric | Baseline (P0-T8) | Post-change (P7-T7) | Delta |
| --- | --- | --- | --- |
| Tests total | 2031 | 2090 | +59 |
| Passed | 2021 | 2080 | +59 |
| Failed | 1 | 1 | **0 (no additional failures)** |
| Errored | 0 | 0 | 0 |
| Skipped | 9 | 9 | 0 |
| Exit code | 1 | 1 | unchanged |

The `+59` test delta is exactly the 59 cases of the new
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` suite, and all 59 land in
the passed column. The failed count is unchanged at 1 and is the same named test in both runs.
**Zero additional failures were introduced by this feature.** This matches the Phase 5
measurement of 2080 passed / 1 failed / 9 skipped.

## Coverage-Configuration Discrepancy (stated plainly)

Two coverage configurations exist in this workspace and they do not agree on scope. Both were
executed; the number reported for each below is labeled with the configuration that produced it.

1. **Bundled MCP runsettings (what `mcp__drm-copilot__run_poshqc_test` uses).** The MCP server
   resolves the *installed extension's* bundled copy of the runsettings file, which is stale. Its
   `CodeCoverage.Path` list **omits `.claude/hooks/enforce-parallel-drift-gate.ps1` (this
   feature's new hook, appended by [P5-T4]) and omits F1's five `.claude/lib/blast-radius/*.psm1`
   blast-radius modules**. Its report therefore measures **41 source files** and contains zero
   occurrences of `enforce-parallel-drift-gate`. Its report-level counters are byte-identical to
   the Phase 0 baseline (LINE 3148 covered / 189 missed / 3337 total = 94.34%; INSTRUCTION 4316
   covered / 278 missed / 4594 total = 93.95%) precisely because the new hook is outside its
   denominator. **This configuration cannot produce the per-file number [P7-T7] requires.**

2. **Authoritative workspace runsettings
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.** Line 129 of that file carries
   `'.claude/hooks/enforce-parallel-drift-gate.ps1'` with the issue-#446 comment added by
   [P5-T4]. Running the same repository harness (`Invoke-PoshQCTest` from
   `scripts/powershell/PoshQC/PoshQC.psd1`, hosting Pester in the global session state) against
   this settings file measures **47 source files** — the 41 above plus the new hook plus F1's
   five blast-radius modules — and reports identical test counts (2090 tests, 2080 passed,
   1 failed, 9 skipped, wall time 100.390s), confirming the two configurations differ only in
   coverage scope, not in test outcome.

**The 96.53% hook line-coverage figure reported by this artifact was produced by configuration 2
(the authoritative workspace runsettings), not by configuration 1 (the bundled MCP runsettings).**
The MCP tool remains the command of record for the test result and exit code; the authoritative
workspace runsettings is the source of the coverage numbers. Reconciling the bundled extension
resource with the workspace runsettings is outside this feature's scope, and no [P5-T4] edit was
reverted or altered to accommodate the stale bundle.

## Per-File Coverage — New PowerShell Hook (authoritative workspace runsettings)

| Counter | Covered | Missed | Total | Percent | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| LINE (line coverage) | 139 | 5 | 144 | **96.53%** | >= 85% | meets |
| INSTRUCTION (branch analogue) | 197 | 7 | 204 | 96.57% | n/a | see note |
| METHOD | 15 | 0 | 15 | 100.00% | n/a | informational |
| CLASS | 1 | 0 | 1 | 100.00% | n/a | informational |
| BRANCH | not emitted | not emitted | not emitted | not emitted | >= 75% | not measurable by this toolchain |

The hook had no baseline coverage row: it did not exist at Phase 0 and was consequently absent
from the `CodeCoverage.Path` list, as the baseline artifact recorded. Its coverage delta is
therefore `absent -> 96.53%`.

The five uncovered lines are exactly the dot-source-guarded entrypoint block, which by design
cannot execute while the test suite dot-sources the file:

```
line 492:  $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT
line 494:  Write-Error $_
line 495:  exit 1
line 498:  $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
line 500:  exit 0
```

This is the thinnest possible host-bound wiring, and it is **not excluded** from measurement:
per `.claude/rules/general-unit-test.md` Coverage Exclusion Policy, the file remains in the
denominator and these five lines are visible as a real cost in the metric. All decision logic
sits in the dot-sourceable, fully-tested helper functions above line 486.

## Report-Level Coverage, Both Configurations

| Configuration | Files | LINE covered/missed/total | LINE % | INSTRUCTION covered/missed/total | INSTRUCTION % |
| --- | --- | --- | --- | --- | --- |
| Baseline (P0-T8) | 41 | 3148 / 189 / 3337 | 94.34% | 4316 / 278 / 4594 | 93.95% |
| Bundled MCP runsettings (this run) | 41 | 3148 / 189 / 3337 | 94.34% | 4316 / 278 / 4594 | 93.95% |
| Authoritative workspace runsettings (this run) | 47 | 3714 / 197 / 3911 | 94.96% | 5081 / 290 / 5371 | 94.60% |

The authoritative configuration's console summary reads
`Covered 94.6% / 0%. 5,371 analyzed Commands in 47 Files.` (the second figure is the configured
`CoveragePercentTarget = 0`, not a measurement). Report-level line coverage rises from 94.34% to
94.96% once the six previously-unmeasured production files enter the denominator, so widening the
scope did not regress the aggregate.

## Branch-Coverage Availability (verification of a negative claim)

Carried forward from the Phase 0 baseline artifact and re-verified against this run's own report.

SearchScope: `artifacts/pester/powershell-coverage.xml` (the JaCoCo report emitted by this run
under the authoritative `CodeCoverage.OutputPath`), plus
`scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` (the repository's coverage conversion
step).

SearchPatterns: `type="[A-Z]*"` counter-type enumeration over the coverage report; a
case-insensitive `branch` search over the conversion script.

SearchResult: The report contains exactly four counter types and **no BRANCH counter**:
`103 type="CLASS"`, `427 type="INSTRUCTION"`, `427 type="LINE"`, `427 type="METHOD"`. The
conversion script contains **zero** occurrences of `branch`.

Conclusion: Pester v5 does not measure branch coverage for PowerShell, and the repository's
PoshQC pipeline emits no branch metric. The branch-coverage figure is unavailable **from the
toolchain**, not unrecorded by choice. INSTRUCTION coverage (96.57% for the hook) is recorded as
the finest-grained numeric metric the toolchain does produce and is the nearest analogue. **This
is a measurement limitation of the toolchain, not a policy waiver**: the uniform branch threshold
(>= 75%) remains in force wherever it is measurable. No branch number was invented for the
PowerShell surface.

## Raw Output

MCP tool result (command of record):

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a16d115637b38dd44",
  "summary": "Command exited with code 1."
}
```

JUnit root element from the MCP run (`artifacts/pester/pester-junit.xml`):

```xml
<testsuites name="Pester" tests="2090" errors="0" failures="1" disabled="9" time="99.238">
```

The single failing test case (identical in both configurations):

```xml
<testcase name="enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists" status="Failed" classname="...\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1" time="0.055">
  <failure message="Expected strings to be the same, but they were different.
Expected length: 5
Actual length:   4
Strings differ at index 0.
Expected: 'allow'
But was:  'deny'">at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:142</failure>
</testcase>
```

Authoritative-runsettings run summary:

```
SETTINGS_PATH: ...\scripts\powershell\PoshQC\settings\pester.runsettings.psd1
Tests completed in 100.39s
Tests Passed: 2080, Failed: 1, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 94.6% / 0%. 5,371 analyzed Commands in 47 Files.
```

Hook `sourcefile` counters from the authoritative report:

```xml
<sourcefile name="enforce-parallel-drift-gate.ps1">
  <counter type="INSTRUCTION" missed="7" covered="197" />
  <counter type="LINE" missed="5" covered="139" />
  <counter type="METHOD" missed="0" covered="15" />
  <counter type="CLASS" missed="0" covered="1" />
</sourcefile>
```
