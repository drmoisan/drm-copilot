#Requires -Version 7.0
# Unit tests for scripts/harness/HarnessSkillContract.psm1 (issue #1025, spec `### Contract Format`).
# All content is in memory; no file is created.

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../../../scripts/harness/HarnessSkillContract.psm1'
    Import-Module $modulePath -Force

    function Get-ContractText {
        param(
            [string] $Name = 'orchestrate',
            [string] $H1 = $null,
            [string[]] $Headings = @('Objective', 'Observable Behaviors', 'Acceptance Checks'),
            [string] $Objective = 'The skill turns a request into a verified change.',
            [string[]] $Behaviors = @('- **OB-1** Produces a plan file.', '- **OB-2** Records evidence.'),
            [string[]] $Checks = @('- **AC-1** (OB-1) A plan file exists.', '- **AC-2** (OB-1, OB-2) Evidence names the plan.'),
            [string[]] $Extra = @()
        )
        $title = if ($null -ne $H1 -and $H1 -ne '') { $H1 } else { "# Gold Standard: $Name" }
        $bodies = @{ 'Objective' = @($Objective); 'Observable Behaviors' = $Behaviors; 'Acceptance Checks' = $Checks }
        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add($title)
        foreach ($heading in $Headings) {
            $lines.Add(''); $lines.Add("## $heading"); $lines.Add('')
            if ($bodies.ContainsKey($heading)) { foreach ($line in $bodies[$heading]) { $lines.Add($line) } } else { $lines.Add('Text.') }
        }
        foreach ($line in $Extra) { $lines.Add($line) }
        return ($lines -join "`n") + "`n"
    }

    function Get-Rule {
        param([string] $Content, [string] $Name = 'orchestrate')
        return @(Get-HarnessSkillContractViolation -Name $Name -Content $Content | ForEach-Object Rule)
    }
}

AfterAll {
    Remove-Module HarnessSkillContract -Force -ErrorAction SilentlyContinue
}

