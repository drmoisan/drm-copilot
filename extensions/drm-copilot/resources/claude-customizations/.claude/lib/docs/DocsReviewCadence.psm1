<#
.SYNOPSIS
    Calendar review cadence of documentation pages: the effective review due date of a page and
    the docs-complete DOCS_REVIEW_OVERDUE findings.

.DESCRIPTION
    A page is due for review on its explicit review_due date; without review_due, on last_reviewed
    plus the review_interval_days of the documentation family whose directory covers the page
    (longest directory that prefixes the page path at a '/' boundary, ordinal comparison);
    otherwise it has no due date. Get-DocsReviewOverdueFinding reports one DOCS_REVIEW_OVERDUE
    finding per page whose due date is earlier than the reference date, the UTC calendar date of
    the command instant (Get-DocsReviewReferenceDate). A due date equal to the reference date is
    not overdue. Pages listed in the legacy exclusions, pages without a due date, and pages whose
    review_due is not later than last_reviewed are skipped; the page checker reports the last.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state. Dates are parsed with TryParseExact, the invariant culture and UTC kind. The page
    reader Get-DocsReviewPageFrontMatter reads only through the ReadText scriptblock it is given.

.NOTES
    Issue #1220. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageFrontMatter.psm1') -ErrorAction Stop

$script:DocsReviewDatePattern = '^[0-9]{4}-[0-9]{2}-[0-9]{2}\z'
$script:DocsReviewIssuedAtPattern = '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z\z'
$script:DocsReviewOverdueNextAction = 'Review the page, then update last_reviewed and review_due.'

function Get-DocsReviewMember {
    <#
    .SYNOPSIS
        Returns a table member, or $null when the table is not a dictionary or the key is absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and $Table.Contains($Name)) { return $Table[$Name] }
    return $null
}

function ConvertFrom-DocsReviewDate {
    <#
    .SYNOPSIS
        Returns the UTC-kind [datetime] of a yyyy-MM-dd calendar date, or $null for any other value.
    .DESCRIPTION
        The value must be exactly four, two and two ASCII digits separated by '-' and name a
        calendar date that exists; the parse uses the invariant culture.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param([AllowNull()] [AllowEmptyString()] [string] $Value)

    if ([string]::IsNullOrEmpty($Value) -or $Value -cnotmatch $script:DocsReviewDatePattern) { return $null }
    $parsed = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    if (-not [datetime]::TryParseExact($Value, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, $styles, [ref] $parsed)) { return $null }
    return [datetime]::SpecifyKind($parsed.Date, [System.DateTimeKind]::Utc)
}

function Get-DocsReviewReferenceDate {
    <#
    .SYNOPSIS
        Returns the UTC calendar date of a yyyy-MM-ddTHH:mm:ssZ instant as a UTC-kind [datetime].
    .DESCRIPTION
        IssuedAt is the command instant the validate command already read. Any other value is a
        defect of the caller and throws an error whose text begins with DOCS_REVIEW_CLOCK_INVALID.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $IssuedAt)

    $parsed = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    $valid = $IssuedAt -cmatch $script:DocsReviewIssuedAtPattern -and [datetime]::TryParseExact($IssuedAt, "yyyy-MM-dd'T'HH:mm:ss'Z'", [cultureinfo]::InvariantCulture, $styles, [ref] $parsed)
    if (-not $valid) { throw "DOCS_REVIEW_CLOCK_INVALID: IssuedAt '$IssuedAt' is not a UTC instant of the form yyyy-MM-ddTHH:mm:ssZ." }
    return [datetime]::SpecifyKind($parsed.Date, [System.DateTimeKind]::Utc)
}

function Test-DocsReviewIntervalValue {
    <#
    .SYNOPSIS
        Returns $true when Value is an integer (Int32 or Int64) of at least 1 (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Value)

    return (($Value -is [int]) -or ($Value -is [long])) -and [long] $Value -ge 1
}

function Get-DocsReviewIntervalDays {
    <#
    .SYNOPSIS
        Returns the review_interval_days of the documentation family covering PagePath, or $null.
    .DESCRIPTION
        A family covers the page when its directory, with trailing '/' removed, followed by '/'
        is an ordinal prefix of PagePath; the family with the longest such directory decides.
        Directories are repository-relative, like the page path. The result is $null when no
        family covers the page or when the deciding family has no integer interval of at least 1.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #1220 API contract and names the review_interval_days value.')]
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PagePath,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Family
    )

    $bestLength = -1
    $interval = $null
    foreach ($entry in @($Family)) {
        $directory = Get-DocsReviewMember -Table $entry -Name 'directory'
        if ($directory -isnot [string]) { continue }
        $directory = $directory.TrimEnd('/')
        if ($directory.Length -le $bestLength -or $directory.Length -eq 0) { continue }
        if (-not $PagePath.StartsWith($directory + '/', [System.StringComparison]::Ordinal)) { continue }
        $bestLength = $directory.Length
        $interval = Get-DocsReviewMember -Table $entry -Name 'review_interval_days'
    }
    if (Test-DocsReviewIntervalValue -Value $interval) { return [long] $interval }
    return $null
}

