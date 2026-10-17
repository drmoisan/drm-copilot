Set-StrictMode -Version Latest

# Pure helpers for the issue #962 CI change-scope decision and its issue #973 merge-base fallback.
#
# The decision tells ci.yml whether the heavy CI steps must run for the commit under test. Every
# function here works on in-memory values only: no function runs git or gh, reads or writes a file,
# starts a process, or touches the network. scripts/ci/Invoke-CiChangeScope.ps1 performs that I/O and
# passes the results in. Every rule fails closed: anything that cannot be shown to be a docs-only change
# leads to a full run.

function Test-CiChangeScopeEventEligible {
    <#
    .SYNOPSIS
        Returns the reason an event cannot use the docs-only decision, or $null when it can.
    .DESCRIPTION
        Only a pull_request event whose head repository is this repository is eligible. Every other
        event (merge_group, push, workflow_dispatch) and every fork pull request runs the full CI.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $EventName,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $HeadRepository,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Repository
    )

    if ($EventName -cne 'pull_request') {
        return 'EVENT_NOT_PULL_REQUEST'
    }
    # A blank head repository cannot be shown to be this repository, so it is treated as a fork.
    if ([string]::IsNullOrWhiteSpace($HeadRepository) -or -not [string]::Equals($HeadRepository, $Repository, [StringComparison]::OrdinalIgnoreCase)) {
        return 'FORK_PULL_REQUEST'
    }
    return $null
}

function ConvertFrom-CiDocsOnlyPathConfig {
    <#
    .SYNOPSIS
        Parses and validates the docs-only allowlist JSON (config/ci-docs-only-paths.json).
    .DESCRIPTION
        Returns an object with Version, IncludePrefixes, ExcludePrefixes, and Extensions (lower case).
        Throws a CI_DOCS_ONLY_CONFIG_INVALID error that names the first rule the text breaks.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Json
    )

    $prefix = 'CI_DOCS_ONLY_CONFIG_INVALID: '
    if ([string]::IsNullOrWhiteSpace($Json)) {
        throw ($prefix + 'malformed JSON')
    }
    try {
        $parsed = ConvertFrom-Json -InputObject $Json -ErrorAction Stop
    }
    catch {
        throw ($prefix + 'malformed JSON')
    }
    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) {
        throw ($prefix + 'malformed JSON')
    }
    $properties = $parsed.PSObject.Properties

    $version = $properties['version']
    if ($null -eq $version -or -not ($version.Value -is [int] -or $version.Value -is [long]) -or $version.Value -ne 1) {
        throw ($prefix + 'version must be 1')
    }

    # include_prefixes must hold at least one non-blank string; an empty list would allow nothing and
    # signals a broken file.
    $include = $properties['include_prefixes']
    if ($null -eq $include -or $include.Value -isnot [array] -or @($include.Value).Count -eq 0 -or @($include.Value | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
        throw ($prefix + 'include_prefixes must be a non-empty array of non-blank strings')
    }

    # exclude_prefixes may be empty, but every entry must be a non-blank string.
    $exclude = $properties['exclude_prefixes']
    if ($null -eq $exclude -or $exclude.Value -isnot [array] -or @($exclude.Value | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
        throw ($prefix + 'exclude_prefixes must be an array of non-blank strings')
    }

    $extensions = $properties['extensions']
    if ($null -eq $extensions -or $extensions.Value -isnot [array] -or @($extensions.Value).Count -eq 0) {
        throw ($prefix + 'extensions must be a non-empty array')
    }
    # Every extension must start with a dot so that it compares against the text from the last dot of a name.
    foreach ($extension in @($extensions.Value)) {
        if ($extension -isnot [string] -or -not $extension.StartsWith('.', [StringComparison]::Ordinal)) {
            throw ($prefix + "extension '$extension' must start with '.'")
        }
    }

    return [pscustomobject]@{
        Version         = 1
        IncludePrefixes = [string[]]@($include.Value)
        ExcludePrefixes = [string[]]@($exclude.Value)
        Extensions      = [string[]]@($extensions.Value | ForEach-Object { $_.ToLowerInvariant() })
    }
}

function Test-CiDocsOnlyPath {
    <#
    .SYNOPSIS
        Returns $true when one repository-relative path is on the docs-only allowlist.
    .DESCRIPTION
        Rejects blank paths, backslashes, a leading slash, and any '..' segment before the prefix
        checks. Prefixes compare ordinally (case-sensitive); the extension compares case-insensitively.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Path,
        [Parameter(Mandatory = $true)][pscustomobject] $Config
    )

    # Structural rejections come first so that no prefix test can be bypassed by an unusual spelling.
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    if ($Path.Contains([string][char]92)) { return $false }
    if ($Path.StartsWith('/', [StringComparison]::Ordinal)) { return $false }
    $segments = $Path.Split('/')
    if ($segments -ccontains '..') { return $false }

    $included = $false
    foreach ($includePrefix in $Config.IncludePrefixes) {
        if ($Path.StartsWith($includePrefix, [StringComparison]::Ordinal)) {
            $included = $true
            break
        }
    }
    if (-not $included) { return $false }
    foreach ($excludePrefix in $Config.ExcludePrefixes) {
        if ($Path.StartsWith($excludePrefix, [StringComparison]::Ordinal)) { return $false }
    }

    # The extension is the text from the last dot of the last segment; a dot at index 0 (a dot file)
    # does not count as an extension.
    $leaf = $segments[$segments.Count - 1]
    $dot = $leaf.LastIndexOf('.')
    if ($dot -lt 1) { return $false }
    $extension = $leaf.Substring($dot).ToLowerInvariant()
    return ($Config.Extensions -ccontains $extension)
}

