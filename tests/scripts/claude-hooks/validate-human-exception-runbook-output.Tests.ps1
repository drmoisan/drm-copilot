#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-human-exception-runbook-output.ps1 SubagentStop hook (issue #1128).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam, the registered worktrees
    from an in-memory WorktreeListInvoker seam, and the runbook and lockfile text from in-memory
    ReadFile, TestFile, and ListRootFile seams, so no test reads or creates a file. Fixture roots are
    /-rooted forward-slash paths. One E3-Entry case spawns the hook with a malformed envelope on stdin.
#>

BeforeAll {
    $script:HookPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-human-exception-runbook-output.ps1'))
    . $script:HookPath
    . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1128'
    $script:Relative = 'docs/features/active/sample/runbooks/package.runbook.md'
    $script:ItemRunbook = "$script:ItemRoot/$script:Relative"
    $script:ItemLock = "$script:ItemRoot/poetry.lock"
    $script:Prompt = "Canonical issue number for this feature is 1128.`nbranch: bug/sample-1128"
    $script:LockText = "[[package]]`nname = `"nuitka`"`nversion = `"4.3.4`"`n"
    $porcelainText = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1128', 'branch refs/heads/bug/sample-1128', ''
    ) -join "`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelainText }.GetNewClosure()
    $script:Fence = [string][char]96 * 3

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Get-Seam {
        # Builds the in-memory ReadFile, TestFile, and ListRootFile seams over a path -> text map.
        param([hashtable] $File)
        return @{
            ReadFile     = { param($Path) if ($File.ContainsKey($Path)) { $File[$Path] } else { $null } }.GetNewClosure()
            TestFile     = { param($Path) $File.ContainsKey($Path) }.GetNewClosure()
            ListRootFile = { param($Root) @($File.Keys | Where-Object { $_.StartsWith("$Root/") -and -not $_.Substring($Root.Length + 1).Contains('/') } | ForEach-Object { $_.Substring($Root.Length + 1) }) }.GetNewClosure()
        }
    }

    function Get-EnvelopeText {
        # Builds a SubagentStop envelope whose assistant text is the given message and whose transcript path lets the seam serve the prompt.
        param([string] $Message)
        return ([ordered]@{
                session_id             = 'hx-1128'
                hook_event_name        = 'SubagentStop'
                agent_type             = 'human-exception-runbook'
                stop_hook_active       = $false
                agent_transcript_path  = 'transcripts/subagents/agent-1128.jsonl'
                last_assistant_message = $Message
            } | ConvertTo-Json -Compress)
    }

    function Invoke-Case {
        # Runs the decision function with the synthetic session root and seams.
        param([string] $Message, [hashtable] $File, [string] $Prompt = $script:Prompt)
        $seam = Get-Seam -File $File
        return Get-HumanExceptionRunbookDecision -InputText (Get-EnvelopeText -Message $Message) -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker -ReadFile $seam.ReadFile -TestFile $seam.TestFile -ListRootFile $seam.ListRootFile
    }

    function Get-RunbookText {
        param([string[]] $Command, [string[]] $AfterFence = @())
        return (@('# Runbook', '', "$($script:Fence)sh") + $Command + @($script:Fence) + $AfterFence + @('', '## Verification')) -join "`n"
    }
}

