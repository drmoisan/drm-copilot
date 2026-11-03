<#
.SYNOPSIS
    Pure admission decisions for /parallel-add and /parallel-plan (issue #1047).

.DESCRIPTION
    Holds the pure functions behind the admission helper
    .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1: the closed-run
    guard, preparation-stage inference from branch files, preparation-receipt
    selection, the staleness verdict over the files a plan cites, complexity-band
    resolution, and the admission decision that maps a stage and a verdict to the
    next action.

    Every function is pure: no filesystem, subprocess, network, or clock access,
    and no input is mutated. The entry script owns every git call, file read, and
    clock read, and passes their results in as values. Path matching reuses
    Get-PlanPaths (.claude/lib/blast-radius/BlastRadius.psm1) and Test-EntryOverlap
    (.claude/lib/blast-radius/BlastRadiusGlob.psm1) rather than re-deriving them.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../blast-radius/BlastRadiusGlob.psm1') -Force -ErrorAction Stop

# The run-mode members of the parallel surface (rule `## Enum Ownership`).
$script:ModeOpen = 'open'
$script:ModeClosed = 'closed'
$script:RunMode = @($script:ModeOpen, $script:ModeClosed)

function Get-ParallelAdmissionMapValue {
    <#
    .SYNOPSIS
        Return the value stored under Key in a dictionary, or null when the key or the map is absent.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][object] $Map, [string] $Key)

    if ($Map -isnot [System.Collections.IDictionary]) { return $null }
    if (-not $Map.Contains($Key)) { return $null }
    return $Map[$Key]
}

function New-ParallelAdmissionRunVerdict {
    <#
    .SYNOPSIS
        Build the closed-run guard result record.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure record constructor; no state is changed.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([bool] $Open, [string] $Detail, [AllowNull()][object] $ManifestMode, [AllowNull()][object] $CheckpointMode)

    return [pscustomobject]@{ Open = $Open; Detail = $Detail; ManifestMode = $ManifestMode; CheckpointMode = $CheckpointMode }
}

function Test-ParallelAdmissionRunOpen {
    <#
    .SYNOPSIS
        Decide whether a parallel run accepts an addition.

    .DESCRIPTION
        The run is open only when the manifest mode and the checkpoint `mode` are
        both `open` and no `mutations[]` entry has `op` equal to `close`. Every
        other case, including a missing or unreadable mode on either side and two
        modes that disagree, is closed. The check fails closed, and Detail names
        the reason.

    .PARAMETER ManifestMode
        The manifest mode, as printed by validate-parallel-manifest.sh --print-mode.

    .PARAMETER Checkpoint
        The parsed parallel-orchestrator checkpoint (a dictionary), or null when it
        could not be read.

    .OUTPUTS
        pscustomobject with Open, Detail, ManifestMode, and CheckpointMode.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $ManifestMode, [AllowNull()][object] $Checkpoint)

    $manifest = if ($null -eq $ManifestMode) { '' } else { $ManifestMode.Trim() }
    if ($script:RunMode -cnotcontains $manifest) {
        return New-ParallelAdmissionRunVerdict -Open $false -Detail "manifest mode is missing or unreadable ('$manifest')" -ManifestMode $manifest -CheckpointMode $null
    }
    if ($Checkpoint -isnot [System.Collections.IDictionary]) {
        return New-ParallelAdmissionRunVerdict -Open $false -Detail 'checkpoint is missing or is not a JSON object' -ManifestMode $manifest -CheckpointMode $null
    }
    $checkpointMode = Get-ParallelAdmissionMapValue -Map $Checkpoint -Key 'mode'
    if ($checkpointMode -isnot [string] -or $script:RunMode -cnotcontains $checkpointMode) {
        return New-ParallelAdmissionRunVerdict -Open $false -Detail 'checkpoint mode is missing or unreadable' -ManifestMode $manifest -CheckpointMode $checkpointMode
    }
    if ($manifest -cne $checkpointMode) {
        return New-ParallelAdmissionRunVerdict -Open $false -Detail "manifest mode '$manifest' disagrees with checkpoint mode '$checkpointMode'" -ManifestMode $manifest -CheckpointMode $checkpointMode
    }
    if ($manifest -ceq $script:ModeClosed) {
        return New-ParallelAdmissionRunVerdict -Open $false -Detail 'manifest and checkpoint mode are closed' -ManifestMode $manifest -CheckpointMode $checkpointMode
    }
    # Both values agree on open here.
    $mutations = Get-ParallelAdmissionMapValue -Map $Checkpoint -Key 'mutations'
    foreach ($mutation in @($mutations)) {
        if ((Get-ParallelAdmissionMapValue -Map $mutation -Key 'op') -ceq 'close') {
            return New-ParallelAdmissionRunVerdict -Open $false -Detail 'a close mutation is recorded' -ManifestMode $manifest -CheckpointMode $checkpointMode
        }
    }
    return New-ParallelAdmissionRunVerdict -Open $true -Detail 'run is open' -ManifestMode $manifest -CheckpointMode $checkpointMode
}

