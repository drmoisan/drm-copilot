#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Epic-state isolation guard for the gate-1, gate-3, and gate-4 hook suites (issue #709).

.DESCRIPTION
    Seven hook suites reach Resolve-EpicScopeCheckpoint in
    .claude/lib/worktree-resolution/EpicScopeResolution.psm1 through the hooks they load.
    Unmocked, that resolver reads the gitignored epic checkpoint at the checkout root, so a
    leftover local epic checkpoint could change their results on a developer machine.

    The structural guard parses each of the seven committed suites and requires, inside the
    suite's outermost BeforeAll, the hook dot-source, then an Import-Module of
    EpicScopeResolution.psm1 without -Force, then a Mock of Get-EpicScopeCheckpointText in
    module scope EpicScopeResolution whose body is exactly $null.

.NOTES
    Known limit (decision D9): the guard iterates an explicit list of seven suite paths, so
    a suite added later that reaches the resolver is not guarded automatically.

    This file loads no hook, creates no file, reads no gitignored state, and runs no git
    command. It reads only committed suite files located from $PSScriptRoot and builds
    every other input in memory; synthetic roots use the /synthetic-worktrees/ form.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

    function Get-EpicStateIsolationCommandDepth {
        # Pure: the number of CommandAst ancestors of an AST node.
        [OutputType([int])]
        param([Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $Node)
        $depth = 0
        $parent = $Node.Parent
        while ($null -ne $parent) {
            if ($parent -is [System.Management.Automation.Language.CommandAst]) { $depth++ }
            $parent = $parent.Parent
        }
        return $depth
    }

    function Get-EpicStateIsolationElementText {
        # Pure: the literal value of a command element, or its source text.
        [OutputType([string])]
        param([AllowNull()] [System.Management.Automation.Language.Ast] $Element)
        if ($null -eq $Element) { return $null }
        if ($Element -is [System.Management.Automation.Language.StringConstantExpressionAst]) { return $Element.Value }
        return $Element.Extent.Text
    }

    function Get-EpicStateIsolationMockBinding {
        # Pure: the CommandName, ModuleName, and MockWith elements of a Mock command,
        # bound by name or by position (CommandName is position 0, MockWith position 1).
        [OutputType([hashtable])]
        param([Parameter(Mandatory)] [System.Management.Automation.Language.CommandAst] $Command)
        $valueParameters = @('CommandName', 'ModuleName', 'MockWith', 'ParameterFilter', 'RemoveParameterType', 'RemoveParameterValidation')
        $named = @{}
        $positional = [System.Collections.Generic.List[System.Management.Automation.Language.Ast]]::new()
        $elements = $Command.CommandElements
        $index = 1
        while ($index -lt $elements.Count) {
            $element = $elements[$index]
            if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
                if ($null -ne $element.Argument) {
                    $named[$element.ParameterName] = $element.Argument
                } elseif ($valueParameters -contains $element.ParameterName -and ($index + 1) -lt $elements.Count) {
                    $index++
                    $named[$element.ParameterName] = $elements[$index]
                } else {
                    $named[$element.ParameterName] = $null
                }
            } else {
                $positional.Add($element)
            }
            $index++
        }
        $nextPosition = 0
        $target = $named['CommandName']
        if (-not $named.ContainsKey('CommandName') -and $positional.Count -gt $nextPosition) {
            $target = $positional[$nextPosition]
            $nextPosition++
        }
        $body = $named['MockWith']
        if (-not $named.ContainsKey('MockWith') -and $positional.Count -gt $nextPosition) {
            $body = $positional[$nextPosition]
        }
        return @{
            CommandName   = Get-EpicStateIsolationElementText -Element $target
            HasModuleName = $named.ContainsKey('ModuleName')
            ModuleName    = Get-EpicStateIsolationElementText -Element $named['ModuleName']
            MockWith      = $body
        }
    }

    function Test-EpicStateIsolationNullBody {
        # Pure: true when a Mock body is a script block holding exactly one $null statement.
        [OutputType([bool])]
        param([AllowNull()] [System.Management.Automation.Language.Ast] $Body)
        if ($Body -isnot [System.Management.Automation.Language.ScriptBlockExpressionAst]) { return $false }
        $block = $Body.ScriptBlock
        if ($null -ne $block.ParamBlock -or $null -ne $block.BeginBlock -or $null -ne $block.ProcessBlock -or $null -eq $block.EndBlock) { return $false }
        $statements = @($block.EndBlock.Statements)
        return ($statements.Count -eq 1 -and $statements[0].Extent.Text.Trim() -ceq '$null')
    }

    function Get-EpicStateIsolationFinding {
        <#
            Pure: the epic-state isolation findings for one parsed suite, empty when the
            suite's outermost BeforeAll dot-sources the hook, then imports
            EpicScopeResolution.psm1 without -Force, then declares the $null Mock of
            Get-EpicScopeCheckpointText in module scope EpicScopeResolution.
        #>
        [OutputType([string])]
        param([Parameter(Mandatory)] [System.Management.Automation.Language.ScriptBlockAst] $Ast)

        $isCommand = { param($node) $node -is [System.Management.Automation.Language.CommandAst] }
        $outermost = @($Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'BeforeAll' }, $true) |
                Sort-Object -Property @{ Expression = { Get-EpicStateIsolationCommandDepth -Node $_ } }, @{ Expression = { $_.Extent.StartOffset } } |
                    Select-Object -First 1)
        $blockExpression = if ($outermost.Count -eq 1) {
            @($outermost[0].CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.ScriptBlockExpressionAst] }) | Select-Object -First 1
        }
        if ($null -eq $blockExpression) {
            'no outermost BeforeAll'
            return
        }

        $commands = @($blockExpression.ScriptBlock.FindAll($isCommand, $true) | Sort-Object -Property { $_.Extent.StartOffset })
        $mock = $null
        $binding = $null
        foreach ($command in $commands) {
            if ($command.GetCommandName() -ne 'Mock') { continue }
            $candidate = Get-EpicStateIsolationMockBinding -Command $command
            if ($candidate.CommandName -eq 'Get-EpicScopeCheckpointText') {
                $mock = $command
                $binding = $candidate
                break
            }
        }
        $import = $commands | Where-Object {
            $_.GetCommandName() -eq 'Import-Module' -and
            (@($_.CommandElements | Select-Object -Skip 1 | ForEach-Object { $_.Extent.Text }) -join ' ') -match 'EpicScopeResolution\.psm1'
        } | Select-Object -First 1
        $dotSource = $commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot } | Select-Object -First 1

        if ($null -eq $mock) {
            'Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll'
        } else {
            if (-not $binding.HasModuleName -or $binding.ModuleName -ne 'EpicScopeResolution') { 'Mock lacks -ModuleName EpicScopeResolution' }
            if (-not (Test-EpicStateIsolationNullBody -Body $binding.MockWith)) { 'Mock body is not exactly $null' }
        }
        if ($null -eq $import) {
            'Import-Module of EpicScopeResolution.psm1 missing from outermost BeforeAll'
        } elseif (@($import.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq 'Force' }).Count -gt 0) {
            'Import-Module of EpicScopeResolution.psm1 uses -Force'
        }
        if ($null -ne $mock -and $null -ne $import) {
            $ordered = $null -ne $dotSource -and
            $dotSource.Extent.StartOffset -lt $import.Extent.StartOffset -and
            $import.Extent.StartOffset -lt $mock.Extent.StartOffset
            if (-not $ordered) { 'hook dot-source, Import-Module, Mock order violated' }
        }
    }

    function Get-EpicStateIsolationSuiteFinding {
        # Parse one committed suite, located from the repository root, and return its
        # findings prefixed by the repository-relative path.
        [OutputType([string])]
        param([Parameter(Mandatory)] [string] $RelativePath)
        $fullPath = Join-Path $script:RepoRoot $RelativePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            "suite file not found: $RelativePath"
            return
        }
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($fullPath, [ref] $tokens, [ref] $errors)
        if (@($errors).Count -gt 0) {
            "${RelativePath}: parse error: $($errors[0].Message)"
            return
        }
        foreach ($finding in @(Get-EpicStateIsolationFinding -Ast $ast)) {
            "${RelativePath}: $finding"
        }
    }
}