Describe 'Get-HarnessSkillContractViolation' {
    It 'reports no violation for a conforming contract' {
        $rules = Get-Rule -Content (Get-ContractText)
        $rules.Count | Should -Be 0 -Because "a conforming contract yields no violation (got: $($rules -join ', '))"
    }

    It 'reports a wrong H1' {
        Get-Rule -Content (Get-ContractText -H1 '# Standard: orchestrate') | Should -Contain 'h1'
    }

    It 'reports a second H1' {
        Get-Rule -Content (Get-ContractText -Extra @('', '# Another title')) | Should -Contain 'h1'
    }

    It 'reports a missing H2' {
        Get-Rule -Content (Get-ContractText -Headings @('Objective', 'Observable Behaviors')) | Should -Contain 'h2-missing'
    }

    It 'reports an extra H2' {
        Get-Rule -Content (Get-ContractText -Headings @('Objective', 'Observable Behaviors', 'Acceptance Checks', 'Notes')) | Should -Contain 'h2-extra'
    }

    It 'reports reordered H2 headings' {
        Get-Rule -Content (Get-ContractText -Headings @('Observable Behaviors', 'Objective', 'Acceptance Checks')) | Should -Contain 'h2-order'
    }

    It 'reports an H3 heading' {
        Get-Rule -Content (Get-ContractText -Extra @('', '### Detail')) | Should -Contain 'heading-level'
    }

    It 'reports an empty section' {
        Get-Rule -Content (Get-ContractText -Objective '   ') | Should -Contain 'empty-section'
    }

    It 'reports a list section with prose but no list item' {
        Get-Rule -Content (Get-ContractText -Behaviors @('Behaviors are described in prose only.')) | Should -Contain 'list-item'
    }

    It 'reports numbering case <Case>' -ForEach @(
        @{ Case = 'OB gap'; Behaviors = @('- **OB-1** A.', '- **OB-3** B.'); Checks = @('- **AC-1** (OB-1, OB-3) Both.') }
        @{ Case = 'OB repeat'; Behaviors = @('- **OB-1** A.', '- **OB-1** B.'); Checks = @('- **AC-1** (OB-1) A.') }
        @{ Case = 'OB starts at 2'; Behaviors = @('- **OB-2** A.', '- **OB-3** B.'); Checks = @('- **AC-1** (OB-2, OB-3) Both.') }
        @{ Case = 'AC gap'; Behaviors = @('- **OB-1** A.'); Checks = @('- **AC-1** (OB-1) A.', '- **AC-3** (OB-1) B.') }
        @{ Case = 'AC repeat'; Behaviors = @('- **OB-1** A.'); Checks = @('- **AC-1** (OB-1) A.', '- **AC-1** (OB-1) B.') }
        @{ Case = 'AC starts at 2'; Behaviors = @('- **OB-1** A.'); Checks = @('- **AC-2** (OB-1) A.', '- **AC-3** (OB-1) B.') }
    ) {
        $rules = Get-Rule -Content (Get-ContractText -Behaviors $Behaviors -Checks $Checks)
        $rules | Should -Contain 'numbering'
        @($rules | Where-Object { $_ -ne 'numbering' }).Count | Should -Be 0 -Because "only the numbering rule is broken in case $Case (got: $($rules -join ', '))"
    }

    It 'reports a check citing a non-existent behavior' {
        Get-Rule -Content (Get-ContractText -Checks @('- **AC-1** (OB-1, OB-2) A.', '- **AC-2** (OB-9) B.')) | Should -Contain 'unknown-citation'
    }

    It 'reports a behavior cited by no check' {
        Get-Rule -Content (Get-ContractText -Checks @('- **AC-1** (OB-1) A.')) | Should -Contain 'uncited-behavior'
    }

    It 'reports checkbox syntax' {
        Get-Rule -Content (Get-ContractText -Extra @('', '- [ ] a checkbox')) | Should -Contain 'checkbox'
    }

    It 'reports a malformed behavior item prefix' {
        Get-Rule -Content (Get-ContractText -Behaviors @('- OB-1 Produces a plan.', '- **OB-2** Records evidence.')) | Should -Contain 'behavior-prefix'
    }

    It 'reports a malformed check item prefix without a refs list' {
        Get-Rule -Content (Get-ContractText -Checks @('- **AC-1** A plan file exists.', '- **AC-2** (OB-1, OB-2) Both.')) | Should -Contain 'check-prefix'
    }

    It 'reports a malformed refs list without the space' {
        Get-Rule -Content (Get-ContractText -Checks @('- **AC-1** (OB-1,OB-2) Both.')) | Should -Contain 'check-prefix'
    }

    It 'reports the TaskMaster.sln product name' {
        Get-Rule -Content (Get-ContractText -Objective 'Build TaskMaster.sln as the result.') | Should -Contain 'product-name'
    }

    It 'reports the No-COM product name' {
        Get-Rule -Content (Get-ContractText -Objective 'Works in No-COM mode.') | Should -Contain 'product-name'
    }
}

Describe 'Get-HarnessSkillContractRequiredSet' {
    It 'derives the required set from an in-memory matrix' {
        $matrix = [pscustomobject]@{ features = @(
                [pscustomobject]@{ kind = 'skill'; ecosystem = 'codex'; disposition = 'shared'; name = 'zeta' }
                [pscustomobject]@{ kind = 'skill'; ecosystem = 'codex'; disposition = 'native'; name = 'native-one' }
                [pscustomobject]@{ kind = 'skill'; ecosystem = 'claude'; disposition = 'shared'; name = 'claude-one' }
                [pscustomobject]@{ kind = 'agent'; ecosystem = 'codex'; disposition = 'shared'; name = 'agent-one' }
                [pscustomobject]@{ kind = 'skill'; ecosystem = 'codex'; disposition = 'shared'; name = 'alpha' }
            )
        }
        Get-HarnessSkillContractRequiredSet -Matrix $matrix | Should -Be @('alpha', 'zeta')
    }
}

Describe 'Get-HarnessSkillContractSetViolation' {
    It 'reports a missing contract for a required skill' {
        $matrix = [pscustomobject]@{ features = @([pscustomobject]@{ kind = 'skill'; ecosystem = 'codex'; disposition = 'shared'; name = 'orchestrate' }) }
        $violations = @(Get-HarnessSkillContractSetViolation -Matrix $matrix -RepositoryRoot 'repo' -TestPath { param($Root, $Path) $null = $Root, $Path; $false } -ReadFile { param($Root, $Path) throw "not read: $Root $Path" })
        $violations.Rule | Should -Be @('missing')
        $violations[0].Message | Should -Match 'orchestrate/references/standard\.md'
    }
}
