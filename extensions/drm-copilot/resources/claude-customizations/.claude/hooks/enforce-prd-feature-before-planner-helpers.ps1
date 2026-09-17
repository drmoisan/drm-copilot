<#
.SYNOPSIS
    Prompt-side feature-folder resolution for the prd-feature gate (issue #672).
.DESCRIPTION
    This file is dot-sourced by its parent hook enforce-prd-feature-before-planner.ps1,
    following the headroom-split precedent set by
    enforce-orchestration-preimplementation-gate-helpers.ps1. The parent keeps the
    decision entrypoint and the seams the existing suites mock; this file carries the
    resolution and prerequisite-mapping logic, so neither file approaches the 500-line
    cap as target resolution grows.

    The file declares no file-scope parameter block, no requires directive, and no
    entrypoint. It is loaded for its declarations only.
.NOTES
    Compatible with PowerShell 7+. Read-only resolution logic.
#>

function Resolve-PrdFeatureWorkMode {
    <#
    .SYNOPSIS
        Parses the persisted `- Work Mode: ...` marker out of issue.md content
        and returns the canonical mode, or $null when the marker is absent,
        unreadable, or unrecognized.
    .DESCRIPTION
        Recognizes minor-audit, full-feature, full-bug, and the legacy full
        marker (normalized to full-feature), mirroring the regex convention
        used by scripts/dev_tools/prompt_mode_contract.py so both runtimes
        agree on what counts as a valid marker line.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()]
        [string] $IssueContent
    )

    if ([string]::IsNullOrWhiteSpace($IssueContent)) {
        return $null
    }

    $match = [regex]::Match($IssueContent, '(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$')
    if (-not $match.Success) {
        return $null
    }

    $rawMode = $match.Groups[1].Value
    if ($rawMode -eq 'full') {
        return 'full-feature'
    }
    return $rawMode
}

function Get-PrdFeatureRequiredFile {
    <#
    .SYNOPSIS
        Maps a resolved work mode to the set of prd-feature output files the
        target folder must contain before an atomic-planner delegation is
        allowed.
    .DESCRIPTION
        full-feature requires spec.md and user-story.md; full-bug requires
        spec.md only; minor-audit requires neither.

        The default arm returns spec.md alone. It is not reached from the
        decision path for an undeterminable mode, which denies on its own branch
        without probing at all; the arm exists so a direct caller passing a $null
        or unrecognized mode never receives a permissive empty set, and it must
        not name user-story.md, because that document is required to be ABSENT
        for full-bug and minor-audit work.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()]
        [string] $WorkMode
    )

    # Route on the canonical mode; anything outside the three known values
    # (including $null) falls through to the fail-closed default case.
    switch ($WorkMode) {
        'full-feature' { return [string[]]@('spec.md', 'user-story.md') }
        'full-bug' { return [string[]]@('spec.md') }
        'minor-audit' { return [string[]]@() }
        default { return [string[]]@('spec.md') }
    }
}

function Find-PrdFeatureFolderFromPrompt {
    <#
    .SYNOPSIS
        Scans a prompt string for docs/features/active/<...> path tokens,
        truncates each to exactly four path segments, and returns the selected
        feature folder. Returns $null when no token truncates to four segments.
    .DESCRIPTION
        Truncation to four segments -- docs, features, active, and the
        feature-folder name -- is two segments past the docs/features/active/
        prefix, so the depth at which an artifact is cited cannot change which
        folder is resolved. Candidates are deduplicated preserving
        first-occurrence order; selection among two or more distinct candidates
        prefers the checkpoint's feature-folder field and otherwise takes the
        earliest occurrence in the prompt.

        The return value is a repo-relative path normalized to forward slashes,
        or $null. The function reads no file except through the existing
        checkpoint seam, and it is deterministic for a given prompt and
        checkpoint value.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Prompt
    )

    if (-not $Prompt) {
        return $null
    }

    # Allow forward or backslash separators inside the matched path token.
    $pattern = 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'
    $matchList = [regex]::Matches($Prompt, $pattern)
    if ($matchList.Count -eq 0) {
        return $null
    }

    # Deduplicate preserving FIRST-OCCURRENCE order. A [hashtable] must not be
    # used here: PowerShell hashtable key enumeration order is unspecified, so a
    # first-occurrence selection rule fed by a hashtable is not deterministic.
    [System.Collections.Generic.List[string]] $candidates = [System.Collections.Generic.List[string]]::new()
    foreach ($m in $matchList) {
        $normalized = ($m.Value -replace '\\', '/').TrimEnd('/')

        # Truncate to exactly two segments past the docs/features/active/ prefix,
        # that is, to the four segments docs, features, active, and the feature
        # folder name. Truncation is depth-insensitive, so a folder path, a
        # spec.md path, a research/ artifact path, and an evidence/ artifact path
        # all reduce to the same value. A '.' component is a path no-op and is
        # discarded first, so a degenerate token such as docs/features/active/.
        # yields three segments and is rejected rather than resolved.
        $segments = @($normalized -split '/' | Where-Object { $_ -ne '' -and $_ -ne '.' })
        if ($segments.Count -lt 4) {
            continue
        }

        $truncated = ($segments[0..3] -join '/')
        if (-not $candidates.Contains($truncated)) {
            $candidates.Add($truncated)
        }
    }

    if ($candidates.Count -eq 0) {
        return $null
    }

    # One distinct candidate is used directly, so the common case never consults
    # the checkpoint.
    if ($candidates.Count -eq 1) {
        return $candidates[0]
    }

    # More than one distinct feature folder was cited. Prefer the folder the
    # orchestrator itself records as in flight: the checkpoint is the
    # authoritative disambiguator, and it reuses a seam this hook already owns.
    $checkpointFolder = Get-PrdFeatureCheckpointFolder
    if ($checkpointFolder) {
        $checkpointNormalized = ($checkpointFolder -replace '\\', '/').TrimEnd('/')
        if ($candidates.Contains($checkpointNormalized)) {
            return $checkpointNormalized
        }
    }

    # Tiebreak of last resort: the orchestrator supplies the active feature folder
    # among its delegation inputs and names it before citing artifacts inside it,
    # so a cross-reference to another feature appears later in the prompt.
    return $candidates[0]
}

function Get-PrdFeatureMissingFile {
    <#
    .SYNOPSIS
        Returns the subset of $RequiredFile that is missing from the target
        folder.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [string] $FeatureFolder,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $RequiredFile
    )

    [System.Collections.Generic.List[string]] $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($name in $RequiredFile) {
        $candidate = "$FeatureFolder/$name"
        if (-not (Get-PrdFeatureFileExistence -Path $candidate)) {
            $missing.Add($name)
        }
    }
    return [string[]] $missing.ToArray()
}
