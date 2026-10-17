# Hook Guard Work Lists ([P0-T11])

Timestamp: 2026-10-09T22-04
Command: sh <SCRATCHPAD>/r.sh derive-worklists (runs <SCRATCHPAD>/derive-worklists.ps1 over <SCRATCHPAD>/vedges-repo.csv and <SCRATCHPAD>/vhooks-repo.csv from [P0-T9]; no W-UNRESOLVED resolutions were required, [P0-T10])
EXIT_CODE: 0
Output Summary: 49 W-HOOKS rows (all EARLY_RETURN yes), 104 W-EDGES rows (8 HELD), 2 W-COND rows (both epic-child-launch-contract.ps1), 7 W-RUNTIME rows, 209 W-NESTED rows, 1 W-NONTERM row (.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1:30), 3 W-VARDS rows; SCOPED_VARIABLE_SET_MATCH: yes, W690_REGEX_SET_MATCH: yes, TEST_LINE_SET_MATCH: yes; every HANDLER-SITE, W690-TEST-LINE, and MAP-TEST-LINE reads found or matches; validate-orchestrator-output R-DECISION Invoke-OrchestratorOutputValidation (rule b).

COUNT W-HOOKS: 49
COUNT W-EDGES: 104
COUNT W-COND: 2
COUNT W-RUNTIME: 7
COUNT W-NESTED: 209
COUNT W-NONTERM: 1
COUNT W-690: 7
COUNT W-690-TESTS: 14
COUNT W-VARDS: 3
COUNT W-FILES: 80
COUNT W-CLOSURE: 209
SCOPED_VARIABLE_SET_MATCH: yes
W690_REGEX_SET_MATCH: yes
TEST_LINE_SET_MATCH: yes

Notes:
- HANDLER-SITE lines compare the observed `if ($script:<Variable>)` consumer line with the cited consumer range; H4, H5, and H6 consumers are at the second line of their cited ranges (the first cited line is the deny-block comment), which is within the cited range and is recorded as `found`.
- The HANDLER-SITE `catch=` column lists every assignment of a non-null value to the handler variable; for H4 it also lists line 57, the #690 catch that shares the variable (section 2.3).
- W-EDGES `ChildPathLiteral` is `-` for Module rows (the column applies to dot-source rows).

## Derivation script (verbatim)

The first fenced block below is the full text of `<SCRATCHPAD>/derive-worklists.ps1`; the second is its output, containing every table.

```text
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$sp = $PSScriptRoot
$root = (Get-Location).Path
$edges = @(Get-Content -LiteralPath (Join-Path $sp 'vedges-repo.csv') | ConvertFrom-Csv)
$hooksCsv = @(Get-Content -LiteralPath (Join-Path $sp 'vhooks-repo.csv') | ConvertFrom-Csv)
$A = [System.Management.Automation.Language.Ast]
function Get-Ast([string] $Path) { $t = $null; $e = $null; [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $root $Path), [ref]$t, [ref]$e) }
function Test-InFunction($Node) { $p = $Node.Parent; while ($null -ne $p) { if ($p -is [System.Management.Automation.Language.FunctionDefinitionAst]) { return $true }; $p = $p.Parent }; return $false }
function Get-Leaf([string] $T) { if ($T -like 'UNRESOLVED*') { $T } else { Split-Path -Leaf $T } }
$selfGating = @('.claude/hooks/validate-bash.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-powershell-batch-budget.ps1')

# ---- W-HOOKS ----
$wHooks = foreach ($h in ($hooksCsv | Where-Object { $_.Hook -ne 'INLINE' })) {
    $ast = Get-Ast $h.Hook
    $lines = @(Get-Content -LiteralPath (Join-Path $root $h.Hook)).Count
    $early = @($ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.IfStatementAst] -and $_.Clauses[0].Item1.Extent.Text -eq '$MyInvocation.InvocationName -eq ''.''' }).Count -gt 0
    $eap = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq '$ErrorActionPreference' -and $n.Right.Extent.Text -eq '''Stop''' }, $true) | Where-Object { -not (Test-InFunction $_) }).Count -gt 0
    $leafName = Split-Path -Leaf $h.Hook
    $strings = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.StringConstantExpressionAst] -or $n -is [System.Management.Automation.Language.ExpandableStringExpressionAst] }, $true) | Sort-Object { $_.Extent.StartOffset })
    $prefix = $null; $rule = $null
    if ($leafName -eq 'validate-bash.ps1') { $prefix = 'HOOK_DEPENDENCY_LOAD_FAILED:'; $rule = 'a' }
    if (-not $prefix) { foreach ($s in $strings) { $m = [regex]::Match([string]$s.Value, '^[A-Z][A-Z0-9_]{3,}:'); if ($m.Success) { $prefix = $m.Value; $rule = 'b'; break } } }
    if (-not $prefix) { foreach ($s in $strings) { $v = [string]$s.Value; $i = $v.IndexOf(' received an unreadable', [System.StringComparison]::Ordinal); if ($i -ge 0) { $prefix = $v.Substring(0, $i) + ':'; $rule = 'c'; break } } }
    if (-not $prefix) { $prefix = [IO.Path]::GetFileNameWithoutExtension($leafName) + ':'; $rule = 'd' }
    $funcs = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | Sort-Object { $_.Extent.StartOffset })
    $outsideCalls = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true) | Where-Object { -not (Test-InFunction $_) } | ForEach-Object { $_.GetCommandName() })
    $dec = $null; $drule = $null
    $c = @($funcs | Where-Object { $_.Name -cmatch '^Invoke-[A-Za-z]+Decision$' }) | Select-Object -First 1
    if ($c) { $dec = $c.Name; $drule = 'a' }
    if (-not $dec) { $c = @($funcs | Where-Object { $_.Name -cmatch '^Invoke-[A-Za-z]+Validation$' -and $outsideCalls -contains $_.Name }) | Select-Object -First 1; if ($c) { $dec = $c.Name; $drule = 'b' } }
    if (-not $dec) { $c = @($funcs | Where-Object { $_.Name -cmatch '^Get-[A-Za-z]+Decision$' -and $_.Name -notmatch 'Block|Deny|Allow' }) | Select-Object -First 1; if ($c) { $dec = $c.Name; $drule = 'c' } }
    if (-not $dec) { $dec = 'NONE'; $drule = 'd' }
    [pscustomobject]@{ Surface = $h.Surface; Event = $h.Event; Hook = $h.Hook; LINES = $lines; EARLY_RETURN = $(if ($early) { 'yes' } else { 'no' }); EAP_STOP = $(if ($eap) { 'yes' } else { 'no' }); RPrefix = $prefix; RPrefixRule = $rule; RDecision = $dec; RDecisionRule = $drule; CHUNK = '' }
}
$ord = [System.StringComparer]::Ordinal
$cp = @($wHooks | Where-Object { $_.Surface -eq 'claude' -and $_.Event -eq 'PreToolUse' -and $selfGating -notcontains $_.Hook } | ForEach-Object Hook); [Array]::Sort([string[]]$cp, $ord) | Out-Null
$cpSorted = [string[]]$cp; [Array]::Sort($cpSorted, $ord)
$xp = [string[]]@($wHooks | Where-Object { $_.Surface -eq 'codex' -and $_.Event -eq 'PreToolUse' } | ForEach-Object Hook); [Array]::Sort($xp, $ord)
foreach ($w in $wHooks) {
    if ($w.Surface -eq 'claude' -and $w.Event -eq 'PreToolUse') {
        if ($selfGating -contains $w.Hook) { $w.CHUNK = 'CP-S' }
        else { $n = [Array]::IndexOf($cpSorted, $w.Hook) + 1; $w.CHUNK = $(if ($n -le 8) { 'CP-A' } elseif ($n -le 16) { 'CP-B' } else { 'CP-C' }) }
    }
    elseif ($w.Surface -eq 'claude') { $w.CHUNK = 'CS' }
    elseif ($w.Event -eq 'PreToolUse') { $n = [Array]::IndexOf($xp, $w.Hook) + 1; $w.CHUNK = $(if ($n -le 9) { 'XP-A' } else { 'XP-B' }) }
    else { $w.CHUNK = 'XS' }
}

# ---- W-EDGES / W-VARDS ----
$held = @(
    'claude|.claude/hooks/enforce-feature-folder-order.ps1|feature-folder-resolution.ps1',
    'claude|.claude/hooks/enforce-epic-wave-barrier.ps1|feature-folder-resolution.ps1',
    'claude|.claude/hooks/enforce-parallel-drift-gate.ps1|feature-folder-resolution.ps1',
    'claude|.claude/hooks/enforce-parallel-cohort-barrier.ps1|feature-folder-resolution.ps1',
    'claude|.claude/hooks/validate-orchestrator-output.ps1|validate-orchestrator-output-resolution.ps1',
    'claude|.claude/hooks/validate-orchestrator-output.ps1|WorktreeItemResolution.psm1',
    'claude|.claude/hooks/validate-orchestrator-output.ps1|WorktreeRunResolution.psm1',
    'claude|.claude/hooks/validate-orchestrator-output.ps1|OrchestratorStateEpicWaveBarrier.psm1')
$wEdges = foreach ($e in ($edges | Where-Object { $_.Hook -ne 'INLINE' -and $_.Via -eq $_.Hook -and $_.Runtime -eq 'False' -and $_.Conditional -eq 'False' })) {
    $leaf = Get-Leaf $e.Target
    $cpl = '-'; $rewrite = '-'; $kept = '-'
    if ($e.Kind -eq 'DotSource') {
        $ast = Get-Ast $e.Via
        $cmd = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.InvocationOperator -eq 'Dot' }, $true) | Where-Object { $_.Extent.StartLineNumber -eq [int]$e.Line }) | Select-Object -First 1
        $jp = @($cmd.CommandElements[0].FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Join-Path' }, $true)) | Select-Object -First 1
        $ops = @(if ($jp) { $jp.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] } })
        if ($ops.Count -ge 2 -and $ops[1] -is [System.Management.Automation.Language.StringConstantExpressionAst]) { $cpl = $ops[1].Value }
        else {
            $cpl = 'VARIABLE'
            $varText = $cmd.CommandElements[0].Extent.Text
            $assign = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq $varText }, $true)) | Select-Object -First 1
            $ajp = @($assign.Right.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Join-Path' }, $true)) | Select-Object -First 1
            $aops = @($ajp.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] })
            $rewrite = "'" + $aops[1].Value + "'"
            $name = $varText -replace '^\$(script:)?', ''
            $refs = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.VariableExpressionAst] -and ($n.VariablePath.UserPath -replace '^script:', '') -eq $name }, $true))
            $other = @($refs | Where-Object { -not [object]::ReferenceEquals($_, $assign.Left) -and $_.Extent.StartLineNumber -ne [int]$e.Line })
            $kept = $(if ($other.Count -gt 0) { 'yes' } else { 'no' })
        }
    }
    [pscustomobject]@{ Surface = $e.Surface; Event = $e.Event; Hook = $e.Hook; Line = $e.Line; Kind = $e.Kind; Target = $e.Target; Leaf = $leaf; ChildPathLiteral = $cpl; Guarded = $e.Guarded; ErrorActionStop = $e.ErrorActionStop; HELD = $(if ($held -contains "$($e.Surface)|$($e.Hook)|$leaf") { 'yes' } else { 'no' }); RewriteLiteral = $rewrite; AssignmentKept = $kept }
}
$wVards = @($wEdges | Where-Object { $_.ChildPathLiteral -eq 'VARIABLE' })
$wCond = @($edges | Where-Object { $_.Conditional -eq 'True' -and $_.Runtime -eq 'False' })
$wRuntime = foreach ($e in ($edges | Where-Object { $_.Runtime -eq 'True' -and (Get-Leaf $_.Target) -ne 'MermaidValidation.psm1' })) {
    $ast = Get-Ast $e.Via
    $cmd = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Import-Module' }, $true) | Where-Object { $_.Extent.StartLineNumber -eq [int]$e.Line }) | Select-Object -First 1
    $lazy = 'NONE'
    $p = $cmd.Parent
    while ($null -ne $p -and $p -isnot [System.Management.Automation.Language.IfStatementAst]) { $p = $p.Parent }
    if ($null -ne $p) {
        $gc = @($p.Clauses[0].Item1.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Get-Command' }, $true)) | Select-Object -First 1
        if ($gc) { $el = @($gc.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] }) | Select-Object -First 1; if ($el) { $lazy = $el.Extent.Text.Trim("'", '"') } }
    }
    [pscustomobject]@{ Surface = $e.Surface; Hook = $e.Hook; Via = $e.Via; Line = $e.Line; Target = $e.Target; LazyFunction = $lazy }
}
$wRuntime = @($wRuntime)
$wNested = @($edges | Where-Object { $_.Hook -ne 'INLINE' -and $_.Via -ne $_.Hook -and $_.Runtime -eq 'False' })
$eapCache = @{}
$wNonterm = @($wNested | Where-Object { $_.Kind -eq 'Module' -and $_.ErrorActionStop -eq 'False' } | Where-Object {
        if (-not $eapCache.ContainsKey($_.Via)) { $eapCache[$_.Via] = @(Get-Content -LiteralPath (Join-Path $root $_.Via)) }
        $before = @($eapCache[$_.Via] | Select-Object -First ([int]$_.Line - 1))
        @($before | Where-Object { $_ -match '^\s*\$ErrorActionPreference\s*=\s*''Stop''' }).Count -eq 0
    } | Sort-Object Via, Line -Unique)
$haltDs = @($wNested | Where-Object { $_.Kind -eq 'DotSource' -and $_.Via -like '*.psm1' })
$wUnresolved = @($edges | Where-Object { $_.Target -like 'UNRESOLVED*' })
$w690 = @('.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-epic-merge-gate-resolution.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1')
$handlerFiles = @('.claude/hooks/enforce-feature-folder-order.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1', '.claude/hooks/validate-orchestrator-output.ps1', '.claude/hooks/validate-orchestrator-output-resolution.ps1')
$t = 'tests/scripts/claude-hooks/'
$w690Tests = @(
    "1|${t}enforce-epic-merge-gate.ItemResolution.Tests.ps1|224|'WorktreeItemResolution.psm1'", "2|${t}enforce-epic-merge-gate.ItemResolution.Tests.ps1|230|`$null",
    "3|${t}enforce-epic-merge-gate.WorktreeResolution.Tests.ps1|239|'WorktreeRunResolution.psm1'", "4|${t}enforce-epic-merge-gate.WorktreeResolution.Tests.ps1|246|`$null",
    "5|${t}enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1|160|'WorktreeRunResolution.psm1'", "6|${t}enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1|167|`$null",
    "7|${t}enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1|184|`$null",
    "8|${t}enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1|190|`$null", "9|${t}enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1|202|'WorktreeItemResolution.psm1'", "10|${t}enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1|208|`$null",
    "11|${t}enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1|163|'WorktreeRunResolution.psm1'", "12|${t}enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1|170|`$null",
    "13|${t}enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1|148|`$null", "14|${t}enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1|159|`$null")
