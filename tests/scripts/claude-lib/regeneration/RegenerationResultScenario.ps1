<#
.SYNOPSIS
    Test support for the Invoke-RegenerationPath suites (issue #1156).

.DESCRIPTION
    Functions only. Maps each scenario name of RegenerationResultTable.psd1 to
    entry-point arguments, in-memory config text, scripted git responses keyed by
    exact argv and occurrence index, and scripted process exit codes, and registers
    Pester mocks of Read-RegenerationConfigText, Invoke-RegenerationGitExe, and
    Invoke-RegenerationProcess that replay them. A git response is a string
    (exit 0 with that output), an integer (that exit code with empty output), or
    THROW; a process response is an integer exit code or THROW. The last response
    of a list repeats for later occurrences. Resolve-RegenerationExpectedCell turns
    a legend token of the table into its fixture value. No file, process, or clock
    is touched; the clock is a counting scriptblock over one fixed UTC value.
#>

function Get-RegenerationScenarioFixture {
    <#
    .SYNOPSIS
        Return the fixed values the scenarios and the legend tokens share.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        ClockValue   = [datetime]::new(2026, 11, 9, 22, 0, 0, [System.DateTimeKind]::Utc)
        ClockUtc     = '2026-11-09T22:00:00Z'
        MergeRef     = 'origin/epic/x'
        Trigger      = 'integration_sync'
        HeadSha      = 'feature-head-sha'
        MergeHeadSha = 'merge-head-sha'
        BaseSha      = 'base-sha'
        Run1Exit     = 4
        Run2Exit     = 5
        CheckExit    = 6
        UnitGateExit = 7
    }
}

function Get-RegenerationScenarioConfigText {
    <#
    .SYNOPSIS
        Return the in-memory config text of one config state ($null for an absent file).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Kind)

    $command = '"command":["gen-tool","--write"],"paths":["gen/**"]'
    switch -CaseSensitive ($Kind) {
        'absent' { return $null }
        'key-absent' { return '{"version":1}' }
        'null' { return '{"version":1,"regeneration":null}' }
        'invalid' { return '{"version":1,"regeneration":{"command":[],"paths":["/abs"]}}' }
        'valid' { return "{`"version`":1,`"regeneration`":{$command}}" }
        'check' { return "{`"version`":1,`"regeneration`":{$command,`"idempotency_check`":[`"check-tool`"]}}" }
        'unit' { return "{`"version`":1,`"regeneration`":{$command,`"unit_gate`":[[`"ut-a`"],[`"ut-b`"]]}}" }
    }
    throw "Unknown config kind '$Kind'"
}

