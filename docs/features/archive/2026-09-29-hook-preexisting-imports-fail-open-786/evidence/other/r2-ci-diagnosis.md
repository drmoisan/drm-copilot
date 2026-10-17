# Remediation Cycle 2 Linux CI Diagnosis

Timestamp: 2026-10-10T20-42
Command: sh <SCRATCHPAD>/r.sh r2-p1t1 (fresh PowerShell 7 process: [System.Management.Automation.Language.Parser]::ParseFile on <SCRATCHPAD>/r2-ciparity.ps1, <SCRATCHPAD>/r2-drivesim.ps1, <SCRATCHPAD>/r2-census.Tests.ps1, <SCRATCHPAD>/r2-ciwait.ps1; scripts written with the Write tool from the section 4 bodies)
EXIT_CODE: 0
Output Summary: four scripts written; parse error counts: 0, 0, 0, 0.

## [P1-T1] Parse results

PARSE: r2-ciparity.ps1 | 0
PARSE: r2-drivesim.ps1 | 0
PARSE: r2-census.Tests.ps1 | 0
PARSE: r2-ciwait.ps1 | 0

## Scripts

### <SCRATCHPAD>/r2-ciparity.ps1

```powershell
param([Parameter(Mandatory = $true)][string] $Label, [string] $ListFile = '')
# r2 R-CIPARITY: Linux hook-suite job Pester configuration (_poshqc.yml:73-82), script-scope Invoke-Pester, coverage disabled.
$ErrorActionPreference = 'Stop'
Import-Module Pester -MinimumVersion 5.6.1
"PESTER-VERSION: $((Get-Module Pester | Select-Object -First 1).Version)"
$root = (Get-Location).Path
$sp = $PSScriptRoot
if ($ListFile) {
    $paths = @(Get-Content -LiteralPath $ListFile | Where-Object { $_.Trim() } | ForEach-Object {
            $line = $_.Trim()
            if ([System.IO.Path]::IsPathRooted($line)) { $line } else { Join-Path $root $line }
        })
}
else {
    $paths = @('tests/scripts/claude-hooks', 'tests/scripts/codex-hooks')
}
$config = New-PesterConfiguration
$config.Run.Path = $paths
$config.Run.Exit = $false
$config.Run.PassThru = $true
$config.CodeCoverage.Enabled = $false
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = 'JUnitXml'
$config.TestResult.OutputPath = (Join-Path $sp "r2-ciparity-$Label-junit.xml")
$result = Invoke-Pester -Configuration $config
function ConvertTo-Shown([string] $p) {
    $full = [System.IO.Path]::GetFullPath($p)
    $rootFull = [System.IO.Path]::GetFullPath($root).TrimEnd('\', '/')
    if ($full.StartsWith($rootFull + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        return ($full.Substring($rootFull.Length + 1) -replace '\\', '/')
    }
    return '<SCRATCHPAD>/' + [System.IO.Path]::GetFileName($full)
}
"PARITY: $Label | containers=$($result.Containers.Count) | passed=$($result.PassedCount) | failed=$($result.FailedCount)"
$i = 0
$containerFull = [System.Collections.Generic.List[string]]::new()
foreach ($c in $result.Containers) {
    $i++
    $item = [string]$c.Item
    $containerFull.Add([System.IO.Path]::GetFullPath($item))
    "ORDER: $i | $(ConvertTo-Shown $item)"
}
if ($ListFile) {
    $expected = @($paths | ForEach-Object { [System.IO.Path]::GetFullPath($_) })
    $same = ($expected.Count -eq $containerFull.Count)
    if ($same) { for ($k = 0; $k -lt $expected.Count; $k++) { if (-not [string]::Equals($expected[$k], $containerFull[$k], [System.StringComparison]::OrdinalIgnoreCase)) { $same = $false; break } } }
    "ORDER-PRESERVED: $(if ($same) { 'yes' } else { 'no' })"
}
else { 'ORDER-PRESERVED: n/a' }
foreach ($t in $result.Failed) {
    $msg = ''
    if ($t.ErrorRecord -and $t.ErrorRecord.Count -gt 0) { $msg = ([string]$t.ErrorRecord[0].Exception.Message -split "`r?`n")[0] }
    "FAILED: $(ConvertTo-Shown ([string]$t.ScriptBlock.File)) | $($t.ExpandedPath) | $msg"
}
foreach ($t in $result.Tests) {
    if ([string]$t.ExpandedName -like '*baseline mock interception probe') {
        $state = if ($t.Result -eq 'Passed') { 'passed' } else { 'failed' }
        "INTERCEPTION-ROW: $(ConvertTo-Shown ([string]$t.ScriptBlock.File)) | $state"
    }
}
exit 0
```

### <SCRATCHPAD>/r2-drivesim.ps1

