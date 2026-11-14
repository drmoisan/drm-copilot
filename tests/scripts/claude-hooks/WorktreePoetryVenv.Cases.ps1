<#
.SYNOPSIS
    Shared decision cases for the worktree Poetry virtual-environment guard (issue #1127).

.DESCRIPTION
    Dot-sourced by the Claude and Codex suites of enforce-worktree-poetry-venv.ps1, so both
    hooks are held to one table. Each case names the Bash command, the payload cwd, the
    injected VIRTUAL_ENV value, and the expected decision ('deny' or 'allow'). A case that
    carries Payload supplies the raw PreToolUse text instead of a built envelope. Paths are
    plain strings in Windows, forward-slash, and Git Bash forms; no case reads the host.
#>

function Get-WorktreePoetryVenvCase {
    <#
    .SYNOPSIS
        Return the shared decision cases as hashtables.
    .OUTPUTS
        System.Collections.Hashtable[]
    #>
    [CmdletBinding()]
    [OutputType([hashtable[]])]
    param()

    $worktree = 'C:\repo\.claude\worktrees\wf-1'
    $main = 'C:\repo'
    $mainVenv = 'C:\repo\.venv'
    $rows = @(
        # The reproduction: a worktree cwd with VIRTUAL_ENV naming the main checkout's .venv.
        @{ Name = 'reproduction poetry install'; Command = 'poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'reproduction poetry sync'; Command = 'poetry sync'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'reproduction poetry add'; Command = 'poetry add requests'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'reproduction poetry remove'; Command = 'poetry remove requests'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'reproduction poetry update'; Command = 'poetry update'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        # Neutralization of VIRTUAL_ENV.
        @{ Name = 'env -u VIRTUAL_ENV prefix'; Command = 'env -u VIRTUAL_ENV poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'env --unset=VIRTUAL_ENV prefix'; Command = 'env --unset=VIRTUAL_ENV poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'env -uVIRTUAL_ENV prefix'; Command = 'env -uVIRTUAL_ENV poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'env -u of another variable'; Command = 'env -u OTHER poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'env with an assignment'; Command = 'env FOO=1 poetry add requests'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'unset VIRTUAL_ENV before the Poetry word'; Command = 'unset VIRTUAL_ENV; poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'neutralized wrapper payload'; Command = 'env -u VIRTUAL_ENV bash -c "poetry install"'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'wrapper payload'; Command = 'bash -c "poetry install"'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        # VIRTUAL_ENV unset, empty, or inside the target.
        @{ Name = 'main checkout own .venv'; Command = 'poetry install'; Cwd = $main; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'VIRTUAL_ENV unset'; Command = 'poetry install'; Cwd = $worktree; VirtualEnv = $null; Expected = 'allow' }
        @{ Name = 'VIRTUAL_ENV empty'; Command = 'poetry install'; Cwd = $worktree; VirtualEnv = ''; Expected = 'allow' }
        # Prose and non-mutating commands.
        @{ Name = 'commit message naming poetry install'; Command = 'git commit -m "poetry install"'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'echo argument naming poetry install'; Command = "echo 'poetry install'"; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'poetry run'; Command = 'poetry run pytest -n auto'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'poetry env info'; Command = 'poetry env info -p'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'poetry show'; Command = 'poetry show'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'poetry check'; Command = 'poetry check'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'non-Poetry command'; Command = 'git status'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'Poetry option without a subcommand'; Command = 'poetry -C'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        # Wrappers and prefixes before the Poetry word.
        @{ Name = 'assignment prefix'; Command = 'FOO=1 poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'timeout wrapper'; Command = 'timeout 60 poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'time -p wrapper'; Command = 'time -p poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'command -p wrapper'; Command = 'command -p poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'nohup wrapper'; Command = 'nohup poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'Poetry executable path'; Command = 'C:/tools/poetry.exe install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'standalone Poetry option'; Command = 'poetry --no-interaction install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'deny' }
        # Target overrides: each flips the decision of the plain command from the same cwd.
        @{ Name = '-C names the main checkout'; Command = 'poetry -C C:/repo install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = '--directory names the main checkout'; Command = 'poetry --directory C:/repo install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = '-P names the main checkout'; Command = 'poetry -P /c/repo install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = '--project names the main checkout'; Command = "poetry --project 'C:\repo' install"; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = '--directory= inline names the main checkout'; Command = 'poetry --directory=C:/repo install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'relative -C resolves to the main checkout'; Command = 'poetry -C ../../.. install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'relative -C names the worktree from main'; Command = 'poetry -C .claude/worktrees/wf-1 install'; Cwd = $main; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'cd to the main checkout'; Command = 'cd C:/repo && poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'cd -P to the main checkout'; Command = 'cd -P /c/repo && poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'cd to the worktree from main'; Command = 'cd .claude/worktrees/wf-1 && poetry install'; Cwd = $main; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'cd to home cannot be derived'; Command = 'cd ~ && poetry install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'relative -C with a shell expansion cannot be derived'; Command = 'poetry -C $HOME/x install'; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        # Path forms compared as strings.
        @{ Name = 'backslash and forward-slash forms'; Command = 'poetry install'; Cwd = 'C:/repo'; VirtualEnv = 'C:\repo\.venv'; Expected = 'allow' }
        @{ Name = 'Git Bash drive form'; Command = 'poetry install'; Cwd = 'C:\repo'; VirtualEnv = '/c/repo/.venv'; Expected = 'allow' }
        @{ Name = 'trailing separators'; Command = 'poetry install'; Cwd = 'C:\repo\'; VirtualEnv = 'C:/repo/.venv/'; Expected = 'allow' }
        @{ Name = 'case variants'; Command = 'poetry install'; Cwd = 'c:\REPO'; VirtualEnv = 'C:\Repo\.VENV'; Expected = 'allow' }
        @{ Name = 'Git Bash worktree form'; Command = 'poetry install'; Cwd = '/c/repo/.claude/worktrees/wf-1'; VirtualEnv = $mainVenv; Expected = 'deny' }
        @{ Name = 'POSIX worktree path'; Command = 'poetry install'; Cwd = '/home/u/repo/.claude/worktrees/wf-1'; VirtualEnv = '/home/u/repo/.venv'; Expected = 'deny' }
        @{ Name = 'sibling .venv-old prefix'; Command = 'poetry install'; Cwd = 'C:\repo\.venv'; VirtualEnv = 'C:\repo\.venv-old'; Expected = 'deny' }
        # Payload edge cases.
        @{ Name = 'empty command'; Command = ''; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'missing cwd'; Command = 'poetry install'; Cwd = $null; VirtualEnv = $mainVenv; Expected = 'allow' }
        @{ Name = 'missing tool_input'; Command = ''; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow'; Payload = '{"hook_event_name":"PreToolUse","tool_name":"Bash"}' }
        @{ Name = 'unparseable JSON'; Command = ''; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow'; Payload = '{not-json' }
        @{ Name = 'empty payload'; Command = ''; Cwd = $worktree; VirtualEnv = $mainVenv; Expected = 'allow'; Payload = '' }
    )
    return [hashtable[]]$rows
}

function ConvertTo-WorktreePoetryVenvCasePayload {
    <#
    .SYNOPSIS
        Build the raw PreToolUse JSON text for one case.
    .PARAMETER Case
        One hashtable from Get-WorktreePoetryVenvCase.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][hashtable] $Case)

    if ($Case.ContainsKey('Payload')) { return [string]$Case['Payload'] }
    $envelope = [ordered]@{ hook_event_name = 'PreToolUse'; tool_name = 'Bash'; tool_input = [ordered]@{ command = $Case['Command'] } }
    if ($null -ne $Case['Cwd']) { $envelope['cwd'] = $Case['Cwd'] }
    return ($envelope | ConvertTo-Json -Compress -Depth 5)
}
