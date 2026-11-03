<#
.SYNOPSIS
    Prepared-item admission helper for /parallel-add and /parallel-plan (issue #1047).

.DESCRIPTION
    Entry point the parallel-planner and parallel-orchestrator forks call as
    `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 <subcommand> ...`
    with the subcommands guard-run, assess, order-cohorts, test-cohorts, record,
    and reuse-edges (feature spec `## API / CLI Surface`). The decisions are the
    pure functions of ParallelAdmission.psm1 and ParallelAdmissionPrecedence.psm1,
    and ParallelAdmissionJson.psm1 reads and writes the JSON; this script owns the
    I/O through three seams: Invoke-ParallelAdmissionGit (every git call),
    Read-ParallelAdmissionJsonText (every file read), and
    Get-ParallelAdmissionUtcNow (the clock).

    Side effects: assess runs `git fetch --quiet origin`, which updates the
    remote-tracking refs and the object store and needs network access; a fetch
    failure exits 1 with the failure prefix. Every other git call reads by ref,
    and the helper writes no file. No parameter is Mandatory, so a missing option
    exits 2.

    Exit codes: 0 prints one JSON object; 1 is a rule rejection with one stderr
    line "PARALLEL_ADMISSION_REJECTED: <code>: <detail>" (run_closed,
    precedence_cycle, precedence_unknown_item, precedence_violated) or an
    unreadable input with one stderr line prefixed "parallel admission failed: ";
    2 is a usage error prefixed "parallel admission usage error: ".
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Position = 0)][string] $Subcommand,
    [string] $CheckpointPath, [string] $ManifestMode, [string] $Branch, [string] $FeatureFolder, [string] $Receipt,
    [string] $Band, [string] $PlannerCheckpointPath, [string] $Main, [string] $Cohorts, [string] $Edges,
    [string] $Precedence, [string] $Pinned, [string] $Floor, [string] $RunFolder, [string] $Entry,
    [string] $Slug, [string] $IssueNum, [string] $PlanHash, [string] $Ref,
    [Parameter(ValueFromRemainingArguments = $true)][string[]] $Remaining
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'ParallelAdmission.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'ParallelAdmissionPrecedence.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'ParallelAdmissionJson.psm1') -Force -ErrorAction Stop

$script:AdmissionUsagePrefix = 'parallel admission usage error: '
$script:AdmissionFailurePrefix = 'parallel admission failed: '
$script:AdmissionRejectionPrefix = 'PARALLEL_ADMISSION_REJECTED: '
$script:AdmissionRejectionCode = @('run_closed', 'precedence_cycle', 'precedence_unknown_item', 'precedence_violated')
$script:AdmissionDefaultMain = 'origin/main'
$script:AdmissionTimestampFormat = 'yyyy-MM-ddTHH-mm'
$script:AdmissionBandName = @('C1', 'C2', 'C3', 'C4')
$script:AdmissionRequiredOption = @{
    'guard-run'     = @('CheckpointPath', 'ManifestMode')
    'assess'        = @('Branch', 'FeatureFolder')
    'order-cohorts' = @('Cohorts')
    'test-cohorts'  = @('CheckpointPath')
    'record'        = @('RunFolder', 'Entry')
    'reuse-edges'   = @('Slug', 'IssueNum', 'PlanHash')
}
$script:AdmissionSpecTemplatePath = 'docs/features/templates/feature/spec.md'
$script:AdmissionPlanTemplatePath = 'docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md'

function Invoke-ParallelAdmissionGit {
    <#
    .SYNOPSIS
        Run one git command and return ExitCode, Output (stdout lines), and Stderr (stderr lines); the only process call and its test seam.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string[]] $GitArgs)

    # 2>&1 interleaves the streams; stderr lines arrive as ErrorRecord objects and are split off by type.
    $all = @(& git @GitArgs 2>&1)
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = [string[]]@($all | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }); Stderr = [string[]]@($all | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } | ForEach-Object { $_.ToString() }) }
}

