<#
.SYNOPSIS
    Discovery helpers for the epic-state isolation guard (issue #737).

.DESCRIPTION
    Dot-sourced by enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 and by the
    compliance helpers. The functions enumerate the hook suites of both surfaces, compute the
    loaded-source closure of a suite from string literals, take a census of the read seams in
    that closure, and detect process-spawning suites.

    Every function is pure over text and AST except the two readers at the file boundary,
    Get-EpicStateDiscoveredSuite and Get-EpicStateSourceReader, which read the committed tree
    from a supplied repository root. Callers inject a reader script block, so fixtures run over
    in-memory text. No function creates a file, runs a process, or reads gitignored state.

    This file is not mirrored under extensions/drm-copilot/resources/.
#>

$script:EpicStateNamedSeam = @(
    'Get-EpicScopeCheckpointText'
    'Get-WorktreeRunCheckpointText'
    'Get-WorktreeItemCheckpointText'
    'Get-WorktreeItemLiveRoot'
)
$script:EpicStateParseCache = @{}

function Get-EpicStateDiscoveredSuite {
    <#
        Reader: the repository-relative paths of every *.Tests.ps1 directly in
        tests/scripts/<Surface>, ordinal sorted, by directory enumeration (no recursion).
    #>
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $RepoRoot,
        [Parameter(Mandatory)] [ValidateSet('claude-hooks', 'codex-hooks')] [string] $Surface
    )
    $directory = Join-Path (Join-Path (Join-Path $RepoRoot 'tests') 'scripts') $Surface
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) { return }
    $found = [System.Collections.Generic.List[string]]::new()
    foreach ($file in (Get-ChildItem -LiteralPath $directory -Filter '*.Tests.ps1' -File)) {
        $found.Add("tests/scripts/$Surface/$($file.Name)")
    }
    $sorted = [string[]]$found.ToArray()
    [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)
    return $sorted
}

function Get-EpicStateSourceReader {
    <#
        Reader: a script block that takes a repository-relative path and returns the file text,
        or $null when the file does not exist.
    #>
    [OutputType([scriptblock])]
    param([Parameter(Mandatory)] [string] $RepoRoot)
    $root = $RepoRoot
    return {
        param([string] $RelativePath)
        $full = Join-Path $root $RelativePath
        if (Test-Path -LiteralPath $full -PathType Leaf) { return (Get-Content -Raw -LiteralPath $full) }
        return $null
    }.GetNewClosure()
}

function Get-EpicStateLibraryDirectory {
    # Reader: the repository-relative library directories beneath .claude/lib and .codex/lib.
    [OutputType([string])]
    param([Parameter(Mandatory)] [string] $RepoRoot)
    foreach ($base in '.claude/lib', '.codex/lib') {
        $full = Join-Path $RepoRoot $base
        if (-not (Test-Path -LiteralPath $full -PathType Container)) { continue }
        foreach ($directory in (Get-ChildItem -LiteralPath $full -Directory | Sort-Object Name)) { "$base/$($directory.Name)" }
    }
}

function Get-EpicStateParsedSource {
    # Pure: the parsed AST and the non-bareword string-literal values of one source text, cached by text.
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Text)
    if ($script:EpicStateParseCache.ContainsKey($Text)) { return $script:EpicStateParseCache[$Text] }
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
    $literals = [System.Collections.Generic.List[string]]::new()
    $isLiteral = {
        param($node)
        ($node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
        $node.StringConstantType -ne [System.Management.Automation.Language.StringConstantType]::BareWord) -or
        $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    foreach ($node in $ast.FindAll($isLiteral, $true)) { $literals.Add([string]$node.Value) }
    $firstError = if (@($errors).Count -gt 0) { [string]$errors[0].Message } else { $null }
    $parsed = [pscustomobject]@{ Ast = $ast; Literal = [string[]]$literals.ToArray(); ErrorCount = @($errors).Count; FirstError = $firstError }
    $script:EpicStateParseCache[$Text] = $parsed
    return $parsed
}

