#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Absolute-path classification cases for the Claude preimplementation gate.
.DESCRIPTION
    Issue #516. The gate exempts the orchestration checkpoints and the feature
    documentation prefix from its implementation classification, but both
    exemptions were written against repo-relative spellings only. The Write tool
    supplies absolute paths by contract, so neither exemption was reachable
    through that tool. These cases assert the paired relative/absolute matrix for
    both exemptions, the case-handling choices, and the mandatory negative half.

    Every case supplies an explicit not-ready checkpoint. A case that omitted it
    would fall through to the on-disk checkpoint, which is ready during an
    orchestrated run, so an allow assertion would pass vacuously without
    exercising the classification under test.

    These cases live in a new sibling suite rather than in
    enforce-orchestration-preimplementation-gate.Tests.ps1 because that file is
    already at 461 content lines against the 500-line cap.
#>

# --- Synthetic absolute prefixes -------------------------------------------------
# Each prefix below is a bare string literal. No absolute path in this suite is
# derived from the runtime environment, the current directory, the script file
# location, or a source-control query. The shipped predicate is a pure
# segment-anchored suffix match, so the real checkout root is irrelevant to every
# assertion here, and synthetic prefixes keep the suite independent of checkout
# location, operating system, and linked-worktree layout.
$WindowsForwardPrefix = 'C:/synthetic-drive-root/synthetic-checkout'
$PosixAbsolutePrefix = '/synthetic-posix-root/synthetic-checkout'
$WindowsBackslashPrefix = 'C:\synthetic-drive-root\synthetic-checkout'

# Local re-declaration of the seven repo-relative checkpoint literals. The hook
# holds these in $script:CheckpointPaths, which a sibling Context's BeforeAll in
# the existing suite does not expose to this file.
$CheckpointLiterals = @(
    'artifacts/orchestration/orchestrator-state.json'
    'artifacts/orchestration/parallel-planner-state.json'
    'artifacts/orchestration/parallel-orchestrator-state.json'
    'artifacts/orchestration/epic-planner-state.json'
    'artifacts/orchestration/epic-orchestrator-state.json'
    'artifacts/orchestration/powershell-orchestrator-state.json'
    'artifacts/orchestration/csharp-orchestrator-state.json'
)

# A .json artifact inside a feature folder. The documentation exemption is only
# reachable for the extensions in the implementation pattern, and .md is not one
# of them, so the reachable case is a .json or .yml artifact.
$DocumentationArtifact = 'docs/features/active/2026-08-23-synthetic-feature-516/evidence/other/example.json'

# Seven literals x three spellings: repo-relative, forward-slash absolute, and
# backslash absolute. The backslash spelling proves the upstream separator
# normalization still feeds the new predicate.
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

# The POSIX-shaped prefix and the leading dot-slash relative spelling. The anchor
# admits the dot-slash form through the '/' of './'.
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

# The mandatory negative half. Every case must report pass both before and after
# the fix, demonstrating the change did not simply open the gate.
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
        # must deny both before and after the fix. This asserts the accepted
        # fail-closed miss explicitly rather than leaving it undocumented.
        Reason = 'checkpoint name reached only through a parent-directory hop'
        Path   = "$WindowsForwardPrefix/artifacts/orchestration/../orchestration/orchestrator-state.json"
    }
)

Describe 'enforce-orchestration-preimplementation-gate.ps1 absolute-path classification' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
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

        function ConvertTo-WriteToolInput {
            param([Parameter(Mandatory)][string] $FilePath)

            return (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = $FilePath; content = 'synthetic content' }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-GateDecisionFor {
            param([Parameter(Mandatory)][string] $FilePath)

            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-WriteToolInput -FilePath $FilePath) `
                -CheckpointRaw (ConvertTo-NotReadyCheckpointRaw)
        }
    }

    Context 'checkpoint exemption holds in every spelling' {
        It 'allows the <Spelling> spelling of <Literal>' -ForEach $CheckpointAllowCases {
            # Arrange / Act
            $decision = Get-GateDecisionFor -FilePath $Path

            # Assert
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
}