function Read-ParallelAdmissionJsonText {
    <#
    .SYNOPSIS
        Read one document as UTF-8 text; the script's only filesystem read and its test seam.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Path)

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Get-ParallelAdmissionUtcNow {
    <#
    .SYNOPSIS
        Return the current UTC instant; the script's only clock read and its test seam.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param()

    return [datetime]::UtcNow
}

function Resolve-ParallelAdmissionPath {
    <#
    .SYNOPSIS
        Return a rooted path unchanged and join a relative path to the current location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Path)

    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return Join-Path -Path (Get-Location).Path -ChildPath $Path
}

function Read-ParallelAdmissionDocument {
    <#
    .SYNOPSIS
        Read and parse one JSON document from disk and require an object root.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param([string] $Path, [string] $Label)

    $value = ConvertFrom-ParallelAdmissionJson -Text (Read-ParallelAdmissionJsonText -Path (Resolve-ParallelAdmissionPath -Path $Path))
    if ($value -isnot [System.Collections.IDictionary]) { throw "$Label at $Path must be a JSON object." }
    return $value
}

function ConvertTo-ParallelAdmissionCliOutcome {
    <#
    .SYNOPSIS
        Build the result record the guarded entry body writes and exits with.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $ExitCode, [string] $Stdout = '', [string] $Stderr = '')

    return [pscustomobject]@{ ExitCode = $ExitCode; Stdout = $Stdout; Stderr = $Stderr }
}

function ConvertTo-ParallelAdmissionRejection {
    <#
    .SYNOPSIS
        Turn a rule rejection ("<code>: <detail>", or a detail plus Code) into exit 1 with one PARALLEL_ADMISSION_REJECTED line.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Message, [string] $Code)

    $detail = ($Message -replace "\r?\n", ' ').Trim()
    if ([string]::IsNullOrEmpty($Code)) {
        $Code = $detail.Substring(0, $detail.IndexOf(':'))
        $detail = $detail.Substring($detail.IndexOf(':') + 1).Trim()
    }
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 1 -Stderr "$($script:AdmissionRejectionPrefix)${Code}: $detail"
}