function Get-ParallelAdmissionText {
    <#
    .SYNOPSIS
        Return the text recorded for Path in FileText, or the empty string when none is recorded.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][System.Collections.IDictionary] $FileText, [string] $Path)

    $value = Get-ParallelAdmissionMapValue -Map $FileText -Key $Path
    if ($null -eq $value) { return '' }
    return [string]$value
}

function Get-ParallelAdmissionLine {
    <#
    .SYNOPSIS
        Split text into lines, accepting LF, CRLF, and CR terminators.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([AllowEmptyString()][string] $Text)

    return , [string[]]@($Text -split "`r`n|`n|`r")
}

function Test-ParallelAdmissionSpecReady {
    <#
    .SYNOPSIS
        Report whether spec text is non-blank and carries no whole-line template placeholder.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowEmptyString()][string] $Text, [AllowEmptyCollection()][string[]] $SpecPlaceholderLine)

    if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
    $placeholder = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($line in @($SpecPlaceholderLine)) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { [void]$placeholder.Add($line.Trim()) }
    }
    foreach ($line in (Get-ParallelAdmissionLine -Text $Text)) {
        if ($placeholder.Contains($line.Trim())) { return $false }
    }
    return $true
}

function Test-ParallelAdmissionPlanReady {
    <#
    .SYNOPSIS
        Report whether plan text carries at least one task line that is not a template task line.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowEmptyString()][string] $Text, [AllowEmptyCollection()][string[]] $PlanTemplateTaskLine)

    $template = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($line in @($PlanTemplateTaskLine)) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { [void]$template.Add($line.TrimEnd()) }
    }
    foreach ($line in (Get-ParallelAdmissionLine -Text $Text)) {
        $trimmed = $line.TrimEnd()
        if ($trimmed -match '^- \[[ x]\] \[P\d+-T\d+\]' -and -not $template.Contains($trimmed)) { return $true }
    }
    return $false
}

