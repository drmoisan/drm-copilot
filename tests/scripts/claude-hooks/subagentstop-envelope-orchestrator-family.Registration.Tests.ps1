#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Frontmatter registration and AST seam rows for the E2 SubagentStop validators (issue #903, epic #904).

.DESCRIPTION
    REG-1 and REG-2 read the agent definitions under .claude/agents as text and check every
    SubagentStop registration that invokes an E2 validator against the parameter block of the target
    script. REG-3 and REG-4 parse the four validator files and check the pure-entry seam and the exit
    placement required by the E1 consumer policies 3 and 5. The suite loads no hook, edits no agent
    file, and writes no file.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:HookDirectory = Join-Path $script:RepoRoot '.claude/hooks'
    $script:AgentDirectory = Join-Path $script:RepoRoot '.claude/agents'
    $script:SelectPattern = '^\s*command:\s*pwsh\b.*\.claude/hooks/(validate-orchestrator-output|validate-executor-output|validate-planner-output|validate-required-artifact-output)\.ps1'
    $script:LeafPattern = '\.claude/hooks/(?<leaf>[A-Za-z-]+\.ps1)'

    function Get-E2Registration {
        # Returns one record per selected registration line: agent file, line text, leaf, and the text after the script path.
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($file in @(Get-ChildItem -LiteralPath $script:AgentDirectory -Filter '*.md' -File | Sort-Object Name)) {
            foreach ($line in [System.IO.File]::ReadAllLines($file.FullName)) {
                if ($line -notmatch $script:SelectPattern) { continue }
                $leafMatch = [regex]::Match($line, $script:LeafPattern)
                $records.Add([pscustomobject]@{
                        Agent     = $file.Name
                        Line      = $line
                        Leaf      = $leafMatch.Groups['leaf'].Value
                        Arguments = $line.Substring($leafMatch.Index + $leafMatch.Length)
                    })
            }
        }
        return $records.ToArray()
    }

    function Get-RegistrationArgumentName {
        # Removes single-quoted spans and returns every -Name token of the argument text.
        param([string] $Arguments)
        $unquoted = [regex]::Replace($Arguments, "'[^']*'", '')
        return @([regex]::Matches($unquoted, '(?<=\s)-([A-Za-z][A-Za-z0-9]*)') | ForEach-Object { $_.Groups[1].Value })
    }

    function Get-HookAst {
        param([string] $Leaf)
        return [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:HookDirectory $Leaf), [ref]$null, [ref]$null)
    }

    function Test-IsScriptScope {
        # True when no FunctionDefinitionAst encloses the node.
        param($Node)
        $parent = $Node.Parent
        while ($null -ne $parent) {
            if ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) { return $false }
            $parent = $parent.Parent
        }
        return $true
    }
}

