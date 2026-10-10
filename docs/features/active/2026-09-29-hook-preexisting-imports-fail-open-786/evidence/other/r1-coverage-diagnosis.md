# Remediation Cycle 1 Coverage Loss Diagnosis (Phase 2, RF-1, AC-24)

Timestamp: 2026-10-10T09-02
Command: [P2-T1] <SCRATCHPAD>/r1-parse.ps1 (route sh, fresh process): [System.Management.Automation.Language.Parser]::ParseFile and Get-FileHash -Algorithm SHA256 on each section 3 diagnostic script. Later sections record the Phase 2 probe commands.
EXIT_CODE: 0
Output Summary: five diagnostic scripts written with the Write tool; each parses with 0 errors.

## Scripts

PARSE: <SCRATCHPAD>/r1-covprobe.ps1 | 0
PARSE: <SCRATCHPAD>/r1-loss.ps1 | 0
PARSE: <SCRATCHPAD>/r1-kmod.Tests.ps1 | 0
PARSE: <SCRATCHPAD>/r1-kfunc.Tests.ps1 | 0
PARSE: <SCRATCHPAD>/r1-kboth.Tests.ps1 | 0

SHA256: <SCRATCHPAD>/r1-covprobe.ps1 | 8E40EE7AC538186E76ED294E4A6FCE6DBA6D0796FF5DA840C180A5821DD011B6
SHA256: <SCRATCHPAD>/r1-loss.ps1 | 55EF119E84410B6977A6AA2FC69907EF8282043BD35FC7339AFE27EB10ACE247
SHA256: <SCRATCHPAD>/r1-kmod.Tests.ps1 | 56121B5428BEF74CF83E01FF3BB9346C0EE1A5E8F4202109D7499B1BE8C2299A
SHA256: <SCRATCHPAD>/r1-kfunc.Tests.ps1 | AE6F0FC6866B14DE955A8AF55558D941BACCB6269E8501256B55B001E64F3313
SHA256: <SCRATCHPAD>/r1-kboth.Tests.ps1 | 7C9E56F729717C0E3A45CB7BDBB330EC43B69E6FF83E0D804A3F77FFD6EB7DC2

T-SET input file <SCRATCHPAD>/r1-tset.txt holds the six T-SET paths recorded in r1-pester-coverage.md.

### <SCRATCHPAD>/r1-covprobe.ps1

```powershell
param([Parameter(Mandatory = $true)][string] $ListFile, [Parameter(Mandatory = $true)][string] $Label)
# R-COVPROBE (remediation plan section 3): Pester run with the R-PESTER coverage population and an explicit container list.
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
Import-Module Pester -MinimumVersion 5.0.0
Import-Module (Join-Path $root 'scripts/powershell/PoshQC/PoshQC.psd1') -Force
$settingsPath = Join-Path $root 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
$settings = Import-PowerShellDataFile -LiteralPath $settingsPath
$population = & (Get-Module PoshQC) { param($r, $s, $p) Resolve-PoshQCCoveragePopulation -Root $r -Settings $s -SettingsFile $p -ScanFolderRoots @('scripts', 'tests/powershell', 'tests/scripts') } $root $settings $settingsPath
$config = New-PesterConfiguration -Hashtable $settings
$list = @(Get-Content -LiteralPath $ListFile | Where-Object { $_ })
$paths = @($list | ForEach-Object { if ([IO.Path]::IsPathRooted($_)) { $_ } else { Join-Path $root $_ } })
$config.Run.Path = $paths
$config.Run.Exit = $false
$config.Run.PassThru = $true
$config.Output.Verbosity = 'Normal'
$config.TestResult.OutputPath = (Join-Path $PSScriptRoot "r1-probe-$Label-junit.xml")
$config.CodeCoverage.Path = @($population.Paths)
$config.CodeCoverage.OutputPath = (Join-Path $PSScriptRoot "r1-probe-$Label-coverage.xml")
$result = Invoke-Pester -Configuration $config
$rootSlash = ($root -replace '\\', '/')
$spSlash = ($PSScriptRoot -replace '\\', '/')
function ConvertTo-ProbeRelative([string] $p) {
    $n = $p -replace '\\', '/'
    if ($n.StartsWith($rootSlash + '/')) { return $n.Substring($rootSlash.Length + 1) }
    if ($n.StartsWith($spSlash + '/')) { return '<SCRATCHPAD>/' + $n.Substring($spSlash.Length + 1) }
    return $n
}
"POPULATION: source=$($population.Source) | files=$(@($population.Paths).Count)"
"PROBE: $Label | containers=$(@($result.Containers).Count) | passed=$($result.PassedCount) | failed=$($result.FailedCount) | failedContainers=$($result.FailedContainersCount)"
$i = 0
$order = @()
foreach ($c in $result.Containers) {
    $i++
    $rel = ConvertTo-ProbeRelative ([string]$c.Item)
    $order += $rel
    "ORDER: $i | $rel"
}
foreach ($c in $result.Containers) {
    $mine = @($result.Tests | Where-Object { [string]$_.ScriptBlock.File -eq [string]$c.Item })
    $p = @($mine | Where-Object { $_.Result -eq 'Passed' }).Count
    $fl = @($mine | Where-Object { $_.Result -eq 'Failed' }).Count
    "CONTAINER: $(ConvertTo-ProbeRelative ([string]$c.Item)) | passed=$p | failed=$fl"
}
foreach ($t in $result.Failed) {
    $msg = ''
    if ($t.ErrorRecord -and $t.ErrorRecord.Count -gt 0) { $msg = ([string]$t.ErrorRecord[0].Exception.Message -split "`r?`n")[0] }
    "FAILED: $($t.ExpandedName) | $msg"
}
$expected = @($paths | ForEach-Object { ConvertTo-ProbeRelative $_ })
$same = ($order.Count -eq $expected.Count)
if ($same) { for ($k = 0; $k -lt $order.Count; $k++) { if ($order[$k] -ne $expected[$k]) { $same = $false; break } } }
"ORDER-PRESERVED: $(if ($same) { 'yes' } else { 'no' })"
exit 0
```

### <SCRATCHPAD>/r1-loss.ps1

```powershell
param([Parameter(Mandatory = $true)][string] $Reference, [Parameter(Mandatory = $true)][string] $Candidate, [string] $TSetFile = '')
# R-LOSS (remediation plan section 3): lines covered in the reference and uncovered or absent in the candidate, per T-SET file.
$ErrorActionPreference = 'Stop'
if (-not $TSetFile) { $TSetFile = Join-Path $PSScriptRoot 'r1-tset.txt' }
$tset = @(Get-Content -LiteralPath $TSetFile | Where-Object { $_ })
function Get-RCovSourceFile([xml] $Xml, [string] $Path) {
    $dir = (Split-Path -Parent $Path) -replace '\\', '/'
    $leaf = Split-Path -Leaf $Path
    $pk = @($Xml.SelectNodes('//package') | Where-Object { $n = ($_.name -replace '\\', '/'); $n.EndsWith('/' + $dir) -and $n -notlike '*extensions/*' })
    return @($pk | ForEach-Object { $_.SelectNodes('sourcefile') } | Where-Object { $_.name -eq $leaf -or ($_.name -replace '\\', '/').EndsWith('/' + $leaf) })
}
[xml]$ref = Get-Content -LiteralPath $Reference -Raw
[xml]$cand = Get-Content -LiteralPath $Candidate -Raw
$lost = 0
foreach ($f in $tset) {
    $rs = Get-RCovSourceFile -Xml $ref -Path $f
    $cs = Get-RCovSourceFile -Xml $cand -Path $f
    if ($rs.Count -ne 1 -or $cs.Count -ne 1) { "SOURCEFILE-MISMATCH: $f | reference=$($rs.Count) | candidate=$($cs.Count)"; continue }
    $cmap = @{}; foreach ($ln in $cs[0].SelectNodes('line')) { $cmap[[int]$ln.nr] = [int]$ln.ci }
    foreach ($ln in $rs[0].SelectNodes('line')) {
        $nr = [int]$ln.nr
        if ([int]$ln.ci -gt 0 -and (-not $cmap.ContainsKey($nr) -or $cmap[$nr] -eq 0)) { "LOST-LINE: ${f}:$nr"; $lost++ }
    }
}
foreach ($f in $tset) {
    $cs = Get-RCovSourceFile -Xml $cand -Path $f
    if ($cs.Count -ne 1) { "COVERAGE: $f | n/a | covered=n/a | missed=n/a | SOURCEFILE_MATCHES: $($cs.Count)"; continue }
    $ctr = $cs[0].SelectSingleNode("counter[@type='LINE']")
    $cv = [int]$ctr.covered; $ms = [int]$ctr.missed
    $pct = if (($cv + $ms) -gt 0) { [math]::Round(100.0 * $cv / ($cv + $ms), 2) } else { 0 }
    "COVERAGE: $f | $($pct.ToString('0.00')) | covered=$cv | missed=$ms | SOURCEFILE_MATCHES: 1"
}
"LOSS: $(if ($lost -gt 0) { 'yes' } else { 'no' })"
```

### <SCRATCHPAD>/r1-kmod.Tests.ps1

```powershell
# K-MOD cleanup container (remediation plan section 3): removes modules loaded from .claude/ or .codex/.
Describe 'r1 K-MOD cleanup' {
    It 'removes repository hook and lib modules left in the session' {
        $root = ((Get-Location).Path -replace '\\', '/')
        $prefixes = @("$root/.claude/", "$root/.codex/")
        foreach ($module in @(Get-Module)) {
            $p = ([string]$module.Path) -replace '\\', '/'
            if (@($prefixes | Where-Object { $p.StartsWith($_) }).Count -gt 0) {
                [Console]::Error.WriteLine("MODULE-RESIDUE: $($module.Name) | $($p.Substring($root.Length + 1))")
                Remove-Module -ModuleInfo $module -Force
            }
        }
        $after = @(Get-Module | Where-Object { $p = ([string]$_.Path) -replace '\\', '/'; @($prefixes | Where-Object { $p.StartsWith($_) }).Count -gt 0 }).Count
        [Console]::Error.WriteLine("MODULE-RESIDUE-AFTER: $after")
        $true | Should -BeTrue
    }
}
```

### <SCRATCHPAD>/r1-kfunc.Tests.ps1

```powershell
# K-FUNC cleanup container (remediation plan section 3): removes functions defined from .claude/hooks/ or .codex/hooks/.
Describe 'r1 K-FUNC cleanup' {
    It 'removes repository hook functions left in the session' {
        $root = ((Get-Location).Path -replace '\\', '/')
        $prefixes = @("$root/.claude/hooks/", "$root/.codex/hooks/")
        foreach ($fn in @(Get-ChildItem -Path function:)) {
            $file = ([string]$fn.ScriptBlock.File) -replace '\\', '/'
            if (@($prefixes | Where-Object { $file.StartsWith($_) }).Count -gt 0) {
                [Console]::Error.WriteLine("FUNC-RESIDUE: $($fn.Name) | $($file.Substring($root.Length + 1))")
                for ($attempt = 0; $attempt -lt 5; $attempt++) {
                    $cmd = Get-Command -Name $fn.Name -CommandType Function -ErrorAction SilentlyContinue
                    if (-not $cmd) { break }
                    $cf = ([string]$cmd.ScriptBlock.File) -replace '\\', '/'
                    if (@($prefixes | Where-Object { $cf.StartsWith($_) }).Count -eq 0) { break }
                    Remove-Item -LiteralPath ('function:' + $fn.Name) -Force -ErrorAction SilentlyContinue
                }
            }
        }
        $after = @(Get-ChildItem -Path function: | Where-Object { $f2 = ([string]$_.ScriptBlock.File) -replace '\\', '/'; @($prefixes | Where-Object { $f2.StartsWith($_) }).Count -gt 0 }).Count
        [Console]::Error.WriteLine("FUNC-RESIDUE-AFTER: $after")
        $true | Should -BeTrue
    }
}
```

### <SCRATCHPAD>/r1-kboth.Tests.ps1

```powershell
# K-BOTH cleanup container (remediation plan section 3): the K-MOD body followed by the K-FUNC body.
Describe 'r1 K-BOTH cleanup' {
    It 'removes repository hook and lib modules and hook functions left in the session' {
        $root = ((Get-Location).Path -replace '\\', '/')
        $modPrefixes = @("$root/.claude/", "$root/.codex/")
        foreach ($module in @(Get-Module)) {
            $p = ([string]$module.Path) -replace '\\', '/'
            if (@($modPrefixes | Where-Object { $p.StartsWith($_) }).Count -gt 0) {
                [Console]::Error.WriteLine("MODULE-RESIDUE: $($module.Name) | $($p.Substring($root.Length + 1))")
                Remove-Module -ModuleInfo $module -Force
            }
        }
        $modAfter = @(Get-Module | Where-Object { $p = ([string]$_.Path) -replace '\\', '/'; @($modPrefixes | Where-Object { $p.StartsWith($_) }).Count -gt 0 }).Count
        [Console]::Error.WriteLine("MODULE-RESIDUE-AFTER: $modAfter")
        $fnPrefixes = @("$root/.claude/hooks/", "$root/.codex/hooks/")
        foreach ($fn in @(Get-ChildItem -Path function:)) {
            $file = ([string]$fn.ScriptBlock.File) -replace '\\', '/'
            if (@($fnPrefixes | Where-Object { $file.StartsWith($_) }).Count -gt 0) {
                [Console]::Error.WriteLine("FUNC-RESIDUE: $($fn.Name) | $($file.Substring($root.Length + 1))")
                for ($attempt = 0; $attempt -lt 5; $attempt++) {
                    $cmd = Get-Command -Name $fn.Name -CommandType Function -ErrorAction SilentlyContinue
                    if (-not $cmd) { break }
                    $cf = ([string]$cmd.ScriptBlock.File) -replace '\\', '/'
                    if (@($fnPrefixes | Where-Object { $cf.StartsWith($_) }).Count -eq 0) { break }
                    Remove-Item -LiteralPath ('function:' + $fn.Name) -Force -ErrorAction SilentlyContinue
                }
            }
        }
        $fnAfter = @(Get-ChildItem -Path function: | Where-Object { $f2 = ([string]$_.ScriptBlock.File) -replace '\\', '/'; @($fnPrefixes | Where-Object { $f2.StartsWith($_) }).Count -gt 0 }).Count
        [Console]::Error.WriteLine("FUNC-RESIDUE-AFTER: $fnAfter")
        $true | Should -BeTrue
    }
}
```

### Script revision during [P2-T2]

The first R-LOSS invocation stopped with "You cannot call a method on a null-valued expression": a single matching `sourcefile` returned from `Get-RCovSourceFile` unrolled to one XmlElement, so `[0]` used the XmlNode name indexer. The three call sites were wrapped in `@()`. No probe result was read from the failed invocation. Re-parse in a fresh process:

PARSE: <SCRATCHPAD>/r1-loss.ps1 | 0
SHA256: <SCRATCHPAD>/r1-loss.ps1 | B70A91DF6CB0C275BA4884E13309622D16B9ADC8A57FD0CCAF60F0AF3234F34D

Revised text:

```powershell
param([Parameter(Mandatory = $true)][string] $Reference, [Parameter(Mandatory = $true)][string] $Candidate, [string] $TSetFile = '')
# R-LOSS (remediation plan section 3): lines covered in the reference and uncovered or absent in the candidate, per T-SET file.
$ErrorActionPreference = 'Stop'
if (-not $TSetFile) { $TSetFile = Join-Path $PSScriptRoot 'r1-tset.txt' }
$tset = @(Get-Content -LiteralPath $TSetFile | Where-Object { $_ })
function Get-RCovSourceFile([xml] $Xml, [string] $Path) {
    $dir = (Split-Path -Parent $Path) -replace '\\', '/'
    $leaf = Split-Path -Leaf $Path
    $pk = @($Xml.SelectNodes('//package') | Where-Object { $n = ($_.name -replace '\\', '/'); $n.EndsWith('/' + $dir) -and $n -notlike '*extensions/*' })
    return @($pk | ForEach-Object { $_.SelectNodes('sourcefile') } | Where-Object { $_.name -eq $leaf -or ($_.name -replace '\\', '/').EndsWith('/' + $leaf) })
}
[xml]$ref = Get-Content -LiteralPath $Reference -Raw
[xml]$cand = Get-Content -LiteralPath $Candidate -Raw
$lost = 0
foreach ($f in $tset) {
    $rs = @(Get-RCovSourceFile -Xml $ref -Path $f)
    $cs = @(Get-RCovSourceFile -Xml $cand -Path $f)
    if ($rs.Count -ne 1 -or $cs.Count -ne 1) { "SOURCEFILE-MISMATCH: $f | reference=$($rs.Count) | candidate=$($cs.Count)"; continue }
    $cmap = @{}; foreach ($ln in $cs[0].SelectNodes('line')) { $cmap[[int]$ln.nr] = [int]$ln.ci }
    foreach ($ln in $rs[0].SelectNodes('line')) {
        $nr = [int]$ln.nr
        if ([int]$ln.ci -gt 0 -and (-not $cmap.ContainsKey($nr) -or $cmap[$nr] -eq 0)) { "LOST-LINE: ${f}:$nr"; $lost++ }
    }
}
foreach ($f in $tset) {
    $cs = @(Get-RCovSourceFile -Xml $cand -Path $f)
    if ($cs.Count -ne 1) { "COVERAGE: $f | n/a | covered=n/a | missed=n/a | SOURCEFILE_MATCHES: $($cs.Count)"; continue }
    $ctr = $cs[0].SelectSingleNode("counter[@type='LINE']")
    $cv = [int]$ctr.covered; $ms = [int]$ctr.missed
    $pct = if (($cv + $ms) -gt 0) { [math]::Round(100.0 * $cv / ($cv + $ms), 2) } else { 0 }
    "COVERAGE: $f | $($pct.ToString('0.00')) | covered=$cv | missed=$ms | SOURCEFILE_MATCHES: 1"
}
"LOSS: $(if ($lost -gt 0) { 'yes' } else { 'no' })"
```

## [P2-T2] Reference run X-S

## Cycle 1

Command: <SCRATCHPAD>/r1-covprobe.ps1 -ListFile <SCRATCHPAD>/xs-c1.list -Label xs-c1 (list S from <SCRATCHPAD>/r1-c0-junit.xml, 61 containers; route sh); <SCRATCHPAD>/r1-drive.ps1 -Label xs-c1 -NoProbe (R-COV on <SCRATCHPAD>/r1-probe-xs-c1-coverage.xml for each T-SET file, through r1-loss.ps1 with the probe XML as both reference and candidate)
EXIT_CODE: 0

T-SET coverage in X-S:

```text
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
```

S-ONLY-FLOOR: met
ORDER-PRESERVED: yes

Probe output (full):

```text

Starting discovery in 61 files.
Discovery found 1652 tests in 3.7s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 2.29s (1.21s|785ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 552ms (257ms|180ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 19.8s (19.63s|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 466ms (303ms|104ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 688ms (567ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 250ms (166ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 960ms (856ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 368ms (231ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 118ms (46ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 427ms (206ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 383ms (226ms|101ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 911ms (753ms|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 243ms (123ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 43.34s (43.28s|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 39.91s (39.79s|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 311ms (160ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 328ms (226ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 251ms (149ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 538ms (442ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 190ms (131ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 199ms (117ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 184ms (93ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 132ms (62ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 165ms (93ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 1.3s (1.15s|123ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 601ms (490ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 832ms (705ms|103ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 386ms (285ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 545ms (427ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 807ms (684ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 2.38s (2.24s|100ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 318ms (254ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 5.65s (5.39s|186ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 944ms (775ms|125ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 1.28s (1.17s|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.62s (1.46s|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 385ms (264ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 343ms (199ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 215ms (142ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 253ms (181ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 868ms (778ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 509ms (403ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 386ms (297ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 195ms (110ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 631ms (545ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 353ms (247ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 6.57s (6.43s|96ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 311ms (228ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 215ms (146ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 251ms (110ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 470ms (356ms|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 270ms (142ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 5.55s (4.57s|151ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 172ms (88ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 742ms (653ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 16.52s (16.37s|108ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 181ms (122ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 542ms (429ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 206ms (158ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 201ms (134ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 420ms (339ms|51ms)
Tests completed in 166.66s
Tests Passed: 1652, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 24.8% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: xs-c1 | containers=61 | passed=1652 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
ORDER-PRESERVED: yes
```

## [P2-T3] Control loss

## Cycle 1

Command: <SCRATCHPAD>/r1-drive.ps1 -Label c0loss -NoProbe -Candidate r1-c0-coverage.xml (R-LOSS: -Reference <SCRATCHPAD>/r1-probe-xs-c1-coverage.xml -Candidate <SCRATCHPAD>/r1-c0-coverage.xml)
EXIT_CODE: 0

CONTROL-LOSS: yes

```text
R-LOSS:
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:96
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:97
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:98
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:100
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:101
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:102
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:103
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:104
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:105
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:106
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:109
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:110
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:111
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:121
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:144
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:149
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:152
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:168
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:180
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:244
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:245
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:246
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:247
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:248
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:249
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:252
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:254
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:257
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:260
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:261
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:263
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:127
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:134
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:135
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:137
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:153
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:175
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:176
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:187
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:189
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:192
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:195
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:196
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:197
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:222
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:227
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:241
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:244
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:248
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:300
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:103
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:104
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:105
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:107
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:108
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:109
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:110
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:111
LOST-LINE: .codex/hooks/validate-bash.ps1:98
LOST-LINE: .codex/hooks/validate-bash.ps1:99
LOST-LINE: .codex/hooks/validate-bash.ps1:102
LOST-LINE: .codex/hooks/validate-bash.ps1:156
LOST-LINE: .codex/hooks/validate-bash.ps1:177
LOST-LINE: .codex/hooks/validate-bash.ps1:304
LOST-LINE: .codex/hooks/validate-bash.ps1:305
LOST-LINE: .codex/hooks/validate-bash.ps1:306
LOST-LINE: .codex/hooks/validate-bash.ps1:309
LOST-LINE: .codex/hooks/validate-bash.ps1:310
LOST-LINE: .codex/hooks/validate-bash.ps1:311
LOST-LINE: .codex/hooks/validate-bash.ps1:312
LOST-LINE: .codex/hooks/validate-bash.ps1:313
LOST-LINE: .codex/hooks/validate-bash.ps1:315
LOST-LINE: .codex/hooks/validate-bash.ps1:317
LOST-LINE: .codex/hooks/validate-bash.ps1:318
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:143
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:375
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:449
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:454
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:471
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:472
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:477
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:478
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:479
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:480
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:482
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:488
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:489
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:490
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:491
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:492
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:493
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:496
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:498
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:499
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:117
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 74.70 | covered=124 | missed=42 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 82.25 | covered=139 | missed=30 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 57.89 | covered=11 | missed=8 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 80.25 | covered=65 | missed=16 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 86.55 | covered=148 | missed=23 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.09 | covered=154 | missed=3 | SOURCEFILE_MATCHES: 1
LOSS: yes
```

## [P2-T4] Side test and probe fidelity

## Cycle 1

Commands: <SCRATCHPAD>/r1-drive.ps1 -Label side-pre-c1 (list PRE then S, 299 entries); <SCRATCHPAD>/r1-drive.ps1 -Label side-post-c1 (list S then POST, 103 entries); <SCRATCHPAD>/r1-drive.ps1 -Label x1-c1 (list L, 341 entries). Each runs R-COVPROBE in a fresh child process and then R-LOSS against <SCRATCHPAD>/r1-probe-xs-c1-coverage.xml; R-VALID by <SCRATCHPAD>/r1-valid.ps1.
EXIT_CODE: 0

SIDE-RUN: pre | containers=299 | passed=8759 | failed=38 | ORDER-PRESERVED: yes | R-VALID: valid (61 S containers, 0 mismatches) | LOSS: no
SIDE-RUN: post | containers=103 | passed=2350 | failed=0 | ORDER-PRESERVED: yes | R-VALID: valid (61 S containers, 0 mismatches) | LOSS: no
X1: containers=341 | passed=9457 | failed=38 | ORDER-PRESERVED: yes | R-VALID: valid (61 S containers, 0 mismatches) | LOSS: yes (47 LOST-LINE lines: hook-dependency-guard.ps1, validate-bash.ps1, enforce-orchestration-preimplementation-gate.ps1)

SIDE: neither
PROBE-FIDELITY: reproduced

Observation: the 38 failed tests in the PRE and X1 probe runs are all in the PRE container tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 (`The term Get-OrchestratorStateIssueAdoptionResult is not recognized`). The same container passes under R-PESTER (C0 root failures 0). The container is outside S, so R-VALID is unaffected. X1 reproduces the control loss on three of the six T-SET files (hook-dependency-guard.ps1 57.89, validate-bash.ps1 80.25, enforce-orchestration-preimplementation-gate.ps1 86.55, the same values as C0) but not on enforce-epic-child-worktree-binding.ps1 or enforce-epic-planning-only.ps1.

S+POST run (side-post-c1) output:

```text

Starting discovery in 103 files.
Discovery found 2359 tests in 3.85s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 1.14s (568ms|358ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 257ms (140ms|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 21.32s (21.26s|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 430ms (319ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 577ms (498ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 187ms (128ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 1.18s (1.1s|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 497ms (338ms|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 159ms (60ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 418ms (328ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 300ms (171ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 1.2s (1.02s|138ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 277ms (130ms|97ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 38.5s (38.45s|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 30.04s (29.93s|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 484ms (299ms|126ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 541ms (362ms|150ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 270ms (174ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 457ms (349ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 129ms (73ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 234ms (130ms|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 271ms (190ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 167ms (91ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 243ms (152ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 1.23s (1.12s|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 396ms (325ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 475ms (412ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 213ms (146ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 369ms (301ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 739ms (639ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 1.37s (1.26s|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 267ms (203ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 4.86s (4.63s|173ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 981ms (793ms|155ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 1.7s (1.61s|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.87s (1.64s|173ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 612ms (464ms|122ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 537ms (366ms|138ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 351ms (263ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 390ms (325ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 1.56s (1.42s|121ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 549ms (444ms|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 354ms (278ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 193ms (128ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 579ms (503ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 282ms (208ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 6.16s (6.05s|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 345ms (277ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 202ms (155ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 210ms (101ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 515ms (414ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 389ms (229ms|112ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 5.17s (4.58s|128ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 148ms (69ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 561ms (505ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 12.39s (12.29s|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 147ms (77ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 505ms (389ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 190ms (135ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 208ms (129ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 432ms (336ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-scripts\codex-routing-cli-common.Tests.ps1 216ms (118ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-scripts\Resolve-CodexRouting.Parity.Tests.ps1 7.91s (7.8s|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\activate.Tests.ps1 300ms (166ms|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\agents-attribution.Tests.ps1 62ms (5ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Enter-DrmCopilotShell.Tests.ps1 82ms (26ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullRelease.Tests.ps1 746ms (600ms|98ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 321ms (238ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 243ms (160ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullReleaseFlow.Tests.ps1 497ms (369ms|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-MarketplacePublish.Tests.ps1 402ms (264ms|96ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseReconciliation.Tests.ps1 76ms (23ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseTagPush.Tests.ps1 979ms (805ms|132ms)
Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.
Publish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.
Publish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 433ms (361ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseVerification.Tests.ps1 748ms (612ms|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseVerificationHelpers.Tests.ps1 114ms (35ms|59ms)
What if: Performing the operation "Update section content" on target "## Feature Docs".
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\link-feature-docs.Tests.ps1 285ms (213ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\link-parent-child.Tests.ps1 672ms (575ms|67ms)
What if: Performing the operation "Create worktree grouping directory" on target "/parent/auth-wt".
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\new-claude-worktree-session.Tests.ps1 316ms (146ms|122ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\new-potential-entry.TemplateRoot.Tests.ps1 307ms (252ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\new-potential-entry.Tests.ps1 488ms (342ms|107ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\post-codex-worktree-session.Tests.ps1 280ms (198ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\publish-sideloaded-extension.Tests.ps1 264ms (170ms|48ms)
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\run-actionlint.Tests.ps1 1.01s (869ms|101ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1 578ms (461ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\tree.Tests.ps1 331ms (205ms|79ms)
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: Package
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Packaging to \repo\artifacts\vsix\drm-copilot-0.0.2-20261010-091258.vsix...

[5/5] Package complete. Install locally with:
      code --install-extension "\repo\artifacts\vsix\drm-copilot-0.0.2-20261010-091258.vsix"
      Marketplace upload and the release tag are performed by CI
      (.github/workflows/publish-extension.yml) after the bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm install...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm install...
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 2
    docs/internal.md

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: Package
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Packaging to \repo\artifacts\vsix\drm-copilot-0.0.2-20261010-091259.vsix...
drm-copilot package script - mode: DryRun
Extension directory: <WORKSPACE_ROOT>\extensions\drm-copilot

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\Publish-DrmCopilotExtension.Tests.ps1 577ms (453ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1 82ms (35ms|30ms)
Already formatted: /repo/test.ps1
Formatted: /repo/test.ps1
Already formatted: /repo/test.ps1
PSScriptAnalyzer passed: no findings under /repo
PSScriptAnalyzer passed: no findings under /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 1.26s (1.05s|124ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1 363ms (283ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1 188ms (114ms|46ms)
No PowerShell files found under <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 190ms (126ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1 134ms (64ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 359ms (263ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 127ms (73ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1 97ms (50ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1 93ms (45ms|25ms)
Coverage file not found; skipping Koverage output: <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 148ms (82ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 303ms (181ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 54ms (7ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 97ms (41ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 121ms (43ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 65ms (11ms|31ms)
Tests completed in 168.89s
Tests Passed: 2350, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 34.33% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: side-post-c1 | containers=103 | passed=2350 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 62 | tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1
ORDER: 63 | tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
ORDER: 64 | tests/scripts/dev-tools/activate.Tests.ps1
ORDER: 65 | tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER: 66 | tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER: 67 | tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER: 68 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER: 69 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER: 70 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER: 71 | tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER: 72 | tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER: 73 | tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER: 74 | tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER: 75 | tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER: 76 | tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER: 77 | tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER: 78 | tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER: 79 | tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER: 80 | tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER: 81 | tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER: 82 | tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER: 83 | tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER: 84 | tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER: 85 | tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER: 86 | tests/scripts/dev-tools/tree.Tests.ps1
ORDER: 87 | tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1
ORDER: 88 | tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1
ORDER: 89 | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1
ORDER: 90 | tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1
ORDER: 91 | tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1
ORDER: 92 | tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1
ORDER: 93 | tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
ORDER: 94 | tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
ORDER: 95 | tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1
ORDER: 96 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1
ORDER: 97 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1
ORDER: 98 | tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1
ORDER: 99 | tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1
ORDER: 100 | tests/scripts/workflows/CiWorkflow.Tests.ps1
ORDER: 101 | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
ORDER: 102 | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
ORDER: 103 | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/activate.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/agents-attribution.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | passed=33 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/dev-tools/run-actionlint.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/dev-tools/tree.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | passed=4 | failed=0
ORDER-PRESERVED: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 2350, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: side-post-c1 | containers=103 | passed=2350 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 62 | tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1
ORDER: 63 | tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
ORDER: 64 | tests/scripts/dev-tools/activate.Tests.ps1
ORDER: 65 | tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER: 66 | tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER: 67 | tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER: 68 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER: 69 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER: 70 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER: 71 | tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER: 72 | tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER: 73 | tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER: 74 | tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER: 75 | tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER: 76 | tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER: 77 | tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER: 78 | tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER: 79 | tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER: 80 | tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER: 81 | tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER: 82 | tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER: 83 | tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER: 84 | tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER: 85 | tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER: 86 | tests/scripts/dev-tools/tree.Tests.ps1
ORDER: 87 | tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1
ORDER: 88 | tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1
ORDER: 89 | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1
ORDER: 90 | tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1
ORDER: 91 | tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1
ORDER: 92 | tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1
ORDER: 93 | tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
ORDER: 94 | tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
ORDER: 95 | tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1
ORDER: 96 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1
ORDER: 97 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1
ORDER: 98 | tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1
ORDER: 99 | tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1
ORDER: 100 | tests/scripts/workflows/CiWorkflow.Tests.ps1
ORDER: 101 | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
ORDER: 102 | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
ORDER: 103 | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/activate.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/agents-attribution.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | passed=33 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/dev-tools/run-actionlint.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/dev-tools/tree.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | passed=4 | failed=0
ORDER-PRESERVED: yes
R-LOSS:
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
LOSS: no
```
```text

Starting discovery in 299 files.
Discovery found 8798 tests in 40.38s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 522ms (164ms|259ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 174ms (115ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 4.28s (4.1s|142ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 212ms (118ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 280ms (240ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 142ms (96ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 167ms (93ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 105ms (63ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 126ms (72ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 98ms (46ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 401ms (253ms|118ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 336ms (210ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 189ms (137ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 168ms (87ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 993ms (922ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 194ms (78ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 300ms (245ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 554ms (481ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 1.38s (1.19s|148ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 597ms (525ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 999ms (902ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 708ms (577ms|106ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 546ms (401ms|113ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 395ms (318ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 407ms (339ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 1.87s (1.75s|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 1.01s (841ms|112ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 216ms (160ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 273ms (219ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 138ms (55ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 344ms (240ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 168ms (106ms|28ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 156.91s (125.61s|270ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 141ms (95ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 413ms (344ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 632ms (539ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 2.12s (2.03s|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 227ms (185ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 243ms (182ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.83s (1.78s|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 373ms (297ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 224ms (178ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 175ms (100ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 272ms (171ms|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 49ms (12ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 373ms (291ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 540ms (365ms|145ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 44ms (9ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 633ms (528ms|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 2.67s (2.5s|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 124ms (86ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 4.09s (3.93s|128ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 788ms (716ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 992ms (925ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 249ms (215ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 3.4s (3.35s|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 1.24s (1.11s|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 539ms (454ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 743ms (689ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 317ms (266ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 232ms (168ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 128ms (88ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 262ms (207ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 139ms (101ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 482ms (331ms|116ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 314ms (253ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 241ms (173ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 282ms (213ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 486ms (382ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 216ms (169ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 426ms (380ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 1.61s (1.52s|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 1.13s (996ms|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 203ms (162ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 309ms (262ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 304ms (216ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 229ms (163ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 524ms (449ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 1.88s (1.79s|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 337ms (301ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 1.07s (1.03s|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 4.67s (4.6s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 6.6s (6.53s|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.18s (1.13s|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 397ms (351ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 1.61s (1.57s|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 2.3s (2.16s|118ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 1.73s (1.63s|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 6.97s (6.9s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 386ms (311ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 729ms (604ms|90ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 549ms (459ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 636ms (556ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 487ms (373ms|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 1.32s (1.22s|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 270ms (212ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 241ms (201ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 286ms (202ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 257ms (176ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 439ms (200ms|217ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 2.29s (2.14s|133ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 2.55s (2.36s|165ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 3.14s (2.83s|270ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 4.09s (3.93s|136ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 791ms (643ms|124ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 1.05s (934ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 1.29s (1.12s|145ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 178ms (94ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 261ms (159ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 7.92s (7.19s|214ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 4.2s (1.67s|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 135ms (77ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 3.54s (3.38s|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 409ms (295ms|90ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 748ms (487ms|227ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 2.5s (2.4s|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 2.36s (2.3s|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 459ms (367ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 286ms (222ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 1.15s (1.03s|97ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 142ms (89ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 184ms (113ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 910ms (733ms|120ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 224ms (143ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 1.68s (1.57s|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 1.69s (1.59s|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 906ms (826ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 1.2s (1.11s|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 1.51s (1.36s|129ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 1.35s (1.28s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 1.86s (1.75s|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 142ms (75ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 604ms (474ms|102ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 141ms (57ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 2.85s (2.74s|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 141ms (71ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 364ms (276ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 318ms (173ms|132ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 451ms (298ms|130ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ClaudeLibModuleConvention.Tests.ps1 2.12s (2.06s|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1 2.75s (2.58s|134ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1 72.75s (72.7s|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.KeyPartition.Tests.ps1 68ms (23ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Manifest.Tests.ps1 64ms (20ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Parity.Tests.ps1 3.69s (3.51s|112ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Regression452.Tests.ps1 1.35s (1.25s|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Tests.ps1 1.59s (1.48s|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.TruthTable.Tests.ps1 1.09s (999ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Validation.Tests.ps1 1.14s (1.01s|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConfig.Tests.ps1 411ms (243ms|130ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.OverlappingPairs.Tests.ps1 985ms (934ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.PathOverlap.Tests.ps1 980ms (915ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.Tests.ps1 1.47s (1.41s|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Path.Tests.ps1 298ms (168ms|99ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Tests.ps1 130ms (54ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.RegexCache.Tests.ps1 123ms (44ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.Tests.ps1 236ms (85ms|116ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusNormalization.Tests.ps1 812ms (735ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.PairCost.Tests.ps1 562ms (505ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.Tests.ps1 2.57s (2.44s|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.Tests.ps1 141ms (50ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusWriteIntent.Tests.ps1 1.94s (1.88s|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1 51ms (15ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 115ms (43ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1 78ms (26ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 69ms (33ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1 140ms (74ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexRouting.Manifest.Tests.ps1 78ms (22ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexTopology.Parity.Tests.ps1 156ms (76ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Manifest.Tests.ps1 45ms (13ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Tests.ps1 215ms (131ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.VersionFloor.Tests.ps1 84ms (32ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\hook-payload\HookPayload.Tests.ps1 228ms (87ms|110ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidGrammar.Tests.ps1 325ms (204ms|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidLineScanner.Tests.ps1 282ms (169ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidMarkdownFences.Tests.ps1 167ms (69ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidValidation.Tests.ps1 465ms (365ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidValidationAcceptMatrix.Tests.ps1 356ms (289ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\Get-ComplexityFloor.Tests.ps1 114ms (45ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\ModelRouting.Manifest.Tests.ps1 61ms (19ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\ModelRouting.Parity.Tests.ps1 134ms (68ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\Resolve-DelegationModel.Tests.ps1 165ms (74ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Manifest.Tests.ps1 212ms (158ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1 797ms (667ms|105ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.ValueContract.Tests.ps1 122ms (69ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Backcompat.Tests.ps1 1.04s (949ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Parity.Tests.ps1 519ms (414ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Tests.ps1 250ms (142ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCheckpointValue.Tests.ps1 359ms (184ms|153ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1 489ms (400ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexTopologyReceipts.Tests.ps1 467ms (382ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletion.Tests.ps1 2.45s (2.31s|104ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletionChecks.Tests.ps1 307ms (184ms|104ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 291ms (221ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateEpicWaveBarrier.Tests.ps1 184ms (108ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Parity.Tests.ps1 941ms (810ms|101ms)
[-] Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone 39ms (39ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:120
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record 36ms (35ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:127
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record 35ms (34ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:134
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route 35ms (34ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:140
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred 35ms (35ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration 35ms (34ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition 28ms (28ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view 44ms (43ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get 32ms (31ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read 27ms (26ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string 34ms (33ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer 31ms (30ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list 27ms (26ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a null adoption value 28ms (27ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:173
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an integer issue number 23ms (22ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:179
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number 19ms (19ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:186
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num 23ms (22ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:193
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number 18ms (18ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:200
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an unknown origin 28ms (28ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:206
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an unknown verification source 33ms (33ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:211
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an absent verification time 18ms (18ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:216
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a null verification time 17ms (17ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:221
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time 19ms (19ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:226
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects empty evidence 25ms (24ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:231
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an empty waived list 29ms (29ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:236
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string 20ms (19ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry 19ms (18ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry 17ms (16ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool 18ms (17ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:253
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool 18ms (18ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:260
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool 22ms (21ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:270
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool 18ms (17ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:277
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint 29ms (29ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:283
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route 32ms (31ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:288
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt 36ms (36ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:293
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice 31ms (31ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:299
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid 27ms (26ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:329
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key 26ms (26ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:349
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateModelReceipts.Tests.ps1 288ms (182ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStatePromotionType.Parity.Tests.ps1 357ms (258ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateReceipts.Tests.ps1 224ms (140ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationAccounting.Tests.ps1 409ms (268ms|106ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 1.06s (982ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Parity.Tests.ps1 1.06s (919ms|123ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingContract.Tests.ps1 433ms (351ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingMatrix.Tests.ps1 160ms (90ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateUnconditional.Tests.ps1 359ms (284ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\Invoke-ParallelDriftDetection.Tests.ps1 2.26s (2.17s|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Manifest.Tests.ps1 77ms (28ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Parity.Tests.ps1 1.21s (1.15s|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Tests.ps1 946ms (896ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDriftHalt.Tests.ps1 131ms (69ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Manifest.Tests.ps1 63ms (26ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Tests.ps1 241ms (173ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\ProjectFileMergeGrammar.Tests.ps1 83ms (38ms|29ms)
What if: Performing the operation "Write the merged project file" on target "<WORKSPACE_ROOT>\tests\fixtures\project_file_merge\whatif-never-written.csproj".
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\Resolve-MergeableConflict.Tests.ps1 365ms (315ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\requirements\GeneratedDocumentCounters.Tests.ps1 44ms (10ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1 127ms (62ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1 204ms (151ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1 537ms (441ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1 161ms (120ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1 339ms (252ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1 90ms (48ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1 363ms (241ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1 356ms (294ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1 81ms (36ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1 247ms (197ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1 482ms (394ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1 103ms (68ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-architecture-doc.Tests.ps1 65ms (21ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-runtime-structure.Tests.ps1 52ms (22ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-settings.Tests.ps1 81ms (41ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-checkpoint-path-explicit.Tests.ps1 3.18s (3.13s|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 5.88s (5.8s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1 32.69s (32.1s|490ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-import-failure-exemptions.Guard.Tests.ps1 19.5s (19.45s|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1 31.72s (31.67s|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\legacy-discovery-agent-roles.Tests.ps1 94ms (44ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\test-name-uniqueness.Tests.ps1 5.06s (5.02s|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 347ms (263ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 147ms (48ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 13.89s (13.86s|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 108ms (67ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 261ms (209ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 86ms (46ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 494ms (450ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 404ms (289ms|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 121ms (59ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 283ms (196ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 233ms (130ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 300ms (221ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 168ms (79ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 31.35s (31.31s|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 27.63s (27.55s|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 222ms (148ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 280ms (201ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 180ms (117ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 304ms (255ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 107ms (69ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 148ms (93ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 137ms (71ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 82ms (38ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 105ms (61ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 647ms (583ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 294ms (237ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 474ms (409ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 250ms (183ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 331ms (258ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 427ms (364ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 1.91s (1.81s|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 520ms (446ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 5.82s (5.54s|238ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 511ms (391ms|100ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 1.14s (1.07s|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.71s (1.54s|150ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 447ms (345ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 512ms (331ms|144ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 364ms (280ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 314ms (268ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 858ms (777ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 370ms (294ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 372ms (289ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 231ms (159ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 657ms (572ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 459ms (361ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 7.59s (7.43s|134ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 624ms (513ms|96ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 260ms (183ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 271ms (156ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 517ms (392ms|105ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 383ms (235ms|124ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 6.29s (5.85s|253ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 154ms (73ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 517ms (462ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 13.31s (13.21s|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 136ms (96ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 508ms (430ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 175ms (142ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 195ms (127ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 375ms (309ms|50ms)
Tests completed in 646s
Tests Passed: 8759, Failed: 38, Skipped: 1, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 79.7% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: side-pre-c1 | containers=299 | passed=8759 | failed=38 | failedContainers=0
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
ORDER: 140 | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER: 141 | tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
ORDER: 142 | tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
ORDER: 143 | tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
ORDER: 144 | tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1
ORDER: 145 | tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
ORDER: 146 | tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1
ORDER: 147 | tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
ORDER: 148 | tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
ORDER: 149 | tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1
ORDER: 150 | tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1
ORDER: 151 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1
ORDER: 152 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1
ORDER: 153 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1
ORDER: 154 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
ORDER: 155 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1
ORDER: 156 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1
ORDER: 157 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1
ORDER: 158 | tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
ORDER: 159 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1
ORDER: 160 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
ORDER: 161 | tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
ORDER: 162 | tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
ORDER: 163 | tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1
ORDER: 164 | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
ORDER: 165 | tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1
ORDER: 166 | tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
ORDER: 167 | tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1
ORDER: 168 | tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1
ORDER: 169 | tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1
ORDER: 170 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1
ORDER: 171 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1
ORDER: 172 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1
ORDER: 173 | tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1
ORDER: 174 | tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1
ORDER: 175 | tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1
ORDER: 176 | tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1
ORDER: 177 | tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1
ORDER: 178 | tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1
ORDER: 179 | tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1
ORDER: 180 | tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1
ORDER: 181 | tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1
ORDER: 182 | tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1
ORDER: 183 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1
ORDER: 184 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1
ORDER: 185 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1
ORDER: 186 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1
ORDER: 187 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1
ORDER: 188 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1
ORDER: 189 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1
ORDER: 190 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1
ORDER: 191 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1
ORDER: 192 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1
ORDER: 193 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1
ORDER: 194 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1
ORDER: 195 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1
ORDER: 196 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
ORDER: 197 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
ORDER: 198 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1
ORDER: 199 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1
ORDER: 200 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1
ORDER: 201 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1
ORDER: 202 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1
ORDER: 203 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1
ORDER: 204 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1
ORDER: 205 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1
ORDER: 206 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1
ORDER: 207 | tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1
ORDER: 208 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1
ORDER: 209 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1
ORDER: 210 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1
ORDER: 211 | tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1
ORDER: 212 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
ORDER: 213 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1
ORDER: 214 | tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1
ORDER: 215 | tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
ORDER: 216 | tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1
ORDER: 217 | tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1
ORDER: 218 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1
ORDER: 219 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
ORDER: 220 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
ORDER: 221 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1
ORDER: 222 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
ORDER: 223 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
ORDER: 224 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
ORDER: 225 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1
ORDER: 226 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1
ORDER: 227 | tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
ORDER: 228 | tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
ORDER: 229 | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
ORDER: 230 | tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1
ORDER: 231 | tests/scripts/claude-runtime/claude-settings.Tests.ps1
ORDER: 232 | tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1
ORDER: 233 | tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
ORDER: 234 | tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
ORDER: 235 | tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
ORDER: 236 | tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
ORDER: 237 | tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1
ORDER: 238 | tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
ORDER: 239 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 240 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 241 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 242 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 243 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 244 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 245 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 246 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 247 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 248 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 249 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 250 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 251 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 252 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 253 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 254 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 255 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 256 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 257 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 258 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 259 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 260 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 261 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 262 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 263 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 264 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 265 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 266 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 267 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 268 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 269 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 270 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 271 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 272 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 273 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 274 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 275 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 276 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 277 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 278 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 279 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 280 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 281 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 282 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 283 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 284 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 285 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 286 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 287 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 288 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 289 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 290 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 291 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 292 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 293 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 294 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 295 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 296 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 297 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 298 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 299 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | passed=80 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | passed=100 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | passed=4 | failed=38
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | passed=95 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | passed=27 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | passed=598 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
FAILED: accepts a feature checkpoint waiving potential_to_issue alone | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a feature checkpoint waiving the feature entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a bug checkpoint waiving the bug entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the same record on the preparation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value transferred | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value filed_before_orchestration | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value epic_decomposition | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_issue_view | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_api_get | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source github_mcp_issue_read | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind integer | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null adoption value | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an integer issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a leading-zero issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue number that differs from the checkpoint issue-num | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue URL that does not end with the issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown origin | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown verification source | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an absent verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a whitespace-only verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects empty evidence | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an empty waived list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind blank-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind integer-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a waived list that omits the issue-creation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an invalid potential record when waiving the entry tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature-folder tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the artifact-validation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature entry tool on a bug checkpoint | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects any waiver on the remediation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving a tool that holds a successful receipt | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a tool listed twice | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: empties the waived set whenever any error is reported across a fixed grid | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: yields no errors and no waivers for a checkpoint without the adoption key | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
ORDER-PRESERVED: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 8759, Failed: 38, Skipped: 1, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: side-pre-c1 | containers=299 | passed=8759 | failed=38 | failedContainers=0
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
ORDER: 140 | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER: 141 | tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
ORDER: 142 | tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
ORDER: 143 | tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
ORDER: 144 | tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1
ORDER: 145 | tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
ORDER: 146 | tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1
ORDER: 147 | tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
ORDER: 148 | tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
ORDER: 149 | tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1
ORDER: 150 | tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1
ORDER: 151 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1
ORDER: 152 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1
ORDER: 153 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1
ORDER: 154 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
ORDER: 155 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1
ORDER: 156 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1
ORDER: 157 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1
ORDER: 158 | tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
ORDER: 159 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1
ORDER: 160 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
ORDER: 161 | tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
ORDER: 162 | tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
ORDER: 163 | tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1
ORDER: 164 | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
ORDER: 165 | tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1
ORDER: 166 | tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
ORDER: 167 | tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1
ORDER: 168 | tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1
ORDER: 169 | tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1
ORDER: 170 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1
ORDER: 171 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1
ORDER: 172 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1
ORDER: 173 | tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1
ORDER: 174 | tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1
ORDER: 175 | tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1
ORDER: 176 | tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1
ORDER: 177 | tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1
ORDER: 178 | tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1
ORDER: 179 | tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1
ORDER: 180 | tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1
ORDER: 181 | tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1
ORDER: 182 | tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1
ORDER: 183 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1
ORDER: 184 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1
ORDER: 185 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1
ORDER: 186 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1
ORDER: 187 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1
ORDER: 188 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1
ORDER: 189 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1
ORDER: 190 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1
ORDER: 191 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1
ORDER: 192 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1
ORDER: 193 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1
ORDER: 194 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1
ORDER: 195 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1
ORDER: 196 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
ORDER: 197 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
ORDER: 198 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1
ORDER: 199 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1
ORDER: 200 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1
ORDER: 201 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1
ORDER: 202 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1
ORDER: 203 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1
ORDER: 204 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1
ORDER: 205 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1
ORDER: 206 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1
ORDER: 207 | tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1
ORDER: 208 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1
ORDER: 209 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1
ORDER: 210 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1
ORDER: 211 | tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1
ORDER: 212 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
ORDER: 213 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1
ORDER: 214 | tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1
ORDER: 215 | tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
ORDER: 216 | tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1
ORDER: 217 | tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1
ORDER: 218 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1
ORDER: 219 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
ORDER: 220 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
ORDER: 221 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1
ORDER: 222 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
ORDER: 223 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
ORDER: 224 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
ORDER: 225 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1
ORDER: 226 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1
ORDER: 227 | tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
ORDER: 228 | tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
ORDER: 229 | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
ORDER: 230 | tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1
ORDER: 231 | tests/scripts/claude-runtime/claude-settings.Tests.ps1
ORDER: 232 | tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1
ORDER: 233 | tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
ORDER: 234 | tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
ORDER: 235 | tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
ORDER: 236 | tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
ORDER: 237 | tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1
ORDER: 238 | tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
ORDER: 239 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 240 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 241 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 242 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 243 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 244 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 245 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 246 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 247 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 248 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 249 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 250 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 251 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 252 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 253 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 254 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 255 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 256 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 257 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 258 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 259 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 260 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 261 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 262 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 263 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 264 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 265 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 266 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 267 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 268 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 269 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 270 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 271 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 272 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 273 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 274 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 275 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 276 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 277 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 278 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 279 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 280 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 281 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 282 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 283 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 284 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 285 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 286 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 287 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 288 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 289 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 290 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 291 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 292 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 293 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 294 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 295 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 296 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 297 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 298 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 299 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | passed=80 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | passed=100 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | passed=4 | failed=38
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | passed=95 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | passed=27 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | passed=598 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
FAILED: accepts a feature checkpoint waiving potential_to_issue alone | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a feature checkpoint waiving the feature entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a bug checkpoint waiving the bug entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the same record on the preparation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value transferred | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value filed_before_orchestration | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value epic_decomposition | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_issue_view | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_api_get | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source github_mcp_issue_read | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind integer | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null adoption value | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an integer issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a leading-zero issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue number that differs from the checkpoint issue-num | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue URL that does not end with the issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown origin | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown verification source | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an absent verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a whitespace-only verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects empty evidence | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an empty waived list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind blank-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind integer-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a waived list that omits the issue-creation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an invalid potential record when waiving the entry tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature-folder tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the artifact-validation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature entry tool on a bug checkpoint | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects any waiver on the remediation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving a tool that holds a successful receipt | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a tool listed twice | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: empties the waived set whenever any error is reported across a fixed grid | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: yields no errors and no waivers for a checkpoint without the adoption key | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
ORDER-PRESERVED: yes
R-LOSS:
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
LOSS: no
```
```text

Starting discovery in 341 files.
Discovery found 9505 tests in 36.95s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 549ms (171ms|258ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 145ms (100ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 4.07s (3.9s|127ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 175ms (98ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 258ms (223ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 143ms (80ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 138ms (81ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 94ms (55ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 115ms (70ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 79ms (38ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 262ms (145ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 207ms (119ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 123ms (78ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 171ms (90ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 839ms (775ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 174ms (81ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 285ms (237ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 538ms (474ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 1.18s (964ms|160ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 584ms (513ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 504ms (450ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 310ms (234ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 276ms (196ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 236ms (196ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 327ms (275ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 1.24s (1.14s|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 944ms (800ms|103ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 210ms (161ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 272ms (234ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 119ms (54ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 326ms (237ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 129ms (90ms|29ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 164.37s (135.89s|290ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 160ms (107ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 279ms (227ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 429ms (358ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 1.82s (1.73s|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 203ms (163ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 218ms (154ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 2.7s (2.65s|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 686ms (562ms|107ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 507ms (420ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 349ms (214ms|113ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 432ms (280ms|132ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 66ms (16ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 636ms (508ms|104ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 1.04s (786ms|207ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 69ms (14ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 997ms (806ms|169ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 5.12s (4.88s|208ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 191ms (132ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 7.36s (7.04s|261ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 1.41s (1.29s|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 1.61s (1.51s|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 480ms (420ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 4.59s (4.51s|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 1.65s (1.52s|105ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 639ms (547ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 1.29s (1.2s|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 385ms (318ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 319ms (209ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 215ms (157ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 375ms (296ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 197ms (150ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 391ms (282ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 236ms (187ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 336ms (217ms|102ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 473ms (355ms|101ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 1.07s (833ms|199ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 455ms (348ms|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 815ms (741ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 2.28s (2.16s|97ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 1.12s (991ms|101ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 185ms (144ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 350ms (302ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 320ms (211ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 223ms (162ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 586ms (500ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 1.81s (1.72s|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 384ms (345ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 1.03s (986ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 5.73s (5.65s|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 7.24s (7.17s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.28s (1.23s|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 552ms (468ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 3.26s (3.18s|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 3.32s (3.09s|195ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 2.25s (2.13s|100ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 10.31s (10.22s|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 568ms (479ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 640ms (532ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 487ms (408ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 611ms (514ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 860ms (640ms|142ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 2.15s (1.98s|146ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 492ms (387ms|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 389ms (317ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 401ms (312ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 288ms (205ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 231ms (115ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 3.06s (2.95s|102ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 2.05s (1.92s|105ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 1.97s (1.78s|170ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 4.41s (4.28s|112ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 727ms (573ms|129ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 685ms (615ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 884ms (775ms|90ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 116ms (59ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 212ms (113ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 10.14s (9.56s|254ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 3.54s (1.75s|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 110ms (61ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 4.03s (3.92s|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 260ms (181ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 392ms (221ms|143ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 949ms (868ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 1.5s (1.44s|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 433ms (345ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 283ms (225ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 1.04s (947ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 142ms (87ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 168ms (102ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 470ms (370ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 91ms (49ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 664ms (618ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 766ms (702ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 392ms (334ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 547ms (496ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 678ms (592ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 622ms (559ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 1.79s (1.71s|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 89ms (33ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 520ms (356ms|140ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 114ms (50ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 1.21s (1.13s|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 56ms (16ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 149ms (104ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 68ms (28ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 235ms (140ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ClaudeLibModuleConvention.Tests.ps1 1.53s (1.48s|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1 1.28s (1.17s|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1 80.66s (80.61s|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.KeyPartition.Tests.ps1 69ms (22ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Manifest.Tests.ps1 56ms (14ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Parity.Tests.ps1 4.28s (4.08s|141ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Regression452.Tests.ps1 1.52s (1.38s|113ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Tests.ps1 1.12s (991ms|100ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.TruthTable.Tests.ps1 729ms (655ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadius.Validation.Tests.ps1 1.7s (1.62s|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConfig.Tests.ps1 363ms (203ms|127ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.OverlappingPairs.Tests.ps1 993ms (922ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.PathOverlap.Tests.ps1 1.12s (1.03s|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.Tests.ps1 1.05s (986ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Path.Tests.ps1 285ms (159ms|99ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Tests.ps1 169ms (83ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.RegexCache.Tests.ps1 125ms (61ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.Tests.ps1 282ms (147ms|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusNormalization.Tests.ps1 885ms (819ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.PairCost.Tests.ps1 483ms (436ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.Tests.ps1 3.17s (3.04s|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.Tests.ps1 134ms (60ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\blast-radius\BlastRadiusWriteIntent.Tests.ps1 2.6s (2.51s|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1 72ms (23ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 160ms (73ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1 133ms (57ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 126ms (62ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1 300ms (148ms|138ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexRouting.Manifest.Tests.ps1 105ms (36ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\codex-routing\CodexTopology.Parity.Tests.ps1 256ms (160ms|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Manifest.Tests.ps1 68ms (17ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Tests.ps1 249ms (140ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.VersionFloor.Tests.ps1 100ms (41ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\hook-payload\HookPayload.Tests.ps1 327ms (165ms|120ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidGrammar.Tests.ps1 369ms (235ms|106ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidLineScanner.Tests.ps1 346ms (216ms|104ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidMarkdownFences.Tests.ps1 161ms (76ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidValidation.Tests.ps1 492ms (379ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\mermaid\MermaidValidationAcceptMatrix.Tests.ps1 369ms (305ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\Get-ComplexityFloor.Tests.ps1 111ms (40ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\ModelRouting.Manifest.Tests.ps1 62ms (17ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\ModelRouting.Parity.Tests.ps1 137ms (64ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\model-routing\Resolve-DelegationModel.Tests.ps1 199ms (106ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Manifest.Tests.ps1 296ms (227ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1 1.66s (1.45s|183ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.ValueContract.Tests.ps1 124ms (69ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Backcompat.Tests.ps1 946ms (865ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Parity.Tests.ps1 357ms (271ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Tests.ps1 134ms (63ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCheckpointValue.Tests.ps1 179ms (83ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1 316ms (250ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexTopologyReceipts.Tests.ps1 337ms (271ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletion.Tests.ps1 1.32s (1.24s|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletionChecks.Tests.ps1 209ms (125ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 236ms (191ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateEpicWaveBarrier.Tests.ps1 141ms (84ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Parity.Tests.ps1 604ms (497ms|60ms)
[-] Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone 24ms (23ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:120
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record 25ms (24ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:127
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record 24ms (24ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:134
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route 24ms (24ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:140
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred 18ms (18ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration 28ms (28ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition 27ms (26ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view 31ms (31ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get 29ms (29ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read 19ms (19ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string 21ms (21ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer 22ms (22ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list 26ms (25ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a null adoption value 31ms (30ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:173
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an integer issue number 32ms (32ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:179
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number 31ms (31ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:186
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num 32ms (31ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:193
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number 43ms (42ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:200
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an unknown origin 31ms (30ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:206
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an unknown verification source 29ms (28ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:211
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an absent verification time 28ms (28ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:216
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a null verification time 29ms (29ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:221
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time 31ms (30ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:226
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects empty evidence 32ms (32ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:231
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an empty waived list 27ms (27ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:236
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string 31ms (31ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry 26ms (26ms|1ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry 21ms (21ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool 18ms (18ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:253
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool 31ms (31ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:260
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool 16ms (16ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:270
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool 28ms (27ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:277
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint 32ms (31ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:283
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route 20ms (20ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:288
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt 19ms (19ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:293
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice 20ms (20ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:299
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid 22ms (21ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:329
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key 15ms (15ms|0ms)
 at script:Invoke-Adoption, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:349
 CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateModelReceipts.Tests.ps1 170ms (118ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStatePromotionType.Parity.Tests.ps1 238ms (181ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateReceipts.Tests.ps1 185ms (125ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationAccounting.Tests.ps1 450ms (300ms|118ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 1.27s (1.19s|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Parity.Tests.ps1 869ms (754ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingContract.Tests.ps1 446ms (345ms|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingMatrix.Tests.ps1 161ms (81ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateUnconditional.Tests.ps1 253ms (195ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\Invoke-ParallelDriftDetection.Tests.ps1 1.35s (1.26s|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Manifest.Tests.ps1 68ms (22ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Parity.Tests.ps1 1.41s (1.35s|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Tests.ps1 1.06s (996ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\parallel-drift\ParallelDriftHalt.Tests.ps1 111ms (55ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Manifest.Tests.ps1 57ms (22ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Tests.ps1 238ms (188ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\ProjectFileMergeGrammar.Tests.ps1 92ms (46ms|33ms)
What if: Performing the operation "Write the merged project file" on target "<WORKSPACE_ROOT>\tests\fixtures\project_file_merge\whatif-never-written.csproj".
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\project-file-merge\Resolve-MergeableConflict.Tests.ps1 351ms (291ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\requirements\GeneratedDocumentCounters.Tests.ps1 44ms (9ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1 108ms (31ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1 137ms (94ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1 456ms (369ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1 174ms (124ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1 334ms (261ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1 97ms (47ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1 349ms (262ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1 418ms (316ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1 128ms (63ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1 447ms (354ms|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1 971ms (822ms|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1 142ms (93ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-architecture-doc.Tests.ps1 81ms (39ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-runtime-structure.Tests.ps1 97ms (48ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-settings.Tests.ps1 120ms (72ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-checkpoint-path-explicit.Tests.ps1 3.92s (3.87s|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 6.82s (6.74s|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1 39.34s (38.59s|669ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-import-failure-exemptions.Guard.Tests.ps1 22.25s (22.2s|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1 35.92s (35.85s|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\legacy-discovery-agent-roles.Tests.ps1 103ms (37ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\test-name-uniqueness.Tests.ps1 5.2s (5.15s|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 365ms (297ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 140ms (76ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 14.95s (14.92s|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 116ms (59ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 276ms (229ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 94ms (61ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 575ms (530ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 487ms (314ms|155ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 155ms (62ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 292ms (198ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 252ms (164ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 359ms (274ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 180ms (76ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 36.42s (36.38s|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 26.9s (26.82s|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 260ms (149ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 358ms (272ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 199ms (106ms|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 335ms (266ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 108ms (73ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 191ms (115ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 132ms (82ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 93ms (46ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 118ms (77ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 680ms (602ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 308ms (245ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 348ms (293ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 210ms (165ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 352ms (294ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 454ms (388ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 1.63s (1.53s|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 284ms (232ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 5.37s (5.17s|171ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 501ms (393ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 875ms (814ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.45s (1.31s|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 309ms (230ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 298ms (192ms|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 204ms (148ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 241ms (203ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 967ms (891ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 406ms (302ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 270ms (213ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 132ms (88ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 408ms (356ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 231ms (165ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 5.57s (5.46s|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 280ms (233ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 189ms (137ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 215ms (109ms|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 579ms (469ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 396ms (263ms|114ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 6.17s (5.81s|187ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 136ms (68ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 682ms (600ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 17.79s (17.68s|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 248ms (180ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 745ms (592ms|133ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 197ms (150ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 226ms (154ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 537ms (453ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-scripts\codex-routing-cli-common.Tests.ps1 342ms (198ms|122ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-scripts\Resolve-CodexRouting.Parity.Tests.ps1 9.07s (8.96s|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\activate.Tests.ps1 275ms (156ms|99ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\agents-attribution.Tests.ps1 44ms (3ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Enter-DrmCopilotShell.Tests.ps1 76ms (25ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullRelease.Tests.ps1 675ms (569ms|77ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 321ms (254ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 167ms (98ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-FullReleaseFlow.Tests.ps1 354ms (278ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-MarketplacePublish.Tests.ps1 363ms (259ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseReconciliation.Tests.ps1 64ms (28ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseTagPush.Tests.ps1 653ms (538ms|95ms)
Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.
Publish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.
Publish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 252ms (205ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseVerification.Tests.ps1 500ms (409ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\Invoke-ReleaseVerificationHelpers.Tests.ps1 93ms (30ms|49ms)
What if: Performing the operation "Update section content" on target "## Feature Docs".
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\link-feature-docs.Tests.ps1 218ms (149ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\link-parent-child.Tests.ps1 488ms (387ms|84ms)
What if: Performing the operation "Create worktree grouping directory" on target "/parent/auth-wt".
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\new-claude-worktree-session.Tests.ps1 309ms (150ms|132ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\new-potential-entry.TemplateRoot.Tests.ps1 283ms (231ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\new-potential-entry.Tests.ps1 415ms (301ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\post-codex-worktree-session.Tests.ps1 214ms (153ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\publish-sideloaded-extension.Tests.ps1 182ms (130ms|32ms)
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\run-actionlint.Tests.ps1 989ms (832ms|132ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1 622ms (475ms|115ms)
[+] <WORKSPACE_ROOT>\tests\scripts\dev-tools\tree.Tests.ps1 313ms (212ms|76ms)
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: Package
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Packaging to \repo\artifacts\vsix\drm-copilot-0.0.2-20261010-094006.vsix...

[5/5] Package complete. Install locally with:
      code --install-extension "\repo\artifacts\vsix\drm-copilot-0.0.2-20261010-094006.vsix"
      Marketplace upload and the release tag are performed by CI
      (.github/workflows/publish-extension.yml) after the bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm install...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm install...
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 2
    docs/internal.md

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: Package
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Packaging to \repo\artifacts\vsix\drm-copilot-0.0.2-20261010-094007.vsix...
drm-copilot package script - mode: DryRun
Extension directory: <WORKSPACE_ROOT>\extensions\drm-copilot

[1/5] Validating manifest...
  Publisher : <ACCOUNT>
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\Publish-DrmCopilotExtension.Tests.ps1 461ms (378ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1 75ms (23ms|40ms)
Already formatted: /repo/test.ps1
Formatted: /repo/test.ps1
Already formatted: /repo/test.ps1
PSScriptAnalyzer passed: no findings under /repo
PSScriptAnalyzer passed: no findings under /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 1.07s (924ms|117ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1 312ms (257ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1 154ms (99ms|41ms)
No PowerShell files found under <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 163ms (106ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1 118ms (58ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 378ms (280ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 170ms (120ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1 148ms (90ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1 161ms (82ms|68ms)
Coverage file not found; skipping Koverage output: <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 290ms (187ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 277ms (176ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 48ms (7ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 79ms (35ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 91ms (44ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 54ms (12ms|29ms)
Tests completed in 712.93s
Tests Passed: 9457, Failed: 38, Skipped: 10, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 87.34% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: x1-c1 | containers=341 | passed=9457 | failed=38 | failedContainers=0
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
ORDER: 140 | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER: 141 | tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
ORDER: 142 | tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
ORDER: 143 | tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
ORDER: 144 | tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1
ORDER: 145 | tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
ORDER: 146 | tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1
ORDER: 147 | tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
ORDER: 148 | tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
ORDER: 149 | tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1
ORDER: 150 | tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1
ORDER: 151 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1
ORDER: 152 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1
ORDER: 153 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1
ORDER: 154 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
ORDER: 155 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1
ORDER: 156 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1
ORDER: 157 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1
ORDER: 158 | tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
ORDER: 159 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1
ORDER: 160 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
ORDER: 161 | tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
ORDER: 162 | tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
ORDER: 163 | tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1
ORDER: 164 | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
ORDER: 165 | tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1
ORDER: 166 | tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
ORDER: 167 | tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1
ORDER: 168 | tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1
ORDER: 169 | tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1
ORDER: 170 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1
ORDER: 171 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1
ORDER: 172 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1
ORDER: 173 | tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1
ORDER: 174 | tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1
ORDER: 175 | tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1
ORDER: 176 | tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1
ORDER: 177 | tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1
ORDER: 178 | tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1
ORDER: 179 | tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1
ORDER: 180 | tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1
ORDER: 181 | tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1
ORDER: 182 | tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1
ORDER: 183 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1
ORDER: 184 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1
ORDER: 185 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1
ORDER: 186 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1
ORDER: 187 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1
ORDER: 188 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1
ORDER: 189 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1
ORDER: 190 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1
ORDER: 191 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1
ORDER: 192 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1
ORDER: 193 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1
ORDER: 194 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1
ORDER: 195 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1
ORDER: 196 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
ORDER: 197 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
ORDER: 198 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1
ORDER: 199 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1
ORDER: 200 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1
ORDER: 201 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1
ORDER: 202 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1
ORDER: 203 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1
ORDER: 204 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1
ORDER: 205 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1
ORDER: 206 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1
ORDER: 207 | tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1
ORDER: 208 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1
ORDER: 209 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1
ORDER: 210 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1
ORDER: 211 | tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1
ORDER: 212 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
ORDER: 213 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1
ORDER: 214 | tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1
ORDER: 215 | tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
ORDER: 216 | tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1
ORDER: 217 | tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1
ORDER: 218 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1
ORDER: 219 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
ORDER: 220 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
ORDER: 221 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1
ORDER: 222 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
ORDER: 223 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
ORDER: 224 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
ORDER: 225 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1
ORDER: 226 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1
ORDER: 227 | tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
ORDER: 228 | tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
ORDER: 229 | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
ORDER: 230 | tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1
ORDER: 231 | tests/scripts/claude-runtime/claude-settings.Tests.ps1
ORDER: 232 | tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1
ORDER: 233 | tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
ORDER: 234 | tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
ORDER: 235 | tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
ORDER: 236 | tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
ORDER: 237 | tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1
ORDER: 238 | tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
ORDER: 239 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 240 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 241 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 242 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 243 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 244 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 245 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 246 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 247 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 248 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 249 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 250 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 251 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 252 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 253 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 254 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 255 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 256 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 257 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 258 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 259 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 260 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 261 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 262 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 263 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 264 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 265 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 266 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 267 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 268 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 269 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 270 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 271 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 272 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 273 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 274 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 275 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 276 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 277 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 278 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 279 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 280 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 281 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 282 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 283 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 284 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 285 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 286 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 287 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 288 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 289 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 290 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 291 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 292 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 293 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 294 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 295 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 296 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 297 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 298 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 299 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 300 | tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1
ORDER: 301 | tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
ORDER: 302 | tests/scripts/dev-tools/activate.Tests.ps1
ORDER: 303 | tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER: 304 | tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER: 305 | tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER: 306 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER: 307 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER: 308 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER: 309 | tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER: 310 | tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER: 311 | tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER: 312 | tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER: 313 | tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER: 314 | tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER: 315 | tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER: 316 | tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER: 317 | tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER: 318 | tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER: 319 | tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER: 320 | tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER: 321 | tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER: 322 | tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER: 323 | tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER: 324 | tests/scripts/dev-tools/tree.Tests.ps1
ORDER: 325 | tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1
ORDER: 326 | tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1
ORDER: 327 | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1
ORDER: 328 | tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1
ORDER: 329 | tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1
ORDER: 330 | tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1
ORDER: 331 | tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
ORDER: 332 | tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
ORDER: 333 | tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1
ORDER: 334 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1
ORDER: 335 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1
ORDER: 336 | tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1
ORDER: 337 | tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1
ORDER: 338 | tests/scripts/workflows/CiWorkflow.Tests.ps1
ORDER: 339 | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
ORDER: 340 | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
ORDER: 341 | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | passed=80 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | passed=100 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | passed=4 | failed=38
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | passed=95 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | passed=27 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | passed=598 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/activate.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/agents-attribution.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | passed=33 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/dev-tools/run-actionlint.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/dev-tools/tree.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | passed=4 | failed=0
FAILED: accepts a feature checkpoint waiving potential_to_issue alone | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a feature checkpoint waiving the feature entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a bug checkpoint waiving the bug entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the same record on the preparation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value transferred | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value filed_before_orchestration | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value epic_decomposition | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_issue_view | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_api_get | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source github_mcp_issue_read | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind integer | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null adoption value | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an integer issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a leading-zero issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue number that differs from the checkpoint issue-num | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue URL that does not end with the issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown origin | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown verification source | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an absent verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a whitespace-only verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects empty evidence | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an empty waived list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind blank-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind integer-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a waived list that omits the issue-creation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an invalid potential record when waiving the entry tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature-folder tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the artifact-validation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature entry tool on a bug checkpoint | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects any waiver on the remediation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving a tool that holds a successful receipt | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a tool listed twice | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: empties the waived set whenever any error is reported across a fixed grid | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: yields no errors and no waivers for a checkpoint without the adoption key | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
ORDER-PRESERVED: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 9457, Failed: 38, Skipped: 10, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: x1-c1 | containers=341 | passed=9457 | failed=38 | failedContainers=0
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
ORDER: 140 | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER: 141 | tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
ORDER: 142 | tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
ORDER: 143 | tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
ORDER: 144 | tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1
ORDER: 145 | tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
ORDER: 146 | tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1
ORDER: 147 | tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
ORDER: 148 | tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
ORDER: 149 | tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1
ORDER: 150 | tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1
ORDER: 151 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1
ORDER: 152 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1
ORDER: 153 | tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1
ORDER: 154 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
ORDER: 155 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1
ORDER: 156 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1
ORDER: 157 | tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1
ORDER: 158 | tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
ORDER: 159 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1
ORDER: 160 | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
ORDER: 161 | tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
ORDER: 162 | tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
ORDER: 163 | tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1
ORDER: 164 | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
ORDER: 165 | tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1
ORDER: 166 | tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
ORDER: 167 | tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1
ORDER: 168 | tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1
ORDER: 169 | tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1
ORDER: 170 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1
ORDER: 171 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1
ORDER: 172 | tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1
ORDER: 173 | tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1
ORDER: 174 | tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1
ORDER: 175 | tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1
ORDER: 176 | tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1
ORDER: 177 | tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1
ORDER: 178 | tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1
ORDER: 179 | tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1
ORDER: 180 | tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1
ORDER: 181 | tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1
ORDER: 182 | tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1
ORDER: 183 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1
ORDER: 184 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1
ORDER: 185 | tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1
ORDER: 186 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1
ORDER: 187 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1
ORDER: 188 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1
ORDER: 189 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1
ORDER: 190 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1
ORDER: 191 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1
ORDER: 192 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1
ORDER: 193 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1
ORDER: 194 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1
ORDER: 195 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1
ORDER: 196 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
ORDER: 197 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
ORDER: 198 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1
ORDER: 199 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1
ORDER: 200 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1
ORDER: 201 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1
ORDER: 202 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1
ORDER: 203 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1
ORDER: 204 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1
ORDER: 205 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1
ORDER: 206 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1
ORDER: 207 | tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1
ORDER: 208 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1
ORDER: 209 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1
ORDER: 210 | tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1
ORDER: 211 | tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1
ORDER: 212 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
ORDER: 213 | tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1
ORDER: 214 | tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1
ORDER: 215 | tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
ORDER: 216 | tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1
ORDER: 217 | tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1
ORDER: 218 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1
ORDER: 219 | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
ORDER: 220 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
ORDER: 221 | tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1
ORDER: 222 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
ORDER: 223 | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
ORDER: 224 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
ORDER: 225 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1
ORDER: 226 | tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1
ORDER: 227 | tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
ORDER: 228 | tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
ORDER: 229 | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
ORDER: 230 | tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1
ORDER: 231 | tests/scripts/claude-runtime/claude-settings.Tests.ps1
ORDER: 232 | tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1
ORDER: 233 | tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
ORDER: 234 | tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
ORDER: 235 | tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
ORDER: 236 | tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
ORDER: 237 | tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1
ORDER: 238 | tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
ORDER: 239 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 240 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 241 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 242 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 243 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 244 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 245 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 246 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 247 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 248 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 249 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 250 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 251 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 252 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 253 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 254 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 255 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 256 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 257 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 258 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 259 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 260 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 261 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 262 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 263 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 264 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 265 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 266 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 267 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 268 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 269 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 270 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 271 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 272 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 273 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 274 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 275 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 276 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 277 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 278 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 279 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 280 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 281 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 282 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 283 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 284 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 285 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 286 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 287 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 288 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 289 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 290 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 291 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 292 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 293 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 294 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 295 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 296 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 297 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 298 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 299 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 300 | tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1
ORDER: 301 | tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
ORDER: 302 | tests/scripts/dev-tools/activate.Tests.ps1
ORDER: 303 | tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER: 304 | tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER: 305 | tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER: 306 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER: 307 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER: 308 | tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER: 309 | tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER: 310 | tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER: 311 | tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER: 312 | tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER: 313 | tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER: 314 | tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER: 315 | tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER: 316 | tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER: 317 | tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER: 318 | tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER: 319 | tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER: 320 | tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER: 321 | tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER: 322 | tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER: 323 | tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER: 324 | tests/scripts/dev-tools/tree.Tests.ps1
ORDER: 325 | tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1
ORDER: 326 | tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1
ORDER: 327 | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1
ORDER: 328 | tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1
ORDER: 329 | tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1
ORDER: 330 | tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1
ORDER: 331 | tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
ORDER: 332 | tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
ORDER: 333 | tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1
ORDER: 334 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1
ORDER: 335 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1
ORDER: 336 | tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1
ORDER: 337 | tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1
ORDER: 338 | tests/scripts/workflows/CiWorkflow.Tests.ps1
ORDER: 339 | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
ORDER: 340 | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
ORDER: 341 | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | passed=80 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | passed=100 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | passed=4 | failed=38
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | passed=40 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | passed=95 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 | passed=28 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | passed=27 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | passed=598 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/activate.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/dev-tools/agents-attribution.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | passed=33 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/dev-tools/run-actionlint.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/dev-tools/tree.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | passed=4 | failed=0
FAILED: accepts a feature checkpoint waiving potential_to_issue alone | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a feature checkpoint waiving the feature entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts a bug checkpoint waiving the bug entry tool with a record | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the same record on the preparation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value transferred | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value filed_before_orchestration | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented origin value epic_decomposition | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_issue_view | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source gh_api_get | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: accepts the documented verification source github_mcp_issue_read | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind integer | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a non-object adoption value of kind list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null adoption value | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an integer issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a leading-zero issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue number that differs from the checkpoint issue-num | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an issue URL that does not end with the issue number | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown origin | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an unknown verification source | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an absent verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a null verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a whitespace-only verification time | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects empty evidence | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an empty waived list | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind string | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind blank-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a malformed waived list of kind integer-entry | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a waived list that omits the issue-creation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects an invalid potential record when waiving the entry tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature-folder tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the artifact-validation tool | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving the feature entry tool on a bug checkpoint | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects any waiver on the remediation route | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects waiving a tool that holds a successful receipt | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: rejects a tool listed twice | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: empties the waived set whenever any error is reported across a fixed grid | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: yields no errors and no waivers for a checkpoint without the adoption key | The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
ORDER-PRESERVED: yes
R-LOSS:
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:103
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:104
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:105
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:107
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:108
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:109
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:110
LOST-LINE: .codex/hooks/hook-dependency-guard.ps1:111
LOST-LINE: .codex/hooks/validate-bash.ps1:98
LOST-LINE: .codex/hooks/validate-bash.ps1:99
LOST-LINE: .codex/hooks/validate-bash.ps1:102
LOST-LINE: .codex/hooks/validate-bash.ps1:156
LOST-LINE: .codex/hooks/validate-bash.ps1:177
LOST-LINE: .codex/hooks/validate-bash.ps1:304
LOST-LINE: .codex/hooks/validate-bash.ps1:305
LOST-LINE: .codex/hooks/validate-bash.ps1:306
LOST-LINE: .codex/hooks/validate-bash.ps1:309
LOST-LINE: .codex/hooks/validate-bash.ps1:310
LOST-LINE: .codex/hooks/validate-bash.ps1:311
LOST-LINE: .codex/hooks/validate-bash.ps1:312
LOST-LINE: .codex/hooks/validate-bash.ps1:313
LOST-LINE: .codex/hooks/validate-bash.ps1:315
LOST-LINE: .codex/hooks/validate-bash.ps1:317
LOST-LINE: .codex/hooks/validate-bash.ps1:318
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:143
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:375
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:449
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:454
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:471
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:472
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:477
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:478
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:479
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:480
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:482
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:488
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:489
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:490
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:491
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:492
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:493
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:496
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:498
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:499
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 57.89 | covered=11 | missed=8 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 80.25 | covered=65 | missed=16 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 86.55 | covered=148 | missed=23 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
LOSS: yes
```

