#Requires -Version 7.0

<#
.SYNOPSIS
    Non-ASCII relay, ledger, decision-file, and stdin-decode tests for enforce-owner-directive-pass-down.ps1 (issue #1187).

.DESCRIPTION
    The hook and the Claude PreToolUse dispatcher are dot-sourced, so neither entry point runs, and
    Get-OwnerDirectivePassDownDecision is called with injected seams: an in-memory file map keyed by
    /synthetic-worktrees/ paths, an in-memory worktree listing, a fixed clock, and fixed resolvers.
    Every non-ASCII character is built from its code point, so this file holds ASCII characters only.
    Byte input reaches the dispatcher reader through an in-memory stream. No test touches the file
    system, git, the console encodings, or the wall clock.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected seam stubs mirror the production script-block signatures and ignore some parameters.')]
param()

BeforeDiscovery {
    $script:CharacterCases = @(
        @{ Name = 'an em dash'; Substitute = 'a hyphen'; Text = ('Run the items in parallel ' + [char]0x2014 + ' the merge cost is lower.'); Altered = 'Run the items in parallel - the merge cost is lower.' }
        @{ Name = 'curly quotes'; Substitute = 'straight quotes'; Text = ('Use the ' + [char]0x201C + 'fast' + [char]0x201D + ' route for the items.'); Altered = 'Use the "fast" route for the items.' }
        @{ Name = 'a non-BMP character'; Substitute = 'the character removed'; Text = ('Ship the items in parallel ' + [char]::ConvertFromUtf32(0x1F600) + ' today.'); Altered = 'Ship the items in parallel  today.' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.claude/hooks/enforce-owner-directive-pass-down.ps1')
    . (Join-Path $script:RepoRoot '.claude/hooks/invoke-pretooluse-dispatch.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Mock Read-OwnerDirectiveFileText { $null }

    $script:Session = '/synthetic-worktrees/main'
    $script:Item = '/synthetic-worktrees/item-1157'
    $script:NowText = '2026-11-10T12:00:00Z'
    $script:ItemCheckpointPath = "$script:Item/artifacts/orchestration/orchestrator-state.json"
    $script:ItemLedgerPath = "$script:Item/artifacts/orchestration/owner-directives.jsonl"
    $script:PromptHead = "Execute the plan.`nbranch: feature/owner-directive-pass-down-1157`nCanonical issue number for this feature is 1157.`n"
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-NonAsciiTestDigest {
        param([string] $Text)
        return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($script:Utf8.GetBytes($Text))).ToLowerInvariant()
    }

    function Get-NonAsciiTestEntry {
        param([string] $Id = 'OD-1', [string] $Text, [string] $DigestText)
        if (-not $PSBoundParameters.ContainsKey('DigestText')) { $DigestText = $Text }
        return ([ordered]@{
                id = $Id; text = $Text; text_sha256 = (Get-NonAsciiTestDigest -Text $DigestText); class = 'scheduling'; recorded_at = '2026-11-01T00:00:00Z'; expires_at = '2026-11-11T00:00:00Z'
                scope = [ordered]@{ issue = 1157; branch = 'feature/owner-directive-pass-down-1157'; step = 'any' }; issued_by_session = 'coordinator-session-1187'
            } | ConvertTo-Json -Compress -Depth 4)
    }

    function Get-NonAsciiTestCheckpoint {
        param([string[]] $Directive = @())
        $text = '{"issue-num":"1157","next_step":"S5"'
        if ($Directive.Count -gt 0) { $text += ',"owner_directives":[' + ($Directive -join ',') + ']' }
        return $text + '}'
    }

    function Get-NonAsciiTestBlock {
        param([string[]] $Entry)
        $source = [pscustomobject]@{ Name = 'item-ledger'; Text = ($Entry -join "`n"); IsEpicParent = $false }
        $selected = (Select-OwnerDirectivePassDown -Source @($source) -ItemIssue 1157 -ItemBranch $null -ItemStep $null -Now ([datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc))).Selected
        return (Format-OwnerDirectiveBlock -Selected $selected)
    }

    function Invoke-NonAsciiPassDownTest {
        param([string] $HookInputRaw, [hashtable] $Files = @{})
        $map = @{}
        foreach ($key in $Files.Keys) { $map[$key] = $Files[$key] }
        $porcelain = @(
            'worktree /synthetic-worktrees/main', 'branch refs/heads/main', ''
            'worktree /synthetic-worktrees/item-1157', 'branch refs/heads/feature/owner-directive-pass-down-1157', ''
        ) -join "`n"
        $arguments = @{
            HookInputRaw        = $HookInputRaw
            SessionRoot         = '/synthetic-worktrees/main'
            ReadText            = { param($Path) $map[([string] $Path).Replace('\', '/')] }.GetNewClosure()
            ReadTranscriptHead  = { param($Path) $null }
            WorktreeListInvoker = { param($SessionRoot) $porcelain }.GetNewClosure()
            EpicResolver        = { param($IntegrationBranch, $SessionRoot) [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null } }
            ParallelResolver    = { param($ParallelSlug, $SessionRoot) [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null } }
            TestFile            = { param($Path) $map.ContainsKey(([string] $Path).Replace('\', '/')) }.GetNewClosure()
            Clock               = { [datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc) }
        }
        return (Get-OwnerDirectivePassDownDecision @arguments)
    }

    function ConvertTo-NonAsciiPayloadText {
        param([hashtable] $Payload)
        return ($Payload | ConvertTo-Json -Compress -Depth 6)
    }

    function Get-NonAsciiDelegation {
        param([string] $Prompt)
        return @{ tool_name = 'Agent'; cwd = '/synthetic-worktrees/main'; tool_input = @{ subagent_type = 'atomic-executor'; prompt = $Prompt } }
    }

    function Get-NonAsciiLedgerCall {
        param([string] $Content)
        return @{ tool_name = 'Write'; cwd = '/synthetic-worktrees/main'; tool_input = @{ file_path = $script:ItemLedgerPath; content = $Content } }
    }

    function Get-NonAsciiReason {
        param($Decision)
        return [string] $Decision.hookSpecificOutput.permissionDecisionReason
    }

    $script:BaseLedgerEntry = Get-NonAsciiTestEntry -Id 'OD-1' -Text ('The existing ' + [char]0x2014 + ' ' + [char]0x201C + 'ledger' + [char]0x201D + ' line ' + [char]::ConvertFromUtf32(0x1F600) + '.')
}

AfterAll {
    Remove-Module -Name HookDispatchRunner, HookDispatch -Force -ErrorAction SilentlyContinue
}

Describe 'relay match of non-ASCII directive text (issue #1187 AC-6)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'allows a verbatim relay of text containing <Name>' -ForEach $script:CharacterCases {
        $entry = Get-NonAsciiTestEntry -Text $Text
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint -Directive @($entry)) }
        $prompt = $script:PromptHead + (Get-NonAsciiTestBlock -Entry @($entry))
        Invoke-NonAsciiPassDownTest -HookInputRaw (ConvertTo-NonAsciiPayloadText (Get-NonAsciiDelegation -Prompt $prompt)) -Files $files | Should -BeNullOrEmpty
    }

    It 'denies a relay whose <Name> is replaced by <Substitute>' -ForEach $script:CharacterCases {
        $entry = Get-NonAsciiTestEntry -Text $Text
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint -Directive @($entry)) }
        $block = Get-NonAsciiTestBlock -Entry @($entry)
        $block.Contains($Text) | Should -BeTrue -Because 'the rendered block quotes the directive text verbatim'
        $prompt = $script:PromptHead + $block.Replace($Text, $Altered)
        $reason = Get-NonAsciiReason (Invoke-NonAsciiPassDownTest -HookInputRaw (ConvertTo-NonAsciiPayloadText (Get-NonAsciiDelegation -Prompt $prompt)) -Files $files)
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED: *'
    }

    It 'records a text_sha256 equal to the digest the hook validates for <Name>' -ForEach $script:CharacterCases {
        $entry = Get-NonAsciiTestEntry -Text $Text
        $hookDigest = InModuleScope OrchestratorStateOwnerDirectives -Parameters @{ DirectiveText = $Text } { param($DirectiveText) Get-OwnerDirectiveTextDigest -Text $DirectiveText }
        ($entry | ConvertFrom-Json).text_sha256 | Should -BeExactly $hookDigest
        $hookDigest | Should -BeExactly (Get-NonAsciiTestDigest -Text $Text)
    }
}

Describe 'ledger append of non-ASCII entries (issue #1187 AC-7)' {
    It 'allows a main-session append of a <Name> entry to a ledger holding non-ASCII lines' -ForEach $script:CharacterCases {
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint); $script:ItemLedgerPath = $script:BaseLedgerEntry }
        $content = $script:BaseLedgerEntry + "`n" + (Get-NonAsciiTestEntry -Id 'OD-2' -Text $Text) + "`n"
        Invoke-NonAsciiPassDownTest -HookInputRaw (ConvertTo-NonAsciiPayloadText (Get-NonAsciiLedgerCall -Content $content)) -Files $files | Should -BeNullOrEmpty
    }

    It 'denies an edit of an existing non-ASCII ledger line' {
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint); $script:ItemLedgerPath = $script:BaseLedgerEntry }
        $content = (Get-NonAsciiTestEntry -Id 'OD-1' -Text 'The existing - "ledger" line.') + "`n"
        $reason = Get-NonAsciiReason (Invoke-NonAsciiPassDownTest -HookInputRaw (ConvertTo-NonAsciiPayloadText (Get-NonAsciiLedgerCall -Content $content)) -Files $files)
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_LEDGER_WRITE_DENIED: *'
    }

    It 'denies an appended non-ASCII line whose digest covers altered text' -ForEach $script:CharacterCases {
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint); $script:ItemLedgerPath = $script:BaseLedgerEntry }
        $content = $script:BaseLedgerEntry + "`n" + (Get-NonAsciiTestEntry -Id 'OD-2' -Text $Text -DigestText $Altered) + "`n"
        $reason = Get-NonAsciiReason (Invoke-NonAsciiPassDownTest -HookInputRaw (ConvertTo-NonAsciiPayloadText (Get-NonAsciiLedgerCall -Content $content)) -Files $files)
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_LEDGER_WRITE_DENIED: *'
    }
}

