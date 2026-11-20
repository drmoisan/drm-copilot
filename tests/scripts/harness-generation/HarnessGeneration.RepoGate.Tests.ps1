Set-StrictMode -Version Latest

# Repository gate for scripts/harness-generation (issue #1028). It runs every surface in check mode against the
# working tree through the file-reading context seam, and checks the parity-matrix upkeep of the selected entries.
# It starts no process, reads no git history and writes no file.

Describe 'Harness generation repository gate' {
    BeforeAll {
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1') -Force
        $script:RepoRoot = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../..')).Path
    }

    AfterAll {
        Remove-Module -Name HarnessGeneration, HarnessMcpConfig, HarnessInstructions, HarnessSkillMirror, HarnessRuleGeneration, HarnessAgentGeneration -Force -ErrorAction SilentlyContinue
    }

    It 'reports no drift for any generated target in the working tree' {
        $context = New-HarnessGenerationContext -Root $script:RepoRoot
        $findings = @(Get-HarnessRepositoryDrift -Context $context)
        $paths = @($findings | ForEach-Object { "$($_.Kind) $($_.Path)" })
        $because = 'a generated target was edited by hand or its source changed without a generation run; drifted: ' + ($paths -join '; ')
        $findings.Count | Should -Be 0 -Because $because
    }

    It 'records a source path and a generator for every selected entry whose source exists' {
        $context = New-HarnessGenerationContext -Root $script:RepoRoot
        $matrix = Import-HarnessGenerationMatrix -Context $context
        $selected = @(
            @(Get-HarnessMatrixSelection -Matrix $matrix -Ecosystem 'claude' -Kind 'skill' -Disposition 'generated' -OwnerChild 3)
            @(Get-HarnessMatrixSelection -Matrix $matrix -Kind 'path-scoped-rule' -Disposition 'generated' -OwnerChild 3)
            @(Get-HarnessMatrixSelection -Matrix $matrix -Kind 'mcp-server' -Disposition 'generated' -OwnerChild 3)
            @(Get-HarnessMatrixSelection -Matrix $matrix -Kind 'agent' -Disposition 'generated' -OwnerChild 3)
        )
        $problems = [System.Collections.Generic.List[string]]::new()
        foreach ($entry in $selected) {
            $names = @($entry.PSObject.Properties | ForEach-Object { $_.Name })
            $from = if ($names -contains 'generated_from') { [string]$entry.generated_from } else { '' }
            if ($from.StartsWith('pending-source:')) { $problems.Add("$($entry.id) still holds $from") ; continue }
            if ($null -eq (& $context.ReadFile $from)) { continue }
            if ($names -notcontains 'generator' -or [string]::IsNullOrEmpty([string]$entry.generator)) { $problems.Add("$($entry.id) has no generator") }
        }
        $selected.Count | Should -BeGreaterThan 0
        $problems.Count | Should -Be 0 -Because ($problems -join '; ')
    }

    It 'names the drifted path when a target differs from its source' {
        $real = New-HarnessGenerationContext -Root $script:RepoRoot
        $reader = $real.ReadFile
        $drifted = New-HarnessGenerationContext -Root $script:RepoRoot `
            -ReadFile { param([string] $Path) if ($Path -ceq '.mcp.json') { "{}`n" } else { & $reader $Path } }.GetNewClosure() `
            -ListFiles $real.ListFiles -TestReparse $real.TestReparse
        $findings = @(Get-HarnessRepositoryDrift -Context $drifted)
        @($findings | ForEach-Object { $_.Path }) | Should -Contain '.mcp.json'
        (Format-HarnessDriftReport -Findings $findings) -join "`n" | Should -Match '\.mcp\.json'
    }
}
