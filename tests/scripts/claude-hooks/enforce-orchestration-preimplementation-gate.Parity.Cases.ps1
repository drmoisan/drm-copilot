<#
    Shared case table for the preimplementation-gate behavioral parity test (issue #737,
    the remainder of issue #555). Data only: this file holds hashtable and array literals
    and no command. It is dot-sourced by enforce-orchestration-preimplementation-gate.Parity.Tests.ps1,
    once at discovery and once at run time.

    Every expected value was derived by reading the post-#732 gates, .claude/hooks and
    .codex/hooks, and each was confirmed by evaluating both gates. A row carries one Expected
    value that holds on both surfaces. A row whose expectation differs by surface also carries
    Surfaces (the per-surface expectation, keyed claude and codex) and Reason, and has a matching
    DeclaredDivergence entry.

    The string THROWS marks a call whose mandatory string parameter rejects an empty argument.
#>

$script:NotReadyCheckpoint = '{"issue-num":"","feature-folder":"","route_id":"","lifecycle_ready":false}'
$script:ReadyCheckpoint = '{"issue-num":"737","feature-folder":"docs/features/active/2026-09-27-x-737","route_id":"small","lifecycle_ready":true}'

$script:PathCases = @(
    @{ Name = 'a repository-relative implementation path'; Input = 'src/module/service.py'; Expected = $true }
    @{ Name = 'an absolute implementation path'; Input = '/home/user/repo/src/app.cs'; Expected = $true }
    @{ Name = 'a case-variant implementation path'; Input = 'SRC/Service.PY'; Expected = $true }
    @{ Name = 'a case-variant feature documentation path with a json extension'; Input = 'Docs/Features/Active/x/spec.json'; Expected = $true }
    @{ Name = 'a checkpoint file name'; Input = 'artifacts/orchestration/orchestrator-state.json'; Expected = $false }
    @{ Name = 'an absolute checkpoint file name'; Input = 'C:/work/artifacts/orchestration/orchestrator-state.json'; Expected = $false }
    @{ Name = 'a feature documentation path'; Input = 'docs/features/active/2026-10-01-x-1/plan.md'; Expected = $false }
    @{ Name = 'an evidence path with a json extension'; Input = 'docs/features/active/x/evidence/qa-gates/result.json'; Expected = $false }
    @{ Name = 'a non-implementation extension'; Input = 'README.md'; Expected = $false }
    @{ Name = 'an empty string'; Input = ''; Expected = 'THROWS' }
)

$script:CommandCases = @(
    @{ Name = 'a write redirect'; Input = 'echo hi > src/x.py'; Expected = $false }
    @{ Name = 'a git add of an implementation path'; Input = 'git add src/app.ps1'; Expected = $true }
    @{ Name = 'a read-only git log'; Input = 'git log --oneline -5'; Expected = $false }
    @{ Name = 'git status'; Input = 'git status'; Expected = $false }
    @{ Name = 'a formatter invocation through poetry'; Input = 'poetry run black src/'; Expected = $true }
    @{ Name = 'a formatter invocation through npx'; Input = 'npx prettier --check .'; Expected = $true }
    @{ Name = 'a documentation-only git commit'; Input = 'git commit -m x -- docs/features/active/x/plan.md'; Expected = $false }
    @{ Name = 'a read-only file listing'; Input = 'Get-Content README.md'; Expected = $false }
    @{ Name = 'an empty string'; Input = ''; Expected = 'THROWS' }
)

$script:DelegationCases = @(
    @{
        Name     = 'a delegation to an implementation agent'
        Input    = @{ subagent_type = 'atomic-executor'; prompt = 'Implement the change.' }
        Expected = @{ Preparation = $false; Implementation = $true }
    }
    @{
        Name     = 'a delegation to a preparation orchestrator'
        Input    = @{ subagent_type = 'orchestrator'; prompt = 'Preparation mode: true. route_id: preparation.' }
        Expected = @{ Preparation = $true; Implementation = $false }
    }
    @{
        Name     = 'a delegation to an orchestrator that is not in preparation mode'
        Input    = @{ subagent_type = 'orchestrator'; prompt = 'Run the item.' }
        Expected = @{ Preparation = $false; Implementation = $true }
    }
    @{
        Name     = 'a delegation to a non-implementation agent'
        Input    = @{ subagent_type = 'atomic-planner'; prompt = 'Plan it.' }
        Expected = @{ Preparation = $false; Implementation = $false }
    }
    @{
        Name     = 'a non-delegation tool input'
        Input    = @{ command = 'git status' }
        Expected = @{ Preparation = $false; Implementation = $false }
    }
    @{
        Name     = 'an empty input'
        Input    = $null
        Expected = @{ Preparation = $false; Implementation = $false }
    }
    @{
        Name     = 'an orchestrator subagent type padded with whitespace'
        Input    = @{ subagent_type = ' orchestrator '; prompt = 'Run the item.' }
        Expected = @{ Preparation = $false; Implementation = $false }
        Surfaces = @{
            claude = @{ Preparation = $false; Implementation = $false }
            codex  = @{ Preparation = $false; Implementation = $true }
        }
        Reason   = 'The Codex reader trims field values and the Claude reader does not, so a padded subagent type is an orchestrator only on the Codex surface (documented above Test-ImplementationDelegation in the Codex gate).'
    }
)

$script:ReadinessCases = @(
    @{ Name = 'a ready checkpoint'; Raw = '{"issue-num":"737","feature-folder":"docs/features/active/x","route_id":"small","lifecycle_ready":true}'; Expected = $true }
    @{ Name = 'a ready checkpoint that names its route as path_selected'; Raw = '{"issue-num":"737","feature-folder":"docs/features/active/x","path_selected":"small","lifecycle_ready":true}'; Expected = $true }
    @{ Name = 'a not-ready checkpoint'; Raw = '{"issue-num":"737","feature-folder":"docs/features/active/x","route_id":"small","lifecycle_ready":false}'; Expected = $false }
    @{ Name = 'an empty checkpoint object'; Raw = '{}'; Expected = $false }
    @{ Name = 'an empty checkpoint text'; Raw = ''; Expected = $false }
    @{ Name = 'a checkpoint whose feature folder is outside the active tree'; Raw = '{"issue-num":"737","feature-folder":"elsewhere/x","route_id":"small","lifecycle_ready":true}'; Expected = $false }
    @{ Name = 'an unparseable checkpoint'; Raw = '{not-json'; Expected = $false }
)

$script:DecisionCases = @(
    @{
        Name       = 'allow for a documentation path'
        Kind       = 'file_path'
        Fields     = @{ file_path = 'docs/features/active/x/plan.md' }
        Checkpoint = $script:NotReadyCheckpoint
        Expected   = 'allow'
    }
    @{
        Name       = 'block for an implementation path with a not-ready checkpoint'
        Kind       = 'file_path'
        Fields     = @{ file_path = 'src/service.py' }
        Checkpoint = $script:NotReadyCheckpoint
        Expected   = 'deny'
    }
    @{
        Name       = 'allow for an implementation path with a ready checkpoint'
        Kind       = 'file_path'
        Fields     = @{ file_path = 'src/service.py' }
        Checkpoint = $script:ReadyCheckpoint
        Expected   = 'allow'
    }
    @{
        Name       = 'allow for an empty input'
        Kind       = 'empty'
        Fields     = @{}
        Checkpoint = $script:NotReadyCheckpoint
        Expected   = 'allow'
        Surfaces   = @{ claude = 'deny'; codex = 'allow' }
        Reason     = 'The Claude gate fails closed on an envelope it cannot read, and the Codex gate allows an empty mapped tool input.'
    }
    @{
        Name       = 'allow for a preparation orchestrator delegation'
        Kind       = 'agent'
        Fields     = @{ subagent_type = 'orchestrator'; prompt = 'Preparation mode: true. route_id: preparation.' }
        Checkpoint = $script:NotReadyCheckpoint
        Expected   = 'allow'
    }
    @{
        Name       = 'block for an implementation agent delegation with a not-ready checkpoint'
        Kind       = 'agent'
        Fields     = @{ subagent_type = 'atomic-executor'; prompt = 'Implement the change.' }
        Checkpoint = $script:NotReadyCheckpoint
        Expected   = 'deny'
    }
)

$script:DeclaredDivergence = @(
    @{
        Table  = 'DelegationCases'
        Name   = 'an orchestrator subagent type padded with whitespace'
        Reason = 'The Codex reader trims field values and the Claude reader does not.'
    }
    @{
        Table  = 'DecisionCases'
        Name   = 'allow for an empty input'
        Reason = 'The Claude gate fails closed on an unreadable envelope; the Codex gate allows an empty mapped tool input.'
    }
)

# Function names defined in the two canonical gate files (the P7-T1 inventory). A function in
# a gate file that is in neither the shared set nor that gate's own set is an undeclared addition.
$script:SharedGateFunction = @(
    'ConvertFrom-CheckpointJson'
    'Get-OrchestrationPreimplementationGateAllowDecision'
    'Get-OrchestrationPreimplementationGateBlockDecision'
    'Get-StringProperty'
    'Invoke-OrchestrationPreimplementationGateDecision'
    'Test-FeatureDocumentationOrEvidencePath'
    'Test-ImplementationCommand'
    'Test-ImplementationDelegation'
    'Test-ImplementationPath'
    'Test-OrchestrationReady'
    'Test-PreparationModeDelegation'
)
$script:ClaudeOnlyGateFunction = @(
    'Invoke-OrchestrationPreimplementationGateEntryPoint'
)
$script:CodexOnlyGateFunction = @(
    'Get-CheckpointContent'
    'Get-OrchestrationModeDenyReason'
)