$mapLines = @(
    "H1|${t}enforce-feature-folder-order.Tests.ps1|328|FeatureFolderOrderResolutionImportFailure", "H1|${t}enforce-feature-folder-order.Tests.ps1|334|FeatureFolderOrderResolutionImportFailure",
    "H2|${t}enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1|205|OrchestrationFeatureFolderResolutionImportFailure", "H2|${t}enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1|212|OrchestrationFeatureFolderResolutionImportFailure",
    "H2|tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1|202|OrchestrationFeatureFolderResolutionImportFailure", "H2|tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1|209|OrchestrationFeatureFolderResolutionImportFailure",
    "H3|${t}enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1|88|PrdFeatureFolderResolutionImportFailure", "H3|${t}enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1|93|PrdFeatureFolderResolutionImportFailure",
    "H4|${t}enforce-epic-wave-barrier.FolderResolution.Tests.ps1|209|EpicWaveBarrierResolutionImportFailure", "H4|${t}enforce-epic-wave-barrier.FolderResolution.Tests.ps1|215|EpicWaveBarrierResolutionImportFailure", "H4|${t}enforce-epic-wave-barrier.FolderResolution.Tests.ps1|242|EpicWaveBarrierResolutionImportFailure",
    "H5|${t}enforce-parallel-drift-gate.FolderResolution.Tests.ps1|137|ParallelDriftGateResolutionImportFailure", "H5|${t}enforce-parallel-drift-gate.FolderResolution.Tests.ps1|143|ParallelDriftGateResolutionImportFailure", "H5|${t}enforce-parallel-drift-gate.FolderResolution.Tests.ps1|170|ParallelDriftGateResolutionImportFailure",
    "H6|${t}enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1|135|ParallelCohortBarrierResolutionImportFailure", "H6|${t}enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1|141|ParallelCohortBarrierResolutionImportFailure", "H6|${t}enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1|168|ParallelCohortBarrierResolutionImportFailure",
    "H7|${t}validate-orchestrator-output-resolution.Tests.ps1|226|OrchestratorOutputResolverImportFailure", "H8|${t}validate-orchestrator-output.WaveBarrier.Tests.ps1|242|OrchestratorOutputWaveBarrierImportFailure")
$wFiles = @(@($wHooks | ForEach-Object Hook) + @($wNested | Where-Object { $_.Via -match '^\.(claude|codex)/(hooks|lib|scripts)/' -and $_.Via -notmatch '^\.codex/lib/' -and $_.Via -notmatch '^\.claude/scripts/' } | ForEach-Object Via) + @($wNonterm | ForEach-Object Via)) | Sort-Object -Unique
$wClosure = foreach ($w in ($wHooks | Where-Object Surface -eq 'claude')) {
    $files = @(@($w.Hook) + @($edges | Where-Object { $_.Surface -eq 'claude' -and $_.Hook -eq $w.Hook -and $_.Target -notlike 'UNRESOLVED*' } | ForEach-Object { $_.Via; $_.Target })) | Sort-Object -Unique
    [pscustomobject]@{ Hook = $w.Hook; Files = $files }
}