function Test-ParallelAdmissionRejectionMessage {
    <#
    .SYNOPSIS
        Report whether an exception message starts with one of the four rejection codes.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([string] $Message)

    foreach ($code in $script:AdmissionRejectionCode) {
        if ($Message.StartsWith("${code}:", [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

function Get-ParallelAdmissionUsageError {
    <#
    .SYNOPSIS
        Return the usage-error text for the arguments, or null when they are usable.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Subcommand, [hashtable] $Option, [AllowNull()][string[]] $Remaining)

    if ([string]::IsNullOrWhiteSpace($Subcommand)) { return "a subcommand is required; use one of $(@($script:AdmissionRequiredOption.Keys | Sort-Object) -join ', ')." }
    if (-not $script:AdmissionRequiredOption.ContainsKey($Subcommand)) { return "unknown subcommand '$Subcommand'." }
    foreach ($argument in @($Remaining)) {
        if ($null -eq $argument) { continue }
        if ($argument.StartsWith('-')) { return "unrecognized parameter '$argument'." }
        return "unexpected argument '$argument'."
    }
    foreach ($name in $script:AdmissionRequiredOption[$Subcommand]) {
        if ([string]::IsNullOrWhiteSpace($Option[$name])) { return "$Subcommand requires -$name." }
    }
    # A ref value is passed to git as a bare argument, so a leading '-' would be read as a git option.
    foreach ($name in @('Branch', 'Main', 'Ref')) {
        if (-not [string]::IsNullOrEmpty($Option[$name]) -and $Option[$name].StartsWith('-', [System.StringComparison]::Ordinal)) { return "-$name must not begin with '-'; got '$($Option[$name])'." }
    }
    if (-not [string]::IsNullOrWhiteSpace($Option['Band']) -and $script:AdmissionBandName -cnotcontains $Option['Band']) {
        return "-Band must be one of $($script:AdmissionBandName -join ', '); got '$($Option['Band'])'."
    }
    $floorValue = 0
    if (-not [string]::IsNullOrWhiteSpace($Option['Floor']) -and -not ($Option['Floor'] -match '^[0-9]+$' -and [int]::TryParse($Option['Floor'], [ref] $floorValue))) {
        return "-Floor must be a non-negative integer; got '$($Option['Floor'])'."
    }
    foreach ($name in @('Edges', 'Precedence')) {
        foreach ($token in (Split-ParallelAdmissionToken -Text $Option[$name])) {
            if ($token -notmatch '^[0-9]+:[0-9]+$') { return "-$name entries must be <key>:<key>; got '$token'." }
        }
    }
    foreach ($token in (Split-ParallelAdmissionToken -Text $Option['Pinned'])) {
        if ($token -notmatch '^[0-9]+$') { return "-Pinned entries must be integer item keys; got '$token'." }
    }
    if ($Subcommand -ceq 'record' -and $Option['RunFolder'] -notmatch '^docs/features/parallel/[^/\s]+/?$') {
        return "-RunFolder must be docs/features/parallel/<slug>; got '$($Option['RunFolder'])'."
    }
    if (-not [string]::IsNullOrEmpty($Option['Slug']) -and $Option['Slug'] -match '[/\s]') {
        return "-Slug must be a run slug without '/' or whitespace; got '$($Option['Slug'])'."
    }
    $issueValue = [long]0
    if (-not [string]::IsNullOrEmpty($Option['IssueNum']) -and -not ($Option['IssueNum'] -match '^[0-9]+$' -and [long]::TryParse($Option['IssueNum'], [ref] $issueValue) -and $issueValue -gt 0)) {
        return "-IssueNum must be a positive integer; got '$($Option['IssueNum'])'."
    }
    return $null
}

function Split-ParallelAdmissionToken {
    <#
    .SYNOPSIS
        Split a space- or comma-separated option value into its non-empty tokens.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return , [string[]]@() }
    return , [string[]]@($Text.Trim() -split '[\s,]+' | Where-Object { $_ })
}

function Invoke-ParallelAdmissionGuardRun {
    <#
    .SYNOPSIS
        guard-run: reject an addition to a closed run (Test-ParallelAdmissionRunOpen).
    .DESCRIPTION
        An unreadable or unparseable checkpoint is closed (fail closed). The
        rejection emits run_closed and never the mutation rejection signal.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Option)

    $checkpoint = $null
    $readError = $null
    try {
        $checkpoint = ConvertFrom-ParallelAdmissionJson -Text (Read-ParallelAdmissionJsonText -Path (Resolve-ParallelAdmissionPath -Path $Option.CheckpointPath))
    } catch {
        $readError = ($_.Exception.Message -replace "\r?\n", ' ').Trim()
    }
    if ($null -ne $readError) {
        return ConvertTo-ParallelAdmissionRejection -Code 'run_closed' -Message "checkpoint $($Option.CheckpointPath) could not be read ($readError)"
    }
    $verdict = Test-ParallelAdmissionRunOpen -ManifestMode $Option.ManifestMode -Checkpoint $checkpoint
    if (-not $verdict.Open) { return ConvertTo-ParallelAdmissionRejection -Code 'run_closed' -Message $verdict.Detail }
    $checkedAt = (Get-ParallelAdmissionUtcNow).ToString($script:AdmissionTimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
    $result = [ordered]@{ checked_at = $checkedAt; checkpoint_mode = $verdict.CheckpointMode; manifest_mode = $verdict.ManifestMode; result = 'open' }
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 0 -Stdout (ConvertTo-ParallelAdmissionJson -Value $result)
}

function Invoke-ParallelAdmissionGitChecked {
    <#
    .SYNOPSIS
        Run one git command through the seam and throw when it exits non-zero, naming the first non-blank stderr line.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([string[]] $GitArgs)

    $result = Invoke-ParallelAdmissionGit -GitArgs $GitArgs
    if ($result.ExitCode -ne 0) {
        # A result without a Stderr property (an older seam double) reads as empty; strict mode would throw on the access.
        $stderrLine = @(if ($result.PSObject.Properties.Name -contains 'Stderr') { $result.Stderr | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } })
        if ($stderrLine.Count -gt 0) { throw "git $($GitArgs -join ' ') exited $($result.ExitCode): $($stderrLine[0].Trim())" }
        throw "git $($GitArgs -join ' ') exited $($result.ExitCode)."
    }
    return , [string[]]@($result.Output | Where-Object { $null -ne $_ })
}

function Get-ParallelAdmissionBlobText {
    <#
    .SYNOPSIS
        Read one file by ref (git show <ref>:<path>) and return its text with LF line breaks.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Ref, [string] $Path)

    return (Invoke-ParallelAdmissionGitChecked -GitArgs @('show', "${Ref}:$Path")) -join "`n"
}

function Get-ParallelAdmissionTemplateLine {
    <#
    .SYNOPSIS
        Read the spec placeholder lines (non-blank, not starting with '#', '-', '|') and plan template task lines from main.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Main)

    $specLine = @((Get-ParallelAdmissionBlobText -Ref $Main -Path $script:AdmissionSpecTemplatePath) -split "`n" | Where-Object {
            $trimmed = $_.Trim()
            $trimmed -and -not ($trimmed.StartsWith('#') -or $trimmed.StartsWith('-') -or $trimmed.StartsWith('|'))
        })
    $taskLine = @((Get-ParallelAdmissionBlobText -Ref $Main -Path $script:AdmissionPlanTemplatePath) -split "`n" | Where-Object { $_ -match '^- \[[ x]\] \[P\d+-T\d+\]' })
    return [pscustomobject]@{ SpecPlaceholderLine = [string[]]$specLine; PlanTemplateTaskLine = [string[]]$taskLine }
}

