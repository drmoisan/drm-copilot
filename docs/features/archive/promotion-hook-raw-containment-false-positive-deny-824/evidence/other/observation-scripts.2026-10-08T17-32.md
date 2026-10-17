# Observation Scripts (plan section 6)

Timestamp: 2026-10-08T17-32

Each script lives at `<SCRATCHPAD>/<name>.ps1` with a one-line launcher `<SCRATCHPAD>/<name>.sh` whose only line is `exec pwsh -NoProfile -File "$(dirname "$0")/<name>.ps1" "$@"`, except `s-full-run.sh` (four-line launcher below). `s-common.ps1` is a shared helper dot-sourced by the scripts; it holds the section-3 write set. `s-collect.ps1` produced this artifact.

## s-common.ps1

```powershell
# Shared write-set definitions for the #824 observation scripts (plan section 3).
$script:FeatureRel = 'docs/features/active/promotion-hook-raw-containment-false-positive-deny-824'
$script:BaseSha = '991aae0a180a09d504b59bc9460ec4b00b85d11b'
$script:ClaudeBundle = 'extensions/drm-copilot/resources/claude-customizations'
$script:CodexBundle = 'extensions/drm-copilot/resources/codex-and-agents-customizations'
$script:SharedModules = @(
    'hook-command-scanner.ps1', 'hook-command-heredoc.ps1', 'hook-command-payload.ps1',
    'hook-command-payload-powershell.ps1', 'hook-command-invocation.ps1', 'hook-command-invocation-operands.ps1'
)
$script:ClaudeOnlyHooks = @(
    '.claude/hooks/enforce-promotion-mcp-only.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate.ps1',
    '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.claude/hooks/enforce-pr-author-skill-helpers.ps1',
    '.claude/hooks/enforce-pr-author-command-allowlist.ps1'
)
$script:ClaudeDocs = @('.claude/agents/pr-author.md', '.claude/skills/pr-author/SKILL.md')
$script:CodexOnlyHooks = @('.codex/hooks/enforce-promotion-mcp-only.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1')
$script:Manifests = @(
    "$script:ClaudeBundle/pack-manifests/core.json", "$script:CodexBundle/pack-manifests/core.json"
)
$script:NewTests = @(
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
    'tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1'
)
$script:ModifiedTests = @(
    'tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1',
    'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1',
    'tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1',
    'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1'
)

function Get-ClaudeProduction { @($script:SharedModules | ForEach-Object { ".claude/hooks/$_" }) + $script:ClaudeOnlyHooks }
function Get-CodexProduction { @($script:SharedModules | ForEach-Object { ".codex/hooks/$_" }) + $script:CodexOnlyHooks }
function Get-ProductionPs1 { @(Get-ClaudeProduction) + @(Get-CodexProduction) }

function Get-SplitSibling {
    param([string] $Root)
    $log = Join-Path $Root "$script:FeatureRel/evidence/other/test-split-log.md"
    if (-not (Test-Path -LiteralPath $log)) { return @() }
    $text = Get-Content -Raw -LiteralPath $log
    @([regex]::Matches($text, 'tests/scripts/[A-Za-z0-9_./-]+\.Tests\.ps1') | ForEach-Object { $_.Value } | Sort-Object -Unique)
}

function Get-WriteSet {
    param([string] $Root)
    $claudeProd = @(Get-ClaudeProduction)
    $codexProd = @(Get-CodexProduction)
    $bundle = @($claudeProd + $script:ClaudeDocs | ForEach-Object { "$script:ClaudeBundle/$_" }) +
        @($codexProd | ForEach-Object { "$script:CodexBundle/$_" })
    @($claudeProd + $codexProd + $script:ClaudeDocs + $bundle + $script:Manifests + $script:NewTests +
        $script:ModifiedTests + @(Get-SplitSibling -Root $Root)) | Sort-Object -Unique
}

function Get-FileSha256 {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 'MISSING' }
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
```

## s-hash.ps1

