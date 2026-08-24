#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Absolute-path classification cases for the Codex preimplementation gate.
.DESCRIPTION
    Issue #516. The Codex copy of the gate carries the same two defective
    predicates as the Claude copy: the checkpoint exemption was a membership
    check against seven repo-relative literals and the documentation exemption
    was a case-sensitive prefix test, so neither was reachable for an absolute
    spelling. These cases assert the paired relative/absolute matrix for both
    exemptions, the case-handling choices, the mandatory negative half, and the
    idempotence proof for the apply_patch call site, which passes repo-relative
    paths harvested from file markers.

    Every case supplies an explicit not-ready checkpoint. A case that omitted it
    would fall through to the on-disk checkpoint, which is ready during an
    orchestrated run, so an allow assertion would pass vacuously.

    Unlike the Claude decision function, the Codex one parses a flat, unenveloped
    tool_input object carrying file_path or command at the top level. The local
    builder below emits that shape.

    These cases live in a new sibling suite rather than in
    legacy-codex-hook-contracts.Tests.ps1 because that file is already at 494
    content lines against the 500-line cap.
#>

# --- Synthetic absolute prefixes -------------------------------------------------
# Each prefix below is a bare string literal. No absolute path in this suite is
# derived from the runtime environment, the current directory, the script file
# location, or a source-control query. The shipped predicate is a pure
# segment-anchored suffix match, so the real checkout root is irrelevant to every
# assertion here.
$WindowsForwardPrefix = 'C:/synthetic-drive-root/synthetic-checkout'
$PosixAbsolutePrefix = '/synthetic-posix-root/synthetic-checkout'
$WindowsBackslashPrefix = 'C:\synthetic-drive-root\synthetic-checkout'

# Local re-declaration of the seven repo-relative checkpoint literals.
$CheckpointLiterals = @(
    'artifacts/orchestration/orchestrator-state.json'
    'artifacts/orchestration/parallel-planner-state.json'
    'artifacts/orchestration/parallel-orchestrator-state.json'
    'artifacts/orchestration/epic-planner-state.json'
    'artifacts/orchestration/epic-orchestrator-state.json'
    'artifacts/orchestration/powershell-orchestrator-state.json'
    'artifacts/orchestration/csharp-orchestrator-state.json'
)

$DocumentationArtifact = 'docs/features/active/2026-08-23-synthetic-feature-516/evidence/other/example.json'

$CheckpointAllowCases = @(
    foreach ($literal in $CheckpointLiterals) {
        @{ Spelling = 'repo-relative'; Literal = $literal; Path = $literal }
        @{ Spelling = 'forward-slash absolute'; Literal = $literal; Path = "$WindowsForwardPrefix/$literal" }
        @{
            Spelling = 'backslash absolute'
            Literal  = $literal
            Path     = $WindowsBackslashPrefix + '\' + ($literal -replace '/', '\')
        }
    }
)

$AdditionalCheckpointAllowCases = @(
    @{
        Spelling = 'POSIX-shaped absolute'
        Literal  = 'artifacts/orchestration/orchestrator-state.json'
        Path     = "$PosixAbsolutePrefix/artifacts/orchestration/orchestrator-state.json"
    }
    @{
        Spelling = 'leading dot-slash relative'
        Literal  = 'artifacts/orchestration/orchestrator-state.json'
        Path     = './artifacts/orchestration/orchestrator-state.json'
    }
)

$DocumentationAllowCases = @(
    @{ Spelling = 'repo-relative'; Path = $DocumentationArtifact }
    @{ Spelling = 'forward-slash absolute'; Path = "$WindowsForwardPrefix/$DocumentationArtifact" }
    @{
        Spelling = 'backslash absolute'
        Path     = $WindowsBackslashPrefix + '\' + ($DocumentationArtifact -replace '/', '\')
    }
)

# Case handling is deliberately zero-delta: case-insensitive for the checkpoint
# literal set, case-sensitive for the documentation prefix. Both cases are bound
# as -ForEach data rather than read from a variable inside the It body, because a
# value assigned at discovery time is not visible during the run phase.
$CaseSensitivityCases = @(
    @{
        Description = 'allows an absolute checkpoint path whose literal differs only in letter case'
        Path        = "$WindowsForwardPrefix/ARTIFACTS/ORCHESTRATION/ORCHESTRATOR-STATE.JSON"
        Expected    = 'allow'
    }
    @{
        Description = 'denies an absolute path whose documentation prefix differs only in letter case'
        Path        = "$WindowsForwardPrefix/DOCS/FEATURES/ACTIVE/2026-08-23-synthetic-feature-516/evidence/other/example.json"
        Expected    = 'deny'
    }
)