```powershell
param([Parameter(Mandatory = $true)][string] $Label)
# r2 R-DRIVESIM: rewrite drive letter C to an absent drive in shadow copies, apply R-SHADOW, run R-SCOPED over the shadows.
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$sp = $PSScriptRoot
$sim = $null
foreach ($letter in @('Z', 'Y', 'X', 'W', 'V', 'U', 'T', 'S', 'R', 'Q', 'P', 'O', 'N', 'M', 'L', 'K', 'J', 'I', 'H', 'G', 'F', 'E', 'D')) {
    if (-not (Get-PSDrive -Name $letter -ErrorAction SilentlyContinue)) { $sim = $letter; break }
}
if (-not $sim) { 'SIM-DRIVE: none'; exit 1 }
"SIM-DRIVE: $sim"
$files = @(
    'tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1',
    'tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1'
)
$shadowDir = Join-Path $sp "r2-shadow-$Label"
New-Item -ItemType Directory -Path $shadowDir -Force | Out-Null
$utf8 = [System.Text.UTF8Encoding]::new($false)
$back = @{}
$shadows = [System.Collections.Generic.List[string]]::new()
foreach ($f in $files) {
    $full = Join-Path $root $f
    $text = [System.IO.File]::ReadAllText($full, $utf8)
    $rx = [regex]'(?<![A-Za-z0-9_$])C:(?=[\\/])'
    $count = $rx.Matches($text).Count
    $text = $rx.Replace($text, "${sim}:")
    "SIM-REPLACED: $f | $count"
    $dir = Split-Path -Parent $full
    $text = $text.Replace('$PSScriptRoot', "'" + $dir + "'").Replace('$PSCommandPath', "'" + $full + "'")
    $leaf = Split-Path -Leaf $full
    $shadow = Join-Path $shadowDir $leaf
    [System.IO.File]::WriteAllText($shadow, $text, $utf8)
    $back[[System.IO.Path]::GetFullPath($shadow)] = $f
    $shadows.Add($shadow)
}
function Get-Original([string] $p) {
    $k = [System.IO.Path]::GetFullPath($p)
    foreach ($key in $back.Keys) { if ([string]::Equals($key, $k, [System.StringComparison]::OrdinalIgnoreCase)) { return $back[$key] } }
    return $p
}
Import-Module Pester -MinimumVersion 5.0.0
$configuration = New-PesterConfiguration
$configuration.Run.Path = @($shadows)
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
$result = Invoke-Pester -Configuration $configuration
"PassedCount: $($result.PassedCount)"
"FailedCount: $($result.FailedCount)"
"FailedBlocksCount: $($result.FailedBlocksCount)"
"FailedContainersCount: $($result.FailedContainersCount)"
foreach ($c in $result.Containers) {
    $orig = Get-Original ([string]$c.Item)
    $mine = @($result.Tests | Where-Object { [string]$_.ScriptBlock.File -eq [string]$c.Item })
    $p = @($mine | Where-Object { $_.Result -eq 'Passed' }).Count
    $fl = @($mine | Where-Object { $_.Result -eq 'Failed' }).Count
    "CONTAINER: $orig | result=$($c.Result) | passed=$p | failed=$fl"
}
foreach ($t in $result.Failed) {
    $msg = ''
    if ($t.ErrorRecord -and $t.ErrorRecord.Count -gt 0) { $msg = ([string]$t.ErrorRecord[0].Exception.Message -split "`r?`n")[0] }
    "FAILED: $($t.ExpandedName) | $msg"
}
foreach ($t in $result.Passed) { "PASSED: $($t.ExpandedName)" }
foreach ($c in $result.Containers) {
    $orig = Get-Original ([string]$c.Item)
    foreach ($t in @($result.Tests | Where-Object { [string]$_.ScriptBlock.File -eq [string]$c.Item -and $_.Result -eq 'Failed' })) {
        $msg = ''
        if ($t.ErrorRecord -and $t.ErrorRecord.Count -gt 0) { $msg = ([string]$t.ErrorRecord[0].Exception.Message -split "`r?`n")[0] }
        "SIM-FAILED: $orig | $($t.ExpandedName) | $msg"
    }
}
exit ([int](($result.FailedCount + $result.FailedBlocksCount + $result.FailedContainersCount) -gt 0))
```

### <SCRATCHPAD>/r2-census.Tests.ps1

```powershell
# r2 R-CENSUS6: read-only census of EpicScopeResolution / WorktreeRunResolution module instances.
Describe 'r2 census' {
    It 'records module instances' {
        $root = (Get-Location).Path -replace '\\', '/'
        foreach ($m in @(Get-Module -All -Name 'EpicScopeResolution', 'WorktreeRunResolution')) {
            $p = ([string]$m.Path) -replace '\\', '/'
            if ($p.StartsWith($root + '/')) { $p = $p.Substring($root.Length + 1) }
            Write-Host "CENSUS: $($m.Name) | $p | $([System.Runtime.CompilerServices.RuntimeHelpers]::GetHashCode($m))"
        }
        $nameWrr = Get-Module -Name WorktreeRunResolution | Select-Object -First 1
        $nameHash = if ($nameWrr) { [System.Runtime.CompilerServices.RuntimeHelpers]::GetHashCode($nameWrr) } else { $null }
        Write-Host "CENSUS-NAME-WRR: $(if ($null -ne $nameHash) { $nameHash } else { 'none' })"
        $innerHash = $null
        $esr = Get-Module -Name EpicScopeResolution | Select-Object -First 1
        if ($esr) {
            $inner = & $esr { (Get-Command -Name Resolve-WorktreeEpicTarget -CommandType Function -ErrorAction SilentlyContinue).Module }
            if ($inner) { $innerHash = [System.Runtime.CompilerServices.RuntimeHelpers]::GetHashCode($inner) }
            Write-Host "CENSUS-INNER-WRR: $(if ($null -ne $innerHash) { $innerHash } else { 'none' })"
        }
        $mismatch = if ($null -ne $nameHash -and $null -ne $innerHash) { if ($nameHash -ne $innerHash) { 'yes' } else { 'no' } } else { 'n/a' }
        Write-Host "INSTANCE-MISMATCH: $mismatch"
        $true | Should -BeTrue
    }
}
```

### <SCRATCHPAD>/r2-ciwait.ps1