```powershell
param([ValidateSet('baseline', 'final')][string] $Mode = 'final')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
$groups = [ordered]@{}
foreach ($m in $script:SharedModules) {
    $groups["shared-$m"] = @(".claude/hooks/$m", ".codex/hooks/$m", "$script:ClaudeBundle/.claude/hooks/$m", "$script:CodexBundle/.codex/hooks/$m")
}
foreach ($f in @($script:ClaudeOnlyHooks + $script:ClaudeDocs)) {
    $groups["claude-$(Split-Path -Leaf $f)"] = @($f, "$script:ClaudeBundle/$f")
}
foreach ($f in $script:CodexOnlyHooks) {
    $groups["codex-$(Split-Path -Leaf $f)"] = @($f, "$script:CodexBundle/$f")
}
$bad = 0
foreach ($name in $groups.Keys) {
    $members = @($groups[$name])
    if ($Mode -eq 'baseline') { $members = @($members | Where-Object { Test-Path -LiteralPath (Join-Path $root $_) }) }
    if ($members.Count -eq 0) { Write-Output "GROUP $name ABSENT_AT_BASELINE"; continue }
    $hashes = @()
    foreach ($rel in $members) {
        $h = Get-FileSha256 -Path (Join-Path $root $rel)
        Write-Output "HASH $rel $h"
        $hashes += $h
    }
    $distinct = @($hashes | Sort-Object -Unique).Count
    Write-Output "GROUP $name DISTINCT=$distinct"
    if ($distinct -ne 1) { $bad++ }
}
if ($bad -gt 0) { exit 1 }
exit 0
```

## s-lines.ps1

```powershell
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
$max = 0
$over = @()
foreach ($rel in @(Get-WriteSet -Root $root | Where-Object { $_ -like '*.ps1' })) {
    $full = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }
    $n = [System.IO.File]::ReadAllLines($full).Count
    Write-Output "LINES $rel $n"
    if ($n -gt $max) { $max = $n }
    if ($n -gt 500) { $over += $rel }
}
Write-Output "MAX_LINES: $max"
if ($over.Count -eq 0) { Write-Output 'OVER_500: NONE'; exit 0 }
Write-Output "OVER_500: $($over -join ', ')"
exit 1
```

## s-fmtcheck.ps1

```powershell
param([ValidateSet('folders', 'writeset')][string] $Scope = 'writeset')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
Import-Module PSScriptAnalyzer -ErrorAction Stop
$root = (Get-Location).Path
$settings = Join-Path $root 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
if ($Scope -eq 'folders') {
    $files = foreach ($folder in @('.claude/hooks', '.codex/hooks', 'tests/scripts/claude-hooks', 'tests/scripts/codex-hooks')) {
        Get-ChildItem -LiteralPath (Join-Path $root $folder) -Filter '*.ps1' -File -Recurse |
            ForEach-Object { [System.IO.Path]::GetRelativePath($root, $_.FullName).Replace('\', '/') }
    }
} else {
    $files = @(Get-WriteSet -Root $root | Where-Object { $_ -like '*.ps1' -and (Test-Path -LiteralPath (Join-Path $root $_)) })
}
$drift = 0
foreach ($rel in @($files | Sort-Object -Unique)) {
    $original = Get-Content -Raw -LiteralPath (Join-Path $root $rel)
    if ($null -eq $original) { $original = '' }
    $normalized = $original -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) { Write-Output "FORMAT_DRIFT $rel"; $drift++ } else { Write-Output "FORMAT_CLEAN $rel" }
}
Write-Output "FORMAT_DRIFT_COUNT: $drift"
if ($drift -gt 0) { exit 1 }
exit 0
```

## s-pssa.ps1

```powershell
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
Import-Module PSScriptAnalyzer -ErrorAction Stop
$root = (Get-Location).Path
$settings = Join-Path $root 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$count = 0
foreach ($rel in @(Get-WriteSet -Root $root | Where-Object { $_ -like '*.ps1' })) {
    $full = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }
    $findings = @(Invoke-ScriptAnalyzer -Path $full -Settings $settings -Severity Error, Warning, Information)
    foreach ($f in $findings) {
        Write-Output "PSSA ${rel}:$($f.Line) $($f.RuleName)"
        $count++
    }
}
Write-Output "PSSA_FINDING_COUNT: $count"
if ($count -gt 0) { exit 1 }
exit 0
```

