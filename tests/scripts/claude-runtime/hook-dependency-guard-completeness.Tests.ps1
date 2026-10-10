#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Structural completeness test for the hook dependency guard (issue #786, FR-10).

.DESCRIPTION
    Hooks are discovered from .claude/settings.json and .codex/config.toml (no fixed hook list) on
    the repository roots and on both bundle mirror roots. For every registered PreToolUse and
    SubagentStop hook the AST shape is checked (S1 bootstrap and tail, S2 single-statement guards
    recorded through Add-HookDependencyFailure, S3 -ErrorAction Stop, S6 decision-function check)
    and the transitive closure is walked (S4 coverage and termination, S5 runtime pre-loads). The
    only exemptions come from HookImportFailureExemptions.Helpers.ps1. Fixtures F1 to F8 prove each
    failure condition is reported through in-memory here-strings; no file is written.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'HookDependencyGraph.Helpers.ps1')
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
    $pairs = [ordered]@{
        repository = @($repoRoot, $repoRoot)
        mirror     = @("$repoRoot/extensions/drm-copilot/resources/claude-customizations", "$repoRoot/extensions/drm-copilot/resources/codex-and-agents-customizations")
    }
    $script:HookRows = foreach ($name in $pairs.Keys) {
        foreach ($r in @(Get-HookRegistration -ClaudeRoot $pairs[$name][0] -CodexRoot $pairs[$name][1] | Where-Object Hook -ne 'INLINE')) {
            @{ Root = $name; Surface = $r.Surface; Event = $r.Event; Hook = $r.Hook; RootPath = $r.Root }
        }
    }
}