function Get-DocsPageReviewDue {
    <#
    .SYNOPSIS
        Returns @{ DueDate; Source } for one page: the explicit review_due, or last_reviewed plus the family interval.
    .DESCRIPTION
        Source is 'review_due' when the page carries a valid review_due date (it wins over any
        family interval), 'interval' when the date is derived from a valid last_reviewed and the
        interval of the covering family, and $null with a $null DueDate otherwise. A page whose
        review_due is present but not a valid date has no due date.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $FrontMatter,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PagePath,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Family
    )

    if ($FrontMatter.Contains('review_due')) {
        $value = $FrontMatter['review_due']
        $explicit = if ($value -is [string]) { ConvertFrom-DocsReviewDate -Value $value } else { $null }
        if ($null -eq $explicit) { return @{ DueDate = $null; Source = $null } }
        return @{ DueDate = $explicit; Source = 'review_due' }
    }
    $reviewed = Get-DocsReviewMember -Table $FrontMatter -Name 'last_reviewed'
    $last = if ($reviewed -is [string]) { ConvertFrom-DocsReviewDate -Value $reviewed } else { $null }
    $interval = Get-DocsReviewIntervalDays -PagePath $PagePath -Family $Family
    if ($null -eq $last -or $null -eq $interval) { return @{ DueDate = $null; Source = $null } }
    return @{ DueDate = $last.AddDays([double] $interval); Source = 'interval' }
}

function Get-DocsReviewPageFrontMatter {
    <#
    .SYNOPSIS
        Returns an ordinal hashtable from each .md page path to its parsed front matter.
    .DESCRIPTION
        Each path ending in '.md' is read once through ReadText and parsed with
        ConvertFrom-DocsPageFrontMatter; a page without a front-matter block or with a parse
        finding is omitted. An exception thrown by ReadText propagates to the caller.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Page paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $PagePath,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadText
    )

    $result = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($page in @($PagePath)) {
        if ([string]::IsNullOrEmpty($page) -or -not $page.EndsWith('.md', [System.StringComparison]::Ordinal) -or $result.ContainsKey($page)) { continue }
        $parsed = ConvertFrom-DocsPageFrontMatter -Text ([string] (& $ReadText $page)) -PagePath $page
        if ($parsed.Value -is [System.Collections.IDictionary]) { $result[$page] = $parsed.Value }
    }
    return $result
}

function Test-DocsReviewOrderingInvalid {
    <#
    .SYNOPSIS
        Returns $true when both dates are valid calendar dates and review_due is not later than last_reviewed (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $FrontMatter)

    $due = Get-DocsReviewMember -Table $FrontMatter -Name 'review_due'
    $reviewed = Get-DocsReviewMember -Table $FrontMatter -Name 'last_reviewed'
    if ($due -isnot [string] -or $reviewed -isnot [string]) { return $false }
    $dueDate = ConvertFrom-DocsReviewDate -Value $due
    $reviewedDate = ConvertFrom-DocsReviewDate -Value $reviewed
    return $null -ne $dueDate -and $null -ne $reviewedDate -and $dueDate -le $reviewedDate
}

function Get-DocsReviewOverdueFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_REVIEW_OVERDUE finding per page whose effective due date is earlier than ReferenceDate.
    .DESCRIPTION
        PageFrontMatter maps a page path to its parsed front matter (Get-DocsReviewPageFrontMatter).
        Pages are visited in ordinal path order. The finding's artifact_path is the page, its
        pointer /review_due for an explicit due date and /last_reviewed for a derived one, and its
        message names the due date, its source and the reference date. Pages in LegacyExclusion,
        pages without a due date, and pages whose review_due is not later than last_reviewed are
        skipped.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [System.Collections.IDictionary] $PageFrontMatter,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Family,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $LegacyExclusion,
        [Parameter(Mandatory = $true)] [datetime] $ReferenceDate,
        [ValidateSet('warning', 'error')] [string] $Severity = 'warning'
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    if ($null -eq $PageFrontMatter) { return , $findings.ToArray() }
    $excluded = [System.Collections.Generic.HashSet[string]]::new([string[]] @($LegacyExclusion | Where-Object { $null -ne $_ }), [System.StringComparer]::Ordinal)
    [string[]] $pages = @($PageFrontMatter.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($pages, [System.StringComparer]::Ordinal)
    $reference = $ReferenceDate.Date
    $referenceText = $reference.ToString('yyyy-MM-dd', [cultureinfo]::InvariantCulture)
    foreach ($page in $pages) {
        $frontMatter = $PageFrontMatter[$page]
        if ($excluded.Contains($page) -or $frontMatter -isnot [System.Collections.IDictionary]) { continue }
        $due = Get-DocsPageReviewDue -FrontMatter $frontMatter -PagePath $page -Family $Family
        if ($null -eq $due.DueDate -or $due.DueDate -ge $reference) { continue }
        if (Test-DocsReviewOrderingInvalid -FrontMatter $frontMatter) { continue }
        $pointer = if ($due.Source -ceq 'review_due') { '/review_due' } else { '/last_reviewed' }
        $dueText = ([datetime] $due.DueDate).ToString('yyyy-MM-dd', [cultureinfo]::InvariantCulture)
        $message = "The review of $page was due on $dueText (source $($due.Source)) and is overdue at the reference date $referenceText."
        $findings.Add((New-DocsFinding -Code 'DOCS_REVIEW_OVERDUE' -Severity $Severity -Pointer $pointer -ArtifactPath $page -Message $message -NextAction $script:DocsReviewOverdueNextAction))
    }
    return , $findings.ToArray()
}

function Get-DocsReviewOverdueSeverity {
    <#
    .SYNOPSIS
        Returns 'error' when completion_gates.docs_complete.block_overdue_review is the boolean $true, else 'warning'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [System.Collections.IDictionary] $Gate)

    $value = Get-DocsReviewMember -Table $Gate -Name 'block_overdue_review'
    if ($value -is [bool] -and $value) { return 'error' }
    return 'warning'
}

Export-ModuleMember -Function `
    ConvertFrom-DocsReviewDate, `
    Get-DocsReviewReferenceDate, `
    Get-DocsReviewIntervalDays, `
    Get-DocsPageReviewDue, `
    Get-DocsReviewPageFrontMatter, `
    Get-DocsReviewOverdueFinding, `
    Get-DocsReviewOverdueSeverity
