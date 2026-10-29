#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the issue-adoption feature_folder_record (issue #992).

.DESCRIPTION
    Mirrors tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py
    through Get-OrchestratorStateIssueAdoptionResult and the exported functions of
    OrchestratorStateFeatureFolderRecord.psm1: rule 10 (an object record is required when
    new_active_feature_folder is waived) and rules 11a to 11e. Checkpoints are built in memory
    and round-tripped through JSON; no file is written and no process is started.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    # The routing contract imports the adoption module, which imports the record module, each
    # with -Force. Importing in that order, the later two without -Force, keeps all three visible.
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateIssueAdoption.psm1')
    Import-Module (Join-Path $libDir 'OrchestratorStateFeatureFolderRecord.psm1')

    $script:FeatureFolder = 'docs/features/active/2026-09-29-sample-feature-509'
    $script:FolderTool = 'new_active_feature_folder'
    $script:LargeTools = [string[]]@('new_potential_entry', 'potential_to_issue', 'new_active_feature_folder', 'collect_pr_context', 'validate_orchestration_artifacts')
    $script:SuccessfulWithoutFolder = [string[]]@('collect_pr_context', 'validate_orchestration_artifacts')

    $script:E10 = 'Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.'
    $script:E11a = 'Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.'
    $script:E11b = 'Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.'
    $script:E11c = 'Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.'
    $script:E11d = 'Checkpoint issue_adoption.feature_folder_record.verified_at must be present.'
    $script:E11e = 'Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.'

    # A valid record with overrides and removals applied.
    function script:Get-FolderRecord {
        param([hashtable] $Override = @{}, [string[]] $Remove = @())
        $record = [ordered]@{
            path         = $script:FeatureFolder
            verified_via = 'git_cat_file_head'
            verified_at  = '2026-09-29T15:20:00Z'
            evidence     = "git cat-file -t HEAD:$($script:FeatureFolder) printed tree"
        }
        foreach ($key in $Override.Keys) { $record[$key] = $Override[$key] }
        foreach ($key in $Remove) { $record.Remove($key) }
        return $record
    }

    # The base adoption for issue 509, waiving the folder tool unless WaivedTools overrides it.
    function script:Get-FolderAdoption {
        param([AllowNull()][object] $Record, [switch] $OmitRecord, [object] $WaivedTools = @('potential_to_issue', 'new_active_feature_folder'))
        $adoption = [ordered]@{
            issue_num    = '509'
            issue_url    = 'https://github.com/drmoisan/drm-copilot/issues/509'
            origin       = 'transferred'
            verified_via = 'gh_issue_view'
            verified_at  = '2026-09-29T15:15:00Z'
            evidence     = 'gh issue view 509 --json number,state,url: number 509, state OPEN'
            waived_tools = $WaivedTools
        }
        if (-not $OmitRecord) { $adoption['feature_folder_record'] = $Record }
        return $adoption
    }

    # Serialize the checkpoint and parse it back, so values reach the module as ConvertFrom-Json output.
    function script:Get-FolderState {
        param([object] $Adoption, [AllowNull()][object] $Folder = $script:FeatureFolder, [switch] $OmitFolder)
        $state = [ordered]@{ 'issue-num' = '509'; 'promotion-type' = 'feature'; issue_adoption = $Adoption }
        if (-not $OmitFolder) { $state['feature-folder'] = $Folder }
        return (ConvertTo-Json -InputObject $state -Depth 8 | ConvertFrom-Json)
    }

    function script:Invoke-FolderAdoption {
        param([psobject] $State)
        return Get-OrchestratorStateIssueAdoptionResult -State $State -RouteId 'large' -RequiredMcpTool $script:LargeTools -SuccessfulTool $script:SuccessfulWithoutFolder
    }

    function script:Join-Text { param([AllowEmptyCollection()][string[]] $Value) return (@($Value) -join "`n") }
}