function Resolve-EpicStateRelativePath {
    # Pure: join a repository-relative directory and a literal, resolving '.' and '..' segments.
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $Directory,
        [Parameter(Mandatory)] [string] $Literal
    )
    $text = $Literal.Replace([string][char]92, '/') -replace '^\$PSScriptRoot/', ''
    $segments = [System.Collections.Generic.List[string]]::new()
    foreach ($segment in (($Directory + '/' + $text) -split '/')) {
        if ($segment -eq '' -or $segment -eq '.') { continue }
        if ($segment -eq '..') {
            if ($segments.Count -gt 0) { $segments.RemoveAt($segments.Count - 1) }
            continue
        }
        $segments.Add($segment)
    }
    return ($segments -join '/')
}

function Get-EpicStateHookLiteral {
    # Pure: the distinct hook script names named by hooks/<name>.ps1 string literals, excluding EpicStateIsolation helpers.
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $SuiteText)
    $names = [System.Collections.Generic.List[string]]::new()
    foreach ($literal in (Get-EpicStateParsedSource -Text $SuiteText).Literal) {
        # The lookbehind keeps a test path such as tests/scripts/claude-hooks/X.Tests.ps1 from reading as a hook.
        foreach ($match in [regex]::Matches($literal, '(?<![A-Za-z0-9_-])hooks/(?<name>[A-Za-z0-9._-]+\.ps1)')) {
            $name = $match.Groups['name'].Value
            if ($name.StartsWith('EpicStateIsolation.', [System.StringComparison]::Ordinal)) { continue }
            if ($name.EndsWith('.Tests.ps1', [System.StringComparison]::Ordinal)) { continue }
            if (-not $names.Contains($name)) { $names.Add($name) }
        }
    }
    return [string[]]$names.ToArray()
}

function Get-EpicStateLoadedSourceClosure {
    <#
        Pure over the injected reader: the files a suite loads. Starts from every hooks/<name>.ps1
        string literal of the suite, resolved against .claude/hooks and .codex/hooks, then expands
        transitively through string literals ending .ps1 or .psm1 in each loaded file, resolved
        beside the file or in a library directory. Literal scanning (not statement scanning) is
        required because the closure includes variable-driven loads.
    #>
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $SuiteText,
        [Parameter(Mandatory)] [scriptblock] $ReadSource,
        [string[]] $LibraryDirectory = @()
    )
    $loaded = [ordered]@{}
    $queue = [System.Collections.Generic.Queue[string]]::new()
    foreach ($name in (Get-EpicStateHookLiteral -SuiteText $SuiteText)) {
        foreach ($directory in '.claude/hooks', '.codex/hooks') { $queue.Enqueue("$directory/$name") }
    }
    while ($queue.Count -gt 0) {
        $path = $queue.Dequeue()
        if ($loaded.Contains($path)) { continue }
        $text = & $ReadSource $path
        if ($null -eq $text) { continue }
        $loaded[$path] = $text
        $folder = if ($path.Contains('/')) { $path.Substring(0, $path.LastIndexOf('/')) } else { '' }
        foreach ($literal in (Get-EpicStateParsedSource -Text $text).Literal) {
            if ($literal -notmatch '\.psm?1$' -or $literal.Contains('*')) { continue }
            $leaf = $literal.Replace([string][char]92, '/').Split('/')[-1]
            $candidates = @(Resolve-EpicStateRelativePath -Directory $folder -Literal $literal) + @("$folder/$leaf") + @($LibraryDirectory | ForEach-Object { "$_/$leaf" })
            foreach ($candidate in $candidates) {
                if ($loaded.Contains($candidate)) { break }
                if ($null -ne (& $ReadSource $candidate)) {
                    $queue.Enqueue($candidate)
                    break
                }
            }
        }
    }
    foreach ($key in $loaded.Keys) { [pscustomobject]@{ Path = $key; Text = $loaded[$key] } }
}

