<#
.SYNOPSIS
    Pester tests for .claude/lib/regeneration/Invoke-RegenerationPath.ps1 (issue #1156).

.DESCRIPTION
    The result-table cases run one It per row of RegenerationResultTable.psd1, a
    transcription of spec ### Result table (normative, D17), and assert the exit
    code, the twenty result keys, every value, and the git and process call-count
    classes. Structure checks pin the table itself. Non-table cases cover the
    config path forwarding, JSON serialization, and the result builder. AST checks
    pin the script body, the parameter declarations, the guarded imports, and the
    seam defaults. Direct seam cases test each wrapper through in-memory
    scriptblocks with no mock of that wrapper. No file, git repository, process,
    or wait is used.
#>

BeforeDiscovery {
    $script:DiscoveryRows = @((Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RegenerationResultTable.psd1')).Rows)
}

BeforeAll {
    $script:LibRoot = Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration'
    $script:ScriptPath = Join-Path $script:LibRoot 'Invoke-RegenerationPath.ps1'
    Import-Module (Join-Path $script:LibRoot 'RegenerationConfig.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:LibRoot 'RegenerationDelta.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:LibRoot 'RegenerationClassifier.psm1') -ErrorAction Stop
    . $script:ScriptPath
    . (Join-Path $PSScriptRoot 'RegenerationResultScenario.ps1')
    $script:Rows = @((Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RegenerationResultTable.psd1')).Rows)
    $script:ResultKeys = @('mode', 'trigger', 'decision', 'reason', 'unmatched_paths', 'config_errors', 'feature_head_sha',
        'merge_head_sha', 'merge_base_sha', 'command_exit_code', 'confined', 'idempotent', 'unit_gate', 'delta_check',
        'changed_paths', 'outcome', 'at', 'event', 'review_outcome', 'evidence_text')

    function Get-OrdinalSortedList {
        param([object[]] $Value)
        $copy = [string[]] @($Value)
        [Array]::Sort($copy, [System.StringComparer]::Ordinal)
        return , $copy
    }

    function ConvertTo-CanonicalJson {
        param([AllowNull()] [object] $Value)
        return (ConvertTo-Json -InputObject $Value -Depth 10 -Compress)
    }

    $parseErrors = $null
    $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ScriptPath, [ref] $null, [ref] $parseErrors)
    $script:ParseErrors = $parseErrors
    $script:Guard = @($script:Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.IfStatementAst] })[0]
    $script:GuardBody = $script:Guard.Clauses[0].Item2.Statements

    function Get-OutsideFunctionCommand {
        param([string] $Name)
        return , @($script:Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq $Name
                }, $true) | Where-Object {
                $parent = $_.Parent
                $inFunction = $false
                while ($null -ne $parent) {
                    if ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) { $inFunction = $true }
                    $parent = $parent.Parent
                }
                -not $inFunction
            })
    }

    function Get-SeamDefault {
        param([string] $FunctionName, [string] $ParameterName)
        $function = $script:Ast.Find({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq $FunctionName
            }, $true)
        $parameter = @($function.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -ceq $ParameterName })[0]
        return $parameter.DefaultValue.ScriptBlock
    }

    function Get-AstCommand {
        param($Root, [string] $Name)
        return , @($Root.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq $Name
                }, $true))
    }

    function Test-ParameterBinding {
        param($Command, [string] $Parameter, [string] $Variable)
        $elements = $Command.CommandElements
        for ($i = 1; $i -lt $elements.Count - 1; $i++) {
            if ($elements[$i] -is [System.Management.Automation.Language.CommandParameterAst] -and $elements[$i].ParameterName -ceq $Parameter) {
                $next = $elements[$i + 1]
                return ($next -is [System.Management.Automation.Language.VariableExpressionAst] -and $next.VariablePath.UserPath -ceq $Variable)
            }
        }
        return $false
    }
}

AfterAll {
    Remove-Module -Name RegenerationDelta, RegenerationClassifier, RegenerationConfig, BlastRadiusGlob -ErrorAction SilentlyContinue
}

