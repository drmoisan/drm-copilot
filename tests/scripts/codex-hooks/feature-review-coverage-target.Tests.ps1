#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for .codex/hooks/feature-review-coverage-target.ps1 (issue #1114).

.DESCRIPTION
    Covers policy-audit path extraction from the reviewer message, audit selection, item-root
    resolution through the dot-sourced resolver twin .codex/hooks/hook-target-worktree.ps1, and the
    git and worktree-list wrappers. git runs only through Invoke-CodexReviewCoverageGitExe, which every
    wrapper row mocks with param([string[]]$GitArgs); the worktree list is in-memory porcelain text and
    file existence comes from a Test-Path mock, so no test runs git, reads a file, or creates a file.
    Fixture roots are /-rooted forward-slash paths in exact case.
#>

BeforeAll {
    $script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
    . (Join-Path $script:RepoRoot '.codex/hooks/hook-target-worktree.ps1')
    . (Join-Path $script:RepoRoot '.codex/hooks/feature-review-coverage-target.ps1')

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/item-a'
    $script:OtherRoot = '/synthetic-worktrees/item-b'
    $script:AuditA = 'docs/features/active/2026-11-07-item-a-1114/policy-audit.2026-11-07T20-00.md'
    $script:AuditANewer = 'docs/features/active/2026-11-07-item-a-1114/policy-audit.2026-11-07T21-30.md'
    $script:AuditB = 'docs/features/active/2026-11-07-item-b-1115/policy-audit.2026-11-07T22-00.md'
    $script:Porcelain = "worktree $script:SessionRoot`nbranch refs/heads/main`n`nworktree $script:ItemRoot`nbranch refs/heads/bug/item-a`n`nworktree $script:OtherRoot`nbranch refs/heads/bug/item-b`n"

    function ConvertTo-ForwardSlashPath {
        # Joins a root and a relative path with Join-Path and returns the forward-slash spelling.
        param([Parameter(Mandatory)] [string] $Root, [Parameter(Mandatory)] [string] $Relative)
        return ((Join-Path $Root $Relative) -replace '\\', '/')
    }
}

Describe 'Get-CodexReviewPolicyAuditPath (issue #1114)' {
    It '1114: extracts the dated policy-audit path shape' {
        $result = Get-CodexReviewPolicyAuditPath -Message "Wrote $script:AuditA and the code review."
        @($result.Paths) | Should -Be @($script:AuditA)
        $result.ReasonCode | Should -BeNullOrEmpty
    }

    It '1114: extracts the versioned dated policy-audit path shape' {
        $versioned = 'docs/features/active/2026-11-07-item-a-1114/v2/policy-audit.2026-11-07T20-00.md'
        @((Get-CodexReviewPolicyAuditPath -Message "audit: $versioned").Paths) | Should -Be @($versioned)
    }

    It '1114: extracts the audit-folder policy-audit path shape' {
        $folderShape = 'docs/features/active/2026-11-07-item-a-1114/audit/2026-11-07T20-00/policy-audit.md'
        @((Get-CodexReviewPolicyAuditPath -Message "- $folderShape").Paths) | Should -Be @($folderShape)
    }

    It '1114: extracts a path written with backslash separators as a forward-slash path' {
        $message = 'policy audit: docs\features\active\2026-11-07-item-a-1114\policy-audit.2026-11-07T20-00.md'
        @((Get-CodexReviewPolicyAuditPath -Message $message).Paths) | Should -Be @($script:AuditA)
    }

    It '1114: extracts a path written with forward-slash separators' {
        @((Get-CodexReviewPolicyAuditPath -Message "./$script:AuditA").Paths) | Should -Be @($script:AuditA)
    }

    It '1114: extracts a labelled path' {
        @((Get-CodexReviewPolicyAuditPath -Message "policy-audit-path: $script:AuditA").Paths) | Should -Be @($script:AuditA)
        @((Get-CodexReviewPolicyAuditPath -Message "policy-audit-path:$script:AuditA").Paths) | Should -Be @($script:AuditA)
    }

    It '1114: extracts an unlabelled backticked path in prose' {
        @((Get-CodexReviewPolicyAuditPath -Message "The audit is ``$script:AuditA``, see it.").Paths) | Should -Be @($script:AuditA)
    }

    It '1114: extracts an absolute path with its root' {
        $absolute = ConvertTo-ForwardSlashPath -Root $script:ItemRoot -Relative $script:AuditA
        @((Get-CodexReviewPolicyAuditPath -Message "policy-audit-path: $absolute").Paths) | Should -Be @($absolute)
    }

    It '1114: returns each distinct path once and ignores other artifacts' {
        $message = "$script:AuditA`n$script:AuditA`ndocs/features/active/2026-11-07-item-a-1114/code-review.2026-11-07T20-00.md`nsub/$script:AuditB"
        @((Get-CodexReviewPolicyAuditPath -Message $message).Paths) | Should -Be @($script:AuditA)
    }

    It '1114: returns AUDIT_PATH_TRAVERSAL for a path with a .. segment' {
        $result = Get-CodexReviewPolicyAuditPath -Message 'policy-audit-path: docs/features/active/../2026-11-07-item-b-1115/policy-audit.2026-11-07T22-00.md'
        $result.ReasonCode | Should -Be 'AUDIT_PATH_TRAVERSAL'
        $result.Reason | Should -BeLike "*'..' segment*"
        @($result.Paths).Count | Should -Be 0
    }

    It '1114: returns no path for a <Case> message' -ForEach @(
        @{ Case = 'null'; Message = $null }
        @{ Case = 'non-string'; Message = 42 }
        @{ Case = 'blank'; Message = '   ' }
    ) {
        $result = Get-CodexReviewPolicyAuditPath -Message $Message
        @($result.Paths).Count | Should -Be 0
        $result.ReasonCode | Should -BeNullOrEmpty
    }
}

