<#
.SYNOPSIS
    Pure test-execution policy logic (issue #1158): defaults, validation, merge, lane
    selection, worker-reduction tokens, and the suite command builder.

.DESCRIPTION
    Dot-sourced by the test-execution launcher, the enforce-test-execution-policy hook, and
    the MCP PoshQC templates. Every function is pure over its inputs; the configuration text
    arrives through the ReadText seam of Get-TestExecutionPolicy. Nothing is written to any
    stream when the file is dot-sourced.

    Dot-sourced as: . (Join-Path $PSScriptRoot 'test-execution-policy.ps1')
#>

$script:TestExecutionPolicyConfigPath = 'config/test-execution-policy.json'
$script:TestExecutionPolicyTopLevelKey = @('version', 'localLanes', 'lanes', 'machineLock', 'requireLauncher', 'suites')
$script:TestExecutionPolicyLaneField = @('pytestMarkers', 'pesterTags', 'mstestCategories', 'fileNameSuffixes')
$script:TestExecutionPolicyRunner = @('pytest', 'pester', 'jest', 'mstest', 'bats')

function Get-TestExecutionPolicyDefault {
    <#
    .SYNOPSIS
        Return the built-in policy as nested ordered dictionaries.
    .PARAMETER PesterSuiteScript
        Repository-relative path of Invoke-PesterSuite.ps1 for the built-in pester suite.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $PesterSuiteScript = '.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'
    )

    $suites = [ordered]@{
        'pytest'      = [ordered]@{ command = @('poetry', 'run', 'pytest', '-n', 'auto'); runner = 'pytest' }
        'pester'      = [ordered]@{ command = @('pwsh', '-NoProfile', '-NonInteractive', '-File', $PesterSuiteScript); runner = 'pester' }
        'jest'        = [ordered]@{ command = @('node', 'run-jest.cjs'); runner = 'jest' }
        'dotnet-test' = [ordered]@{ command = @('dotnet', 'test'); runner = 'mstest' }
    }
    return [ordered]@{
        version         = 1
        localLanes      = [ordered]@{ exclude = @('integration', 'golden') }
        lanes           = [ordered]@{
            integration = [ordered]@{
                pytestMarkers    = @('integration')
                pesterTags       = @('Integration')
                mstestCategories = @('Integration')
                fileNameSuffixes = @('.integration.test.ts', '.integration.test.js', '_integration.py', '.integration.tests.ps1')
            }
            golden      = [ordered]@{
                pytestMarkers    = @('golden')
                pesterTags       = @('Golden')
                mstestCategories = @('Golden')
                fileNameSuffixes = @('.golden.test.ts', '.golden.test.js', '_golden.py', '.golden.tests.ps1')
            }
        }
        machineLock     = [ordered]@{ enabled = $true; waitMilliseconds = 90000; pollMilliseconds = 2000 }
        requireLauncher = $true
        suites          = $suites
    }
}

function Test-TestExecutionPolicyDictionary {
    <#
    .SYNOPSIS
        Return true when Value is a dictionary (a parsed JSON object).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [System.Collections.IDictionary])
}

function Test-TestExecutionPolicyStringArray {
    <#
    .SYNOPSIS
        Return true when Value is an array whose every entry is a non-blank string.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    if ($null -eq $Value -or $Value -is [string] -or $Value -isnot [System.Collections.IList]) { return $false }
    foreach ($item in $Value) {
        if ($item -isnot [string] -or [string]::IsNullOrWhiteSpace($item)) { return $false }
    }
    return $true
}

function Test-TestExecutionPolicyInteger {
    <#
    .SYNOPSIS
        Return true when Value is an integral number within Minimum and Maximum inclusive.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value, [long] $Minimum = [long]::MinValue, [long] $Maximum = [long]::MaxValue)

    if ($Value -isnot [int] -and $Value -isnot [long]) { return $false }
    return ([long] $Value -ge $Minimum -and [long] $Value -le $Maximum)
}

