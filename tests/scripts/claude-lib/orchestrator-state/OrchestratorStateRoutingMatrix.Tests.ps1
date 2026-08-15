#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Config-parity and accessor tests for the pinned routing-matrix constants.

.DESCRIPTION
    Exercises .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1,
    the PD-1 implementation that embeds the routing-matrix subset the completion
    checks consume rather than reading config/orchestration-routing.json at
    validation time.

    The first Describe is the static config-parity test: it reads
    config/orchestration-routing.json at TEST time only, as the parity oracle, and
    pins every embedded constant to it - the route set, both gate flags including
    the absent-versus-false distinction, and all three required-name lists in
    matrix order. If the config changes and the module does not, this suite fails.
    That test is the mechanism that keeps hard-coded constants honest, following
    the established ModelRouting.psm1 pattern.

    The remaining Describes cover the accessors, including the deliberate
    asymmetry between the two gate predicates and the two distinct route-value
    resolution rules the Python reference uses.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port must
    embed the same constants and reproduce the same accessor semantics.

    The suite creates no temporary files, starts no external process, and never
    mutates $PSVersionTable or $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture data is consumed inside It blocks after assignment in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingMatrix.psm1') -Force

    # The parity oracle. Read at TEST time only; the module under test never opens
    # this file, which is the entire point of PD-1.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:ConfigPath = Join-Path $repoRoot 'config/orchestration-routing.json'
    $script:ConfigRoutes = (Get-Content -LiteralPath $script:ConfigPath -Raw | ConvertFrom-Json).routes

    function script:Get-CheckpointState {
        param([Parameter(Mandatory = $true)][string] $Json)
        return ($Json | ConvertFrom-Json)
    }
}