Describe 'epic-state baseline isolation (issue #1128)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'Get-HumanExceptionRunbookDecision (AC 4)' {
    It 'blocks and lists every finding for an unmarked pinned tool and an unmarked unpinned tool' {
        # Arrange
        $runbook = Get-RunbookText -Command @('python -m nuitka --clean-cache=clcache', 'az login')
        $file = @{ $script:ItemRunbook = $runbook; $script:ItemLock = $script:LockText }

        # Act
        $result = Invoke-Case -Message "Done.`nrunbook_path: $script:Relative" -File $file

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:*2 tool command version finding(s)*'
        $result.Message | Should -BeLike '*nuitka*4.3.4*'
        $result.Message | Should -BeLike '*tool az*not pinned in any lockfile*'
        $result.Message | Should -Not -BeLike '*not repairable*'
    }

    It 'allows a runbook whose markers match the pinned version' {
        # Arrange
        $runbook = Get-RunbookText -Command @('python -m nuitka --clean-cache=all') -AfterFence @('Version check: not verified against nuitka 4.3.4')
        $file = @{ $script:ItemRunbook = $runbook; $script:ItemLock = $script:LockText }

        # Act
        $result = Invoke-Case -Message "Done.`nrunbook_path: $script:Relative" -File $file

        # Assert
        $result.Ok | Should -BeTrue
        $result.Message | Should -BeNullOrEmpty
    }

    It 'accepts the hyphenated runbook-path token' {
        # Arrange
        $runbook = Get-RunbookText -Command @('az login') -AfterFence @('Version check: az not pinned in this repository')
        $file = @{ $script:ItemRunbook = $runbook }

        # Act
        $result = Invoke-Case -Message "runbook-path: $script:Relative" -File $file

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'merges pinned versions from several lockfile formats at the item root' {
        # Arrange
        $runbook = Get-RunbookText -Command @('npx prettier --check .', 'ruff check .') -AfterFence @('Version check: verified against prettier 3.3.2', 'Version check: not verified against ruff 0.5.1')
        $file = @{
            $script:ItemRunbook                      = $runbook
            "$script:ItemRoot/package-lock.json"     = '{"packages":{"":{},"node_modules/prettier":{"version":"3.3.2"}}}'
            "$script:ItemRoot/requirements.txt"      = "ruff==0.5.1`n"
            "$script:ItemRoot/notes.txt"             = 'ignored'
        }

        # Act
        $result = Invoke-Case -Message "runbook_path: $script:Relative" -File $file

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'blocks when the last assistant message advertises no runbook_path' {
        # Arrange / Act
        $result = Invoke-Case -Message 'Runbook written.' -File @{}

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:*does not advertise a runbook path*'
    }

    It 'blocks when the last assistant message is empty' {
        # Arrange / Act
        $result = Invoke-Case -Message '' -File @{}

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*does not advertise a runbook path*'
    }

    It 'blocks when the advertised file does not exist' {
        # Arrange / Act
        $result = Invoke-Case -Message "runbook_path: $script:Relative" -File @{ $script:ItemLock = $script:LockText }

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*was advertised but no file exists at that location.*Probed location: '$script:ItemRunbook'*"
    }

    It 'blocks a path that is not a runbooks .runbook.md file' {
        # Arrange / Act
        $result = Invoke-Case -Message 'runbook_path: docs/features/active/sample/notes.md' -File @{ 'x' = 'y' }

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*must name <FEATURE>/runbooks/<name>.runbook.md*'
    }

    It 'blocks with a read failure message when the runbook cannot be read' {
        # Arrange
        $seam = Get-Seam -File @{ $script:ItemRunbook = 'x' }
        $failingRead = { param($Path) throw "denied $Path" }

        # Act
        $result = Get-HumanExceptionRunbookDecision -InputText (Get-EnvelopeText -Message "runbook_path: $script:Relative") -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $script:Prompt) -WorktreeListInvoker $script:ListInvoker -ReadFile $failingRead -TestFile $seam.TestFile -ListRootFile $seam.ListRootFile

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*failed to read runbook path*denied*'
    }

    It 'blocks with a payload anomaly reason for an empty envelope' {
        # Arrange / Act
        $result = Get-HumanExceptionRunbookDecision -InputText '' -SessionRoot $script:SessionRoot

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING: payload anomaly*'
    }
}

Describe 'validate-human-exception-runbook-output entry point' {
    BeforeAll {
        function Invoke-HookEntry {
            # Drives the hook through the & route with stdin and stderr redirected; both are restored in finally.
            param([AllowEmptyString()] [string] $Stdin)
            $ErrorActionPreference = 'Continue'
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                try { $null = & $script:HookPath 2>&1 } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ ExitCode = $exitCode; Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }
    }

    It 'E3-Entry: exits 2 with the hook prefix on stderr for a malformed envelope' -Tag 'E3-Entry' {
        # Arrange / Act
        $result = Invoke-HookEntry -Stdin 'this is not json'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -BeLike 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:*'
    }

    It 'E3-Entry: exits 2 with the missing-path reason for a well-formed envelope without a runbook_path' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'human-exception-runbook' -AssistantMessage 'Runbook written.'

        # Act
        $result = Invoke-HookEntry -Stdin $stdin

        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -BeLike '*does not advertise a runbook path*'
    }
}