function Merge-TestExecutionPolicyValue {
    <#
    .SYNOPSIS
        Merge Override over Base: dictionaries merge by key, every other value replaces.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary], [object[]], [object])]
    param([AllowNull()] $Base, [AllowNull()] $Override)

    if ((Test-TestExecutionPolicyDictionary $Base) -and (Test-TestExecutionPolicyDictionary $Override)) {
        $merged = [ordered]@{}
        foreach ($key in $Base.Keys) { $merged[$key] = $Base[$key] }
        foreach ($key in $Override.Keys) {
            $merged[$key] = Merge-TestExecutionPolicyValue -Base $merged[$key] -Override $Override[$key]
        }
        return $merged
    }
    return , $Override
}

function Get-TestExecutionWorkerReductionToken {
    <#
    .SYNOPSIS
        Return the first worker-reduction token of Runner in ArgumentList, or $null (D9).
    .DESCRIPTION
        pytest: -n or --numprocesses followed by a number (space or = form) and -p no:xdist;
        jest: --maxWorkers, -w, --runInBand, -i; pester: -WorkerCount; mstest and bats: none.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Runner,
        [AllowEmptyCollection()][string[]] $ArgumentList = @()
    )

    $words = @($ArgumentList)
    for ($i = 0; $i -lt $words.Count; $i++) {
        $word = $words[$i]
        $next = if ($i + 1 -lt $words.Count) { $words[$i + 1] } else { $null }
        switch ($Runner) {
            'pytest' {
                if ($word -ceq '-n' -or $word -ceq '--numprocesses') {
                    if ($null -ne $next -and $next -match '^[0-9]+$') { return "$word $next" }
                } elseif ($word -cmatch '^(-n|--numprocesses)=?([0-9]+)$') {
                    return $word
                } elseif ($word -ceq '-p' -and $next -ceq 'no:xdist') {
                    return '-p no:xdist'
                } elseif ($word -ceq '-pno:xdist') {
                    return $word
                }
            }
            'jest' {
                if ($word -cmatch '^--maxWorkers(=.*)?$' -or $word -cmatch '^-w(=.*)?$' -or $word -ceq '--runInBand' -or $word -ceq '-i') { return $word }
            }
            'pester' {
                if ($word -match '^-WorkerCount(:.*)?$') { return $word }
            }
        }
    }
    return $null
}

function Get-TestExecutionExcludedLane {
    <#
    .SYNOPSIS
        Return the merged lane definitions named by localLanes.exclude, as name and lane pairs.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][System.Collections.IDictionary] $Policy)

    $result = [System.Collections.Generic.List[object]]::new()
    foreach ($name in @($Policy['localLanes']['exclude'])) {
        if ($Policy['lanes'].Contains($name)) { $result.Add([pscustomobject]@{ Name = $name; Lane = $Policy['lanes'][$name] }) }
    }
    return $result.ToArray()
}

function Test-TestExecutionMarkerSelected {
    <#
    .SYNOPSIS
        Return true when the pytest marker expression selects Marker without a preceding not.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([string] $Expression, [string] $Marker)

    $tokens = @([regex]::Split($Expression, '[\s()]+') | Where-Object { $_ -ne '' })
    for ($i = 0; $i -lt $tokens.Count; $i++) {
        if ($tokens[$i] -ceq $Marker -and -not ($i -gt 0 -and $tokens[$i - 1] -ceq 'not')) { return $true }
    }
    return $false
}

