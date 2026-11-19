#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and absence contracts of the release-commit allowance leg (issue #1201).

.DESCRIPTION
    Hashes and reads committed files only, located from $PSScriptRoot; hook paths are built from
    a variable leaf, as hook-docs-estate-context.Parity.Tests.ps1 does, so no hook is loaded. The
    rows cover byte identity and size of the two new hook files (spec AC-22), the gate wiring in
    the four gate copies (AC-21), the absence of the allowance file from the repository, both
    bundle roots, and every pack manifest (AC-24), the Python publisher tuple (AC-25), the
    documentation tokens (AC-27, AC-28), the absence of Python invocation text (AC-32), and the
    ReleaseAllowance prefix of every script-scope variable the new files assign. No row writes a
    file or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:HookRoots = @(
        '.claude/hooks'
        '.codex/hooks'
        'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
        'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
    )
    $script:AllowanceFile = 'release-commit-allowance.json'

    function Get-ReleaseParityText {
        # Read one committed file as text.
        param([Parameter(Mandatory)] [string] $RelativePath)
        return [string](Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot $RelativePath))
    }

    function Get-ReleaseParityHash {
        # Hash one committed file.
        param([Parameter(Mandatory)] [string] $RelativePath)
        return (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Algorithm SHA256).Hash
    }

    function Get-ReleaseParitySection {
        # Return the text from a level-two heading to the next level-two heading.
        param([Parameter(Mandatory)] [string] $Text, [Parameter(Mandatory)] [string] $Heading)
        $lines = $Text -split "`r?`n"
        $start = [array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return '' }
        $end = $lines.Count
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index].StartsWith('## ', [System.StringComparison]::Ordinal)) { $end = $index; break }
        }
        return (($lines[$start..($end - 1)]) -join "`n")
    }

    function Get-ReleaseParityScriptScopeViolation {
        # Return each script-scope variable a script assigns whose name does not start with ReleaseAllowance.
        param([Parameter(Mandatory)] [string] $Text)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
        $names = [System.Collections.Generic.List[string]]::new()
        foreach ($assignment in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true)) {
            $target = $assignment.Left
            if ($target -is [System.Management.Automation.Language.ConvertExpressionAst]) { $target = $target.Child }
            if ($target -is [System.Management.Automation.Language.VariableExpressionAst] -and $target.VariablePath.IsScript) { $names.Add(($target.VariablePath.UserPath -replace '^script:', '')) }
        }
        foreach ($command in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -in @('Set-Variable', 'New-Variable') }, $true)) {
            $elements = @($command.CommandElements)
            $scope = ''
            $name = ''
            for ($index = 1; $index -lt $elements.Count - 1; $index++) {
                if ($elements[$index] -isnot [System.Management.Automation.Language.CommandParameterAst]) { continue }
                if ($elements[$index].ParameterName -eq 'Scope') { $scope = [string]$elements[$index + 1].Extent.Text.Trim("'", '"') }
                if ($elements[$index].ParameterName -eq 'Name') { $name = [string]$elements[$index + 1].Extent.Text.Trim("'", '"') }
            }
            if ($scope -eq 'Script') { $names.Add($name) }
        }
        return @($names | Where-Object { -not ([string]$_).StartsWith('ReleaseAllowance', [System.StringComparison]::Ordinal) } | ForEach-Object { [string]$_ })
    }
}

