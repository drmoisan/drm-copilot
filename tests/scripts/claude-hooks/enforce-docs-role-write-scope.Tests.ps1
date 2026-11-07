#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit tests for the documentation-role write-scope hook (.claude/hooks/enforce-docs-role-write-scope.ps1, issue #1037).

.DESCRIPTION
    Decision rows call Invoke-DocsRoleWriteScopeDecision with in-memory PreToolUse payloads; the
    repository root and the profile text come from the mocked seams Get-DocsWriteScopeRepositoryRoot
    and Get-DocsWriteScopeProfileText. Entry-tail rows run the hook in process through the & route
    with the payload supplied through [Console]::SetIn and CLAUDE_HOOK_INPUT, both restored in
    finally. No row starts a process, waits on a timer, or creates a file. Paths use forward slashes
    and no drive letter.
#>

BeforeDiscovery {
    $script:ArtifactRows = @(
        @{ Key = 'inventory_snapshot'; Path = 'docs/documentation-estate/inventory-snapshot.json' }
        @{ Key = 'coverage_ledger'; Path = 'docs/documentation-estate/coverage-ledger.json' }
        @{ Key = 'parity_matrix'; Path = 'docs/documentation-estate/parity-matrix.json' }
        @{ Key = 'evidence_pins'; Path = 'docs/documentation-estate/evidence-pins.json' }
        @{ Key = 'validation_receipt'; Path = 'docs/documentation-estate/validation-receipt.md' }
    )
    $script:ReadOnlyWriteRows = @(
        foreach ($role in 'docs-architect', 'docs-reconciler', 'docs-coverage-reviewer') {
            foreach ($tool in 'Write', 'Edit', 'MultiEdit', 'NotebookEdit') { @{ Role = $role; Tool = $tool } }
        }
    )
    $script:RoleRows = @(@{ Role = 'docs-architect' }, @{ Role = 'docs-author' }, @{ Role = 'docs-reconciler' }, @{ Role = 'docs-coverage-reviewer' })
    $script:ProtectedRows = @(@{ Target = '.claude/agents/docs-author.md' }, @{ Target = '.github/skills/x/SKILL.md' }, @{ Target = '.codex/agents/notes.md' }, @{ Target = '.agents/skills/x/SKILL.md' })
}

BeforeAll {
    $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-docs-role-write-scope.ps1'))
    . $script:Hook
    $script:AddedFunctions = @(
        'Add-HookDependencyFailure', 'Test-HookDependencyFailure', 'Get-HookDependencyFailureReason', 'Get-HookDependencyFailureDecision',
        'Get-DocsRoleName', 'Get-DocsRoleRequiredToken', 'ConvertFrom-DocsRoleOutput', 'Test-DocsRoleRelativePath',
        'Get-DocsRoleIntegerFinding', 'Get-DocsRolePathFinding', 'Get-DocsRoleSpecificFinding', 'Test-DocsRoleOutput',
        'Get-DocsWriteScopeRepositoryRoot', 'Get-DocsWriteScopeProfileText', 'Get-DocsWriteScopeDenyDecision', 'ConvertTo-DocsWriteScopeRelativePath',
        'Get-DocsWriteScopeProtectedArtifactPath', 'Get-DocsAuthorWriteDecision', 'Invoke-DocsRoleWriteScopeDecision',
        'ConvertTo-WriteScopePayload', 'Invoke-WriteScopeHookTail'
    )
    $script:Root = '/repo/root'
    $script:ProfileJson = '{"id":"sample","artifact_paths":{"inventory_snapshot":"docs/documentation-estate/inventory-snapshot.json","coverage_ledger":"docs/documentation-estate/coverage-ledger.json","parity_matrix":"./docs/documentation-estate/parity-matrix.json","evidence_pins":"docs/documentation-estate/evidence-pins.json","validation_receipt":"docs/documentation-estate/validation-receipt.md"}}'

    function ConvertTo-WriteScopePayload {
        # Builds a compressed PreToolUse payload; -Role '' omits agent_type.
        param([AllowEmptyString()] [string] $Role, [string] $Tool = 'Write', [AllowEmptyString()] [string] $FilePath, [string] $PathKey = 'file_path')
        $payload = [ordered]@{ session_id = 'w-1037'; hook_event_name = 'PreToolUse'; tool_name = $Tool; cwd = $script:Root }
        if ($Role) { $payload['agent_type'] = $Role }
        $payload['tool_input'] = if ($Tool -eq 'Bash') { [ordered]@{ command = 'ls' } } else { [ordered]@{ $PathKey = $FilePath; content = '# Page' } }
        return ($payload | ConvertTo-Json -Compress -Depth 5)
    }

    function Invoke-WriteScopeHookTail {
        # Runs the hook entry tail with stdin, stderr and CLAUDE_HOOK_INPUT replaced for one call; all are restored in finally.
        param([AllowEmptyString()] [string] $Payload)
        $priorIn = [System.Console]::In
        $priorError = [System.Console]::Error
        $priorHookInput = $env:CLAUDE_HOOK_INPUT
        $errorWriter = [System.IO.StringWriter]::new()
        $stdout = @()
        $exitCode = $null
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new($Payload))
            [System.Console]::SetError($errorWriter)
            $env:CLAUDE_HOOK_INPUT = $Payload
            $global:LASTEXITCODE = 0
            $stdout = @(& $script:Hook)
            $exitCode = $LASTEXITCODE
        }
        finally {
            [System.Console]::SetIn($priorIn)
            [System.Console]::SetError($priorError)
            $env:CLAUDE_HOOK_INPUT = $priorHookInput
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
            $global:LASTEXITCODE = 0
        }
        return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
    }
}

