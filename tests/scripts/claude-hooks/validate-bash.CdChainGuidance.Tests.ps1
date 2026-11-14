#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision regression and deny-reason shape for the cd-chained leg of .claude/hooks/validate-bash.ps1 (issue #1165).

.DESCRIPTION
    The decision-regression Context drives a table-driven corpus made of every command string
    that validate-bash.Tests.ps1, validate-bash.TriggerScoping.Tests.ps1, and
    hook-command-consumers.Issue824.Tests.ps1 pass to the Claude detection functions, plus the
    intent commands of issue #1165. Each row records the values the unedited hook produced:
    whether Get-BashBlockReason returns a reason, the Get-CdChainedReadCommandMatch value, and,
    for a destructive row, the exact reason string. The guidance change of issue #1165 may change
    only the text of a cd-chained reason, so every row must keep these values.

    Determinism: pure string functions over literal fixtures. No disk write, no temporary file,
    no child process, and no live executable.
#>

Set-StrictMode -Version Latest

Describe 'validate-bash.ps1 cd-chained guidance (issue #1165)' {
    BeforeAll {
        $hookPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'validate-bash.ps1'
        . (Resolve-Path -LiteralPath $hookPath).Path
    }

    Context 'decision regression corpus' {
        It 'row <Command> keeps its pre-change decision, read match, and destructive reason' -ForEach @(
            @{ Command = 'git push --force'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git push --force''' }
            @{ Command = 'git push origin --force'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git push origin --force''' }
            @{ Command = 'git push -f'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git push -f''' }
            @{ Command = 'git reset --hard'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git reset --hard''' }
            @{ Command = 'rm -rf /some/path'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''rm -rf''' }
            @{ Command = 'Remove-Item -Recurse -Force C:\temp'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''Remove-Item -Recurse -Force''' }
            @{ Command = 'git status'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'ls -la'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'echo hello'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'rm -rf /tmp'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''rm -rf''' }
            @{ Command = 'not-valid-json rm -rf /danger'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''rm -rf''' }
            @{ Command = 'not-json-but-safe'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && grep -n test file.txt'; Blocked = $true; ReadOp = 'grep'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && cat file.txt'; Blocked = $true; ReadOp = 'cat'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x; tail -f log.txt'; Blocked = $true; ReadOp = 'tail'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && head -20 file.txt'; Blocked = $true; ReadOp = 'head'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && less file.txt'; Blocked = $true; ReadOp = 'less'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && more file.txt'; Blocked = $true; ReadOp = 'more'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && awk "{print}" file.txt'; Blocked = $true; ReadOp = 'awk'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && sed -n 1,5p file.txt'; Blocked = $true; ReadOp = 'sed -n'; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && grep -n test /tmp/x/file.txt'; Blocked = $true; ReadOp = 'grep'; DestructiveReason = $null }
            @{ Command = 'grep -n pattern /abs/path/file'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd extensions/drm-copilot && npm test'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd extensions/drm-copilot && npm ci'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd extensions/drm-copilot && npx jest'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && rm -rf /tmp/x/file.txt'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''rm -rf''' }
            @{ Command = 'git push --force-with-lease origin HEAD'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'git -C ../wt push --force origin HEAD'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git push --force''' }
            @{ Command = 'git commit -m "docs: explain why rm -rf is banned"'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'git push origin main'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'git reset --soft HEAD~1'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'git commit -m "cd docs && cat notes.md"'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd /tmp/x && npm test && grep -n test file.txt'; Blocked = $true; ReadOp = 'grep'; DestructiveReason = $null }
            @{ Command = 'bash -c "rm -rf /tmp/x"'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''rm -rf''' }
            @{ Command = 'sh -c ''git reset --hard'''; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git reset --hard''' }
            @{ Command = 'pwsh -NoProfile -Command "Remove-Item -Recurse -Force build"'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''Remove-Item -Recurse -Force''' }
            @{ Command = 'git commit -m "chore: note that Remove-Item -Recurse -Force is banned"'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'echo "rm -rf /tmp/x'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''rm -rf''' }
            @{ Command = 'bash -c "cd /x && head f"'; Blocked = $true; ReadOp = 'head'; DestructiveReason = $null }
            @{ Command = 'sh -c "cd /x; grep foo bar"'; Blocked = $true; ReadOp = 'grep'; DestructiveReason = $null }
            @{ Command = 'pwsh -NoProfile -Command "cd /x && cat f"'; Blocked = $true; ReadOp = 'cat'; DestructiveReason = $null }
            @{ Command = 'echo "cd /x && head f"'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'git push --force origin main'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git push --force''' }
            @{ Command = 'bash -c "git push --force origin main"'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git push --force''' }
            @{ Command = 'git reset --hard HEAD'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git reset --hard''' }
            @{ Command = 'pwsh -Command ''git reset --hard HEAD'''; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git reset --hard''' }
            @{ Command = 'pwsh -NoProfile -f ./scripts/legit-push.ps1'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd /repo/wt && git status --short && git log --oneline -3 && cat f'; Blocked = $true; ReadOp = 'cat'; DestructiveReason = $null }
            @{ Command = 'cd /repo/wt && env -u VIRTUAL_ENV poetry install --no-interaction 2>&1 | tail -n 20'; Blocked = $true; ReadOp = 'tail'; DestructiveReason = $null }
            @{ Command = 'cd /x && cat f'; Blocked = $true; ReadOp = 'cat'; DestructiveReason = $null }
            @{ Command = 'bash -c "cd /x && git log | head"'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'cd /repo/wt && npm test | tail -n 5'; Blocked = $true; ReadOp = 'tail'; DestructiveReason = $null }
            @{ Command = 'cd /repo/wt && npx jest | tail -n 5'; Blocked = $true; ReadOp = 'tail'; DestructiveReason = $null }
            @{ Command = 'cd /repo/wt && git status && poetry install | tail -n 5'; Blocked = $true; ReadOp = 'tail'; DestructiveReason = $null }
            @{ Command = 'git -C /repo/wt reset --keep HEAD~1'; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = 'git -C /repo/wt reset --hard HEAD~1'; Blocked = $true; ReadOp = $null; DestructiveReason = 'Blocked dangerous command pattern detected: ''git reset --hard''' }
            @{ Command = ''; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
            @{ Command = $null; Blocked = $false; ReadOp = $null; DestructiveReason = $null }
        ) {
            $reason = Get-BashBlockReason -Command $Command
            $match = Get-CdChainedReadCommandMatch -Command $Command
            $destructive = $null
            if ($reason -is [string] -and $reason.StartsWith('Blocked dangerous command pattern detected:', [System.StringComparison]::Ordinal)) {
                $destructive = $reason
            }

            Should -ActualValue ([bool]$reason) -Be $Blocked -Because 'the allow/deny decision must not change'
            Should -ActualValue $match -BeExactly $ReadOp -Because 'Get-CdChainedReadCommandMatch must not change'
            Should -ActualValue $destructive -BeExactly $DestructiveReason -Because 'destructive reasons stay byte-unchanged'
        }

        It 'pins the retained cd-chained pattern constant' {
            Should -ActualValue $script:CdChainedReadCommandPattern -BeExactly 'cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b'
        }

        It 'pins the retained read-command word family' {
            Should -ActualValue ($script:CdChainedReadCommandWords -join ',') -BeExactly 'grep,cat,head,tail,less,more,awk,sed'
        }
    }

    Context 'cd-chained reason shape by intent' {
        It '<Intent> reason keeps the first two sentences and names the intent form' -ForEach @(
            @{ Intent = 'plain read'; Command = 'cd /x && cat f'; Op = 'cat'; Present = @('Read or Grep tool', 'against the absolute path'); Absent = @('git -C', 'poetry -C', 'npm --prefix', 'sh <SCRATCH>/') }
            @{ Intent = 'git'; Command = 'cd /repo/wt && git status --short && git log --oneline -3 && cat f'; Op = 'cat'; Present = @('git -C <abs>', '/repo/wt'); Absent = @('sh <SCRATCH>/') }
            @{ Intent = 'poetry'; Command = 'cd /repo/wt && env -u VIRTUAL_ENV poetry install --no-interaction 2>&1 | tail -n 20'; Op = 'tail'; Present = @('poetry -C <abs>', '--directory', 'env -u VIRTUAL_ENV'); Absent = @() }
            @{ Intent = 'npm'; Command = 'cd /repo/wt && npm test | tail -n 5'; Op = 'tail'; Present = @('npm --prefix <abs>'); Absent = @() }
            @{ Intent = 'npx'; Command = 'cd /repo/wt && npx jest | tail -n 5'; Op = 'tail'; Present = @('npm --prefix <abs> run <script>', 'sh <SCRATCH>/<file>.sh'); Absent = @() }
            @{ Intent = 'multi-step'; Command = 'cd /repo/wt && git status && poetry install | tail -n 5'; Op = 'tail'; Present = @('sh <SCRATCH>/<file>.sh', 'git -C <abs>', 'poetry -C <abs>'); Absent = @() }
        ) {
            $reason = Get-BashBlockReason -Command $Command
            $prefix = "Forbidden Bash pattern: 'cd ... && $Op' (or ';'-chained). Claude Code's Bash permission engine cannot resolve a file-reading command ($Op) against Read() rules once a preceding 'cd' has changed the working directory in the same command line - it always requires manual approval, regardless of any Read() or Bash() allow rule, and regardless of whether the path argument is relative or absolute. "

            $reason.StartsWith($prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the first two sentences stay byte-unchanged'
            $reason.Contains('Read()', [System.StringComparison]::Ordinal) | Should -BeTrue
            foreach ($token in @('.claude/rules/bash-command-shape.md', 'Command-Text Restrictions', 'agent-isolated worktree', 'sibling worktree') + $Present) {
                $reason.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the $Intent reason names $token"
            }
            foreach ($token in @("Rewrite as a single command using an absolute path instead of 'cd'-ing first") + $Absent) {
                $reason.Contains($token, [System.StringComparison]::Ordinal) | Should -BeFalse -Because "the $Intent reason does not carry $token"
            }
        }

        It 'allows git reset --keep with a directory option' {
            Get-BashBlockReason -Command 'git -C /repo/wt reset --keep HEAD~1' | Should -BeNullOrEmpty
        }

        It 'still denies git reset --hard with a directory option' {
            Get-BashBlockReason -Command 'git -C /repo/wt reset --hard HEAD~1' | Should -BeExactly "Blocked dangerous command pattern detected: 'git reset --hard'"
        }
    }
}