function Get-RegenerationScenarioBaseResponse {
    <#
    .SYNOPSIS
        Return the base git and process responses of the Merge or Tip fixture.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Flow)

    $nul = [string] [char] 0
    $process = @{ 'gen-tool --write' = @(0); 'check-tool' = @(0); 'ut-a' = @(0); 'ut-b' = @(0) }
    if ($Flow -ceq 'Tip') {
        $git = @{
            'rev-parse -q --verify MERGE_HEAD'            = @(1)
            'status --porcelain -z'                       = @('')
            'diff --name-only -z'                         = @("gen/a.json$nul")
            'ls-files --others --exclude-standard -z'     = @("gen/new.json$nul")
            'hash-object -- gen/a.json'                   = @('blob-a')
            'hash-object -- gen/new.json'                 = @('blob-new')
            'hash-object -- gen/extra.json'               = @('blob-extra')
            'hash-object -- src/x.ps1'                    = @('blob-x')
            'hash-object -- stray.txt'                    = @('blob-stray')
            'checkout -- gen/a.json'                      = @('')
            'checkout -- gen/a.json src/x.ps1'            = @('')
            'clean -f -q -- gen/new.json'                 = @('')
            'clean -f -q -- gen/new.json stray.txt'       = @('')
            'clean -f -q -- gen/extra.json gen/new.json'  = @('')
        }
        return @{ Git = $git; Process = $process }
    }
    $git = @{
        'merge --no-commit --no-ff origin/epic/x'              = @('')
        'merge --no-commit --no-ff origin/main'                = @('')
        'rev-parse -q --verify MERGE_HEAD'                     = @('merge-head-sha')
        'rev-parse HEAD'                                       = @('feature-head-sha')
        'merge-base --all HEAD MERGE_HEAD'                     = @('base-sha')
        'diff --name-only -z --no-renames base-sha HEAD'       = @("gen/a.json${nul}src/feature.ps1$nul")
        'diff --name-only -z --no-renames base-sha MERGE_HEAD' = @("gen/a.json${nul}src/main.ps1$nul")
        'diff --name-only -z --diff-filter=U'                  = @("gen/a.json$nul")
        'checkout --ours -- gen/a.json'                        = @('')
        'add -- gen/a.json'                                    = @('')
        'diff --name-only -z'                                  = @('', "gen/a.json$nul", '')
        'ls-files --others --exclude-standard -z'              = @('', "gen/new.json$nul", '')
        'add -A -- gen/a.json gen/new.json'                    = @('')
        'diff --cached --name-only -z --no-renames HEAD'       = @("gen/a.json${nul}gen/new.json${nul}src/main.ps1$nul")
        'diff --cached --name-only -z --no-renames MERGE_HEAD' = @("gen/a.json${nul}gen/new.json${nul}src/feature.ps1$nul")
        'merge --abort'                                        = @('')
    }
    return @{ Git = $git; Process = $process }
}

function New-RegenerationScenarioAlternative {
    <#
    .SYNOPSIS
        Return one scenario alternative: arguments, config kind, and response overrides.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory test builder.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Arguments,
        [string] $Config = 'valid',
        [hashtable] $Git = @{},
        [hashtable] $Process = @{}
    )

    return @{ Arguments = $Arguments; Config = $Config; Git = $Git; Process = $Process }
}

function Get-RegenerationScenarioUsageAlternative {
    <#
    .SYNOPSIS
        Return the alternatives of one usage-error scenario.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    $merge = @{ Mode = 'Merge'; MergeRef = 'origin/epic/x'; Trigger = 'integration_sync' }
    $modeName = @{ tip = 'Tip'; validate = 'Validate' }
    $configPath = @{ slash = '/etc/regeneration.json'; drive = 'C:/regeneration.json'; parent = 'config/../regeneration.json' }
    $list = switch -CaseSensitive -Regex ($Name) {
        '^usage-mode-omitted$' { , @(@{}) }
        '^usage-mode-unknown$' { , @(@{ Mode = 'Deploy' }, @{ Mode = 'merge' }, @{ Mode = 'tip' }) }
        '^usage-merge-ref-missing$' { , @(@{ Mode = 'Merge'; Trigger = 'integration_sync' }, @{ Mode = 'Merge'; MergeRef = ''; Trigger = 'integration_sync' }) }
        '^usage-merge-trigger-missing$' { , @(@{ Mode = 'Merge'; MergeRef = 'origin/epic/x' }, @{ Mode = 'Merge'; MergeRef = 'origin/epic/x'; Trigger = '' }) }
        '^usage-merge-trigger-unknown$' { , @(@{ Mode = 'Merge'; MergeRef = 'origin/epic/x'; Trigger = 'other' }, @{ Mode = 'Merge'; MergeRef = 'origin/epic/x'; Trigger = 'Main_Sync' }) }
        '^usage-(tip|validate)-merge-ref$' { , @(@{ Mode = $modeName[$Matches[1]]; MergeRef = 'origin/main' }) }
        '^usage-(tip|validate)-trigger$' { , @(@{ Mode = $modeName[$Matches[1]]; Trigger = 'main_sync' }) }
        '^usage-merge-config-(slash|drive|parent)$' { , @(($merge.Clone() + @{ ConfigPath = $configPath[$Matches[1]] })) }
        '^usage-(tip|validate)-config-(slash|drive|parent)$' {
            , @(@{ Mode = $modeName[$Matches[1]]; ConfigPath = $configPath[$Matches[2]] })
        }
    }
    if ($null -eq $list) { throw "Unknown usage scenario '$Name'" }
    return , @($list | ForEach-Object { New-RegenerationScenarioAlternative -Arguments $_ })
}

