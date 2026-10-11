#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Exemption guard for the named import-failure handler exemptions (issue #786; operator decision of
    2026-10-09, option 1).

.DESCRIPTION
    Over the .claude/hooks and .codex/hooks roots of the repository and of both bundle mirrors, the
    guard proves that every named handler exemption still exists at its handler site (G1), that no
    scoped import-failure handler exists outside the named-exemption list (G2), and that every named
    exemption's deny code still appears in its deny path (G3). Fixtures GF1 to GF4 feed here-string
    hooks through the ReadText and ListFiles seams, so no file is written.
#>

BeforeDiscovery {
    $script:RootRows = @(@{ Root = 'repository' }, @{ Root = 'mirror' })
}

Describe 'named import-failure handler exemptions guard (issue #786)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'HookImportFailureExemptions.Helpers.ps1')
        $script:Exemptions = @(Get-HookImportFailureExemption)
        $repo = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        $script:HookRoots = @{
            repository = @("$repo/.claude/hooks", "$repo/.codex/hooks")
            mirror     = @("$repo/extensions/drm-copilot/resources/claude-customizations/.claude/hooks", "$repo/extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks")
        }

        function Get-RootFinding {
            param([string] $Root)
            foreach ($hookRoot in $script:HookRoots[$Root]) { Get-HookExemptionFinding -Exemption $script:Exemptions -HookRoot $hookRoot }
        }

        $script:SampleEntry = [pscustomobject]@{
            Id = 'HX'; Kind = 'Handler'; Surface = 'claude'; HandlerFile = '.claude/hooks/sample-gate.ps1'; Variable = 'SampleImportFailure'; Leaf = @('sample-resolution.ps1')
            ConsumerFile = '.claude/hooks/sample-gate.ps1'; DenyPathFile = '.claude/hooks/sample-gate.ps1'; DenyPathCondition = '$script:SampleImportFailure'; DenyCode = 'SAMPLE_BLOCKED:'
            Justification = 'HX: synthetic handler'
        }
        $script:SampleHandler = @'
$script:SampleImportFailure = $null
try {
    . (Join-Path $PSScriptRoot 'sample-resolution.ps1')
}
catch {
    $script:SampleImportFailure = 'sample-resolution.ps1'
}
function Invoke-SampleDecision {
    if ($script:SampleImportFailure) { return 'SAMPLE_BLOCKED: the dependency failed to load' }
    return 'allow'
}
'@

        function Get-FixtureFinding {
            # Findings for one synthetic hook text under /synthetic-root/.claude/hooks.
            param([string] $HookText)
            $files = @{ '/synthetic-root/.claude/hooks/sample-gate.ps1' = $HookText }
            $read = { param([string] $Path) $files[$Path] }.GetNewClosure()
            $list = { param([string] $Directory) $null = $Directory; @($files.Keys) }.GetNewClosure()
            return @(Get-HookExemptionFinding -Exemption @($script:SampleEntry) -HookRoot '/synthetic-root/.claude/hooks' -ReadText $read -ListFiles $list)
        }
    }

    It 'G1: <Root> finds every named handler exemption at its handler site' -ForEach $script:RootRows {
        @(Get-RootFinding -Root $Root | Where-Object { $_ -like 'EXEMPTION-MISSING:*' }) | Should -BeNullOrEmpty
    }

    It 'G2: <Root> reports no scoped import-failure handler outside the named-exemption list' -ForEach $script:RootRows {
        @(Get-RootFinding -Root $Root | Where-Object { $_ -like 'UNLISTED-HANDLER:*' }) | Should -BeNullOrEmpty
    }

    It 'G3: <Root> finds the deny code of every named handler exemption in its deny path' -ForEach $script:RootRows {
        @(Get-RootFinding -Root $Root | Where-Object { $_ -like 'DENY-CODE-MISSING:*' }) | Should -BeNullOrEmpty
    }

    It 'GF1: reports a named exemption whose handler site no longer exists' {
        # The catch no longer records into the exemption's variable, so the handler site is gone.
        $text = ($script:SampleHandler -replace "(?s)catch \{\s+\`$script:SampleImportFailure = 'sample-resolution.ps1'\s+\}", "catch { Write-Verbose 'ignored' }")
        @(Get-FixtureFinding -HookText $text | Where-Object { $_ -like 'EXEMPTION-MISSING: HX*' }).Count | Should -Be 1
    }

    It 'GF2: reports a scoped import-failure handler that is not in the named-exemption list' {
        $text = $script:SampleHandler + "`ntry { . (Join-Path `$PSScriptRoot 'other-resolution.ps1') } catch { `$script:OtherImportFailure = 'other-resolution.ps1' }`n"
        $findings = @(Get-FixtureFinding -HookText $text)
        @($findings | Where-Object { $_ -like 'UNLISTED-HANDLER:*OtherImportFailure*other-resolution.ps1*' }).Count | Should -Be 1
        @($findings | Where-Object { $_ -like 'UNLISTED-HANDLER:*SampleImportFailure*' }) | Should -BeNullOrEmpty
    }

    It 'GF3: reports a named exemption whose deny code no longer appears in its deny path' {
        $text = $script:SampleHandler.Replace('SAMPLE_BLOCKED:', 'OTHER_CODE:')
        @(Get-FixtureFinding -HookText $text | Where-Object { $_ -like 'DENY-CODE-MISSING: HX*' }).Count | Should -Be 1
    }

    It 'GF4: does not report a conforming named exemption' {
        Get-FixtureFinding -HookText $script:SampleHandler | Should -BeNullOrEmpty
    }
}