Describe 'Select-CodexReviewPolicyAudit (issue #1114)' {
    It '1114: selects the single named audit' {
        (Select-CodexReviewPolicyAudit -RelativePath @($script:AuditA)).RelativePath | Should -Be $script:AuditA
    }

    It '1114: selects the greatest timestamp among audits of one folder' {
        $result = Select-CodexReviewPolicyAudit -RelativePath @($script:AuditANewer, $script:AuditA)
        $result.RelativePath | Should -Be $script:AuditANewer
        (Select-CodexReviewPolicyAudit -RelativePath @($script:AuditA, $script:AuditANewer)).RelativePath | Should -Be $script:AuditANewer
    }

    It '1114: returns AUDIT_AMBIGUOUS naming the folders for audits of two folders' {
        $result = Select-CodexReviewPolicyAudit -RelativePath @($script:AuditA, $script:AuditB)
        $result.ReasonCode | Should -Be 'AUDIT_AMBIGUOUS'
        $result.Reason | Should -BeLike '*2026-11-07-item-a-1114*'
        $result.Reason | Should -BeLike '*2026-11-07-item-b-1115*'
        $result.RelativePath | Should -BeNullOrEmpty
    }

    It '1114: returns AUDIT_NOT_NAMED asking for the policy-audit path when no audit is named' {
        $result = Select-CodexReviewPolicyAudit -RelativePath @()
        $result.ReasonCode | Should -Be 'AUDIT_NOT_NAMED'
        $result.Reason | Should -BeLike '*names no policy audit*policy-audit-path*'
    }
}