Describe 'feature_folder_record rule 10' {
    It 'waives the folder tool with a valid record' {
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record (Get-FolderRecord)))
        @($result.Errors).Count | Should -Be 0
        @($result.WaivedTools) | Should -Contain $script:FolderTool
    }

    It 'reports rule 10 when the record key is absent' {
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -OmitRecord))
        Join-Text $result.Errors | Should -BeExactly $script:E10
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'reports rule 10 for a <Label> record' -ForEach @(
        @{ Label = 'null'; Record = $null }
        @{ Label = 'string'; Record = 'docs/features/active/2026-09-29-sample-feature-509' }
        @{ Label = 'list'; Record = @('path') }
        @{ Label = 'number'; Record = 7 }
    ) {
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $Record))
        Join-Text $result.Errors | Should -BeExactly $script:E10
    }

    It 'is silent when the tool is not waived and no record exists' {
        $adoption = Get-FolderAdoption -OmitRecord -WaivedTools @('potential_to_issue')
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption $adoption)
        @($result.Errors).Count | Should -Be 0
    }
}

Describe 'feature_folder_record rule 11a' {
    It 'rejects a malformed path (<Label>)' -ForEach @(
        @{ Label = 'outside-prefix'; BadPath = 'docs/features/completed/2026-09-29-sample-feature-509' }
        @{ Label = 'dot-segment'; BadPath = 'docs/features/active/./2026-09-29-sample-feature-509' }
        @{ Label = 'dot-dot-segment'; BadPath = 'docs/features/active/../active/2026-09-29-sample-feature-509' }
        @{ Label = 'empty-segment'; BadPath = 'docs/features/active//2026-09-29-sample-feature-509' }
        @{ Label = 'trailing-slash'; BadPath = 'docs/features/active/2026-09-29-sample-feature-509/' }
        @{ Label = 'backslash'; BadPath = 'docs\features\active\2026-09-29-sample-feature-509' }
        @{ Label = 'drive-letter'; BadPath = 'C:/docs/features/active/2026-09-29-sample-feature-509' }
        @{ Label = 'leading-hyphen'; BadPath = 'docs/features/active/-2026-09-29-sample-feature-509' }
        @{ Label = 'glob-character'; BadPath = 'docs/features/active/2026-09-*' }
        @{ Label = 'prefix-only'; BadPath = 'docs/features/active/' }
        @{ Label = 'trailing-newline'; BadPath = "docs/features/active/2026-09-29-sample-feature-509`n" }
        @{ Label = 'empty'; BadPath = '' }
    ) {
        $record = Get-FolderRecord -Override @{ path = $BadPath }
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record) -Folder $BadPath)
        Join-Text $result.Errors | Should -BeExactly $script:E11a
        Test-OrchestratorStateFeatureFolderPath -Value $BadPath | Should -BeFalse
    }

    It 'rejects a non-string path' {
        $record = Get-FolderRecord -Override @{ path = 509 }
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))
        Join-Text $result.Errors | Should -BeExactly $script:E11a
    }

    It 'rejects a null path value' {
        Test-OrchestratorStateFeatureFolderPath -Value $null | Should -BeFalse
    }

    It 'accepts a valid nested path' {
        $nested = 'docs/features/active/epic-2026/child_1.v2'
        $record = Get-FolderRecord -Override @{ path = $nested }
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record) -Folder $nested)
        @($result.Errors).Count | Should -Be 0
        Test-OrchestratorStateFeatureFolderPath -Value $nested | Should -BeTrue
    }
}

Describe 'feature_folder_record rule 11b' {
    It 'requires equality with feature-folder (<Label>)' -ForEach @(
        @{ Label = 'different'; Folder = 'docs/features/active/2026-09-29-other-feature-510'; Omit = $false }
        @{ Label = 'case-variant'; Folder = 'DOCS/FEATURES/ACTIVE/2026-09-29-SAMPLE-FEATURE-509'; Omit = $false }
        @{ Label = 'number'; Folder = 992; Omit = $false }
        @{ Label = 'null'; Folder = $null; Omit = $false }
        @{ Label = 'absent'; Folder = 'docs/features/active/2026-09-29-sample-feature-509'; Omit = $true }
    ) {
        $state = Get-FolderState -Adoption (Get-FolderAdoption -Record (Get-FolderRecord)) -Folder $Folder -OmitFolder:$Omit
        Join-Text (Invoke-FolderAdoption -State $state).Errors | Should -BeExactly $script:E11b
    }
}

