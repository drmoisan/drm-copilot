#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity of the generated-agent family list across its authoritative copies (issue #737,
    the remainder of issue #646).

.DESCRIPTION
    The list of agent families for which a generated per-band Codex deployment agent exists
    is declared in the PowerShell module .claude/lib/codex-routing/CodexDeployment.psm1, in
    the central routing config config/orchestration-routing.json
    (codex_model_policy.generated_agent_families), and in the Python reference
    scripts/dev_tools/resolve_codex_deployment.py. These rows compare the three sets with a
    case-sensitive ordinal comparison.

    No interpreter is launched: the Python literal is read as text and its quoted members are
    extracted by pattern. The extractor rejects text with no declaration, and every set passes
    a non-vacuity check, so an empty extraction cannot pass as equality of two empty sets.
    The rows create no file and read only committed files located from $PSScriptRoot.
#>

BeforeAll {
    # codex-routing -> claude-lib -> scripts -> tests -> repository root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/codex-routing/CodexDeployment.psm1')

    function Get-GeneratedFamilyFromPythonText {
        <# Extracts every GENERATED_AGENT_FAMILIES frozenset declaration and its quoted members from Python text. #>
        param([Parameter(Mandatory)] [string] $Text)
        $pattern = '(?ms)^GENERATED_AGENT_FAMILIES\b[^=\r\n]*=\s*frozenset\(\s*\{(?<body>.*?)\}\s*\)'
        $declarations = [regex]::Matches($Text, $pattern)
        if ($declarations.Count -eq 0) {
            throw 'No GENERATED_AGENT_FAMILIES declaration was found in the Python text.'
        }
        $members = [System.Collections.Generic.List[string]]::new()
        foreach ($declaration in $declarations) {
            foreach ($member in [regex]::Matches($declaration.Groups['body'].Value, '["''](?<name>[^"'']+)["'']')) {
                $members.Add($member.Groups['name'].Value)
            }
        }
        return [pscustomobject]@{ Declarations = $declarations.Count; Members = [string[]]$members.ToArray() }
    }

    function Get-ModuleFamilySet {
        <# The module set, wrapped with the leading comma so that a single member is not unrolled. #>
        $set = [string[]]@(InModuleScope -ModuleName 'CodexDeployment' -ScriptBlock { $script:GENERATED_AGENT_FAMILIES })
        return , $set
    }

    function Get-ConfigFamilySet {
        <# The central config set, wrapped with the leading comma so that a single member is not unrolled. #>
        $config = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot 'config/orchestration-routing.json')) | ConvertFrom-Json
        $set = [string[]]@($config.codex_model_policy.generated_agent_families)
        return , $set
    }

    function Get-PythonFamilySet {
        <# The Python authority set, wrapped with the leading comma so that a single member is not unrolled. #>
        $text = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot 'scripts/dev_tools/resolve_codex_deployment.py'))
        $set = [string[]]@((Get-GeneratedFamilyFromPythonText -Text $text).Members)
        return , $set
    }

    function ConvertTo-OrdinalSortedText {
        <# The distinct members in case-sensitive ordinal order, joined for comparison. #>
        param([Parameter(Mandatory)] [AllowEmptyCollection()] [string[]] $Set)
        $copy = [string[]]@($Set | Select-Object -Unique)
        [System.Array]::Sort($copy, [System.StringComparer]::Ordinal)
        return ($copy -join '|')
    }

    function Assert-NonEmptySet {
        <# Throws for a null or empty set, so two empty extractions cannot pass as equal. #>
        param([AllowNull()] [AllowEmptyCollection()] $Set, [Parameter(Mandatory)] [string] $Name)
        if ($null -eq $Set -or @($Set).Count -eq 0) {
            throw "The $Name family set is null or empty."
        }
    }
}

Describe 'GENERATED_AGENT_FAMILIES parity' {
    It 'AC-19 extractor rejects text with zero declarations' {
        { Get-GeneratedFamilyFromPythonText -Text 'OTHER_NAME = 1' } | Should -Throw -Because 'text without a declaration must not extract as an empty set'
    }

    It 'AC-19 extractor detects a divergent member' {
        $moduleSet = Get-ModuleFamilySet
        $fixture = 'GENERATED_AGENT_FAMILIES: frozenset[str] = frozenset({"orchestrator", "an-extra-family"})'

        $extracted = Get-GeneratedFamilyFromPythonText -Text $fixture

        (ConvertTo-OrdinalSortedText -Set $extracted.Members) | Should -Not -BeExactly (ConvertTo-OrdinalSortedText -Set $moduleSet) -Because 'a fixture literal with an extra member must differ from the module set'
    }

    It 'AC-19 module set equals the central config set' {
        $moduleSet = Get-ModuleFamilySet
        $configSet = Get-ConfigFamilySet

        (ConvertTo-OrdinalSortedText -Set $moduleSet) | Should -BeExactly (ConvertTo-OrdinalSortedText -Set $configSet) -Because 'the module list and codex_model_policy.generated_agent_families must be the same set'
    }

    It 'AC-19 module set equals the Python authority set' {
        $moduleSet = Get-ModuleFamilySet
        $pythonSet = Get-PythonFamilySet

        (ConvertTo-OrdinalSortedText -Set $moduleSet) | Should -BeExactly (ConvertTo-OrdinalSortedText -Set $pythonSet) -Because 'the module list and the Python frozenset literal must be the same set'
    }

    It 'AC-19 module set is non-empty' {
        { Assert-NonEmptySet -Set (Get-ModuleFamilySet) -Name 'module' } | Should -Not -Throw
    }

    It 'AC-19 config set is non-empty' {
        { Assert-NonEmptySet -Set (Get-ConfigFamilySet) -Name 'config' } | Should -Not -Throw
    }

    It 'AC-19 Python set is non-empty' {
        { Assert-NonEmptySet -Set (Get-PythonFamilySet) -Name 'Python' } | Should -Not -Throw
    }

    It 'AC-19 non-vacuity check rejects an empty set and a null set' {
        { Assert-NonEmptySet -Set @() -Name 'empty' } | Should -Throw
        { Assert-NonEmptySet -Set $null -Name 'null' } | Should -Throw
    }

    It 'AC-19 the test launches no interpreter' {
        $selfText = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'CodexDeployment.GeneratedFamilies.Parity.Tests.ps1'))
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($selfText, [ref] $null, [ref] $null)
        $forbidden = @('python', 'python3', 'py', 'poetry', 'Invoke-Expression', ('Start-' + 'Process'))

        $commandNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() })

        @($commandNames | Where-Object { $forbidden -contains $_ }).Count | Should -Be 0 -Because 'the rows read the Python literal as text and start no interpreter'
    }
}