Describe 'gate suites isolate the epic checkpoint read (structural guard)' {
    It '<Path> isolates the epic checkpoint read in its outermost BeforeAll' -ForEach @(
        @{ Path = 'tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1' }
        @{ Path = 'tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1' }
        @{ Path = 'tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1' }
        @{ Path = 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1' }
        @{ Path = 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1' }
        @{ Path = 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1' }
        @{ Path = 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1' }
    ) {
        # Arrange and act: parse the committed suite.
        $findings = @(Get-EpicStateIsolationSuiteFinding -RelativePath $Path)

        # Assert: no finding; the message names the suite and each missing property.
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }

    Context 'guard predicate discrimination' {
        # Each row parses an in-memory fixture, so the guard is shown to reject every
        # non-compliant shape rather than passing vacuously.
        It 'accepts the compliant <Name> form with zero findings' -ForEach @(
            @{
                Name   = 'positional'
                Source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    }
}
'@
            }
            @{
                Name   = '-CommandName and -MockWith'
                Source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock -CommandName Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -MockWith { $null }
    }
}
'@
            }
        ) {
            # Arrange
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)

            # Act
            $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

            # Assert
            @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
        }

        It 'rejects <Name> with a finding containing "<Expected>"' -ForEach @(
            @{
                Name     = 'a Mock that targets another command'
                Expected = 'missing from outermost BeforeAll'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'a Mock without -ModuleName'
                Expected = 'lacks -ModuleName'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText { $null }
    }
}
'@
            }
            @{
                Name     = 'a Mock body other than $null'
                Expected = 'not exactly'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { '' }
    }
}
'@
            }
            @{
                Name     = 'a Mock declared only in a nested Context BeforeAll'
                Expected = 'missing from outermost BeforeAll'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
    }
    Context 'nested' {
        BeforeAll {
            Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        }
    }
}
'@
            }
            @{
                Name     = 'an Import-Module with -Force'
                Expected = 'uses -Force'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1 -Force
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'an import and Mock placed before the hook dot-source'
                Expected = 'order violated'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        . $script:UnderTest
    }
}
'@
            }
        ) {
            # Arrange
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)

            # Act
            $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

            # Assert
            ($findings -join '; ') | Should -BeLike "*$Expected*"
        }

        It 'reports a listed suite path that does not exist and names the path' {
            # Arrange
            $missingPath = '/synthetic-worktrees/missing/enforce-missing.Tests.ps1'

            # Act
            $findings = @(Get-EpicStateIsolationSuiteFinding -RelativePath $missingPath)

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0] | Should -BeLike '*suite file not found*'
            $findings[0] | Should -BeLike "*$missingPath*"
        }
    }
}