AfterAll {
    foreach ($name in $script:AddedFunctions) { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
    foreach ($name in 'HookDependencyFailures', 'HookDependencyGuardLoadFailed', 'DocsWriteScopeWriteTools', 'DocsWriteScopeProtectedPrefixes', 'DocsWriteScopeProfilePath', 'DocsWriteScopeArtifactKeys', 'Hook', 'AddedFunctions', 'Root', 'ProfileJson') { Remove-Variable -Name $name -Scope Script -ErrorAction SilentlyContinue }
}

Describe 'Invoke-DocsRoleWriteScopeDecision' {
    BeforeEach {
        Mock Get-DocsWriteScopeRepositoryRoot { $script:Root }
        Mock Get-DocsWriteScopeProfileText { $script:ProfileJson }
    }

    Context 'docs-author deny rules' {
        It 'denies the profile path under rule 5' {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/documentation-estate/docs-profile.json')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 5 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies the <Key> artifact path under rule 5' -ForEach $script:ArtifactRows {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath $Path)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 5 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies a .json page under rule 4' {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/guide/data.json')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 4 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies <Target> under rule 6' -ForEach $script:ProtectedRows {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath $Target)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 6 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies an absolute path outside the root under rule 3' {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath '/elsewhere/page.md')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 3 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies a relative path that escapes the root with .. under rule 3' -ForEach @(@{ Target = '../outside/page.md' }, @{ Target = 'docs/../../outside/page.md' }) {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath $Target)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 3 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies a write that names no target path under rule 3' {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath '')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 3 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'reads notebook_path for NotebookEdit and denies a notebook under rule 4' {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -Tool 'NotebookEdit' -FilePath 'docs/guide/demo.ipynb' -PathKey 'notebook_path')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 4 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }
    }

    Context 'role and tool rules' {
        It 'denies <Tool> by <Role> under rule 1' -ForEach $script:ReadOnlyWriteRows {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role $Role -Tool $Tool -FilePath 'docs/guide/index.md')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 1 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'denies Bash by <Role> under rule 2' -ForEach $script:RoleRows {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role $Role -Tool 'Bash')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 2 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        }

        It 'allows a docs-author write of <Target> with no output' -ForEach @(@{ Target = 'docs/guide/index.md' }, @{ Target = './README.md' }) {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -Tool 'Edit' -FilePath $Target)

            # Assert
            $decision | Should -BeNullOrEmpty
        }

        It 'allows a docs-author write of an absolute .md path inside the root' {
            # Arrange
            $absolute = [System.IO.Path]::Combine([System.IO.Path]::GetFullPath($script:Root), 'docs', 'guide', 'index.md')

            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath $absolute)

            # Assert
            $decision | Should -BeNullOrEmpty
        }

        It 'allows a docs-author call to a tool outside the Write class' {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -Tool 'Read' -FilePath 'docs/guide/index.md')

            # Assert
            $decision | Should -BeNullOrEmpty
        }

        It 'allows <Case> with no output' -ForEach @(
            @{ Case = 'a payload without agent_type'; Role = '' }
            @{ Case = 'a non-docs agent_type'; Role = 'atomic-executor' }
            @{ Case = 'a case variant of a docs role'; Role = 'Docs-Author' }
        ) {
            # Act
            $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role $Role -Tool 'Bash')

            # Assert
            $decision | Should -BeNullOrEmpty
        }

        It 'allows an unparseable payload, which carries no agent_type' {
            # Act / Assert
            Invoke-DocsRoleWriteScopeDecision -HookInputRaw '{ not json' | Should -BeNullOrEmpty
        }

        It 'denies with the prefix when a dependency failure is recorded' {
            # Arrange
            Add-HookDependencyFailure -Name 'docs-role-contract.ps1'

            # Act
            try { $decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role '' -Tool 'Bash') }
            finally { $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new() }

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: ', [System.StringComparison]::Ordinal) | Should -BeTrue
            $decision.hookSpecificOutput.permissionDecisionReason.Contains('docs-role-contract.ps1') | Should -BeTrue
        }
    }

    Context 'profile availability' {
        It 'still denies a non-.md write under rule 4 and a protected write under rule 6 when the profile is <Case>' -ForEach @(
            @{ Case = 'absent'; ProfileText = $null; Throws = $false }
            @{ Case = 'unparseable'; ProfileText = '{ not json'; Throws = $false }
            @{ Case = 'a JSON array'; ProfileText = '[1, 2]'; Throws = $false }
            @{ Case = 'unreadable'; ProfileText = $null; Throws = $true }
        ) {
            # Arrange
            $text = $ProfileText
            if ($Throws) { Mock Get-DocsWriteScopeProfileText { throw 'simulated read failure' } }
            else { Mock Get-DocsWriteScopeProfileText { $text } }

            # Act
            $profileWrite = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/documentation-estate/docs-profile.json')
            $protectedWrite = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath '.github/agents/docs-author.agent.md')

            # Assert
            $profileWrite.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 4 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $profileWrite.hookSpecificOutput.permissionDecisionReason
            $protectedWrite.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 6 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $protectedWrite.hookSpecificOutput.permissionDecisionReason
        }

        It 'skips a non-string artifact_paths value and keeps the string values' {
            # Arrange
            Mock Get-DocsWriteScopeProfileText { '{"artifact_paths":{"coverage_ledger":42,"validation_receipt":"docs/estate/receipt.md"}}' }

            # Act
            $receipt = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/estate/receipt.md')
            $profileWrite = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/documentation-estate/docs-profile.json')

            # Assert
            $receipt.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 5 - ', [System.StringComparison]::Ordinal) | Should -BeTrue
            $profileWrite.hookSpecificOutput.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 5 - ', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'protects only the profile path when artifact_paths is not an object' {
            # Arrange
            Mock Get-DocsWriteScopeProfileText { '{"artifact_paths":"docs/estate"}' }

            # Act
            $page = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/estate/index.md')

            # Assert
            $page | Should -BeNullOrEmpty
        }
    }
}