function Get-RegenerationScenarioDefinition {
    <#
    .SYNOPSIS
        Return the flow and the alternatives of one named scenario.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    if ($Name.StartsWith('usage-')) { return @{ Flow = 'Usage'; Alternatives = (Get-RegenerationScenarioUsageAlternative -Name $Name) } }
    $states = @{ absent = 'absent'; 'key-absent' = 'key-absent'; null = 'null'; invalid = 'invalid'; valid = 'valid' }
    foreach ($flow in @('validate', 'tip', 'merge')) {
        $suffix = $Name.Substring([Math]::Min($Name.Length, $flow.Length + 1))
        if ($Name.StartsWith("$flow-") -and $states.ContainsKey($suffix)) {
            $arguments = Get-RegenerationScenarioFlowArgument -Flow $flow
            return @{ Flow = 'Config'; Alternatives = @(New-RegenerationScenarioAlternative -Arguments $arguments -Config $states[$suffix]) }
        }
    }
    if ($Name.StartsWith('tip-')) { return @{ Flow = 'Tip'; Alternatives = (Get-RegenerationTipScenarioAlternative -Name $Name) } }
    if ($Name.StartsWith('merge-')) { return @{ Flow = 'Merge'; Alternatives = (Get-RegenerationMergeScenarioAlternative -Name $Name) } }
    throw "Unknown scenario '$Name'"
}

function Get-RegenerationScenarioFlowArgument {
    <#
    .SYNOPSIS
        Return the entry-point arguments of a non-usage scenario of one flow.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Flow)

    switch -CaseSensitive ($Flow) {
        'validate' { return @{ Mode = 'Validate' } }
        'tip' { return @{ Mode = 'Tip' } }
        'merge' { return @{ Mode = 'Merge'; MergeRef = 'origin/epic/x'; Trigger = 'integration_sync' } }
    }
    throw "Unknown flow '$Flow'"
}

function Get-RegenerationTipScenarioAlternative {
    <#
    .SYNOPSIS
        Return the alternatives of one Tip scenario.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    throw "Unknown Tip scenario '$Name'"
}

function Get-RegenerationMergeScenarioAlternative {
    <#
    .SYNOPSIS
        Return the alternatives of one Merge scenario.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    throw "Unknown Merge scenario '$Name'"
}

function Get-RegenerationScenarioAlternativeCount {
    <#
    .SYNOPSIS
        Return the number of alternatives of a table row's scenario.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [hashtable] $Row)

    return @((Get-RegenerationScenarioDefinition -Name $Row.Scenario).Alternatives).Count
}

function Get-RegenerationScenarioArgument {
    <#
    .SYNOPSIS
        Return the entry-point arguments of a table row (one alternative).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Row,
        [int] $Alternative = 0
    )

    $definition = Get-RegenerationScenarioDefinition -Name $Row.Scenario
    return $definition.Alternatives[$Alternative].Arguments.Clone()
}

