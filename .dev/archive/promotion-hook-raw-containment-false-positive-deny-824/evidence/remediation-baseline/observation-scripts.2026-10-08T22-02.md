# Observation Scripts (Remediation Cycle 1)

Timestamp: 2026-10-08T22-02
Location: `<SCRATCHPAD>/` (session scratchpad; launched with `sh <SCRATCHPAD>/<name>.sh` from the worktree root)
Output Summary: eight blocks follow (four scripts, four launchers), copied verbatim from the files launched.

## s-merge-check.ps1

```powershell
$ErrorActionPreference = 'Continue'
$root = (Get-Location).Path
$claudeRel = 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
$codexRel = 'extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json'
$legacyRel = 'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1'
$expectedNames = @('codex-pretooluse-file-mapping.ps1', 'enforce-orchestration-preimplementation-gate-helpers.ps1', 'hook-command-scanner.ps1', 'hook-command-invocation.ps1', 'enforce-batch-budget-route.ps1', 'feature-folder-resolution.ps1', 'hook-command-heredoc.ps1', 'hook-command-payload.ps1', 'hook-command-payload-powershell.ps1', 'hook-command-invocation-operands.ps1')
$pass = $true

function Get-ManifestResult {
    param([string]$RelativePath)
    $result = [ordered]@{ Ok = $false; Paths = @() }
    try {
        $raw = Get-Content -Raw -LiteralPath (Join-Path $root $RelativePath) -ErrorAction Stop
        $json = $raw | ConvertFrom-Json -ErrorAction Stop
        $result.Ok = $true
        $result.Paths = @($json.paths)
    }
    catch {
        $result.Ok = $false
    }
    return $result
}

function Write-ManifestSummary {
    param([string]$RelativePath, $Result)
    if ($Result.Ok) {
        Write-Output "MANIFEST_PARSE $RelativePath OK"
        $counts = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
        foreach ($entry in $Result.Paths) {
            if ($counts.ContainsKey($entry)) { $counts[$entry]++ } else { $counts[$entry] = 1 }
        }
        $dups = @($counts.Keys | Where-Object { $counts[$_] -gt 1 })
        Write-Output "MANIFEST $RelativePath paths=$($Result.Paths.Count) duplicates=$($dups.Count)"
        foreach ($d in $dups) { Write-Output "DUPLICATE $d" }
        $script:LastDuplicateCount = $dups.Count
        return
    }
    Write-Output "MANIFEST_PARSE $RelativePath FAIL"
    Write-Output "MANIFEST $RelativePath paths=-1 duplicates=-1"
    $script:LastDuplicateCount = -1
}

$claude = Get-ManifestResult -RelativePath $claudeRel
Write-ManifestSummary -RelativePath $claudeRel -Result $claude
if (-not $claude.Ok -or $script:LastDuplicateCount -ne 0) { $pass = $false }
$i = -1
$j = -1
if ($claude.Ok) {
    $i = [array]::IndexOf([string[]]$claude.Paths, '.claude/hooks/feature-folder-resolution.ps1')
    $j = [array]::IndexOf([string[]]$claude.Paths, '.claude/hooks/hook-command-heredoc.ps1')
}
Write-Output "ORDER feature-folder-resolution=$i hook-command-heredoc=$j"
if (-not ($i -ge 0 -and $j -eq ($i + 1))) { $pass = $false }

$codex = Get-ManifestResult -RelativePath $codexRel
Write-ManifestSummary -RelativePath $codexRel -Result $codex
if (-not $codex.Ok -or $script:LastDuplicateCount -ne 0) { $pass = $false }
foreach ($entry in @('.codex/hooks/feature-folder-resolution.ps1', '.codex/hooks/hook-command-heredoc.ps1')) {
    $present = $codex.Ok -and ([array]::IndexOf([string[]]$codex.Paths, $entry) -ge 0)
    if ($present) { Write-Output "CODEX_ENTRY $entry PRESENT" } else { Write-Output "CODEX_ENTRY $entry ABSENT"; $pass = $false }
}

$legacyLines = @()
try { $legacyLines = @(Get-Content -LiteralPath (Join-Path $root $legacyRel) -ErrorAction Stop) } catch { $pass = $false }
$sharedLines = @($legacyLines | Where-Object { $_ -match '^\s*\$script:SharedModuleNames = @\(' })
Write-Output "SHARED_MODULE_LINES: $($sharedLines.Count)"
$names = @()
if ($sharedLines.Count -gt 0) {
    $names = @([regex]::Matches($sharedLines[0], "'([^']+)'") | ForEach-Object { $_.Groups[1].Value })
}
$uniqueNames = @($names | Sort-Object -Unique -CaseSensitive)
$nameDups = $names.Count - $uniqueNames.Count
Write-Output "SHARED_MODULE_COUNT: $($names.Count)"
Write-Output "SHARED_MODULE_DUPLICATES: $nameDups"
$missingCount = 0
foreach ($n in $expectedNames) {
    if ($names -cnotcontains $n) { Write-Output "SHARED_MODULE_MISSING: $n"; $missingCount++ }
}
Write-Output "LEGACY_LINES: $($legacyLines.Count)"
if ($sharedLines.Count -ne 1 -or $names.Count -ne 10 -or $nameDups -ne 0 -or $missingCount -ne 0 -or $legacyLines.Count -gt 500) { $pass = $false }

$markerCount = 0
foreach ($rel in @($claudeRel, $codexRel, $legacyRel)) {
    $lines = @()
    try { $lines = @(Get-Content -LiteralPath (Join-Path $root $rel) -ErrorAction Stop) } catch { $pass = $false }
    for ($k = 0; $k -lt $lines.Count; $k++) {
        if ($lines[$k] -match '^(<<<<<<<|=======|>>>>>>>)( |$)') {
            Write-Output "CONFLICT_MARKER ${rel}:$($k + 1)"
            $markerCount++
        }
    }
}
Write-Output "CONFLICT_MARKER_COUNT: $markerCount"
if ($markerCount -ne 0) { $pass = $false }

if ($pass) {
    Write-Output 'MERGE_CHECK: PASS'
    exit 0
}
Write-Output 'MERGE_CHECK: FAIL'
exit 1
```