Describe 'Invoke-RegenerationPath result table (spec D17)' {
    It '<Id> <Scenario>' -ForEach $script:DiscoveryRows {
        $row = $_
        $count = Get-RegenerationScenarioAlternativeCount -Row $row
        for ($alternative = 0; $alternative -lt $count; $alternative++) {
            $label = "$($row.Id) alternative $alternative"
            $context = Register-RegenerationScenarioMock -Row $row -Alternative $alternative
            $arguments = Get-RegenerationScenarioArgument -Row $row -Alternative $alternative
            $output = Invoke-RegenerationPathCommand @arguments -UtcNow $context.UtcNow

            $output.ExitCode | Should -Be $row.Exit -Because $label
            (Get-OrdinalSortedList -Value @($output.Result.Keys)) -join ',' | Should -BeExactly ((Get-OrdinalSortedList -Value $script:ResultKeys) -join ',') -Because $label
            foreach ($key in $script:ResultKeys) {
                $expected = Resolve-RegenerationExpectedCell -Row $row -Token $row.Expected[$key]
                ConvertTo-CanonicalJson -Value $output.Result[$key] | Should -BeExactly (ConvertTo-CanonicalJson -Value $expected) -Because "$label $key"
            }
            if ($row.GitCalls -ceq 'none') { $context.State.GitCalls | Should -Be 0 -Because "$label git calls" }
            else { $context.State.GitCalls | Should -BeGreaterOrEqual 1 -Because "$label git calls" }
            if ($row.ProcessCalls -ceq 'none') { $context.State.ProcessCalls | Should -Be 0 -Because "$label process calls" }
            else { $context.State.ProcessCalls | Should -BeGreaterOrEqual 1 -Because "$label process calls" }
            $expectedReads = if ($row.ConfigState -ceq 'not read') { 0 } else { 1 }
            $context.State.ConfigReads.Count | Should -Be $expectedReads -Because "$label config reads"
            $context.Clock.Count | Should -Be $expectedReads -Because "$label clock reads"
        }
    }
}

Describe 'Invoke-RegenerationPath result table structure' {
    It 'lists the row IDs R01 through R74 in order with no duplicate' {
        $expected = @(1..74 | ForEach-Object { 'R{0:D2}' -f $_ })
        (@($script:Rows | ForEach-Object { $_.Id }) -join ',') | Should -BeExactly ($expected -join ',')
    }

    It 'carries the twenty result keys plus Exit, GitCalls, and ProcessCalls on every row' {
        $sortedKeys = (Get-OrdinalSortedList -Value $script:ResultKeys) -join ','
        foreach ($row in $script:Rows) {
            (Get-OrdinalSortedList -Value @($row.Expected.Keys)) -join ',' | Should -BeExactly $sortedKeys -Because $row.Id
            $row.ContainsKey('Exit') | Should -BeTrue -Because $row.Id
            @('none', '>=1') | Should -Contain $row.GitCalls -Because $row.Id
            @('none', '>=1') | Should -Contain $row.ProcessCalls -Because $row.Id
        }
    }

    It 'uses the key set of New-RegenerationResult as the twenty-key list' {
        $builderKeys = (Get-OrdinalSortedList -Value @((New-RegenerationResult).Keys)) -join ','
        $builderKeys | Should -BeExactly ((Get-OrdinalSortedList -Value $script:ResultKeys) -join ',')
        @($script:ResultKeys).Count | Should -Be 20
    }

    It 'resolves every scenario and every token of the table' {
        foreach ($row in $script:Rows) {
            { Get-RegenerationScenarioAlternativeCount -Row $row } | Should -Not -Throw -Because $row.Id
            foreach ($key in $script:ResultKeys) {
                { Resolve-RegenerationExpectedCell -Row $row -Token $row.Expected[$key] } | Should -Not -Throw -Because "$($row.Id) $key"
            }
        }
    }
}

