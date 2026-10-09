<#
.SYNOPSIS
    Compliance helpers for the epic-state isolation guard (issue #737).

.DESCRIPTION
    Dot-sourced after EpicStateIsolation.Discovery.Helpers.ps1 and EpicStateIsolation.Helpers.ps1,
    whose functions these helpers call. For one suite they compute the loaded-source closure and
    the seam census, map each seam to a requirement, and decide compliance by form F1 (a direct
    null Mock in the outermost BeforeAll, or the Register-EpicStateBaselineMock helper form), form
    F2 (seam under test, with synthetic-path literals), or form F3 (a cwd-derived resolver pinned
    to a synthetic root). Process-spawning suites are reported and never fail the guard.

    Every function takes an optional -ReadSource script block (repository-relative path in, text
    or $null out), so fixtures run over in-memory text. No function creates a file, runs a
    process, or reads gitignored state. This file is not mirrored under
    extensions/drm-copilot/resources/.
#>

function Test-EpicStateSeamUnderTestForm {
    # Pure: form F2. True when every direct call to the seam passes a /synthetic-worktrees/ literal
    # and the suite mocks Test-Path and Get-Content with a ParameterFilter on that literal.
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $Ast,
        [Parameter(Mandatory)] [string] $Seam
    )
    $isCommand = { param($node) $node -is [System.Management.Automation.Language.CommandAst] }
    $isLiteral = {
        param($node)
        $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    $commands = @($Ast.FindAll($isCommand, $true))
    $calls = @($commands | Where-Object { $_.GetCommandName() -eq $Seam })
    if ($calls.Count -eq 0) { return $false }
    foreach ($call in $calls) {
        $synthetic = @($call.FindAll($isLiteral, $true) | Where-Object { ([string]$_.Value).StartsWith('/synthetic-worktrees/', [System.StringComparison]::Ordinal) })
        if ($synthetic.Count -eq 0) { return $false }
    }
    foreach ($target in 'Test-Path', 'Get-Content') {
        $filtered = $false
        foreach ($mock in @($commands | Where-Object { $_.GetCommandName() -eq 'Mock' })) {
            if ((Get-EpicStateIsolationMockBinding -Command $mock).CommandName -ne $target) { continue }
            $elements = $mock.CommandElements
            for ($index = 1; $index -lt $elements.Count; $index++) {
                $element = $elements[$index]
                if ($element -isnot [System.Management.Automation.Language.CommandParameterAst] -or $element.ParameterName -ne 'ParameterFilter') { continue }
                $filterNode = if ($null -ne $element.Argument) { $element.Argument } elseif (($index + 1) -lt $elements.Count) { $elements[$index + 1] } else { $null }
                if ($null -ne $filterNode -and $filterNode.Extent.Text.Contains('/synthetic-worktrees/')) { $filtered = $true }
            }
        }
        if (-not $filtered) { return $false }
    }
    return $true
}

function Test-EpicStateResolverPinnedForm {
    # Pure: form F3. True when an outermost BeforeAll mocks the named cwd-derived resolver to
    # return a value containing a /synthetic-worktrees/ literal.
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.ScriptBlockAst] $Ast,
        [Parameter(Mandatory)] [string] $Resolver
    )
    foreach ($block in @(Get-EpicStateIsolationOutermostBlock -Ast $Ast)) {
        foreach ($command in @(Get-EpicStateIsolationDirectCommand -Block $block)) {
            if ($command.GetCommandName() -ne 'Mock') { continue }
            $binding = Get-EpicStateIsolationMockBinding -Command $command
            if ($binding.CommandName -ne $Resolver -or $null -eq $binding.MockWith) { continue }
            if ($binding.MockWith.Extent.Text.Contains('/synthetic-worktrees/')) { return $true }
        }
    }
    return $false
}