## s-pester.ps1

```powershell
param([Parameter(Mandatory = $true)][string] $Set)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
$root = (Get-Location).Path
$ch = 'tests/scripts/claude-hooks'
$cx = 'tests/scripts/codex-hooks'

function Expand-SetPath {
    param([string[]] $Pattern)
    foreach ($p in $Pattern) {
        $dir = Join-Path $root (Split-Path -Parent $p)
        $leaf = Split-Path -Leaf $p
        Get-ChildItem -LiteralPath $dir -Filter $leaf -File | ForEach-Object { $_.FullName }
    }
}
function Get-NewTestWithSibling {
    param([string[]] $Rel)
    foreach ($r in $Rel) {
        $r
        $r -replace '\.Tests\.ps1$', '.*.Tests.ps1'
    }
}
$setA = @(
    "$ch/hook-command-invocation.Tests.ps1", "$ch/hook-command-scanner.Tests.ps1", "$ch/hook-command-parser.AcceptanceCases.Tests.ps1",
    "$ch/enforce-promotion-mcp-only.Tests.ps1", "$ch/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1",
    "$ch/enforce-epic-worktree-removal-gate.Tests.ps1", "$ch/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1",
    "$ch/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1",
    "$ch/enforce-parallel-worktree-removal-gate.Tests.ps1", "$ch/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1",
    "$ch/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1", "$ch/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1",
    "$ch/enforce-pr-author-skill*.Tests.ps1", "$ch/validate-bash.Tests.ps1", "$ch/validate-bash.TriggerScoping.Tests.ps1",
    "$ch/enforce-orchestration-preimplementation-gate.Tests.ps1", "$ch/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1",
    "$ch/enforce-epic-merge-gate.Tests.ps1", "$ch/enforce-epic-merge-gate.TriggerScoping.Tests.ps1",
    "$ch/enforce-parallel-abandon-gate.Tests.ps1", "$ch/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1",
    "$ch/PreToolUsePayload.Contract.Tests.ps1",
    "$cx/hook-command-invocation.Tests.ps1", "$cx/epic-execution-gates.Tests.ps1", "$cx/hook-command-scanner.Tests.ps1",
    "$cx/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1", "$cx/enforce-promotion-mcp-only-decision-surface.Tests.ps1",
    "$cx/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1", "$cx/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1",
    "$cx/validate-bash-trigger-scoping.Tests.ps1", "$cx/validate-bash-decision-surface.Tests.ps1",
    "$cx/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1",
    "$cx/enforce-epic-merge-gate-trigger-scoping.Tests.ps1", "$cx/enforce-epic-merge-gate-decision-surface.Tests.ps1",
    "$cx/legacy-codex-hook-contracts.Tests.ps1", "$cx/codex-epic-runtime-contracts.Tests.ps1",
    'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1'
)
$parity = @("$cx/legacy-codex-hook-contracts.Tests.ps1", "$cx/codex-epic-runtime-contracts.Tests.ps1")
$setANoParity = @($setA | Where-Object { $parity -notcontains $_ })
$tReg = Get-NewTestWithSibling "$ch/hook-command-invocation.Issue824Regression.Tests.ps1"
$tScan = Get-NewTestWithSibling "$ch/hook-command-scanner.Issue824.Tests.ps1"
$tPay = Get-NewTestWithSibling "$ch/hook-command-payload.Tests.ps1"
$tInv = Get-NewTestWithSibling "$ch/hook-command-invocation.Issue824.Tests.ps1"
$tOps = Get-NewTestWithSibling "$ch/hook-command-invocation-operands.Tests.ps1"
$tPromo = Get-NewTestWithSibling "$ch/enforce-promotion-mcp-only.Issue824.Tests.ps1"
$tEpic = Get-NewTestWithSibling "$ch/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1"
$tPar = Get-NewTestWithSibling "$ch/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1"
$tCxEpic = Get-NewTestWithSibling "$cx/enforce-epic-worktree-removal-gate-issue824.Tests.ps1"
$tCons = Get-NewTestWithSibling "$ch/hook-command-consumers.Issue824.Tests.ps1"
$tAllow = Get-NewTestWithSibling "$ch/enforce-pr-author-command-allowlist.Tests.ps1"
$p2 = @($tScan) + @("$ch/hook-command-scanner.Tests.ps1", "$cx/hook-command-scanner.Tests.ps1",
    "$ch/hook-command-invocation.Tests.ps1", "$cx/hook-command-invocation.Tests.ps1", "$ch/hook-command-parser.AcceptanceCases.Tests.ps1")
$p3 = $p2 + $tPay
$p4 = $p3 + $tInv + $tOps
$tag = $null
switch ($Set) {
    'A' { $patterns = $setA }
    'A-NOPARITY' { $patterns = $setANoParity }
    'REG' { $patterns = $tReg }
    'P2' { $patterns = $p2 }
    'P3' { $patterns = $p3 }
    'P4' { $patterns = $p4 }
    'P5' { $patterns = $setANoParity + $tScan + $tPay + $tInv + $tOps + $tPromo + $tEpic + $tPar + $tCxEpic + $tCons }
    'P6' { $patterns = @("$ch/enforce-pr-author-skill*.Tests.ps1") + $tAllow + @("$ch/validate-pr-author-output.Tests.ps1") }
    'PARITY' { $patterns = $parity + @("$ch/PreToolUsePayload.Contract.Tests.ps1", 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1') }
    'I824' { $patterns = @("$ch/*.Tests.ps1", "$cx/*.Tests.ps1"); $tag = 'Issue824' }
    'NC' { $patterns = @("$ch/*.Tests.ps1", "$cx/*.Tests.ps1"); $tag = 'NegativeControl' }
    default { throw "Unknown set: $Set" }
}
$paths = @(Expand-SetPath -Pattern $patterns | Sort-Object -Unique)
Write-Output "PESTER_SET: $Set FILES=$($paths.Count)"
foreach ($p in $paths) { Write-Output "PESTER_FILE: $([System.IO.Path]::GetRelativePath($root, $p).Replace('\', '/'))" }
$cfg = New-PesterConfiguration
$cfg.Run.Path = $paths
$cfg.Run.PassThru = $true
$cfg.Run.Exit = $false
$cfg.Output.Verbosity = 'Normal'
$cfg.CodeCoverage.Enabled = $false
if ($tag) { $cfg.Filter.Tag = $tag }
$r = Invoke-Pester -Configuration $cfg
Write-Output "PESTER_TOTAL: $($r.TotalCount)"
Write-Output "PESTER_PASSED: $($r.PassedCount)"
Write-Output "PESTER_FAILED: $($r.FailedCount)"
Write-Output "PESTER_SKIPPED: $($r.SkippedCount)"
Write-Output "PESTER_FAILED_BLOCKS: $($r.FailedBlocksCount)"
Write-Output "PESTER_FAILED_CONTAINERS: $($r.FailedContainersCount)"
foreach ($t in $r.Tests) { Write-Output "RESULT $($t.Result) $($t.ExpandedPath)" }
foreach ($t in @($r.Failed)) {
    Write-Output "FAILED_TEST: $($t.ExpandedPath)"
    $msg = if ($t.ErrorRecord) { ($t.ErrorRecord[0].Exception.Message -split "`r?`n")[0] } else { '' }
    Write-Output "FAILURE_MESSAGE: $msg"
}
foreach ($c in @($r.FailedContainers)) { Write-Output "FAILED_CONTAINER: $($c.Item)" }
if ($r.FailedCount -gt 0 -or $r.FailedContainersCount -gt 0 -or $r.FailedBlocksCount -gt 0) { exit 1 }
exit 0
```