Describe 'Invoke-RegenerationPathCommand config path forwarding' {
    It 'passes the default config path when -ConfigPath is omitted and the supplied value otherwise, in <Id>' -ForEach @(
        @{ Id = 'R19' }, @{ Id = 'R24' }, @{ Id = 'R43' }
    ) {
        $row = @($script:Rows | Where-Object { $_.Id -ceq $Id })[0]
        $arguments = Get-RegenerationScenarioArgument -Row $row
        $context = Register-RegenerationScenarioMock -Row $row
        $null = Invoke-RegenerationPathCommand @arguments -UtcNow $context.UtcNow
        @($context.State.ConfigReads) | Should -BeExactly @('config/orchestration-regeneration.json')

        $context = Register-RegenerationScenarioMock -Row $row
        $null = Invoke-RegenerationPathCommand @arguments -ConfigPath 'config/alt.json' -UtcNow $context.UtcNow
        @($context.State.ConfigReads) | Should -BeExactly @('config/alt.json')
    }
}

Describe 'ConvertTo-RegenerationResultJson' {
    It 'returns one line that parses back to twenty keys with merge_head_sha null' {
        $json = ConvertTo-RegenerationResultJson -Result (New-RegenerationResult -Mode 'Validate' -Outcome 'valid')
        $json.Contains("`n") | Should -BeFalse
        $parsed = $json | ConvertFrom-Json
        @($parsed.PSObject.Properties.Name).Count | Should -Be 20
        @($parsed.PSObject.Properties.Name) | Should -Contain 'merge_head_sha'
        $parsed.merge_head_sha | Should -BeNullOrEmpty
        $null -eq $parsed.merge_head_sha | Should -BeTrue
    }

    It 'round-trips an R73-shaped result with nested and list values' {
        $regenerationEvent = New-RegenerationEvent -At '2026-11-09T22:00:00Z' -Trigger 'main_sync' -FeatureHeadSha 'f' -MergeHeadSha 'm' `
            -MergeBaseSha 'b' -Decision 'regenerate' -Reason 'all_match' -UnmatchedPaths @() -CommandExitCode 0 -Confined $true `
            -Idempotent $true -UnitGate 'not_run' -DeltaCheck 'pass' -Outcome 'regenerated' -HeadSha $null -EvidencePath $null
        $result = New-RegenerationResult -Mode 'Merge' -Decision 'regenerate' -Reason 'all_match' -ChangedPaths @('gen/a.json') `
            -Event $regenerationEvent -ReviewOutcome (New-RegenerationDeltaReviewOutcome -HeadSha $null -EvidencePath $null)

        $parsed = ConvertTo-RegenerationResultJson -Result $result | ConvertFrom-Json

        $parsed.event.classifier.decision | Should -BeExactly 'regenerate'
        $parsed.event.classifier.unmatched_paths -is [System.Array] | Should -BeTrue
        $parsed.event.classifier.unmatched_paths.Count | Should -Be 0
        $parsed.review_outcome.findings -is [System.Array] | Should -BeTrue
        $parsed.review_outcome.findings.Count | Should -Be 0
        $parsed.review_outcome.review_kind | Should -BeExactly 'regeneration_delta'
        $parsed.changed_paths -is [System.Array] | Should -BeTrue
        $parsed.changed_paths.Count | Should -Be 1
        $parsed.changed_paths[0] | Should -BeExactly 'gen/a.json'
        @($parsed.event.PSObject.Properties.Name) | Should -Contain 'head_sha'
        $null -eq $parsed.event.head_sha | Should -BeTrue
    }

    It 'keeps one-element config_errors and unmatched_paths lists as arrays' {
        $result = New-RegenerationResult -Mode 'Validate' -ConfigErrors @('regeneration.paths: empty') -UnmatchedPaths @('src/x.ps1')
        $parsed = ConvertTo-RegenerationResultJson -Result $result | ConvertFrom-Json
        $parsed.config_errors -is [System.Array] | Should -BeTrue
        $parsed.config_errors.Count | Should -Be 1
        $parsed.config_errors[0] | Should -BeExactly 'regeneration.paths: empty'
        $parsed.unmatched_paths -is [System.Array] | Should -BeTrue
        $parsed.unmatched_paths.Count | Should -Be 1
        $parsed.unmatched_paths[0] | Should -BeExactly 'src/x.ps1'
    }
}

Describe 'New-RegenerationResult field mapping' {
    It 'maps each of the twenty parameters to the key of the same name' {
        $eventMarker = @{ marker = 'event' }
        $reviewMarker = @{ marker = 'review' }
        $result = New-RegenerationResult -Mode 'mode-x' -Trigger 'trigger-x' -Decision 'decision-x' -Reason 'reason-x' `
            -UnmatchedPaths @('unmatched-x') -ConfigErrors @('error-x') -FeatureHeadSha 'feature-x' -MergeHeadSha 'merge-x' `
            -MergeBaseSha 'base-x' -CommandExitCode 7 -Confined $true -Idempotent $false -UnitGate 'unit-x' -DeltaCheck 'delta-x' `
            -ChangedPaths @('changed-x') -Outcome 'outcome-x' -At 'at-x' -Event $eventMarker -ReviewOutcome $reviewMarker -EvidenceText 'evidence-x'

        $result.mode | Should -BeExactly 'mode-x'
        $result.trigger | Should -BeExactly 'trigger-x'
        $result.decision | Should -BeExactly 'decision-x'
        $result.reason | Should -BeExactly 'reason-x'
        ConvertTo-CanonicalJson -Value $result.unmatched_paths | Should -BeExactly '["unmatched-x"]'
        ConvertTo-CanonicalJson -Value $result.config_errors | Should -BeExactly '["error-x"]'
        $result.feature_head_sha | Should -BeExactly 'feature-x'
        $result.merge_head_sha | Should -BeExactly 'merge-x'
        $result.merge_base_sha | Should -BeExactly 'base-x'
        $result.command_exit_code | Should -Be 7
        $result.confined | Should -BeTrue
        $result.idempotent | Should -BeFalse
        $result.unit_gate | Should -BeExactly 'unit-x'
        $result.delta_check | Should -BeExactly 'delta-x'
        ConvertTo-CanonicalJson -Value $result.changed_paths | Should -BeExactly '["changed-x"]'
        $result.outcome | Should -BeExactly 'outcome-x'
        $result.at | Should -BeExactly 'at-x'
        [object]::ReferenceEquals($result.event, $eventMarker) | Should -BeTrue
        [object]::ReferenceEquals($result.review_outcome, $reviewMarker) | Should -BeTrue
        $result.evidence_text | Should -BeExactly 'evidence-x'
    }
}

