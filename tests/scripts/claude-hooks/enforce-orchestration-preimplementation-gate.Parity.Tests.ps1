#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Behavioral parity of the Claude and Codex preimplementation gates (issue #737, the remainder
# of issue #555). The two gates carry a mirrored set of functions. This suite proves that they
# agree by BEHAVIOR on a shared case table, not by text: no hash and no text comparison of the
# gate files is used. A row whose expectation differs by surface must appear in the declared
# divergence list of the case file, and a function added to either gate must be declared.
#
# Each runtime Describe dot-sources exactly one gate, from a path resolved relative to this
# file, and never both in one scope. The two main gates are read only. The suite creates no
# file, starts no child process, and reads no gitignored state; the epic-state reads of the
# gate closure are mocked by the baseline helper.

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.Parity.Cases.ps1')
}

Describe 'preimplementation gate behavioral parity (<Runtime>)' -ForEach @(
    @{ Runtime = 'claude'; GateRelativePath = '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'; PayloadKind = 'envelope'; Surface = 'Claude'; Seam = @('Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent') }
    @{ Runtime = 'codex'; GateRelativePath = '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; PayloadKind = 'mapped'; Surface = 'Codex'; Seam = @('Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText') }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        . (Join-Path $repoRoot $GateRelativePath)
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam $Seam -Surface $Surface
        Register-EpicStateBaselineMock -Seam $ExtraSeam -Surface $Surface
        if ($Runtime -eq 'claude') { Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } } }

        function Get-ParityExpected {
            <# The expectation of a case on one surface: the per-surface value when declared, else the shared value. #>
            param([Parameter(Mandatory)] [hashtable] $Case, [Parameter(Mandatory)] [string] $Surface)
            if ($Case.ContainsKey('Surfaces') -and $Case.Surfaces.ContainsKey($Surface)) { return $Case.Surfaces[$Surface] }
            return $Case.Expected
        }

        function ConvertTo-ParityToolInputRaw {
            <# The tool input text of a decision case in the payload shape of the runtime under test. #>
            param([Parameter(Mandatory)] [hashtable] $Case, [Parameter(Mandatory)] [string] $Kind)
            if ($Case.Kind -eq 'empty') { return '' }
            $toolName = switch ($Case.Kind) { 'agent' { 'Agent' } 'command' { 'Bash' } default { 'Write' } }
            if ($Kind -eq 'envelope') {
                return (@{ tool_name = $toolName; tool_input = $Case.Fields } | ConvertTo-Json -Compress -Depth 5)
            }
            return ($Case.Fields | ConvertTo-Json -Compress -Depth 5)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface $Surface -Seam $Seam }

    It 'AC-17 path classification <Name> <Runtime>' -ForEach $script:PathCases {
        $case = $_
        $expected = Get-ParityExpected -Case $case -Surface $Runtime

        $actual = try { Test-ImplementationPath -NormalizedPath $case.Input } catch { 'THROWS' }

        $actual | Should -Be $expected -Because "Test-ImplementationPath must classify '$($case.Input)' the same way as the shared table on the $Runtime surface"
    }

    It 'AC-17 command classification <Name> <Runtime>' -ForEach $script:CommandCases {
        $case = $_
        $expected = Get-ParityExpected -Case $case -Surface $Runtime

        $actual = try { Test-ImplementationCommand -Command $case.Input } catch { 'THROWS' }

        $actual | Should -Be $expected -Because "Test-ImplementationCommand must classify '$($case.Input)' the same way as the shared table on the $Runtime surface"
    }

    It 'AC-17 delegation classification <Name> <Runtime>' -ForEach $script:DelegationCases {
        $case = $_
        $expected = Get-ParityExpected -Case $case -Surface $Runtime
        $toolInput = if ($null -eq $case.Input) { $null } else { $case.Input | ConvertTo-Json -Compress -Depth 5 | ConvertFrom-Json }

        $preparation = Test-PreparationModeDelegation -ToolInput $toolInput
        $implementation = Test-ImplementationDelegation -ToolInput $toolInput

        $preparation | Should -Be $expected.Preparation -Because 'the preparation-mode classification must match the shared table'
        $implementation | Should -Be $expected.Implementation -Because 'the implementation classification must match the shared table'
    }

    It 'AC-17 readiness <Name> <Runtime>' -ForEach $script:ReadinessCases {
        $case = $_
        $expected = Get-ParityExpected -Case $case -Surface $Runtime
        $checkpoint = try { ConvertFrom-CheckpointJson -Json $case.Raw } catch { $null }

        $actual = Test-OrchestrationReady -Payload $checkpoint

        $actual | Should -Be $expected -Because "Test-OrchestrationReady must judge the checkpoint '$($case.Name)' the same way as the shared table"
    }

    It 'AC-17 decision <Name> <Runtime>' -ForEach $script:DecisionCases {
        $case = $_
        $expected = Get-ParityExpected -Case $case -Surface $Runtime
        $raw = ConvertTo-ParityToolInputRaw -Case $case -Kind $PayloadKind

        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $raw -CheckpointRaw $case.Checkpoint

        $decision.hookSpecificOutput.permissionDecision | Should -Be $expected -Because "the gate decision for '$($case.Name)' must match the shared table on the $Runtime surface"
    }
}