Describe 'Pinned routing-matrix constants match config/orchestration-routing.json' {

    It 'pins exactly the config route set, with no extra and no missing route' {
        $pinned = @((Get-OrchestratorStateRoutingMatrix).routes.Keys) | Sort-Object
        $configured = @($script:ConfigRoutes.PSObject.Properties.Name) | Sort-Object
        $pinned | Should -Be $configured
    }

    It 'pins requires_pr_gate for every route, preserving absent versus false' {
        foreach ($property in $script:ConfigRoutes.PSObject.Properties) {
            $route = Get-OrchestratorStateRoute -RouteId $property.Name
            $configHasFlag = @($property.Value.PSObject.Properties.Name) -contains 'requires_pr_gate'
            if ($configHasFlag) {
                $route['requires_pr_gate'] | Should -Be $property.Value.requires_pr_gate `
                    -Because "route $($property.Name) records requires_pr_gate in the config"
            } else {
                $route['requires_pr_gate'] | Should -BeNullOrEmpty `
                    -Because "route $($property.Name) omits requires_pr_gate in the config"
            }
        }
    }

    It 'pins requires_ci_gate for every route, preserving absent versus false' {
        foreach ($property in $script:ConfigRoutes.PSObject.Properties) {
            $route = Get-OrchestratorStateRoute -RouteId $property.Name
            $configHasFlag = @($property.Value.PSObject.Properties.Name) -contains 'requires_ci_gate'
            if ($configHasFlag) {
                $route['requires_ci_gate'] | Should -Be $property.Value.requires_ci_gate `
                    -Because "route $($property.Name) records requires_ci_gate in the config"
            } else {
                $route['requires_ci_gate'] | Should -BeNullOrEmpty `
                    -Because "route $($property.Name) omits requires_ci_gate in the config"
            }
        }
    }

    It 'pins all three required-name lists for every route, in matrix order' {
        foreach ($property in $script:ConfigRoutes.PSObject.Properties) {
            foreach ($listName in (Get-OrchestratorStateRouteListName)) {
                $pinned = @(Get-OrchestratorStateRouteRequiredList -RouteId $property.Name -ListName $listName)
                $configured = @($property.Value.$listName)
                $pinned | Should -Be $configured `
                    -Because "route $($property.Name) list $listName must match the config in order"
            }
        }
    }

    It 'reports the same PR-gate decision as the config for every route' {
        foreach ($property in $script:ConfigRoutes.PSObject.Properties) {
            $expected = ($property.Value.PSObject.Properties.Name -contains 'requires_pr_gate') -and
            ($property.Value.requires_pr_gate -is [bool]) -and $property.Value.requires_pr_gate
            Test-OrchestratorStateRouteRequiresPrGate -RouteId $property.Name |
                Should -Be $expected -Because "route $($property.Name) PR-gate decision must match the config"
        }
    }

    It 'reports the same CI-gate decision as the config for every route' {
        foreach ($property in $script:ConfigRoutes.PSObject.Properties) {
            $explicitlyFalse = ($property.Value.PSObject.Properties.Name -contains 'requires_ci_gate') -and
            ($property.Value.requires_ci_gate -is [bool]) -and (-not $property.Value.requires_ci_gate)
            Test-OrchestratorStateRouteRequiresCiGate -RouteId $property.Name |
                Should -Be (-not $explicitlyFalse) -Because "route $($property.Name) CI-gate decision must match the config"
        }
    }
}

Describe 'Routing-matrix route lookup' {

    It 'returns a known route entry' {
        (Get-OrchestratorStateRoute -RouteId 'small') | Should -Not -BeNullOrEmpty
    }

    It 'returns null for an unknown route' {
        Get-OrchestratorStateRoute -RouteId 'fabricated_route' | Should -BeNullOrEmpty
    }

    It 'returns null for a null route id' {
        Get-OrchestratorStateRoute -RouteId $null | Should -BeNullOrEmpty
    }

    It 'returns null for a route id from a matrix override with no routes object' {
        Get-OrchestratorStateRoute -RouteId 'small' -RoutingMatrix @{} | Should -BeNullOrEmpty
    }

    It 'reports a matrix override with no routes object as malformed' {
        Get-OrchestratorStateRoutingMatrixRouteMap -RoutingMatrix @{} | Should -BeNullOrEmpty
    }

    It 'reports a matrix override whose routes member is not a mapping as malformed' {
        Get-OrchestratorStateRoutingMatrixRouteMap -RoutingMatrix @{ routes = 'x' } | Should -BeNullOrEmpty
    }

    It 'honours a matrix override that supplies its own routes' {
        $override = @{ routes = @{ custom = @{ requires_pr_gate = $true } } }
        Test-OrchestratorStateRouteRequiresPrGate -RouteId 'custom' -RoutingMatrix $override | Should -BeTrue
    }
}

Describe 'Route gate predicates' {

    It 'requires the PR gate only for a route whose flag is exactly true' {
        Test-OrchestratorStateRouteRequiresPrGate -RouteId 'large' | Should -BeTrue
        Test-OrchestratorStateRouteRequiresPrGate -RouteId 'epic' | Should -BeTrue
    }

    It 'does not require the PR gate for a route whose flag is absent' {
        Test-OrchestratorStateRouteRequiresPrGate -RouteId 'small' | Should -BeFalse
    }

    It 'does not require the PR gate for a route whose flag is false' {
        Test-OrchestratorStateRouteRequiresPrGate -RouteId 'parallel' | Should -BeFalse
    }

    It 'does not require the PR gate for an unknown or null route' {
        Test-OrchestratorStateRouteRequiresPrGate -RouteId 'unknown' | Should -BeFalse
        Test-OrchestratorStateRouteRequiresPrGate -RouteId $null | Should -BeFalse
    }

    It 'requires the CI gate for a route whose flag is absent, unlike the PR gate' {
        Test-OrchestratorStateRouteRequiresCiGate -RouteId 'small' | Should -BeTrue
    }

    It 'does not require the CI gate only for a route whose flag is exactly false' {
        Test-OrchestratorStateRouteRequiresCiGate -RouteId 'preparation' | Should -BeFalse
    }

    It 'requires the CI gate for an unknown or null route, failing closed' {
        Test-OrchestratorStateRouteRequiresCiGate -RouteId 'unknown' | Should -BeTrue
        Test-OrchestratorStateRouteRequiresCiGate -RouteId $null | Should -BeTrue
    }
}

Describe 'Route required-name list accessor' {

    It 'returns the pinned agents for a known route' {
        Get-OrchestratorStateRouteRequiredList -RouteId 'small' -ListName 'required_agents' |
            Should -Be @('atomic-planner', 'atomic-executor', 'feature-review')
    }

    It 'returns an empty list for an unknown route' {
        @(Get-OrchestratorStateRouteRequiredList -RouteId 'unknown' -ListName 'required_agents').Count |
            Should -Be 0
    }

    It 'returns an empty list when the override route omits the named list' {
        $override = @{ routes = @{ custom = @{} } }
        @(Get-OrchestratorStateRouteRequiredList -RouteId 'custom' -ListName 'required_skills' -RoutingMatrix $override).Count |
            Should -Be 0
    }

    It 'returns an empty list when the override list is not a list of non-blank strings' {
        $override = @{ routes = @{ custom = @{ required_agents = @('ok', '  ') } } }
        @(Get-OrchestratorStateRouteRequiredList -RouteId 'custom' -ListName 'required_agents' -RoutingMatrix $override).Count |
            Should -Be 0
    }

    It 'reports exactly the three per-route list names' {
        Get-OrchestratorStateRouteListName |
            Should -Be @('required_agents', 'required_skills', 'required_mcp_tools')
    }
}

Describe 'Checkpoint route-value resolution' {

    It 'prefers route_id over path_selected' {
        $state = Get-CheckpointState -Json '{"route_id":"large","path_selected":"small"}'
        Get-OrchestratorStateSelectedRouteId -State $state | Should -Be 'large'
    }

    It 'falls back to path_selected only when the route_id key is absent' {
        $state = Get-CheckpointState -Json '{"path_selected":"small"}'
        Get-OrchestratorStateRawRouteValue -State $state | Should -Be 'small'
    }

    It 'does not fall back when route_id is present but null, matching Python dict.get' {
        $state = Get-CheckpointState -Json '{"route_id":null,"path_selected":"small"}'
        Get-OrchestratorStateRawRouteValue -State $state | Should -BeNullOrEmpty
    }

    It 'reports a blank route value as unusable for the gate predicates' {
        $state = Get-CheckpointState -Json '{"route_id":"   "}'
        Get-OrchestratorStateSelectedRouteId -State $state | Should -BeNullOrEmpty
    }

    It 'reports a non-string route value as unusable for the gate predicates' {
        $state = Get-CheckpointState -Json '{"route_id":5}'
        Get-OrchestratorStateSelectedRouteId -State $state | Should -BeNullOrEmpty
    }

    It 'returns the raw non-string route value for the preparation check' {
        $state = Get-CheckpointState -Json '{"route_id":5}'
        Get-OrchestratorStateRawRouteValue -State $state | Should -Be 5
    }
}
