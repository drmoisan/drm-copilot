#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for .claude/hooks/validate-bash.ps1 (issue #545).

.DESCRIPTION
    Covers spec Test Strategy rows AT-8, AT-9, and AT-10, plus two scoping pins for the
    cd-chained read-command leg.

    Expected state BEFORE [P10-T3]:
      - AT-8, AT-9, AT-10 and the quoted cd-chain case FAIL. The denylist compares each
        literal with a whole-string Contains, so 'git push --force-with-lease origin HEAD'
        contains 'git push --force' and denies (AT-8); 'git -C ../wt push --force origin
        HEAD' contains no literal and allows (AT-9); a commit message quoting 'rm -rf'
        denies (AT-10); and the cd-chain regex matches a 'cd ... && cat' phrase that exists
        only inside a quoted commit message.
      - The non-adjacent chain case PASSES. It is a preservation pin, not a regression: the
        current regex places a lazy '.*?' between the cd argument and the delimiter, so it
        already reaches a read command that is not adjacent to the cd segment. Requiring
        adjacency after the change would turn an existing denial into an allow, which
        acceptance criterion 9 forbids.

    Determinism: every case calls a pure string function with a literal fixture. No disk
    I/O, no child process, no temporary file, no live executable.
#>

Set-StrictMode -Version Latest

Describe 'validate-bash.ps1 trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-bash.ps1").Path
        . $script:UnderTest
    }

    Context 'AT-8 through AT-10 - the denylist matching primitive' {
        It 'AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force' {
            # The whole-string Contains treats '--force-with-lease' as containing '--force'.
            # Whole-token equality does not.
            Get-BlockedPatternMatch -Command 'git push --force-with-lease origin HEAD' | Should -BeNullOrEmpty
        }

        It 'AT-9 denies a relocating git push --force carrying a directory global option' {
            # 'git -C ../wt push --force' is a real forced push. No denylist literal occurs
            # as a contiguous token run in it, so only the structural git classifier catches it.
            Get-BlockedPatternMatch -Command 'git -C ../wt push --force origin HEAD' | Should -Be 'git push --force'
        }

        It 'AT-10 allows a commit message that quotes a dangerous pattern in prose' {
            # The tokenizer keeps a quoted span as ONE token, so 'rm' and '-rf' never form
            # an adjacent token pair here.
            Get-BlockedPatternMatch -Command 'git commit -m "docs: explain why rm -rf is banned"' | Should -BeNullOrEmpty
        }
    }

    Context 'the structural git classifier does not fire on a bare subcommand' {
        # The flag conjunction in the structural leg is load-bearing. Without it, every
        # 'git push' and every 'git reset' would be denied.
        It 'allows git push origin main because no force flag is present' {
            Get-BlockedPatternMatch -Command 'git push origin main' | Should -BeNullOrEmpty
        }

        It 'allows git reset --soft HEAD~1 because --soft is not --hard' {
            Get-BlockedPatternMatch -Command 'git reset --soft HEAD~1' | Should -BeNullOrEmpty
        }
    }

    Context 'the cd-chained read-command leg' {
        It 'allows a commit message whose quoted text contains a cd-then-read phrase' {
            # The phrase exists only inside a quoted span. The scanner masks that span
            # before the segment list is built, so no real cd segment exists on this line.
            Get-BashBlockReason -Command 'git commit -m "cd docs && cat notes.md"' | Should -BeNullOrEmpty
        }

        It 'still denies a read command that is not adjacent to the cd segment' {
            # Preservation pin. An intervening 'npm test' segment sits between the cd
            # segment and the grep segment. This case passes against the unfixed hook and
            # must keep passing: turning it into an allow would weaken an existing denial.
            Get-CdChainedReadCommandMatch -Command 'cd /tmp/x && npm test && grep -n test file.txt' | Should -Be 'grep'
        }
    }

    Context 'R-1 wrapper carve-out inside the denylist leg' {
        # Determinism: every case in this Context drives the pure string function
        # Get-BlockedPatternMatch with a literal fixture. No disk I/O, no child process,
        # no temporary file, no live executable, no ambient state.
        It 'R1-C1 denies rm -rf carried inside a bash -c quoted argument' {
            # 'bash' is a wrapper name, so the scanner selects RawText as ScanText. The
            # tokenizer collapses the balanced quoted argument into ONE token, so no token
            # run can match; the raw-scan condition is what restores the denial.
            Get-BlockedPatternMatch -Command 'bash -c "rm -rf /tmp/x"' | Should -Be 'rm -rf'
        }

        It 'R1-C2 denies git reset --hard carried inside an sh -c quoted argument' {
            Get-BlockedPatternMatch -Command "sh -c 'git reset --hard'" | Should -Be 'git reset --hard'
        }

        It 'R1-C3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument' {
            Get-BlockedPatternMatch -Command 'pwsh -NoProfile -Command "Remove-Item -Recurse -Force build"' | Should -Be 'Remove-Item -Recurse -Force'
        }

        It 'R1-C4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led' {
            # A new negative, distinct from AT-10: a different literal reaching the same
            # masking path. 'git' is not a wrapper name, the segment carries no live
            # substitution and its quotes close, so ScanText is the masked text and the
            # quoted literal is spaces there.
            Get-BlockedPatternMatch -Command 'git commit -m "chore: note that Remove-Item -Recurse -Force is banned"' | Should -BeNullOrEmpty
        }

        It 'R1-C5 denies rm -rf carried inside an unterminated quoted span' {
            # The unterminated double quote sets Unbalanced, so the scanner selects RawText
            # as ScanText while the tokenizer emits only 'echo' and the trailing span. This
            # case is the pin for the third disjunct: it fails against a two-disjunct fix
            # and passes only against the three-disjunct fix.
            Get-BlockedPatternMatch -Command 'echo "rm -rf /tmp/x' | Should -Be 'rm -rf'
        }
    }

    Context 'R-2.d wrapper-led cd-chain' {
        # Determinism: every case in this Context calls the pure function
        # Get-CdChainedReadCommandMatch with a literal fixture. No disk I/O, no child
        # process, no temporary file, no live executable, no ambient state.
        #
        # A wrapper's quoted argument is a nested command line that the tokenizer collapses
        # into ONE token, so the CommandWord walk sees only the wrapper and never a 'cd'
        # segment. The retained pattern, evaluated per segment against ScanText, is the leg
        # that reads these three.
        It 'R2d-C1 returns head for a cd-chained read inside a bash -c argument' {
            Get-CdChainedReadCommandMatch -Command 'bash -c "cd /x && head f"' | Should -Be 'head'
        }

        It 'R2d-C2 returns grep for a semicolon-chained read inside an sh -c argument' {
            Get-CdChainedReadCommandMatch -Command 'sh -c "cd /x; grep foo bar"' | Should -Be 'grep'
        }

        It 'R2d-C3 returns cat for a cd-chained read inside a pwsh -Command argument' {
            Get-CdChainedReadCommandMatch -Command 'pwsh -NoProfile -Command "cd /x && cat f"' | Should -Be 'cat'
        }

        It 'R2d-N1 still returns null for an echo whose quoted text contains a cd-then-read phrase' {
            # 'echo' is not a wrapper name, the quotes close, and there is no live
            # substitution, so the segment is not one the scanner reads raw. The new leg is
            # skipped and the masked text carries no cd segment. The narrowing holds.
            Get-CdChainedReadCommandMatch -Command 'echo "cd /x && head f"' | Should -BeNullOrEmpty
        }
    }
}
