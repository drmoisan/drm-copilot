#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the sanctioned-removal manifest reader (issue #635).

.DESCRIPTION
    Covers the vocabulary constants the allow predicate is written against, path
    normalization, removal-record lookup, the allow predicate itself, and the
    checkpoint-exclusion helper.

    Every manifest fixture is a literal JSON string returned by a mock of the
    module's read seam, and every clock value is a constructed UTC DateTime
    returned by a mock of the module's clock seam. Both mocks are registered with
    -ModuleName so they intercept the call the module makes to itself. No test
    creates, writes, or reads a temporary file, reads a wall clock, spawns a
    process, or touches the network.
#>

BeforeAll {
    # Resolve the module four levels up (cleanup-manifest -> claude-lib -> scripts
    # -> tests -> repo root). Resolve-Path normalizes separators so Pester coverage
    # breakpoints bind to the path the run settings name.
    $script:CleanupManifestModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1").Path
    Import-Module $script:CleanupManifestModulePath -Force
}

Describe 'CleanupWorktreeManifest' {
    BeforeAll {
        # Default seam behavior for the whole Describe. Individual tests re-register
        # either seam with their own literal fixture; the innermost registration
        # wins for that test only. The literals are inline rather than read from a
        # shared variable because a -ModuleName mock body executes in the module's
        # session state, where a test-scope variable does not resolve.
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith { $null }
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith {
            [datetime]::new(2026, 9, 7, 4, 0, 0, [System.DateTimeKind]::Utc)
        }
    }

    Context 'vocabulary constants' {
        It 'exposes exactly SAFE_TO_DELETE as the allowed removal disposition' {
            # Arrange / Act: read the script-scope constant from inside the module.
            $actual = @(InModuleScope 'CleanupWorktreeManifest' { $script:AllowedRemovalDispositions })

            # Assert: a single-member set. A widened set would authorize a
            # disposition the specification never sanctions.
            $actual | Should -HaveCount 1
            $actual[0] | Should -BeExactly 'SAFE_TO_DELETE'
        }

        It 'exposes exactly NOT_MERGED and HAS_UNIQUE_RESIDUALS as the authorized branch states' {
            # Arrange / Act: read the script-scope constant from inside the module.
            $actual = @(InModuleScope 'CleanupWorktreeManifest' { $script:AuthorizedBranchStates })

            # Assert: exactly the two durable-residual states, and nothing else.
            # PROTECTED_CURRENT and the three merged states must stay outside it.
            $actual | Should -HaveCount 2
            $actual | Should -Contain 'NOT_MERGED'
            $actual | Should -Contain 'HAS_UNIQUE_RESIDUALS'
        }
    }

    Context 'path normalization' {
        It 'normalizes trailing-slash, Windows-separator, and POSIX paths to one value' {
            # Arrange: three spellings of one worktree location.
            $posix = 'C:/repos/drm-copilot/.claude/worktrees/agent-0f1c2d'
            $trailingSlash = 'C:/repos/drm-copilot/.claude/worktrees/agent-0f1c2d/'
            $windows = 'C:\repos\drm-copilot\.claude\worktrees\agent-0f1c2d'

            # Act: normalize each spelling.
            $normalizedPosix = ConvertTo-CleanupWorktreeManifestNormalizedPath -Path $posix
            $normalizedTrailingSlash = ConvertTo-CleanupWorktreeManifestNormalizedPath -Path $trailingSlash
            $normalizedWindows = ConvertTo-CleanupWorktreeManifestNormalizedPath -Path $windows

            # Assert: all three collapse to the recorded POSIX spelling, so a
            # manifest record written one way still matches a command written
            # another way.
            $normalizedPosix | Should -BeExactly $posix
            $normalizedTrailingSlash | Should -BeExactly $posix
            $normalizedWindows | Should -BeExactly $posix
        }
    }

    Context 'removal record lookup' {
        It 'returns the first matching removals record' {
            # Arrange: two records sharing one normalized worktree_path, told apart
            # by their run-scoped evidence text.
            $raw = '{"tool":"cleanup-merged-worktrees","schema_version":1,"removals":[{"worktree_path":"C:/repos/wt/agent-0f1c2d","evidence":"first"},{"worktree_path":"C:/repos/wt/agent-0f1c2d","evidence":"second"}]}'

            # Act: look the target up.
            $record = Find-CleanupWorktreeManifestRemovalRecord -Raw $raw -WorktreePath 'C:/repos/wt/agent-0f1c2d'

            # Assert: the scan stops at the first match. Continuing past it would
            # let a permissive later duplicate override a restrictive earlier one.
            $record | Should -Not -BeNullOrEmpty
            $record.evidence | Should -BeExactly 'first'
        }

        It 'skips a record whose worktree_path key is absent and continues the scan' {
            # Arrange: a keyless record ahead of the matching record.
            $raw = '{"tool":"cleanup-merged-worktrees","schema_version":1,"removals":[{"evidence":"keyless"},{"worktree_path":"C:/repos/wt/agent-77bb10","evidence":"matched"}]}'

            # Act: look the target up.
            $record = Find-CleanupWorktreeManifestRemovalRecord -Raw $raw -WorktreePath 'C:/repos/wt/agent-77bb10'

            # Assert: the keyless record is skipped rather than aborting the scan,
            # so a malformed neighbour cannot hide a well-formed record.
            $record | Should -Not -BeNullOrEmpty
            $record.evidence | Should -BeExactly 'matched'
        }
    }

    Context 'allow predicate' {
        It 'authorizes a fully conforming manifest record' {
            # Arrange: a manifest satisfying conditions 1 through 9, supplied
            # through the read seam, and a clock 20 minutes after generated_at so
            # the freshness bound is met without reading a wall clock.
            Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith {
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-09-07T03:40:00Z","run_id":"cleanup-2026-09-07T03-40-00Z-a47a5e33","removals":[{"worktree_path":"C:/repos/wt/agent-0f1c2d","branch":"drm-copilot-wt-2026-08-14T09-02","branch_state":"HAS_UNIQUE_RESIDUALS","removal_disposition":"SAFE_TO_DELETE","verdict":"ALREADY_SOLVED_ELSEWHERE","evidence":"Unique residual commit 3f9a1c2 is already fixed on main under issue #612."}],"preserved_files":[]}'
            }
            Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith {
                [datetime]::new(2026, 9, 7, 4, 0, 0, [System.DateTimeKind]::Utc)
            }

            # Act: evaluate the predicate for the recorded target.
            $isAuthorized = Test-CleanupWorktreeManifestAuthorizesRemoval -WorktreePath 'C:/repos/wt/agent-0f1c2d'

            # Assert: every condition holds, so the record authorizes the removal.
            $isAuthorized | Should -BeTrue
        }
    }

    Context 'checkpoint exclusion' {
        It 'reports coverage for a checkpoint record whose merge_status is outside the allow-set' {
            # Arrange: an epic checkpoint recording the target with a merge_status
            # neither gate treats as authorizing.
            $checkpoint = '{"features":[{"worktree_path":"C:\\repos\\wt\\agent-0f1c2d","merge_status":"in_progress"}]}' | ConvertFrom-Json

            # Act: ask whether the checkpoint records the target at all, supplying
            # the target in the other separator spelling.
            $isCovered = Test-CleanupManifestCheckpointCoversPath -Checkpoint $checkpoint -RecordArrayName 'features' -WorktreePath 'C:/repos/wt/agent-0f1c2d/'

            # Assert: coverage is reported on presence alone. A merge_status-aware
            # answer here would let the manifest branch authorize a removal the
            # checkpoint protects, which is the one widening path condition 10
            # exists to close.
            $isCovered | Should -BeTrue
        }
    }
}