function Register-RegenerationScenarioMock {
    <#
    .SYNOPSIS
        Register the seam mocks of one scenario alternative and return its recording context.

    .OUTPUTS
        PSCustomObject with State (recorded calls and counts), Clock (invocation
        count), and UtcNow (the counting clock scriptblock).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Row,
        [int] $Alternative = 0
    )

    $definition = Get-RegenerationScenarioDefinition -Name $Row.Scenario
    $selected = $definition.Alternatives[$Alternative]
    $flow = if ($selected.Arguments.ContainsKey('Mode') -and $selected.Arguments.Mode -ceq 'Tip') { 'Tip' } else { 'Merge' }
    $base = Get-RegenerationScenarioBaseResponse -Flow $flow
    $git = $base.Git.Clone()
    foreach ($key in $selected.Git.Keys) { $git[$key] = $selected.Git[$key] }
    $process = $base.Process.Clone()
    foreach ($key in $selected.Process.Keys) { $process[$key] = $selected.Process[$key] }

    $state = @{
        Git         = $git
        Process     = $process
        ConfigText  = (Get-RegenerationScenarioConfigText -Kind $selected.Config)
        Calls       = [System.Collections.Generic.List[string]]::new()
        ConfigReads = [System.Collections.Generic.List[string]]::new()
        Occurrence  = @{}
        GitCalls    = 0
        ProcessCalls = 0
    }
    $script:RegenerationScenarioState = $state
    Mock Read-RegenerationConfigText { $script:RegenerationScenarioState.ConfigReads.Add($ConfigPath); return $script:RegenerationScenarioState.ConfigText }
    Mock Invoke-RegenerationGitExe { Resolve-RegenerationScenarioGitResponse -GitArgs $GitArgs }
    Mock Invoke-RegenerationProcess { Resolve-RegenerationScenarioProcessResponse -Argv $Argv }

    $clock = @{ Count = 0; Value = (Get-RegenerationScenarioFixture).ClockValue }
    $utcNow = { $clock.Count++; $clock.Value }.GetNewClosure()
    return [pscustomobject]@{ State = $state; Clock = $clock; UtcNow = $utcNow }
}

function Get-RegenerationScenarioNextResponse {
    <#
    .SYNOPSIS
        Record one call and return its scripted response for the current occurrence.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [string] $Key,
        [Parameter(Mandatory = $true)] [hashtable] $Table
    )

    $state = $script:RegenerationScenarioState
    $state.Calls.Add("$Kind $Key")
    if ($Kind -ceq 'git') { $state.GitCalls++ } else { $state.ProcessCalls++ }
    if (-not $Table.ContainsKey($Key)) { throw "Unscripted $Kind call: $Key" }
    $responses = @($Table[$Key])
    $index = 0
    if ($state.Occurrence.ContainsKey("$Kind $Key")) { $index = [int] $state.Occurrence["$Kind $Key"] }
    $state.Occurrence["$Kind $Key"] = $index + 1
    return $responses[[Math]::Min($index, $responses.Count - 1)]
}

function Resolve-RegenerationScenarioGitResponse {
    <#
    .SYNOPSIS
        Replay the scripted git response for one argv.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string[]] $GitArgs)

    $key = $GitArgs -join ' '
    $response = Get-RegenerationScenarioNextResponse -Kind 'git' -Key $key -Table $script:RegenerationScenarioState.Git
    if ($response -is [int]) { return [pscustomobject]@{ ExitCode = $response; Output = '' } }
    if ($response -ceq 'THROW') { throw "Scripted git failure: $key" }
    return [pscustomobject]@{ ExitCode = 0; Output = [string] $response }
}

function Resolve-RegenerationScenarioProcessResponse {
    <#
    .SYNOPSIS
        Replay the scripted process exit code for one argv.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [string[]] $Argv)

    $key = $Argv -join ' '
    $response = Get-RegenerationScenarioNextResponse -Kind 'process' -Key $key -Table $script:RegenerationScenarioState.Process
    if ($response -ceq 'THROW') { throw "Scripted start failure: $key" }
    return [int] $response
}

