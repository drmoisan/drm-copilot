# Phase 0 Python-Free Enforcement Guard Baseline — Issue #673 ([P0-T9])

Timestamp: 2026-09-17T10-38

Command: sh "C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p0t9.sh"
(route a-prime per `execution-route.md`). The PowerShell body:
```
Set-Location -LiteralPath 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe'
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe' -ScanFolders tests/scripts/claude-runtime -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

EXIT_CODE: 0

Output Summary:

The located structural guard suite for issue #475 is
`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (500 lines; no headroom).
Its two scan roots are `.claude/hooks` and `.claude/lib`, assigned to `$script:ScanRoot` at that file's
`:39-42` and enumerated recursively at `:60` (`Get-ChildItem -Path $root -Recurse -File`), which is why it
already covers all four in-scope hook files and needs no extension. Detection logic lives in the sibling
`EnforcementHooksNoPythonInvocation.Helpers.ps1`.

Read from `artifacts/pester/pester-junit.xml` immediately after this task's own run:

- Report last-write time: 2026-09-17T10:39:04 (at or after this artifact's Timestamp)
- Scoped run root totals: tests=64, failures=0, disabled=0 across 6 `testsuite` elements
- `testsuite` whose `name` attribute ends with `enforcement-hooks-no-python-invocation.Tests.ps1`
  (name: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a4da10d770a658efe\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1`):
  - `tests` = 27
  - `failures` = 0
  - `skipped` = 0
  - `disabled` = 0
  - passed (derived as `tests` - `failures` - `skipped` - `disabled`) = **27**

`testcase` elements under that `testsuite`, verbatim `name` and `status`:

```
Passed  enforcement hooks must not invoke Python.allowlist policy.ships an empty allowlist
Passed  enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects a bare python invocation
Passed  enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects an ampersand-invoked python invocation
Passed  enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects a dot-invoked python invocation
Passed  enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects a quoted python constant invocation
Passed  enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects python3, py, and poetry as interpreter commands
Passed  enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects an interpreter name written in mixed case
Passed  enforcement hooks must not invoke Python.detection class 2 - subprocess start targeting an interpreter.detects a subprocess start whose FilePath is an interpreter
Passed  enforcement hooks must not invoke Python.detection class 2 - subprocess start targeting an interpreter.detects a subprocess start whose first positional argument is an interpreter
Passed  enforcement hooks must not invoke Python.detection class 2 - subprocess start targeting an interpreter.reports no finding for a subprocess start targeting an unrelated executable
Passed  enforcement hooks must not invoke Python.detection class 3 - dynamic invocation fail-closed.detects an ampersand-invoked variable that is not a scriptblock parameter
Passed  enforcement hooks must not invoke Python.detection class 3 - dynamic invocation fail-closed.detects an ampersand-invoked expression in the command position
Passed  enforcement hooks must not invoke Python.detection class 4 - arbitrary text execution.detects an Invoke-Expression call
Passed  enforcement hooks must not invoke Python.detection class 4 - arbitrary text execution.detects the built-in alias of Invoke-Expression
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for interpreter names inside string literals
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for interpreter names inside comments
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for function names beginning with Invoke-Python
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for a scriptblock-parameter seam invocation
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding when a seam variable differs from its parameter by letter case
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for dot-sourcing a sibling helper path variable
Passed  enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for dot-sourcing an inline sibling helper path
Passed  enforcement hooks must not invoke Python.carve-out boundaries - the inline sibling-load exemption stays tight.still reports a dot-sourced expression that is not a Join-Path call
Passed  enforcement hooks must not invoke Python.carve-out boundaries - the inline sibling-load exemption stays tight.still reports a Join-Path load that does not resolve a ps1 sibling
Passed  enforcement hooks must not invoke Python.carve-out boundaries - the inline sibling-load exemption stays tight.still reports an ampersand-invoked inline sibling-load expression
Passed  enforcement hooks must not invoke Python.repository scan.enumerates only the two guarded roots and never the bundled mirror
Passed  enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree
Passed  enforcement hooks must not invoke Python.repository scan.carries no stale allowlist entry
```

Console tail of the scoped run: `Tests Passed: 64, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`.

Note: this scoped run overwrote `artifacts/pester/powershell-coverage.xml` with a report showing 0% for the
four hooks, which is expected for a run that executes only `tests/scripts/claude-runtime`. The coverage
figures for [P0-T7] were read from that file immediately after [P0-T7]'s own full-suite run, before this run.