Describe 'release-commit allowance parity and absence contracts (issue #1201)' {
    It 'keeps the four copies of <Leaf> byte-identical and below 500 lines (AC-22)' -ForEach @(
        @{ Leaf = 'hook-release-allowance-context.ps1' }
        @{ Leaf = 'enforce-orchestration-preimplementation-gate-release.ps1' }
    ) {
        # Arrange
        $copies = @($script:HookRoots | ForEach-Object { "$_/$Leaf" })

        # Act
        $hashes = @($copies | ForEach-Object { Get-ReleaseParityHash -RelativePath $_ })
        $lineCounts = @($copies | ForEach-Object { @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $_)).Count })

        # Assert
        $hashes.Count | Should -Be 4
        @($hashes | Select-Object -Unique).Count | Should -Be 1 -Because "every copy of $Leaf must equal .claude/hooks/$Leaf"
        @($lineCounts | Where-Object { $_ -ge 500 }).Count | Should -Be 0 -Because "each copy of $Leaf stays below 500 lines ($($lineCounts -join ', '))"
    }

    It 'wires the leg into the <Surface> gate copy under <Root> (AC-21)' -ForEach @(
        @{ Surface = 'Claude'; Root = '.claude/hooks'; Source = '.claude/hooks'; LastLeg = 'Get-OrchestrationParallelRecordsResult' }
        @{ Surface = 'Claude'; Root = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'; Source = '.claude/hooks'; LastLeg = 'Get-OrchestrationParallelRecordsResult' }
        @{ Surface = 'Codex'; Root = '.codex/hooks'; Source = '.codex/hooks'; LastLeg = 'Get-OrchestrationDocsEstateContextResult' }
        @{ Surface = 'Codex'; Root = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'; Source = '.codex/hooks'; LastLeg = 'Get-OrchestrationDocsEstateContextResult' }
    ) {
        # Arrange
        $gateLeaf = 'enforce-orchestration-preimplementation-gate.ps1'
        $text = Get-ReleaseParityText -RelativePath "$Root/$gateLeaf"
        $guarded = "try { . (Join-Path `$PSScriptRoot 'enforce-orchestration-preimplementation-gate-release.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-release.ps1' -ErrorRecord `$_ }"
        $denyLine = @($text -split "`r?`n" | Where-Object { $_.Contains("'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require") })

        # Act
        $dotSourceCount = ([regex]::Matches($text, [regex]::Escape("'enforce-orchestration-preimplementation-gate-release.ps1')"))).Count
        $callCount = ([regex]::Matches($text, 'Get-OrchestrationReleaseAllowanceResult')).Count

        # Assert
        $dotSourceCount | Should -Be 1 -Because 'one dot-source of the release sibling'
        $text.Contains($guarded) | Should -BeTrue -Because 'the dot-source uses the guarded single-statement form'
        $callCount | Should -Be 1 -Because 'one leg call'
        $text.IndexOf('Get-OrchestrationReleaseAllowanceResult', [System.StringComparison]::Ordinal) | Should -BeGreaterThan $text.LastIndexOf("$LastLeg -", [System.StringComparison]::Ordinal) -Because "the leg runs after $LastLeg"
        $denyLine.Count | Should -Be 1
        $denyLine[0].TrimEnd().EndsWith('+ $release.DenySuffix)', [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the release suffix is the last term of the final deny'
        (Get-ReleaseParityHash -RelativePath "$Root/$gateLeaf") | Should -Be (Get-ReleaseParityHash -RelativePath "$Source/$gateLeaf") -Because 'each bundle gate equals its source'
    }

    It 'lists the allowance file in no pack manifest and ships it in no root (AC-24)' {
        # Arrange
        $manifests = @(Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot 'extensions/drm-copilot/resources') -Recurse -Filter '*.json' | Where-Object { $_.Directory.Name -eq 'pack-manifests' })
        $roots = @('.claude', 'extensions/drm-copilot/resources/claude-customizations/.claude', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.claude')

        # Act
        $listing = @($manifests | Where-Object { (Get-Content -Raw -LiteralPath $_.FullName).Contains($script:AllowanceFile) })
        $present = @($roots | Where-Object { Test-Path -LiteralPath (Join-Path (Join-Path $script:RepoRoot $_) $script:AllowanceFile) })

        # Assert
        $manifests.Count | Should -BeGreaterThan 1 -Because 'the bundle holds pack manifests to search'
        $listing.Count | Should -Be 0 -Because ('no pack manifest lists the allowance file: ' + (@($listing | ForEach-Object { $_.Name }) -join ', '))
        $present.Count | Should -Be 0 -Because ('the allowance file is absent from: ' + ($present -join ', '))
    }

    It 'lists the allowance file in the Python publisher tuple (AC-25)' {
        # Arrange
        $text = Get-ReleaseParityText -RelativePath 'scripts/dev_tools/push_down_claude_customizations.py'

        # Act
        $tuple = [regex]::Match($text, '(?s)EXCLUDED_RELATIVE_PATHS: tuple\[Path, \.\.\.\] = \((.*?)\n\)').Groups[1].Value

        # Assert
        $tuple.Contains('Path(".claude/release-commit-allowance.json")') | Should -BeTrue -Because 'the Python publisher excludes the allowance file'
    }

    It 'states the release-commit allowance in <Path> (AC-27)' -ForEach @(
        @{ Path = '.claude/skills/execution-environment/SKILL.md' }
        @{ Path = '.agents/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md' }
    ) {
        # Arrange
        $text = Get-ReleaseParityText -RelativePath $Path
        $context = Get-ReleaseParitySection -Text $text -Heading '## Hook Execution Context'
        $contracts = Get-ReleaseParitySection -Text $text -Heading '## Contract Tests That Pin Mirrored Files'

        # Act
        $missingContext = @('Release-commit allowance leg (#1201)', '.claude/release-commit-allowance.json', 'RELEASE_ALLOWANCE_CONFIG_INVALID', 'RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED', 'single quotes', '-F <file>' | Where-Object { -not $context.Contains($_) })
        $missingContracts = @('hook-release-allowance-context.Parity.Tests.ps1', 'claude-customizations-release-allowance.test.ts' | Where-Object { -not $contracts.Contains($_) })

        # Assert
        $missingContext | Should -BeNullOrEmpty -Because "## Hook Execution Context of $Path names every token"
        $missingContracts | Should -BeNullOrEmpty -Because "## Contract Tests That Pin Mirrored Files of $Path names both tests"
        (Get-ReleaseParityHash -RelativePath $Path) | Should -Be (Get-ReleaseParityHash -RelativePath '.claude/skills/execution-environment/SKILL.md') -Because 'the six brief copies are byte-identical'
    }

    It 'states the release-commit allowance in <Path> (AC-28)' -ForEach @(
        @{ Path = '.agents/skills/orchestrate/SKILL.md'; Source = '.agents/skills/orchestrate/SKILL.md'; Heading = '## Pre-Implementation Gate'; Token = 'Release-commit allowance (issue #1201)' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md'; Source = '.agents/skills/orchestrate/SKILL.md'; Heading = '## Pre-Implementation Gate'; Token = 'Release-commit allowance (issue #1201)' }
        @{ Path = '.claude/rules/orchestrator-state.md'; Source = '.claude/rules/orchestrator-state.md'; Heading = '## Release-Commit Allowance Scope'; Token = 'destination-owned' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md'; Source = '.claude/rules/orchestrator-state.md'; Heading = '## Release-Commit Allowance Scope'; Token = 'destination-owned' }
    ) {
        # Arrange
        $text = Get-ReleaseParityText -RelativePath $Path

        # Act
        $section = Get-ReleaseParitySection -Text $text -Heading $Heading

        # Assert
        $section.Contains($Token) | Should -BeTrue -Because "$Heading of $Path names $Token"
        (Get-ReleaseParityHash -RelativePath $Path) | Should -Be (Get-ReleaseParityHash -RelativePath $Source) -Because 'each bundle copy equals its source'
    }

    It 'keeps Python and Poetry out of <Leaf> under <Root> (AC-32)' -ForEach @(
        foreach ($root in '.claude/hooks', '.codex/hooks', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks') {
            foreach ($leaf in 'hook-release-allowance-context.ps1', 'enforce-orchestration-preimplementation-gate-release.ps1') { @{ Root = $root; Leaf = $leaf } }
        }
    ) {
        # Act
        $text = Get-ReleaseParityText -RelativePath "$Root/$Leaf"

        # Assert
        $text | Should -Not -Match 'python' -Because "$Leaf invokes no Python"
        $text | Should -Not -Match 'poetry' -Because "$Leaf invokes no Poetry"
    }

    It 'prefixes every script-scope variable of <Leaf> under <Root> with ReleaseAllowance' -ForEach @(
        foreach ($root in '.claude/hooks', '.codex/hooks', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks') {
            foreach ($leaf in 'hook-release-allowance-context.ps1', 'enforce-orchestration-preimplementation-gate-release.ps1') { @{ Root = $root; Leaf = $leaf } }
        }
    ) {
        # Act
        $violations = @(Get-ReleaseParityScriptScopeViolation -Text (Get-ReleaseParityText -RelativePath "$Root/$Leaf"))

        # Assert
        $violations | Should -BeNullOrEmpty -Because "script-scope names in $Leaf use the ReleaseAllowance prefix"
    }

    It 'reports a script-scope assignment without the prefix (<Label>)' -ForEach @(
        @{ Label = 'assignment'; Text = '$script:Other = 1'; Expected = 'Other' }
        @{ Label = 'typed assignment'; Text = '[string] $script:Typed = ''x'''; Expected = 'Typed' }
        @{ Label = 'Set-Variable'; Text = 'Set-Variable -Name Named -Scope Script -Value 1'; Expected = 'Named' }
        @{ Label = 'prefixed assignment'; Text = '$script:ReleaseAllowanceKeys = 1'; Expected = $null }
    ) {
        # Act
        $violations = @(Get-ReleaseParityScriptScopeViolation -Text $Text)

        # Assert
        if ($null -eq $Expected) { $violations.Count | Should -Be 0 } else { $violations | Should -Be @($Expected) }
    }
}