function Get-ParallelAdmissionPlannerItem {
    <#
    .SYNOPSIS
        Return the planner checkpoint item whose feature_folder is FeatureFolder, or null.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowEmptyString()][string] $Path, [string] $FeatureFolder)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $checkpoint = Read-ParallelAdmissionDocument -Path $Path -Label 'Parallel planner checkpoint'
    foreach ($item in @(Get-ParallelAdmissionMapValue -Map $checkpoint -Key 'items')) {
        $folder = Get-ParallelAdmissionMapValue -Map $item -Key 'feature_folder'
        if ($folder -is [string] -and $folder.TrimEnd('/') -ceq $FeatureFolder) { return $item }
    }
    return $null
}

function Read-ParallelAdmissionBranchFile {
    <#
    .SYNOPSIS
        Read research, spec, plan, and preflight-evidence texts, and the plan and preflight commit times.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Branch, [string] $FeatureFolder, [string[]] $TreePath)

    $text = @{}
    $time = @{}
    foreach ($path in $TreePath) {
        $relative = $path.Substring($FeatureFolder.Length + 1)
        $isResearch = $relative.StartsWith('research/') -and $relative.EndsWith('.md')
        $isPlan = -not $relative.Contains('/') -and $relative.StartsWith('plan.') -and $relative.EndsWith('.md')
        $isPreflight = $relative.StartsWith('evidence/') -and $relative.Substring($relative.LastIndexOf('/') + 1).Contains('preflight')
        if ($isResearch -or $isPlan -or $isPreflight -or $relative -ceq 'spec.md') { $text[$path] = Get-ParallelAdmissionBlobText -Ref $Branch -Path $path }
        if ($isPlan -or $isPreflight) {
            $stamp = [string[]](Invoke-ParallelAdmissionGitChecked -GitArgs @('log', '-1', '--format=%ct', $Branch, '--', $path))
            if ($stamp.Count -gt 0 -and $stamp[0] -match '^[0-9]+$') { $time[$path] = [long]$stamp[0] }
        }
    }
    return [pscustomobject]@{ FileText = $text; CommitTime = $time }
}

function Get-ParallelAdmissionAssessStaleness {
    <#
    .SYNOPSIS
        Gather the git facts for the staleness verdict and apply Get-ParallelAdmissionStaleness.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Main, [string] $BaseCommit, [string] $PlanText, [string[]] $DeclaredPath, [string] $FeatureFolder)

    $isAncestor = (Invoke-ParallelAdmissionGit -GitArgs @('merge-base', '--is-ancestor', $BaseCommit, $Main)).ExitCode -eq 0
    $changed = Invoke-ParallelAdmissionGitChecked -GitArgs @('diff', '--name-only', '--no-renames', $BaseCommit, $Main)
    $cited = Get-ParallelAdmissionCitedPath -PlanText $PlanText -DeclaredPath $DeclaredPath -FeatureFolder $FeatureFolder
    $atBase = [System.Collections.Generic.List[string]]::new()
    $atMain = [System.Collections.Generic.List[string]]::new()
    foreach ($path in $cited) {
        if ($path.IndexOfAny([char[]]'*?[') -ge 0) { continue }
        if ((Invoke-ParallelAdmissionGit -GitArgs @('cat-file', '-e', "${BaseCommit}:$path")).ExitCode -eq 0) { $atBase.Add($path) }
        if ((Invoke-ParallelAdmissionGit -GitArgs @('cat-file', '-e', "${Main}:$path")).ExitCode -eq 0) { $atMain.Add($path) }
    }
    return Get-ParallelAdmissionStaleness -CitedPath $cited -ChangedPath $changed -PresentAtBase $atBase.ToArray() -PresentAtMain $atMain.ToArray() -BaseIsAncestor $isAncestor -FeatureFolder $FeatureFolder
}