Describe 'E2 SubagentStop registrations and seams' {
    It 'REG-1 discovers exactly nine SubagentStop registrations of E2 hooks' {
        # Arrange / Act
        $registrations = @(Get-E2Registration)
        $leaves = @($registrations | ForEach-Object { $_.Leaf } | Sort-Object -Unique)

        # Assert
        $registrations.Count | Should -Be 9 -Because (($registrations | ForEach-Object { "$($_.Agent): $($_.Leaf)" }) -join '; ')
        ($leaves -join ',') | Should -BeExactly 'validate-executor-output.ps1,validate-orchestrator-output.ps1,validate-planner-output.ps1,validate-required-artifact-output.ps1'
    }

    It 'REG-2 every argument name passed by a registration exists in the target script param block' {
        # Arrange
        $failures = [System.Collections.Generic.List[string]]::new()

        # Act
        foreach ($registration in Get-E2Registration) {
            $declared = @((Get-HookAst -Leaf $registration.Leaf).ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
            foreach ($name in Get-RegistrationArgumentName -Arguments $registration.Arguments) {
                if ($declared -notcontains $name) { $failures.Add("$($registration.Agent): -$name is not a parameter of $($registration.Leaf)") }
            }
        }

        # Assert
        $failures | Should -BeNullOrEmpty -Because ($failures -join '; ')
    }

    It 'REG-3 <Function> declares the InputText seam and calls Read-SubagentStopEnvelope' -ForEach @(
        @{ Leaf = 'validate-orchestrator-output.ps1'; Function = 'Invoke-OrchestratorOutputValidation' }
        @{ Leaf = 'validate-executor-output.ps1'; Function = 'Invoke-ExecutorOutputValidation' }
        @{ Leaf = 'validate-planner-output.ps1'; Function = 'Invoke-PlannerOutputValidation' }
        @{ Leaf = 'validate-required-artifact-output.ps1'; Function = 'Invoke-RequiredArtifactOutputValidation' }
    ) {
        # Arrange
        $ast = Get-HookAst -Leaf $Leaf
        $definition = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $Function }, $true))[0]

        # Act
        $parameters = @($definition.Body.ParamBlock.Parameters)
        $names = @($parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
        $inputText = @($parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'InputText' })
        $attributes = if ($inputText.Count -eq 1) { @($inputText[0].Attributes | ForEach-Object { $_.TypeName.Name }) } else { @() }
        $reads = @($definition.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Read-SubagentStopEnvelope' }, $true))

        # Assert
        $inputText.Count | Should -Be 1 -Because "$Function must declare -InputText"
        $attributes | Should -Contain 'AllowNull'
        $attributes | Should -Contain 'AllowEmptyString'
        $names | Should -Not -Contain 'RawPayload'
        $names | Should -Not -Contain 'AssistantText'
        $reads.Count | Should -BeGreaterThan 0 -Because "$Function must read the envelope through the helper"
    }

    It 'REG-4 <Leaf> calls Exit-SubagentStopBlock twice at script scope after the inline S1 tail' -ForEach @(
        @{ Leaf = 'validate-orchestrator-output.ps1' }
        @{ Leaf = 'validate-executor-output.ps1' }
        @{ Leaf = 'validate-planner-output.ps1' }
        @{ Leaf = 'validate-required-artifact-output.ps1' }
    ) {
        # Arrange
        $ast = Get-HookAst -Leaf $Leaf

        # Act
        $exitCalls = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Exit-SubagentStopBlock' }, $true))
        $decisionAssignments = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -eq '$dependencyDecision' -and $node.Right.Extent.Text.Contains('Get-HookDependencyFailureDecision') }, $true) | Where-Object { Test-IsScriptScope -Node $_ })
        $writeLines = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $node.Extent.Text.StartsWith('[Console]::Error.WriteLine(', [System.StringComparison]::Ordinal) }, $true) | Where-Object { Test-IsScriptScope -Node $_ })
        $dependencyExits = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.ExitStatementAst] -and $null -ne $node.Pipeline -and $node.Pipeline.Extent.Text -eq '$dependencyDecision.ExitCode' }, $true) | Where-Object { Test-IsScriptScope -Node $_ })

        # Assert
        $exitCalls.Count | Should -Be 2 -Because "$Leaf must call Exit-SubagentStopBlock exactly twice: the unhandled-error catch and the validation-failure line (issue #928)"
        @($exitCalls | Where-Object { -not (Test-IsScriptScope -Node $_) }).Count | Should -Be 0 -Because 'both calls sit in the entry tail'
        $decisionAssignments.Count | Should -Be 1 -Because 'the inline S1 tail assigns $dependencyDecision once at script scope'
        $decisionAssignments[0].Extent.StartOffset | Should -BeLessThan $exitCalls[0].Extent.StartOffset
        $writeLines.Count | Should -BeGreaterOrEqual 2 -Because 'the S1 tail keeps its inline stderr writes'
        $dependencyExits.Count | Should -Be 1 -Because 'the S1 tail keeps exit $dependencyDecision.ExitCode inline'
    }

    It 'REG-5 no registration passes the same parameter name twice' {
        # Arrange
        $failures = [System.Collections.Generic.List[string]]::new()

        # Act: pwsh -File cannot bind a repeated parameter, so a repeated name fails every run at binding.
        foreach ($registration in Get-E2Registration) {
            $names = @(Get-RegistrationArgumentName -Arguments $registration.Arguments)
            $caseInsensitive = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($name in $names) { $caseInsensitive[$name] = 1 + $(if ($caseInsensitive.ContainsKey($name)) { $caseInsensitive[$name] } else { 0 }) }
            $repeated = @($caseInsensitive.Keys | Where-Object { $caseInsensitive[$_] -gt 1 })
            if ($repeated.Count -gt 0) { $failures.Add("$($registration.Agent): repeated -$($repeated -join ', -')") }
        }

        # Assert
        $failures | Should -BeNullOrEmpty -Because ($failures -join '; ')
    }
}