Describe 'Invoke-RegenerationPath script layer (AST)' {
    It 'parses without errors' {
        @($script:ParseErrors).Count | Should -Be 0
    }

    It '(a) declares exactly Mode, MergeRef, Trigger, and ConfigPath with no Mandatory or Validate attribute' {
        $parameters = @($script:Ast.ParamBlock.Parameters)
        (@($parameters | ForEach-Object { $_.Name.VariablePath.UserPath }) -join ',') | Should -BeExactly 'Mode,MergeRef,Trigger,ConfigPath'
        foreach ($parameter in $parameters) {
            foreach ($attribute in @($parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.Language.AttributeAst] })) {
                $attribute.TypeName.Name.StartsWith('Validate') | Should -BeFalse
                @($attribute.NamedArguments | Where-Object { $_.ArgumentName -eq 'Mandatory' }).Count | Should -Be 0
            }
        }
    }

    It '(b) holds only the param block, function definitions, and the dot-source guard at top level' {
        $other = @($script:Ast.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })
        $other.Count | Should -Be 1
        $other[0] | Should -BeOfType ([System.Management.Automation.Language.IfStatementAst])
        $other[0].Clauses.Count | Should -Be 1
        $other[0].Clauses[0].Item1.Extent.Text | Should -BeExactly '$MyInvocation.InvocationName -ne ''.'''
        $null -eq $script:Ast.BeginBlock -and $null -eq $script:Ast.ProcessBlock | Should -BeTrue
    }

    It '(c) forwards @PSBoundParameters in exactly one Invoke-RegenerationPathCommand call assigned to one variable' {
        $calls = Get-OutsideFunctionCommand -Name 'Invoke-RegenerationPathCommand'
        $calls.Count | Should -Be 1
        $calls[0].CommandElements.Count | Should -Be 2
        $splat = $calls[0].CommandElements[1]
        $splat.Splatted | Should -BeTrue
        $splat.VariablePath.UserPath | Should -BeExactly 'PSBoundParameters'
        $calls[0].Parent.Parent | Should -BeOfType ([System.Management.Automation.Language.AssignmentStatementAst])
        $calls[0].Parent.Parent.Left | Should -BeOfType ([System.Management.Automation.Language.VariableExpressionAst])
    }

    It '(d) serializes the Result member in one standalone ConvertTo-RegenerationResultJson statement' {
        $resultVariable = (Get-OutsideFunctionCommand -Name 'Invoke-RegenerationPathCommand')[0].Parent.Parent.Left.VariablePath.UserPath
        $calls = Get-OutsideFunctionCommand -Name 'ConvertTo-RegenerationResultJson'
        $calls.Count | Should -Be 1
        $pipeline = $calls[0].Parent
        $pipeline.PipelineElements.Count | Should -Be 1
        $pipeline.Parent | Should -BeOfType ([System.Management.Automation.Language.StatementBlockAst])
        $calls[0].Redirections.Count | Should -Be 0
        $calls[0].CommandElements.Count | Should -Be 3
        $calls[0].CommandElements[1].ParameterName | Should -BeExactly 'Result'
        $argument = $calls[0].CommandElements[2]
        $argument | Should -BeOfType ([System.Management.Automation.Language.MemberExpressionAst])
        $argument.Expression.VariablePath.UserPath | Should -BeExactly $resultVariable
        $argument.Member.Value | Should -BeExactly 'Result'
    }

    It '(e) exits once with the ExitCode member of the result variable' {
        $resultVariable = (Get-OutsideFunctionCommand -Name 'Invoke-RegenerationPathCommand')[0].Parent.Parent.Left.VariablePath.UserPath
        $exits = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.ExitStatementAst] }, $true))
        $exits.Count | Should -Be 1
        $expression = $exits[0].Pipeline.PipelineElements[0].Expression
        $expression | Should -BeOfType ([System.Management.Automation.Language.MemberExpressionAst])
        $expression.Expression.VariablePath.UserPath | Should -BeExactly $resultVariable
        $expression.Member.Value | Should -BeExactly 'ExitCode'
    }

    It '(f) imports the three modules from $PSScriptRoot with -ErrorAction Stop inside the guard before the call' {
        $imports = Get-AstCommand -Root $script:Ast -Name 'Import-Module'
        $imports.Count | Should -Be 3
        $body = @($script:GuardBody)
        $callIndex = [Array]::FindIndex([object[]] $body, [Predicate[object]] { param($s) $s -is [System.Management.Automation.Language.AssignmentStatementAst] -and $s.Extent.Text -match 'Invoke-RegenerationPathCommand' })
        $names = foreach ($import in $imports) {
            $statementIndex = [Array]::IndexOf([object[]] $body, $import.Parent)
            $statementIndex | Should -BeGreaterOrEqual 0
            $statementIndex | Should -BeLessThan $callIndex
            $errorActionIndex = [Array]::FindIndex([object[]] $import.CommandElements, [Predicate[object]] { param($e) $e -is [System.Management.Automation.Language.CommandParameterAst] -and $e.ParameterName -ceq 'ErrorAction' })
            $import.CommandElements[$errorActionIndex + 1].Value | Should -BeExactly 'Stop'
            $join = @(Get-AstCommand -Root $import.CommandElements[1] -Name 'Join-Path')
            $join.Count | Should -Be 1
            Test-ParameterBinding -Command $join[0] -Parameter 'Path' -Variable 'PSScriptRoot' | Should -BeTrue
            $childIndex = [Array]::FindIndex([object[]] $join[0].CommandElements, [Predicate[object]] { param($e) $e -is [System.Management.Automation.Language.CommandParameterAst] -and $e.ParameterName -ceq 'ChildPath' })
            $join[0].CommandElements[$childIndex + 1].Value
        }
        (@($names) -join ',') | Should -BeExactly 'RegenerationConfig.psm1,RegenerationClassifier.psm1,RegenerationDelta.psm1'
    }

    It '(g) sets strict mode and the Stop error preference as the first two guarded statements only' {
        $body = @($script:GuardBody)
        $body[0].Extent.Text | Should -BeExactly 'Set-StrictMode -Version Latest'
        $body[1] | Should -BeOfType ([System.Management.Automation.Language.AssignmentStatementAst])
        $body[1].Left.VariablePath.UserPath | Should -BeExactly 'ErrorActionPreference'
        $body[1].Right.Expression.Value | Should -BeExactly 'Stop'
        (Get-AstCommand -Root $script:Ast -Name 'Set-StrictMode').Count | Should -Be 1
        $preferenceAssignments = @($script:Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -eq '$ErrorActionPreference'
                }, $true))
        $preferenceAssignments.Count | Should -Be 1
    }
}