Describe 'decision files with non-ASCII reasons (issue #1187 AC-8)' {
    It 'accepts a decision-file write whose reason contains <Name>' -ForEach $script:CharacterCases {
        $entry = Get-NonAsciiTestEntry -Text 'Run the features in parallel where the merge cost is lower.'
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint -Directive @($entry)) }
        $line = "OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | $script:NowText | $Text`n"
        $call = @{ tool_name = 'Write'; cwd = $script:Item; agent_type = 'atomic-executor'; agent_id = 'a1'; tool_input = @{ file_path = "$script:Item/artifacts/orchestration/owner-directive-decisions/a1/OD-1.md"; content = $line } }
        Invoke-NonAsciiPassDownTest -HookInputRaw (ConvertTo-NonAsciiPayloadText $call) -Files $files | Should -BeNullOrEmpty
    }
}

Describe 'stdin decode contrast (issue #1187 AC-12)' {
    It 'denies the Latin1 decode and allows the UTF-8 reader decode of the same relay bytes' {
        # Arrange: one relay payload whose directive text holds all three characters, as UTF-8 bytes.
        $text = 'Relay ' + [char]0x2014 + ' ' + [char]0x201C + 'as written' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600) + ' verbatim.'
        $entry = Get-NonAsciiTestEntry -Text $text
        $files = @{ $script:ItemCheckpointPath = (Get-NonAsciiTestCheckpoint -Directive @($entry)) }
        $prompt = $script:PromptHead + (Get-NonAsciiTestBlock -Entry @($entry))
        $bytes = $script:Utf8.GetBytes((ConvertTo-NonAsciiPayloadText (Get-NonAsciiDelegation -Prompt $prompt)))

        # Act: the console decode the defect produced, and the dispatcher reader over the same bytes.
        $latin1Text = [System.Text.Encoding]::Latin1.GetString($bytes)
        $stream = [System.IO.MemoryStream]::new($bytes)
        $readerText = Read-PreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure()

        # Assert
        (Get-NonAsciiReason (Invoke-NonAsciiPassDownTest -HookInputRaw $latin1Text -Files $files)) | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED: *'
        Invoke-NonAsciiPassDownTest -HookInputRaw $readerText -Files $files | Should -BeNullOrEmpty
    }
}