Describe 'Resolve-CodexReviewCoverageTarget (issue #1114)' {
    BeforeEach {
        Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) throw "unexpected git call: $($GitArgs -join ' ')" }
        Mock Get-CodexReviewCoverageWorktreeList { $script:Porcelain }
        Mock Test-Path { $true }
    }

    It '1114: resolves a relative path to the session root with Source SessionRoot' {
        # Act
        $result = Resolve-CodexReviewCoverageTarget -Message "policy-audit-path: $script:AuditA" -SessionRoot $script:SessionRoot

        # Assert
        $result.ReasonCode | Should -BeNullOrEmpty
        $result.ItemRoot | Should -Be $script:SessionRoot
        $result.Source | Should -Be 'SessionRoot'
        $result.AuditRelativePath | Should -Be $script:AuditA
        Should -Invoke Get-CodexReviewCoverageWorktreeList -Times 0 -Exactly
    }

    It '1114: resolves an absolute path through Resolve-HookTargetWorktree and makes it relative' {
        # Arrange
        $absolute = ConvertTo-ForwardSlashPath -Root $script:ItemRoot -Relative $script:AuditA

        # Act
        $result = Resolve-CodexReviewCoverageTarget -Message "policy-audit-path: $absolute" -SessionRoot $script:SessionRoot

        # Assert
        $result.ReasonCode | Should -BeNullOrEmpty
        $result.ItemRoot | Should -Be $script:ItemRoot
        $result.Source | Should -Be 'FilePath'
        $result.AuditRelativePath | Should -Be $script:AuditA
        Should -Invoke Get-CodexReviewCoverageWorktreeList -Times 1 -Exactly -ParameterFilter { $SessionRoot -eq $script:SessionRoot }
        Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq "$script:ItemRoot/$script:AuditA" }
    }

    It '1114: falls back to the session root for an absolute path outside every listed worktree' {
        # Arrange: the worktree list is empty, so the resolver places the path at the session root.
        Mock Get-CodexReviewCoverageWorktreeList { '' }
        $absolute = ConvertTo-ForwardSlashPath -Root $script:SessionRoot -Relative $script:AuditA

        # Act
        $result = Resolve-CodexReviewCoverageTarget -Message $absolute -SessionRoot $script:SessionRoot

        # Assert
        $result.ReasonCode | Should -BeNullOrEmpty
        $result.ItemRoot | Should -Be $script:SessionRoot
        $result.Source | Should -Be 'SessionRoot'
        $result.AuditRelativePath | Should -Be $script:AuditA
    }

    It '1114: returns AUDIT_NOT_FOUND for an absolute path beneath neither a worktree nor the session root' {
        # Arrange
        $absolute = ConvertTo-ForwardSlashPath -Root '/synthetic-elsewhere/clone' -Relative $script:AuditA

        # Act
        $result = Resolve-CodexReviewCoverageTarget -Message $absolute -SessionRoot $script:SessionRoot

        # Assert
        $result.ReasonCode | Should -Be 'AUDIT_NOT_FOUND'
        $result.Reason | Should -BeLike "*'$absolute'*'$script:SessionRoot'*"
    }

    It '1114: returns TARGET_WORKTREE_AMBIGUOUS naming the worktrees for absolute paths in two worktrees' {
        # Arrange
        $first = ConvertTo-ForwardSlashPath -Root $script:ItemRoot -Relative $script:AuditA
        $second = ConvertTo-ForwardSlashPath -Root $script:OtherRoot -Relative $script:AuditA

        # Act
        $result = Resolve-CodexReviewCoverageTarget -Message "$first and $second" -SessionRoot $script:SessionRoot

        # Assert
        $result.ReasonCode | Should -Be 'TARGET_WORKTREE_AMBIGUOUS'
        $result.ItemRoot | Should -BeNullOrEmpty
        $result.Reason | Should -BeLike "*$script:ItemRoot*"
        $result.Reason | Should -BeLike "*$script:OtherRoot*"
    }

    It '1114: returns AUDIT_PATH_TRAVERSAL for a path with a .. segment' {
        $result = Resolve-CodexReviewCoverageTarget -Message 'docs/features/active/2026-11-07-item-a-1114/../policy-audit.2026-11-07T20-00.md' -SessionRoot $script:SessionRoot
        $result.ReasonCode | Should -Be 'AUDIT_PATH_TRAVERSAL'
        $result.Reason | Should -BeLike "*'..' segment*"
    }

    It '1114: returns AUDIT_NOT_NAMED for a <Case> message' -ForEach @(
        @{ Case = 'null'; Message = $null }
        @{ Case = 'non-string'; Message = [pscustomobject]@{ text = 'docs/features/active/f/policy-audit.2026-11-07T20-00.md' } }
    ) {
        $result = Resolve-CodexReviewCoverageTarget -Message $Message -SessionRoot $script:SessionRoot
        $result.ReasonCode | Should -Be 'AUDIT_NOT_NAMED'
        $result.Reason | Should -BeLike '*names no policy audit*'
    }

    It '1114: returns AUDIT_AMBIGUOUS for relative audits of two folders' {
        $result = Resolve-CodexReviewCoverageTarget -Message "$script:AuditA $script:AuditB" -SessionRoot $script:SessionRoot
        $result.ReasonCode | Should -Be 'AUDIT_AMBIGUOUS'
        $result.Reason | Should -BeLike '*2026-11-07-item-b-1115*'
    }

    It '1114: returns AUDIT_NOT_FOUND naming the path and the item root when the audit is absent' {
        # Arrange
        Mock Test-Path { $false }
        $absolute = ConvertTo-ForwardSlashPath -Root $script:ItemRoot -Relative $script:AuditA

        # Act
        $result = Resolve-CodexReviewCoverageTarget -Message $absolute -SessionRoot $script:SessionRoot

        # Assert
        $result.ReasonCode | Should -Be 'AUDIT_NOT_FOUND'
        $result.ItemRoot | Should -Be $script:ItemRoot
        $result.Reason | Should -BeLike "*'$script:AuditA'*'$script:ItemRoot'*"
    }
}