Describe 'feature_folder_record rules 11c to 11e' {
    It 'accepts verified_via <Value>' -ForEach @(@{ Value = 'git_ls_tree_head' }, @{ Value = 'git_cat_file_head' }) {
        $record = Get-FolderRecord -Override @{ verified_via = $Value }
        @((Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors).Count | Should -Be 0
    }

    It 'rejects verified_via <Label>' -ForEach @(
        @{ Label = 'git_status'; Value = 'git_status' }
        @{ Label = 'case-variant'; Value = 'GIT_CAT_FILE_HEAD' }
        @{ Label = 'null'; Value = $null }
        @{ Label = 'number'; Value = 1 }
    ) {
        $record = Get-FolderRecord -Override @{ verified_via = $Value }
        Join-Text (Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors | Should -BeExactly $script:E11c
    }

    It 'rejects verified_at <Label>' -ForEach @(
        @{ Label = 'null'; Value = $null }
        @{ Label = 'empty'; Value = '' }
        @{ Label = 'blank'; Value = '   ' }
    ) {
        $record = Get-FolderRecord -Override @{ verified_at = $Value }
        Join-Text (Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors | Should -BeExactly $script:E11d
    }

    It 'rejects an absent verified_at' {
        $record = Get-FolderRecord -Remove @('verified_at')
        Join-Text (Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors | Should -BeExactly $script:E11d
    }

    It 'treats verified_at as presence-only' {
        $record = Get-FolderRecord -Override @{ verified_at = 0 }
        @((Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors).Count | Should -Be 0
    }

    It 'rejects evidence <Label>' -ForEach @(
        @{ Label = 'empty'; Value = '' }
        @{ Label = 'blank'; Value = '  ' }
        @{ Label = 'null'; Value = $null }
        @{ Label = 'number'; Value = 3 }
    ) {
        $record = Get-FolderRecord -Override @{ evidence = $Value }
        Join-Text (Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors | Should -BeExactly $script:E11e
    }

    It 'accepts non-blank evidence' {
        $record = Get-FolderRecord -Override @{ evidence = 'git ls-tree HEAD printed the folder' }
        @((Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors).Count | Should -Be 0
    }

    It 'accumulates record errors in rule order' {
        $record = [ordered]@{ path = 'docs/x'; verified_via = 'x'; verified_at = ' '; evidence = '' }
        $expected = @($script:E11a, $script:E11c, $script:E11d, $script:E11e) -join "`n"
        Join-Text (Invoke-FolderAdoption -State (Get-FolderState -Adoption (Get-FolderAdoption -Record $record))).Errors | Should -BeExactly $expected
    }

    It 'validates a record when the tool is not waived' {
        $adoption = Get-FolderAdoption -Record (Get-FolderRecord -Override @{ evidence = '' }) -WaivedTools @('potential_to_issue')
        $result = Invoke-FolderAdoption -State (Get-FolderState -Adoption $adoption)
        Join-Text $result.Errors | Should -BeExactly $script:E11e
        @($result.WaivedTools).Count | Should -Be 0
    }

    It 'does not run record rules when waived_tools is malformed' {
        $adoption = Get-FolderAdoption -Record (Get-FolderRecord -Override @{ evidence = '' }) -WaivedTools 'potential_to_issue'
        $errors = @((Invoke-FolderAdoption -State (Get-FolderState -Adoption $adoption)).Errors)
        $errors | Should -Not -Contain $script:E11e
        $errors | Should -Not -Contain $script:E10
    }
}

Describe 'Get-OrchestratorStateFeatureFolderRecordError direct calls' {
    It 'returns nothing for an adoption without a record and without the waiver' {
        $state = Get-FolderState -Adoption (Get-FolderAdoption -OmitRecord -WaivedTools @('potential_to_issue'))
        $errors = Get-OrchestratorStateFeatureFolderRecordError -Adoption $state.issue_adoption -State $state -WaivedTool @('potential_to_issue')
        @($errors).Count | Should -Be 0
    }

    It 'returns rule 10 for a waived tool without a record' {
        $state = Get-FolderState -Adoption (Get-FolderAdoption -OmitRecord)
        $errors = Get-OrchestratorStateFeatureFolderRecordError -Adoption $state.issue_adoption -State $state -WaivedTool @('potential_to_issue', 'new_active_feature_folder')
        Join-Text $errors | Should -BeExactly $script:E10
    }
}
