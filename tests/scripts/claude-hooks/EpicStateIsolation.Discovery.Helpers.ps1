<#
.SYNOPSIS
    Discovery helpers for the epic-state isolation guard (issue #737).

.DESCRIPTION
    Dot-sourced by enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, by
    enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 and by the
    compliance helpers. The functions enumerate the hook suites of both surfaces, compute the
    loaded-source closure of a suite from string literals, take a census of the read seams in
    that closure, and detect process-spawning suites.

    Get-EpicStateHookLiteral, Get-EpicStateProcessSpawningHook and Get-EpicStateVariableHookLoad call
    functions defined in EpicStateIsolation.HookReference.Helpers.ps1 (Get-EpicStateIsolationPattern,
    Test-EpicStateIsolationExcludedHookName, Get-EpicStateIsolationHookReference), which
    EpicStateIsolation.Helpers.ps1 dot-sources; dot-source EpicStateIsolation.Helpers.ps1 before
    calling any of them (issue #935, CR-R4, CR-F5).

    Every function is pure over text and AST except the two readers at the file boundary,
    Get-EpicStateDiscoveredSuite and Get-EpicStateSourceReader, which read the committed tree
    from a supplied repository root. Callers inject a reader script block, so fixtures run over
    in-memory text. No function creates a file, runs a process, or reads gitignored state.

    The closure is seeded only from hooks/<name>.ps1 string literals. Variable-built hook loads
    (root-variable, segment and dynamic forms, for example Join-Path $script:HookRoot '<name>.ps1')
    are detected by Get-EpicStateIsolationHookReference and reported through the AC-5b row; they are
    reported, not added to the closure (issue #935, #737 F-3).

    $script:EpicStateParseCache is a deliberate memo exception to the no-mutable-state rule: it
    is deterministic, keyed by source text, and lives for one test session only (#737 F-6).

    The census, closure-node and reader memos follow the same exception (issue #935, PERF):
    $script:EpicStateCensusCache is keyed by file path and text, $script:EpicStateClosureNodeCache
    by reader instance and path, and $script:EpicStateReaderCache by repository root. Dot-sourcing
    this file replaces every memo with an empty one, and each suite dot-sources it before calling
    these functions, so no suite reads another suite's memo entries.

    This file is not mirrored under extensions/drm-copilot/resources/.
#>

$script:EpicStateNamedSeam = @(
    'Get-EpicScopeCheckpointText'
    'Get-WorktreeRunCheckpointText'
    'Get-WorktreeItemCheckpointText'
    'Get-WorktreeItemLiveRoot'
)
$script:EpicStateParseCache = @{}
$script:EpicStateCensusCache = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
$script:EpicStateClosureNodeCache = [System.Collections.Generic.Dictionary[object, object]]::new()
$script:EpicStateReaderCache = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)

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
        The same script block is returned for a repository root on every call (issue #935, PERF).
    #>
    [OutputType([scriptblock])]
    param([Parameter(Mandatory)] [string] $RepoRoot)
    if ($script:EpicStateReaderCache.ContainsKey($RepoRoot)) { return $script:EpicStateReaderCache[$RepoRoot] }
    $root = $RepoRoot
    $reader = {
        param([string] $RelativePath)
        $full = Join-Path $root $RelativePath
        if (Test-Path -LiteralPath $full -PathType Leaf) { return (Get-Content -Raw -LiteralPath $full) }
        return $null
    }.GetNewClosure()
    $script:EpicStateReaderCache[$RepoRoot] = $reader
    return $reader
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
    # Pure: the distinct hook script names named by hooks/<name>.ps1 string literals, excluding EpicStateIsolation helper files and test files.
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $SuiteText)
    $names = [System.Collections.Generic.List[string]]::new()
    $hookLiteralPattern = Get-EpicStateIsolationPattern -Name HookLiteral
    foreach ($literal in (Get-EpicStateParsedSource -Text $SuiteText).Literal) {
        # The lookbehind keeps a test path such as tests/scripts/claude-hooks/X.Tests.ps1 from reading as a hook.
        foreach ($match in [regex]::Matches($literal, $hookLiteralPattern)) {
            $name = $match.Groups['name'].Value
            if (Test-EpicStateIsolationExcludedHookName -Name $name) { continue }
            if (-not $names.Contains($name)) { $names.Add($name) }
        }
    }
    return [string[]]$names.ToArray()
}

function Get-EpicStateMemoSourceText {
    <#
        Pure over the injected reader: the reader's text for one path, or $null when it returns
        none, memoized in $script:EpicStateClosureNodeCache per reader instance and path. A reader
        returns the same text for a path for as long as the instance lives (issue #935, PERF).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [scriptblock] $ReadSource
    )
    $key = [System.Tuple[object, string]]::new($ReadSource, 'text' + [char]0 + $Path)
    if (-not $script:EpicStateClosureNodeCache.ContainsKey($key)) { $script:EpicStateClosureNodeCache[$key] = & $ReadSource $Path }
    return $script:EpicStateClosureNodeCache[$key]
}

function Get-EpicStateClosureSuccessor {
    <#
        Pure over the injected reader: the paths that the .ps1 and .psm1 string literals of one
        closure file resolve to, in literal order; each is the first candidate (resolved beside the
        file, beside the file by leaf, then in each library directory) for which the reader returns
        text. Memoized per reader instance, path and library directories (issue #935, PERF).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [scriptblock] $ReadSource,
        [string[]] $LibraryDirectory = @()
    )
    $key = [System.Tuple[object, string]]::new($ReadSource, 'next' + [char]0 + $Path + [char]0 + ($LibraryDirectory -join [char]0))
    if (-not $script:EpicStateClosureNodeCache.ContainsKey($key)) {
        $text = Get-EpicStateMemoSourceText -Path $Path -ReadSource $ReadSource
        $folder = if ($Path.Contains('/')) { $Path.Substring(0, $Path.LastIndexOf('/')) } else { '' }
        $next = [System.Collections.Generic.List[string]]::new()
        $literals = if ($null -eq $text) { @() } else { (Get-EpicStateParsedSource -Text $text).Literal }
        foreach ($literal in $literals) {
            if ($literal -notmatch '\.psm?1$' -or $literal.Contains('*')) { continue }
            $leaf = $literal.Replace([string][char]92, '/').Split('/')[-1]
            $candidates = @(Resolve-EpicStateRelativePath -Directory $folder -Literal $literal) + @("$folder/$leaf") + @($LibraryDirectory | ForEach-Object { "$_/$leaf" })
            foreach ($candidate in $candidates) {
                if ($null -ne (Get-EpicStateMemoSourceText -Path $candidate -ReadSource $ReadSource)) {
                    $next.Add($candidate)
                    break
                }
            }
        }
        $script:EpicStateClosureNodeCache[$key] = [string[]]$next.ToArray()
    }
    foreach ($candidate in $script:EpicStateClosureNodeCache[$key]) { $candidate }
}

function Get-EpicStateLoadedSourceClosure {
    <#
        Pure over the injected reader: the files a suite loads. Starts from every hooks/<name>.ps1
        string literal of the suite, resolved against .claude/hooks and .codex/hooks, then expands
        transitively through string literals ending .ps1 or .psm1 in each loaded file, resolved
        beside the file or in a library directory. Literal scanning (not statement scanning) is
        required because the closure includes variable-driven loads.
        Reads and resolutions go through the per-reader memo (Get-EpicStateMemoSourceText,
        Get-EpicStateClosureSuccessor), so each file is read and resolved once (issue #935, PERF).
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
        $text = Get-EpicStateMemoSourceText -Path $path -ReadSource $ReadSource
        if ($null -eq $text) { continue }
        $loaded[$path] = $text
        foreach ($candidate in @(Get-EpicStateClosureSuccessor -Path $path -ReadSource $ReadSource -LibraryDirectory $LibraryDirectory)) {
            if (-not $loaded.Contains($candidate)) { $queue.Enqueue($candidate) }
        }
    }
    foreach ($key in $loaded.Keys) { [pscustomobject]@{ Path = $key; Text = $loaded[$key] } }
}

function Get-EpicStateSeamCensus {
    <#
        Pure: the read seams in a closure. A seam is a function whose body contains a read
        primitive (Get-Content, ReadAllText, ReadAllLines) and either whose name matches
        Checkpoint or whose body or defining file holds an artifacts/ string literal (Decision 3),
        plus the four named seams of Decision 1 whenever defined in the closure. Each file's
        records come from the Get-EpicStateFileSeamCensus memo (issue #935, PERF).
    #>
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $ClosureFile)
    foreach ($file in $ClosureFile) { Get-EpicStateFileSeamCensus -Path $file.Path -Text $file.Text }
}

function Get-EpicStateFileSeamCensus {
    <#
        Pure: the census records of one closure file, memoized in $script:EpicStateCensusCache by
        path and text, because a file's census does not depend on the suite that loaded it. A
        repeated path and text returns the cached record objects; callers do not modify them.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $Text
    )
    $key = $Path + [char]0 + $Text
    if (-not $script:EpicStateCensusCache.ContainsKey($key)) {
        $isFunction = { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }
        $isLiteral = {
            param($node)
            $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
            $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
        }
        $parsed = Get-EpicStateParsedSource -Text $Text
        $fileHoldsArtifacts = @($parsed.Literal | Where-Object { $_.Contains('artifacts/') }).Count -gt 0
        $records = foreach ($function in $parsed.Ast.FindAll($isFunction, $true)) {
            $body = $function.Body.Extent.Text
            $reads = $body -match 'Get-Content|ReadAllText|ReadAllLines'
            $named = $script:EpicStateNamedSeam -contains $function.Name
            $bodyHoldsArtifacts = @($function.Body.FindAll($isLiteral, $true) | Where-Object { ([string]$_.Value).Contains('artifacts/') }).Count -gt 0
            if (-not ($named -or ($reads -and ($function.Name -match 'Checkpoint' -or $bodyHoldsArtifacts -or $fileHoldsArtifacts)))) { continue }
            $paramBlock = $function.Body.ParamBlock
            $parameterDefaultReads = $null -ne $paramBlock -and @($paramBlock.Parameters | Where-Object { $null -ne $_.DefaultValue -and $_.DefaultValue.Extent.Text -match 'Get-Content|ReadAllText|ReadAllLines' }).Count -gt 0
            $class = if ($body -match '\(Get-Location\)\.Path') { 'CwdDerivedResolver' }
            elseif ($parameterDefaultReads -and -not $named) { 'DefaultParameterSeam' }
            elseif ($Path -match '(^|/)lib/.+\.psm1$') { 'ModuleTextSeam' }
            else { 'HookLocalContentSeam' }
            [pscustomobject]@{ Name = $function.Name; Class = $class; DefiningFile = $Path }
        }
        $script:EpicStateCensusCache[$key] = [object[]]@($records)
    }
    foreach ($record in $script:EpicStateCensusCache[$key]) { $record }
}

function Get-EpicStateProcessSpawningHook {
    <#
        Pure: the hook script names a suite launches as child processes. The suite is
        process-spawning when its text contains ProcessStartInfo or the process-start cmdlet
        name (written literally or composed from two fragments). The result is the distinct union
        of its hooks/<name>.ps1 literal names and its variable-built hook loads, a dynamic leaf
        rendered as *(<root>) (issue #935, F-3). The cmdlet name is built here from two fragments
        so this file never holds it as one token.
    #>
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $SuiteText)
    $cmdlet = 'Start' + '-' + 'Process'
    $composedLeading = "['""]Start['""]\s*\+\s*['""]-Process"
    $composedTrailing = "['""]Start-['""]\s*\+\s*['""]Process"
    $spawns = $SuiteText.Contains('ProcessStartInfo') -or $SuiteText.Contains($cmdlet) -or
    $SuiteText -match $composedLeading -or $SuiteText -match $composedTrailing
    if (-not $spawns) { return }
    return [string[]](@(Get-EpicStateHookLiteral -SuiteText $SuiteText) + @(Get-EpicStateVariableHookLoad -SuiteText $SuiteText))
}

function Get-EpicStateVariableHookLoad {
    <#
        Pure (issue #935, #737 F-3): the variable-built hook loads of a suite whose names are not
        already named by a hooks/<name>.ps1 literal, distinct and in source order. A dynamic leaf is
        rendered as *(<root>), or * when its root names neither hook surface. Parses through the
        Get-EpicStateParsedSource memo, so no additional parse is made.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $SuiteText)
    $literal = @(Get-EpicStateHookLiteral -SuiteText $SuiteText)
    $names = [System.Collections.Generic.List[string]]::new()
    foreach ($reference in @(Get-EpicStateIsolationHookReference -Ast (Get-EpicStateParsedSource -Text $SuiteText).Ast)) {
        if ($reference.Form -eq 'Literal') { continue }
        $name = if ($reference.Form -ne 'Dynamic') { $reference.Name } elseif ($null -ne $reference.Root) { "*($($reference.Root))" } else { '*' }
        if ($literal -contains $name -or $names.Contains($name)) { continue }
        $names.Add($name)
    }
    foreach ($loadName in $names) { $loadName }
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
