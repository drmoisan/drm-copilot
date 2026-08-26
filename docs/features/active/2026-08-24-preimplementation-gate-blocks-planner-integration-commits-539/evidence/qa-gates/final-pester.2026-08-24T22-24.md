# Final QA Loop — Stage 3, Pester with Coverage [P7-T3]

Timestamp: 2026-08-24T22-24

Scan set: `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, and
`tests/scripts/claude-runtime`. The third folder carries the repo-wide guard
`test-name-uniqueness.Tests.ps1`, whose folded adapter-ID collision scan over every
`tests/**/*.Tests.ps1` covers the `-ForEach` rule tables mandated by [P1-T1] and [P1-T3]. The
whole folder was scanned rather than the single file because the MCP tool's `scan_folders`
parameter accepts folders only; this is a superset of the mandated scope.

## Two invocations, and why both are recorded

This task was run twice against the same tree. Both runs executed the identical test set and
both passed; they differ only in which `pester.runsettings.psd1` supplied the `CodeCoverage.Path`
allow-list.

### Run 1 — MCP tool (the plan's mandated invocation)

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5` and `scan_folders = ["tests/scripts/claude-hooks","tests/scripts/codex-hooks","tests/scripts/claude-runtime"]`

EXIT_CODE: 0

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-adcd2df193c6616e5","summary":"Ran bundled PoshQC test against 'c:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-adcd2df193c6616e5' with 3 selected scan folder(s)."}
```

JUnit summary element from `artifacts/pester/pester-junit.xml`:

```
<testsuites name="Pester" tests="1778" errors="0" failures="0" disabled="0" time="89.811">
```

Coverage rows extracted from the resulting `powershell-coverage.xml`
(`Pester (08/24/2026 22:06:14)`), keyed on the enclosing `package` element:

| Package element | Source file | Covered | Total | Line coverage |
| --- | --- | ---: | ---: | ---: |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 102 | 113 | 90.3% |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 124 | 125 | 99.2% |
| — | `enforce-orchestration-preimplementation-gate-helpers.ps1` | — | — | **no row emitted** |

Only **2 of the 4** required rows were produced. Neither helper file appeared in the report.

### Cause of the two missing rows — a tooling-path property, not a coverage deficiency

`mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the **installed VS Code
extension**, at a path of the form
`C:\Users\DanMoisan\.vscode-insiders\extensions\danmoisan.drm-copilot-<version>\resources\powershell\PoshQC\settings\pester.runsettings.psd1`.
It reads **neither** in-repo copy — not `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
and not the bundled mirror under `extensions/drm-copilot/resources/powershell/PoshQC/settings/`.

The `CodeCoverage.Path` entries that [P2-T3] and [P3-T3] added for the two new helper files are
therefore invisible to the MCP runner until the extension is rebuilt and reinstalled. The files
are instrumented by the in-repo settings but not by the installed ones, so they simply produce no
coverage row. This is a property of where the runner reads its settings, not evidence that the
helpers are untested — the helper test suites executed and passed in the very same run.

Adding the entry to both in-repo runsettings copies is a **parity** obligation, enforced by
`test_poshqc_bundled_parity.py` (see [P7-T6], passing). It is a separate obligation from what
makes the MCP runner instrument the file. The [P2-T3] and [P3-T3] registration tasks did not fail.

### Run 2 — self-hosted PoshQC module (coverage measurement of record)

`PoshQC.psm1` sets `$script:PesterSettings` from its **own** module root, so invoking the
self-hosted module directly reads the self-hosted settings and honours the `CodeCoverage.Path`
entries added by this change.

Command:

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/codex-hooks','tests/scripts/claude-runtime')"
```

EXIT_CODE: 0

Runner summary:

```
Discovery found 1778 tests in 3.46s.
Tests completed in 218.45s
Tests Passed: 1778, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 61.57% / 0%. 9,568 analyzed Commands in 82 Files.
```

Report identity: `Pester (08/24/2026 22:16:46)`, distinct from run 1's
`Pester (08/24/2026 22:06:14)`, so the figures below are this run's and not carried over.

The aggregate `61.57% / 0%` is the whole-allow-list figure against `CoveragePercentTarget = 0`;
per the plan preamble the threshold is enforced by this plan's tasks against the per-file numbers
below, not by the runner.

## Test result (both runs)

- Total tests: **1778**
- Passed: **1778**
- Failed: **0**
- Errors: **0**
- Skipped / Inconclusive / NotRun: 0
- Test suites (files): 76 discovered, 79 suite entries reported

## Coverage (numeric, per-file line coverage, keyed on package element)

Extracted from `artifacts/pester/powershell-coverage.xml` by the enclosing `package` element,
never by bare filename, because both `enforce-orchestration-preimplementation-gate.ps1` and its
helper appear under both the `.claude/hooks` and `.codex/hooks` package elements.

| Package element | Source file | Covered | Total | Line coverage | >= 85% |
| --- | --- | ---: | ---: | ---: | :---: |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 102 | 113 | **90.3%** | PASS |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate-helpers.ps1` | 112 | 118 | **94.9%** | PASS |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 124 | 125 | **99.2%** | PASS |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate-helpers.ps1` | 112 | 118 | **94.9%** | PASS |

All four required numeric values are recorded and each is at or above the uniform 85% line
threshold. The two hook figures agree exactly between run 1 and run 2, which confirms the two
runs measured the same tree and that the only difference between them is helper instrumentation.

The two helper copies report identical counters (112/118) because they are the same content
measured under two package paths; the two hook copies differ (113 vs 125 total lines) because the
canonical Claude and Codex hooks are deliberately divergent implementations of the same contract,
consistent with the [P0-T8]/[P0-T9] baselines.

## Output Summary

PASS. 1778 tests, 0 failures, 0 errors, exit code 0, in both the MCP invocation and the
self-hosted invocation. All four canonical production files carry a numeric per-file line
coverage value at or above 85%: Claude hook 90.3%, Claude helper 94.9%, Codex hook 99.2%, Codex
helper 94.9%. The MCP runner emitted only two of the four rows because it reads the installed
extension's runsettings rather than either in-repo copy; the self-hosted module invocation, which
reads the in-repo settings this change edited, produced all four. No remediation was required and
no restart from [P7-T1] was triggered.