## s-merge-check.sh

```sh
exec pwsh -NoProfile -File "$(dirname "$0")/s-merge-check.ps1" "$@"
```

## s-fmt-legacy.ps1

```powershell
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$rel = 'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1'
Import-Module PSScriptAnalyzer
$content = (Get-Content -Raw -LiteralPath (Join-Path $root $rel)) -replace "`r`n", "`n"
$settings = Join-Path $root 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$formatted = Invoke-Formatter -ScriptDefinition $content -Settings $settings
$drift = 0
if ($formatted -cne $content) {
    $drift = 1
    Write-Output "FORMAT_DRIFT $rel"
}
else {
    Write-Output "FORMAT_CLEAN $rel"
}
Write-Output "FORMAT_DRIFT_COUNT: $drift"
if ($drift -gt 0) { exit 1 }
exit 0
```

## s-fmt-legacy.sh

```sh
exec pwsh -NoProfile -File "$(dirname "$0")/s-fmt-legacy.ps1" "$@"
```

## s-pssa-legacy.ps1

```powershell
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$rel = 'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1'
Import-Module PSScriptAnalyzer
$settings = Join-Path $root 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$findings = @(Invoke-ScriptAnalyzer -Path (Join-Path $root $rel) -Settings $settings -Severity Error, Warning, Information)
foreach ($f in $findings) {
    Write-Output "PSSA ${rel}:$($f.Line) $($f.RuleName)"
}
Write-Output "PSSA_FINDING_COUNT: $($findings.Count)"
if ($findings.Count -gt 0) { exit 1 }
exit 0
```

## s-pssa-legacy.sh

```sh
exec pwsh -NoProfile -File "$(dirname "$0")/s-pssa-legacy.ps1" "$@"
```

## s-qc-pester.ps1

```powershell
param([string]$Mode = '')
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$ffr = @('tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1', 'tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1')
$qc = @(
    'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1',
    'tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1',
    'tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-payload.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1',
    'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1',
    'tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1',
    'tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1',
    'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1'
)
if ($Mode -eq 'baseline') {
    $set = @($qc | Where-Object { $ffr -notcontains $_ })
}
else {
    $set = $qc
}
Write-Output "QC_SET_SIZE: $($set.Count)"
$missing = @($set | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) })
foreach ($m in $missing) { Write-Output "QC_MISSING_FILE: $m" }
if ($missing.Count -gt 0) { exit 1 }

Import-Module Pester -MinimumVersion 5.0
$config = New-PesterConfiguration
$config.Run.Path = @($set | ForEach-Object { Join-Path $root $_ })
$config.Run.PassThru = $true
$config.Run.Exit = $false
$config.Output.Verbosity = 'Normal'
$config.CodeCoverage.Enabled = $false
$result = Invoke-Pester -Configuration $config

$failedBlocks = @($result.FailedBlocks).Count
$failedContainers = @($result.FailedContainers).Count
Write-Output "PESTER_TOTAL: $($result.TotalCount)"
Write-Output "PESTER_PASSED: $($result.PassedCount)"
Write-Output "PESTER_FAILED: $($result.FailedCount)"
Write-Output "PESTER_SKIPPED: $($result.SkippedCount)"
Write-Output "PESTER_FAILED_BLOCKS: $failedBlocks"
Write-Output "PESTER_FAILED_CONTAINERS: $failedContainers"
$prefix = $root.TrimEnd('\', '/')
foreach ($c in $result.Containers) {
    $path = [string]$c.Item
    if ($path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $path = $path.Substring($prefix.Length).TrimStart('\', '/')
    }
    $path = $path -replace '\\', '/'
    Write-Output "FILE_RESULT $path passed=$($c.PassedCount) failed=$($c.FailedCount)"
}
foreach ($t in $result.Failed) {
    Write-Output "FAILED_TEST: $($t.ExpandedPath)"
}
if ($result.FailedCount -gt 0 -or $failedBlocks -gt 0 -or $failedContainers -gt 0) { exit 1 }
exit 0
```

## s-qc-pester.sh

```sh
pwsh -NoProfile -File "$(dirname "$0")/s-qc-pester.ps1" "$@"
code=$?
echo "QC_PESTER_EXIT_CODE: $code"
exit $code
```