function Resolve-RegenerationExpectedCell {
    <#
    .SYNOPSIS
        Resolve one Expected cell of a table row: a JSON literal unchanged, or a legend token.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Row,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object] $Token
    )

    if ($Token -isnot [string] -or -not $Token.StartsWith('@')) { return , $Token }
    $fixture = Get-RegenerationScenarioFixture
    switch -CaseSensitive ($Token) {
        '@Trigger' { return (Get-RegenerationScenarioArgument -Row $Row).Trigger }
        '@ValidatorErrors' { return , [object[]] @((ConvertFrom-RegenerationConfigText -Text (Get-RegenerationScenarioConfigText -Kind 'invalid')).Errors) }
        '@HeadSha' { return $fixture.HeadSha }
        '@MergeHeadSha' { return $fixture.MergeHeadSha }
        '@BaseSha' { return $fixture.BaseSha }
        '@UnmatchedPath' { return , [object[]] @('src/shared.ps1') }
        '@Run1Exit' { return $fixture.Run1Exit }
        '@Run2Exit' { return $fixture.Run2Exit }
        '@CheckExit' { return $fixture.CheckExit }
        '@UnitGateExit' { return $fixture.UnitGateExit }
        '@C1Sorted' { return , [object[]] @('gen/a.json', 'gen/new.json') }
        '@ClockUtc' { return $fixture.ClockUtc }
        '@EventFellBack' { return (Resolve-RegenerationExpectedEvent -Row $Row -Outcome 'fell_back') }
        '@EventRegenerated' { return (Resolve-RegenerationExpectedEvent -Row $Row -Outcome 'regenerated') }
        '@DeltaOutcome' { return (New-RegenerationDeltaReviewOutcome -HeadSha $null -EvidencePath $null) }
        '@EvidenceText' { return (Resolve-RegenerationExpectedEvidenceText -Row $Row) }
    }
    throw "Unknown token '$Token'"
}

function Get-RegenerationExpectedCellMap {
    <#
    .SYNOPSIS
        Resolve the plain cells of a row that the event and evidence builders read.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [hashtable] $Row)

    $map = @{}
    foreach ($key in @('at', 'trigger', 'feature_head_sha', 'merge_head_sha', 'merge_base_sha', 'decision', 'reason',
            'unmatched_paths', 'command_exit_code', 'confined', 'idempotent', 'unit_gate', 'delta_check')) {
        $map[$key] = Resolve-RegenerationExpectedCell -Row $Row -Token $Row.Expected[$key]
    }
    return $map
}

function Resolve-RegenerationExpectedEvent {
    <#
    .SYNOPSIS
        Build the expected event of a row from the row's own cells.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Row,
        [Parameter(Mandatory = $true)] [string] $Outcome
    )

    $cell = Get-RegenerationExpectedCellMap -Row $Row
    return (New-RegenerationEvent -At $cell.at -Trigger $cell.trigger -FeatureHeadSha $cell.feature_head_sha `
            -MergeHeadSha $cell.merge_head_sha -MergeBaseSha $cell.merge_base_sha -Decision $cell.decision -Reason $cell.reason `
            -UnmatchedPaths ([string[]] @($cell.unmatched_paths)) -CommandExitCode $cell.command_exit_code -Confined $cell.confined `
            -Idempotent $cell.idempotent -UnitGate $cell.unit_gate -DeltaCheck $cell.delta_check -Outcome $Outcome `
            -HeadSha $null -EvidencePath $null)
}

function Resolve-RegenerationExpectedEvidenceText {
    <#
    .SYNOPSIS
        Build the expected evidence text of a row from the row's own cells and arguments.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [hashtable] $Row)

    $cell = Get-RegenerationExpectedCellMap -Row $Row
    $arguments = Get-RegenerationScenarioArgument -Row $Row
    $configPath = if ($arguments.ContainsKey('ConfigPath')) { $arguments.ConfigPath } else { $null }
    $command = Get-RegenerationInvocationText -MergeRef $arguments.MergeRef -Trigger $arguments.Trigger -ConfigPath $configPath
    $stamp = ConvertTo-RegenerationStamp -Value (Get-RegenerationScenarioFixture).ClockValue
    return (New-RegenerationEvidenceText -Timestamp $stamp -Command $command -ExitCode 0 -Reason $cell.reason `
            -Confined $cell.confined -Idempotent $cell.idempotent -UnitGate $cell.unit_gate -DeltaCheck $cell.delta_check)
}