Describe 'write-scope seams' {
    It 'returns the payload cwd as the repository root' {
        # Act / Assert
        Get-DocsWriteScopeRepositoryRoot -HookInput ([pscustomobject]@{ cwd = '/repo/root' }) | Should -Be '/repo/root'
    }

    It 'falls back to the current location when the payload carries no cwd' {
        # Act / Assert
        Get-DocsWriteScopeRepositoryRoot -HookInput $null | Should -Be (Get-Location).ProviderPath
    }

    It 'returns null when no profile file exists' {
        # Arrange
        Mock Test-Path { $false }

        # Act / Assert
        Get-DocsWriteScopeProfileText -RepositoryRoot '/repo/root' | Should -BeNullOrEmpty
    }

    It 'returns the profile text when the profile file exists' {
        # Arrange
        Mock Test-Path { $true }
        Mock Get-Content { '{"id":"x"}' }

        # Act
        $text = Get-DocsWriteScopeProfileText -RepositoryRoot '/repo/root'

        # Assert
        $text | Should -Be '{"id":"x"}'
        Should -Invoke Get-Content -Times 1 -Exactly -ParameterFilter { ($LiteralPath -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json') }
    }
}

Describe 'enforce-docs-role-write-scope.ps1 entry tail' {
    It 'writes the deny JSON at exit 0 for a docs-author .json write' {
        # Arrange
        Mock Get-DocsWriteScopeProfileText { $null }

        # Act
        $result = Invoke-WriteScopeHookTail -Payload (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/guide/data.json')

        # Assert
        $result.ExitCode | Should -Be 0
        $reason = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput
        $reason.permissionDecision | Should -Be 'deny'
        $reason.permissionDecisionReason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule 4 - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason.permissionDecisionReason
    }

    It 'writes nothing at exit 0 for a main-thread Bash call' {
        # Act
        $result = Invoke-WriteScopeHookTail -Payload (ConvertTo-WriteScopePayload -Role '' -Tool 'Bash')

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeNullOrEmpty
    }

    It 'writes the deny JSON naming docs-role-contract.ps1 when that dependency fails to load' {
        # Arrange
        Mock Read-ClaudeHookRawPayload { '' }
        $originalJoinPath = Get-Command Join-Path -CommandType Cmdlet
        Mock Join-Path {
            # Only the selected dependency fails; other path joins retain native semantics.
            if ($ChildPath -eq 'docs-role-contract.ps1') { throw 'simulated load failure: docs-role-contract.ps1'; return }
            & $originalJoinPath @PesterBoundParameters
        }

        # Act
        $result = Invoke-WriteScopeHookTail -Payload (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/guide/index.md')

        # Assert
        $result.ExitCode | Should -Be 0
        $reason = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains('docs-role-contract.ps1') | Should -BeTrue -Because $reason
        Should -Invoke Read-ClaudeHookRawPayload -Times 0 -Exactly
    }

    It 'exits 2 when hook-dependency-guard.ps1 fails to load' {
        # Arrange
        $originalJoinPath = Get-Command Join-Path -CommandType Cmdlet
        Mock Join-Path {
            # Only the selected dependency fails; other path joins retain native semantics.
            if ($ChildPath -eq 'hook-dependency-guard.ps1') { throw 'simulated load failure: hook-dependency-guard.ps1'; return }
            & $originalJoinPath @PesterBoundParameters
        }

        # Act
        $result = Invoke-WriteScopeHookTail -Payload (ConvertTo-WriteScopePayload -Role 'docs-author' -FilePath 'docs/guide/index.md')

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('DOCS_ROLE_WRITE_SCOPE_BLOCKED: hook-dependency-guard.ps1 failed to load', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }
}