Describe 'Invoke-RegenerationPath seam defaults (AST)' {
    It '(h) -UtcNow defaults to the static UtcNow member of datetime' {
        $block = Get-SeamDefault -FunctionName 'Invoke-RegenerationPathCommand' -ParameterName 'UtcNow'
        $statements = @($block.EndBlock.Statements)
        $statements.Count | Should -Be 1
        $expression = $statements[0].PipelineElements[0].Expression
        $expression | Should -BeOfType ([System.Management.Automation.Language.MemberExpressionAst])
        $expression.Static | Should -BeTrue
        $expression.Expression.TypeName.Name | Should -BeExactly 'datetime'
        $expression.Member.Value | Should -BeExactly 'UtcNow'
    }

    It '(h) -TestPath and -ReadText default to Test-Path and Get-Content -Raw with -LiteralPath bound to the parameter' {
        $test = Get-SeamDefault -FunctionName 'Read-RegenerationConfigText' -ParameterName 'TestPath'
        $testCommands = Get-AstCommand -Root $test -Name 'Test-Path'
        $testCommands.Count | Should -Be 1
        Test-ParameterBinding -Command $testCommands[0] -Parameter 'LiteralPath' -Variable 'Path' | Should -BeTrue
        $read = Get-SeamDefault -FunctionName 'Read-RegenerationConfigText' -ParameterName 'ReadText'
        $readCommands = Get-AstCommand -Root $read -Name 'Get-Content'
        $readCommands.Count | Should -Be 1
        Test-ParameterBinding -Command $readCommands[0] -Parameter 'LiteralPath' -Variable 'Path' | Should -BeTrue
        @($readCommands[0].CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -ceq 'Raw' }).Count | Should -Be 1
    }

    It '(h) the git -Invoker default runs one git command with only the splatted GitArgs and reads $LASTEXITCODE' {
        $block = Get-SeamDefault -FunctionName 'Invoke-RegenerationGitExe' -ParameterName 'Invoker'
        $git = Get-AstCommand -Root $block -Name 'git'
        $git.Count | Should -Be 1
        $git[0].CommandElements.Count | Should -Be 2
        $git[0].CommandElements[1].Splatted | Should -BeTrue
        $git[0].CommandElements[1].VariablePath.UserPath | Should -BeExactly 'GitArgs'
        $block.Extent.Text | Should -Match '\$LASTEXITCODE'
    }

    It '(h) the process -Invoker default pipes one call-operator invocation to [Console]::Error.WriteLine and reads $LASTEXITCODE' {
        $block = Get-SeamDefault -FunctionName 'Invoke-RegenerationProcess' -ParameterName 'Invoker'
        $invocations = @($block.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and
                    $node.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Ampersand
                }, $true))
        $invocations.Count | Should -Be 1
        $invocations[0].CommandElements.Count | Should -Be 2
        $invocations[0].CommandElements[0].VariablePath.UserPath | Should -BeExactly 'FilePath'
        $invocations[0].CommandElements[1].Splatted | Should -BeTrue
        $invocations[0].CommandElements[1].VariablePath.UserPath | Should -BeExactly 'ArgumentList'
        $pipeline = $invocations[0].Parent
        [object]::ReferenceEquals($pipeline.PipelineElements[0], $invocations[0]) | Should -BeTrue
        $last = $pipeline.PipelineElements[$pipeline.PipelineElements.Count - 1]
        $writeLine = @($last.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $node.Member.Value -ceq 'WriteLine' -and
                    $node.Expression.Extent.Text -eq '[Console]::Error'
                }, $true))
        $writeLine.Count | Should -Be 1
        $block.Extent.Text | Should -Match '\$LASTEXITCODE'
    }

    It '(h) no seam default writes to the success or host stream' {
        $defaults = @(
            (Get-SeamDefault -FunctionName 'Invoke-RegenerationPathCommand' -ParameterName 'UtcNow'),
            (Get-SeamDefault -FunctionName 'Read-RegenerationConfigText' -ParameterName 'TestPath'),
            (Get-SeamDefault -FunctionName 'Read-RegenerationConfigText' -ParameterName 'ReadText'),
            (Get-SeamDefault -FunctionName 'Invoke-RegenerationGitExe' -ParameterName 'Invoker'),
            (Get-SeamDefault -FunctionName 'Invoke-RegenerationProcess' -ParameterName 'Invoker')
        )
        foreach ($block in $defaults) {
            foreach ($name in @('Write-Output', 'Write-Host', 'Out-Host')) {
                (Get-AstCommand -Root $block -Name $name).Count | Should -Be 0
            }
        }
    }
}

