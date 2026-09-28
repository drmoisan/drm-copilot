#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Fail-closed matrix for the sanctioned-removal manifest branch of both worktree
    removal gate hooks (issue #635).

.DESCRIPTION
    Each case in the tables below differs from one canonical, fully authorizing
    manifest document in exactly the property its case name states, so a deny it
    produces is attributable to that property alone. Every case is exercised against
    BOTH gates: the two Describe blocks below run the same tables, one dot-sourcing
    the epic hook and one the parallel hook, in separate blocks with separate
    BeforeAll bodies so the two hooks' script-scope state does not collide.

    Determinism. Every manifest fixture is a literal JSON string returned by a mock
    of the module read seam, and every clock value is a constructed UTC DateTime
    returned by a mock of the module clock seam, both registered with
    -ModuleName 'CleanupWorktreeManifest' so they intercept the call the module makes
    to itself. Each mock body is built with [scriptblock]::Create from a literal
    expression string rather than captured from a test-scope variable, because a
    -ModuleName mock body executes in the module's session state where a test-scope
    variable does not resolve. No test creates, writes, or reads a temporary file,
    reads a wall clock, spawns a process, or touches the network.

    Every test also mocks the checkpoint seams of the hook under test, so no test
    reads live local orchestration state. The epic block mocks both of that hook's
    seams and the parallel block mocks its single seam.
#>

BeforeDiscovery {
    # The two canonical fixtures, expressed as ordered member tables so a case can
    # drop or replace exactly one member. Values are JSON fragments, already quoted
    # where the JSON type is a string.
    $script:RecordOrder = @('worktree_path', 'branch', 'branch_state', 'removal_disposition', 'verdict', 'evidence')
    $script:RecordValue = @{
        worktree_path       = '"/repo/worktrees/cleanup-target"'
        branch              = 'null'
        branch_state        = '"HAS_UNIQUE_RESIDUALS"'
        removal_disposition = '"SAFE_TO_DELETE"'
        verdict             = '"ALREADY_SOLVED_ELSEWHERE"'
        evidence            = '"Residual commit 3f9a1c2 is already fixed on main."'
    }
    $script:ManifestOrder = @('tool', 'schema_version', 'generated_at', 'run_id', 'removals', 'preserved_files')
    $script:ManifestValue = @{
        tool            = '"cleanup-merged-worktrees"'
        schema_version  = '1'
        generated_at    = '"2026-09-07T03:40:00Z"'
        run_id          = '"cleanup-2026-09-07T03-40-00Z-a47a5e33"'
        removals        = $null
        preserved_files = '[]'
    }

    function Get-CleanupManifestRecordLiteral {
        <#
        .SYNOPSIS
            Compose one removals[] record as a JSON fragment.
        #>
        param([hashtable] $Override = @{}, [string[]] $Drop = @())

        $members = @()
        foreach ($name in $script:RecordOrder) {
            if ($Drop -contains $name) { continue }
            $value = if ($Override.ContainsKey($name)) { $Override[$name] } else { $script:RecordValue[$name] }
            $members += ('"' + $name + '":' + $value)
        }
        return '{' + ($members -join ',') + '}'
    }

    function Get-CleanupManifestBodyLiteral {
        <#
        .SYNOPSIS
            Compose the whole manifest document and wrap it as a PowerShell
            single-quoted string literal, ready for [scriptblock]::Create.
        #>
        param([hashtable] $Override = @{}, [string[]] $Drop = @())

        $members = @()
        foreach ($name in $script:ManifestOrder) {
            if ($Drop -contains $name) { continue }
            $value = if ($Override.ContainsKey($name)) {
                $Override[$name]
            } elseif ($name -eq 'removals') {
                '[' + (Get-CleanupManifestRecordLiteral) + ']'
            } else {
                $script:ManifestValue[$name]
            }
            $members += ('"' + $name + '":' + $value)
        }
        return "'{" + ($members -join ',') + "}'"
    }

    function Get-CleanupManifestBodyForRecord {
        <#
        .SYNOPSIS
            Compose a manifest whose single removals[] record carries the supplied
            record-level override or omission.
        #>
        param([hashtable] $Override = @{}, [string[]] $Drop = @())

        $record = Get-CleanupManifestRecordLiteral -Override $Override -Drop $Drop
        return Get-CleanupManifestBodyLiteral -Override @{ removals = ('[' + $record + ']') }
    }

    $script:StandardClock = '[datetime]::new(2026, 9, 7, 4, 0, 0, [System.DateTimeKind]::Utc)'
    $script:StandardCommand = 'git worktree remove /repo/worktrees/cleanup-target'

    # Cases whose expected decision is deny. Grouped by the allow-predicate condition
    # each one falsifies.
    $script:DenyCases = @(
        # Condition 1 -- the manifest exists, is readable, and parses as JSON.
        @{ Case = 'the manifest file is absent'; Body = '$null' }
        @{ Case = 'the raw manifest text is whitespace only'; Body = "'   '" }
        @{ Case = 'the manifest text does not parse as JSON'; Body = "'{not-json'" }

        # Condition 2 -- the self-identifying discriminator and the contract version.
        @{ Case = 'tool is absent'; Body = (Get-CleanupManifestBodyLiteral -Drop 'tool') }
        @{ Case = 'tool names another producer'; Body = (Get-CleanupManifestBodyLiteral -Override @{ tool = '"some-other-tool"' }) }
        @{ Case = 'schema_version is absent'; Body = (Get-CleanupManifestBodyLiteral -Drop 'schema_version') }
        @{ Case = 'schema_version is not an integer'; Body = (Get-CleanupManifestBodyLiteral -Override @{ schema_version = '"one"' }) }
        @{ Case = 'schema_version is a forward version'; Body = (Get-CleanupManifestBodyLiteral -Override @{ schema_version = '2' }) }

        # Condition 3 -- freshness, measured against the injected clock only. Every
        # case here fixes the clock at 2026-09-07T04:00:00Z and moves generated_at.
        @{ Case = 'generated_at is absent'; Body = (Get-CleanupManifestBodyLiteral -Drop 'generated_at') }
        @{ Case = 'generated_at does not parse as a timestamp'; Body = (Get-CleanupManifestBodyLiteral -Override @{ generated_at = '"not-a-timestamp"' }) }
        @{ Case = 'generated_at is in the future'; Body = (Get-CleanupManifestBodyLiteral -Override @{ generated_at = '"2026-09-07T05:00:00Z"' }) }
        @{ Case = 'generated_at is one second beyond the twenty-four hour bound'; Body = (Get-CleanupManifestBodyLiteral -Override @{ generated_at = '"2026-09-06T03:59:59Z"' }) }

        # Condition 4 -- removals is present, is an array, and is non-empty.
        @{ Case = 'removals is absent'; Body = (Get-CleanupManifestBodyLiteral -Drop 'removals') }
        @{ Case = 'removals is not an array'; Body = (Get-CleanupManifestBodyLiteral -Override @{ removals = '"not-an-array"' }) }
        @{ Case = 'removals is an empty array'; Body = (Get-CleanupManifestBodyLiteral -Override @{ removals = '[]' }) }

        # Condition 5 -- the first record whose normalized path matches the target.
        @{ Case = 'no recorded worktree_path matches the target'; Body = (Get-CleanupManifestBodyLiteral); Command = 'git worktree remove /repo/worktrees/some-other-target' }

        # Condition 6 -- removal_disposition is in the single-member allowed set.
        @{ Case = 'removal_disposition is absent'; Body = (Get-CleanupManifestBodyForRecord -Drop 'removal_disposition') }
        @{ Case = 'removal_disposition is PRESERVE'; Body = (Get-CleanupManifestBodyForRecord -Override @{ removal_disposition = '"PRESERVE"' }) }
        @{ Case = 'removal_disposition is outside the allowed set'; Body = (Get-CleanupManifestBodyForRecord -Override @{ removal_disposition = '"MAYBE_DELETE"' }) }

        # Condition 7 -- evidence is a present, non-empty justification.
        @{ Case = 'evidence is absent'; Body = (Get-CleanupManifestBodyForRecord -Drop 'evidence') }
        @{ Case = 'evidence is an empty string'; Body = (Get-CleanupManifestBodyForRecord -Override @{ evidence = '""' }) }
        @{ Case = 'evidence is whitespace only'; Body = (Get-CleanupManifestBodyForRecord -Override @{ evidence = '"   "' }) }

        # Condition 8 -- the verdict is one the skill does not classify as preserve.
        @{ Case = 'verdict is absent'; Body = (Get-CleanupManifestBodyForRecord -Drop 'verdict') }
        @{ Case = 'verdict is outside the vocabulary'; Body = (Get-CleanupManifestBodyForRecord -Override @{ verdict = '"PROBABLY_FINE"' }) }
        @{ Case = 'verdict is GENUINELY_NEW'; Body = (Get-CleanupManifestBodyForRecord -Override @{ verdict = '"GENUINELY_NEW"' }) }
        @{ Case = 'verdict is STILL_RELEVANT'; Body = (Get-CleanupManifestBodyForRecord -Override @{ verdict = '"STILL_RELEVANT"' }) }

        # Condition 9 -- branch_state is one of the two durable-residual states. The
        # three merged states and the detached case belong to the cleanup script's
        # deterministic apply path, and PROTECTED_CURRENT is never authorized.
        @{ Case = 'branch_state is absent'; Body = (Get-CleanupManifestBodyForRecord -Drop 'branch_state') }
        @{ Case = 'branch_state is PROTECTED_CURRENT'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"PROTECTED_CURRENT"' }) }
        @{ Case = 'branch_state is MERGED_CLEAN'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"MERGED_CLEAN"' }) }
        @{ Case = 'branch_state is MERGED_CONTENT_NEUTRAL'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"MERGED_CONTENT_NEUTRAL"' }) }
        @{ Case = 'branch_state is MERGED_EQUIVALENT'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"MERGED_EQUIVALENT"' }) }
        @{ Case = 'branch_state is outside the vocabulary'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"SOMETHING_ELSE"' }) }
    )

    # Cases whose expected decision is allow. Each states its decision explicitly
    # rather than leaving it to be inferred from the absence of a deny case.
    $script:AllowCases = @(
        # Condition 3 -- exactly at the twenty-four hour bound. The bound is inclusive:
        # the predicate denies only when the age is GREATER than 24 hours, so a
        # manifest generated exactly 24 hours before the injected clock still
        # authorizes. Pinned explicitly because an off-by-one in either direction here
        # would otherwise be invisible.
        @{ Case = 'generated_at sits exactly on the twenty-four hour bound'; Body = (Get-CleanupManifestBodyLiteral -Override @{ generated_at = '"2026-09-06T04:00:00Z"' }) }

        # Condition 5 -- three spellings of one location all compare equal to the
        # recorded POSIX worktree_path, and a keyless neighbour does not abort the scan.
        @{ Case = 'the target carries a trailing slash'; Body = (Get-CleanupManifestBodyLiteral); Command = 'git worktree remove /repo/worktrees/cleanup-target/' }
        @{ Case = 'the target is quoted'; Body = (Get-CleanupManifestBodyLiteral); Command = 'git worktree remove "/repo/worktrees/cleanup-target"' }
        @{ Case = 'the target uses Windows separators'; Body = (Get-CleanupManifestBodyForRecord -Override @{ worktree_path = '"C:/repos/wt/agent-0f1c2d"' }); Command = 'git worktree remove C:\repos\wt\agent-0f1c2d' }
        @{ Case = 'a record with no worktree_path key precedes the matching record'; Body = (Get-CleanupManifestBodyLiteral -Override @{ removals = ('[' + (Get-CleanupManifestRecordLiteral -Drop 'worktree_path') + ',' + (Get-CleanupManifestRecordLiteral) + ']') }) }

        # Condition 9 -- the two authorized branch states, each asserted explicitly.
        @{ Case = 'branch_state is NOT_MERGED'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"NOT_MERGED"' }) }
        @{ Case = 'branch_state is HAS_UNIQUE_RESIDUALS'; Body = (Get-CleanupManifestBodyForRecord -Override @{ branch_state = '"HAS_UNIQUE_RESIDUALS"' }) }
    )

    # The preserved_files isolation pin. The two documents differ only in that array,
    # which belongs to a different consumer and must never influence a gate decision.
    # Carried through -ForEach as a single-element list because a variable set during
    # discovery does not resolve in a run-phase It body.
    $script:PreservedFilesCases = @(
        @{
            Case          = 'preserved_files does not influence the decision'
            MalformedBody = (Get-CleanupManifestBodyLiteral -Override @{ preserved_files = '"not-an-array"' })
            Body          = (Get-CleanupManifestBodyLiteral -Override @{ preserved_files = '[]' })
        }
    )

    # The duplicate-path resolution pin. Two records share one normalized
    # worktree_path; the scan stops at the first match, so the leading record decides.
    $script:DuplicateCases = @(
        @{
            Case           = 'duplicate worktree_path records resolve on the first match'
            NonAuthorizing = (Get-CleanupManifestBodyLiteral -Override @{ removals = ('[' + (Get-CleanupManifestRecordLiteral -Override @{ removal_disposition = '"PRESERVE"' }) + ',' + (Get-CleanupManifestRecordLiteral) + ']') })
            Body           = (Get-CleanupManifestBodyLiteral -Override @{ removals = ('[' + (Get-CleanupManifestRecordLiteral) + ',' + (Get-CleanupManifestRecordLiteral -Override @{ removal_disposition = '"PRESERVE"' }) + ']') })
        }
    )

    # Fill the two optional per-case fields so every case carries the full variable
    # set the It bodies bind. A case that needs a different clock or command states it
    # explicitly above and is left alone here.
    foreach ($case in ($script:DenyCases + $script:AllowCases + $script:PreservedFilesCases + $script:DuplicateCases)) {
        if (-not $case.ContainsKey('Clock')) { $case.Clock = $script:StandardClock }
        if (-not $case.ContainsKey('Command')) { $case.Command = $script:StandardCommand }
    }
}

Describe 'enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1").Path -Force
    }

    BeforeEach {
        # Both seams mocked, as this hook's suite rule requires of every test that can
        # reach a deny. Neither fixture records the target, so condition 10 permits the
        # manifest branch to be reached and the decision turns on the manifest alone.
        Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { '{"features":[]}' }
        Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { '{"route_id":"parallel","items":[]}' }
    }

    It 'denies when <Case>' -ForEach $script:DenyCases {
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED*'
    }

    It 'allows when <Case>' -ForEach $script:AllowCases {
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'never reads preserved_files' -ForEach $script:PreservedFilesCases {
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($MalformedBody))
        $malformed = (Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        $empty = (Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
        $malformed | Should -BeExactly $empty
        $empty | Should -Be 'allow'
    }

    It 'resolves duplicate worktree_path records on the first match' -ForEach $script:DuplicateCases {
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($NonAuthorizing))
        (Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        (Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }
}

Describe 'enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1").Path -Force
    }

    BeforeEach {
        # This hook defines one checkpoint seam. The fixture records no item, so
        # condition 10 permits the manifest branch to be reached.
        Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { '{"items":[]}' }
    }

    It 'denies when <Case>' -ForEach $script:DenyCases {
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
    }

    It 'allows when <Case>' -ForEach $script:AllowCases {
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'never reads preserved_files' -ForEach $script:PreservedFilesCases {
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($MalformedBody))
        $malformed = (Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        $empty = (Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
        $malformed | Should -BeExactly $empty
        $empty | Should -Be 'allow'
    }

    It 'resolves duplicate worktree_path records on the first match' -ForEach $script:DuplicateCases {
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Clock))
        $payload = @{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($NonAuthorizing))
        (Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith ([scriptblock]::Create($Body))
        (Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }
}
