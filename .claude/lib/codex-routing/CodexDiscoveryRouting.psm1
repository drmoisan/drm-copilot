<#
.SYNOPSIS
    Constrain direct discovery routing to the fixed operation contracts.
.DESCRIPTION
    Pure companion to CodexTopology. Constants mirror discovery_operations in
    config/orchestration-routing.json so published consumers need no config or
    interpreter. Receipts describe a specialist and allowed output kinds; they
    grant no writes, approvals, installation rights, or native tool authority.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Keep each exact operation independent: sharing a role never broadens its kinds.
$script:DISCOVERY_OPERATIONS = @{
    'inventory-legacy-system'         = @{
        role  = 'legacy-parity-analyst'
        kinds = @('coverage-ledger', 'evidence-reference', 'inventory-snapshot',
            'required-output-manifest', 'unspecified-behavior', 'unspecified-behavior-collection')
    }
    'extract-feature-contract'        = @{
        role  = 'legacy-parity-analyst'
        kinds = @('coverage-ledger', 'evidence-reference', 'feature-contract',
            'required-output-manifest', 'unspecified-behavior', 'unspecified-behavior-collection')
    }
    'characterize-runtime-behavior'   = @{
        role  = 'runtime-characterization-analyst'
        kinds = @('evidence-payload', 'evidence-reference', 'required-output-manifest',
            'runtime-characterization-scenario', 'unspecified-behavior', 'unspecified-behavior-collection')
    }
    'reconcile-parity-matrix'         = @{
        role  = 'requirements-reconciler'
        kinds = @('parity-matrix', 'required-output-manifest',
            'unspecified-behavior', 'unspecified-behavior-collection')
    }
    'review-discovery-coverage'       = @{
        role  = 'migration-coverage-reviewer'
        kinds = @('completion-report', 'coverage-report', 'parity-report',
            'required-output-manifest', 'validation-report')
    }
    'adjudicate-unspecified-behavior' = @{
        role  = 'requirements-reconciler'
        kinds = @('acceptance-specification', 'acceptance-view', 'product-decision',
            'product-decision-collection', 'required-output-manifest',
            'unspecified-behavior', 'unspecified-behavior-collection')
    }
    'generate-acceptance-scenarios'   = @{
        role  = 'requirements-reconciler'
        kinds = @('acceptance-specification', 'acceptance-view', 'required-output-manifest')
    }
    'initialize-discovery-workspace'  = @{
        role  = 'migration-coverage-reviewer'
        kinds = @('coverage-report', 'required-output-manifest', 'validation-report')
    }
    'validate-discovery-artifacts'    = @{
        role  = 'migration-coverage-reviewer'
        kinds = @('coverage-report', 'required-output-manifest', 'validation-report')
    }
}

function Resolve-CodexDiscoveryTopology {
    <#
    .SYNOPSIS
        Select a fixed discovery role or allow the unchanged ordinary route.
    .DESCRIPTION
        Called after topology validates context, languages, counts and boolean
        type. Validates selectors without coercion, rejects nonzero code/test
        scope and root overrides, then returns a new seventeen-key receipt.
        Ordinary requests with no skill return null. Invalid selectors or
        combinations throw ArgumentException in the shared contract order.
        No I/O or native authority is created; returned arrays are fresh copies.
    .PARAMETER InvocationKind
        Exact ordinary or discovery string; all other values are rejected.
    .PARAMETER SkillId
        Exact canonical skill string for discovery, null for ordinary requests.
    .PARAMETER Context
        Execution context already validated by the topology resolver; retained
        unchanged. Named Context because ExecutionContext is a readonly
        automatic variable.
    .PARAMETER Language
        Already normalized languages. Discovery requires an empty collection.
    .PARAMETER ProductionFileCount
        Already validated integer count. Discovery requires zero.
    .PARAMETER TestFileCount
        Already validated integer count. Discovery requires zero.
    .PARAMETER CrossCutting
        Already validated boolean. Discovery requires false.
    .PARAMETER RootPersona
        Raw optional root override. Discovery requires null.
    .OUTPUTS
        System.Collections.Hashtable for discovery, or null for ordinary routing.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)][AllowNull()][object] $InvocationKind,
        [Parameter(Mandatory)][AllowNull()][object] $SkillId,
        [Parameter(Mandatory)][string] $Context,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Language,
        [Parameter(Mandatory)][int] $ProductionFileCount,
        [Parameter(Mandatory)][int] $TestFileCount,
        [Parameter(Mandatory)][bool] $CrossCutting,
        [Parameter(Mandatory)][AllowNull()][object] $RootPersona
    )

    # Object selectors retain their actual types; case-insensitive coercion
    # would otherwise admit unsupported operations at this authority boundary.
    if ($InvocationKind -isnot [string] -or @('ordinary', 'discovery') -cnotcontains $InvocationKind) {
        throw [System.ArgumentException]::new('invocation_kind must be ordinary or discovery.')
    }
    if ($InvocationKind -ceq 'ordinary') {
        if ($null -ne $SkillId) {
            throw [System.ArgumentException]::new('skill_id is only valid for discovery invocations.')
        }
        return $null
    }

    # Reject discovery scope before looking up a role, preserving guard order
    # even when several fields are malformed in the same invocation.
    if ($null -ne $RootPersona) {
        throw [System.ArgumentException]::new('Discovery invocations do not accept root_persona.')
    }
    if ($ProductionFileCount -ne 0) {
        throw [System.ArgumentException]::new('Discovery invocations require production_file_count=0.')
    }
    if ($TestFileCount -ne 0) {
        throw [System.ArgumentException]::new('Discovery invocations require test_file_count=0.')
    }
    if ($Language.Count -ne 0) {
        throw [System.ArgumentException]::new('Discovery invocations do not accept languages.')
    }
    if ($CrossCutting) {
        throw [System.ArgumentException]::new('Discovery invocations do not accept cross_cutting.')
    }
    if ($SkillId -isnot [string] -or $script:DISCOVERY_OPERATIONS.Keys -cnotcontains $SkillId) {
        throw [System.ArgumentException]::new('Discovery invocations require a supported skill_id.')
    }

    $operation = $script:DISCOVERY_OPERATIONS[$SkillId]
    return @{
        execution_context          = $Context
        languages                  = [string[]]@()
        production_file_count      = 0
        test_file_count            = 0
        cross_cutting              = $false
        root_persona               = $null
        route                      = 'discovery'
        topology                   = 'discovery_specialist'
        logical_agent              = $operation.role
        routing_reason             = 'fixed_discovery_operation'
        max_production_files       = 0
        max_test_files             = 0
        invocation_kind            = 'discovery'
        skill_id                   = $SkillId
        output_contract_version    = '2.0.0'
        permissible_artifact_kinds = [string[]]@($operation.kinds)
        gate_mode                  = 'agent-output'
    }
}

Export-ModuleMember -Function Resolve-CodexDiscoveryTopology
