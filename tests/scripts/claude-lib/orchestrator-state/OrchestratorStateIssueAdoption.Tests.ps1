#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the portable issue-adoption resolver (inventory row C6.15).

.DESCRIPTION
    Exercises Get-OrchestratorStateIssueAdoptionResult in
    .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 with the
    positive schema cases, every rejection rule with its exact ordered error
    text, the closed waivable-tool set, the fail-closed invariant on a fixed
    grid, and presence gating. Three further blocks exercise the wiring in
    Get-OrchestratorStateRoutingContractError: presence gating, error placement
    relative to local_execution_overrides, and the case-sensitive tool name.

    These cases mirror tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py.

    Every checkpoint is an in-memory JSON string converted with ConvertFrom-Json.
    The suite creates no files, starts no external process, and never mutates
    $PSVersionTable or $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateIssueAdoption.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force

    $script:LargeTools = [string[]]@('new_potential_entry', 'potential_to_issue', 'new_active_feature_folder', 'collect_pr_context', 'validate_orchestration_artifacts')
    $script:LargeBugTools = [string[]]@('new_potential_bug_entry', 'potential_to_issue', 'new_active_feature_folder', 'collect_pr_context', 'validate_orchestration_artifacts')
    $script:PreparationTools = [string[]]@('new_potential_entry', 'potential_to_issue', 'new_active_feature_folder', 'validate_orchestration_artifacts')
    $script:RemediationTools = [string[]]@('collect_pr_context', 'validate_orchestration_artifacts')
    $script:NonWaivableSuccessful = [string[]]@('new_active_feature_folder', 'collect_pr_context', 'validate_orchestration_artifacts')
    $script:ValidRecord = 'docs/features/potential/promoted/2026-08-22-promotion-gate-lacks-preexisting-issue-branch.md'

    $script:E1 = 'Checkpoint issue_adoption must be an object when present.'
    $script:E2a = 'Checkpoint issue_adoption.issue_num must be a string of decimal digits without a leading zero.'
    $script:E2b = 'Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num.'
    $script:E3 = 'Checkpoint issue_adoption.issue_url must end with /issues/ followed by issue_num.'
    $script:E4 = 'Checkpoint issue_adoption.origin must be one of transferred, filed_before_orchestration, epic_decomposition.'
    $script:E5 = 'Checkpoint issue_adoption.verified_via must be one of gh_issue_view, gh_api_get, github_mcp_issue_read.'
    $script:E6 = 'Checkpoint issue_adoption.verified_at must be present.'
    $script:E7 = 'Checkpoint issue_adoption.evidence must be a non-empty string.'
    $script:E8a = 'Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names.'
    $script:E8include = 'Checkpoint issue_adoption.waived_tools must include potential_to_issue.'
    $script:Leo = 'Checkpoint local_execution_overrides must be empty at completion.'

    function script:Get-E8Cannot { param([string] $Tool) "Checkpoint issue_adoption.waived_tools names a tool that cannot be waived: $Tool." }
    function script:Get-E8NotRequired { param([string] $RouteId, [string] $Tool) "Checkpoint issue_adoption.waived_tools names a tool that is not required by route ${RouteId}: $Tool." }
    function script:Get-E8Receipt { param([string] $Tool) "Checkpoint issue_adoption.waived_tools names a tool that has a successful MCP receipt: $Tool." }
    function script:Get-E8Duplicate { param([string] $Tool) "Checkpoint issue_adoption.waived_tools lists a tool more than once: $Tool." }
    function script:Get-E9 { param([string] $Tool) "Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving $Tool." }
    function script:Get-MissingReceipt { param([string] $Tool) "Checkpoint missing successful MCP receipt: $Tool." }

    # Build the base valid adoption record for issue 509 with field overrides and
    # removals applied, as an ordered dictionary ready for JSON serialization.
    function script:Get-AdoptionRecord {
        param([hashtable] $Override = @{}, [string[]] $Remove = @())
        $record = [ordered]@{
            issue_num    = '509'
            issue_url    = 'https://github.com/drmoisan/drm-copilot/issues/509'
            origin       = 'transferred'
            verified_via = 'gh_issue_view'
            verified_at  = '2026-09-29T15:15:00Z'
            evidence     = 'gh issue view 509 --json number,state,url: number 509, state OPEN'
            waived_tools = @('potential_to_issue')
        }
        foreach ($key in $Override.Keys) { $record[$key] = $Override[$key] }
        foreach ($key in $Remove) { $record.Remove($key) }
        return $record
    }

    # Serialize a minimal checkpoint carrying the given adoption value to an
    # in-memory JSON string and convert it back, as the validator receives it.
    function script:Get-AdoptionState {
        param([AllowNull()][object] $Adoption, [string] $PromotionType = 'feature')
        $state = [ordered]@{ 'issue-num' = '509'; 'promotion-type' = $PromotionType; issue_adoption = $Adoption }
        $json = ConvertTo-Json -InputObject $state -Depth 8
        return ($json | ConvertFrom-Json)
    }

    function script:Invoke-Adoption {
        param(
            [psobject] $State,
            [string] $RouteId = 'large',
            [string[]] $Required = $script:LargeTools,
            [AllowEmptyCollection()][string[]] $Successful = $script:NonWaivableSuccessful
        )
        return Get-OrchestratorStateIssueAdoptionResult -State $State -RouteId $RouteId -RequiredMcpTool $Required -SuccessfulTool $Successful
    }

    function script:Join-Text { param([AllowEmptyCollection()][string[]] $Value) return (@($Value) -join "`n") }
    function script:Join-Sorted { param([AllowEmptyCollection()][string[]] $Value) return ((@($Value) | Sort-Object) -join ',') }

    # A large-route checkpoint whose receipts cover every tool except
    # potential_to_issue, with the adoption member spliced in when supplied.
    function script:Get-LargeCheckpoint {
        param([string] $AdoptionJson = '', [string] $OverridesJson = '[]')
        $adoptionMember = if ($AdoptionJson.Length -gt 0) { ",`"issue_adoption`":$AdoptionJson" } else { '' }
        $json = @"
{"route_id":"large","promotion-type":"feature","issue-num":"509",
 "required_agents":["task-researcher","prd-feature","atomic-planner","atomic-executor","feature-review","pr-author"],
 "required_skills":["orchestrate","feature-promotion-lifecycle","atomic-plan-contract","acceptance-criteria-tracking","pr-context-artifacts","pr-base-branch-merge-base"],
 "required_mcp_tools":["new_potential_entry","potential_to_issue","new_active_feature_folder","collect_pr_context","validate_orchestration_artifacts"],
 "delegation_receipts":[{"agent_name":"task-researcher"},{"agent_name":"prd-feature"},{"agent_name":"atomic-planner"},{"agent_name":"atomic-executor"},{"agent_name":"feature-review"},{"agent_name":"pr-author"}],
 "skill_receipts":[{"skill":"orchestrate","required":true,"evidence":"e"},{"skill":"feature-promotion-lifecycle","required":true,"evidence":"e"},{"skill":"atomic-plan-contract","required":true,"evidence":"e"},{"skill":"acceptance-criteria-tracking","required":true,"evidence":"e"},{"skill":"pr-context-artifacts","required":true,"evidence":"e"},{"skill":"pr-base-branch-merge-base","required":true,"evidence":"e"}],
 "mcp_call_receipts":[{"tool":"new_potential_entry","ok":true,"evidence":"e"},{"tool":"new_active_feature_folder","ok":true,"evidence":"e"},{"tool":"collect_pr_context","ok":true,"evidence":"e"},{"tool":"validate_orchestration_artifacts","ok":true,"evidence":"e"}],
 "local_execution_overrides":$OverridesJson,"delegation_bypasses":[]$adoptionMember}
"@
        return ($json | ConvertFrom-Json)
    }
}

Describe 'Issue adoption accepts valid records (AC-6)' {

    It 'accepts a feature checkpoint waiving potential_to_issue alone' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord))
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'potential_to_issue'
    }

    It 'accepts a feature checkpoint waiving the feature entry tool with a record' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'new_potential_entry'); potential_record = $script:ValidRecord }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'new_potential_entry,potential_to_issue'
    }

    It 'accepts a bug checkpoint waiving the bug entry tool with a record' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'new_potential_bug_entry'); potential_record = $script:ValidRecord }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption -PromotionType 'bug') -Required $script:LargeBugTools
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'new_potential_bug_entry,potential_to_issue'
    }

    It 'accepts the same record on the preparation route' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord)) -RouteId 'preparation' -Required $script:PreparationTools
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'potential_to_issue'
    }

    It 'accepts the documented origin value <Value>' -ForEach @(
        @{ Value = 'transferred' }, @{ Value = 'filed_before_orchestration' }, @{ Value = 'epic_decomposition' }
    ) {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ origin = $Value }))
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'potential_to_issue'
    }

    It 'accepts the documented verification source <Value>' -ForEach @(
        @{ Value = 'gh_issue_view' }, @{ Value = 'gh_api_get' }, @{ Value = 'github_mcp_issue_read' }
    ) {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ verified_via = $Value }))
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'potential_to_issue'
    }
}

Describe 'Issue adoption rejects malformed records (AC-7)' {

    It 'rejects a non-object adoption value of kind <Label>' -ForEach @(
        @{ Label = 'string'; Value = 'adopted' }, @{ Label = 'integer'; Value = 509 }, @{ Label = 'list'; Value = @('potential_to_issue') }
    ) {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $Value)
        Join-Text $result.Errors | Should -BeExactly $script:E1
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects a null adoption value' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $null)
        Join-Text $result.Errors | Should -BeExactly $script:E1
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects an integer issue number' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ issue_num = 509 }))
        Join-Text $result.Errors | Should -BeExactly (Join-Text @($script:E2a, $script:E3))
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects a leading-zero issue number' {
        $adoption = Get-AdoptionRecord -Override @{ issue_num = '0509'; issue_url = 'https://github.com/drmoisan/drm-copilot/issues/0509' }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Join-Text @($script:E2a, $script:E3))
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects an issue number that differs from the checkpoint issue-num' {
        $adoption = Get-AdoptionRecord -Override @{ issue_num = '510'; issue_url = 'https://github.com/drmoisan/drm-copilot/issues/510' }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly $script:E2b
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects an issue URL that does not end with the issue number' {
        $adoption = Get-AdoptionRecord -Override @{ issue_url = 'https://github.com/drmoisan/drm-copilot/issues/510' }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly $script:E3
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects an unknown origin' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ origin = 'imported' }))
        Join-Text $result.Errors | Should -BeExactly $script:E4
    }

    It 'rejects an unknown verification source' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ verified_via = 'curl' }))
        Join-Text $result.Errors | Should -BeExactly $script:E5
    }

    It 'rejects an absent verification time' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Remove @('verified_at')))
        Join-Text $result.Errors | Should -BeExactly $script:E6
    }

    It 'rejects a null verification time' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ verified_at = $null }))
        Join-Text $result.Errors | Should -BeExactly $script:E6
    }

    It 'rejects a whitespace-only verification time' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ verified_at = '   ' }))
        Join-Text $result.Errors | Should -BeExactly $script:E6
    }

    It 'rejects empty evidence' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ evidence = '' }))
        Join-Text $result.Errors | Should -BeExactly $script:E7
    }

    It 'rejects an empty waived list' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ waived_tools = @() }))
        Join-Text $result.Errors | Should -BeExactly $script:E8a
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects a malformed waived list of kind <Label>' -ForEach @(
        @{ Label = 'string'; Value = 'potential_to_issue' },
        @{ Label = 'blank-entry'; Value = @('potential_to_issue', ' ') },
        @{ Label = 'integer-entry'; Value = @('potential_to_issue', 7) }
    ) {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord -Override @{ waived_tools = $Value }))
        Join-Text $result.Errors | Should -BeExactly $script:E8a
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects a waived list that omits the issue-creation tool' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('new_potential_entry'); potential_record = $script:ValidRecord }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly $script:E8include
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects an invalid potential record when waiving the entry tool' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'new_potential_entry'); potential_record = 'notes/record.txt' }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E9 -Tool 'new_potential_entry')
        @($result.WaivedTools).Count | Should -Be 0
    }
}

Describe 'Issue adoption enforces the closed waivable set (AC-8)' {

    It 'rejects waiving the feature-folder tool' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'new_active_feature_folder') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E8Cannot -Tool 'new_active_feature_folder')
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'rejects waiving the artifact-validation tool' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'validate_orchestration_artifacts') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E8Cannot -Tool 'validate_orchestration_artifacts')
    }

    It 'rejects waiving the feature entry tool on a bug checkpoint' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'new_potential_entry'); potential_record = $script:ValidRecord }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption -PromotionType 'bug') -Required $script:LargeBugTools
        Join-Text $result.Errors | Should -BeExactly (Get-E8NotRequired -RouteId 'large' -Tool 'new_potential_entry')
    }

    It 'rejects any waiver on the remediation route' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord)) -RouteId 'remediation' -Required $script:RemediationTools -Successful $script:RemediationTools
        Join-Text $result.Errors | Should -BeExactly (Get-E8NotRequired -RouteId 'remediation' -Tool 'potential_to_issue')
    }

    It 'rejects waiving a tool that holds a successful receipt' {
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption (Get-AdoptionRecord)) -Successful $script:LargeTools
        Join-Text $result.Errors | Should -BeExactly (Get-E8Receipt -Tool 'potential_to_issue')
    }

    It 'rejects a tool listed twice' {
        $adoption = Get-AdoptionRecord -Override @{ waived_tools = @('potential_to_issue', 'potential_to_issue') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E8Duplicate -Tool 'potential_to_issue')
        @($result.WaivedTools).Count | Should -Be 0
    }
}

Describe 'Issue adoption fails closed and is presence gated (AC-9, AC-11)' {

    It 'empties the waived set whenever any error is reported across a fixed grid' {
        # Deterministic enumeration; no random source.
        $observedValid = 0
        $combinations = 0
        foreach ($issueNum in @('509', '0509')) {
            foreach ($origin in @('transferred', 'imported')) {
                foreach ($verifiedVia in @('gh_issue_view', 'curl')) {
                    foreach ($verifiedAt in @('2026-09-29T15:15:00Z', ' ')) {
                        foreach ($evidence in @('gh issue view 509', '')) {
                            foreach ($waived in @(, @('potential_to_issue')) + @(, @('potential_to_issue', 'new_potential_entry')) + @(, @())) {
                                $combinations++
                                $override = @{
                                    issue_num        = $issueNum
                                    issue_url        = "https://github.com/drmoisan/drm-copilot/issues/$issueNum"
                                    origin           = $origin
                                    verified_via     = $verifiedVia
                                    verified_at      = $verifiedAt
                                    evidence         = $evidence
                                    waived_tools     = [object[]]$waived
                                    potential_record = $script:ValidRecord
                                }
                                $adoption = Get-AdoptionRecord -Override $override
                                $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
                                if (@($result.Errors).Count -gt 0) {
                                    @($result.WaivedTools).Count | Should -Be 0 -Because "errors must empty the waived set for $issueNum/$origin/$verifiedVia"
                                }
                                else {
                                    $observedValid++
                                    Join-Sorted $result.WaivedTools | Should -BeExactly (Join-Sorted ([string[]]$waived))
                                }
                            }
                        }
                    }
                }
            }
        }
        $combinations | Should -Be 96
        $observedValid | Should -Be 2
    }

    It 'yields no errors and no waivers for a checkpoint without the adoption key' {
        $state = ConvertFrom-Json -InputObject '{"issue-num":"509","promotion-type":"feature"}'
        $result = Invoke-Adoption -State $state
        @($result.Errors).Count | Should -Be 0
        @($result.WaivedTools).Count | Should -Be 0
    }
}

Describe 'Routing contract wiring for issue adoption' {

    It 'returns no adoption errors and no waivers when issue_adoption is absent' {
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-LargeCheckpoint))
        Join-Text $errors | Should -BeExactly (Get-MissingReceipt -Tool 'potential_to_issue')
    }

    It 'fails closed and places adoption errors after the receipt loop and before local_execution_overrides errors' {
        $adoptionJson = ConvertTo-Json -InputObject (Get-AdoptionRecord -Override @{ origin = 'imported' }) -Depth 4 -Compress
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-LargeCheckpoint -AdoptionJson $adoptionJson -OverridesJson '["manual-step"]'))
        Join-Text $errors | Should -BeExactly (Join-Text @((Get-MissingReceipt -Tool 'potential_to_issue'), $script:E4, $script:Leo))
    }

    It 'waives the receipt requirement for a valid adoption record' {
        $adoptionJson = ConvertTo-Json -InputObject (Get-AdoptionRecord) -Depth 4 -Compress
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-LargeCheckpoint -AdoptionJson $adoptionJson))
        $errors.Count | Should -Be 0
    }

    It 'rejects the case-variant tool name Potential_To_Issue' {
        $adoptionJson = ConvertTo-Json -InputObject (Get-AdoptionRecord -Override @{ waived_tools = @('Potential_To_Issue') }) -Depth 4 -Compress
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-LargeCheckpoint -AdoptionJson $adoptionJson))
        $expected = @((Get-MissingReceipt -Tool 'potential_to_issue'), (Get-E8Cannot -Tool 'Potential_To_Issue'), $script:E8include)
        Join-Text $errors | Should -BeExactly (Join-Text $expected)
    }
}

Describe 'Issue adoption potential record requirement by origin (issue 849)' {

    It 'waives the bug entry tool without a record when origin is filed_before_orchestration' {
        $adoption = Get-AdoptionRecord -Override @{ origin = 'filed_before_orchestration'; waived_tools = @('potential_to_issue', 'new_potential_bug_entry') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption -PromotionType 'bug') -Required $script:LargeBugTools
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'new_potential_bug_entry,potential_to_issue'
    }

    It 'waives the feature entry tool without a record when origin is transferred' {
        $adoption = Get-AdoptionRecord -Override @{ origin = 'transferred'; waived_tools = @('potential_to_issue', 'new_potential_entry') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'new_potential_entry,potential_to_issue'
    }

    It 'waives the bug entry tool without a record on the preparation route' {
        $preparationBugTools = [string[]]@('new_potential_bug_entry', 'potential_to_issue', 'new_active_feature_folder', 'validate_orchestration_artifacts')
        $successful = [string[]]@('new_active_feature_folder', 'validate_orchestration_artifacts')
        $adoption = Get-AdoptionRecord -Override @{ origin = 'filed_before_orchestration'; waived_tools = @('potential_to_issue', 'new_potential_bug_entry') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption -PromotionType 'bug') -RouteId 'preparation' -Required $preparationBugTools -Successful $successful
        Join-Text $result.Errors | Should -BeExactly ''
        Join-Sorted $result.WaivedTools | Should -BeExactly 'new_potential_bug_entry,potential_to_issue'
    }

    It 'still reports rule 9 when origin is epic_decomposition and the record is absent' {
        $adoption = Get-AdoptionRecord -Override @{ origin = 'epic_decomposition'; waived_tools = @('potential_to_issue', 'new_potential_entry') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E9 -Tool 'new_potential_entry')
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'still reports rule 9 when origin is filed_before_orchestration and the record is null' {
        $adoption = Get-AdoptionRecord -Override @{ origin = 'filed_before_orchestration'; waived_tools = @('potential_to_issue', 'new_potential_entry'); potential_record = $null }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E9 -Tool 'new_potential_entry')
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'still reports rule 9 when origin is transferred and the record path is invalid' {
        $adoption = Get-AdoptionRecord -Override @{ origin = 'transferred'; waived_tools = @('potential_to_issue', 'new_potential_entry'); potential_record = 'notes/record.txt' }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Get-E9 -Tool 'new_potential_entry')
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'reports the origin error and rule 9 when origin is invalid and the record is absent' {
        $adoption = Get-AdoptionRecord -Override @{ origin = 'imported'; waived_tools = @('potential_to_issue', 'new_potential_entry') }
        $result = Invoke-Adoption -State (Get-AdoptionState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly (Join-Text @($script:E4, (Get-E9 -Tool 'new_potential_entry')))
        @($result.WaivedTools).Count | Should -Be 0
    }
}
