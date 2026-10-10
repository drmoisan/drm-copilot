<#
.SYNOPSIS
    The single exemption list of the hook dependency guard tests and the exemption guard
    detectors (issue #786; operator decision of 2026-10-09, option 1).

.DESCRIPTION
    Test support only (operator decision D5): not mirrored, not in a pack manifest, not a coverage
    target. Requires HookDependencyGraph.Helpers.ps1 to be dot-sourced by the caller first.

    Get-HookImportFailureExemption returns the D2 and D3 design entries and one Handler entry per
    surface for every handler whose fail-closed proof recorded FAIL-CLOSED (W-EXEMPT in
    exemption-decisions.md). Get-HookScopedImportFailureHandler detects scoped import-failure
    handlers in script text, and Get-HookExemptionFinding reports a missing handler site, an
    unlisted handler, or a missing deny code. Every reader is an injectable script block, so the
    fixtures are in-memory here-strings and no file is written.
#>

function Get-HookImportFailureExemption {
    <#
    .SYNOPSIS
        Returns the named exemptions consumed by the structural and exemption guard tests.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    [pscustomobject]@{
        Id = 'D2'; Kind = 'Design'; Surface = 'claude'; HandlerFile = @('.claude/hooks/enforce-mermaid-validation.ps1'); Leaf = @('MermaidValidation.psm1')
        Justification = 'D2: a consumer repository without the MermaidValidation module must not be blocked; the mermaid gate allows by design when the module is unavailable.'
    }
    [pscustomobject]@{
        Id = 'D3'; Kind = 'Design'; Surface = 'codex'; HandlerFile = @('.codex/hooks/codex-epic-child-launch-attestation.ps1', '.codex/hooks/enforce-epic-child-worktree-binding.ps1'); Leaf = @('epic-child-launch-contract.ps1')
        Justification = 'D3: an absent .codex/scripts/epic-child-launch-contract.ps1 is a skip; a present file that fails to load is a guarded dependency failure.'
    }
    $handlers = @(
        @('H1', '#565', 'claude', '.claude/hooks/enforce-feature-folder-order.ps1', 'FeatureFolderOrderResolutionImportFailure', '.claude/hooks/enforce-feature-folder-order.ps1', '.claude/hooks/enforce-feature-folder-order.ps1', '$script:FeatureFolderOrderResolutionImportFailure', 'FEATURE_FOLDER_ORDER_BLOCKED:',
            'H1 (#565): enforce-feature-folder-order.ps1 denies every plan write with FEATURE_FOLDER_ORDER_BLOCKED: when feature-folder-resolution.ps1 fails to load; non-plan writes never call the resolver; fail-closed proof recorded.'),
        @('H2', '#565', 'claude', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 'OrchestrationFeatureFolderResolutionImportFailure', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '$script:OrchestrationFeatureFolderResolutionImportFailure', 'feature-folder-resolution-import',
            'H2 (#565): the preimplementation-gate modes sibling fails every epic and parallel readiness predicate with feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load, and the gate denies; fail-closed proof recorded.'),
        @('H2', '#565', 'codex', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 'OrchestrationFeatureFolderResolutionImportFailure', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '$script:OrchestrationFeatureFolderResolutionImportFailure', 'feature-folder-resolution-import',
            'H2 (#565): the preimplementation-gate modes sibling fails every epic and parallel readiness predicate with feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load, and the gate denies; fail-closed proof recorded.'),
        @('H3', '#565', 'claude', '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1', 'PrdFeatureFolderResolutionImportFailure', '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1', '.claude/hooks/enforce-prd-feature-before-planner.ps1', '-not $workMode', 'PRD_FEATURE_BLOCKED:',
            'H3 (#565): Resolve-PrdFeatureWorkMode returns null when feature-folder-resolution.ps1 fails to load, and the planner gate denies with PRD_FEATURE_BLOCKED:; fail-closed proof recorded.'),
        @('H4', '#565', 'claude', '.claude/hooks/enforce-epic-wave-barrier.ps1', 'EpicWaveBarrierResolutionImportFailure', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '$script:EpicWaveBarrierResolutionImportFailure', 'EPIC_WAVE_BARRIER_BLOCKED:',
            'H4 (#565): enforce-epic-wave-barrier.ps1 denies with EPIC_WAVE_BARRIER_BLOCKED: before any other logic when feature-folder-resolution.ps1 fails to load; fail-closed proof recorded.'),
        @('H5', '#565', 'claude', '.claude/hooks/enforce-parallel-drift-gate.ps1', 'ParallelDriftGateResolutionImportFailure', '.claude/hooks/enforce-parallel-drift-gate.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', '$script:ParallelDriftGateResolutionImportFailure', 'PARALLEL_DRIFT_GATE_BLOCKED:',
            'H5 (#565): enforce-parallel-drift-gate.ps1 denies with PARALLEL_DRIFT_GATE_BLOCKED: before any other logic when feature-folder-resolution.ps1 fails to load; fail-closed proof recorded.'),
        @('H6', '#565', 'claude', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', 'ParallelCohortBarrierResolutionImportFailure', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '$script:ParallelCohortBarrierResolutionImportFailure', 'PARALLEL_COHORT_BARRIER_BLOCKED:',
            'H6 (#565): enforce-parallel-cohort-barrier.ps1 denies with PARALLEL_COHORT_BARRIER_BLOCKED: before any other logic when feature-folder-resolution.ps1 fails to load; fail-closed proof recorded.')
    )
    foreach ($h in $handlers) {
        [pscustomobject]@{
            Id = $h[0]; Kind = 'Handler'; Issue = $h[1]; Surface = $h[2]; HandlerFile = $h[3]; Variable = $h[4]; Leaf = @('feature-folder-resolution.ps1')
            ConsumerFile = $h[5]; DenyPathFile = $h[6]; DenyPathCondition = $h[7]; DenyCode = $h[8]; Justification = $h[9]
        }
    }
}

function Get-HookScopedImportFailureHandler {
    <#
    .SYNOPSIS
        Detects scoped import-failure handlers in one script text.
    .DESCRIPTION
        A handler is a TryStatementAst outside every function definition whose body contains an
        Import-Module or dot-source command and one of whose catch clauses assigns a variable named
        $script:<Name>ImportFailure. One object per (Variable, Leaf), where a foreach over a literal
        array yields one leaf per element.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ScriptText,
        [Parameter(Mandatory)] [string] $SourcePath
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)
    $edges = @(Get-HookScriptEdge -ScriptText $ScriptText -SourcePath $SourcePath)
    foreach ($try in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.TryStatementAst] }, $true)) {
        $parent = $try.Parent
        while ($null -ne $parent -and $parent -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { $parent = $parent.Parent }
        if ($null -ne $parent) { continue }
        $assignments = @($try.CatchClauses | ForEach-Object { $_.Body.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -match '^\$script:\w+ImportFailure$' }, $true) })
        if ($assignments.Count -eq 0) { continue }
        $start = $try.Body.Extent.StartOffset
        $end = $try.Body.Extent.EndOffset
        $inside = @($edges | Where-Object { $_.Command.Extent.StartOffset -ge $start -and $_.Command.Extent.EndOffset -le $end })
        if ($inside.Count -eq 0) { continue }
        foreach ($variable in @($assignments | ForEach-Object { $_.Left.Extent.Text.Substring(8) } | Sort-Object -Unique)) {
            foreach ($edge in $inside) {
                [pscustomobject]@{ SourcePath = $SourcePath; Variable = $variable; Leaf = $edge.Leaf; Line = $try.Extent.StartLineNumber }
            }
        }
    }
}