function Get-TestExecutionLaneSelection {
    <#
    .SYNOPSIS
        Return the name of the excluded lane that ArgumentList selects for Runner, or $null.
    .DESCRIPTION
        Launcher step 3: a path operand whose file name ends with a lane suffix (ordinal,
        case-insensitive); a pytest -m expression naming a lane marker without not; a
        Pester -Tag value equal to a lane tag; a dotnet test --filter naming a lane category.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory)][string] $Runner,
        [AllowEmptyCollection()][string[]] $ArgumentList = @()
    )

    $words = @($ArgumentList)
    foreach ($entry in (Get-TestExecutionExcludedLane -Policy $Policy)) {
        $lane = $entry.Lane
        for ($i = 0; $i -lt $words.Count; $i++) {
            $word = $words[$i]
            $next = if ($i + 1 -lt $words.Count) { $words[$i + 1] } else { '' }
            if (-not $word.StartsWith('-')) {
                $leaf = ($word -split '::')[0]
                $leaf = ($leaf -split '[\\/]')[-1]
                foreach ($suffix in @($lane['fileNameSuffixes'])) {
                    if ($leaf.EndsWith($suffix, [System.StringComparison]::OrdinalIgnoreCase)) { return $entry.Name }
                }
            }
            if ($Runner -eq 'pytest') {
                $expression = if ($word -ceq '-m') { $next } elseif ($word -cmatch '^-m(.+)$') { $Matches[1].TrimStart('=') } else { $null }
                if ($null -ne $expression) {
                    foreach ($marker in @($lane['pytestMarkers'])) { if (Test-TestExecutionMarkerSelected -Expression $expression -Marker $marker) { return $entry.Name } }
                }
            }
            if ($Runner -eq 'pester' -and $word -match '^-Tag$') {
                for ($j = $i + 1; $j -lt $words.Count -and -not $words[$j].StartsWith('-'); $j++) {
                    foreach ($value in ($words[$j] -split ',')) {
                        foreach ($tag in @($lane['pesterTags'])) { if ($value.Trim() -ieq $tag) { return $entry.Name } }
                    }
                }
            }
            if ($Runner -eq 'mstest') {
                $filter = if ($word -ceq '--filter') { $next } elseif ($word -cmatch '^--filter[=:](.*)$') { $Matches[1] } else { $null }
                if ($null -ne $filter) {
                    foreach ($category in @($lane['mstestCategories'])) {
                        if ($filter -match "(?i)(^|[^!])(Test)?Category\s*[=~]\s*$([regex]::Escape($category))\b") { return $entry.Name }
                    }
                }
            }
        }
    }
    return $null
}

function Get-TestExecutionLaneExclusionArgument {
    <#
    .SYNOPSIS
        Return the lane-exclusion words for Runner in the one-word-per-value forms of D27.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory)][string] $Runner
    )

    $lanes = @(Get-TestExecutionExcludedLane -Policy $Policy)
    $words = [System.Collections.Generic.List[string]]::new()
    if ($lanes.Count -eq 0) { return $words.ToArray() }
    $markers = @($lanes | ForEach-Object { @($_.Lane['pytestMarkers']) })
    $tags = @($lanes | ForEach-Object { @($_.Lane['pesterTags']) })
    $categories = @($lanes | ForEach-Object { @($_.Lane['mstestCategories']) })
    $suffixes = @($lanes | ForEach-Object { @($_.Lane['fileNameSuffixes']) })
    switch ($Runner) {
        'pytest' {
            if ($markers.Count -gt 0) {
                $words.Add('-m')
                $words.Add((@($markers | ForEach-Object { "not $_" }) -join ' and '))
            }
            foreach ($suffix in $suffixes) { $words.Add("--ignore-glob=*$suffix") }
        }
        'pester' {
            if ($tags.Count -gt 0) { $words.Add('-ExcludeTag'); foreach ($tag in $tags) { $words.Add($tag) } }
            if ($suffixes.Count -gt 0) { $words.Add('-ExcludeTestFileSuffix'); foreach ($suffix in $suffixes) { $words.Add($suffix) } }
        }
        'jest' {
            $words.Add('--testPathIgnorePatterns=/node_modules/')
            $words.Add('--testPathIgnorePatterns=/out/')
            foreach ($suffix in $suffixes) { $words.Add("--testPathIgnorePatterns=$([regex]::Escape($suffix))`$") }
        }
        'mstest' {
            if ($categories.Count -gt 0) { $words.Add('--filter=' + (@($categories | ForEach-Object { "TestCategory!=$_" }) -join '&')) }
        }
    }
    return $words.ToArray()
}

