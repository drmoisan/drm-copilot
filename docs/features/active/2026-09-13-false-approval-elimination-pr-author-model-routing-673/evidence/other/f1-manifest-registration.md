# F1 Push-Down Registration and Manifest Test — Issue #673 [P2-T2]

Timestamp: 2026-09-17T11-37

Command: `sh "C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p2t2.sh"`
(route a-prime per `evidence/baseline/execution-route.md`). The PowerShell body invoked by that script:

```
Set-Location -LiteralPath 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe'
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe' -ScanFolders 'tests/scripts/claude-lib' -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
```

EXIT_CODE: 0

Output Summary: Both F1 module paths appear **exactly once** each in the `paths` array of
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (the array opens at
`core.json:4`; the two entries are at `core.json:167` and `core.json:168`). F1's manifest suite
`tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` exists and was run
out of process. Read from `artifacts/pester/pester-junit.xml` immediately after this task's own run: the
report's last-write time is **2026-09-17T11:38:16**, which is at or after this artifact's `Timestamp:`
of 2026-09-17T11-37. The `testsuite` element whose `name` attribute ends with
`WorktreeResolution.Manifest.Tests.ps1` records `tests=7`, `failures=0`, `skipped=0`, `disabled=0`, so
the derived passed count is **7**. All seven `testcase` elements carry `status="Passed"`. The console
line for the whole `tests/scripts/claude-lib` scan read `Tests Passed: 1490, Failed: 0, Skipped: 0,
Inconclusive: 0, NotRun: 0`.

## `core.json` occurrence counts

| module path | occurrence count in `core.json` | line |
| --- | --- | --- |
| `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | 1 | `core.json:168` |
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | 1 | `core.json:167` |

Commands:

```
grep -c "worktree-resolution/WorktreeTargetResolution.psm1" extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
1
grep -c "worktree-resolution/WorktreeResolution.psm1" extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
1
```

Surrounding `core.json` lines, confirming both entries sit inside the `paths` array that opens at
`core.json:4`:

```
    ".claude/lib/mermaid/MermaidValidation.psm1",
    ".claude/lib/worktree-resolution/WorktreeResolution.psm1",
    ".claude/lib/worktree-resolution/WorktreeTargetResolution.psm1",
    ".claude/skills/mermaid-diagram/references/flowchart.md",
```

## Manifest test file

- Path: `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`
- Base filename used for the `testsuite` ends-with match: `WorktreeResolution.Manifest.Tests.ps1`

## JUnit report values, read from `artifacts/pester/pester-junit.xml`

- Report last-write time: `2026-09-17T11:38:16`
- Matching `testsuite` element count: 1
- `testsuite` `name` attribute (absolute, backslash-separated container path):
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a4da10d770a658efe\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1`
- `tests` = 7
- `failures` = 0
- `skipped` = 0
- `disabled` = 0
- passed, derived as `tests` minus `failures` minus `skipped` minus `disabled` = **7**

`testcase` elements under that `testsuite`, `name` and `status` verbatim:

```
name=WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 in core.json paths | status=Passed
name=WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 in core.json paths | status=Passed
name=WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 exactly once | status=Passed
name=WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 exactly once | status=Passed
name=WorktreeResolution core.json manifest membership.registers every on-disk worktree-resolution module so none is unregistered | status=Passed
name=WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeResolution.psm1 byte-identically into the bundle | status=Passed
name=WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 byte-identically into the bundle | status=Passed
```

Reader command used to extract the values above (route a-prime,
`.../scratchpad/f673-exec/p2t2read.sh`, which runs `p2t2read.ps1`):

```
[xml]$doc = Get-Content -LiteralPath 'artifacts/pester/pester-junit.xml' -Raw
$suite = $doc.testsuites.testsuite | Where-Object { $_.name -like '*WorktreeResolution.Manifest.Tests.ps1' }
```