function Get-ParallelAdmissionInferredStage {
    <#
    .SYNOPSIS
        Infer how far an item's branch is prepared from the files under its feature folder.

    .DESCRIPTION
        Applies the stage-inference rules of the feature spec `## Data & State`.
        The highest satisfied stage wins and each stage requires the one before it:

        - research: a non-blank .md file under <folder>/research/;
        - spec: <folder>/spec.md is non-blank and carries none of the template
          placeholder lines;
        - plan: the lexicographically greatest <folder>/plan.*.md carries at least
          one task line that is not a template task line;
        - cleared: a file under <folder>/evidence/ whose name contains `preflight`
          and whose text contains `PREFLIGHT: ALL CLEAR` was committed at or after
          the plan file (decision D4). Otherwise the stage is capped at plan.

    .PARAMETER TreePath
        Repository-relative file paths on the branch (git ls-tree output).

    .PARAMETER FileText
        Path-to-text map for the files the rules read; a missing entry reads as empty.

    .PARAMETER CommitTime
        Path-to-epoch-seconds map of each file's last commit time on the branch.

    .PARAMETER SpecPlaceholderLine
        Whole-line placeholder lines of the spec template.

    .PARAMETER PlanTemplateTaskLine
        Task lines of the plan template.

    .PARAMETER FeatureFolder
        The item's repository-relative feature folder.

    .OUTPUTS
        pscustomobject with stage, research_path, spec_path, and plan_path; a path
        is null when its stage is not satisfied.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyCollection()][string[]] $TreePath = @(),
        [AllowNull()][System.Collections.IDictionary] $FileText,
        [AllowNull()][System.Collections.IDictionary] $CommitTime,
        [AllowEmptyCollection()][string[]] $SpecPlaceholderLine = @(),
        [AllowEmptyCollection()][string[]] $PlanTemplateTaskLine = @(),
        [string] $FeatureFolder
    )

    if ([string]::IsNullOrWhiteSpace($FeatureFolder)) { throw 'Get-ParallelAdmissionInferredStage requires -FeatureFolder.' }
    $prefix = $FeatureFolder.Trim().TrimEnd('/') + '/'
    $paths = @(@($TreePath) | Where-Object { $_ -and $_.StartsWith($prefix, [System.StringComparison]::Ordinal) } | Sort-Object -CaseSensitive)
    $result = [pscustomobject]@{ stage = 'none'; research_path = $null; spec_path = $null; plan_path = $null }

    $research = @($paths | Where-Object {
            $_.StartsWith($prefix + 'research/', [System.StringComparison]::Ordinal) -and $_.EndsWith('.md', [System.StringComparison]::Ordinal) -and
            -not [string]::IsNullOrWhiteSpace((Get-ParallelAdmissionText -FileText $FileText -Path $_))
        })
    if ($research.Count -eq 0) { return $result }
    $result.stage = 'research'
    $result.research_path = $research[-1]

    $specPath = $prefix + 'spec.md'
    if ($paths -cnotcontains $specPath -or -not (Test-ParallelAdmissionSpecReady -Text (Get-ParallelAdmissionText -FileText $FileText -Path $specPath) -SpecPlaceholderLine $SpecPlaceholderLine)) { return $result }
    $result.stage = 'spec'
    $result.spec_path = $specPath

    $plans = @($paths | Where-Object {
            $name = $_.Substring($prefix.Length)
            -not $name.Contains('/') -and $name.StartsWith('plan.', [System.StringComparison]::Ordinal) -and $name.EndsWith('.md', [System.StringComparison]::Ordinal)
        })
    if ($plans.Count -eq 0) { return $result }
    $planPath = $plans[-1]
    if (-not (Test-ParallelAdmissionPlanReady -Text (Get-ParallelAdmissionText -FileText $FileText -Path $planPath) -PlanTemplateTaskLine $PlanTemplateTaskLine)) { return $result }
    $result.stage = 'plan'
    $result.plan_path = $planPath

    $planTime = Get-ParallelAdmissionMapValue -Map $CommitTime -Key $planPath
    if ($null -eq $planTime) { return $result }
    foreach ($path in $paths) {
        if (-not $path.StartsWith($prefix + 'evidence/', [System.StringComparison]::Ordinal)) { continue }
        $name = $path.Substring($path.LastIndexOf('/') + 1)
        if (-not $name.Contains('preflight')) { continue }
        if (-not (Get-ParallelAdmissionText -FileText $FileText -Path $path).Contains('PREFLIGHT: ALL CLEAR')) { continue }
        $evidenceTime = Get-ParallelAdmissionMapValue -Map $CommitTime -Key $path
        if ($null -ne $evidenceTime -and [long]$evidenceTime -ge [long]$planTime) {
            $result.stage = 'cleared'
            return $result
        }
    }
    return $result
}

function Select-ParallelAdmissionReceipt {
    <#
    .SYNOPSIS
        Select the newest preparation receipt by file name.

    .DESCRIPTION
        Returns the path whose file name matches preparation-receipt.*.json and is
        lexicographically greatest under ordinal comparison (decision D8). The
        fixed-width UTC stamp makes that the most recently written receipt. Older
        receipts are superseded, never deleted.

    .OUTPUTS
        System.String, or null when no path matches.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyCollection()][string[]] $ReceiptPath = @())

    $selected = $null
    $selectedName = $null
    foreach ($path in @($ReceiptPath)) {
        if ([string]::IsNullOrWhiteSpace($path)) { continue }
        $name = $path.Substring($path.LastIndexOf('/') + 1)
        if ($name -notmatch '^preparation-receipt\..+\.json$') { continue }
        if ($null -eq $selectedName -or [string]::CompareOrdinal($name, $selectedName) -gt 0) {
            $selected = $path
            $selectedName = $name
        }
    }
    return $selected
}

$script:StageOrder = @('none', 'research', 'spec', 'plan', 'cleared')

