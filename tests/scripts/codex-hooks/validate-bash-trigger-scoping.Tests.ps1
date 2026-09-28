#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Codex validate-bash hook (issue #545).

.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1, carrying spec Test
    Strategy rows AT-8, AT-9, and AT-10 in the Codex idiom.

    Codex idiom note: this copy carries no cd-chained read-command leg, so the two
    cd-chain cases in the Claude suite have no Codex counterpart and none is added. The
    detector under test, Get-BlockedPatternMatch, has the same name and the same pure
    string signature on both sides, so the three denylist cases read identically.

    This file is NEW rather than an extension of
    tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, which is at 494 of its
    500 permitted lines.

    Determinism: every case calls a pure string function with a literal fixture. No disk
    I/O, no child process, no temporary file, no live executable.
#>

Set-StrictMode -Version Latest

Describe 'Codex validate-bash trigger scoping (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/validate-bash.ps1'
        . $script:UnderTest
    }

    It 'AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force' {
        Get-BlockedPatternMatch -Command 'git push --force-with-lease origin HEAD' | Should -BeNullOrEmpty
    }

    It 'AT-9 denies a relocating git push --force carrying a directory global option' {
        Get-BlockedPatternMatch -Command 'git -C ../wt push --force origin HEAD' | Should -Be 'git push --force'
    }

    It 'AT-10 allows a commit message that quotes a dangerous pattern in prose' {
        Get-BlockedPatternMatch -Command 'git commit -m "docs: explain why rm -rf is banned"' | Should -BeNullOrEmpty
    }

    # R-1 wrapper carve-out inside the denylist leg.
    # Determinism: every case below drives the pure string function Get-BlockedPatternMatch
    # with a literal fixture. No disk I/O, no child process, no temporary file, no live
    # executable, no ambient state.
    It 'R1-X1 denies rm -rf carried inside a bash -c quoted argument' {
        # 'bash' is a wrapper name, so the scanner selects RawText as ScanText. The
        # tokenizer collapses the balanced quoted argument into ONE token, so no token run
        # can match; the raw-scan condition is what restores the denial.
        Get-BlockedPatternMatch -Command 'bash -c "rm -rf /tmp/x"' | Should -Be 'rm -rf'
    }

    It 'R1-X2 denies git reset --hard carried inside an sh -c quoted argument' {
        Get-BlockedPatternMatch -Command "sh -c 'git reset --hard'" | Should -Be 'git reset --hard'
    }

    It 'R1-X3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument' {
        Get-BlockedPatternMatch -Command 'pwsh -NoProfile -Command "Remove-Item -Recurse -Force build"' | Should -Be 'Remove-Item -Recurse -Force'
    }

    It 'R1-X4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led' {
        # A new negative, distinct from AT-10: a different literal reaching the same masking
        # path. 'git' is not a wrapper name, the segment carries no live substitution and its
        # quotes close, so ScanText is the masked text and the quoted literal is spaces there.
        Get-BlockedPatternMatch -Command 'git commit -m "chore: note that Remove-Item -Recurse -Force is banned"' | Should -BeNullOrEmpty
    }

    It 'R1-X5 denies rm -rf carried inside an unterminated quoted span' {
        # The unterminated double quote sets Unbalanced, so the scanner selects RawText as
        # ScanText while the tokenizer emits only 'echo' and the trailing span. This case is
        # the pin for the third disjunct: it fails against a two-disjunct fix and passes only
        # against the three-disjunct fix.
        Get-BlockedPatternMatch -Command 'echo "rm -rf /tmp/x' | Should -Be 'rm -rf'
    }
}
