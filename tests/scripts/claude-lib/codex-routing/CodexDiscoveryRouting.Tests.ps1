#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Verify fixed discovery routing without filesystem or native authority effects.
.DESCRIPTION
    Calls the pure topology/deployment boundaries with in-memory requests. Only
    the authoritative committed config is read. No fixture files, subprocesses,
    global process settings or native grants are created. Case-sensitive selector
    guards, shared precedence, output ownership and independent receipts are
    checked separately from the operational CLI corpus.
#>

BeforeDiscovery {
    $script:Skills = @(
        'inventory-legacy-system', 'extract-feature-contract',
        'characterize-runtime-behavior', 'reconcile-parity-matrix',
        'review-discovery-coverage', 'adjudicate-unspecified-behavior',
        'generate-acceptance-scenarios', 'initialize-discovery-workspace',
        'validate-discovery-artifacts'
    )
    $script:Roles = @('legacy-parity-analyst', 'runtime-characterization-analyst',
        'requirements-reconciler', 'migration-coverage-reviewer')
    $script:ProfileCases = foreach ($role in $script:Roles) {
        foreach ($row in @(
                @{ Band = 'C1'; Model = 'gpt-6-luna'; Effort = 'low' },
                @{ Band = 'C2'; Model = 'gpt-6.1-sol'; Effort = 'medium' },
                @{ Band = 'C3'; Model = 'gpt-6.1-sol'; Effort = 'high' },
                @{ Band = 'C4'; Model = 'gpt-6-astra'; Effort = 'max' }
            )) {
            @{ Role = $role; Band = $row.Band; Model = $row.Model; Effort = $row.Effort }
        }
    }
}

BeforeAll {
    $root = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $root '.claude/lib/codex-routing/CodexTopology.psm1') -Force
    Import-Module (Join-Path $root '.claude/lib/codex-routing/CodexDeployment.psm1') -Force
    $script:Operations = (Get-Content -Raw -Encoding utf8 -LiteralPath (
            Join-Path $root 'config/orchestration-routing.json') | ConvertFrom-Json -AsHashtable).discovery_operations
    $script:Request = @{
        Language = @(); ProductionFileCount = 0; TestFileCount = 0
        ExecutionContext = 'standalone'; InvocationKind = 'discovery'
        SkillId = 'inventory-legacy-system'
    }
}

Describe 'Fixed discovery contracts' {
    It 'matches the complete canonical operation for <_>' -ForEach $script:Skills {
        $request = $script:Request.Clone()
        $request.SkillId = $_
        $operation = $script:Operations[$_]

        $result = Resolve-CodexTopology @request

        $result.Keys.Count | Should -Be 17
        $result.logical_agent | Should -BeExactly $operation.logical_agent
        $result.permissible_artifact_kinds | Should -Be $operation.permissible_artifact_kinds
        $result.output_contract_version | Should -BeExactly '2.0.0'
        $result.gate_mode | Should -BeExactly 'agent-output'
        $result.skill_id | Should -BeExactly $_
        $result.invocation_kind | Should -BeExactly 'discovery'
        $result.route | Should -BeExactly 'discovery'
        $result.topology | Should -BeExactly 'discovery_specialist'
        $result.routing_reason | Should -BeExactly 'fixed_discovery_operation'
        $result.production_file_count | Should -Be 0
        $result.test_file_count | Should -Be 0
        $result.max_production_files | Should -Be 0
        $result.max_test_files | Should -Be 0
        @($result.languages).Count | Should -Be 0
        $result.cross_cutting | Should -BeFalse
        $result.root_persona | Should -BeNullOrEmpty
        $result.execution_context | Should -BeExactly 'standalone'
        $script:Operations.Count | Should -Be 9
    }

    It 'routes discovery before ordinary zero-count and epic-child escalation for <_>' -ForEach @(
        'standalone', 'epic_preparation_child', 'epic_execution_child'
    ) {
        $request = $script:Request.Clone()
        $request.ExecutionContext = $_

        $result = Resolve-CodexTopology @request

        $result.route | Should -BeExactly 'discovery'
        $result.execution_context | Should -BeExactly $_
        $result.logical_agent | Should -BeExactly 'legacy-parity-analyst'
    }

    It 'returns independent output-kind arrays and receipts on successive invocations' {
        $first = Resolve-CodexTopology @script:Request
        $second = Resolve-CodexTopology @script:Request

        $first.permissible_artifact_kinds[0] = 'forbidden-source-write'
        $first.logical_agent = 'epic-orchestrator'
        $third = Resolve-CodexTopology @script:Request

        $expected = $script:Operations['inventory-legacy-system']
        $second.permissible_artifact_kinds | Should -Be $expected.permissible_artifact_kinds
        $third.permissible_artifact_kinds | Should -Be $expected.permissible_artifact_kinds
        $third.logical_agent | Should -BeExactly $expected.logical_agent
        [object]::ReferenceEquals($second.permissible_artifact_kinds, $third.permissible_artifact_kinds) | Should -BeFalse
        $script:Request.SkillId | Should -BeExactly 'inventory-legacy-system'
    }
}