Describe 'preimplementation gate declared divergence' {
    BeforeEach {
        . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.Parity.Cases.ps1')

        function Assert-DivergenceDeclared {
            <# Throws unless the rows whose per-surface expectations differ equal the declared set, both ways. #>
            param([Parameter(Mandatory)] [hashtable] $Table, [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Declared)
            $found = [System.Collections.Generic.List[string]]::new()
            foreach ($tableName in $Table.Keys) {
                foreach ($row in $Table[$tableName]) {
                    if (-not $row.ContainsKey('Surfaces')) { continue }
                    $claude = $row.Surfaces['claude'] | ConvertTo-Json -Compress -Depth 5
                    $codex = $row.Surfaces['codex'] | ConvertTo-Json -Compress -Depth 5
                    if ($claude -ne $codex) { $found.Add("$tableName|$($row.Name)") }
                }
            }
            $declaredKeys = @($Declared | ForEach-Object { "$($_.Table)|$($_.Name)" })
            $undeclared = @($found | Where-Object { $declaredKeys -cnotcontains $_ })
            $stale = @($declaredKeys | Where-Object { $found -cnotcontains $_ })
            if ($undeclared.Count -gt 0 -or $stale.Count -gt 0) {
                throw "Divergent rows without a declaration: [$($undeclared -join '; ')]. Declarations without a divergent row: [$($stale -join '; ')]."
            }
        }
    }

    It 'AC-17 the set of rows with differing per-surface expectations equals the declared set' {
        $tables = @{
            PathCases       = $script:PathCases
            CommandCases    = $script:CommandCases
            DelegationCases = $script:DelegationCases
            ReadinessCases  = $script:ReadinessCases
            DecisionCases   = $script:DecisionCases
        }

        { Assert-DivergenceDeclared -Table $tables -Declared $script:DeclaredDivergence } | Should -Not -Throw
    }

    It 'AC-17 an undeclared divergence fails' {
        $fixture = @{ FixtureCases = @(@{ Name = 'an undeclared row'; Expected = $true; Surfaces = @{ claude = $true; codex = $false } }) }

        { Assert-DivergenceDeclared -Table $fixture -Declared @() } | Should -Throw
    }
}

Describe 'preimplementation gate function inventory' {
    BeforeEach {
        . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.Parity.Cases.ps1')

        function Get-GateFunctionName {
            <# The names of the functions an in-memory script text defines. #>
            param([Parameter(Mandatory)] [string] $Text)
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
            return @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object { $_.Name } | Sort-Object -Unique -CaseSensitive)
        }

        function Assert-GateFunctionSet {
            <# Throws unless the defined function names equal the declared names, both ways. #>
            param([Parameter(Mandatory)] [string[]] $Actual, [Parameter(Mandatory)] [string[]] $Expected)
            $undeclared = @($Actual | Where-Object { $Expected -cnotcontains $_ })
            $missing = @($Expected | Where-Object { $Actual -cnotcontains $_ })
            if ($undeclared.Count -gt 0 -or $missing.Count -gt 0) {
                throw "Undeclared functions: [$($undeclared -join '; ')]. Declared functions that are absent: [$($missing -join '; ')]."
            }
        }
    }

    It 'AC-18 each gate''s function names equal the shared set plus its declared per-surface set' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $gates = @(
            @{ Path = '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'; Own = $script:ClaudeOnlyGateFunction }
            @{ Path = '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; Own = $script:CodexOnlyGateFunction }
        )

        foreach ($gate in $gates) {
            $text = [System.IO.File]::ReadAllText((Join-Path $repoRoot $gate.Path))
            $expected = @($script:SharedGateFunction) + @($gate.Own)

            { Assert-GateFunctionSet -Actual (Get-GateFunctionName -Text $text) -Expected $expected } | Should -Not -Throw -Because "$($gate.Path) must define only declared functions"
        }
    }

    It 'AC-18 an undeclared added function fails' {
        $fixture = "function Test-Declared { }`nfunction Test-Added { }"

        { Assert-GateFunctionSet -Actual (Get-GateFunctionName -Text $fixture) -Expected @('Test-Declared') } | Should -Throw
    }

    It 'AC-18 the parity test reads only the two canonical gate files' {
        $selfText = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.Parity.Tests.ps1'))
        $caseText = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.Parity.Cases.ps1'))
        $forbidden = @('Get-FileHash', 'Compare-Object', 'diff', 'fc', 'cmp')
        $gatePattern = '^\.(claude|codex)/hooks/enforce-orchestration-preimplementation-gate\.ps1$'
        $selfAst = [System.Management.Automation.Language.Parser]::ParseInput($selfText, [ref] $null, [ref] $null)
        $caseAst = [System.Management.Automation.Language.Parser]::ParseInput($caseText, [ref] $null, [ref] $null)

        $gatePaths = @($selfAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $node.Value -match $gatePattern }, $true) | ForEach-Object { $_.Value } | Sort-Object -Unique)
        $commands = @(@($selfAst, $caseAst) | ForEach-Object { $_.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) } | ForEach-Object { $_.GetCommandName() })

        $gatePaths | Should -Be @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1') -Because 'the suite reads only the two canonical gate files'
        @($commands | Where-Object { $forbidden -contains $_ }).Count | Should -Be 0 -Because 'no hash or whole-file text-comparison command may be used'
    }
}