```powershell
param([Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-f]{40}$')][string] $Sha)
# r2 R-CIWAIT: wait for PR #881 checks on the given head SHA.
$ErrorActionPreference = 'Stop'
function Invoke-GhJson([string[]] $GhArgs) {
    $out = & gh @GhArgs 2>$null
    $code = $LASTEXITCODE
    $text = (@($out) -join "`n")
    [pscustomobject]@{ Code = $code; Text = $text }
}
$iter = 0
$view = $null
$checks = @()
$result = 'timeout'
while ($iter -lt 120) {
    $iter++
    $v = Invoke-GhJson @('pr', 'view', '881', '--json', 'headRefOid,mergeable,baseRefName')
    $view = if ([string]::IsNullOrWhiteSpace($v.Text)) { $null } else { $v.Text | ConvertFrom-Json }
    $c = Invoke-GhJson @('pr', 'checks', '881', '--json', 'name,workflow,state,bucket,link')
    $checks = if ([string]::IsNullOrWhiteSpace($c.Text)) { @() } else { @($c.Text | ConvertFrom-Json) }
    $headOk = ($null -ne $view -and [string]$view.headRefOid -eq $Sha)
    $pending = @($checks | Where-Object { $_.bucket -eq 'pending' }).Count
    if ($headOk -and $checks.Count -ge 1 -and $pending -eq 0) { $result = 'complete'; break }
    if ($iter -lt 120) { Start-Sleep -Seconds 60 }
}
if ($result -ne 'complete' -and -not ($null -ne $view -and [string]$view.headRefOid -eq $Sha)) { $result = 'head-mismatch' }
"PR-HEAD: $(if ($view) { $view.headRefOid } else { 'unknown' })"
"PR-BASE: $(if ($view) { $view.baseRefName } else { 'unknown' })"
"MERGEABLE: $(if ($view) { $view.mergeable } else { 'unknown' })"
"CHECK-COUNT: $($checks.Count)"
foreach ($k in $checks) { "CHECK: $($k.workflow) / $($k.name) | state=$($k.state) | bucket=$($k.bucket) | $($k.link)" }
"WAIT-ITERATIONS: $iter"
"WAIT-RESULT: $result"
exit 0
```

## [P1-T3] Row 6 reproduction

Timestamp: 2026-10-10T20-50
Command: sh <SCRATCHPAD>/r.sh r2-ciparity -Label r6-solo -ListFile <SCRATCHPAD>/r6-solo.list; sh <SCRATCHPAD>/r.sh r2-ciparity -Label r6-pair -ListFile <SCRATCHPAD>/r6-pair.list; sh <SCRATCHPAD>/r.sh r2-ciparity -Label r6-ciorder -ListFile <SCRATCHPAD>/r2-linux-order.list (R-CIPARITY, each in a fresh PowerShell 7 process; run (c) launched in the background)
EXIT_CODE: 0
Output Summary: row 6 passes alone and after validate-orchestrator-output-resolution.Tests.ps1 alone, and fails in the 200-container LINUX-ORDER run with the CI message (1 failure of 5700 tests; the 17 Mechanism A rows pass on the Windows host). ORDER-PRESERVED: yes in all three runs.

R6-SOLO: passed
R6-PAIR: passed
R6-CIORDER: failed
PARITY-BASELINE-FAILED: 1

Summary lines:
- r6-solo: PARITY: r6-solo | containers=1 | passed=75 | failed=0; ORDER-PRESERVED: yes; INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
- r6-pair: PARITY: r6-pair | containers=2 | passed=88 | failed=0; ORDER-PRESERVED: yes; INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
- r6-ciorder: PARITY: r6-ciorder | containers=200 | passed=5699 | failed=1; ORDER-PRESERVED: yes; INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | failed
- r6-ciorder FAILED: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times

Each run prints exactly one INTERCEPTION-ROW line for tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1. Run (c) is the CI-parity baseline for [P2-T8] and [P3-T10].

Output of `<SCRATCHPAD>/r2-ciparity-r6-solo.out`:

```text
PESTER-VERSION: 5.6.1

Starting discovery in 1 files.
Discovery found 75 tests in 488ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 5.43s (4.55s|412ms)
Tests completed in 5.45s
Tests Passed: 75, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PARITY: r6-solo | containers=1 | passed=75 | failed=0
ORDER: 1 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER-PRESERVED: yes
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
```

Output of `<SCRATCHPAD>/r2-ciparity-r6-pair.out`:

```text
PESTER-VERSION: 5.6.1