## [P2-T5] Named-candidate probes (cycle 1 only)

## Cycle 1

Commands: <SCRATCHPAD>/r1-batch.ps1 -Labels nc1-alone-c1,nc1-c1,nc2-c1,nc3-c1 -Valid nc2-c1,nc3-c1 (each label: R-COVPROBE then R-LOSS against <SCRATCHPAD>/r1-probe-xs-c1-coverage.xml, R-VALID for the runs containing S); <SCRATCHPAD>/r1-nc1.ps1 (NC-1 line comparison); <SCRATCHPAD>/r1-nc4.ps1 (NC-4 census over the 341 L containers).
EXIT_CODE: 0

- NC-1 lists: nc1-c1 = tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 then tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1; nc1-alone-c1 = tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1. These runs do not contain S, so their R-LOSS LOSS lines (yes, by construction against the S-only reference) are not the NC-1 result; NC1-LOSS is decided by the NC1-LINE rule.
- NC-2 list: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 then S (62 entries).
- NC-3 list: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 then S (62 entries).
- NC-4 counting note: `Select-String -SimpleMatch` leaves `MatchInfo.Matches` empty, so the first census run printed `NC4: none`; the script was corrected to count occurrences in each matched line, and the corrected count agrees with an independent repository search (25 occurrences in 4 files).

