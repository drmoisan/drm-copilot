#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree rows for .claude/hooks/validate-docs-role-output.ps1 (issue #1163).

.DESCRIPTION
    A documentation role that works in an item worktree reports repository-relative paths. The
    hook resolves the item worktree from the delegation prompt named by agent_transcript_path
    (D8) and probes each docs-profile, docs-snapshot, and docs-pages-written value beneath it;
    an unresolved present identity blocks before any probe; with no identity the
    repository-relative probe is unchanged.

    Argument builder: Get-DocsRoleTargetArgument adds -SessionRoot, -ReadTranscriptHead, and
    -WorktreeListInvoker only when Get-Command reports that Invoke-DocsRoleOutputValidation
    declares them, so each row runs unchanged against the unmodified hook (fail-before) and the
    changed hook (pass-after). Transcript lines and worktree lists are in-memory, and
    Test-DocsRoleOutputFile is mocked, so no row reads or creates a file or runs git.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-docs-role-output.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    $script:SessionRoot = '/repo'
    $script:ItemRoot = '/repo/.claude/worktrees/item'
    $porcelain = "worktree /repo`nbranch refs/heads/main`n`nworktree /repo/.claude/worktrees/item`nbranch refs/heads/bug/item`n`nworktree /sibling/item-b`nbranch refs/heads/bug/twice`n`nworktree /sibling/item-c`nbranch refs/heads/bug/twice`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelain }.GetNewClosure()
    $script:Output = @{
        'docs-architect' = "docs-role: docs-architect`ndocs-result: PASS`ndocs-findings: 0`ndocs-profile: docs/documentation-estate/docs-profile.json`ndocs-snapshot: docs/documentation-estate/inventory.json`ndocs-pages-planned: 3`n`n## Information Architecture`n`n- docs/guide/index.md"
        'docs-author'    = "docs-role: docs-author`ndocs-result: PASS`ndocs-findings: 0`ndocs-pages-written: docs/guide/index.md`ndocs-check-exit-code: 0"
    }

    function Get-DocsRoleTargetReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    # Builds the validation arguments; the seams this item adds are passed only when declared.
    function Get-DocsRoleTargetArgument {
        param([string] $Role, [string] $Prompt)
        $envelope = [ordered]@{ session_id = 's-1163'; hook_event_name = 'SubagentStop'; agent_type = $Role; stop_hook_active = $false; agent_transcript_path = 'transcripts/subagents/agent-1163.jsonl'; last_assistant_message = $script:Output[$Role] }
        $arguments = @{ InputText = ($envelope | ConvertTo-Json -Compress) }
        $parameters = (Get-Command -Name Invoke-DocsRoleOutputValidation).Parameters
        if ($parameters.ContainsKey('SessionRoot')) { $arguments['SessionRoot'] = $script:SessionRoot }
        if ($parameters.ContainsKey('ReadTranscriptHead')) { $arguments['ReadTranscriptHead'] = (Get-DocsRoleTargetReader -Prompt $Prompt) }
        if ($parameters.ContainsKey('WorktreeListInvoker')) { $arguments['WorktreeListInvoker'] = $script:ListInvoker }
        return $arguments
    }
}

Describe 'epic-state baseline isolation (issue #1163)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'validate-docs-role-output target worktree (issue #1163)' {
    It 'probes the <Role> output paths beneath the item worktree named by the prompt branch' -ForEach @(
        @{ Role = 'docs-architect'; Probes = @('/repo/.claude/worktrees/item/docs/documentation-estate/docs-profile.json', '/repo/.claude/worktrees/item/docs/documentation-estate/inventory.json') }
        @{ Role = 'docs-author'; Probes = @('/repo/.claude/worktrees/item/docs/guide/index.md') }
    ) {
        # Arrange (fails before: the unmodified hook probes the repository-relative values)
        $itemRoot = $script:ItemRoot
        Mock Test-DocsRoleOutputFile { param([string] $Path) $Path.StartsWith("$itemRoot/") }.GetNewClosure()
        $arguments = Get-DocsRoleTargetArgument -Role $Role -Prompt "Canonical issue number for this feature is 1163.`nbranch: bug/item"

        # Act
        $result = Invoke-DocsRoleOutputValidation @arguments

        # Assert
        $result.Ok | Should -BeTrue -Because ([string]$result.Message)
        foreach ($probe in $Probes) {
            $expected = $probe
            Should -Invoke Test-DocsRoleOutputFile -Times 1 -Exactly -ParameterFilter { $Path -eq $expected }
        }
    }

    It 'blocks without a probe when the prompt branch resolves to <ReasonCode>' -ForEach @(
        @{ ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Prompt = 'branch: bug/unknown-branch' }
        @{ ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; Prompt = 'branch: bug/twice' }
    ) {
        # Arrange (fails before: the unmodified hook probes the session-root values)
        Mock Test-DocsRoleOutputFile { throw 'the docs-role probe must not be called for an unresolved identity' }
        $arguments = Get-DocsRoleTargetArgument -Role 'docs-architect' -Prompt $Prompt

        # Act
        $result = Invoke-DocsRoleOutputValidation @arguments

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "DOCS_ROLE_OUTPUT_BLOCKED:*$ReasonCode*"
        $result.Message | Should -Not -BeLike '*not repairable*'
        Should -Invoke Test-DocsRoleOutputFile -Times 0 -Exactly
    }

    It 'keeps the repository-relative probes when the prompt carries no identity' {
        # Arrange
        Mock Test-DocsRoleOutputFile { param([string] $Path) -not $Path.StartsWith('/') }
        $arguments = Get-DocsRoleTargetArgument -Role 'docs-author' -Prompt 'Write the guide pages.'

        # Act
        $result = Invoke-DocsRoleOutputValidation @arguments

        # Assert
        $result.Ok | Should -BeTrue -Because ([string]$result.Message)
        Should -Invoke Test-DocsRoleOutputFile -Times 1 -Exactly -ParameterFilter { $Path -eq 'docs/guide/index.md' }
    }
}