function ConvertFrom-CiNulPathList {
    <#
    .SYNOPSIS
        Splits git diff -z output into paths.
    .DESCRIPTION
        Returns Valid = $true with no paths for empty text. Text that does not end in NUL, or that holds
        an empty entry, is not git diff -z output and is returned with Valid = $false.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Text
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return [pscustomobject]@{ Valid = $true; Paths = [string[]]@() }
    }
    # The trailing character is compared as a char: a culture-aware string comparison ignores NUL.
    if ($Text[$Text.Length - 1] -ne [char]0) {
        return [pscustomobject]@{ Valid = $false; Paths = [string[]]@() }
    }
    $entries = $Text.Substring(0, $Text.Length - 1).Split([char]0)
    if (@($entries | Where-Object { $_.Length -eq 0 }).Count -gt 0) {
        return [pscustomobject]@{ Valid = $false; Paths = [string[]]@() }
    }
    return [pscustomobject]@{ Valid = $true; Paths = [string[]]$entries }
}

function Get-CiChangeScopePathDecision {
    <#
    .SYNOPSIS
        Returns the full-run reason for a set of changed paths, or $null when every path is docs-only.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Paths,
        [Parameter(Mandatory = $true)][pscustomobject] $Config
    )

    if ($Paths.Count -eq 0) {
        return 'EMPTY_DIFF'
    }
    # The first rejected path in input order is reported so that the log names a concrete cause.
    foreach ($path in $Paths) {
        if (-not (Test-CiDocsOnlyPath -Path $path -Config $Config)) {
            return "NON_ALLOWLISTED_PATH: $path"
        }
    }
    return $null
}

function Select-CiGreenBaseCandidates {
    <#
    .SYNOPSIS
        Selects the successful ci.yml runs that may serve as the green base, newest first.
    .DESCRIPTION
        Parses the GitHub Actions runs payload and keeps a run only when it is not the current run, its
        conclusion is success, its head repository is this repository, and it has a head SHA. Throws
        CI_RUN_LIST_INVALID when the payload is not a run list.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #962 spec.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $RunsJson,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $CurrentRunId,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Repository
    )

    if ([string]::IsNullOrWhiteSpace($RunsJson)) {
        throw 'CI_RUN_LIST_INVALID: malformed JSON'
    }
    try {
        $payload = ConvertFrom-Json -InputObject $RunsJson -ErrorAction Stop
    }
    catch {
        throw 'CI_RUN_LIST_INVALID: malformed JSON'
    }
    if ($payload -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'CI_RUN_LIST_INVALID: malformed JSON'
    }
    $runsProperty = $payload.PSObject.Properties['workflow_runs']
    if ($null -eq $runsProperty) {
        throw 'CI_RUN_LIST_INVALID: workflow_runs is missing'
    }

    # Keep only runs that can be a base; properties are read through PSObject so that a missing field
    # excludes the run instead of failing under strict mode.
    $candidates = foreach ($run in @($runsProperty.Value)) {
        if ($run -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $fields = $run.PSObject.Properties
        if ($null -eq $fields['id'] -or $null -eq $fields['conclusion'] -or $null -eq $fields['head_sha'] -or $null -eq $fields['head_repository']) { continue }
        $id = [string]$fields['id'].Value
        $headSha = [string]$fields['head_sha'].Value
        $headRepository = $fields['head_repository'].Value
        $headName = ''
        if ($headRepository -is [System.Management.Automation.PSCustomObject] -and $null -ne $headRepository.PSObject.Properties['full_name']) {
            $headName = [string]$headRepository.PSObject.Properties['full_name'].Value
        }
        if ($id -ceq $CurrentRunId) { continue }
        if ([string]$fields['conclusion'].Value -cne 'success') { continue }
        if (-not [string]::Equals($headName, $Repository, [StringComparison]::OrdinalIgnoreCase)) { continue }
        if ([string]::IsNullOrWhiteSpace($headSha)) { continue }
        $runNumber = [long]0
        if ($null -ne $fields['run_number']) { $runNumber = [long]$fields['run_number'].Value }
        [pscustomobject]@{ Id = $id; RunNumber = $runNumber; HeadSha = $headSha }
    }
    $candidates | Sort-Object -Property RunNumber -Descending
}