## s-full-run.ps1

```powershell
$ErrorActionPreference = 'Stop'
Import-Module ./scripts/powershell/PoshQC
Invoke-PoshQCTest -Root .
```

## s-full-parse.ps1

```powershell
param([ValidateSet('baseline', 'final')][string] $Mode = 'final')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
[xml] $junit = Get-Content -Raw -LiteralPath (Join-Path $root 'artifacts/pester/pester-junit.xml')
$suites = @($junit.SelectNodes('//testsuite'))
$tests = 0; $failures = 0; $errors = 0
foreach ($s in $suites) { $tests += [int]$s.tests; $failures += [int]$s.failures; $errors += [int]$s.errors }
Write-Output "JUNIT_TESTS: $tests"
Write-Output "JUNIT_FAILURES: $failures"
Write-Output "JUNIT_ERRORS: $errors"
foreach ($tc in @($junit.SelectNodes('//testcase[failure or error]'))) { Write-Output "FAILED_TEST: $($tc.name)" }

[xml] $cov = Get-Content -Raw -LiteralPath (Join-Path $root 'artifacts/pester/powershell-coverage.xml')
$index = @{}
foreach ($pkg in @($cov.SelectNodes('//package'))) {
    $dir = [string]$pkg.name
    $relDir = if ([System.IO.Path]::IsPathRooted($dir)) { [System.IO.Path]::GetRelativePath($root, $dir) } else { $dir }
    $relDir = $relDir.Replace('\', '/').TrimEnd('/')
    foreach ($sf in @($pkg.SelectNodes('sourcefile'))) {
        $counter = $sf.SelectSingleNode("counter[@type='LINE']")
        if ($null -ne $counter) { $index["$relDir/$($sf.name)"] = $counter }
    }
}
$below = @()
foreach ($rel in @(Get-ProductionPs1)) {
    $exists = Test-Path -LiteralPath (Join-Path $root $rel)
    if ($Mode -eq 'baseline' -and -not $exists) { Write-Output "COVERAGE $rel NEW_FILE"; continue }
    if (-not $index.ContainsKey($rel)) { Write-Output "COVERAGE $rel ABSENT"; $below += $rel; continue }
    $c = [int]$index[$rel].covered; $m = [int]$index[$rel].missed
    $pct = if (($c + $m) -gt 0) { [math]::Round(100.0 * $c / ($c + $m), 2) } else { 0 }
    Write-Output ("COVERAGE {0} covered={1} missed={2} pct={3:F2}" -f $rel, $c, $m, $pct)
    if ($pct -lt 85.00) { $below += $rel }
}
if ($below.Count -eq 0) { Write-Output 'COVERAGE_BELOW_85: NONE'; exit 0 }
Write-Output "COVERAGE_BELOW_85: $($below -join ', ')"
exit 1
```