function Invoke-ParallelAdmissionAssess {
    <#
    .SYNOPSIS
        assess: report how far an item is prepared, whether main moved under its plan, and the next action.
    .DESCRIPTION
        Fetches origin first (git fetch --quiet origin), then reads by ref through
        Invoke-ParallelAdmissionGit. The newest receipt
        takes precedence over inference; plan_hash is the plan blob hash at the
        branch head; base_commit is the receipt's, else the merge base with main.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Option)

    $branch = $Option.Branch
    $main = $Option.Main
    $folder = $Option.FeatureFolder.Trim().TrimEnd('/')
    [void](Invoke-ParallelAdmissionGitChecked -GitArgs @('fetch', '--quiet', 'origin'))
    # Seam results are parenthesized so the pipeline enumerates their lines rather than one array object.
    $tree = [string[]]@((Invoke-ParallelAdmissionGitChecked -GitArgs @('ls-tree', '-r', '--name-only', $branch, '--', $folder)) | Where-Object { $_.StartsWith("$folder/", [System.StringComparison]::Ordinal) })
    $template = Get-ParallelAdmissionTemplateLine -Main $main
    $files = Read-ParallelAdmissionBranchFile -Branch $branch -FeatureFolder $folder -TreePath $tree
    $inferred = Get-ParallelAdmissionInferredStage -TreePath $tree -FileText $files.FileText -CommitTime $files.CommitTime `
        -SpecPlaceholderLine $template.SpecPlaceholderLine -PlanTemplateTaskLine $template.PlanTemplateTaskLine -FeatureFolder $folder

    $receiptPath = if ([string]::IsNullOrWhiteSpace($Option.Receipt)) { Select-ParallelAdmissionReceipt -ReceiptPath @($tree | Where-Object { $_.StartsWith("$folder/evidence/other/", [System.StringComparison]::Ordinal) }) } else { $Option.Receipt }
    $receipt = $null
    if (-not [string]::IsNullOrWhiteSpace($receiptPath)) {
        $receipt = ConvertFrom-ParallelAdmissionJson -Text (Get-ParallelAdmissionBlobText -Ref $branch -Path $receiptPath)
        if ($receipt -isnot [System.Collections.IDictionary]) { throw "Preparation receipt $receiptPath must be a JSON object." }
    }
    $planPath = $inferred.plan_path
    if ($null -eq $planPath) { $planPath = Get-ParallelAdmissionMapValue -Map $receipt -Key 'plan_path' }
    $planHash = $null
    if (-not [string]::IsNullOrWhiteSpace($planPath)) {
        $hashResult = Invoke-ParallelAdmissionGit -GitArgs @('rev-parse', "${branch}:$planPath")
        if ($hashResult.ExitCode -eq 0 -and @($hashResult.Output).Count -gt 0) { $planHash = $hashResult.Output[0].Trim() }
    }
    $stage = Resolve-ParallelAdmissionStage -Receipt $receipt -InferredStage $inferred.stage -CurrentPlanHash $planHash
    $preflightCleared = $stage.stage -ceq 'cleared' -and ($stage.source -ceq 'inference' -or (Get-ParallelAdmissionMapValue -Map $receipt -Key 'preflight_status') -ceq 'PREFLIGHT: ALL CLEAR')

    $baseCommit = Get-ParallelAdmissionMapValue -Map $receipt -Key 'base_commit'
    if ([string]::IsNullOrWhiteSpace([string]$baseCommit)) { $baseCommit = [string[]](Invoke-ParallelAdmissionGitChecked -GitArgs @('merge-base', $main, $branch)) | Select-Object -First 1 }
    $plannerItem = Get-ParallelAdmissionPlannerItem -Path $Option.PlannerCheckpointPath -FeatureFolder $folder
    $staleness = [pscustomobject]@{ verdict = $null; changed_cited_paths = [string[]]@(); removed_cited_paths = [string[]]@() }
    if (@('plan', 'cleared') -ccontains $stage.stage -and -not [string]::IsNullOrWhiteSpace($planPath)) {
        $planText = if ($files.FileText.ContainsKey($planPath)) { $files.FileText[$planPath] } else { Get-ParallelAdmissionBlobText -Ref $branch -Path $planPath }
        $declared = [string[]]@(Get-ParallelAdmissionMapValue -Map (Get-ParallelAdmissionMapValue -Map $plannerItem -Key 'blast_radius') -Key 'paths' | Where-Object { $_ -is [string] })
        $staleness = Get-ParallelAdmissionAssessStaleness -Main $main -BaseCommit $baseCommit -PlanText $planText -DeclaredPath $declared -FeatureFolder $folder
    }
    $band = Resolve-ParallelAdmissionBand -CallerBand $Option.Band -PlannerBand ([string](Get-ParallelAdmissionMapValue -Map $plannerItem -Key 'complexity_band'))
    $decision = Get-ParallelAdmissionDecision -Stage $stage.stage -Verdict $staleness.verdict -PreflightCleared $preflightCleared

    $result = [ordered]@{
        preparation_status = $stage.stage
        resume_stage       = $decision.resume_stage
        research_path      = $inferred.research_path
        spec_path          = $inferred.spec_path
        plan_path          = $planPath
        plan_hash          = $planHash
        base_commit        = $baseCommit
        staleness          = [ordered]@{ verdict = $staleness.verdict; changed_cited_paths = [object[]]@($staleness.changed_cited_paths); removed_cited_paths = [object[]]@($staleness.removed_cited_paths) }
        band               = [ordered]@{ value = $band.value; source = $band.source }
        next_action        = $decision.next_action
    }
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 0 -Stdout (ConvertTo-ParallelAdmissionJson -Value $result)
}

function ConvertTo-ParallelAdmissionPrecedenceEntry {
    <#
    .SYNOPSIS
        Turn "<before>:<after>" tokens into precedence entries.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($token in (Split-ParallelAdmissionToken -Text $Text)) {
        $ends = $token -split ':'
        $entries.Add(@{ before = [long]$ends[0]; after = [long]$ends[1] })
    }
    return , $entries.ToArray()
}

function ConvertFrom-ParallelAdmissionCohortJson {
    <#
    .SYNOPSIS
        Read a cohort table from JSON: an array of key arrays, an array of cohort objects, or an object with cohorts.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param([string] $Text)

    $value = ConvertFrom-ParallelAdmissionJson -Text $Text
    if ($value -is [System.Collections.IDictionary]) {
        # Indexed directly: a function return would unroll a one-cohort array into its only entry.
        $cohortList = if ($value.Contains('cohorts')) { , $value['cohorts'] } else { $null }
        $value = if ($cohortList -is [array]) { , $cohortList } else { $null }
    }
    if ($value -isnot [array]) { throw '-Cohorts must be a JSON array of cohorts or an object with a cohorts array.' }
    $table = [System.Collections.Generic.List[object]]::new()
    foreach ($cohort in $value) {
        $members = if ($cohort -is [System.Collections.IDictionary]) { Get-ParallelAdmissionMapValue -Map $cohort -Key 'item_keys' } else { $cohort }
        $table.Add([object[]]@($members))
    }
    return , $table.ToArray()
}

function Invoke-ParallelAdmissionCohortOrder {
    <#
    .SYNOPSIS
        order-cohorts: apply the precedence lift to a computed cohort table.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Option)

    $entries = ConvertTo-ParallelAdmissionPrecedenceEntry -Text $Option.Precedence
    $floorValue = if ([string]::IsNullOrWhiteSpace($Option.Floor)) { 0 } else { [int]$Option.Floor }
    $pinnedKey = [long[]]@((Split-ParallelAdmissionToken -Text $Option.Pinned) | ForEach-Object { [long]$_ })
    $table = Invoke-ParallelPrecedenceLift -Cohort (ConvertFrom-ParallelAdmissionCohortJson -Text $Option.Cohorts) -Edge (Split-ParallelAdmissionToken -Text $Option.Edges) `
        -Precedence $entries -Pinned $pinnedKey -Floor $floorValue
    $result = [ordered]@{ cohorts = [object[]]$table; precedence_edges = [object[]](ConvertTo-ParallelPrecedenceEdge -Entry $entries) }
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 0 -Stdout (ConvertTo-ParallelAdmissionJson -Value $result)
}