# ---- Output ----
function Out-Table($Rows, [string[]] $Cols) { '| ' + ($Cols -join ' | ') + ' |'; '|' + (($Cols | ForEach-Object { '---' }) -join '|') + '|'; foreach ($r in $Rows) { '| ' + (($Cols | ForEach-Object { ([string]$r.$_).Replace('|', '\|') }) -join ' | ') + ' |' } }
'## W-HOOKS'; Out-Table $wHooks @('Surface', 'Event', 'Hook', 'LINES', 'EARLY_RETURN', 'EAP_STOP', 'RPrefix', 'RPrefixRule', 'RDecision', 'RDecisionRule', 'CHUNK')
'## W-EDGES'; Out-Table $wEdges @('Surface', 'Hook', 'Line', 'Kind', 'Target', 'Leaf', 'ChildPathLiteral', 'Guarded', 'ErrorActionStop', 'HELD')
'## W-COND'; Out-Table $wCond @('Surface', 'Hook', 'Via', 'Line', 'Kind', 'Target')
'## W-RUNTIME'; Out-Table $wRuntime @('Surface', 'Hook', 'Via', 'Line', 'Target', 'LazyFunction')
'## W-NESTED'; Out-Table $wNested @('Surface', 'Hook', 'Via', 'Line', 'Kind', 'Target', 'Guarded', 'Covered', 'ErrorActionStop')
'## W-NONTERM'; Out-Table $wNonterm @('Surface', 'Hook', 'Via', 'Line', 'Target')
"W-NESTED DotSource rows with a .psm1 Via (halt condition): $($haltDs.Count)"
'## W-UNRESOLVED'; "none ($($wUnresolved.Count) records)"
'## W-690'; $w690 | ForEach-Object { "- $_" }
'## W-690-TESTS'; $w690Tests | ForEach-Object { $p = $_.Split('|'); "- row $($p[0]) | $($p[1]):$($p[2]) | $($p[3])" }
'## W-VARDS'; foreach ($v in $wVards) { "- $($v.Surface) | $($v.Hook):$($v.Line) | REWRITE_LITERAL: $($v.RewriteLiteral) | ASSIGNMENT_KEPT: $($v.AssignmentKept)" }
'## W-FILES'; $wFiles | ForEach-Object { "- $_" }
'## W-CLOSURE'; foreach ($c in $wClosure) { "- $($c.Hook) | $($c.Files -join ', ')" }

# (i) scoped variable inventory
'## SCOPED-VARIABLE-INVENTORY'
$inv = foreach ($f in @(Get-ChildItem -LiteralPath (Join-Path $root '.claude/hooks') -Filter '*.ps1' -File) + @(Get-ChildItem -LiteralPath (Join-Path $root '.codex/hooks') -Filter '*.ps1' -File)) {
    $rel = [IO.Path]::GetRelativePath($root, $f.FullName) -replace '\\', '/'
    $i = 0
    foreach ($l in (Get-Content -LiteralPath $f.FullName)) { $i++; $m = [regex]::Match($l, '^\s*\$script:(\w+ImportFailure)\s*=\s*\$null'); if ($m.Success) { "$rel|$i|$($m.Groups[1].Value)" } }
}
$expected = @('.claude/hooks/enforce-feature-folder-order.ps1|45|FeatureFolderOrderResolutionImportFailure', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|36|OrchestrationFeatureFolderResolutionImportFailure', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|36|OrchestrationFeatureFolderResolutionImportFailure', '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1|34|PrdFeatureFolderResolutionImportFailure', '.claude/hooks/enforce-epic-wave-barrier.ps1|52|EpicWaveBarrierResolutionImportFailure', '.claude/hooks/enforce-parallel-drift-gate.ps1|77|ParallelDriftGateResolutionImportFailure', '.claude/hooks/enforce-parallel-cohort-barrier.ps1|66|ParallelCohortBarrierResolutionImportFailure', '.claude/hooks/validate-orchestrator-output.ps1|55|OrchestratorOutputResolverImportFailure', '.claude/hooks/validate-orchestrator-output.ps1|56|OrchestratorOutputWaveBarrierImportFailure', '.claude/hooks/enforce-epic-merge-gate-resolution.ps1|38|EpicMergeGateResolutionImportFailure', '.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1|33|EpicWorktreeGateResolutionImportFailure', '.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1|46|OrchestrationGateResolutionImportFailure', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1|49|ParallelWorktreeGateResolutionImportFailure')
$inv | ForEach-Object { "- $_" }
"SCOPED_VARIABLE_SET_MATCH: $(if (@(Compare-Object @($inv) $expected).Count -eq 0) { 'yes' } else { 'no' })"

# (ii) handler sites
'## HANDLER-SITES'
$handlers = @(
    @{ Id = 'H1'; File = '.claude/hooks/enforce-feature-folder-order.ps1'; Var = 'FeatureFolderOrderResolutionImportFailure'; Init = 45; Catch = @(50); Cons = @('.claude/hooks/enforce-feature-folder-order.ps1|210|214') },
    @{ Id = 'H2 claude'; File = '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'; Var = 'OrchestrationFeatureFolderResolutionImportFailure'; Init = 36; Catch = @(41); Cons = @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|242|242', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|403|403', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|468|468') },
    @{ Id = 'H2 codex'; File = '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'; Var = 'OrchestrationFeatureFolderResolutionImportFailure'; Init = 36; Catch = @(41); Cons = @('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|242|242', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|400|400', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|465|465') },
    @{ Id = 'H3'; File = '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'; Var = 'PrdFeatureFolderResolutionImportFailure'; Init = 34; Catch = @(39); Cons = @('.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1|64|66') },
    @{ Id = 'H4'; File = '.claude/hooks/enforce-epic-wave-barrier.ps1'; Var = 'EpicWaveBarrierResolutionImportFailure'; Init = 52; Catch = @(66, 67, 68); Cons = @('.claude/hooks/enforce-epic-wave-barrier.ps1|274|279') },
    @{ Id = 'H5'; File = '.claude/hooks/enforce-parallel-drift-gate.ps1'; Var = 'ParallelDriftGateResolutionImportFailure'; Init = 77; Catch = @(92, 93); Cons = @('.claude/hooks/enforce-parallel-drift-gate.ps1|321|326') },
    @{ Id = 'H6'; File = '.claude/hooks/enforce-parallel-cohort-barrier.ps1'; Var = 'ParallelCohortBarrierResolutionImportFailure'; Init = 66; Catch = @(81, 82, 83, 84); Cons = @('.claude/hooks/enforce-parallel-cohort-barrier.ps1|239|244') },
    @{ Id = 'H7'; File = '.claude/hooks/validate-orchestrator-output.ps1'; Var = 'OrchestratorOutputResolverImportFailure'; Init = 55; Catch = @(57..71); Cons = @('.claude/hooks/validate-orchestrator-output.ps1|383|388') },
    @{ Id = 'H8'; File = '.claude/hooks/validate-orchestrator-output.ps1'; Var = 'OrchestratorOutputWaveBarrierImportFailure'; Init = 56; Catch = @(72..77); Cons = @('.claude/hooks/validate-orchestrator-output-resolution.ps1|294|297') })
foreach ($h in $handlers) {
    $lines = @(Get-Content -LiteralPath (Join-Path $root $h.File))
    $initObs = @(for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq "`$script:$($h.Var) = `$null") { $i + 1 } })
    $catchObs = @(for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match ('\$script:' + $h.Var + '\s*=\s*(''|\$resolverModule)')) { $i + 1 } })
    $consObs = @(); $consStatus = 'found'
    foreach ($c in $h.Cons) {
        $cf, $cs, $ce = $c.Split('|')
        $cl = @(Get-Content -LiteralPath (Join-Path $root $cf))
        $hit = @(@(for ($i = 0; $i -lt $cl.Count; $i++) { if ($cl[$i] -match ('^\s*if \(\$script:' + $h.Var + '\)')) { $i + 1 } }) | Where-Object { $_ -ge [int]$cs -and $_ -le [int]$ce })
        if ($hit.Count -eq 0) { $consStatus = 'absent' } else { $consObs += "$(Split-Path -Leaf $cf):$($hit[0])" }
    }
    $status = 'found'
    if ($initObs.Count -eq 0 -or $catchObs.Count -eq 0 -or $consStatus -eq 'absent') { $status = 'absent' }
    elseif ($initObs[0] -ne $h.Init) { $status = "moved to $($initObs[0])" }
    elseif (@($catchObs | Where-Object { $h.Catch -contains $_ }).Count -eq 0) { $status = "moved to $($catchObs[0])" }
    "HANDLER-SITE: $($h.Id) | $($h.File) | init=$($initObs -join ',') | catch=$($catchObs -join ',') | consumer=$($consObs -join ',') | $status"
}

# (iii) W-690 regex set
$regexSet = @(Get-ChildItem -LiteralPath (Join-Path $root '.claude/hooks') -Filter '*.ps1' -File | Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match '\$script:\w+ImportFailure' -or (Get-Content -LiteralPath $_.FullName -Raw).Contains('Import guard (issue #690)') } | ForEach-Object { '.claude/hooks/' + $_.Name })
"W690_REGEX_SET: $($regexSet -join ', ')"
"W690_REGEX_SET_MATCH: $(if (@(Compare-Object $regexSet (@($w690) + $handlerFiles)).Count -eq 0) { 'yes' } else { 'no' })"