Describe 'git wrappers (issue #1114)' {
    Context 'Invoke-CodexReviewCoverageGitLog' {
        It '1114: passes the log argument list with the root and pathspecs' {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) $calls.Add($GitArgs -join ' '); [pscustomobject]@{ ExitCode = 0; Output = '1762525200' } }.GetNewClosure()

            # Act
            $null = Invoke-CodexReviewCoverageGitLog -Root $script:ItemRoot -Pathspec @('*.ps1', '*.psm1')

            # Assert
            $calls.Count | Should -Be 1
            $calls[0] | Should -BeExactly "-C $script:ItemRoot log -1 --format=%ct HEAD -- *.ps1 *.psm1"
        }

        It '1114: returns the seam ExitCode and Output unchanged for exit <ExitCode>' -ForEach @(
            @{ ExitCode = 0; Output = '1762525200' }
            @{ ExitCode = 128; Output = 'fatal: not a git repository' }
        ) {
            # Arrange
            $exit = $ExitCode
            $text = $Output
            Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) $null = $GitArgs; [pscustomobject]@{ ExitCode = $exit; Output = $text } }.GetNewClosure()

            # Act
            $result = Invoke-CodexReviewCoverageGitLog -Root $script:ItemRoot -Pathspec @('*.py')

            # Assert
            $result.ExitCode | Should -Be $ExitCode
            $result.Output | Should -BeExactly $Output
        }

        It '1114: lets a seam throw propagate' {
            Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) $null = $GitArgs; throw 'git is not installed' }
            { Invoke-CodexReviewCoverageGitLog -Root $script:ItemRoot -Pathspec @('*.py') } | Should -Throw '*git is not installed*'
        }
    }

    Context 'Get-CodexReviewCoverageWorktreeList' {
        It '1114: passes the worktree-list argument list with the session root and returns the output on exit 0' {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            $porcelain = $script:Porcelain
            Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) $calls.Add($GitArgs -join ' '); [pscustomobject]@{ ExitCode = 0; Output = $porcelain } }.GetNewClosure()

            # Act
            $result = Get-CodexReviewCoverageWorktreeList -SessionRoot $script:SessionRoot

            # Assert
            $calls.Count | Should -Be 1
            $calls[0] | Should -BeExactly "-C $script:SessionRoot worktree list --porcelain"
            $result | Should -BeExactly $script:Porcelain
        }

        It '1114: returns an empty string on a non-zero exit' {
            Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) $null = $GitArgs; [pscustomobject]@{ ExitCode = 128; Output = 'fatal: not a git repository' } }
            Get-CodexReviewCoverageWorktreeList -SessionRoot $script:SessionRoot | Should -BeExactly ''
        }

        It '1114: returns an empty string on a seam throw' {
            Mock Invoke-CodexReviewCoverageGitExe { param([string[]] $GitArgs) $null = $GitArgs; throw 'git is not installed' }
            Get-CodexReviewCoverageWorktreeList -SessionRoot $script:SessionRoot | Should -BeExactly ''
        }
    }
}