function Invoke-ParallelAdmissionCohortTest {
    <#
    .SYNOPSIS
        test-cohorts: reject a current-generation cohort table that violates an active precedence entry.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Option)

    $checkpoint = Read-ParallelAdmissionDocument -Path $Option.CheckpointPath -Label 'Parallel checkpoint'
    $check = Test-ParallelPrecedenceCohortTable -Checkpoint $checkpoint
    if (-not $check.Satisfied) { return ConvertTo-ParallelAdmissionRejection -Code 'precedence_violated' -Message ($check.Violation -join '; ') }
    $result = [ordered]@{ active_precedence = [object[]]@($check.Active); result = 'satisfied' }
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 0 -Stdout (ConvertTo-ParallelAdmissionJson -Value $result)
}

function Invoke-ParallelAdmissionRecord {
    <#
    .SYNOPSIS
        record: print the parallel-scheduling.json content; the caller writes and commits it, so no git command runs.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Option)

    $slug = $Option.RunFolder.TrimEnd('/').Substring('docs/features/parallel/'.Length)
    $entry = ConvertFrom-ParallelAdmissionJson -Text $Option.Entry
    if ($entry -isnot [System.Collections.IDictionary]) { throw '-Entry must be a JSON object.' }
    $record = New-ParallelSchedulingRecord -Slug $slug -Edge @(Get-ParallelAdmissionMapValue -Map $entry -Key 'edges') `
        -ToleratedOverlap @(Get-ParallelAdmissionMapValue -Map $entry -Key 'tolerated_overlaps') `
        -Precedence @(Get-ParallelAdmissionMapValue -Map $entry -Key 'precedence') -Item @(Get-ParallelAdmissionMapValue -Map $entry -Key 'items')
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 0 -Stdout (ConvertTo-ParallelAdmissionJson -Value $record)
}