function New-TestExecutionSuiteCommand {
    <#
    .SYNOPSIS
        Return the suite's command words, then its lane exclusions, then the caller's extras.
    .DESCRIPTION
        Never adds a worker option (D9). Throws when the suite is not defined.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that returns command words and changes no system state.')]
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory)][string] $SuiteName,
        [AllowEmptyCollection()][string[]] $ExtraArgument = @()
    )

    if (-not $Policy['suites'].Contains($SuiteName)) { throw "Unknown test suite '$SuiteName'." }
    $suite = $Policy['suites'][$SuiteName]
    $words = [System.Collections.Generic.List[string]]::new()
    foreach ($word in @($suite['command'])) { $words.Add([string] $word) }
    foreach ($word in (Get-TestExecutionLaneExclusionArgument -Policy $Policy -Runner ([string] $suite['runner']))) { $words.Add($word) }
    foreach ($word in @($ExtraArgument)) { $words.Add($word) }
    return $words.ToArray()
}

function Test-TestExecutionSuiteDefinition {
    <#
    .SYNOPSIS
        Return the validation errors of one suite definition.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([string] $Name, [AllowNull()] $Suite)

    $errors = [System.Collections.Generic.List[string]]::new()
    $field = "suites.$Name"
    if (-not (Test-TestExecutionPolicyDictionary $Suite)) { $errors.Add("field '$field' must be an object"); return $errors.ToArray() }
    $runner = $Suite['runner']
    if ($runner -isnot [string] -or $script:TestExecutionPolicyRunner -cnotcontains $runner) {
        $errors.Add("field '$field.runner' must be one of $($script:TestExecutionPolicyRunner -join ', ')")
    }
    if (-not (Test-TestExecutionPolicyStringArray $Suite['command']) -or @($Suite['command']).Count -eq 0) {
        $errors.Add("field '$field.command' must be a non-empty array of non-blank strings")
    } elseif ($runner -is [string]) {
        $token = Get-TestExecutionWorkerReductionToken -Runner $runner -ArgumentList ([string[]] @($Suite['command']))
        if ($null -ne $token) { $errors.Add("field '$field.command' carries the worker-reduction token '$token'") }
    }
    if ($Suite.Contains('workingDirectory')) {
        $directory = $Suite['workingDirectory']
        $relative = $directory -is [string] -and -not [string]::IsNullOrWhiteSpace($directory) -and -not ($directory -match '^([A-Za-z]:|[\\/])') -and -not (@($directory -split '[\\/]') -contains '..')
        if (-not $relative) { $errors.Add("field '$field.workingDirectory' must be a repository-relative path with no '..' segment") }
    }
    return $errors.ToArray()
}