Starting discovery in 2 files.
Discovery found 88 tests in 515ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 1.32s (962ms|264ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 5.06s (4.47s|189ms)
Tests completed in 6.4s
Tests Passed: 88, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PARITY: r6-pair | containers=2 | passed=88 | failed=0
ORDER: 1 | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER-PRESERVED: yes
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
```

Output of `<SCRATCHPAD>/r2-ciparity-r6-ciorder.out`:

```text
PESTER-VERSION: 5.6.1

Starting discovery in 200 files.
Discovery found 5700 tests in 33.95s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 530ms (186ms|249ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 139ms (76ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 2.31s (2.14s|126ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 182ms (88ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 258ms (214ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 158ms (116ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 161ms (100ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 113ms (66ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 118ms (71ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 91ms (40ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 278ms (158ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 296ms (182ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 143ms (93ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 183ms (97ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 476ms (415ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 153ms (80ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 228ms (188ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 401ms (330ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 778ms (638ms|106ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 351ms (293ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 396ms (343ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 296ms (210ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 300ms (213ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 277ms (235ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 280ms (232ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 695ms (619ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 824ms (670ms|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 187ms (140ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 250ms (207ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 137ms (65ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 375ms (273ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 116ms (63ms|41ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 95.32s (67.7s|222ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 151ms (103ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 294ms (236ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 420ms (352ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 836ms (734ms|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 233ms (165ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 273ms (205ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.49s (1.44s|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 348ms (261ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 225ms (172ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 131ms (66ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 173ms (88ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 51ms (13ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 332ms (255ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 428ms (284ms|109ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 48ms (10ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 441ms (333ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 1.03s (927ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 132ms (87ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 1.5s (1.36s|107ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 560ms (495ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 479ms (420ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 255ms (204ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 2.6s (2.55s|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 955ms (851ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 461ms (380ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 459ms (393ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 343ms (282ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 213ms (131ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 112ms (73ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 237ms (166ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 152ms (98ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 387ms (263ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 212ms (161ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 227ms (155ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 245ms (163ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 478ms (363ms|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 198ms (146ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 285ms (230ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 702ms (579ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 736ms (607ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 183ms (132ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 269ms (219ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 276ms (196ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 233ms (169ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 316ms (254ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 938ms (846ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 359ms (296ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 600ms (536ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 3.28s (3.2s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 4.16s (4.1s|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.1s (1.05s|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 363ms (310ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 1.07s (1.02s|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 1.33s (1.17s|126ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 833ms (732ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 3.63s (3.58s|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 216ms (171ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 346ms (281ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 246ms (203ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 390ms (326ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 419ms (316ms|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 577ms (512ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 191ms (127ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 149ms (98ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 247ms (170ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 255ms (164ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 196ms (100ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 1.25s (1.17s|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 588ms (487ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 914ms (766ms|123ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 2.29s (2.18s|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 278ms (186ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 473ms (400ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 563ms (438ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 121ms (65ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 215ms (117ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 7.47s (6.91s|195ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 3.48s (1.55s|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 112ms (54ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.67s (2.58s|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 192ms (132ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 239ms (123ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 689ms (640ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 947ms (902ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 249ms (160ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 177ms (106ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 838ms (743ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 108ms (55ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 144ms (77ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 431ms (333ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 93ms (47ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 634ms (585ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 690ms (609ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 344ms (293ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 544ms (487ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 623ms (536ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 511ms (453ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 982ms (894ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 60ms (24ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 226ms (151ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 64ms (28ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 1.07s (997ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 48ms (14ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 144ms (94ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 61ms (24ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 235ms (146ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 365ms (300ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 136ms (53ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 14.17s (14.13s|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 126ms (71ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 299ms (241ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 105ms (64ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 599ms (555ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 291ms (192ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 103ms (40ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 265ms (185ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 245ms (153ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 288ms (213ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 197ms (94ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 30.76s (30.71s|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 24.41s (24.34s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 199ms (125ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 262ms (193ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 173ms (106ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 274ms (228ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 93ms (60ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 167ms (93ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 124ms (79ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 122ms (57ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 152ms (95ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 447ms (349ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 333ms (266ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 222ms (177ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 166ms (117ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 273ms (221ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 333ms (270ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 605ms (519ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 185ms (132ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 1.44s (1.29s|113ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 477ms (397ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 387ms (335ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 697ms (613ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 252ms (174ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 256ms (154ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 180ms (131ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 169ms (132ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 365ms (308ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 280ms (228ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 140ms (80ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 97ms (62ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 329ms (264ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 186ms (126ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.46s (4.35s|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 234ms (189ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 144ms (94ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 182ms (97ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 213ms (147ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 169ms (95ms|48ms)
[-] Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe 47ms (47ms|1ms)
 at Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:130
 at Invoke-EpicStateProbeEpicScope, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:130
 at Invoke-EpicStateInterceptionProbe, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:174
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:131
 Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 98ms (50ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 326ms (283ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 11.48s (11.41s|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 127ms (84ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 392ms (305ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 117ms (78ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 211ms (153ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 397ms (316ms|65ms)
Tests completed in 282.55s
Tests Passed: 5699, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
PARITY: r6-ciorder | containers=200 | passed=5699 | failed=1
ORDER: 1 | tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1
ORDER: 2 | tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1
ORDER: 3 | tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
ORDER: 4 | tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1
ORDER: 5 | tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
ORDER: 6 | tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1
ORDER: 7 | tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1
ORDER: 8 | tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
ORDER: 9 | tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1
ORDER: 10 | tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
ORDER: 11 | tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
ORDER: 12 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
ORDER: 13 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 14 | tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
ORDER: 15 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
ORDER: 16 | tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1
ORDER: 17 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
ORDER: 18 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
ORDER: 19 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
ORDER: 20 | tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
ORDER: 21 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
ORDER: 22 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
ORDER: 23 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1
ORDER: 24 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
ORDER: 25 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
ORDER: 26 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 27 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
ORDER: 28 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 29 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 30 | tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1
ORDER: 31 | tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
ORDER: 32 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
ORDER: 33 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
ORDER: 34 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
ORDER: 35 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1
ORDER: 36 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
ORDER: 37 | tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1
ORDER: 38 | tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
ORDER: 39 | tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
ORDER: 40 | tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
ORDER: 41 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 42 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
ORDER: 43 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
ORDER: 44 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
ORDER: 45 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
ORDER: 46 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 47 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 48 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
ORDER: 49 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
ORDER: 50 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
ORDER: 51 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1
ORDER: 52 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
ORDER: 53 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
ORDER: 54 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
ORDER: 55 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
ORDER: 56 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
ORDER: 57 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1
ORDER: 58 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
ORDER: 59 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
ORDER: 60 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1
ORDER: 61 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1
ORDER: 62 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
ORDER: 63 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
ORDER: 64 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1
ORDER: 65 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
ORDER: 66 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
ORDER: 67 | tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
ORDER: 68 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
ORDER: 69 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
ORDER: 70 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
ORDER: 71 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
ORDER: 72 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 73 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
ORDER: 74 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 75 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 76 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
ORDER: 77 | tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1
ORDER: 78 | tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
ORDER: 79 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
ORDER: 80 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
ORDER: 81 | tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
ORDER: 82 | tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
ORDER: 83 | tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
ORDER: 84 | tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
ORDER: 85 | tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
ORDER: 86 | tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
ORDER: 87 | tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
ORDER: 88 | tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
ORDER: 89 | tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
ORDER: 90 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
ORDER: 91 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
ORDER: 92 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1
ORDER: 93 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
ORDER: 94 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1
ORDER: 95 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1
ORDER: 96 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1
ORDER: 97 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
ORDER: 98 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
ORDER: 99 | tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1
ORDER: 100 | tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
ORDER: 101 | tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
ORDER: 102 | tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1
ORDER: 103 | tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1
ORDER: 104 | tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
ORDER: 105 | tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
ORDER: 106 | tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
ORDER: 107 | tests/scripts/claude-hooks/hook-command-payload.Tests.ps1
ORDER: 108 | tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1
ORDER: 109 | tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
ORDER: 110 | tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
ORDER: 111 | tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
ORDER: 112 | tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
ORDER: 113 | tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 114 | tests/scripts/claude-hooks/persist-session-id.Tests.ps1
ORDER: 115 | tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1
ORDER: 116 | tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
ORDER: 117 | tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1
ORDER: 118 | tests/scripts/claude-hooks/validate-bash.Tests.ps1
ORDER: 119 | tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
ORDER: 120 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
ORDER: 121 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 122 | tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
ORDER: 123 | tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 124 | tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
ORDER: 125 | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
ORDER: 126 | tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
ORDER: 127 | tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1
ORDER: 128 | tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1
ORDER: 129 | tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
ORDER: 130 | tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
ORDER: 131 | tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
ORDER: 132 | tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
ORDER: 133 | tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
ORDER: 134 | tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
ORDER: 135 | tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
ORDER: 136 | tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
ORDER: 137 | tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
ORDER: 138 | tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1
ORDER: 139 | tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
ORDER: 140 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 141 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 142 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 143 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 144 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 145 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 146 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 147 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 148 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 149 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 150 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 151 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 152 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 153 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 154 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 155 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 156 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 157 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 158 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 159 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 160 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 161 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 162 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 163 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 164 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 165 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 166 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 167 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 168 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 169 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 170 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 171 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 172 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 173 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 174 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 175 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 176 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 177 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 178 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 179 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 180 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 181 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 182 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 183 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 184 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 185 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 186 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 187 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 188 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 189 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 190 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 191 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 192 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 193 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 194 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 195 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 196 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 197 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 198 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 199 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 200 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER-PRESERVED: yes
FAILED: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
INTERCEPTION-ROW: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | failed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
```

## [P1-T4] Row 6 census

Timestamp: 2026-10-10T20-56
Command: sh <SCRATCHPAD>/r.sh r2-mkcensus (REPRO-LIST = <SCRATCHPAD>/r2-linux-order.list truncated after tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, written to <SCRATCHPAD>/r6-repro.list; <SCRATCHPAD>/r6-census.list = REPRO-LIST with <SCRATCHPAD>/r2-census.Tests.ps1 inserted immediately before the Codex suite); sh <SCRATCHPAD>/r.sh r2-ciparity -Label r6-census -ListFile <SCRATCHPAD>/r6-census.list (R-CIPARITY, background)
EXIT_CODE: 0
Output Summary: the read-only census, placed immediately before the Codex suite, records two loaded module instances and a mismatch between the WorktreeRunResolution instance in the module table and the instance that EpicScopeResolution's Resolve-WorktreeEpicTarget belongs to; the Codex interception row still fails (the census does not change the outcome).

REPRO-LIST: ciorder-prefix | entries=192

CENSUS: EpicScopeResolution | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 44463905
CENSUS: WorktreeRunResolution | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 44806581
CENSUS-NAME-WRR: 44806581
CENSUS-INNER-WRR: 25234029
INSTANCE-MISMATCH: yes

PARITY: r6-census | containers=193 | passed=5541 | failed=1
ORDER-PRESERVED: yes
R6-CENSUS-RUN: failed

Output of `<SCRATCHPAD>/r2-ciparity-r6-census.out`:

```text
PESTER-VERSION: 5.6.1

Starting discovery in 193 files.
Discovery found 5542 tests in 28.14s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 480ms (149ms|227ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 137ms (86ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 1.95s (1.79s|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 153ms (81ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 223ms (185ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 132ms (78ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 141ms (82ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 114ms (69ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 104ms (66ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 75ms (37ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 236ms (136ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 198ms (127ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 128ms (81ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 148ms (81ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 431ms (366ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 149ms (78ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 225ms (189ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 332ms (281ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 692ms (571ms|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 312ms (257ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 320ms (280ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 277ms (209ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 298ms (191ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 220ms (179ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 277ms (230ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 646ms (570ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 738ms (607ms|96ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 178ms (136ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 247ms (197ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 151ms (79ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 338ms (252ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 99ms (64ms|24ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 83.92s (61.38s|210ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 141ms (94ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 242ms (186ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 378ms (319ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 769ms (679ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 228ms (188ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 214ms (156ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.23s (1.19s|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 297ms (237ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 215ms (161ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 120ms (63ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 144ms (73ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 38ms (10ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 312ms (243ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 391ms (278ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 45ms (10ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 406ms (310ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 969ms (880ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 114ms (77ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 1.38s (1.24s|106ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 489ms (433ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 407ms (353ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 209ms (173ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 2.13s (2.08s|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 873ms (764ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 382ms (312ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 442ms (381ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 296ms (244ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 203ms (125ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 119ms (81ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 222ms (165ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 170ms (128ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 359ms (243ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 186ms (142ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 214ms (160ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 218ms (160ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 417ms (315ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 189ms (148ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 262ms (217ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 578ms (500ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 644ms (540ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 153ms (109ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 228ms (189ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 248ms (167ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 235ms (162ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 325ms (270ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 747ms (679ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 305ms (237ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 475ms (429ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 2.54s (2.48s|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 3.52s (3.47s|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.03s (988ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 331ms (288ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 1.11s (1.07s|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 1.19s (1.07s|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 722ms (649ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 3.73s (3.68s|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 247ms (189ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 354ms (288ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 267ms (222ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 374ms (311ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 361ms (282ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 548ms (480ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 203ms (137ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 144ms (93ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 227ms (145ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 212ms (156ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 187ms (102ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 1.05s (980ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 489ms (418ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 833ms (681ms|109ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 1.82s (1.73s|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 243ms (156ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 427ms (369ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 486ms (384ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 102ms (57ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 191ms (110ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 6.29s (5.79s|184ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 2.95s (1.3s|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 97ms (49ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.09s (2.01s|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 164ms (109ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 222ms (132ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 592ms (554ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 847ms (807ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 211ms (138ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 147ms (91ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 843ms (757ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 97ms (48ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 123ms (68ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 381ms (300ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 97ms (56ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 546ms (505ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 669ms (604ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 361ms (297ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 535ms (487ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 585ms (519ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 447ms (400ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 758ms (699ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 56ms (15ms|18ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 196ms (141ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 62ms (23ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 1.02s (971ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 41ms (12ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 125ms (89ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 54ms (23ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 203ms (121ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 312ms (251ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 130ms (68ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 13.74s (13.7s|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 104ms (61ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 289ms (239ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 106ms (60ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 436ms (394ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 263ms (191ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 84ms (41ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 218ms (167ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 209ms (122ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 226ms (159ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 179ms (89ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 30.56s (30.5s|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 24.12s (24.05s|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 201ms (137ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 266ms (197ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 157ms (104ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 275ms (216ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 101ms (68ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 159ms (94ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 136ms (80ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 87ms (49ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 103ms (67ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 348ms (291ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 263ms (211ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 201ms (161ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 172ms (122ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 279ms (223ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 384ms (320ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 610ms (519ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 198ms (147ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 1.38s (1.22s|120ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 481ms (386ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 425ms (371ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 717ms (612ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 245ms (177ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 281ms (175ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 182ms (124ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 156ms (122ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 366ms (311ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 297ms (237ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 131ms (90ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 101ms (59ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 305ms (264ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 174ms (110ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.41s (4.32s|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 251ms (200ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 137ms (102ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 164ms (80ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 216ms (134ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 180ms (93ms|63ms)
CENSUS: EpicScopeResolution | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 44463905
CENSUS: WorktreeRunResolution | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 44806581
CENSUS-NAME-WRR: 44806581
CENSUS-INNER-WRR: 25234029
INSTANCE-MISMATCH: yes
[+] <SCRATCHPAD>\r2-census.Tests.ps1 54ms (25ms|19ms)
[-] Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe 30ms (30ms|1ms)
 at Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:130
 at Invoke-EpicStateProbeEpicScope, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:130
 at Invoke-EpicStateInterceptionProbe, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:174
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:131
 Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
Tests completed in 246.16s
Tests Passed: 5541, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
PARITY: r6-census | containers=193 | passed=5541 | failed=1
ORDER: 1 | tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1
ORDER: 2 | tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1
ORDER: 3 | tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
ORDER: 4 | tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1
ORDER: 5 | tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
ORDER: 6 | tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1
ORDER: 7 | tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1
ORDER: 8 | tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
ORDER: 9 | tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1
ORDER: 10 | tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
ORDER: 11 | tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
ORDER: 12 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
ORDER: 13 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 14 | tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
ORDER: 15 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
ORDER: 16 | tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1
ORDER: 17 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
ORDER: 18 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
ORDER: 19 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
ORDER: 20 | tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
ORDER: 21 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
ORDER: 22 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
ORDER: 23 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1
ORDER: 24 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
ORDER: 25 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
ORDER: 26 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 27 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
ORDER: 28 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 29 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 30 | tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1
ORDER: 31 | tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
ORDER: 32 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
ORDER: 33 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
ORDER: 34 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
ORDER: 35 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1
ORDER: 36 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
ORDER: 37 | tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1
ORDER: 38 | tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
ORDER: 39 | tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
ORDER: 40 | tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
ORDER: 41 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 42 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
ORDER: 43 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
ORDER: 44 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
ORDER: 45 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
ORDER: 46 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 47 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 48 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
ORDER: 49 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
ORDER: 50 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
ORDER: 51 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1
ORDER: 52 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
ORDER: 53 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
ORDER: 54 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
ORDER: 55 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
ORDER: 56 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
ORDER: 57 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1
ORDER: 58 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
ORDER: 59 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
ORDER: 60 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1
ORDER: 61 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1
ORDER: 62 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
ORDER: 63 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
ORDER: 64 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1
ORDER: 65 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
ORDER: 66 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
ORDER: 67 | tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
ORDER: 68 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
ORDER: 69 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
ORDER: 70 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
ORDER: 71 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
ORDER: 72 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 73 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
ORDER: 74 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 75 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 76 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
ORDER: 77 | tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1
ORDER: 78 | tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
ORDER: 79 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
ORDER: 80 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
ORDER: 81 | tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
ORDER: 82 | tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
ORDER: 83 | tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
ORDER: 84 | tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
ORDER: 85 | tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
ORDER: 86 | tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
ORDER: 87 | tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
ORDER: 88 | tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
ORDER: 89 | tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
ORDER: 90 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
ORDER: 91 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
ORDER: 92 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1
ORDER: 93 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
ORDER: 94 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1
ORDER: 95 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1
ORDER: 96 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1
ORDER: 97 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
ORDER: 98 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
ORDER: 99 | tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1
ORDER: 100 | tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
ORDER: 101 | tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
ORDER: 102 | tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1
ORDER: 103 | tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1
ORDER: 104 | tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
ORDER: 105 | tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
ORDER: 106 | tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
ORDER: 107 | tests/scripts/claude-hooks/hook-command-payload.Tests.ps1
ORDER: 108 | tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1
ORDER: 109 | tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
ORDER: 110 | tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
ORDER: 111 | tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
ORDER: 112 | tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
ORDER: 113 | tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 114 | tests/scripts/claude-hooks/persist-session-id.Tests.ps1
ORDER: 115 | tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1
ORDER: 116 | tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
ORDER: 117 | tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1
ORDER: 118 | tests/scripts/claude-hooks/validate-bash.Tests.ps1
ORDER: 119 | tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
ORDER: 120 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
ORDER: 121 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 122 | tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
ORDER: 123 | tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 124 | tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
ORDER: 125 | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
ORDER: 126 | tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
ORDER: 127 | tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1
ORDER: 128 | tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1
ORDER: 129 | tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
ORDER: 130 | tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
ORDER: 131 | tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
ORDER: 132 | tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
ORDER: 133 | tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
ORDER: 134 | tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
ORDER: 135 | tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
ORDER: 136 | tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
ORDER: 137 | tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
ORDER: 138 | tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1
ORDER: 139 | tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
ORDER: 140 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 141 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 142 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 143 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 144 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 145 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 146 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 147 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 148 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 149 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 150 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 151 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 152 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 153 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 154 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 155 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 156 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 157 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 158 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 159 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 160 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 161 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 162 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 163 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 164 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 165 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 166 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 167 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 168 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 169 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 170 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 171 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 172 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 173 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 174 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 175 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 176 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 177 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 178 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 179 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 180 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 181 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 182 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 183 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 184 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 185 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 186 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 187 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 188 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 189 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 190 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 191 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 192 | <SCRATCHPAD>/r2-census.Tests.ps1
ORDER: 193 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER-PRESERVED: yes
FAILED: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
INTERCEPTION-ROW: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | failed
```

Note: the census run printed exactly one `INSTANCE-MISMATCH:` line (count over `<SCRATCHPAD>/r2-ciparity-r6-census.out`: 1); the same line appears a second time in this section only because the task requires both the extracted census lines and the full output.

## [P1-T5] Production review

Timestamp: 2026-10-10T20-57
Command: read-only inspection of the cited hook call sites and the production sources of their path arguments (Read/Grep over .codex/hooks/*.ps1, .codex/hooks/codex-epic-child-launch-attestation.ps1, .codex/scripts/launch-epic-child-wave.ps1); sh <SCRATCHPAD>/r.sh r2-lines -DriveList <SCRATCHPAD>/r2-hooks5.list (R-DRIVE-LITERALS over the five hook files)
EXIT_CODE: 0
Output Summary: every Mechanism A path argument is derived in production from $PSScriptRoot or from runtime output (git worktree list, launcher environment, receipt content, directory enumeration under a $PSScriptRoot-derived root); the five hook files contain no drive-letter literal. PRODUCTION-DEFECT: none.

PROD-PATH: 1 | .codex/hooks/enforce-codex-model-routing.ps1:185 | Get-Content -Raw of a FullName enumerated by Get-ChildItem under the state root from Get-CodexAuthorityStateRoot -RepositoryRoot $repositoryRoot ($script:CodexModelGateRepositoryRoot, two Split-Path levels above $PSScriptRoot; lines 164, 181-184) | .codex/hooks/enforce-codex-model-routing.ps1:12
PROD-PATH: 2 | .codex/hooks/enforce-epic-root-invocation.ps1:122 | Get-Content -Raw of a FullName enumerated under the state root from Get-CodexAuthorityStateRoot -RepositoryRoot $repositoryRoot (lines 118-121); $repositoryRoot is two Split-Path levels above $PSScriptRoot | .codex/hooks/enforce-epic-root-invocation.ps1:101
PROD-PATH: 3 | .codex/hooks/enforce-epic-wave-barrier.ps1:284 | Join-Path $primaryRoot, where $primaryRoot is the first worktree path printed by `git worktree list --porcelain` (Get-CodexPrimaryWorktreeRoot, lines 247-252), falling back to $repositoryRoot ($PSScriptRoot-derived, line 264) | .codex/hooks/enforce-epic-wave-barrier.ps1:279
PROD-PATH: 4 | .codex/hooks/enforce-epic-wave-barrier.ps1:274 | Get-Content -Raw of the launcher receipt path from runtime environment variable CODEX_EPIC_CHILD_LAUNCH_RECEIPT (Get-CodexEpicChildLaunchEnvironment), which the wave launcher sets from Join-Path $ArtifactRoot '<launch_id>.receipt.json' | .codex/hooks/codex-epic-child-launch-attestation.ps1:17
PROD-PATH: 5 | .codex/hooks/enforce-epic-wave-barrier.ps1:287 | Get-Content -Raw of $epicPath, which is the checkpoint_path field of the runtime launcher receipt (line 282) or Join-Path $primaryRoot (line 284, git worktree list output) | .codex/hooks/enforce-epic-wave-barrier.ps1:282
PROD-PATH: 7 | .codex/hooks/validate-codex-subagent-routing.ps1:119 | Get-ChildItem -LiteralPath $StateRoot -File, where $StateRoot is Get-CodexAuthorityStateRoot -RepositoryRoot $repositoryRoot (lines 148-151) and $repositoryRoot is two Split-Path levels above $PSScriptRoot | .codex/hooks/validate-codex-subagent-routing.ps1:143
PROD-PATH: 8 | .codex/hooks/validate-codex-subagent-routing.ps1:121 | Get-Content -Raw of a FullName enumerated at line 119 under the same $PSScriptRoot-derived state root | .codex/hooks/validate-codex-subagent-routing.ps1:148
PROD-PATH: 9 | .codex/hooks/validate-feature-review-coverage.ps1:55 | Join-Path $RepoRoot 'docs/features/active' in Get-LatestPolicyAudit; production caller passes Get-RepoRoot (two Split-Path levels above $PSScriptRoot, line 48) at line 258 | .codex/hooks/validate-feature-review-coverage.ps1:257
PROD-PATH: 10 | .codex/hooks/validate-feature-review-coverage.ps1:55 | same Get-LatestPolicyAudit Join-Path; $RepoRoot from Get-RepoRoot | .codex/hooks/validate-feature-review-coverage.ps1:48
PROD-PATH: 11 | .codex/hooks/validate-feature-review-coverage.ps1:67 | Join-Path $RepoRoot 'artifacts/pr_context.summary.txt' in Get-ChangedLanguageSet; production caller passes Get-RepoRoot at line 265 | .codex/hooks/validate-feature-review-coverage.ps1:257
PROD-PATH: 12 | .codex/hooks/validate-feature-review-coverage.ps1:67 | same Get-ChangedLanguageSet Join-Path; $RepoRoot from Get-RepoRoot | .codex/hooks/validate-feature-review-coverage.ps1:48
PROD-PATH: 13 | .codex/hooks/validate-feature-review-coverage.ps1:134 | Join-Path $RepoRoot 'coverage/lcov.info' (TypeScript) in Get-LanguageRepoCoverage; production caller passes $repoRoot at line 274 | .codex/hooks/validate-feature-review-coverage.ps1:257
PROD-PATH: 14 | .codex/hooks/validate-feature-review-coverage.ps1:135 | Join-Path $RepoRoot 'artifacts/python/lcov.info' (Python); $RepoRoot from Get-RepoRoot | .codex/hooks/validate-feature-review-coverage.ps1:257
PROD-PATH: 15 | .codex/hooks/validate-feature-review-coverage.ps1:136 | Join-Path $RepoRoot 'artifacts/pester/powershell-coverage.xml' (PowerShell); $RepoRoot from Get-RepoRoot | .codex/hooks/validate-feature-review-coverage.ps1:257
PROD-PATH: 16 | .codex/hooks/validate-feature-review-coverage.ps1:137 | Join-Path $RepoRoot 'artifacts/csharp/coverage.xml' (CSharp); $RepoRoot from Get-RepoRoot | .codex/hooks/validate-feature-review-coverage.ps1:257
PROD-PATH: 17 | .codex/hooks/validate-feature-review-coverage.ps1:264 | Get-Content -Path $audit.FullName -Raw, where $audit is the newest policy-audit file enumerated by Get-ChildItem under the $PSScriptRoot-derived repository root (line 258) | .codex/hooks/validate-feature-review-coverage.ps1:258
PROD-PATH: 18 | .codex/hooks/validate-feature-review-coverage.ps1:264 | same Get-Content of the enumerated audit FullName under the Get-RepoRoot-derived root | .codex/hooks/validate-feature-review-coverage.ps1:48

PROD-PATH-DRIVE-LITERAL: .codex/hooks/enforce-codex-model-routing.ps1 | 0
PROD-PATH-DRIVE-LITERAL: .codex/hooks/enforce-epic-root-invocation.ps1 | 0
PROD-PATH-DRIVE-LITERAL: .codex/hooks/enforce-epic-wave-barrier.ps1 | 0
PROD-PATH-DRIVE-LITERAL: .codex/hooks/validate-codex-subagent-routing.ps1 | 0
PROD-PATH-DRIVE-LITERAL: .codex/hooks/validate-feature-review-coverage.ps1 | 0

Note: the launcher receipt path for row 4 is assigned in production at .codex/scripts/launch-epic-child-wave.ps1:339 (Join-Path $ArtifactRoot "<launch_id>.receipt.json") and passed to the child through the environment; it is runtime output, not a literal. Mechanism B (row 6) is a test-session effect; in production each hook runs in a fresh process.

PRODUCTION-DEFECT: none

## Verdict

Timestamp: 2026-10-10T20-58
Command: derivation from the [P1-T2] SIM-CLASS lines, the [P1-T4] census, and the [P1-T5] production review, following the section 2 per-row cause table (no command run)
EXIT_CODE: 0
Output Summary: 17 rows are drive-literal fixture defects (each with a [P1-T2] SIM-CLASS line in its suite), fixed by E-FRC, E-CSR, E-CMR, E-ERI, E-EWB; row 6 is a stale module instance (INSTANCE-MISMATCH: yes), fixed by E-HDF. No production defect. VERDICT: test-only fixes identified.

ROW: 1 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1:118 | cause=drive-literal | hook=.codex/hooks/enforce-codex-model-routing.ps1:185 | fix=E-CMR
ROW: 2 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1:90 | cause=drive-literal | hook=.codex/hooks/enforce-epic-root-invocation.ps1:122 | fix=E-ERI
ROW: 3 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1:151 | cause=drive-literal | hook=.codex/hooks/enforce-epic-wave-barrier.ps1:284 | fix=E-EWB
ROW: 4 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1:168 | cause=drive-literal | hook=.codex/hooks/enforce-epic-wave-barrier.ps1:274 | fix=E-EWB
ROW: 5 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1:177 | cause=drive-literal | hook=.codex/hooks/enforce-epic-wave-barrier.ps1:287 | fix=E-EWB
ROW: 6 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:131 | cause=module-instance | hook=none | fix=E-HDF
ROW: 7 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1:85 | cause=drive-literal | hook=.codex/hooks/validate-codex-subagent-routing.ps1:119 | fix=E-CSR
ROW: 8 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1:92 | cause=drive-literal | hook=.codex/hooks/validate-codex-subagent-routing.ps1:119 | fix=E-CSR
ROW: 9 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:63 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:55 | fix=E-FRC
ROW: 10 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:69 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:55 | fix=E-FRC
ROW: 11 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:74 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:67 | fix=E-FRC
ROW: 12 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:80 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:67 | fix=E-FRC
ROW: 13 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:121 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:134 | fix=E-FRC
ROW: 14 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:121 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:135 | fix=E-FRC
ROW: 15 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:121 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:136 | fix=E-FRC
ROW: 16 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:121 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:137 | fix=E-FRC
ROW: 17 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:178 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:264 | fix=E-FRC
ROW: 18 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:186 | cause=drive-literal | hook=.codex/hooks/validate-feature-review-coverage.ps1:264 | fix=E-FRC

R6-CAUSE: module-instance
R6-CULPRIT: not isolated (ciorder prefix)
VERDICT: test-only fixes identified

Rows 13 to 16 are the four `-ForEach` rows of `It 'routes <Language> to its report'` (TypeScript, Python, PowerShell, CSharp), whose hook call sites are the four `Join-Path $RepoRoot` lines 134 to 137 of the switch that the section 2 table cites as `:134`. Every cause=drive-literal row has a [P1-T2] SIM-CLASS line in the same suite (validate-feature-review-coverage 10, validate-codex-subagent-routing 2, enforce-codex-model-routing 1, enforce-epic-root-invocation 1, enforce-epic-wave-barrier 3).