Describe 'Discovery refusal and guard order' {
    It 'rejects invalid invocation kind <Name> without string coercion' -ForEach @(
        @{ Name = 'null'; Value = $null }, @{ Name = 'number'; Value = 7 },
        @{ Name = 'boolean'; Value = $true }, @{ Name = 'array'; Value = @('discovery') },
        @{ Name = 'uppercase'; Value = 'Discovery' }, @{ Name = 'blank'; Value = '' },
        @{ Name = 'unknown'; Value = 'agent' }
    ) {
        $request = $script:Request.Clone()
        $request.InvocationKind = $Value
        { Resolve-CodexTopology @request } | Should -Throw -ExceptionType ([ArgumentException]) `
            -ExpectedMessage 'invocation_kind must be ordinary or discovery.'
    }

    It 'rejects noncanonical skill <Name>' -ForEach @(
        @{ Name = 'null'; Value = $null }, @{ Name = 'number'; Value = 7 },
        @{ Name = 'boolean'; Value = $false }, @{ Name = 'array'; Value = @('inventory-legacy-system') },
        @{ Name = 'uppercase'; Value = 'Inventory-legacy-system' }, @{ Name = 'blank'; Value = '' },
        @{ Name = 'alias'; Value = 'discovery-repo-inventory' }, @{ Name = 'padding'; Value = 'inventory-legacy-system ' }
    ) {
        $request = $script:Request.Clone()
        $request.SkillId = $Value
        { Resolve-CodexTopology @request } | Should -Throw -ExceptionType ([ArgumentException]) `
            -ExpectedMessage 'Discovery invocations require a supported skill_id.'
    }

    It 'rejects supplied ordinary skill <Name>' -ForEach @(
        @{ Name = 'canonical'; Value = 'inventory-legacy-system' },
        @{ Name = 'empty'; Value = '' }, @{ Name = 'false'; Value = $false }
    ) {
        $request = $script:Request.Clone()
        $request.InvocationKind = 'ordinary'
        $request.SkillId = $Value
        { Resolve-CodexTopology @request } | Should -Throw `
            -ExpectedMessage 'skill_id is only valid for discovery invocations.'
    }

    It 'refuses forbidden discovery field <Field> with value <Value>' -ForEach @(
        @{ Field = 'RootPersona'; Value = 'epic-planner'; Error = 'Discovery invocations do not accept root_persona.' },
        @{ Field = 'RootPersona'; Value = ''; Error = 'Discovery invocations do not accept root_persona.' },
        @{ Field = 'RootPersona'; Value = $false; Error = 'Discovery invocations do not accept root_persona.' },
        @{ Field = 'ProductionFileCount'; Value = 1; Error = 'Discovery invocations require production_file_count=0.' },
        @{ Field = 'ProductionFileCount'; Value = -1; Error = 'Discovery invocations require production_file_count=0.' },
        @{ Field = 'TestFileCount'; Value = 1; Error = 'Discovery invocations require test_file_count=0.' },
        @{ Field = 'TestFileCount'; Value = -1; Error = 'Discovery invocations require test_file_count=0.' },
        @{ Field = 'Language'; Value = @('python'); Error = 'Discovery invocations do not accept languages.' },
        @{ Field = 'CrossCutting'; Value = $true; Error = 'Discovery invocations do not accept cross_cutting.' }
    ) {
        $request = $script:Request.Clone()
        $request[$Field] = $Value
        { Resolve-CodexTopology @request } | Should -Throw -ExceptionType ([ArgumentException]) -ExpectedMessage $Error
    }

    It 'preserves existing type validation before selector validation for <Field>' -ForEach @(
        @{ Field = 'ExecutionContext'; Value = 'unknown'; Error = '*execution_context must be one of*' },
        @{ Field = 'Language'; Value = @(7); Error = 'languages must contain non-empty strings.' },
        @{ Field = 'ProductionFileCount'; Value = $false; Error = 'production_file_count must be an integer.' },
        @{ Field = 'TestFileCount'; Value = $true; Error = 'test_file_count must be an integer.' },
        @{ Field = 'CrossCutting'; Value = 'true'; Error = 'cross_cutting must be a boolean.' }
    ) {
        $request = $script:Request.Clone()
        $request.InvocationKind = 'unknown'
        $request[$Field] = $Value
        { Resolve-CodexTopology @request } | Should -Throw -ExpectedMessage $Error
    }

    It 'rejects all invalid discovery fields in the shared precedence order' {
        $request = $script:Request.Clone()
        $request.RootPersona = 'epic-planner'
        $request.ProductionFileCount = 1
        $request.TestFileCount = 1
        $request.Language = @('python')
        $request.CrossCutting = $true
        $request.SkillId = 'unknown'
        $ordered = @(
            @{ Field = 'RootPersona'; Valid = $null; Error = 'Discovery invocations do not accept root_persona.' },
            @{ Field = 'ProductionFileCount'; Valid = 0; Error = 'Discovery invocations require production_file_count=0.' },
            @{ Field = 'TestFileCount'; Valid = 0; Error = 'Discovery invocations require test_file_count=0.' },
            @{ Field = 'Language'; Valid = @(); Error = 'Discovery invocations do not accept languages.' },
            @{ Field = 'CrossCutting'; Valid = $false; Error = 'Discovery invocations do not accept cross_cutting.' },
            @{ Field = 'SkillId'; Valid = 'inventory-legacy-system'; Error = 'Discovery invocations require a supported skill_id.' }
        )
        foreach ($guard in $ordered) {
            { Resolve-CodexTopology @request } | Should -Throw -ExpectedMessage $guard.Error
            $request[$guard.Field] = $guard.Valid
        }
        (Resolve-CodexTopology @request).route | Should -BeExactly 'discovery'
    }
}

Describe 'Discovery uses the unchanged deployment policy' {
    It 'selects exact <Role> profile <Band> with no fallback' -ForEach $script:ProfileCases {
        $result = Resolve-CodexDeployment -LogicalAgent $Role -ComplexityBand $Band `
            -ExecutionContext standalone -OrchestrationComplexityCeiling $Band -AvailableModel @($Model)
        $result.deployment_agent | Should -BeExactly "$Role-$($Band.ToLowerInvariant())"
        $result.model | Should -BeExactly $Model
        $result.model_reasoning_effort | Should -BeExactly $Effort
        $result.c3_overlay_applied | Should -BeFalse
        $result.Keys.Count | Should -Be 9
    }

    It 'retains C3 context and ceiling overlays for <_>' -ForEach $script:Roles {
        foreach ($case in @(
                @{ Context = 'epic_preparation_child'; Ceiling = 'C3'; Reason = 'epic_context' },
                @{ Context = 'standalone'; Ceiling = 'C4'; Reason = 'c4_orchestration_ceiling' },
                @{ Context = 'epic_execution_child'; Ceiling = 'C4'; Reason = 'epic_context_and_c4_ceiling' }
            )) {
            $result = Resolve-CodexDeployment -LogicalAgent $_ -ComplexityBand C3 `
                -ExecutionContext $case.Context -OrchestrationComplexityCeiling $case.Ceiling
            $result.deployment_agent | Should -BeExactly "$_-c3-elevated"
            $result.c3_overlay_reason | Should -BeExactly $case.Reason
            $result.model | Should -BeExactly 'gpt-6-astra'
            $result.model_reasoning_effort | Should -BeExactly 'high'
        }
    }

    It 'refuses unavailable models and a below-band ceiling for <_>' -ForEach $script:Roles {
        { Resolve-CodexDeployment -LogicalAgent $_ -ComplexityBand C1 -ExecutionContext standalone `
                -OrchestrationComplexityCeiling C1 -AvailableModel @('gpt-6-astra') } |
            Should -Throw -ExceptionType ([InvalidOperationException]) -ExpectedMessage '*model_unavailable*'
        { Resolve-CodexDeployment -LogicalAgent $_ -ComplexityBand C3 -ExecutionContext standalone `
                -OrchestrationComplexityCeiling C2 } |
            Should -Throw -ExpectedMessage '*C2 below C3*'
    }
}