function Get-ParallelAdmissionRecordedEdge {
    <#
    .SYNOPSIS
        Read a run's committed scheduling record by ref and apply the edge-reuse rule for one item.
    .DESCRIPTION
        Reads the record from origin/parallel/<slug>-plan (or -Ref) through the git
        seam; a missing record gives a recompute marker with reason record_missing.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Slug, [long] $IssueNum, [AllowEmptyString()][string] $CurrentPlanHash, [string] $Ref = '')

    if ([string]::IsNullOrWhiteSpace($Ref)) { $Ref = "origin/parallel/$Slug-plan" }
    $recordPath = "docs/features/parallel/$Slug/parallel-scheduling.json"
    $shown = Invoke-ParallelAdmissionGit -GitArgs @('show', "${Ref}:$recordPath")
    if ($shown.ExitCode -ne 0) { return [pscustomobject]@{ action = 'recompute'; reason = 'record_missing'; edges = [object[]]@() } }
    $record = ConvertFrom-ParallelAdmissionJson -Text (@($shown.Output) -join "`n")
    if ($record -isnot [System.Collections.IDictionary]) { throw "Scheduling record ${Ref}:$recordPath must be a JSON object." }
    return Get-ParallelSchedulingRecordReuse -Record $record -IssueNum $IssueNum -CurrentPlanHash $CurrentPlanHash
}

function Invoke-ParallelAdmissionEdgeReuse {
    <#
    .SYNOPSIS
        reuse-edges: apply the edge-reuse rule to one item from the committed scheduling record; no fetch runs.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Option)

    $reuse = Get-ParallelAdmissionRecordedEdge -Slug $Option.Slug -IssueNum ([long]$Option.IssueNum) -CurrentPlanHash $Option.PlanHash -Ref ([string]$Option.Ref)
    $result = [ordered]@{ action = $reuse.action; edges = [object[]]@($reuse.edges); reason = $reuse.reason }
    return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 0 -Stdout (ConvertTo-ParallelAdmissionJson -Value $result)
}