Describe 'Read-RegenerationConfigText seams' {
    It 'returns $null without calling -ReadText when -TestPath returns false' {
        $reads = @{ Count = 0 }
        $reader = { param($Path) $reads.Count++; 'text' }.GetNewClosure()
        Read-RegenerationConfigText -ConfigPath 'config/x.json' -TestPath { param($Path) $false } -ReadText $reader | Should -BeNullOrEmpty
        $reads.Count | Should -Be 0
    }

    It 'returns exactly the reader text when -TestPath returns true' {
        $text = "{`n}"
        Read-RegenerationConfigText -ConfigPath 'config/x.json' -TestPath { param($Path) $true } -ReadText { param($Path) "{`n}" } | Should -BeExactly $text
    }

    It 'passes <Value> unchanged to both seams once' -ForEach @(
        @{ Value = 'config/orchestration-regeneration.json' }, @{ Value = 'config/alt.json' }, @{ Value = 'config/my config.json' }
    ) {
        $seen = @{ Test = [System.Collections.Generic.List[string]]::new(); Read = [System.Collections.Generic.List[string]]::new() }
        $tester = { param($Path) $seen.Test.Add($Path); $true }.GetNewClosure()
        $reader = { param($Path) $seen.Read.Add($Path); 'text' }.GetNewClosure()
        $null = Read-RegenerationConfigText -ConfigPath $Value -TestPath $tester -ReadText $reader
        @($seen.Test) | Should -BeExactly @($Value)
        @($seen.Read) | Should -BeExactly @($Value)
    }
}