# (iv) test lines
'## TEST-LINES'
$testHits = @(Get-ChildItem -LiteralPath (Join-Path $root 'tests') -Filter '*.ps1' -File -Recurse | ForEach-Object {
        $rel = [IO.Path]::GetRelativePath($root, $_.FullName) -replace '\\', '/'
        $i = 0; foreach ($l in (Get-Content -LiteralPath $_.FullName)) { $i++; if ($l -match '\$script:\w+ImportFailure') { "${rel}:$i" } }
    })
$expectedLines = @()
foreach ($r in $w690Tests) {
    $p = $r.Split('|'); $l = @(Get-Content -LiteralPath (Join-Path $root $p[1]))[[int]$p[2] - 1]
    $ok = $l -match ('\$script:\w+ImportFailure\s*=\s*' + [regex]::Escape($p[3]) + '\s*$')
    "W690-TEST-LINE: $($p[0]) | $($p[1]):$($p[2]) | $(if ($ok) { 'matches' } else { 'differs' })"; $expectedLines += "$($p[1]):$($p[2])"
}
foreach ($r in $mapLines) {
    $p = $r.Split('|'); $l = @(Get-Content -LiteralPath (Join-Path $root $p[1]))[[int]$p[2] - 1]
    $ok = $l.Contains('$script:' + $p[3])
    "MAP-TEST-LINE: $($p[0]) | $($p[1]):$($p[2]) | $(if ($ok) { 'matches' } else { 'differs' })"; $expectedLines += "$($p[1]):$($p[2])"
}
"TEST_LINE_HITS: $($testHits.Count)"
"TEST_LINE_SET_MATCH: $(if ($testHits.Count -eq 33 -and @(Compare-Object $testHits $expectedLines).Count -eq 0) { 'yes' } else { 'no' })"