## s-changedcov.ps1

```powershell
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
[xml] $cov = Get-Content -Raw -LiteralPath (Join-Path $root 'artifacts/pester/powershell-coverage.xml')
$lineIndex = @{}
foreach ($pkg in @($cov.SelectNodes('//package'))) {
    $dir = [string]$pkg.name
    $relDir = if ([System.IO.Path]::IsPathRooted($dir)) { [System.IO.Path]::GetRelativePath($root, $dir) } else { $dir }
    $relDir = $relDir.Replace('\', '/').TrimEnd('/')
    foreach ($sf in @($pkg.SelectNodes('sourcefile'))) {
        $map = @{}
        foreach ($ln in @($sf.SelectNodes('line'))) { $map[[int]$ln.nr] = [int]$ln.ci }
        $lineIndex["$relDir/$($sf.name)"] = $map
    }
}
$total = 0
foreach ($rel in @(Get-ProductionPs1)) {
    $full = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }
    $null = git cat-file -e "$($script:BaseSha):$rel" 2>$null
    $isNew = ($LASTEXITCODE -ne 0)
    $changed = @()
    if ($isNew) {
        $changed = 1..([System.IO.File]::ReadAllLines($full).Count)
    } else {
        foreach ($h in @(git diff -U0 $script:BaseSha -- $rel | Select-String -Pattern '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')) {
            $start = [int]$h.Matches[0].Groups[1].Value
            $len = if ($h.Matches[0].Groups[2].Success) { [int]$h.Matches[0].Groups[2].Value } else { 1 }
            if ($len -gt 0) { $changed += $start..($start + $len - 1) }
        }
    }
    $map = if ($lineIndex.ContainsKey($rel)) { $lineIndex[$rel] } else { @{} }
    $instrumented = @($changed | Where-Object { $map.ContainsKey($_) })
    $uncovered = @($instrumented | Where-Object { $map[$_] -eq 0 })
    Write-Output "CHANGED $rel changed=$($changed.Count) instrumented=$($instrumented.Count) uncovered=$($uncovered.Count)"
    foreach ($u in $uncovered) { Write-Output "UNCOVERED_CHANGED ${rel}:$u" }
    $total += $uncovered.Count
}
Write-Output "UNCOVERED_CHANGED_TOTAL: $total"
if ($total -gt 0) { exit 1 }
exit 0
```