function Test-CiFullRunMarker {
    <#
    .SYNOPSIS
        Returns $true when a run's jobs payload holds the marker job with conclusion success.
    .DESCRIPTION
        The marker job ('CI full run') runs only when the heavy CI steps run, so a run whose marker
        succeeded is a full green run. Throws CI_JOB_LIST_INVALID when the payload is not a job list.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $JobsJson,
        [string] $MarkerName = 'CI full run'
    )

    if ([string]::IsNullOrWhiteSpace($JobsJson)) {
        throw 'CI_JOB_LIST_INVALID: malformed JSON'
    }
    try {
        $payload = ConvertFrom-Json -InputObject $JobsJson -ErrorAction Stop
    }
    catch {
        throw 'CI_JOB_LIST_INVALID: malformed JSON'
    }
    if ($payload -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'CI_JOB_LIST_INVALID: malformed JSON'
    }
    $jobsProperty = $payload.PSObject.Properties['jobs']
    if ($null -eq $jobsProperty) {
        throw 'CI_JOB_LIST_INVALID: jobs is missing'
    }

    # Any one marker job with conclusion success is enough; a skipped or failed marker does not count.
    foreach ($job in @($jobsProperty.Value)) {
        if ($job -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $fields = $job.PSObject.Properties
        if ($null -eq $fields['name'] -or $null -eq $fields['conclusion']) { continue }
        if ([string]$fields['name'].Value -ceq $MarkerName -and [string]$fields['conclusion'].Value -ceq 'success') {
            return $true
        }
    }
    return $false
}

function Test-CiMergeBaseFallbackApplicable {
    <#
    .SYNOPSIS
        Returns $true when a full-run reason may fall back to the pull request's merge base (issue #973).
    .DESCRIPTION
        Only the reasons that mean the branch has no usable green base fall back: NO_FULL_GREEN_RUN,
        BASE_NOT_PRESENT, and BASE_NOT_ANCESTOR. The fallback applies only to a pull request whose base ref
        is exactly 'main'. Both comparisons are case-sensitive. Unreadable run or job data and a failed
        ancestry check stay full runs.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $PrimaryReason,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $BaseRef
    )

    $fallbackReasons = @('NO_FULL_GREEN_RUN', 'BASE_NOT_PRESENT', 'BASE_NOT_ANCESTOR')
    return (($fallbackReasons -ccontains $PrimaryReason) -and ($BaseRef -ceq 'main'))
}

function ConvertFrom-CiMergeBaseOutput {
    <#
    .SYNOPSIS
        Returns the SHA printed by git merge-base, or an empty string when the output is not one full SHA.
    .DESCRIPTION
        At most one trailing LF is removed. The remaining text must be exactly 40 (SHA-1) or 64 (SHA-256)
        lower-case hexadecimal characters. Empty, multi-line, short, upper-case, padded, or non-hex output
        returns an empty string, which the caller treats as an unresolved merge base.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text
    )

    $candidate = $Text
    if ($candidate.EndsWith("`n", [StringComparison]::Ordinal)) {
        $candidate = $candidate.Substring(0, $candidate.Length - 1)
    }
    # \A and \z anchor the whole text; unlike $, \z does not admit a trailing newline.
    if ($candidate -cmatch '\A(?:[0-9a-f]{40}|[0-9a-f]{64})\z') {
        return $candidate
    }
    return ''
}

function New-CiChangeScopeDecision {
    <#
    .SYNOPSIS
        Builds the decision object and the three texts the entry script publishes.
    .DESCRIPTION
        Code is 'true' (run the heavy steps) or 'false' (skip them). code=false is only valid with a
        DOCS_ONLY_SINCE_ reason, so no other path can produce a skip.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the name is fixed by the issue #962 spec.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][bool] $Code,
        [Parameter(Mandatory = $true)][string] $Reason,
        [AllowEmptyString()][string] $BaseSha = ''
    )

    if (-not $Code -and -not $Reason.StartsWith('DOCS_ONLY_SINCE_', [StringComparison]::Ordinal)) {
        throw 'CI_CHANGE_SCOPE_DECISION_INVALID: code=false requires a DOCS_ONLY_SINCE_ reason'
    }
    $codeText = 'true'
    if (-not $Code) { $codeText = 'false' }
    $baseText = $BaseSha
    if ([string]::IsNullOrWhiteSpace($BaseSha)) { $baseText = 'none' }

    return [pscustomobject]@{
        Code        = $codeText
        Reason      = $Reason
        BaseSha     = $BaseSha
        OutputLine  = "code=$codeText"
        LogLine     = "code=$codeText reason=$Reason"
        SummaryText = "Change scope: code=$codeText; reason=$Reason; base=$baseText"
    }
}

Export-ModuleMember -Function @(
    'Test-CiChangeScopeEventEligible'
    'ConvertFrom-CiDocsOnlyPathConfig'
    'Test-CiDocsOnlyPath'
    'ConvertFrom-CiNulPathList'
    'Get-CiChangeScopePathDecision'
    'Select-CiGreenBaseCandidates'
    'Test-CiFullRunMarker'
    'Test-CiMergeBaseFallbackApplicable'
    'ConvertFrom-CiMergeBaseOutput'
    'New-CiChangeScopeDecision'
)
# Changes to this module fall outside the docs-only allowlist, so they always start a full CI run (issue #962, proof step P3).