function Get-EpicStateSeamRequirement {
    # Pure: one requirement per distinct census seam. A seam defined in a lib .psm1 is a module seam
    # (ModuleName and ModuleFile from that file); any other seam is script-scope (ModuleName $null).
    # DefaultParameterSeam entries are report-only and produce no requirement.
    [OutputType([hashtable])]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Census)
    foreach ($group in ($Census | Group-Object -Property Name)) {
        $entries = @($group.Group)
        $required = @($entries | Where-Object { $_.Class -ne 'DefaultParameterSeam' })
        if ($required.Count -eq 0) { continue }
        $chosen = @($required | Where-Object { $_.Class -eq 'ModuleTextSeam' }) | Select-Object -First 1
        if ($null -eq $chosen) { $chosen = $required[0] }
        $moduleName = $null
        $moduleFile = $null
        if ($chosen.Class -eq 'ModuleTextSeam') {
            $moduleFile = $chosen.DefiningFile.Split('/')[-1]
            $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($moduleFile)
        }
        @{ Seam = $group.Name; ModuleName = $moduleName; ModuleFile = $moduleFile; Class = $chosen.Class }
    }
}

function Get-EpicStateSuiteState {
    # Pure over the reader: the AST and requirements of one suite, or an error finding.
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $RepoRoot,
        [Parameter(Mandatory)] [string] $RelativePath,
        [scriptblock] $ReadSource
    )
    $reader = $ReadSource
    $library = @()
    if ($null -eq $reader) {
        $reader = New-EpicStateSourceReader -RepoRoot $RepoRoot
        $library = @(Get-EpicStateLibraryDirectory -RepoRoot $RepoRoot)
    }
    $text = & $reader $RelativePath
    if ($null -eq $text) { return [pscustomobject]@{ Error = "${RelativePath}: suite file not found"; Ast = $null; Requirement = @() } }
    $parsed = Get-EpicStateParsedSource -Text $text
    if ($parsed.ErrorCount -gt 0) { return [pscustomobject]@{ Error = "${RelativePath}: parse error: $($parsed.FirstError)"; Ast = $null; Requirement = @() } }
    $closure = @(Get-EpicStateLoadedSourceClosure -SuiteText $text -ReadSource $reader -LibraryDirectory $library)
    $requirement = @(Get-EpicStateSeamRequirement -Census @(Get-EpicStateSeamCensus -ClosureFile $closure))
    return [pscustomobject]@{ Error = $null; Ast = $parsed.Ast; Requirement = $requirement }
}

function Get-EpicStateSuiteCompliance {
    # Findings for one suite, each in the form "<path>: seam <name>: <violated rule>"; empty when
    # compliant. A missing or unparseable suite yields one finding that names the path.
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $RepoRoot,
        [Parameter(Mandatory)] [string] $RelativePath,
        [scriptblock] $ReadSource
    )
    $state = Get-EpicStateSuiteState -RepoRoot $RepoRoot -RelativePath $RelativePath -ReadSource $ReadSource
    if ($null -ne $state.Error) { return $state.Error }
    foreach ($item in $state.Requirement) {
        $form1 = @(Get-EpicStateIsolationFinding -Ast $state.Ast -Requirement @($item))
        if ($form1.Count -eq 0) { continue }
        if (Test-EpicStateSeamUnderTestForm -Ast $state.Ast -Seam $item.Seam) { continue }
        if ($item.Class -eq 'CwdDerivedResolver' -and (Test-EpicStateResolverPinnedForm -Ast $state.Ast -Resolver $item.Seam)) { continue }
        "${RelativePath}: seam $($item.Seam): $($form1[0])"
    }
}

function Get-EpicStateProcessSpawningReport {
    # One REPORT line for a process-spawning suite and nothing otherwise; never a finding.
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $RepoRoot,
        [Parameter(Mandatory)] [string] $RelativePath,
        [scriptblock] $ReadSource
    )
    $reader = $ReadSource
    if ($null -eq $reader) { $reader = New-EpicStateSourceReader -RepoRoot $RepoRoot }
    $text = & $reader $RelativePath
    if ($null -eq $text) { return }
    $launched = @(Get-EpicStateProcessSpawningHook -SuiteText $text)
    if ($launched.Count -gt 0) { "REPORT: $RelativePath launches $($launched -join ', ')" }
}