## s-mirror.ps1

```powershell
param([Parameter(Mandatory = $true)][ValidateSet('codex-scanner', 'codex-payload', 'codex-invocation', 'claude-bundle', 'codex-bundle')][string] $Group)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
switch ($Group) {
    'codex-scanner' { $pairs = @('hook-command-scanner.ps1', 'hook-command-heredoc.ps1') | ForEach-Object { , @(".claude/hooks/$_", ".codex/hooks/$_") } }
    'codex-payload' { $pairs = @('hook-command-payload.ps1', 'hook-command-payload-powershell.ps1', 'hook-command-invocation.ps1') | ForEach-Object { , @(".claude/hooks/$_", ".codex/hooks/$_") } }
    'codex-invocation' { $pairs = @('hook-command-invocation.ps1', 'hook-command-invocation-operands.ps1') | ForEach-Object { , @(".claude/hooks/$_", ".codex/hooks/$_") } }
    'claude-bundle' { $pairs = @(Get-ClaudeProduction) + $script:ClaudeDocs | ForEach-Object { , @($_, "$script:ClaudeBundle/$_") } }
    'codex-bundle' { $pairs = @(Get-CodexProduction) | ForEach-Object { , @($_, "$script:CodexBundle/$_") } }
}
$log = Join-Path $root "$script:FeatureRel/evidence/other/mirror-log.md"
if (-not (Test-Path -LiteralPath $log)) { Set-Content -LiteralPath $log -Value "# Mirror Log`n" -Encoding utf8NoBOM }
$bad = 0
foreach ($pair in $pairs) {
    $src = Join-Path $root $pair[0]
    $dst = Join-Path $root $pair[1]
    Copy-Item -LiteralPath $src -Destination $dst -Force
    $hs = Get-FileSha256 -Path $src
    $hd = Get-FileSha256 -Path $dst
    if ($hs -ne $hd) { $bad++ }
    Write-Output "COPIED $($pair[0]) -> $($pair[1]) $hd"
    Add-Content -LiteralPath $log -Value "- $(Get-Date -Format 'yyyy-MM-ddTHH-mm') group=$Group source=$($pair[0]) target=$($pair[1]) source_sha256=$hs target_sha256=$hd" -Encoding utf8NoBOM
}
if ($bad -gt 0) { exit 1 }
exit 0
```

## s-scope.ps1

```powershell
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
$changed = @(git diff --name-only $script:BaseSha) + @(git ls-files --others --exclude-standard) | Where-Object { $_ } | Sort-Object -Unique
$writeSet = @(Get-WriteSet -Root $root)
$out = 0; $add2 = 0
foreach ($p in $changed) {
    if ($writeSet -notcontains $p -and -not $p.StartsWith("$script:FeatureRel/")) { Write-Output "OUT_OF_SET: $p"; $out++ }
}
Write-Output "OUT_OF_SET_COUNT: $out"
foreach ($p in $changed) {
    if ($p -match 'codex-web-setup|KcovFunctionCoverageGate|_shell-coverage|TaskMaster|validate-feature-review-coverage') { Write-Output "ADDENDUM2_PATH: $p"; $add2++ }
}
Write-Output "ADDENDUM2_COUNT: $add2"
if ($out -gt 0 -or $add2 -gt 0) { exit 1 }
exit 0
```

## s-nopy.ps1

```powershell
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
$count = 0
foreach ($rel in @(Get-ProductionPs1)) {
    $full = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }
    $lines = [System.IO.File]::ReadAllLines($full)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '(^|[\s;&|(])(python3?|py|poetry|pipx|uv)(\.exe)?(\s|$)') {
            Write-Output "PYTHON_INVOCATION ${rel}:$($i + 1)"
            $count++
        }
    }
}
Write-Output "PYTHON_INVOCATION_COUNT: $count"
if ($count -gt 0) { exit 1 }
exit 0
```

## s-tokens.ps1

```powershell
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 's-common.ps1')
$root = (Get-Location).Path
$pattern = '[A-Z][A-Z_]+_(BLOCKED|NONCANONICAL|NOT_ALLOWED|NOT_DERIVABLE):'
$baseTokens = @{}
$nowTokens = @{}
foreach ($rel in @(Get-ProductionPs1)) {
    $baseText = git show "$($script:BaseSha):$rel" 2>$null
    if ($LASTEXITCODE -eq 0) {
        foreach ($m in [regex]::Matches(($baseText -join "`n"), $pattern)) { $baseTokens[$m.Value] = $true }
    }
    $full = Join-Path $root $rel
    if (Test-Path -LiteralPath $full) {
        foreach ($m in [regex]::Matches((Get-Content -Raw -LiteralPath $full), $pattern)) { $nowTokens[$m.Value] = $true }
    }
}
$permitted = @('PR_AUTHOR_COMMAND_NOT_ALLOWED:', 'TARGET_WORKTREE_NOT_DERIVABLE:')
$new = @($nowTokens.Keys | Where-Object { -not $baseTokens.ContainsKey($_) } | Sort-Object)
foreach ($t in $new) { Write-Output "NEW_TOKEN: $t" }
Write-Output "NEW_TOKEN_COUNT: $($new.Count)"
$unexpected = @($new | Where-Object { $permitted -cnotcontains $_ })
if ($unexpected.Count -gt 0 -or $new -cnotcontains 'PR_AUTHOR_COMMAND_NOT_ALLOWED:') { exit 1 }
exit 0
```

## s-collect.ps1

```powershell
param([Parameter(Mandatory = $true)][string] $OutRel, [Parameter(Mandatory = $true)][string] $Stamp)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$sb = [System.Text.StringBuilder]::new()
$fence = '```'
[void]$sb.Append("# Observation Scripts (plan section 6)`n`nTimestamp: $Stamp`n`n")
[void]$sb.Append("Each script lives at ``<SCRATCHPAD>/<name>.ps1`` with a one-line launcher ``<SCRATCHPAD>/<name>.sh`` whose only line is ``exec pwsh -NoProfile -File `"`$(dirname `"`$0`")/<name>.ps1`" `"`$@`"``, except ``s-full-run.sh`` (four-line launcher below). ``s-common.ps1`` is a shared helper dot-sourced by the scripts; it holds the section-3 write set. ``s-collect.ps1`` produced this artifact.`n`n")
foreach ($n in @('s-common', 's-hash', 's-lines', 's-fmtcheck', 's-pssa', 's-pester', 's-full-run', 's-full-parse', 's-changedcov', 's-mirror', 's-scope', 's-nopy', 's-tokens', 's-collect')) {
    $text = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "$n.ps1")
    [void]$sb.Append("## $n.ps1`n`n${fence}powershell`n$($text.TrimEnd())`n$fence`n`n")
}
$launcher = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 's-full-run.sh')
[void]$sb.Append("## s-full-run.sh (launcher, rule 4 exception)`n`n${fence}sh`n$($launcher.TrimEnd())`n$fence`n")
Set-Content -LiteralPath (Join-Path $root $OutRel) -Value $sb.ToString() -Encoding utf8NoBOM -NoNewline
Write-Output "WROTE $OutRel"
```

## s-full-run.sh (launcher, rule 4 exception)

```sh
pwsh -NoProfile -File "$(dirname "$0")/s-full-run.ps1"
code=$?
echo "FULL_RUN_EXIT_CODE: $code"
exit $code
```