function Resolve-ParallelAdmissionStage {
    <#
    .SYNOPSIS
        Combine a preparation receipt with the inferred stage.

    .DESCRIPTION
        A receipt takes precedence over inference. A receipt that records
        `cleared` but whose plan_hash differs from the current plan blob hash is
        downgraded to `plan`, so preflight runs again on the changed plan. A
        receipt stage outside none|research|spec|plan|cleared throws.

    .OUTPUTS
        pscustomobject with stage, source (receipt or inference), and downgraded.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][object] $Receipt, [string] $InferredStage, [AllowNull()][AllowEmptyString()][string] $CurrentPlanHash)

    if ($script:StageOrder -cnotcontains $InferredStage) { throw "Inferred stage '$InferredStage' is not one of $($script:StageOrder -join ', ')." }
    if ($null -eq $Receipt) {
        return [pscustomobject]@{ stage = $InferredStage; source = 'inference'; downgraded = $false }
    }
    $stage = Get-ParallelAdmissionMapValue -Map $Receipt -Key 'stage'
    if ($stage -isnot [string] -or $script:StageOrder -cnotcontains $stage) { throw "Preparation receipt stage '$stage' is not one of $($script:StageOrder -join ', ')." }
    $receiptHash = Get-ParallelAdmissionMapValue -Map $Receipt -Key 'plan_hash'
    if ($stage -ceq 'cleared' -and ([string]$receiptHash -cne [string]$CurrentPlanHash -or [string]::IsNullOrEmpty($CurrentPlanHash))) {
        return [pscustomobject]@{ stage = 'plan'; source = 'receipt'; downgraded = $true }
    }
    return [pscustomobject]@{ stage = $stage; source = 'receipt'; downgraded = $false }
}

function Test-ParallelAdmissionFolderPath {
    <#
    .SYNOPSIS
        Report whether a path or glob lies inside the item's own feature folder.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([string] $Path, [string] $FeatureFolder)

    $folder = $FeatureFolder.Trim().TrimEnd('/')
    return ($Path -ceq $folder) -or $Path.StartsWith($folder + '/', [System.StringComparison]::Ordinal)
}

function Get-ParallelAdmissionCitedPath {
    <#
    .SYNOPSIS
        Return the paths a plan cites or declares, minus the item's own feature folder.

    .DESCRIPTION
        The cited set is the Get-PlanPaths extraction of the plan text plus the
        declared radius paths, with every entry inside <FeatureFolder>/ (including
        the feature-folder glob) removed. Entries are deduplicated and sorted
        ordinally.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([AllowEmptyString()][string] $PlanText = '', [AllowEmptyCollection()][string[]] $DeclaredPath = @(), [string] $FeatureFolder)

    if ([string]::IsNullOrWhiteSpace($FeatureFolder)) { throw 'Get-ParallelAdmissionCitedPath requires -FeatureFolder.' }
    $set = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($path in @(Get-PlanPaths -PlanText $PlanText) + @($DeclaredPath)) {
        if ([string]::IsNullOrWhiteSpace($path)) { continue }
        if (Test-ParallelAdmissionFolderPath -Path $path -FeatureFolder $FeatureFolder) { continue }
        [void]$set.Add($path)
    }
    return , [string[]]@($set)
}

function Get-ParallelAdmissionStaleness {
    <#
    .SYNOPSIS
        Decide whether main changed anything the plan cites since the base commit.

    .DESCRIPTION
        A changed path hits when it equals a cited entry or Test-EntryOverlap
        reports an overlap with one. A concrete cited path that exists at the base
        and is absent on main is removed. The verdict is premise_falsified when
        any cited path was removed, stale when there is any hit or the base is not
        an ancestor of main (fail closed), and fresh otherwise. Changed paths in
        the item's own feature folder are ignored.

    .PARAMETER PresentAtBase
        Concrete cited paths that exist at the base commit.

    .PARAMETER PresentAtMain
        Concrete cited paths that exist on main.

    .OUTPUTS
        pscustomobject with verdict, changed_cited_paths, and removed_cited_paths.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyCollection()][string[]] $CitedPath = @(),
        [AllowEmptyCollection()][string[]] $ChangedPath = @(),
        [AllowEmptyCollection()][string[]] $PresentAtBase = @(),
        [AllowEmptyCollection()][string[]] $PresentAtMain = @(),
        [bool] $BaseIsAncestor = $true,
        [string] $FeatureFolder
    )

    $hits = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($changed in @($ChangedPath)) {
        if ([string]::IsNullOrWhiteSpace($changed)) { continue }
        if (-not [string]::IsNullOrWhiteSpace($FeatureFolder) -and (Test-ParallelAdmissionFolderPath -Path $changed -FeatureFolder $FeatureFolder)) { continue }
        foreach ($cited in @($CitedPath)) {
            if ([string]::IsNullOrWhiteSpace($cited)) { continue }
            if ($changed -ceq $cited -or (Test-EntryOverlap -EntryA $changed -EntryB $cited)) {
                [void]$hits.Add($changed)
                break
            }
        }
    }
    $removed = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($cited in @($CitedPath)) {
        if ([string]::IsNullOrWhiteSpace($cited) -or $cited.IndexOfAny([char[]]'*?[') -ge 0) { continue }
        if (@($PresentAtBase) -ccontains $cited -and @($PresentAtMain) -cnotcontains $cited) { [void]$removed.Add($cited) }
    }
    $verdict = if ($removed.Count -gt 0) { 'premise_falsified' } elseif ($hits.Count -gt 0 -or -not $BaseIsAncestor) { 'stale' } else { 'fresh' }
    return [pscustomobject]@{ verdict = $verdict; changed_cited_paths = [string[]]@($hits); removed_cited_paths = [string[]]@($removed) }
}