$ImplementationDenyCases = @(
    @{
        Reason = 'production .ps1 file'
        Path   = "$WindowsForwardPrefix/scripts/powershell/Synthetic-Module.ps1"
    }
    @{
        Reason = 'production .py file'
        Path   = "$WindowsForwardPrefix/scripts/dev_tools/synthetic_module.py"
    }
    @{
        Reason = 'orchestration JSON whose name is not one of the seven literals'
        Path   = "$WindowsForwardPrefix/artifacts/orchestration/not-a-checkpoint.json"
    }
    @{
        Reason = 'checkpoint-named JSON with no preceding artifacts/orchestration segment'
        Path   = "$WindowsForwardPrefix/some/other/place/orchestrator-state.json"
    }
    @{
        # The parent-directory hop sits inside the artifacts/orchestration segment
        # itself, so the text carries no contiguous checkpoint literal and the path
        # must deny both before and after the fix.
        Reason = 'checkpoint name reached only through a parent-directory hop'
        Path   = "$WindowsForwardPrefix/artifacts/orchestration/../orchestration/orchestrator-state.json"
    }
)

Describe 'codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-NotReadyCheckpointRaw {
            <#
            .SYNOPSIS
                Builds a checkpoint whose route id is empty and whose lifecycle
                readiness is false, so Test-OrchestrationReady cannot short-circuit
                the decision to allow.
            #>
            param()

            return @{
                'issue-num'      = '516'
                'feature-folder' = 'docs/features/active/2026-08-23-synthetic-feature-516'
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }

        function ConvertTo-FlatToolInput {
            <#
            .SYNOPSIS
                Emits the flat, unenveloped tool_input object the Codex decision
                function parses, carrying file_path or command at the top level.
            #>
            param(
                [string] $FilePath,
                [string] $Command
            )

            $map = @{}
            if ($FilePath) { $map['file_path'] = $FilePath }
            if ($Command) { $map['command'] = $Command }
            return ($map | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-GateDecisionFor {
            param([Parameter(Mandatory)][string] $FilePath)

            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-FlatToolInput -FilePath $FilePath) `
                -CheckpointRaw (ConvertTo-NotReadyCheckpointRaw)
        }

        function Get-GateDecisionForCommand {
            param([Parameter(Mandatory)][string] $Command)

            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-FlatToolInput -Command $Command) `
                -CheckpointRaw (ConvertTo-NotReadyCheckpointRaw)
        }
    }

    Context 'checkpoint exemption holds in every spelling' {
        It 'allows the <Spelling> spelling of <Literal>' -ForEach $CheckpointAllowCases {
            $decision = Get-GateDecisionFor -FilePath $Path

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'admits the <Spelling> spelling of <Literal>' -ForEach $AdditionalCheckpointAllowCases {
            $decision = Get-GateDecisionFor -FilePath $Path

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'documentation exemption holds in every spelling' {
        It 'allows the <Spelling> spelling of a feature-folder .json artifact' -ForEach $DocumentationAllowCases {
            $decision = Get-GateDecisionFor -FilePath $Path

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'case handling is zero-delta against the previous operators' {
        # The allow case preserves the case-insensitive -contains semantics
        # exactly; the deny case preserves the case-sensitive String.StartsWith
        # semantics exactly.
        It '<Description>' -ForEach $CaseSensitivityCases {
            $decision = Get-GateDecisionFor -FilePath $Path

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected
        }
    }

    Context 'negative half stays denied' {
        It 'denies a synthetic absolute path ending in a <Reason>' -ForEach $ImplementationDenyCases {
            $decision = Get-GateDecisionFor -FilePath $Path

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'apply_patch file markers classify exactly as before' {
        It 'denies a repo-relative file-marker path for a production .ps1 file' {
            $decision = Get-GateDecisionForCommand -Command '*** Add File: scripts/powershell/Synthetic-Module.ps1'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows a repo-relative file-marker path for a checkpoint literal' {
            $decision = Get-GateDecisionForCommand -Command '*** Update File: artifacts/orchestration/orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