Describe 'Invoke-RegenerationGitExe seam' {
    It 'passes the argv to the invoker as one array in order' {
        $seen = @{ Value = $null }
        $invoker = { param($GitArgs) $seen.Value = $GitArgs; [pscustomobject]@{ ExitCode = 0; Lines = @() } }.GetNewClosure()
        $null = Invoke-RegenerationGitExe -GitArgs @('diff', '--name-only', '-z', '--', 'gen/a b.json') -Invoker $invoker
        $seen.Value -is [System.Array] | Should -BeTrue
        $seen.Value.Count | Should -Be 5
        ($seen.Value -join '|') | Should -BeExactly 'diff|--name-only|-z|--|gen/a b.json'
    }

    It 'returns exit code <Code> unchanged' -ForEach @(@{ Code = 0 }, @{ Code = 128 }) {
        $invoker = [scriptblock]::Create("param(`$GitArgs) [pscustomobject]@{ ExitCode = $Code; Lines = @() }")
        (Invoke-RegenerationGitExe -GitArgs @('status') -Invoker $invoker).ExitCode | Should -Be $Code
    }

    It 'joins lines with LF, returns an empty string for no lines, and keeps NUL characters' {
        (Invoke-RegenerationGitExe -GitArgs @('x') -Invoker { param($GitArgs) [pscustomobject]@{ ExitCode = 0; Lines = @('a', 'b') } }).Output | Should -BeExactly "a`nb"
        (Invoke-RegenerationGitExe -GitArgs @('x') -Invoker { param($GitArgs) [pscustomobject]@{ ExitCode = 0; Lines = @() } }).Output | Should -BeExactly ''
        $nulLine = "a$([char] 0)b$([char] 0)"
        $invoker = { param($GitArgs) [pscustomobject]@{ ExitCode = 0; Lines = @($nulLine) } }.GetNewClosure()
        (Invoke-RegenerationGitExe -GitArgs @('x') -Invoker $invoker).Output | Should -BeExactly $nulLine
    }

    It 'returns exactly one object' {
        @(Invoke-RegenerationGitExe -GitArgs @('x') -Invoker { param($GitArgs) [pscustomobject]@{ ExitCode = 0; Lines = @('a') } }).Count | Should -Be 1
    }

    It 'throws for an invoker returning two objects' {
        { Invoke-RegenerationGitExe -GitArgs @('x') -Invoker { param($GitArgs) [pscustomobject]@{ ExitCode = 0; Lines = @() }; 'extra' } } | Should -Throw
    }

    It 'propagates an invoker exception' {
        { Invoke-RegenerationGitExe -GitArgs @('x') -Invoker { param($GitArgs) throw 'git missing' } } | Should -Throw -ExpectedMessage 'git missing'
    }
}