function Get-EpicStateSeamCensus {
    <#
        Pure: the read seams in a closure. A seam is a function whose body contains a read
        primitive (Get-Content, ReadAllText, ReadAllLines) and either whose name matches
        Checkpoint or whose body or defining file holds an artifacts/ string literal (Decision 3),
        plus the four named seams of Decision 1 whenever defined in the closure.
    #>
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $ClosureFile)
    $isFunction = { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }
    $isLiteral = {
        param($node)
        $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    foreach ($file in $ClosureFile) {
        $parsed = Get-EpicStateParsedSource -Text $file.Text
        $fileHoldsArtifacts = @($parsed.Literal | Where-Object { $_.Contains('artifacts/') }).Count -gt 0
        foreach ($function in $parsed.Ast.FindAll($isFunction, $true)) {
            $body = $function.Body.Extent.Text
            $reads = $body -match 'Get-Content|ReadAllText|ReadAllLines'
            $named = $script:EpicStateNamedSeam -contains $function.Name
            $bodyHoldsArtifacts = @($function.Body.FindAll($isLiteral, $true) | Where-Object { ([string]$_.Value).Contains('artifacts/') }).Count -gt 0
            if (-not ($named -or ($reads -and ($function.Name -match 'Checkpoint' -or $bodyHoldsArtifacts -or $fileHoldsArtifacts)))) { continue }
            $paramBlock = $function.Body.ParamBlock
            $parameterDefaultReads = $null -ne $paramBlock -and @($paramBlock.Parameters | Where-Object { $null -ne $_.DefaultValue -and $_.DefaultValue.Extent.Text -match 'Get-Content|ReadAllText|ReadAllLines' }).Count -gt 0
            $class = if ($body -match '\(Get-Location\)\.Path') { 'CwdDerivedResolver' }
            elseif ($parameterDefaultReads -and -not $named) { 'DefaultParameterSeam' }
            elseif ($file.Path -match '(^|/)lib/.+\.psm1$') { 'ModuleTextSeam' }
            else { 'HookLocalContentSeam' }
            [pscustomobject]@{ Name = $function.Name; Class = $class; DefiningFile = $file.Path }
        }
    }
}

function Get-EpicStateProcessSpawningHook {
    <#
        Pure: the hook script names a suite launches as child processes. The suite is
        process-spawning when its text contains ProcessStartInfo or the process-start cmdlet
        name (written literally or composed from two fragments) and names a hook script by a
        hooks/<name>.ps1 literal. The cmdlet name is built here from two fragments so this file
        never holds it as one token.
    #>
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $SuiteText)
    $cmdlet = 'Start' + '-' + 'Process'
    $composedLeading = "['""]Start['""]\s*\+\s*['""]-Process"
    $composedTrailing = "['""]Start-['""]\s*\+\s*['""]Process"
    $spawns = $SuiteText.Contains('ProcessStartInfo') -or $SuiteText.Contains($cmdlet) -or
    $SuiteText -match $composedLeading -or $SuiteText -match $composedTrailing
    if (-not $spawns) { return }
    return (Get-EpicStateHookLiteral -SuiteText $SuiteText)
}

function Get-EpicStateSuiteCensusRow {
    # Compose the discovery functions for one committed suite, located from the repository root.
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $RepoRoot,
        [Parameter(Mandatory)] [string] $RelativePath
    )
    $reader = Get-EpicStateSourceReader -RepoRoot $RepoRoot
    $suiteText = & $reader $RelativePath
    if ($null -eq $suiteText) { $suiteText = '' }
    $closure = @(Get-EpicStateLoadedSourceClosure -SuiteText $suiteText -ReadSource $reader -LibraryDirectory @(Get-EpicStateLibraryDirectory -RepoRoot $RepoRoot))
    $seams = @(Get-EpicStateSeamCensus -ClosureFile $closure | ForEach-Object { $_.Name } | Sort-Object -Unique -CaseSensitive)
    $launched = @(Get-EpicStateProcessSpawningHook -SuiteText $suiteText)
    return [pscustomobject]@{
        Path            = $RelativePath
        ClosureCount    = $closure.Count
        Seam            = $seams
        ProcessSpawning = ($launched.Count -gt 0)
        HooksLaunched   = $launched
    }
}

function Format-EpicStateCensusLine {
    # Pure: the CENSUS-SUITE line for one census row.
    [OutputType([string])]
    param([Parameter(Mandatory)] [pscustomobject] $Row)
    $seamText = if (@($Row.Seam).Count -gt 0) { @($Row.Seam) -join ',' } else { 'NONE' }
    $launchedText = if (@($Row.HooksLaunched).Count -gt 0) { @($Row.HooksLaunched) -join ',' } else { 'NONE' }
    return "CENSUS-SUITE: $($Row.Path) | closure=$($Row.ClosureCount) | seams=$seamText | process-spawning=$($Row.ProcessSpawning) | hooks-launched=$launchedText"
}