function Test-HookExemptionIfClause {
    # True when the text holds an if clause whose condition text equals Condition and, when Code is
    # given, whose body text contains Code by ordinal comparison.
    param([string] $ScriptText, [string] $Condition, [string] $Code)
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)
    foreach ($if in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.IfStatementAst] }, $true)) {
        foreach ($clause in $if.Clauses) {
            if ($clause.Item1.Extent.Text -ne $Condition) { continue }
            if ([string]::IsNullOrEmpty($Code) -or $clause.Item2.Extent.Text.Contains($Code)) { return $true }
        }
    }
    return $false
}

function Get-HookExemptionFinding {
    <#
    .SYNOPSIS
        Returns the exemption guard findings for one hook root.
    .DESCRIPTION
        HookRoot ends in .claude/hooks or .codex/hooks; the entries of that surface are judged and
        their root-relative files are read beneath the root that contains HookRoot. Findings:
        EXEMPTION-MISSING (condition a), UNLISTED-HANDLER (condition b), DENY-CODE-MISSING (condition c).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Exemption,
        [Parameter(Mandatory)] [string] $HookRoot,
        [scriptblock] $ReadText = $script:HookGraphDefaultReadText,
        [scriptblock] $ListFiles = { param([string] $Directory) Get-ChildItem -LiteralPath $Directory -Filter '*.ps1' -File | ForEach-Object FullName }
    )

    $normalRoot = ($HookRoot -replace '\\', '/').TrimEnd('/')
    if ($normalRoot -notmatch '^(.*?)/?\.(claude|codex)/hooks$') { throw "HookRoot must end in .claude/hooks or .codex/hooks: $HookRoot" }
    $baseRoot = $Matches[1]
    $surface = $Matches[2]
    $entries = @($Exemption | Where-Object { $_.Kind -eq 'Handler' -and $_.Surface -eq $surface })
    $read = { param([string] $Relative) & $ReadText (Join-HookGraphPath -Left $baseRoot -Right $Relative) }
    foreach ($entry in $entries) {
        $text = & $read $entry.HandlerFile
        if ($null -eq $text) { "EXEMPTION-MISSING: $($entry.Id) $($entry.Surface): handler file $($entry.HandlerFile) is absent"; continue }
        $found = @(Get-HookScopedImportFailureHandler -ScriptText $text -SourcePath $entry.HandlerFile | Where-Object { $_.Variable -eq $entry.Variable })
        $missingLeaf = @(@($entry.Leaf) | Where-Object { @($found | ForEach-Object Leaf) -notcontains $_ })
        if ($found.Count -eq 0 -or $missingLeaf.Count -gt 0) { "EXEMPTION-MISSING: $($entry.Id) $($entry.Surface): no handler assigning `$script:$($entry.Variable) guards $(@($entry.Leaf) -join ', ') in $($entry.HandlerFile)" }
        $consumer = & $read $entry.ConsumerFile
        if ($null -eq $consumer -or -not (Test-HookExemptionIfClause -ScriptText $consumer -Condition ('$script:' + $entry.Variable))) { "EXEMPTION-MISSING: $($entry.Id) $($entry.Surface): $($entry.ConsumerFile) has no if clause on `$script:$($entry.Variable)" }
        $deny = & $read $entry.DenyPathFile
        if ($null -eq $deny -or -not (Test-HookExemptionIfClause -ScriptText $deny -Condition $entry.DenyPathCondition -Code $entry.DenyCode)) { "DENY-CODE-MISSING: $($entry.Id) $($entry.Surface): no if clause on $($entry.DenyPathCondition) carrying $($entry.DenyCode) in $($entry.DenyPathFile)" }
    }
    foreach ($file in @(& $ListFiles $normalRoot)) {
        $normalFile = ($file -replace '\\', '/')
        $relative = $normalFile
        if ($baseRoot -and $normalFile.StartsWith($baseRoot + '/', [System.StringComparison]::OrdinalIgnoreCase)) { $relative = $normalFile.Substring($baseRoot.Length + 1) }
        $text = & $ReadText $normalFile
        if ($null -eq $text) { continue }
        foreach ($handler in @(Get-HookScopedImportFailureHandler -ScriptText $text -SourcePath $relative)) {
            $listed = @($entries | Where-Object { $_.HandlerFile -eq $handler.SourcePath -and $_.Variable -eq $handler.Variable -and @($_.Leaf) -contains $handler.Leaf })
            if ($listed.Count -eq 0) { "UNLISTED-HANDLER: $($handler.SourcePath):$($handler.Line) `$script:$($handler.Variable) guards $($handler.Leaf)" }
        }
    }
}
