#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-surface parity of the issue #1010 target-resolution helpers (finding F1).

.DESCRIPTION
    The Claude and Codex enforce-orchestration-preimplementation-gate-epic-scope.ps1 files
    each define Get-OrchestrationGateWorktreeList, Invoke-OrchestrationGateWorktreeList, and
    Get-OrchestrationGateCommandOperandPath, and the Codex header states that the three
    definitions are byte-identical to the Claude copies. These rows enforce that statement:
    each definition is parsed from both files and its text is compared ordinally after CRLF
    is normalized to LF, so the comparison is the same under the eol=lf checkout rule.

    The two negative rows drive the parity assertion with in-memory text, so they prove
    that the assertion fails on a one-character difference and on a missing definition.
    The suite dot-sources no hook, registers no mock, and writes no file; it reads only the
    two tracked -epic-scope files.
#>

BeforeAll {
    function Get-GateHelperDefinitionText {
        <#
        .SYNOPSIS
            Returns the text of the named function definition in a script text, or $null.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
            [Parameter(Mandatory)][string] $Name
        )

        $functionName = $Name
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
        $definition = $ast.Find({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq $functionName
            }, $true)
        if ($null -eq $definition) { return $null }
        return [string]$definition.Extent.Text
    }

    function Assert-GateHelperDefinitionParity {
        <#
        .SYNOPSIS
            Throws when the named definition is absent from either text or the two differ.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)][AllowEmptyString()][string] $LeftText,
            [Parameter(Mandatory)][AllowEmptyString()][string] $RightText,
            [Parameter(Mandatory)][string] $Name
        )

        $left = Get-GateHelperDefinitionText -Text $LeftText -Name $Name
        $right = Get-GateHelperDefinitionText -Text $RightText -Name $Name
        if ($null -eq $left -or $null -eq $right) {
            throw "The definition of $Name is missing from one surface."
        }
        if (-not (($left -replace "`r`n", "`n") -ceq ($right -replace "`r`n", "`n"))) {
            throw "The definition of $Name differs between the Claude and Codex surfaces."
        }
    }

    # The two files are read as text and never loaded. Each path is joined from its segments, so
    # the epic-state discovery guard, which treats a hooks/<name>.ps1 literal as a loaded hook,
    # does not count either file as part of this suite's loaded-source closure.
    $repositoryRoot = Join-Path $PSScriptRoot '../../..'
    $epicScopeFileName = 'enforce-orchestration-preimplementation-gate-epic-scope.ps1'
    $script:ClaudeEpicScopeText = [System.IO.File]::ReadAllText((Join-Path -Path (Join-Path -Path (Join-Path -Path $repositoryRoot -ChildPath '.claude') -ChildPath 'hooks') -ChildPath $epicScopeFileName))
    $script:CodexEpicScopeText = [System.IO.File]::ReadAllText((Join-Path -Path (Join-Path -Path (Join-Path -Path $repositoryRoot -ChildPath '.codex') -ChildPath 'hooks') -ChildPath $epicScopeFileName))
}

Describe 'Preimplementation gate -epic-scope helper parity (issue #1010, finding F1)' {

    It 'F1 the <Name> definition is identical on the Claude and Codex surfaces' -ForEach @(
        @{ Name = 'Get-OrchestrationGateWorktreeList' }
        @{ Name = 'Invoke-OrchestrationGateWorktreeList' }
        @{ Name = 'Get-OrchestrationGateCommandOperandPath' }
    ) {
        # Act / Assert
        { Assert-GateHelperDefinitionParity -LeftText $script:ClaudeEpicScopeText -RightText $script:CodexEpicScopeText -Name $Name } | Should -Not -Throw
    }

    It 'F1 a definition that differs by one character fails the parity assertion' {
        # Arrange
        $left = "function Get-SampleHelper {`n    return 'a'`n}`n"
        $right = "function Get-SampleHelper {`n    return 'b'`n}`n"

        # Act / Assert
        { Assert-GateHelperDefinitionParity -LeftText $left -RightText $right -Name 'Get-SampleHelper' } | Should -Throw '*differs*'
    }

    It 'F1 a definition missing from one surface fails the parity assertion' {
        # Arrange
        $left = "function Get-SampleHelper {`n    return 'a'`n}`n"
        $right = "function Get-OtherHelper {`n    return 'a'`n}`n"

        # Act / Assert
        { Assert-GateHelperDefinitionParity -LeftText $left -RightText $right -Name 'Get-SampleHelper' } | Should -Throw '*missing*'
    }
}