Describe 'hook dependency guard structural completeness (issue #786)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'HookGuardShape.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'HookImportFailureExemptions.Helpers.ps1')
        $script:Exemptions = @(Get-HookImportFailureExemption)
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        $script:ShapeCache = @{}

        function Get-ShapeFinding {
            # Cached shape findings of one registered hook.
            param([string] $RootPath, [string] $Hook, [string] $HookEvent)
            $key = "$RootPath|$Hook"
            if (-not $script:ShapeCache.ContainsKey($key)) {
                $text = Get-Content -LiteralPath (Join-HookGraphPath -Left $RootPath -Right $Hook) -Raw
                $script:ShapeCache[$key] = @(Get-HookGuardShapeFinding -ScriptText $text -HookPath $Hook -HookEvent $HookEvent -Exemption $script:Exemptions)
            }
            return $script:ShapeCache[$key]
        }

        function Get-TransitiveFinding {
            # S4: closure edges (Runtime False) that are uncovered or non-terminating.
            param([pscustomobject] $Registration, [scriptblock] $ReadText = $script:HookGraphDefaultReadText, [scriptblock] $TestPath = $script:HookGraphDefaultTestPath)
            foreach ($edge in @(Get-HookDependencyClosure -Registration $Registration -ReadText $ReadText -TestPath $TestPath | Where-Object { -not $_.Runtime })) {
                if (-not $edge.Covered) { "S4: $($edge.Via):$($edge.Line) $($edge.Leaf) is neither guarded nor covered" }
                elseif (-not $edge.Terminating) { "S4: $($edge.Via):$($edge.Line) $($edge.Leaf) is not terminating" }
            }
        }

        function Get-RuntimeFinding {
            # S5: every runtime edge of the closure has a guarded hook-level pre-load of the same target.
            param([pscustomobject] $Registration, [object[]] $Exemption, [scriptblock] $ReadText = $script:HookGraphDefaultReadText, [scriptblock] $TestPath = $script:HookGraphDefaultTestPath)
            $closure = @(Get-HookDependencyClosure -Registration $Registration -ReadText $ReadText -TestPath $TestPath)
            $preloads = @($closure | Where-Object { $_.Via -eq $Registration.Hook -and $_.Kind -eq 'Module' -and -not $_.Runtime -and $_.Guarded -and $_.ErrorActionStop } | ForEach-Object Target)
            $designed = @($Exemption | Where-Object { $_.Kind -eq 'Design' -and @($_.HandlerFile) -contains $Registration.Hook } | ForEach-Object { $_.Leaf })
            foreach ($edge in @($closure | Where-Object { $_.Runtime -and $_.Kind -eq 'Module' })) {
                if ($designed -contains $edge.Leaf) { continue }
                if ($preloads -notcontains $edge.Target) { "S5: runtime import of $($edge.Leaf) at $($edge.Via):$($edge.Line) is not pre-loaded under a guard" }
            }
        }

        function New-Registration {
            param([string] $RootPath, [string] $Surface, [string] $HookEvent, [string] $Hook)
            return [pscustomobject]@{ Surface = $Surface; Event = $HookEvent; Root = $RootPath; Hook = $Hook; Path = (Join-HookGraphPath -Left $RootPath -Right $Hook) }
        }

        function New-SyntheticReader {
            param([hashtable] $Files)
            $map = $Files
            return @{ ReadText = { param([string] $Path) $map[$Path] }.GetNewClosure(); TestPath = { param([string] $Path) $map.ContainsKey($Path) }.GetNewClosure() }
        }

        # A conforming synthetic hook; #EDGES# and #TAIL# are replaced per fixture.
        $script:Skeleton = @'
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
#EDGES#
function Invoke-SampleDecision {
    param([string] $ToolInputRaw)
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'SAMPLE_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    return $null
}
#BEFORE#
if ($MyInvocation.InvocationName -eq '.') {
    return
}
#TAIL#
exit 0
'@
        $script:Tail = @'
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('SAMPLE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'SAMPLE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
'@
        $script:GuardedPayload = "try { Import-Module (Join-Path `$PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord `$_ }"

        function New-SampleHook {
            param([string] $Edges = $script:GuardedPayload, [string] $Before = '', [string] $TailText = $script:Tail, [switch] $NoBootstrap)
            $text = $script:Skeleton.Replace('#EDGES#', $Edges).Replace('#BEFORE#', $Before).Replace('#TAIL#', $TailText)
            if ($NoBootstrap) { $text = $text.Replace("`$script:HookDependencyGuardLoadFailed = `$false; try { . (Join-Path `$PSScriptRoot 'hook-dependency-guard.ps1') } catch { `$script:HookDependencyGuardLoadFailed = `$true }", '') }
            return $text
        }
    }

    It 'S1: <Root> <Surface> <Event> <Hook> carries the bootstrap try and the tail check after the dot-source early return' -ForEach $script:HookRows {
        @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty
    }

    It 'S2: <Root> <Surface> <Event> <Hook> guards every direct edge in its own single-statement try' -ForEach $script:HookRows {
        @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty
    }

    It 'S3: <Root> <Surface> <Event> <Hook> uses -ErrorAction Stop on every guarded Import-Module' -ForEach $script:HookRows {
        @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S3:*' }) | Should -BeNullOrEmpty
    }

    It 'S4: <Root> <Surface> <Event> <Hook> leaves no transitive edge uncovered or non-terminating' -ForEach $script:HookRows {
        @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty
    }

    It 'S5: <Root> <Surface> <Event> <Hook> pre-loads every runtime edge under a guard' -ForEach $script:HookRows {
        @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty
    }

    It 'S6: <Root> <Surface> <Event> <Hook> returns the dependency decision first in its decision function' -ForEach $script:HookRows {
        @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty
    }

    It 'S7: discovers hooks from .claude/settings.json and .codex/config.toml' {
        # Arrange: a synthetic registration pair proves discovery reads the registrations, not a list.
        $reader = New-SyntheticReader -Files @{
            '/synthetic-root/.claude/settings.json' = '{"hooks":{"PreToolUse":[{"hooks":[{"command":"pwsh -NoProfile -File .claude/hooks/sample-gate.ps1"}]}],"SubagentStop":[{"hooks":[{"command":"pwsh -NoProfile -Command \"exit 0\""}]}]}}'
            '/synthetic-root/.codex/config.toml'    = "[[hooks.SubagentStop]]`ncommand = `"pwsh -NoProfile -File .codex/hooks/sample-stop.ps1`"`n"
        }
        # Act
        $synthetic = @(Get-HookRegistration -ClaudeRoot '/synthetic-root' -CodexRoot '/synthetic-root' -ReadText $reader.ReadText | ForEach-Object { "$($_.Surface)|$($_.Event)|$($_.Hook)" })
        $live = @(Get-HookRegistration -ClaudeRoot $script:RepoRoot -CodexRoot $script:RepoRoot | Where-Object Hook -ne 'INLINE')
        # Assert
        $synthetic | Should -Be @('claude|PreToolUse|.claude/hooks/sample-gate.ps1', 'claude|SubagentStop|INLINE', 'codex|SubagentStop|.codex/hooks/sample-stop.ps1')
        @($live | Where-Object Surface -eq 'claude').Count | Should -BeGreaterThan 0
        @($live | Where-Object Surface -eq 'codex').Count | Should -BeGreaterThan 0
    }

    It 'S8: names every exemption with its justification' {
        @($script:Exemptions | Where-Object { $_.Kind -eq 'Design' } | ForEach-Object Id) | Should -Be @('D2', 'D3')
        foreach ($entry in $script:Exemptions) {
            $entry.Justification.StartsWith($entry.Id, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "exemption $($entry.Id) must carry its named justification"
            $entry.Justification.Length | Should -BeGreaterThan 40
        }
    }

    It 'F1: reports an unguarded direct edge in a synthetic hook' {
        $text = New-SampleHook -Edges "Import-Module (Join-Path `$PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop"
        @(Get-HookGuardShapeFinding -ScriptText $text -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse | Where-Object { $_ -like 'S2:*HookPayload.psm1*' }).Count | Should -Be 1
    }

    It 'F2: reports a try body that holds more than the import statement' {
        $text = New-SampleHook -Edges "try { Import-Module (Join-Path `$PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop; `$loaded = `$true } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord `$_ }"
        @(Get-HookGuardShapeFinding -ScriptText $text -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse | Where-Object { $_ -like 'S2:*single-statement*' }).Count | Should -Be 1
    }

    It 'F3: reports a guarded Import-Module without -ErrorAction Stop' {
        $text = New-SampleHook -Edges "try { Import-Module (Join-Path `$PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord `$_ }"
        @(Get-HookGuardShapeFinding -ScriptText $text -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse | Where-Object { $_ -like 'S3:*' }).Count | Should -Be 1
    }

    It 'F4: reports a hook without the bootstrap try' {
        $findings = @(Get-HookGuardShapeFinding -ScriptText (New-SampleHook -NoBootstrap) -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse)
        @($findings | Where-Object { $_ -like 'S1: bootstrap*' }).Count | Should -Be 1
        @(Get-HookGuardShapeFinding -ScriptText (New-SampleHook) -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse) | Should -BeNullOrEmpty -Because 'the conforming skeleton reports nothing'
    }

    It 'F5: reports a missing tail check or one placed before the dot-source early return' {
        $missing = @(Get-HookGuardShapeFinding -ScriptText (New-SampleHook -TailText '') -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse)
        $early = @(Get-HookGuardShapeFinding -ScriptText (New-SampleHook -TailText '' -Before $script:Tail) -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse)
        @($missing | Where-Object { $_ -like 'S1:*' }).Count | Should -Be 1
        @($early | Where-Object { $_ -like 'S1:*' }).Count | Should -Be 1
    }

    It 'F6: reports a runtime import that is not pre-loaded under a guard' {
        $hook = New-SampleHook -Edges ($script:GuardedPayload + "`nfunction Get-Lazy { if (-not (Get-Command -Name Test-Lazy -ErrorAction SilentlyContinue)) { Import-Module (Join-Path `$PSScriptRoot '../lib/lazy/Lazy.psm1') -Force } }")
        $reader = New-SyntheticReader -Files @{ '/synthetic-root/.claude/hooks/sample-gate.ps1' = $hook; '/synthetic-root/.claude/lib/lazy/Lazy.psm1' = "function Test-Lazy { `$true }`n" }
        $findings = @(Get-RuntimeFinding -Registration (New-Registration -RootPath '/synthetic-root' -Surface 'claude' -HookEvent 'PreToolUse' -Hook '.claude/hooks/sample-gate.ps1') -Exemption @() -ReadText $reader.ReadText -TestPath $reader.TestPath)
        @($findings | Where-Object { $_ -like 'S5:*Lazy.psm1*' }).Count | Should -Be 1
    }

    It 'F7: reports a transitive Import-Module that is neither terminating nor covered' {
        $hook = New-SampleHook -Edges ". (Join-Path `$PSScriptRoot 'sample-helpers.ps1')"
        $reader = New-SyntheticReader -Files @{
            '/synthetic-root/.claude/hooks/sample-gate.ps1'    = $hook
            '/synthetic-root/.claude/hooks/sample-helpers.ps1' = "Import-Module (Join-Path `$PSScriptRoot '../lib/sample/Nested.psm1') -Force`n"
            '/synthetic-root/.claude/lib/sample/Nested.psm1'   = "function Get-Nested { 1 }`n"
        }
        $findings = @(Get-TransitiveFinding -Registration (New-Registration -RootPath '/synthetic-root' -Surface 'claude' -HookEvent 'PreToolUse' -Hook '.claude/hooks/sample-gate.ps1') -ReadText $reader.ReadText -TestPath $reader.TestPath)
        @($findings | Where-Object { $_ -like 'S4:*Nested.psm1*' }).Count | Should -Be 1
    }

    It 'F8: does not report the named exemptions' {
        # Arrange: a D2-style runtime import, the D3 absence-path block, and a synthetic handler entry.
        $edges = @(
            $script:GuardedPayload,
            '$script:SampleImportFailure = $null',
            "try { . (Join-Path `$PSScriptRoot 'sample-resolution.ps1') } catch { `$script:SampleImportFailure = 'sample-resolution.ps1' }",
            "`$contractPath = Join-Path `$PSScriptRoot '../scripts/epic-child-launch-contract.ps1'",
            "if (Test-Path -LiteralPath `$contractPath -PathType Leaf) { try { . `$contractPath } catch { Add-HookDependencyFailure -Name 'epic-child-launch-contract.ps1' -ErrorRecord `$_ } }",
            "function Test-Mermaid { try { Import-Module (Join-Path `$PSScriptRoot '../lib/mermaid/MermaidValidation.psm1') -ErrorAction Stop; return `$true } catch { return `$false } }") -join "`n"
        $hook = New-SampleHook -Edges $edges
        $exemption = @(
            [pscustomobject]@{ Id = 'D2'; Kind = 'Design'; Surface = 'claude'; HandlerFile = @('.claude/hooks/sample-gate.ps1'); Leaf = @('MermaidValidation.psm1'); Justification = 'D2: synthetic' },
            [pscustomobject]@{ Id = 'HX'; Kind = 'Handler'; Surface = 'claude'; HandlerFile = '.claude/hooks/sample-gate.ps1'; Variable = 'SampleImportFailure'; Leaf = @('sample-resolution.ps1') })
        $reader = New-SyntheticReader -Files @{
            '/synthetic-root/.claude/hooks/sample-gate.ps1'                = $hook
            '/synthetic-root/.claude/hooks/sample-resolution.ps1'          = "function Get-Sample { 1 }`n"
            '/synthetic-root/.claude/lib/mermaid/MermaidValidation.psm1'   = "function Test-MermaidBlock { `$true }`n"
        }
        $registration = New-Registration -RootPath '/synthetic-root' -Surface 'claude' -HookEvent 'PreToolUse' -Hook '.claude/hooks/sample-gate.ps1'
        # Act
        $shape = @(Get-HookGuardShapeFinding -ScriptText $hook -HookPath '.claude/hooks/sample-gate.ps1' -HookEvent PreToolUse -Exemption $exemption)
        $runtime = @(Get-RuntimeFinding -Registration $registration -Exemption $exemption -ReadText $reader.ReadText -TestPath $reader.TestPath)
        $transitive = @(Get-TransitiveFinding -Registration $registration -ReadText $reader.ReadText -TestPath $reader.TestPath)
        # Assert
        $shape | Should -BeNullOrEmpty
        $runtime | Should -BeNullOrEmpty
        $transitive | Should -BeNullOrEmpty
    }
}
