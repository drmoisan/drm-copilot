#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Repository guard: a module or helper imported by a registered hook writes nothing to the success
    or warning stream (issue #792).

.DESCRIPTION
    Hooks are discovered from .claude/settings.json and .codex/config.toml (PreToolUse and
    SubagentStop), and the transitive closure of every imported module and dot-sourced helper is
    scanned with the AST detector of HookGuardShape.Helpers.ps1. Registered entry scripts are out of
    scope, including when another hook dot-sources one. The repository roots and both bundle mirror
    roots are scanned and the mirror findings must equal the repository findings. The detector and
    the discovery helper read through injectable seams, so every fixture is a here-string and no
    file is written.
#>

BeforeDiscovery {
    $script:RootRows = @(@{ Root = 'repository' }, @{ Root = 'mirror' })
    $script:OffenderRows = @('Write-Output', 'write', 'echo', 'Write-Host', 'Write-Information', 'Write-Warning', 'Out-Host', '[Console]::Write', '[Console]::WriteLine', '[System.Console]::WriteLine', '[Console]::Out.WriteLine', '[System.Console]::Out.Write') | ForEach-Object { @{ Form = $_ } }
    $script:AllowedRows = @('[Console]::Error.WriteLine', 'a comment', 'a string literal', 'Write-Verbose', 'Write-Error', 'Write-Debug') | ForEach-Object { @{ Form = $_ } }
}

Describe 'hook-imported modules write nothing to the success or warning stream (issue #792)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'HookGuardShape.Helpers.ps1')
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        $script:Roots = @{
            repository = @{ Claude = $script:RepoRoot; Codex = $script:RepoRoot }
            mirror     = @{ Claude = "$script:RepoRoot/extensions/drm-copilot/resources/claude-customizations"; Codex = "$script:RepoRoot/extensions/drm-copilot/resources/codex-and-agents-customizations" }
        }

        function Get-ImportedModuleStdoutFinding {
            # Findings for every non-entry file in the import closure of every registered hook.
            param([string] $ClaudeRoot, [string] $CodexRoot, [scriptblock] $ReadText, [scriptblock] $TestPath)
            $graph = @{}
            $discovery = @{ ClaudeRoot = $ClaudeRoot; CodexRoot = $CodexRoot }
            if ($ReadText) { $graph['ReadText'] = $ReadText; $discovery['ReadText'] = $ReadText }
            if ($TestPath) { $graph['TestPath'] = $TestPath }
            $registrations = @(Get-HookRegistration @discovery | Where-Object Hook -ne 'INLINE')
            $entries = @{}
            foreach ($r in $registrations) { $entries["$($r.Root)|$($r.Hook)"] = $true }
            $scanned = @{}
            foreach ($r in $registrations) {
                foreach ($edge in @(Get-HookDependencyClosure -Registration $r -IncludeRuntimeTargets @graph)) {
                    if ($edge.Target -like 'UNRESOLVED*' -or $entries.ContainsKey("$($r.Root)|$($edge.Target)") -or $scanned.ContainsKey("$($r.Root)|$($edge.Target)")) { continue }
                    $scanned["$($r.Root)|$($edge.Target)"] = $true
                    $reader = if ($ReadText) { $ReadText } else { $script:HookGraphDefaultReadText }
                    $text = & $reader (Join-HookGraphPath -Left $r.Root -Right $edge.Target)
                    if ($null -ne $text) { Get-HookStdoutWriteFinding -ScriptText $text -SourceLabel $edge.Target }
                }
            }
        }

        function New-SyntheticReader {
            # A ReadText and TestPath pair over an in-memory path-to-text map.
            param([hashtable] $Files)
            $map = $Files
            return @{ ReadText = { param([string] $Path) $map[$Path] }.GetNewClosure(); TestPath = { param([string] $Path) $map.ContainsKey($Path) }.GetNewClosure() }
        }

        $script:SyntheticSettings = '{"hooks":{"PreToolUse":[{"matcher":"Write","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/synthetic-gate.ps1"},{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/synthetic-entry.ps1"}]}],"SubagentStop":[{"hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/synthetic-stop.ps1"}]}]}}'
        $script:SyntheticConfig = "[[hooks.PreToolUse]]`ncommand = `"pwsh -NoProfile -File .codex/hooks/synthetic-codex.ps1`"`n[[hooks.SubagentStop]]`ncommand = `"pwsh -NoProfile -File .codex/hooks/synthetic-codex-stop.ps1`"`n"
    }

    It 'N1: <Root> reports no success- or warning-stream write in any module or helper imported by a registered hook' -ForEach $script:RootRows {
        # Arrange
        $pair = $script:Roots[$Root]
        # Act
        $findings = @(Get-ImportedModuleStdoutFinding -ClaudeRoot $pair.Claude -CodexRoot $pair.Codex)
        # Assert
        $findings | ForEach-Object { "$($_.SourceLabel):$($_.Line) $($_.Form)" } | Should -BeNullOrEmpty
    }

    It 'N2: mirror findings equal repository findings' {
        $repo = @(Get-ImportedModuleStdoutFinding -ClaudeRoot $script:Roots.repository.Claude -CodexRoot $script:Roots.repository.Codex | ForEach-Object { "$($_.SourceLabel):$($_.Line) $($_.Form)" })
        $mirror = @(Get-ImportedModuleStdoutFinding -ClaudeRoot $script:Roots.mirror.Claude -CodexRoot $script:Roots.mirror.Codex | ForEach-Object { "$($_.SourceLabel):$($_.Line) $($_.Form)" })
        @(Compare-Object -ReferenceObject $repo -DifferenceObject $mirror) | Should -BeNullOrEmpty
    }

    It 'N3: discovers registered PreToolUse and SubagentStop hooks from both registrations' {
        # Arrange: a synthetic settings.json and config.toml supplied through the text seam.
        $reader = New-SyntheticReader -Files @{ '/synthetic-root/.claude/settings.json' = $script:SyntheticSettings; '/synthetic-root/.codex/config.toml' = $script:SyntheticConfig }
        # Act
        $registrations = @(Get-HookRegistration -ClaudeRoot '/synthetic-root' -CodexRoot '/synthetic-root' -ReadText $reader.ReadText)
        $live = @(Get-HookRegistration -ClaudeRoot $script:RepoRoot -CodexRoot $script:RepoRoot)
        # Assert
        @($registrations | ForEach-Object { "$($_.Surface)|$($_.Event)|$($_.Hook)" }) | Should -Be @(
            'claude|PreToolUse|.claude/hooks/synthetic-gate.ps1', 'claude|PreToolUse|.claude/hooks/synthetic-entry.ps1', 'claude|SubagentStop|.claude/hooks/synthetic-stop.ps1',
            'codex|PreToolUse|.codex/hooks/synthetic-codex.ps1', 'codex|SubagentStop|.codex/hooks/synthetic-codex-stop.ps1')
        foreach ($key in 'claude|PreToolUse', 'claude|SubagentStop', 'codex|PreToolUse', 'codex|SubagentStop') {
            @($live | Where-Object { "$($_.Surface)|$($_.Event)" -eq $key }).Count | Should -BeGreaterThan 0 -Because "the live registrations include $key hooks"
        }
    }

    It 'N4: reports <Form> as an offender' -ForEach $script:OffenderRows {
        # Arrange: one here-string fixture per flagged form.
        $fixtures = @{
            'Write-Output' = "Write-Output 'text'"; 'write' = "write 'text'"; 'echo' = "echo 'text'"; 'Write-Host' = "Write-Host 'text'"
            'Write-Information' = "Write-Information 'text'"; 'Write-Warning' = "Write-Warning 'text'"; 'Out-Host' = "'text' | Out-Host"
            '[Console]::Write' = "[Console]::Write('text')"; '[Console]::WriteLine' = "[Console]::WriteLine('text')"
            '[System.Console]::WriteLine' = "[System.Console]::WriteLine('text')"; '[Console]::Out.WriteLine' = "[Console]::Out.WriteLine('text')"
            '[System.Console]::Out.Write' = "[System.Console]::Out.Write('text')"
        }
        $text = "function Get-Sample {`n    $($fixtures[$Form])`n}`n"
        # Act
        $findings = @(Get-HookStdoutWriteFinding -ScriptText $text -SourceLabel 'synthetic.psm1')
        # Assert
        $findings.Count | Should -Be 1 -Because "the form $Form writes to the success or warning stream"
        $findings[0].Line | Should -Be 2
    }

    It 'N5: does not report <Form>' -ForEach $script:AllowedRows {
        $fixtures = @{
            '[Console]::Error.WriteLine' = "[Console]::Error.WriteLine('text')"; 'a comment' = "# Write-Output 'text' and [Console]::WriteLine('text')"
            'a string literal' = "`$value = 'Write-Output Write-Host [Console]::WriteLine'"; 'Write-Verbose' = "Write-Verbose 'text'"
            'Write-Error' = "Write-Error 'text'"; 'Write-Debug' = "Write-Debug 'text'"
        }
        @(Get-HookStdoutWriteFinding -ScriptText $fixtures[$Form] -SourceLabel 'synthetic.psm1') | Should -BeNullOrEmpty
    }

    It 'N6: reports an offender in a module imported transitively by a synthetic registered hook' {
        # Arrange: hook -> First.psm1 -> Second.psm1, which writes a warning.
        $reader = New-SyntheticReader -Files @{
            '/synthetic-root/.claude/settings.json'             = $script:SyntheticSettings
            '/synthetic-root/.codex/config.toml'                = ''
            '/synthetic-root/.claude/hooks/synthetic-gate.ps1'  = "Import-Module (Join-Path `$PSScriptRoot '../lib/sample/First.psm1') -Force -ErrorAction Stop`n"
            '/synthetic-root/.claude/lib/sample/First.psm1'     = "Import-Module (Join-Path `$PSScriptRoot 'Second.psm1') -Force -ErrorAction Stop`n"
            '/synthetic-root/.claude/lib/sample/Second.psm1'    = "function Get-Value {`n    Write-Warning 'diagnostic'`n}`n"
        }
        # Act
        $findings = @(Get-ImportedModuleStdoutFinding -ClaudeRoot '/synthetic-root' -CodexRoot '/synthetic-root' -ReadText $reader.ReadText -TestPath $reader.TestPath)
        # Assert
        @($findings | ForEach-Object { "$($_.SourceLabel):$($_.Line) $($_.Form)" }) | Should -Be @('.claude/lib/sample/Second.psm1:2 Write-Warning')
    }

    It 'N7: does not report a Write-Output in a registered entry script invoked directly' {
        $reader = New-SyntheticReader -Files @{
            '/synthetic-root/.claude/settings.json'              = $script:SyntheticSettings
            '/synthetic-root/.codex/config.toml'                 = ''
            '/synthetic-root/.claude/hooks/synthetic-entry.ps1'  = "`$decision | ConvertTo-Json | Write-Output`n"
        }
        @(Get-ImportedModuleStdoutFinding -ClaudeRoot '/synthetic-root' -CodexRoot '/synthetic-root' -ReadText $reader.ReadText -TestPath $reader.TestPath) | Should -BeNullOrEmpty
    }

    It 'N8: does not report a Write-Output in a registered entry script dot-sourced by another hook' {
        $reader = New-SyntheticReader -Files @{
            '/synthetic-root/.claude/settings.json'              = $script:SyntheticSettings
            '/synthetic-root/.codex/config.toml'                 = ''
            '/synthetic-root/.claude/hooks/synthetic-gate.ps1'   = ". (Join-Path `$PSScriptRoot 'synthetic-entry.ps1')`n"
            '/synthetic-root/.claude/hooks/synthetic-entry.ps1'  = "if (`$MyInvocation.InvocationName -eq '.') { return }`n`$decision | ConvertTo-Json | Write-Output`n"
        }
        @(Get-ImportedModuleStdoutFinding -ClaudeRoot '/synthetic-root' -CodexRoot '/synthetic-root' -ReadText $reader.ReadText -TestPath $reader.TestPath) | Should -BeNullOrEmpty
    }
}