Describe 'Invoke-RegenerationProcess seam' {
    It 'passes the first argv element as FilePath and the rest in order as ArgumentList' {
        $seen = @{ FilePath = $null; ArgumentList = $null }
        $invoker = { param($FilePath, $ArgumentList) $seen.FilePath = $FilePath; $seen.ArgumentList = $ArgumentList; 0 }.GetNewClosure()
        $null = Invoke-RegenerationProcess -Argv @('poetry', 'run', 'gen') -Invoker $invoker
        $seen.FilePath | Should -BeExactly 'poetry'
        ($seen.ArgumentList -join '|') | Should -BeExactly 'run|gen'
    }

    It 'returns exit code <Code> unchanged' -ForEach @(@{ Code = 0 }, @{ Code = 7 }) {
        $invoker = [scriptblock]::Create("param(`$FilePath, `$ArgumentList) $Code")
        Invoke-RegenerationProcess -Argv @('tool') -Invoker $invoker | Should -Be $Code
    }

    It 'throws for an empty argv without calling the invoker' {
        $calls = @{ Count = 0 }
        $invoker = { param($FilePath, $ArgumentList) $calls.Count++; 0 }.GetNewClosure()
        { Invoke-RegenerationProcess -Argv @() -Invoker $invoker } | Should -Throw
        $calls.Count | Should -Be 0
    }

    It 'throws for an invoker returning noise and an exit code' {
        { Invoke-RegenerationProcess -Argv @('tool') -Invoker { param($FilePath, $ArgumentList) 'noise'; 0 } } | Should -Throw
    }

    It 'propagates an invoker exception' {
        { Invoke-RegenerationProcess -Argv @('tool') -Invoker { param($FilePath, $ArgumentList) throw 'cannot start' } } | Should -Throw -ExpectedMessage 'cannot start'
    }
}