```text
NC1-LINE: 103 | alone=1 | after-claude=1
NC1-LINE: 104 | alone=1 | after-claude=1
NC1-LINE: 105 | alone=3 | after-claude=3
NC1-LINE: 107 | alone=1 | after-claude=1
NC1-LINE: 108 | alone=1 | after-claude=1
NC1-LINE: 109 | alone=1 | after-claude=1
NC1-LINE: 110 | alone=1 | after-claude=1
NC1-LINE: 111 | alone=1 | after-claude=1
```

NC1-LOSS: no
NC2-LOSS: no (R-VALID valid, ORDER-PRESERVED yes)
NC3-LOSS: no (R-VALID valid, ORDER-PRESERVED yes)
NC4: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | 22
NC4: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 1
NC4: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 1
NC4: tests/scripts/dev-tools/activate.Tests.ps1 | 1

Run outputs:

```text

Starting discovery in 1 files.
Discovery found 11 tests in 137ms.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 1.46s (558ms|799ms)
Tests completed in 1.51s
Tests Passed: 11, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 0.13% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: nc1-alone-c1 | containers=1 | passed=11 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
ORDER-PRESERVED: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 11, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: nc1-alone-c1 | containers=1 | passed=11 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
ORDER-PRESERVED: yes
R-LOSS:
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:13
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:15
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:17
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:24
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:25
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:28
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:30
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:39
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:40
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:42
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:44
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:55
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:56
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:57
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:58
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:59
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:69
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:70
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:71
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:73
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:74
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:76
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:77
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:79
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:93
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:94
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:96
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:97
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:98
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:100
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:101
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:102
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:103
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:104
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:105
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:106
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:109
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:110
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:111
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:120
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:121
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:123
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:124
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:140
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:141
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:142
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:143
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:144
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:146
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:148
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:149
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:151
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:152
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:154
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:155
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:156
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:157
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:158
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:159
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:160
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:161
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:162
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:163
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:164
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:166
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:167
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:168
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:171
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:172
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:177
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:180
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:182
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:183
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:184
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:186
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:190
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:192
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:194
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:196
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:197
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:198
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:199
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:201
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:203
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:205
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:207
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:222
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:223
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:225
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:226
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:227
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:229
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:230
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:231
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:232
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:234
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:235
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:237
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:238
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:239
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:241
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:242
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:244
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:245
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:246
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:247
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:248
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:249
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:252
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:254
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:257
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:260
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:261
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:263
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:270
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:278
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:279
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:280
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:282
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:285
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:288
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:289
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:290
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:293
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:294
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:295
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:296
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:297
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:298
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:299
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:300
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:301
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:302
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:303
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:304
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:305
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:307
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:308
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:311
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:313
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:314
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:317
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:319
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:322
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:324
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:327
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:329
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:330
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:333
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:336
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:12
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:14
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:15
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:22
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:23
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:37
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:38
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:39
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:41
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:44
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:46
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:58
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:59
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:61
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:62
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:64
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:65
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:66
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:67
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:68
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:70
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:71
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:72
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:73
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:75
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:76
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:77
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:78
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:80
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:83
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:86
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:93
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:94
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:95
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:96
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:97
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:108
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:112
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:122
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:123
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:127
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:129
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:130
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:131
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:133
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:134
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:135
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:137
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:139
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:151
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:153
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:155
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:156
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:162
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:163
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:164
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:168
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:169
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:170
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:171
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:175
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:176
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:181
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:182
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:183
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:184
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:185
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:187
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:189
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:192
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:194
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:195
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:196
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:197
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:200
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:211
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:213
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:214
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:216
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:217
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:218
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:219
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:221
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:222
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:224
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:226
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:227
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:229
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:230
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:233
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:234
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:235
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:236
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:237
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:239
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:241
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:243
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:244
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:246
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:248
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:250
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:251
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:254
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:257
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:258
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:259
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:262
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:265
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:266
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:267
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:268
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:270
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:276
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:277
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:278
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:279
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:280
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:282
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:285
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:287
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:288
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:289
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:290
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:293
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:296
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:299
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:300
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:303
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:318
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:319
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:320
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:322
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:323
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:325
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:328
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:331
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:332
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:333
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:336
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:337
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:338
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:339
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:340
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:344
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:345
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:346
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:347
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:354
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:358
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:361
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:364
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:367
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:369
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:370
LOST-LINE: .codex/hooks/validate-bash.ps1:16
LOST-LINE: .codex/hooks/validate-bash.ps1:22
LOST-LINE: .codex/hooks/validate-bash.ps1:23
LOST-LINE: .codex/hooks/validate-bash.ps1:30
LOST-LINE: .codex/hooks/validate-bash.ps1:31
LOST-LINE: .codex/hooks/validate-bash.ps1:59
LOST-LINE: .codex/hooks/validate-bash.ps1:60
LOST-LINE: .codex/hooks/validate-bash.ps1:63
LOST-LINE: .codex/hooks/validate-bash.ps1:64
LOST-LINE: .codex/hooks/validate-bash.ps1:65
LOST-LINE: .codex/hooks/validate-bash.ps1:66
LOST-LINE: .codex/hooks/validate-bash.ps1:67
LOST-LINE: .codex/hooks/validate-bash.ps1:71
LOST-LINE: .codex/hooks/validate-bash.ps1:72
LOST-LINE: .codex/hooks/validate-bash.ps1:76
LOST-LINE: .codex/hooks/validate-bash.ps1:97
LOST-LINE: .codex/hooks/validate-bash.ps1:98
LOST-LINE: .codex/hooks/validate-bash.ps1:99
LOST-LINE: .codex/hooks/validate-bash.ps1:101
LOST-LINE: .codex/hooks/validate-bash.ps1:102
LOST-LINE: .codex/hooks/validate-bash.ps1:105
LOST-LINE: .codex/hooks/validate-bash.ps1:155
LOST-LINE: .codex/hooks/validate-bash.ps1:156
LOST-LINE: .codex/hooks/validate-bash.ps1:159
LOST-LINE: .codex/hooks/validate-bash.ps1:161
LOST-LINE: .codex/hooks/validate-bash.ps1:162
LOST-LINE: .codex/hooks/validate-bash.ps1:163
LOST-LINE: .codex/hooks/validate-bash.ps1:164
LOST-LINE: .codex/hooks/validate-bash.ps1:165
LOST-LINE: .codex/hooks/validate-bash.ps1:167
LOST-LINE: .codex/hooks/validate-bash.ps1:169
LOST-LINE: .codex/hooks/validate-bash.ps1:174
LOST-LINE: .codex/hooks/validate-bash.ps1:175
LOST-LINE: .codex/hooks/validate-bash.ps1:176
LOST-LINE: .codex/hooks/validate-bash.ps1:177
LOST-LINE: .codex/hooks/validate-bash.ps1:181
LOST-LINE: .codex/hooks/validate-bash.ps1:194
LOST-LINE: .codex/hooks/validate-bash.ps1:195
LOST-LINE: .codex/hooks/validate-bash.ps1:196
LOST-LINE: .codex/hooks/validate-bash.ps1:199
LOST-LINE: .codex/hooks/validate-bash.ps1:210
LOST-LINE: .codex/hooks/validate-bash.ps1:211
LOST-LINE: .codex/hooks/validate-bash.ps1:212
LOST-LINE: .codex/hooks/validate-bash.ps1:213
LOST-LINE: .codex/hooks/validate-bash.ps1:214
LOST-LINE: .codex/hooks/validate-bash.ps1:234
LOST-LINE: .codex/hooks/validate-bash.ps1:236
LOST-LINE: .codex/hooks/validate-bash.ps1:237
LOST-LINE: .codex/hooks/validate-bash.ps1:238
LOST-LINE: .codex/hooks/validate-bash.ps1:242
LOST-LINE: .codex/hooks/validate-bash.ps1:246
LOST-LINE: .codex/hooks/validate-bash.ps1:247
LOST-LINE: .codex/hooks/validate-bash.ps1:250
LOST-LINE: .codex/hooks/validate-bash.ps1:267
LOST-LINE: .codex/hooks/validate-bash.ps1:268
LOST-LINE: .codex/hooks/validate-bash.ps1:270
LOST-LINE: .codex/hooks/validate-bash.ps1:272
LOST-LINE: .codex/hooks/validate-bash.ps1:273
LOST-LINE: .codex/hooks/validate-bash.ps1:274
LOST-LINE: .codex/hooks/validate-bash.ps1:277
LOST-LINE: .codex/hooks/validate-bash.ps1:284
LOST-LINE: .codex/hooks/validate-bash.ps1:285
LOST-LINE: .codex/hooks/validate-bash.ps1:288
LOST-LINE: .codex/hooks/validate-bash.ps1:290
LOST-LINE: .codex/hooks/validate-bash.ps1:292
LOST-LINE: .codex/hooks/validate-bash.ps1:293
LOST-LINE: .codex/hooks/validate-bash.ps1:295
LOST-LINE: .codex/hooks/validate-bash.ps1:296
LOST-LINE: .codex/hooks/validate-bash.ps1:298
LOST-LINE: .codex/hooks/validate-bash.ps1:301
LOST-LINE: .codex/hooks/validate-bash.ps1:304
LOST-LINE: .codex/hooks/validate-bash.ps1:305
LOST-LINE: .codex/hooks/validate-bash.ps1:306
LOST-LINE: .codex/hooks/validate-bash.ps1:309
LOST-LINE: .codex/hooks/validate-bash.ps1:310
LOST-LINE: .codex/hooks/validate-bash.ps1:311
LOST-LINE: .codex/hooks/validate-bash.ps1:312
LOST-LINE: .codex/hooks/validate-bash.ps1:313
LOST-LINE: .codex/hooks/validate-bash.ps1:315
LOST-LINE: .codex/hooks/validate-bash.ps1:317
LOST-LINE: .codex/hooks/validate-bash.ps1:318
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:14
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:37
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:44
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:45
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:46
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:47
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:48
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:49
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:50
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:51
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:57
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:58
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:59
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:66
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:77
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:78
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:80
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:94
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:102
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:103
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:128
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:129
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:130
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:133
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:141
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:142
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:143
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:146
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:147
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:148
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:149
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:152
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:153
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:154
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:155
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:159
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:160
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:166
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:167
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:169
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:170
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:179
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:182
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:184
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:205
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:206
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:209
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:210
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:211
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:214
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:215
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:216
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:217
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:220
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:241
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:242
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:245
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:246
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:247
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:249
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:250
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:253
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:254
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:262
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:263
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:265
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:266
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:267
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:268
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:269
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:271
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:272
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:273
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:276
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:277
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:280
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:281
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:292
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:293
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:295
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:303
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:304
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:305
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:306
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:319
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:320
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:321
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:322
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:323
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:339
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:340
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:366
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:367
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:369
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:370
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:373
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:375
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:378
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:383
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:384
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:385
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:386
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:387
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:388
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:389
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:391
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:392
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:393
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:395
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:396
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:397
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:398
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:403
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:404
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:410
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:411
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:412
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:418
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:419
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:420
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:421
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:425
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:426
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:427
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:428
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:429
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:430
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:432
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:433
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:434
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:436
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:437
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:438
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:439
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:441
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:443
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:444
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:445
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:448
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:449
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:452
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:454
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:457
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:458
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:460
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:463
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:471
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:472
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:477
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:478
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:479
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:480
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:482
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:488
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:489
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:490
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:491
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:492
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:493
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:496
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:498
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:499
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:7
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:12
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:13
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:18
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:19
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:20
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:21
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:27
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:28
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:29
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:31
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:34
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:36
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:37
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:39
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:64
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:65
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:66
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:70
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:71
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:72
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:75
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:83
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:84
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:86
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:87
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:88
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:92
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:101
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:102
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:104
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:106
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:110
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:112
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:113
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:117
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:120
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:131
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:132
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:134
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:135
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:136
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:138
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:144
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:145
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:146
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:147
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:148
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:155
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:156
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:159
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:160
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:161
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:163
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:164
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:165
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:166
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:172
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:175
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:176
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:178
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:180
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:181
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:182
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:187
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:189
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:190
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:191
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:205
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:217
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:230
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:231
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:232
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:234
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:250
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:251
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:256
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:258
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:259
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:260
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:263
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:264
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:265
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:266
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:267
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:273
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:274
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:276
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:277
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:279
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:280
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:281
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:283
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:284
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:287
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:289
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:310
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:311
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:312
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:313
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:314
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:315
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:319
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:320
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:321
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:322
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:325
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:326
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:327
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:328
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:330
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:331
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:332
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:333
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:338
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:339
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:340
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:341
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:342
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:343
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:344
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:345
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:346
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:348
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:349
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:350
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:352
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:353
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:356
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:357
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:358
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:359
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:363
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:366
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:367
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:368
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:371
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:372
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:373
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:374
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:375
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:376
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:377
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:378
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:381
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:383
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:384
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 0.00 | covered=0 | missed=166 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 0.00 | covered=0 | missed=169 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 0.00 | covered=0 | missed=81 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 0.00 | covered=0 | missed=171 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 0.00 | covered=0 | missed=157 | SOURCEFILE_MATCHES: 1
LOSS: yes
```
```text

Starting discovery in 2 files.
Discovery found 23 tests in 189ms.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 941ms (362ms|439ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 180ms (85ms|73ms)
Tests completed in 1.14s
Tests Passed: 23, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 0.26% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: nc1-c1 | containers=2 | passed=23 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
ORDER-PRESERVED: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 23, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: nc1-c1 | containers=2 | passed=23 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
ORDER-PRESERVED: yes
R-LOSS:
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:13
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:15
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:17
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:24
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:25
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:28
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:30
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:39
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:40
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:42
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:44
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:55
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:56
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:57
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:58
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:59
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:69
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:70
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:71
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:73
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:74
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:76
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:77
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:79
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:93
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:94
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:96
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:97
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:98
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:100
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:101
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:102
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:103
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:104
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:105
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:106
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:109
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:110
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:111
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:120
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:121
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:123
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:124
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:140
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:141
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:142
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:143
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:144
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:146
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:148
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:149
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:151
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:152
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:154
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:155
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:156
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:157
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:158
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:159
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:160
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:161
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:162
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:163
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:164
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:166
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:167
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:168
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:171
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:172
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:177
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:180
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:182
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:183
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:184
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:186
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:190
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:192
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:194
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:196
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:197
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:198
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:199
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:201
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:203
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:205
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:207
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:222
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:223
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:225
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:226
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:227
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:229
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:230
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:231
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:232
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:234
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:235
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:237
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:238
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:239
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:241
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:242
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:244
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:245
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:246
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:247
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:248
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:249
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:252
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:254
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:257
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:260
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:261
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:263
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:270
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:278
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:279
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:280
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:282
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:285
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:288
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:289
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:290
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:293
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:294
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:295
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:296
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:297
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:298
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:299
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:300
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:301
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:302
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:303
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:304
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:305
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:307
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:308
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:311
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:313
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:314
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:317
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:319
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:322
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:324
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:327
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:329
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:330
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:333
LOST-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:336
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:12
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:14
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:15
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:22
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:23
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:37
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:38
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:39
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:41
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:44
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:46
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:58
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:59
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:61
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:62
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:64
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:65
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:66
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:67
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:68
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:70
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:71
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:72
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:73
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:75
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:76
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:77
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:78
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:80
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:83
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:86
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:93
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:94
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:95
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:96
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:97
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:108
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:112
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:122
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:123
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:127
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:129
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:130
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:131
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:133
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:134
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:135
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:137
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:139
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:151
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:153
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:155
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:156
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:162
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:163
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:164
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:168
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:169
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:170
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:171
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:175
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:176
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:181
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:182
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:183
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:184
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:185
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:187
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:189
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:192
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:194
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:195
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:196
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:197
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:200
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:211
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:213
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:214
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:216
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:217
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:218
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:219
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:221
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:222
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:224
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:226
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:227
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:229
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:230
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:233
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:234
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:235
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:236
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:237
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:239
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:241
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:243
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:244
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:246
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:248
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:250
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:251
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:254
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:257
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:258
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:259
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:262
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:265
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:266
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:267
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:268
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:270
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:276
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:277
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:278
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:279
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:280
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:282
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:285
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:287
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:288
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:289
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:290
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:293
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:296
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:299
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:300
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:303
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:318
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:319
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:320
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:322
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:323
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:325
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:328
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:331
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:332
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:333
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:336
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:337
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:338
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:339
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:340
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:344
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:345
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:346
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:347
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:354
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:358
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:361
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:364
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:367
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:369
LOST-LINE: .codex/hooks/enforce-epic-planning-only.ps1:370
LOST-LINE: .codex/hooks/validate-bash.ps1:16
LOST-LINE: .codex/hooks/validate-bash.ps1:22
LOST-LINE: .codex/hooks/validate-bash.ps1:23
LOST-LINE: .codex/hooks/validate-bash.ps1:30
LOST-LINE: .codex/hooks/validate-bash.ps1:31
LOST-LINE: .codex/hooks/validate-bash.ps1:59
LOST-LINE: .codex/hooks/validate-bash.ps1:60
LOST-LINE: .codex/hooks/validate-bash.ps1:63
LOST-LINE: .codex/hooks/validate-bash.ps1:64
LOST-LINE: .codex/hooks/validate-bash.ps1:65
LOST-LINE: .codex/hooks/validate-bash.ps1:66
LOST-LINE: .codex/hooks/validate-bash.ps1:67
LOST-LINE: .codex/hooks/validate-bash.ps1:71
LOST-LINE: .codex/hooks/validate-bash.ps1:72
LOST-LINE: .codex/hooks/validate-bash.ps1:76
LOST-LINE: .codex/hooks/validate-bash.ps1:97
LOST-LINE: .codex/hooks/validate-bash.ps1:98
LOST-LINE: .codex/hooks/validate-bash.ps1:99
LOST-LINE: .codex/hooks/validate-bash.ps1:101
LOST-LINE: .codex/hooks/validate-bash.ps1:102
LOST-LINE: .codex/hooks/validate-bash.ps1:105
LOST-LINE: .codex/hooks/validate-bash.ps1:155
LOST-LINE: .codex/hooks/validate-bash.ps1:156
LOST-LINE: .codex/hooks/validate-bash.ps1:159
LOST-LINE: .codex/hooks/validate-bash.ps1:161
LOST-LINE: .codex/hooks/validate-bash.ps1:162
LOST-LINE: .codex/hooks/validate-bash.ps1:163
LOST-LINE: .codex/hooks/validate-bash.ps1:164
LOST-LINE: .codex/hooks/validate-bash.ps1:165
LOST-LINE: .codex/hooks/validate-bash.ps1:167
LOST-LINE: .codex/hooks/validate-bash.ps1:169
LOST-LINE: .codex/hooks/validate-bash.ps1:174
LOST-LINE: .codex/hooks/validate-bash.ps1:175
LOST-LINE: .codex/hooks/validate-bash.ps1:176
LOST-LINE: .codex/hooks/validate-bash.ps1:177
LOST-LINE: .codex/hooks/validate-bash.ps1:181
LOST-LINE: .codex/hooks/validate-bash.ps1:194
LOST-LINE: .codex/hooks/validate-bash.ps1:195
LOST-LINE: .codex/hooks/validate-bash.ps1:196
LOST-LINE: .codex/hooks/validate-bash.ps1:199
LOST-LINE: .codex/hooks/validate-bash.ps1:210
LOST-LINE: .codex/hooks/validate-bash.ps1:211
LOST-LINE: .codex/hooks/validate-bash.ps1:212
LOST-LINE: .codex/hooks/validate-bash.ps1:213
LOST-LINE: .codex/hooks/validate-bash.ps1:214
LOST-LINE: .codex/hooks/validate-bash.ps1:234
LOST-LINE: .codex/hooks/validate-bash.ps1:236
LOST-LINE: .codex/hooks/validate-bash.ps1:237
LOST-LINE: .codex/hooks/validate-bash.ps1:238
LOST-LINE: .codex/hooks/validate-bash.ps1:242
LOST-LINE: .codex/hooks/validate-bash.ps1:246
LOST-LINE: .codex/hooks/validate-bash.ps1:247
LOST-LINE: .codex/hooks/validate-bash.ps1:250
LOST-LINE: .codex/hooks/validate-bash.ps1:267
LOST-LINE: .codex/hooks/validate-bash.ps1:268
LOST-LINE: .codex/hooks/validate-bash.ps1:270
LOST-LINE: .codex/hooks/validate-bash.ps1:272
LOST-LINE: .codex/hooks/validate-bash.ps1:273
LOST-LINE: .codex/hooks/validate-bash.ps1:274
LOST-LINE: .codex/hooks/validate-bash.ps1:277
LOST-LINE: .codex/hooks/validate-bash.ps1:284
LOST-LINE: .codex/hooks/validate-bash.ps1:285
LOST-LINE: .codex/hooks/validate-bash.ps1:288
LOST-LINE: .codex/hooks/validate-bash.ps1:290
LOST-LINE: .codex/hooks/validate-bash.ps1:292
LOST-LINE: .codex/hooks/validate-bash.ps1:293
LOST-LINE: .codex/hooks/validate-bash.ps1:295
LOST-LINE: .codex/hooks/validate-bash.ps1:296
LOST-LINE: .codex/hooks/validate-bash.ps1:298
LOST-LINE: .codex/hooks/validate-bash.ps1:301
LOST-LINE: .codex/hooks/validate-bash.ps1:304
LOST-LINE: .codex/hooks/validate-bash.ps1:305
LOST-LINE: .codex/hooks/validate-bash.ps1:306
LOST-LINE: .codex/hooks/validate-bash.ps1:309
LOST-LINE: .codex/hooks/validate-bash.ps1:310
LOST-LINE: .codex/hooks/validate-bash.ps1:311
LOST-LINE: .codex/hooks/validate-bash.ps1:312
LOST-LINE: .codex/hooks/validate-bash.ps1:313
LOST-LINE: .codex/hooks/validate-bash.ps1:315
LOST-LINE: .codex/hooks/validate-bash.ps1:317
LOST-LINE: .codex/hooks/validate-bash.ps1:318
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:14
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:37
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:44
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:45
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:46
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:47
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:48
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:49
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:50
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:51
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:57
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:58
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:59
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:66
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:77
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:78
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:80
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:94
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:102
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:103
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:128
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:129
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:130
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:133
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:141
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:142
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:143
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:146
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:147
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:148
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:149
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:152
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:153
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:154
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:155
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:159
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:160
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:166
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:167
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:169
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:170
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:179
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:182
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:184
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:205
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:206
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:209
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:210
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:211
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:214
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:215
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:216
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:217
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:220
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:241
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:242
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:245
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:246
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:247
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:249
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:250
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:253
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:254
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:262
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:263
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:265
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:266
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:267
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:268
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:269
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:271
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:272
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:273
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:276
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:277
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:280
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:281
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:292
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:293
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:295
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:303
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:304
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:305
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:306
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:319
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:320
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:321
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:322
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:323
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:339
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:340
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:366
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:367
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:369
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:370
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:373
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:375
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:378
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:383
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:384
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:385
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:386
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:387
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:388
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:389
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:391
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:392
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:393
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:395
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:396
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:397
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:398
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:403
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:404
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:410
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:411
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:412
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:418
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:419
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:420
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:421
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:425
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:426
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:427
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:428
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:429
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:430
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:432
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:433
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:434
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:436
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:437
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:438
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:439
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:441
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:443
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:444
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:445
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:448
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:449
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:452
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:454
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:457
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:458
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:460
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:463
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:471
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:472
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:477
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:478
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:479
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:480
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:482
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:488
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:489
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:490
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:491
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:492
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:493
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:496
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:498
LOST-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:499
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:7
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:12
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:13
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:18
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:19
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:20
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:21
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:27
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:28
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:29
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:31
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:34
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:36
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:37
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:39
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:64
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:65
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:66
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:70
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:71
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:72
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:75
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:83
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:84
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:86
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:87
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:88
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:92
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:101
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:102
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:104
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:106
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:107
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:110
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:112
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:113
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:114
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:117
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:120
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:131
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:132
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:134
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:135
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:136
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:138
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:144
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:145
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:146
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:147
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:148
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:155
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:156
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:159
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:160
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:161
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:163
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:164
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:165
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:166
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:172
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:173
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:174
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:175
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:176
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:178
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:179
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:180
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:181
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:182
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:187
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:188
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:189
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:190
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:191
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:205
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:217
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:230
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:231
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:232
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:234
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:250
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:251
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:253
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:255
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:256
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:258
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:259
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:260
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:263
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:264
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:265
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:266
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:267
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:273
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:274
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:276
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:277
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:279
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:280
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:281
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:283
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:284
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:287
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:289
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:310
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:311
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:312
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:313
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:314
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:315
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:319
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:320
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:321
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:322
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:325
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:326
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:327
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:328
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:330
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:331
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:332
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:333
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:338
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:339
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:340
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:341
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:342
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:343
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:344
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:345
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:346
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:348
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:349
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:350
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:352
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:353
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:356
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:357
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:358
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:359
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:363
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:366
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:367
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:368
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:371
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:372
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:373
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:374
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:375
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:376
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:377
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:378
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:381
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:383
LOST-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:384
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 0.00 | covered=0 | missed=166 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 0.00 | covered=0 | missed=169 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 0.00 | covered=0 | missed=81 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 0.00 | covered=0 | missed=171 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 0.00 | covered=0 | missed=157 | SOURCEFILE_MATCHES: 1
LOSS: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 1663, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: nc2-c1 | containers=62 | passed=1663 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 62 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
ORDER-PRESERVED: yes
R-LOSS:
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
LOSS: no
R-VALID: nc2-c1 | S containers compared=61 | mismatches=0 | valid
```
```text
PROBE_EXIT: 0
Tests Passed: 1791, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: nc3-c1 | containers=62 | passed=1791 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 62 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
ORDER-PRESERVED: yes
R-LOSS:
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
LOSS: no
R-VALID: nc3-c1 | S containers compared=61 | mismatches=0 | valid
```
```text

Starting discovery in 62 files.
Discovery found 1663 tests in 7.01s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 10.97s (5.81s|408ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 808ms (604ms|149ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 297ms (134ms|125ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 21.93s (21.87s|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 173ms (113ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 372ms (286ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 167ms (101ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 1.17s (1.07s|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 506ms (336ms|135ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 166ms (65ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 529ms (389ms|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 572ms (336ms|167ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 893ms (736ms|127ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 227ms (98ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 49.32s (49.24s|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 28.53s (28.42s|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 322ms (208ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 494ms (361ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 312ms (193ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 498ms (411ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 135ms (84ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 174ms (103ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 147ms (83ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 116ms (48ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 132ms (80ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 762ms (685ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 316ms (251ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 348ms (288ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 208ms (138ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 393ms (310ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 944ms (826ms|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 2.16s (2.01s|120ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 561ms (457ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 6.66s (6.34s|260ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 846ms (655ms|122ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 1.13s (1.05s|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.71s (1.55s|131ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 547ms (416ms|102ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 509ms (332ms|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 275ms (192ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 284ms (237ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 1.11s (1.02s|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 662ms (562ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 649ms (548ms|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 235ms (144ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 637ms (533ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 479ms (365ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 6.75s (6.58s|140ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 496ms (396ms|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 265ms (198ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 258ms (126ms|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 484ms (377ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 259ms (136ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 5.2s (4.62s|147ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 166ms (87ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 665ms (601ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 13.58s (13.48s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 146ms (91ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 525ms (410ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 208ms (156ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 261ms (156ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 676ms (527ms|102ms)
Tests completed in 170.44s
Tests Passed: 1663, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 27.47% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: nc2-c1 | containers=62 | passed=1663 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 62 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
ORDER-PRESERVED: yes
```
```text

Starting discovery in 62 files.
Discovery found 1791 tests in 3.43s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 14.71s (13.27s|607ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 458ms (344ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 249ms (134ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 19.47s (19.41s|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 255ms (152ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 576ms (469ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 189ms (123ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 934ms (851ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 573ms (378ms|128ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 193ms (93ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 486ms (350ms|99ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 294ms (169ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 607ms (488ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 309ms (153ms|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 48.4s (48.31s|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 31.65s (31.48s|112ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 266ms (150ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 290ms (200ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 199ms (120ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 306ms (249ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 148ms (66ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 185ms (100ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 139ms (86ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 97ms (47ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 131ms (69ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 667ms (579ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 292ms (223ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 315ms (256ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 179ms (129ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 317ms (257ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 489ms (412ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 1.6s (1.49s|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 282ms (227ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 4.05s (3.85s|139ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 802ms (647ms|124ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 942ms (874ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.28s (1.12s|107ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 386ms (284ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 347ms (217ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 238ms (158ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 237ms (192ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 834ms (759ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 382ms (304ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 275ms (213ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 136ms (80ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 421ms (352ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 273ms (181ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.86s (4.73s|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 316ms (250ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 178ms (119ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 242ms (127ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 475ms (366ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 282ms (158ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 4.34s (3.66s|112ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 116ms (56ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 391ms (331ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 12.86s (12.75s|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 157ms (105ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 569ms (443ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 213ms (161ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 222ms (145ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 506ms (413ms|56ms)
Tests completed in 161.67s
Tests Passed: 1791, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 28.41% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: nc3-c1 | containers=62 | passed=1791 | failed=0 | failedContainers=0
ORDER: 1 | tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 62 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
ORDER-PRESERVED: yes
```