function Invoke-ParallelAdmissionCli {
    <#
    .SYNOPSIS
        Validate the arguments, run one subcommand, and return ExitCode, Stdout, and Stderr.
    .DESCRIPTION
        Usage errors are reported before any read. A rule rejection becomes exit 1
        with the rejection line; any other read or data error exit 1 with the failure prefix.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string] $Subcommand, [string] $CheckpointPath, [string] $ManifestMode, [string] $Branch, [string] $FeatureFolder,
        [string] $Receipt, [string] $Band, [string] $PlannerCheckpointPath, [string] $Main, [string] $Cohorts, [string] $Edges,
        [string] $Precedence, [string] $Pinned, [string] $Floor, [string] $RunFolder, [string] $Entry,
        [string] $Slug, [string] $IssueNum, [string] $PlanHash, [string] $Ref, [AllowNull()][string[]] $Remaining
    )

    $option = @{ CheckpointPath = $CheckpointPath; ManifestMode = $ManifestMode; Branch = $Branch; FeatureFolder = $FeatureFolder; Receipt = $Receipt; Band = $Band
        PlannerCheckpointPath = $PlannerCheckpointPath; Main = $Main; Cohorts = $Cohorts; Edges = $Edges; Precedence = $Precedence; Pinned = $Pinned; Floor = $Floor; RunFolder = $RunFolder; Entry = $Entry
        Slug = $Slug; IssueNum = $IssueNum; PlanHash = $PlanHash; Ref = $Ref }
    $usage = Get-ParallelAdmissionUsageError -Subcommand $Subcommand -Option $option -Remaining $Remaining
    if ($null -ne $usage) { return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 2 -Stderr "$($script:AdmissionUsagePrefix)$usage" }
    if ([string]::IsNullOrWhiteSpace($option.Main)) { $option.Main = $script:AdmissionDefaultMain }

    try {
        switch ($Subcommand) {
            'guard-run' { return Invoke-ParallelAdmissionGuardRun -Option $option }
            'assess' { return Invoke-ParallelAdmissionAssess -Option $option }
            'order-cohorts' { return Invoke-ParallelAdmissionCohortOrder -Option $option }
            'test-cohorts' { return Invoke-ParallelAdmissionCohortTest -Option $option }
            'record' { return Invoke-ParallelAdmissionRecord -Option $option }
            'reuse-edges' { return Invoke-ParallelAdmissionEdgeReuse -Option $option }
        }
    } catch {
        $message = $_.Exception.Message
        if (Test-ParallelAdmissionRejectionMessage -Message $message) { return ConvertTo-ParallelAdmissionRejection -Message $message }
        return ConvertTo-ParallelAdmissionCliOutcome -ExitCode 1 -Stderr "$($script:AdmissionFailurePrefix)$(($message -replace "\r?\n", ' ').Trim())"
    }
}

# Dot-sourcing loads the functions for a test host; any other invocation runs
# the subcommand. Parameters are passed by name rather than by splatting
# $PSBoundParameters, which under CmdletBinding can carry common parameters.
if ($MyInvocation.InvocationName -ne '.') {
    $outcome = Invoke-ParallelAdmissionCli -Subcommand $Subcommand -CheckpointPath $CheckpointPath -ManifestMode $ManifestMode `
        -Branch $Branch -FeatureFolder $FeatureFolder -Receipt $Receipt -Band $Band -PlannerCheckpointPath $PlannerCheckpointPath `
        -Main $Main -Cohorts $Cohorts -Edges $Edges -Precedence $Precedence -Pinned $Pinned -Floor $Floor -RunFolder $RunFolder `
        -Entry $Entry -Slug $Slug -IssueNum $IssueNum -PlanHash $PlanHash -Ref $Ref -Remaining $Remaining
    if (-not [string]::IsNullOrEmpty($outcome.Stdout)) { [Console]::Out.WriteLine($outcome.Stdout) }
    if (-not [string]::IsNullOrEmpty($outcome.Stderr)) { [Console]::Error.WriteLine($outcome.Stderr) }
    exit $outcome.ExitCode
}