function Test-TestExecutionPolicyDocument {
    <#
    .SYNOPSIS
        Return the validation errors of a parsed configuration document, each naming its field.
    .PARAMETER Document
        The parsed configuration object.
    .PARAMETER Default
        The built-in policy the document is merged over; used for cross-field rules.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()] $Document,
        [System.Collections.IDictionary] $Default = (Get-TestExecutionPolicyDefault)
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    if (-not (Test-TestExecutionPolicyDictionary $Document)) { $errors.Add("field '(document)' must be a JSON object"); return $errors.ToArray() }
    foreach ($key in $Document.Keys) {
        if ($script:TestExecutionPolicyTopLevelKey -cnotcontains $key) { $errors.Add("field '$key' is not a known top-level key") }
    }
    if ($Document.Contains('version') -and -not ((Test-TestExecutionPolicyInteger $Document['version']) -and [long] $Document['version'] -eq 1)) {
        $errors.Add("field 'version' must equal 1")
    }
    foreach ($key in 'localLanes', 'lanes', 'machineLock', 'suites') {
        if ($Document.Contains($key) -and -not (Test-TestExecutionPolicyDictionary $Document[$key])) { $errors.Add("field '$key' must be an object") }
    }
    if ($errors.Count -gt 0) { return $errors.ToArray() }
    $merged = Merge-TestExecutionPolicyValue -Base $Default -Override $Document
    foreach ($laneName in $merged['lanes'].Keys) {
        $lane = $merged['lanes'][$laneName]
        if (-not (Test-TestExecutionPolicyDictionary $lane)) { $errors.Add("field 'lanes.$laneName' must be an object"); continue }
        foreach ($fieldName in $script:TestExecutionPolicyLaneField) {
            if ($lane.Contains($fieldName) -and -not (Test-TestExecutionPolicyStringArray $lane[$fieldName])) {
                $errors.Add("field 'lanes.$laneName.$fieldName' must be an array of non-blank strings")
            }
        }
    }
    $exclude = $merged['localLanes']['exclude']
    if (-not (Test-TestExecutionPolicyStringArray $exclude)) {
        $errors.Add("field 'localLanes.exclude' must be an array of non-blank strings")
    } else {
        foreach ($name in $exclude) {
            if (-not $merged['lanes'].Contains($name)) { $errors.Add("field 'localLanes.exclude' names the lane '$name', which is not defined under lanes") }
        }
    }
    $lock = $merged['machineLock']
    if ($lock['enabled'] -isnot [bool]) { $errors.Add("field 'machineLock.enabled' must be a boolean") }
    if (-not (Test-TestExecutionPolicyInteger $lock['waitMilliseconds'] -Minimum 0 -Maximum 540000)) { $errors.Add("field 'machineLock.waitMilliseconds' must be an integer from 0 to 540000") }
    if (-not (Test-TestExecutionPolicyInteger $lock['pollMilliseconds'] -Minimum 100 -Maximum 10000)) { $errors.Add("field 'machineLock.pollMilliseconds' must be an integer from 100 to 10000") }
    if ($merged['requireLauncher'] -isnot [bool]) { $errors.Add("field 'requireLauncher' must be a boolean") }
    foreach ($suiteName in $merged['suites'].Keys) {
        foreach ($message in (Test-TestExecutionSuiteDefinition -Name $suiteName -Suite $merged['suites'][$suiteName])) { $errors.Add($message) }
    }
    return $errors.ToArray()
}

function Get-TestExecutionPolicy {
    <#
    .SYNOPSIS
        Return the built-in policy merged with the repository configuration text.
    .DESCRIPTION
        ReadText returns the text of config/test-execution-policy.json, or $null when the
        file is absent (defaults apply). Invalid text throws a message that starts
        TEST_EXECUTION_POLICY_BLOCKED: and names the file and the failing field.
    .PARAMETER ReadText
        Seam returning the configuration text or $null.
    .PARAMETER PesterSuiteScript
        Repository-relative path of Invoke-PesterSuite.ps1 passed to the defaults.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][scriptblock] $ReadText,
        [string] $PesterSuiteScript = '.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'
    )

    $default = Get-TestExecutionPolicyDefault -PesterSuiteScript $PesterSuiteScript
    $text = & $ReadText
    if ($null -eq $text) { return $default }
    $prefix = "TEST_EXECUTION_POLICY_BLOCKED: invalid test-execution policy configuration $($script:TestExecutionPolicyConfigPath)"
    try {
        $document = ConvertFrom-Json -InputObject ([string] $text) -AsHashtable -NoEnumerate -ErrorAction Stop
    } catch {
        throw "${prefix}: field '(document)' is not valid JSON (test-execution policy)."
    }
    $errors = @(Test-TestExecutionPolicyDocument -Document $document -Default $default)
    if ($errors.Count -gt 0) { throw "${prefix}: $($errors[0]) (test-execution policy)." }
    return (Merge-TestExecutionPolicyValue -Base $default -Override $document)
}