## [P2-T6] Container bisection

## Cycle 1

Command: <SCRATCHPAD>/r1-bisect.ps1 -Cycle 1 -Side neither (C = PRE followed by POST from the C0 JUnit order, |C| = 280; LOSS(k) = R-COVPROBE over the first k entries of C placed around S, then R-LOSS against <SCRATCHPAD>/r1-probe-xs-c1-coverage.xml and R-VALID against probe-xs-c1)
EXIT_CODE: 4 (halt: PROBE INVALID)

```text
C-COUNT: 280
BISECT-START: lo=0 | hi=280 (LOSS(0) is X-S: no; LOSS(280) is the [P2-T4] reproducing run: yes)
RUN: bis-c1-k140 | entries=201 | ORDER-PRESERVED: yes | R-VALID: invalid | LOSS: no
HALT: PROBE INVALID at bis-c1-k140
```

R-VALID detail for bis-c1-k140 (list: the first 140 PRE containers, then S; no POST container):

```text
PROBE: bis-c1-k140 | containers=201 | passed=5705 | failed=1 | failedContainers=0
FAILED: baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
R-VALID-DIFF: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | reference passed=75 failed=0 | candidate passed=74 failed=1
R-VALID: bis-c1-k140 | S containers compared=61 | mismatches=1 | invalid
```