BeforeDiscovery {
    # One call shape per gate that reaches Resolve-EpicScopeCheckpoint.
    $script:HostileShapes = @(
        @{ Gate = 'gate 1'; Text = 'gh pr create --head epic/hostile-integration --body-file artifacts/pr_body_1.md'; MatchWorktreeHead = $false; WorktreeSelector = '' }
        @{ Gate = 'gate 3'; Text = "Run the model-routing review for this item.`nbranch: epic/hostile-integration"; MatchWorktreeHead = $false; WorktreeSelector = '' }
        @{ Gate = 'gate 4'; Text = 'git add scripts/powershell/Sample.ps1'; MatchWorktreeHead = $true; WorktreeSelector = '' }
        @{ Gate = 'gate 4 selector'; Text = 'git -C /synthetic-worktrees/selected-item add scripts/powershell/Sample.ps1'; MatchWorktreeHead = $true; WorktreeSelector = '/synthetic-worktrees/selected-item' }
    )
}

Describe 'the Get-EpicScopeCheckpointText mock blocks the epic-state read (seam sufficiency)' {
    BeforeAll {
        # This file loads no hook, so there is no module instance to bind to; -Force loads a fresh one.
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeResolution.psm1') -Force
        $script:HostileEpicJson = '{"route_id":"epic","integration_branch":"epic/hostile-integration","epic_feature_folder":"hostile-epic","features":[]}'
        $script:SessionRoot = '/synthetic-worktrees/local-checkout'

        function Set-HostileEpicSeam {
            <#
                Mock the lower seams inside EpicScopeResolution so that, without the
                Get-EpicScopeCheckpointText mock, the resolver reads a hostile ready epic
                checkpoint whose integration_branch matches every call shape.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param()
            $hostileText = $script:HostileEpicJson
            Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
                if ($Path -like '/synthetic-worktrees/*') { return $Path }
                return '/synthetic-worktrees/local-checkout'
            }
            Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution { 'File' }
            Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { $hostileText }.GetNewClosure()
            Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { 'epic/hostile-integration' }
            Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $false }
        }

        function Invoke-HostileEpicResolution {
            # Resolve one call shape from the synthetic session root.
            param([Parameter(Mandatory)] [string] $Text, [bool] $MatchWorktreeHead, [string] $WorktreeSelector)
            $arguments = @{ Text = $Text; SessionRoot = $script:SessionRoot; MatchWorktreeHead = $MatchWorktreeHead }
            if (-not [string]::IsNullOrEmpty($WorktreeSelector)) { $arguments['WorktreeSelector'] = $WorktreeSelector }
            return (Resolve-EpicScopeCheckpoint @arguments)
        }
    }

    It '<Gate> control: the hostile payload is epic scope without the mock' -ForEach $script:HostileShapes {
        # Arrange: only the hostile lower seams.
        Set-HostileEpicSeam

        # Act
        $result = Invoke-HostileEpicResolution -Text $Text -MatchWorktreeHead $MatchWorktreeHead -WorktreeSelector $WorktreeSelector

        # Assert: the payload is read and decides the call, so the treatment rows are not vacuous.
        $result.IsEpicScope | Should -BeTrue -Because "the hostile checkpoint is read for $Gate (reason: $($result.Reason))"
        Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }
    }

    It '<Gate> treatment: the $null mock blocks the epic-state read' -ForEach $script:HostileShapes {
        # Arrange: the hostile lower seams plus the mock the seven suites declare.
        Set-HostileEpicSeam
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }

        # Act
        $result = Invoke-HostileEpicResolution -Text $Text -MatchWorktreeHead $MatchWorktreeHead -WorktreeSelector $WorktreeSelector

        # Assert
        $result.IsEpicScope | Should -BeFalse
        $result.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly
        Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 0 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 0 -Exactly
        Should -Invoke Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -Times 0 -Exactly
    }
}