$script:BandName = @('C1', 'C2', 'C3', 'C4')

function Resolve-ParallelAdmissionBand {
    <#
    .SYNOPSIS
        Resolve an item's complexity band and record where it came from.

    .DESCRIPTION
        The caller's --band value wins (source caller); otherwise the planner
        checkpoint item's complexity_band (source planner_checkpoint); otherwise
        the value is null with source assessment, which tells the skill to run
        `## Complexity Assessment`. A non-blank value outside C1 to C4 throws.

    .OUTPUTS
        pscustomobject with value and source.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $CallerBand, [AllowNull()][AllowEmptyString()][string] $PlannerBand)

    foreach ($candidate in @(@{ Value = $CallerBand; Source = 'caller' }, @{ Value = $PlannerBand; Source = 'planner_checkpoint' })) {
        if ([string]::IsNullOrWhiteSpace($candidate.Value)) { continue }
        if ($script:BandName -cnotcontains $candidate.Value) { throw "Complexity band '$($candidate.Value)' from $($candidate.Source) is not one of C1, C2, C3, C4." }
        return [pscustomobject]@{ value = $candidate.Value; source = $candidate.Source }
    }
    return [pscustomobject]@{ value = $null; source = 'assessment' }
}

$script:Verdict = @('fresh', 'stale', 'premise_falsified')

function Get-ParallelAdmissionDecision {
    <#
    .SYNOPSIS
        Map a preparation stage and a staleness verdict to the next admission action.

    .DESCRIPTION
        Implements the verdict-to-action table of the feature spec `## Data & State`:

        - cleared + fresh: admit_prepared, no child, no preflight, no replan;
        - cleared or plan + stale: resume at preflight;
        - premise_falsified: resume at plan;
        - plan that never cleared preflight: resume at preflight even when fresh (D3);
        - spec: resume at plan; research: resume at spec;
        - none: full_preparation.

        A cleared stage counts only when PreflightCleared is true; otherwise it is
        handled as plan. The verdict is required for plan and cleared and ignored
        below them.

    .OUTPUTS
        pscustomobject with resume_stage (null for admit_prepared) and next_action.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Stage, [AllowNull()][AllowEmptyString()][string] $Verdict, [bool] $PreflightCleared)

    if ($script:StageOrder -cnotcontains $Stage) { throw "Stage '$Stage' is not one of $($script:StageOrder -join ', ')." }
    $effective = if ($Stage -ceq 'cleared' -and -not $PreflightCleared) { 'plan' } else { $Stage }
    switch ($effective) {
        'none' { return [pscustomobject]@{ resume_stage = 'research'; next_action = 'full_preparation' } }
        'research' { return [pscustomobject]@{ resume_stage = 'spec'; next_action = 'resume_preparation' } }
        'spec' { return [pscustomobject]@{ resume_stage = 'plan'; next_action = 'resume_preparation' } }
    }
    if ($script:Verdict -cnotcontains $Verdict) { throw "Staleness verdict '$Verdict' is not one of $($script:Verdict -join ', ')." }
    if ($Verdict -ceq 'premise_falsified') { return [pscustomobject]@{ resume_stage = 'plan'; next_action = 'resume_preparation' } }
    if ($effective -ceq 'cleared' -and $Verdict -ceq 'fresh') { return [pscustomobject]@{ resume_stage = $null; next_action = 'admit_prepared' } }
    return [pscustomobject]@{ resume_stage = 'preflight'; next_action = 'resume_preparation' }
}

Export-ModuleMember -Function `
    Get-ParallelAdmissionMapValue, `
    Test-ParallelAdmissionRunOpen, `
    Get-ParallelAdmissionInferredStage, `
    Select-ParallelAdmissionReceipt, `
    Resolve-ParallelAdmissionStage, `
    Get-ParallelAdmissionCitedPath, `
    Get-ParallelAdmissionStaleness, `
    Resolve-ParallelAdmissionBand, `
    Get-ParallelAdmissionDecision