No BISECT predicate value is recorded for k=140, because R-VALID makes the loss predicate undefined for an invalid run. No CULPRIT line is recorded.

Full run output:

```text

Starting discovery in 201 files.
Discovery found 5706 tests in 43.22s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 1.54s (593ms|835ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 446ms (330ms|98ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 5.95s (5.64s|245ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 277ms (153ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 513ms (445ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 260ms (186ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 333ms (176ms|134ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 220ms (115ms|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 195ms (120ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 162ms (86ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 466ms (272ms|125ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 297ms (181ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 207ms (142ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 299ms (158ms|113ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 966ms (892ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 234ms (105ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 456ms (374ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 737ms (630ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 1.81s (1.59s|155ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 866ms (770ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 769ms (692ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 490ms (387ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 334ms (227ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 307ms (254ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 371ms (297ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 1.46s (1.36s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 1.42s (1.21s|133ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 236ms (180ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 296ms (250ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 155ms (77ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 417ms (297ms|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 151ms (106ms|29ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 190.42s (155.02s|304ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 200ms (140ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 355ms (294ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 598ms (505ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 2.73s (2.59s|102ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 263ms (209ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 240ms (164ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 2.99s (2.91s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 514ms (430ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 393ms (311ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 283ms (178ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 475ms (305ms|148ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 72ms (17ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 518ms (391ms|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 770ms (545ms|180ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 77ms (19ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 819ms (660ms|138ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 3.17s (3.03s|106ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 185ms (128ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 4.21s (4.02s|141ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 1.3s (1.19s|97ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 1.11s (1.04s|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 423ms (365ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 4.37s (4.29s|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 2.31s (2.1s|174ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 1.04s (894ms|114ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 966ms (868ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 530ms (446ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 456ms (334ms|97ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 340ms (235ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 408ms (302ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 194ms (141ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 461ms (330ms|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 244ms (189ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 266ms (186ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 413ms (289ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 862ms (667ms|163ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 516ms (435ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 718ms (647ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 2.06s (1.97s|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 1.1s (979ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 334ms (257ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 553ms (485ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 615ms (468ms|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 357ms (277ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 528ms (468ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 1.95s (1.86s|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 392ms (330ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 988ms (938ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 6.8s (6.69s|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 9.94s (9.83s|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.49s (1.42s|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 451ms (394ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 1.46s (1.4s|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 2.14s (1.98s|120ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 1.98s (1.89s|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 9.23s (9.17s|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 261ms (212ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 440ms (363ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 299ms (253ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 464ms (384ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 423ms (328ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 1.29s (1.2s|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 271ms (205ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 252ms (198ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 299ms (229ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 239ms (177ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 215ms (107ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 1.31s (1.23s|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 1.43s (1.34s|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 1.73s (1.57s|134ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 2.46s (2.35s|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 438ms (345ms|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 616ms (545ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 865ms (748ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 135ms (74ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 243ms (148ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 7.31s (6.71s|182ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 4.33s (1.52s|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 140ms (80ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.6s (2.51s|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 168ms (114ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 267ms (135ms|93ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 687ms (642ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 1.01s (977ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 325ms (255ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 267ms (210ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 826ms (752ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 111ms (55ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 140ms (80ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 418ms (338ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 92ms (40ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 650ms (610ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 1.05s (979ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 403ms (363ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 577ms (529ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 667ms (565ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 571ms (514ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 845ms (784ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 49ms (18ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 271ms (202ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 53ms (22ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 1.06s (1s|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 44ms (14ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 143ms (93ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 51ms (19ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 230ms (121ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ClaudeLibModuleConvention.Tests.ps1 1.13s (1.09s|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 376ms (316ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 144ms (66ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 14.1s (14.06s|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 111ms (70ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 286ms (240ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 95ms (59ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 546ms (496ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 326ms (223ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 117ms (55ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 267ms (190ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 253ms (150ms|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 306ms (226ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 185ms (96ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 31.08s (31.04s|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 24.37s (24.29s|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 225ms (145ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 296ms (202ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 168ms (91ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 301ms (245ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 100ms (58ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 159ms (104ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 142ms (98ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 80ms (42ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 117ms (60ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 626ms (561ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 284ms (223ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 320ms (274ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 192ms (140ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 332ms (267ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 445ms (372ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 1.61s (1.53s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 282ms (236ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 4.01s (3.86s|116ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 485ms (394ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 778ms (730ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.1s (959ms|118ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 303ms (229ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 278ms (176ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 188ms (139ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 201ms (165ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 803ms (733ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 355ms (261ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 254ms (196ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 111ms (73ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 392ms (329ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 201ms (141ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.78s (4.69s|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 274ms (226ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 157ms (103ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 183ms (96ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 421ms (339ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 234ms (139ms|70ms)
[-] Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe 41ms (40ms|1ms)
 at Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:130
 at Invoke-EpicStateProbeEpicScope, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:130
 at Invoke-EpicStateInterceptionProbe, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\EpicStateIsolation.Baseline.Helpers.ps1:174
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:131
 Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 81ms (43ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 324ms (281ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 11.57s (11.49s|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 135ms (97ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 473ms (378ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 197ms (156ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 291ms (209ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 496ms (389ms|86ms)
Tests completed in 442.54s
Tests Passed: 5705, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 64.65% / 0%. 25,713 analyzed Commands in 192 Files.
POPULATION: source=config | files=192
PROBE: bis-c1-k140 | containers=201 | passed=5705 | failed=1 | failedContainers=0
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
ORDER: 140 | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER: 141 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 142 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 143 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 144 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 145 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 146 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 147 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 148 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 149 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 150 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 151 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 152 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 153 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 154 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 155 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 156 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 157 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 158 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 159 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 160 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 161 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 162 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 163 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 164 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 165 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 166 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 167 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 168 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 169 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 170 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 171 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 172 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 173 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 174 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 175 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 176 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 177 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 178 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 179 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 180 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 181 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 182 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 183 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 184 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 185 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 186 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 187 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 188 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 189 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 190 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 191 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 192 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 193 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 194 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 195 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 196 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 197 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 198 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 199 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 200 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 201 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=74 | failed=1
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
FAILED: baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
ORDER-PRESERVED: yes
```
```text
PROBE_EXIT: 0
Tests Passed: 5705, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
POPULATION: source=config | files=192
PROBE: bis-c1-k140 | containers=201 | passed=5705 | failed=1 | failedContainers=0
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
ORDER: 140 | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER: 141 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 142 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 143 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 144 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 145 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 146 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 147 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 148 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 149 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 150 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 151 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 152 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 153 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 154 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 155 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 156 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 157 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 158 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 159 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 160 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 161 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 162 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 163 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 164 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 165 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 166 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 167 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 168 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 169 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 170 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 171 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 172 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 173 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 174 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 175 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 176 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 177 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 178 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 179 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 180 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 181 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 182 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 183 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 184 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 185 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 186 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 187 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 188 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 189 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 190 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 191 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 192 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 193 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 194 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 195 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 196 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 197 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 198 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 199 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 200 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 201 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=74 | failed=1
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
FAILED: baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
ORDER-PRESERVED: yes
R-LOSS:
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1
LOSS: no
R-VALID-DIFF: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | reference passed=75 failed=0 | candidate passed=74 failed=1
R-VALID: bis-c1-k140 | S containers compared=61 | mismatches=1 | invalid
```