'## COUNTS'
"COUNT W-HOOKS: $(@($wHooks).Count)"
"COUNT W-EDGES: $(@($wEdges).Count)"
"COUNT W-HELD-EDGES: $(@($wEdges | Where-Object HELD -eq 'yes').Count)"
"COUNT W-COND: $($wCond.Count)"
"COUNT W-RUNTIME: $($wRuntime.Count)"
"COUNT W-NESTED: $($wNested.Count)"
"COUNT W-NONTERM: $($wNonterm.Count)"
"COUNT W-UNRESOLVED: $($wUnresolved.Count)"
"COUNT W-690: $($w690.Count)"
"COUNT W-690-TESTS: $($w690Tests.Count)"
"COUNT W-VARDS: $($wVards.Count)"
"COUNT W-FILES: $(@($wFiles).Count)"
"COUNT W-CLOSURE: $(@($wClosure | ForEach-Object { $_.Files }).Count)"
# machine-readable exports for later tasks
$wHooks | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath (Join-Path $sp 'whooks.csv')
$wEdges | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath (Join-Path $sp 'wedges.csv')
$wRuntime | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath (Join-Path $sp 'wruntime.csv')
$wNonterm | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath (Join-Path $sp 'wnonterm.csv')
$wFiles | Set-Content -LiteralPath (Join-Path $sp 'wfiles.txt')
$wClosure | ForEach-Object { foreach ($f in $_.Files) { "$($_.Hook)|$f" } } | Set-Content -LiteralPath (Join-Path $sp 'wclosure.txt')
```

```text
## W-HOOKS
| Surface | Event | Hook | LINES | EARLY_RETURN | EAP_STOP | RPrefix | RPrefixRule | RDecision | RDecisionRule | CHUNK |
|---|---|---|---|---|---|---|---|---|---|---|
| claude | PreToolUse | .claude/hooks/check-powershell-test-purity.ps1 | 145 | yes | no | PowerShell unit test purity hook: | c | Invoke-PowerShellTestPurityDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/check-python-test-purity.ps1 | 147 | yes | no | Python unit test purity hook: | c | Invoke-PythonTestPurityDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-checkpoint-monotonic.ps1 | 309 | yes | no | CHECKPOINT_MONOTONIC_BLOCKED: | b | Invoke-CheckpointMonotonicDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-completion-consistency.ps1 | 465 | yes | no | COMPLETION_CONSISTENCY_BLOCKED: | b | Invoke-CompletionConsistencyDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-discovery-artifact-gate.ps1 | 232 | yes | no | DISCOVERY_ARTIFACT_GATE_BLOCKED: | b | Invoke-DiscoveryArtifactGateDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-epic-invocation-origin.ps1 | 280 | yes | no | EPIC_INVOCATION_ORIGIN_BLOCKED: | b | Invoke-EpicInvocationOriginDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-epic-merge-gate.ps1 | 470 | yes | no | EPIC_MERGE_GATE_BLOCKED: | b | Invoke-EpicMergeGateDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-epic-wave-barrier.ps1 | 380 | yes | no | EPIC_WAVE_BARRIER_BLOCKED: | b | Invoke-EpicWaveBarrierDecision | a | CP-A |
| claude | PreToolUse | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 459 | yes | no | EPIC_WORKTREE_REMOVAL_BLOCKED: | b | Invoke-EpicWorktreeRemovalGateDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-evidence-locations.ps1 | 223 | yes | no | EVIDENCE_LOCATION_BLOCKED: | b | Invoke-EvidenceLocationDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-feature-folder-order.ps1 | 281 | yes | no | FEATURE_FOLDER_ORDER_BLOCKED: | b | Invoke-FeatureFolderOrderDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-mermaid-validation.ps1 | 402 | yes | no | MERMAID_VALIDATION_BLOCKED: | b | Invoke-MermaidValidationDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-model-routing-receipt.ps1 | 295 | yes | no | MODEL_ROUTING_RECEIPT_BLOCKED: | b | Invoke-ModelRoutingReceiptDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 468 | yes | no | PREIMPLEMENTATION_GATE_BLOCKED: | b | Invoke-OrchestrationPreimplementationGateDecision | a | CP-S |
| claude | PreToolUse | .claude/hooks/enforce-parallel-abandon-gate.ps1 | 353 | yes | no | enforce-parallel-abandon-gate: | d | Invoke-ParallelAbandonGateDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 348 | yes | no | PARALLEL_COHORT_BARRIER_BLOCKED: | b | Invoke-ParallelCohortBarrierDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-parallel-drift-gate.ps1 | 454 | yes | no | PARALLEL_DRIFT_GATE_BLOCKED: | b | Invoke-ParallelDriftGateDecision | a | CP-B |
| claude | PreToolUse | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 464 | yes | no | PARALLEL_WORKTREE_REMOVAL_BLOCKED: | b | Invoke-ParallelWorktreeRemovalGateDecision | a | CP-C |
| claude | PreToolUse | .claude/hooks/enforce-powershell-batch-budget.ps1 | 486 | yes | no | POWERSHELL_LARGE_PATH_REQUIRED: | b | Invoke-PowerShellBatchBudgetDecision | a | CP-S |
| claude | PreToolUse | .claude/hooks/enforce-pr-author-skill.ps1 | 326 | yes | no | PR_AUTHOR_SKILL_BLOCKED: | b | Invoke-PrAuthorSkillDecision | a | CP-C |
| claude | PreToolUse | .claude/hooks/enforce-prd-feature-before-planner.ps1 | 477 | yes | no | PRD_FEATURE_BLOCKED: | b | Invoke-PrdFeatureBeforePlannerDecision | a | CP-C |
| claude | PreToolUse | .claude/hooks/enforce-promotion-mcp-only.ps1 | 306 | yes | no | PROMOTION_MCP_ONLY_BLOCKED: | b | Invoke-PromotionMcpOnlyDecision | a | CP-C |
| claude | PreToolUse | .claude/hooks/enforce-python-batch-budget.ps1 | 489 | yes | no | PYTHON_LARGE_PATH_REQUIRED: | b | Invoke-PythonBatchBudgetDecision | a | CP-C |
| claude | PreToolUse | .claude/hooks/validate-bash.ps1 | 442 | yes | no | HOOK_DEPENDENCY_LOAD_FAILED: | a | Invoke-ValidateBashDecision | a | CP-S |
| claude | SubagentStop | .claude/hooks/validate-discovery-artifact-gate.ps1 | 257 | yes | no | DISCOVERY_ARTIFACT_GATE_BLOCKED: | b | Invoke-DiscoveryArtifactGateValidation | b | CS |
| claude | SubagentStop | .claude/hooks/validate-feature-review-coverage.ps1 | 459 | yes | yes | validate-feature-review-coverage: | d | Invoke-FeatureReviewCoverageValidation | b | CS |
| claude | SubagentStop | .claude/hooks/validate-orchestrator-output.ps1 | 482 | yes | yes | ORCHESTRATOR_CHECKPOINT_UNRESOLVED: | b | Invoke-OrchestratorOutputValidation | b | CS |
| claude | SubagentStop | .claude/hooks/validate-planner-output.ps1 | 410 | yes | yes | validate-planner-output: | d | Invoke-PlannerOutputValidation | b | CS |
| claude | SubagentStop | .claude/hooks/validate-pr-author-output.ps1 | 136 | yes | no | PR_AUTHOR_OUTPUT_MISSING: | b | Get-PrAuthorOutputDecision | c | CS |
| claude | SubagentStop | .claude/hooks/validate-prd-feature-output.ps1 | 91 | yes | yes | validate-prd-feature-output: | d | Invoke-PrdFeatureOutputValidation | b | CS |
| codex | PreToolUse | .codex/hooks/check-powershell-test-purity.ps1 | 166 | yes | no | check-powershell-test-purity: | d | Invoke-PowerShellTestPurityDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/check-python-test-purity.ps1 | 166 | yes | no | check-python-test-purity: | d | Invoke-PythonTestPurityDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-checkpoint-monotonic.ps1 | 339 | yes | no | CHECKPOINT_ORDER_BLOCKED: | b | Invoke-CheckpointMonotonicDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-codex-model-routing.ps1 | 198 | yes | no | MODEL_ROUTING_ATTESTATION_BLOCKED: | b | Invoke-CodexModelRoutingDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-completion-consistency.ps1 | 486 | yes | no | COMPLETION_CONSISTENCY_BLOCKED: | b | Invoke-CompletionConsistencyDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 334 | yes | no | EPIC_WORKTREE_BINDING_BLOCKED: | b | Invoke-CodexEpicChildGuardDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-epic-merge-gate.ps1 | 379 | yes | no | EPIC_MERGE_GATE_BLOCKED: | b | Invoke-CodexEpicMergeDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-epic-planning-only.ps1 | 365 | yes | no | EPIC_PLANNING_ONLY_BLOCKED: | b | Invoke-EpicPlanningOnlyDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-epic-root-invocation.ps1 | 135 | yes | no | EPIC_INVOCATION_ORIGIN_BLOCKED: | b | Invoke-EpicRootInvocationDecision | a | XP-A |
| codex | PreToolUse | .codex/hooks/enforce-epic-wave-barrier.ps1 | 295 | yes | no | EPIC_WAVE_BARRIER_BLOCKED: | b | Invoke-CodexEpicWaveDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 184 | yes | no | EPIC_WORKTREE_REMOVAL_BLOCKED: | b | Invoke-CodexWorktreeRemovalDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/enforce-evidence-locations.ps1 | 196 | yes | no | EVIDENCE_LOCATION_BLOCKED: | b | Invoke-EvidenceLocationDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 496 | yes | no | PREIMPLEMENTATION_GATE_BLOCKED: | b | Invoke-OrchestrationPreimplementationGateDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/enforce-powershell-batch-budget.ps1 | 341 | yes | no | POWERSHELL_LARGE_PATH_REQUIRED: | b | Invoke-PowerShellBatchBudgetDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/enforce-promotion-mcp-only.ps1 | 291 | yes | no | PROMOTION_MCP_ONLY_BLOCKED: | b | Invoke-PromotionMcpOnlyDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/enforce-python-batch-budget.ps1 | 344 | yes | no | PYTHON_LARGE_PATH_REQUIRED: | b | Invoke-PythonBatchBudgetDecision | a | XP-B |
| codex | PreToolUse | .codex/hooks/validate-bash.ps1 | 313 | yes | no | HOOK_DEPENDENCY_LOAD_FAILED: | a | Invoke-ValidateBashDecision | a | XP-B |
| codex | SubagentStop | .codex/hooks/validate-codex-subagent-routing.ps1 | 154 | yes | no | MODEL_ROUTING_ATTESTATION_BLOCKED: | b | Invoke-CodexSubagentStopDecision | a | XS |
| codex | SubagentStop | .codex/hooks/validate-feature-review-coverage.ps1 | 300 | yes | yes | validate-feature-review-coverage: | d | NONE | d | XS |
## W-EDGES
| Surface | Hook | Line | Kind | Target | Leaf | ChildPathLiteral | Guarded | ErrorActionStop | HELD |
|---|---|---|---|---|---|---|---|---|---|
| claude | .claude/hooks/check-powershell-test-purity.ps1 | 36 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/check-python-test-purity.ps1 | 33 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-checkpoint-monotonic.ps1 | 47 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-completion-consistency.ps1 | 51 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-completion-consistency.ps1 | 55 | DotSource | .claude/hooks/enforce-completion-helpers.ps1 | enforce-completion-helpers.ps1 | VARIABLE | False | False | no |
| claude | .claude/hooks/enforce-discovery-artifact-gate.ps1 | 37 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-epic-invocation-origin.ps1 | 47 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | 63 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | 66 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | 67 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | 69 | DotSource | .claude/hooks/enforce-epic-merge-gate-authorization.ps1 | enforce-epic-merge-gate-authorization.ps1 | enforce-epic-merge-gate-authorization.ps1 | False | False | no |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | 71 | DotSource | .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | enforce-epic-merge-gate-resolution.ps1 | enforce-epic-merge-gate-resolution.ps1 | False | False | no |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | 49 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | 54 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | WorktreeRunResolution.psm1 | - | True | True | no |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | 63 | DotSource | .claude/hooks/feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | True | False | yes |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 72 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 75 | Module | .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | CleanupWorktreeManifest.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 78 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 79 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 81 | DotSource | .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | enforce-epic-worktree-removal-gate-resolution.ps1 | enforce-epic-worktree-removal-gate-resolution.ps1 | False | False | no |
| claude | .claude/hooks/enforce-evidence-locations.ps1 | 45 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-feature-folder-order.ps1 | 41 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-feature-folder-order.ps1 | 47 | DotSource | .claude/hooks/feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | True | False | yes |
| claude | .claude/hooks/enforce-mermaid-validation.ps1 | 62 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | 50 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | 53 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | WorktreeItemResolution.psm1 | - | False | True | no |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | 55 | Module | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | EpicScopeResolution.psm1 | - | False | True | no |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 9 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 14 | DotSource | .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | enforce-orchestration-preimplementation-gate-helpers.ps1 | enforce-orchestration-preimplementation-gate-helpers.ps1 | False | False | no |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 20 | DotSource | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | enforce-orchestration-preimplementation-gate-modes.ps1 | enforce-orchestration-preimplementation-gate-modes.ps1 | False | False | no |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 25 | DotSource | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | False | False | no |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 28 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 29 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | 37 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | 51 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | 52 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 62 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 69 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | WorktreeRunResolution.psm1 | - | True | True | no |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 69 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | WorktreeItemResolution.psm1 | - | True | True | no |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 79 | DotSource | .claude/hooks/feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | True | False | yes |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 92 | DotSource | .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | enforce-parallel-cohort-barrier-helpers.ps1 | enforce-parallel-cohort-barrier-helpers.ps1 | False | False | no |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | 73 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | 80 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | WorktreeItemResolution.psm1 | - | True | True | no |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | 80 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | WorktreeRunResolution.psm1 | - | True | True | no |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | 90 | DotSource | .claude/hooks/feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | feature-folder-resolution.ps1 | True | False | yes |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | 99 | DotSource | .claude/hooks/enforce-parallel-drift-gate-helpers.ps1 | enforce-parallel-drift-gate-helpers.ps1 | VARIABLE | False | False | no |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 37 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 40 | Module | .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | CleanupWorktreeManifest.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 45 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 46 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 51 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | WorktreeRunResolution.psm1 | - | True | True | no |
| claude | .claude/hooks/enforce-powershell-batch-budget.ps1 | 62 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-powershell-batch-budget.ps1 | 63 | DotSource | .claude/hooks/enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | False | False | no |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | 53 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | 59 | Module | .claude/lib/orchestrator-state/OrchestratorState.psm1 | OrchestratorState.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | 164 | DotSource | .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | enforce-pr-author-skill.epic-base-branch.ps1 | enforce-pr-author-skill.epic-base-branch.ps1 | False | False | no |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | 168 | DotSource | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | enforce-pr-author-skill-helpers.ps1 | enforce-pr-author-skill-helpers.ps1 | False | False | no |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | 103 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | 111 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | WorktreeTargetResolution.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | 112 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | WorktreeItemResolution.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | 113 | DotSource | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | enforce-prd-feature-before-planner-helpers.ps1 | enforce-prd-feature-before-planner-helpers.ps1 | False | False | no |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | 33 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | 38 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | 39 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/enforce-python-batch-budget.ps1 | 62 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/enforce-python-batch-budget.ps1 | 63 | DotSource | .claude/hooks/enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | False | False | no |
| claude | .claude/hooks/validate-bash.ps1 | 41 | Module | .claude/lib/hook-payload/HookPayload.psm1 | HookPayload.psm1 | - | False | False | no |
| claude | .claude/hooks/validate-bash.ps1 | 45 | DotSource | .claude/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| claude | .claude/hooks/validate-bash.ps1 | 46 | DotSource | .claude/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | 51 | Module | .claude/lib/orchestrator-state/OrchestratorState.psm1 | OrchestratorState.psm1 | - | False | False | no |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | 58 | DotSource | .claude/hooks/validate-orchestrator-output-resolution.ps1 | validate-orchestrator-output-resolution.ps1 | validate-orchestrator-output-resolution.ps1 | True | False | yes |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | 66 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | WorktreeItemResolution.psm1 | - | True | True | yes |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | 66 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | WorktreeRunResolution.psm1 | - | True | True | yes |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | 73 | Module | .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 | OrchestratorStateEpicWaveBarrier.psm1 | - | True | True | yes |
| codex | .codex/hooks/check-powershell-test-purity.ps1 | 38 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/check-python-test-purity.ps1 | 35 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-checkpoint-monotonic.ps1 | 49 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-codex-model-routing.ps1 | 8 | DotSource | .codex/hooks/codex-authority-store.ps1 | codex-authority-store.ps1 | codex-authority-store.ps1 | False | False | no |
| codex | .codex/hooks/enforce-codex-model-routing.ps1 | 9 | DotSource | .codex/hooks/codex-agent-profile-attestation.ps1 | codex-agent-profile-attestation.ps1 | codex-agent-profile-attestation.ps1 | False | False | no |
| codex | .codex/hooks/enforce-completion-consistency.ps1 | 51 | DotSource | .codex/hooks/enforce-checkpoint-monotonic.ps1 | enforce-checkpoint-monotonic.ps1 | enforce-checkpoint-monotonic.ps1 | False | False | no |
| codex | .codex/hooks/enforce-completion-consistency.ps1 | 57 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-completion-consistency.ps1 | 62 | DotSource | .codex/hooks/enforce-completion-helpers.ps1 | enforce-completion-helpers.ps1 | VARIABLE | False | False | no |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | 11 | DotSource | .codex/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | 12 | DotSource | .codex/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| codex | .codex/hooks/enforce-epic-root-invocation.ps1 | 12 | DotSource | .codex/hooks/codex-authority-store.ps1 | codex-authority-store.ps1 | codex-authority-store.ps1 | False | False | no |
| codex | .codex/hooks/enforce-epic-wave-barrier.ps1 | 14 | DotSource | .codex/hooks/codex-epic-child-launch-attestation.ps1 | codex-epic-child-launch-attestation.ps1 | codex-epic-child-launch-attestation.ps1 | False | False | no |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 11 | DotSource | .codex/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 12 | DotSource | .codex/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| codex | .codex/hooks/enforce-evidence-locations.ps1 | 46 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 18 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 23 | DotSource | .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | enforce-orchestration-preimplementation-gate-helpers.ps1 | enforce-orchestration-preimplementation-gate-helpers.ps1 | False | False | no |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 29 | DotSource | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | enforce-orchestration-preimplementation-gate-modes.ps1 | enforce-orchestration-preimplementation-gate-modes.ps1 | False | False | no |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 32 | DotSource | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | False | False | no |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 34 | DotSource | .codex/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 35 | DotSource | .codex/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| codex | .codex/hooks/enforce-powershell-batch-budget.ps1 | 51 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-powershell-batch-budget.ps1 | 54 | DotSource | .codex/hooks/enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | False | False | no |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | 35 | DotSource | .codex/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | 36 | DotSource | .codex/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| codex | .codex/hooks/enforce-python-batch-budget.ps1 | 51 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | codex-pretooluse-file-mapping.ps1 | False | False | no |
| codex | .codex/hooks/enforce-python-batch-budget.ps1 | 54 | DotSource | .codex/hooks/enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | enforce-batch-budget-route.ps1 | False | False | no |
| codex | .codex/hooks/validate-bash.ps1 | 21 | DotSource | .codex/hooks/hook-command-scanner.ps1 | hook-command-scanner.ps1 | hook-command-scanner.ps1 | False | False | no |
| codex | .codex/hooks/validate-bash.ps1 | 22 | DotSource | .codex/hooks/hook-command-invocation.ps1 | hook-command-invocation.ps1 | hook-command-invocation.ps1 | False | False | no |
| codex | .codex/hooks/validate-codex-subagent-routing.ps1 | 12 | DotSource | .codex/hooks/codex-authority-store.ps1 | codex-authority-store.ps1 | codex-authority-store.ps1 | False | False | no |
## W-COND
| Surface | Hook | Via | Line | Kind | Target |
|---|---|---|---|---|---|
| codex | .codex/hooks/enforce-epic-child-worktree-binding.ps1 | .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 16 | DotSource | .codex/scripts/epic-child-launch-contract.ps1 |
| codex | .codex/hooks/enforce-epic-wave-barrier.ps1 | .codex/hooks/codex-epic-child-launch-attestation.ps1 | 5 | DotSource | .codex/scripts/epic-child-launch-contract.ps1 |
## W-RUNTIME
| Surface | Hook | Via | Line | Target | LazyFunction |
|---|---|---|---|---|---|
| claude | .claude/hooks/enforce-discovery-artifact-gate.ps1 | .claude/hooks/enforce-discovery-artifact-gate.ps1 | 72 | .claude/lib/discovery-validation/DiscoveryValidation.psm1 | NONE |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorState.psm1 | 431 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | Get-OrchestratorStateUnconditionalError |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 93 | .claude/lib/orchestrator-state/OrchestratorState.psm1 | NONE |
| claude | .claude/hooks/validate-discovery-artifact-gate.ps1 | .claude/hooks/validate-discovery-artifact-gate.ps1 | 73 | .claude/lib/discovery-validation/DiscoveryValidation.psm1 | NONE |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/hooks/validate-orchestrator-output.ps1 | 295 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | Test-OrchestratorStateCompletionReadiness |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorState.psm1 | 431 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | Get-OrchestratorStateUnconditionalError |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 93 | .claude/lib/orchestrator-state/OrchestratorState.psm1 | NONE |
## W-NESTED
| Surface | Hook | Via | Line | Kind | Target | Guarded | Covered | ErrorActionStop |
|---|---|---|---|---|---|---|---|---|
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 40 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | True | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 46 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | True | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 35 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | True | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidLineScanner.psm1 | 39 | Module | .claude/lib/mermaid/MermaidGrammar.psm1 | False | True | True |
| claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidValidation.psm1 | 46 | Module | .claude/lib/mermaid/MermaidGrammar.psm1 | False | True | True |
| claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidValidation.psm1 | 47 | Module | .claude/lib/mermaid/MermaidLineScanner.psm1 | False | True | True |
| claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidValidation.psm1 | 48 | Module | .claude/lib/mermaid/MermaidMarkdownFences.psm1 | False | True | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 40 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 41 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 42 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | True | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | Module | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | True | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | True | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 55 | Module | .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | False | False | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 57 | DotSource | .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | False | False | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 38 | DotSource | .claude/hooks/feature-folder-resolution.ps1 | True | True | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 40 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 41 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 42 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 36 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 37 | DotSource | .claude/hooks/hook-command-invocation.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 43 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 44 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 48 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 50 | Module | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 51 | Module | .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 53 | DotSource | .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 14 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 15 | DotSource | .claude/hooks/hook-command-invocation.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | 34 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | 36 | Module | .claude/lib/codex-routing/CodexDeployment.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | 37 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | 39 | Module | .claude/lib/codex-routing/CodexTopology.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | 31 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | 33 | Module | .claude/lib/model-routing/ModelRouting.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | 39 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | 40 | Module | .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | 34 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 51 | Module | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 52 | Module | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 53 | Module | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 54 | Module | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 55 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 40 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 41 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 42 | Module | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 30 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | False |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 36 | DotSource | .claude/hooks/feature-folder-resolution.ps1 | True | True | False |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | False | True |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1 | 21 | DotSource | .claude/hooks/hook-command-scanner.ps1 | False | False | False |
| claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1 | 22 | DotSource | .claude/hooks/hook-command-payload.ps1 | False | False | False |
| claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1 | 23 | DotSource | .claude/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1 | 24 | DotSource | .claude/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-scanner.ps1 | 20 | DotSource | .claude/hooks/hook-command-heredoc.ps1 | False | False | False |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | 34 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | 36 | Module | .claude/lib/codex-routing/CodexDeployment.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | 37 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | 39 | Module | .claude/lib/codex-routing/CodexTopology.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 56 | Module | .claude/lib/orchestrator-state/OrchestratorState.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 58 | Module | .claude/lib/model-routing/ModelRouting.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 59 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 60 | Module | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 61 | Module | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 62 | Module | .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 63 | Module | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | 45 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | 46 | Module | .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 31 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | 31 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | 33 | Module | .claude/lib/model-routing/ModelRouting.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | 39 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | 40 | Module | .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | 34 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | 59 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | 60 | Module | .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | 61 | Module | .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 | 44 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 51 | Module | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 52 | Module | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 53 | Module | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 54 | Module | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 55 | Module | .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | False | False | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 31 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 32 | Module | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | False | True | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 33 | Module | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | False | True | True |
| claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 27 | Module | .claude/lib/worktree-resolution/WorktreeResolution.psm1 | False | True | True |
| codex | .codex/hooks/enforce-completion-consistency.ps1 | .codex/hooks/enforce-checkpoint-monotonic.ps1 | 49 | DotSource | .codex/hooks/codex-pretooluse-file-mapping.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 21 | DotSource | .codex/hooks/hook-command-scanner.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 22 | DotSource | .codex/hooks/hook-command-payload.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 23 | DotSource | .codex/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 24 | DotSource | .codex/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-scanner.ps1 | 20 | DotSource | .codex/hooks/hook-command-heredoc.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-wave-barrier.ps1 | .codex/hooks/codex-epic-child-launch-attestation.ps1 | 5 | DotSource | .codex/scripts/epic-child-launch-contract.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 21 | DotSource | .codex/hooks/hook-command-scanner.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 22 | DotSource | .codex/hooks/hook-command-payload.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 23 | DotSource | .codex/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 24 | DotSource | .codex/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-scanner.ps1 | 20 | DotSource | .codex/hooks/hook-command-heredoc.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 37 | DotSource | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 38 | DotSource | .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 38 | DotSource | .codex/hooks/feature-folder-resolution.ps1 | True | True | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 21 | DotSource | .codex/hooks/hook-command-scanner.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 22 | DotSource | .codex/hooks/hook-command-payload.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 23 | DotSource | .codex/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1 | 24 | DotSource | .codex/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-scanner.ps1 | 20 | DotSource | .codex/hooks/hook-command-heredoc.ps1 | False | False | False |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1 | 21 | DotSource | .codex/hooks/hook-command-scanner.ps1 | False | False | False |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1 | 22 | DotSource | .codex/hooks/hook-command-payload.ps1 | False | False | False |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1 | 23 | DotSource | .codex/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1 | 24 | DotSource | .codex/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-scanner.ps1 | 20 | DotSource | .codex/hooks/hook-command-heredoc.ps1 | False | False | False |
| codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1 | 21 | DotSource | .codex/hooks/hook-command-scanner.ps1 | False | False | False |
| codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1 | 22 | DotSource | .codex/hooks/hook-command-payload.ps1 | False | False | False |
| codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1 | 23 | DotSource | .codex/hooks/hook-command-payload-powershell.ps1 | False | False | False |
| codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1 | 24 | DotSource | .codex/hooks/hook-command-invocation-operands.ps1 | False | False | False |
| codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-scanner.ps1 | 20 | DotSource | .codex/hooks/hook-command-heredoc.ps1 | False | False | False |
## W-NONTERM
| Surface | Hook | Via | Line | Target |
|---|---|---|---|---|
| claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 30 | .claude/lib/worktree-resolution/WorktreeResolution.psm1 |
W-NESTED DotSource rows with a .psm1 Via (halt condition): 0
## W-UNRESOLVED
none (0 records)
## W-690
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
- .claude/hooks/enforce-epic-wave-barrier.ps1
- .claude/hooks/enforce-parallel-drift-gate.ps1
- .claude/hooks/enforce-parallel-cohort-barrier.ps1
- .claude/hooks/enforce-epic-merge-gate-resolution.ps1
- .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
## W-690-TESTS
- row 1 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:224 | 'WorktreeItemResolution.psm1'
- row 2 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:230 | $null
- row 3 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:239 | 'WorktreeRunResolution.psm1'
- row 4 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:246 | $null
- row 5 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1:160 | 'WorktreeRunResolution.psm1'
- row 6 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1:167 | $null
- row 7 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:184 | $null
- row 8 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1:190 | $null
- row 9 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1:202 | 'WorktreeItemResolution.psm1'
- row 10 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1:208 | $null
- row 11 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:163 | 'WorktreeRunResolution.psm1'
- row 12 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:170 | $null
- row 13 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1:148 | $null
- row 14 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1:159 | $null
## W-VARDS
- claude | .claude/hooks/enforce-completion-consistency.ps1:55 | REWRITE_LITERAL: 'enforce-completion-helpers.ps1' | ASSIGNMENT_KEPT: no
- claude | .claude/hooks/enforce-parallel-drift-gate.ps1:99 | REWRITE_LITERAL: 'enforce-parallel-drift-gate-helpers.ps1' | ASSIGNMENT_KEPT: no
- codex | .codex/hooks/enforce-completion-consistency.ps1:62 | REWRITE_LITERAL: 'enforce-completion-helpers.ps1' | ASSIGNMENT_KEPT: no
## W-FILES
- .claude/hooks/check-powershell-test-purity.ps1
- .claude/hooks/check-python-test-purity.ps1
- .claude/hooks/enforce-checkpoint-monotonic.ps1
- .claude/hooks/enforce-completion-consistency.ps1
- .claude/hooks/enforce-discovery-artifact-gate.ps1
- .claude/hooks/enforce-epic-invocation-origin.ps1
- .claude/hooks/enforce-epic-merge-gate-resolution.ps1
- .claude/hooks/enforce-epic-merge-gate.ps1
- .claude/hooks/enforce-epic-wave-barrier.ps1
- .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1
- .claude/hooks/enforce-evidence-locations.ps1
- .claude/hooks/enforce-feature-folder-order.ps1
- .claude/hooks/enforce-mermaid-validation.ps1
- .claude/hooks/enforce-model-routing-receipt.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
- .claude/hooks/enforce-parallel-abandon-gate.ps1
- .claude/hooks/enforce-parallel-cohort-barrier.ps1
- .claude/hooks/enforce-parallel-drift-gate.ps1
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
- .claude/hooks/enforce-powershell-batch-budget.ps1
- .claude/hooks/enforce-pr-author-skill-helpers.ps1
- .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
- .claude/hooks/enforce-pr-author-skill.ps1
- .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
- .claude/hooks/enforce-prd-feature-before-planner.ps1
- .claude/hooks/enforce-promotion-mcp-only.ps1
- .claude/hooks/enforce-python-batch-budget.ps1
- .claude/hooks/hook-command-invocation.ps1
- .claude/hooks/hook-command-scanner.ps1
- .claude/hooks/validate-bash.ps1
- .claude/hooks/validate-discovery-artifact-gate.ps1
- .claude/hooks/validate-feature-review-coverage.ps1
- .claude/hooks/validate-orchestrator-output.ps1
- .claude/hooks/validate-planner-output.ps1
- .claude/hooks/validate-pr-author-output.ps1
- .claude/hooks/validate-prd-feature-output.ps1
- .claude/lib/mermaid/MermaidLineScanner.psm1
- .claude/lib/mermaid/MermaidValidation.psm1
- .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1
- .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1
- .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1
- .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1
- .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
- .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1
- .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1
- .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1
- .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1
- .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1
- .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1
- .claude/lib/worktree-resolution/WorktreeItemResolution.psm1
- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1
- .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .codex/hooks/check-powershell-test-purity.ps1
- .codex/hooks/check-python-test-purity.ps1
- .codex/hooks/codex-epic-child-launch-attestation.ps1
- .codex/hooks/enforce-checkpoint-monotonic.ps1
- .codex/hooks/enforce-codex-model-routing.ps1
- .codex/hooks/enforce-completion-consistency.ps1
- .codex/hooks/enforce-epic-child-worktree-binding.ps1
- .codex/hooks/enforce-epic-merge-gate.ps1
- .codex/hooks/enforce-epic-planning-only.ps1
- .codex/hooks/enforce-epic-root-invocation.ps1
- .codex/hooks/enforce-epic-wave-barrier.ps1
- .codex/hooks/enforce-epic-worktree-removal-gate.ps1
- .codex/hooks/enforce-evidence-locations.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
- .codex/hooks/enforce-powershell-batch-budget.ps1
- .codex/hooks/enforce-promotion-mcp-only.ps1
- .codex/hooks/enforce-python-batch-budget.ps1
- .codex/hooks/hook-command-invocation.ps1
- .codex/hooks/hook-command-scanner.ps1
- .codex/hooks/validate-bash.ps1
- .codex/hooks/validate-codex-subagent-routing.ps1
- .codex/hooks/validate-feature-review-coverage.ps1
## W-CLOSURE
- .claude/hooks/check-powershell-test-purity.ps1 | .claude/hooks/check-powershell-test-purity.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/check-python-test-purity.ps1 | .claude/hooks/check-python-test-purity.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-checkpoint-monotonic.ps1 | .claude/hooks/enforce-checkpoint-monotonic.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-completion-consistency.ps1 | .claude/hooks/enforce-completion-consistency.ps1, .claude/hooks/enforce-completion-helpers.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-discovery-artifact-gate.ps1 | .claude/hooks/enforce-discovery-artifact-gate.ps1, .claude/lib/discovery-validation/DiscoveryValidation.psm1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-epic-invocation-origin.ps1 | .claude/hooks/enforce-epic-invocation-origin.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/enforce-epic-merge-gate-authorization.ps1, .claude/hooks/enforce-epic-merge-gate-resolution.ps1, .claude/hooks/enforce-epic-merge-gate.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/hooks/enforce-epic-wave-barrier.ps1, .claude/hooks/feature-folder-resolution.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1, .claude/hooks/enforce-epic-worktree-removal-gate.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-evidence-locations.ps1 | .claude/hooks/enforce-evidence-locations.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-feature-folder-order.ps1 | .claude/hooks/enforce-feature-folder-order.ps1, .claude/hooks/feature-folder-resolution.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-mermaid-validation.ps1 | .claude/hooks/enforce-mermaid-validation.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/mermaid/MermaidGrammar.psm1, .claude/lib/mermaid/MermaidLineScanner.psm1, .claude/lib/mermaid/MermaidMarkdownFences.psm1, .claude/lib/mermaid/MermaidValidation.psm1
- .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/hooks/enforce-model-routing-receipt.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/EpicScopeResolution.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, .claude/hooks/feature-folder-resolution.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/EpicScopeReadiness.psm1, .claude/lib/worktree-resolution/EpicScopeResolution.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/enforce-parallel-abandon-gate.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1, .claude/hooks/enforce-parallel-cohort-barrier.ps1, .claude/hooks/feature-folder-resolution.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/hooks/enforce-parallel-drift-gate-helpers.ps1, .claude/hooks/enforce-parallel-drift-gate.ps1, .claude/hooks/feature-folder-resolution.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-powershell-batch-budget.ps1 | .claude/hooks/enforce-batch-budget-route.ps1, .claude/hooks/enforce-powershell-batch-budget.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1, .claude/hooks/enforce-pr-author-skill.artifact-root.ps1, .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1, .claude/hooks/enforce-pr-author-skill.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/codex-routing/CodexDeployment.psm1, .claude/lib/codex-routing/CodexTopology.psm1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/model-routing/ModelRouting.psm1, .claude/lib/orchestrator-state/OrchestratorState.psm1, .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1, .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1, .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1, .claude/lib/worktree-resolution/EpicScopeReadiness.psm1, .claude/lib/worktree-resolution/EpicScopeResolution.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1, .claude/hooks/enforce-prd-feature-before-planner.ps1, .claude/hooks/feature-folder-resolution.ps1, .claude/lib/hook-payload/HookPayload.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/enforce-promotion-mcp-only.ps1, .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/enforce-python-batch-budget.ps1 | .claude/hooks/enforce-batch-budget-route.ps1, .claude/hooks/enforce-python-batch-budget.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-heredoc.ps1, .claude/hooks/hook-command-invocation-operands.ps1, .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-payload-powershell.ps1, .claude/hooks/hook-command-payload.ps1, .claude/hooks/hook-command-scanner.ps1, .claude/hooks/validate-bash.ps1, .claude/lib/hook-payload/HookPayload.psm1
- .claude/hooks/validate-discovery-artifact-gate.ps1 | .claude/hooks/validate-discovery-artifact-gate.ps1, .claude/lib/discovery-validation/DiscoveryValidation.psm1
- .claude/hooks/validate-feature-review-coverage.ps1 | .claude/hooks/validate-feature-review-coverage.ps1
- .claude/hooks/validate-orchestrator-output.ps1 | .claude/hooks/validate-orchestrator-output-resolution.ps1, .claude/hooks/validate-orchestrator-output.ps1, .claude/lib/codex-routing/CodexDeployment.psm1, .claude/lib/codex-routing/CodexTopology.psm1, .claude/lib/model-routing/ModelRouting.psm1, .claude/lib/orchestrator-state/OrchestratorState.psm1, .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1, .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1, .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1, .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1, .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1, .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1, .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1, .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1, .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1, .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1, .claude/lib/worktree-resolution/WorktreeItemResolution.psm1, .claude/lib/worktree-resolution/WorktreeResolution.psm1, .claude/lib/worktree-resolution/WorktreeRunResolution.psm1, .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
- .claude/hooks/validate-planner-output.ps1 | .claude/hooks/validate-planner-output.ps1
- .claude/hooks/validate-pr-author-output.ps1 | .claude/hooks/validate-pr-author-output.ps1
- .claude/hooks/validate-prd-feature-output.ps1 | .claude/hooks/validate-prd-feature-output.ps1
## SCOPED-VARIABLE-INVENTORY
- .claude/hooks/enforce-epic-merge-gate-resolution.ps1|38|EpicMergeGateResolutionImportFailure
- .claude/hooks/enforce-epic-wave-barrier.ps1|52|EpicWaveBarrierResolutionImportFailure
- .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1|33|EpicWorktreeGateResolutionImportFailure
- .claude/hooks/enforce-feature-folder-order.ps1|45|FeatureFolderOrderResolutionImportFailure
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1|46|OrchestrationGateResolutionImportFailure
- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|36|OrchestrationFeatureFolderResolutionImportFailure
- .claude/hooks/enforce-parallel-cohort-barrier.ps1|66|ParallelCohortBarrierResolutionImportFailure
- .claude/hooks/enforce-parallel-drift-gate.ps1|77|ParallelDriftGateResolutionImportFailure
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1|49|ParallelWorktreeGateResolutionImportFailure
- .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1|34|PrdFeatureFolderResolutionImportFailure
- .claude/hooks/validate-orchestrator-output.ps1|55|OrchestratorOutputResolverImportFailure
- .claude/hooks/validate-orchestrator-output.ps1|56|OrchestratorOutputWaveBarrierImportFailure
- .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1|36|OrchestrationFeatureFolderResolutionImportFailure
SCOPED_VARIABLE_SET_MATCH: yes
## HANDLER-SITES
HANDLER-SITE: H1 | .claude/hooks/enforce-feature-folder-order.ps1 | init=45 | catch=50 | consumer=enforce-feature-folder-order.ps1:210 | found
HANDLER-SITE: H2 claude | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | init=36 | catch=41 | consumer=enforce-orchestration-preimplementation-gate-modes.ps1:242,enforce-orchestration-preimplementation-gate-modes.ps1:403,enforce-orchestration-preimplementation-gate-modes.ps1:468 | found
HANDLER-SITE: H2 codex | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | init=36 | catch=41 | consumer=enforce-orchestration-preimplementation-gate-modes.ps1:242,enforce-orchestration-preimplementation-gate-modes.ps1:400,enforce-orchestration-preimplementation-gate-modes.ps1:465 | found
HANDLER-SITE: H3 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | init=34 | catch=39 | consumer=enforce-prd-feature-before-planner-helpers.ps1:64 | found
HANDLER-SITE: H4 | .claude/hooks/enforce-epic-wave-barrier.ps1 | init=52 | catch=57,67 | consumer=enforce-epic-wave-barrier.ps1:275 | found
HANDLER-SITE: H5 | .claude/hooks/enforce-parallel-drift-gate.ps1 | init=77 | catch=93 | consumer=enforce-parallel-drift-gate.ps1:322 | found
HANDLER-SITE: H6 | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | init=66 | catch=83 | consumer=enforce-parallel-cohort-barrier.ps1:240 | found
HANDLER-SITE: H7 | .claude/hooks/validate-orchestrator-output.ps1 | init=55 | catch=61,69 | consumer=validate-orchestrator-output.ps1:385 | found
HANDLER-SITE: H8 | .claude/hooks/validate-orchestrator-output.ps1 | init=56 | catch=76 | consumer=validate-orchestrator-output-resolution.ps1:294 | found
W690_REGEX_SET: .claude/hooks/enforce-epic-merge-gate-resolution.ps1, .claude/hooks/enforce-epic-wave-barrier.ps1, .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1, .claude/hooks/enforce-feature-folder-order.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1, .claude/hooks/enforce-parallel-cohort-barrier.ps1, .claude/hooks/enforce-parallel-drift-gate.ps1, .claude/hooks/enforce-parallel-worktree-removal-gate.ps1, .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1, .claude/hooks/validate-orchestrator-output-resolution.ps1, .claude/hooks/validate-orchestrator-output.ps1
W690_REGEX_SET_MATCH: yes
## TEST-LINES
W690-TEST-LINE: 1 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:224 | matches
W690-TEST-LINE: 2 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:230 | matches
W690-TEST-LINE: 3 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:239 | matches
W690-TEST-LINE: 4 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:246 | matches
W690-TEST-LINE: 5 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1:160 | matches
W690-TEST-LINE: 6 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1:167 | matches
W690-TEST-LINE: 7 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:184 | matches
W690-TEST-LINE: 8 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1:190 | matches
W690-TEST-LINE: 9 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1:202 | matches
W690-TEST-LINE: 10 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1:208 | matches
W690-TEST-LINE: 11 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:163 | matches
W690-TEST-LINE: 12 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:170 | matches
W690-TEST-LINE: 13 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1:148 | matches
W690-TEST-LINE: 14 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1:159 | matches
MAP-TEST-LINE: H1 | tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1:328 | matches
MAP-TEST-LINE: H1 | tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1:334 | matches
MAP-TEST-LINE: H2 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1:205 | matches
MAP-TEST-LINE: H2 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1:212 | matches
MAP-TEST-LINE: H2 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1:202 | matches
MAP-TEST-LINE: H2 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1:209 | matches
MAP-TEST-LINE: H3 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1:88 | matches
MAP-TEST-LINE: H3 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1:93 | matches
MAP-TEST-LINE: H4 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1:209 | matches
MAP-TEST-LINE: H4 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1:215 | matches
MAP-TEST-LINE: H4 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1:242 | matches
MAP-TEST-LINE: H5 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1:137 | matches
MAP-TEST-LINE: H5 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1:143 | matches
MAP-TEST-LINE: H5 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1:170 | matches
MAP-TEST-LINE: H6 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1:135 | matches
MAP-TEST-LINE: H6 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1:141 | matches
MAP-TEST-LINE: H6 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1:168 | matches
MAP-TEST-LINE: H7 | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1:226 | matches
MAP-TEST-LINE: H8 | tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1:242 | matches
TEST_LINE_HITS: 33
TEST_LINE_SET_MATCH: yes
## COUNTS
COUNT W-HOOKS: 49
COUNT W-EDGES: 104
COUNT W-HELD-EDGES: 8
COUNT W-COND: 2
COUNT W-RUNTIME: 7
COUNT W-NESTED: 209
COUNT W-NONTERM: 1
COUNT W-UNRESOLVED: 0
COUNT W-690: 7
COUNT W-690-TESTS: 14
COUNT W-VARDS: 3
COUNT W-FILES: 80
COUNT W-CLOSURE: 209
```
