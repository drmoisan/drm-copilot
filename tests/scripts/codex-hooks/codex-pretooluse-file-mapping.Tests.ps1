#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Unit coverage for the shared Codex PreToolUse transport module
    .codex/hooks/codex-pretooluse-file-mapping.ps1 (issue #415 remediation cycle 1, R1).

    The module is entrypoint-free by design, so every case here dot-sources the ROOT
    copy in-process and calls its functions directly. The existing codex suites drive
    the module only through spawned hook processes, which contributes no in-process
    coverage; these cases target the dot-source-reachable lines itemized at [P1-T3].

    No temporary file is created. The one case that needs a readable on-disk source
    uses the module's own file, which is a tracked repository file, and the one case
    that needs an unreadable source injects the failure through a Get-Content mock.
#>

Describe 'codex-pretooluse-file-mapping shared transport module' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:ModulePath = Join-Path $script:RepoRoot '.codex/hooks/codex-pretooluse-file-mapping.ps1'
        . $script:ModulePath

        function ConvertTo-CodexPayloadObject {
            <#
                Builds a parsed-payload-shaped object without going through JSON, so a
                case can construct shapes ConvertFrom-CodexPreToolUsePayload would have
                rejected and still exercise ConvertTo-CodexFileEditInput directly.
            #>
            param(
                [Parameter()][AllowNull()][string] $ToolName,
                [Parameter()][AllowNull()] $ToolInput
            )

            return [pscustomobject]@{
                tool_name  = $ToolName
                tool_input = $ToolInput
            }
        }
    }

    Context 'ConvertFrom-CodexPreToolUsePayload rejects un-processable input' {
        It 'throws a hook-named error when the payload is an empty string' {
            # Arrange / Act / Assert
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw '' -HookName 'sample-hook' } |
                Should -Throw -ExpectedMessage 'sample-hook hook input is empty.'
        }

        It 'throws a hook-named error when the payload is whitespace only' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw "  `t " -HookName 'other-hook' } |
                Should -Throw -ExpectedMessage 'other-hook hook input is empty.'
        }

        It 'throws a hook-named error when the payload is not valid JSON' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw 'this is not json' -HookName 'sample-hook' } |
                Should -Throw -ExpectedMessage 'sample-hook hook input is malformed JSON: *'
        }

        It 'throws when the payload carries no tool_input property' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw '{"tool_name":"Edit"}' -HookName 'sample-hook' } |
                Should -Throw -ExpectedMessage 'sample-hook hook input is missing tool_input.'
        }

        It 'throws when tool_input is present but null' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw '{"tool_input":null}' -HookName 'sample-hook' } |
                Should -Throw -ExpectedMessage 'sample-hook hook input is missing tool_input.'
        }

        It 'throws when the payload is the JSON null literal' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw 'null' -HookName 'sample-hook' } |
                Should -Throw -ExpectedMessage 'sample-hook hook input is missing tool_input.'
        }

        It 'throws when session_id is absent under -RequireSessionId' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw '{"tool_input":{}}' -HookName 'budget-hook' -RequireSessionId } |
                Should -Throw -ExpectedMessage 'budget-hook hook input is missing session_id.'
        }

        It 'throws when session_id is whitespace only under -RequireSessionId' {
            { ConvertFrom-CodexPreToolUsePayload -PayloadRaw '{"session_id":"  ","tool_input":{}}' -HookName 'budget-hook' -RequireSessionId } |
                Should -Throw -ExpectedMessage 'budget-hook hook input is missing session_id.'
        }
    }

    Context 'ConvertFrom-CodexPreToolUsePayload accepts processable input' {
        It 'returns the parsed payload for a well-formed payload' {
            # Arrange
            $raw = '{"tool_name":"Edit","tool_input":{"file_path":"src/a.ps1"}}'

            # Act
            $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw $raw -HookName 'sample-hook'

            # Assert
            $payload.tool_name | Should -Be 'Edit'
            $payload.tool_input.file_path | Should -Be 'src/a.ps1'
        }

        It 'returns the parsed payload when -RequireSessionId is satisfied' {
            $raw = '{"session_id":"s-1","tool_name":"Write","tool_input":{"file_path":"src/b.ps1"}}'

            $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw $raw -HookName 'budget-hook' -RequireSessionId

            $payload.session_id | Should -Be 's-1'
        }

        It 'does not reject a payload whose hook_event_name is absent' {
            $raw = '{"tool_name":"Edit","tool_input":{"file_path":"src/c.ps1"}}'

            $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw $raw -HookName 'sample-hook'

            $payload.tool_input.file_path | Should -Be 'src/c.ps1'
        }
    }

    Context 'ConvertTo-CodexFileEditInput maps nothing when nothing is governed' {
        It 'returns an empty array for a null payload' {
            $records = ConvertTo-CodexFileEditInput -Payload $null

            @($records).Count | Should -Be 0
        }

        It 'returns an empty array when tool_input is null' {
            $payload = ConvertTo-CodexPayloadObject -ToolName 'Edit' -ToolInput $null

            $records = ConvertTo-CodexFileEditInput -Payload $payload

            @($records).Count | Should -Be 0
        }

        It 'returns an empty array for an unadmitted tool name' {
            $payload = ConvertTo-CodexPayloadObject -ToolName 'Bash' -ToolInput ([pscustomobject]@{ file_path = 'src/a.ps1' })

            $records = ConvertTo-CodexFileEditInput -Payload $payload

            @($records).Count | Should -Be 0
        }

        It 'returns an empty array when file_path is whitespace only' {
            $payload = ConvertTo-CodexPayloadObject -ToolName 'Write' -ToolInput ([pscustomobject]@{ file_path = '   ' })

            $records = ConvertTo-CodexFileEditInput -Payload $payload

            @($records).Count | Should -Be 0
        }

        It 'returns an empty array when tool_input carries neither file_path nor command' {
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ note = 'nothing usable' })

            $records = ConvertTo-CodexFileEditInput -Payload $payload

            @($records).Count | Should -Be 0
        }

        It 'returns an empty array when the command is whitespace only' {
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = '   ' })

            $records = ConvertTo-CodexFileEditInput -Payload $payload

            @($records).Count | Should -Be 0
        }

        It 'returns an empty array when the command contains no apply_patch file marker' {
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = 'echo hello' })

            $records = ConvertTo-CodexFileEditInput -Payload $payload

            @($records).Count | Should -Be 0
        }
    }

    Context 'ConvertTo-CodexFileEditInput maps direct file_path input' {
        It 'copies every supplied tool_input field onto the emitted record' {
            $toolInput = [pscustomobject]@{
                file_path  = 'src/a.ps1'
                old_string = 'before'
                new_string = 'after'
            }
            $payload = ConvertTo-CodexPayloadObject -ToolName 'Edit' -ToolInput $toolInput

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records.Count | Should -Be 1
            $records[0].file_path | Should -Be 'src/a.ps1'
            $records[0].source_path | Should -Be 'src/a.ps1'
            $records[0].operation | Should -Be 'Edit'
            $records[0].old_string | Should -Be 'before'
            $records[0].new_string | Should -Be 'after'
        }

        It 'records the Write operation name for Write-shaped input' {
            $toolInput = [pscustomobject]@{ file_path = 'src/b.ps1'; content = 'body' }
            $payload = ConvertTo-CodexPayloadObject -ToolName 'Write' -ToolInput $toolInput

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records[0].operation | Should -Be 'Write'
            $records[0].content | Should -Be 'body'
        }
    }

    Context 'ConvertTo-CodexFileEditInput maps apply_patch input' {
        It 'emits the added lines for an Add operation' {
            $command = @(
                '*** Begin Patch'
                '*** Add File: docs/new.md'
                '+first'
                '+second'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records.Count | Should -Be 1
            $records[0].operation | Should -Be 'Add'
            $records[0].file_path | Should -Be 'docs/new.md'
            $records[0].content | Should -Be "first`nsecond"
        }

        It 'excludes unified-diff +++ headers from the added-line text' {
            $command = @(
                '*** Begin Patch'
                '*** Add File: docs/new.md'
                '+++ b/docs/new.md'
                '+kept'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records[0].content | Should -Be 'kept'
        }

        It 'resolves a rename destination into file_path while keeping source_path' {
            $command = @(
                '*** Begin Patch'
                '*** Update File: docs/old.md'
                '*** Move to: docs/renamed.md'
                '@@'
                '+line'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records[0].file_path | Should -Be 'docs/renamed.md'
            $records[0].source_path | Should -Be 'docs/old.md'
        }

        It 'emits empty content for a Delete operation' {
            $command = @(
                '*** Begin Patch'
                '*** Delete File: docs/gone.md'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records[0].operation | Should -Be 'Delete'
            $records[0].content | Should -Be ''
        }

        It 'emits one record per file for a multi-file patch' {
            $command = @(
                '*** Begin Patch'
                '*** Add File: docs/one.md'
                '+one'
                '*** Add File: docs/two.md'
                '+two'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records.Count | Should -Be 2
            $records[0].file_path | Should -Be 'docs/one.md'
            $records[1].file_path | Should -Be 'docs/two.md'
        }
    }

    Context 'Test-CodexGovernedPath anchors on segment boundaries' {
        It 'returns false when the governed path is empty' {
            Test-CodexGovernedPath -Path 'artifacts/orchestration/orchestrator-state.json' -GovernedPath '' |
                Should -BeFalse
        }

        It 'returns false when the candidate path is empty' {
            Test-CodexGovernedPath -Path '' -GovernedPath 'artifacts/orchestration/orchestrator-state.json' |
                Should -BeFalse
        }

        It 'matches an absolute path that ends with the governed path' {
            Test-CodexGovernedPath -Path 'C:/repo/artifacts/state.json' -GovernedPath 'artifacts/state.json' |
                Should -BeTrue
        }

        It 'does not match a path that merely shares a suffix mid-segment' {
            Test-CodexGovernedPath -Path 'repo/xartifacts/state.json' -GovernedPath 'artifacts/state.json' |
                Should -BeFalse
        }
    }

    Context 'Resolve-CodexUpdatedFileContent fails closed with empty content' {
        It 'returns an empty string when the source file does not exist' {
            $missing = Join-Path $script:RepoRoot 'no-such-file-for-codex-mapping-tests.txt'

            Resolve-CodexUpdatedFileContent -SourcePath $missing -Body '' | Should -Be ''
        }

        It 'returns an empty string when the source file cannot be read' {
            # Arrange: the path exists, so the Test-Path guard passes and the read
            # failure is injected at the Get-Content boundary rather than by creating
            # an unreadable temporary file.
            Mock Get-Content { throw 'simulated read failure' }

            # Act
            $result = Resolve-CodexUpdatedFileContent -SourcePath $script:ModulePath -Body ''

            # Assert
            $result | Should -Be ''
            Should -Invoke Get-Content -Times 1 -Exactly
        }

        It 'returns an empty string when a hunk pre-image is absent from the source' {
            $body = @(
                '@@'
                ' a context line that is absent from the module source'
                '-removed line'
                '+added line'
            ) -join "`n"

            Resolve-CodexUpdatedFileContent -SourcePath $script:ModulePath -Body $body | Should -Be ''
        }
    }

    Context 'Resolve-CodexUpdatedFileContent applies hunks in memory' {
        It 'returns the source content unchanged for a hunk that is entirely pre-image' {
            # Arrange: a hunk line carrying no diff marker classifies into both the
            # pre-image and the post-image, so the substitution is a no-op.
            $body = @('@@', '<#') -join "`n"

            # Act
            $result = Resolve-CodexUpdatedFileContent -SourcePath $script:ModulePath -Body $body

            # Assert
            $result | Should -Not -Be ''
            $result | Should -BeLike '*ConvertFrom-CodexPreToolUsePayload*'
        }

        It 'substitutes the post-image when the pre-image is found in the source' {
            $body = @('@@', '-<#', '+<# patched marker') -join "`n"

            $result = Resolve-CodexUpdatedFileContent -SourcePath $script:ModulePath -Body $body

            $result | Should -BeLike '<# patched marker*'
        }
    }

    Context 'ConvertTo-CodexFileEditInput reconstructs governed updates' {
        It 'emits no record for an Update outside the governed path' {
            $command = @(
                '*** Begin Patch'
                '*** Update File: docs/unrelated.md'
                '@@'
                '+line'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload -ResolveUpdateContent -GovernedPath 'artifacts/state.json')

            $records.Count | Should -Be 0
        }

        It 'emits a governed Update record with empty content when reconstruction fails' {
            $command = @(
                '*** Begin Patch'
                '*** Update File: artifacts/state.json'
                '@@'
                '-absent'
                '+present'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload -ResolveUpdateContent -GovernedPath 'artifacts/state.json')

            $records.Count | Should -Be 1
            $records[0].content | Should -Be ''
        }

        It 'emits the added lines for an Update when reconstruction is not requested' {
            $command = @(
                '*** Begin Patch'
                '*** Update File: artifacts/state.json'
                '@@'
                '+added only'
                '*** End Patch'
            ) -join "`n"
            $payload = ConvertTo-CodexPayloadObject -ToolName 'apply_patch' -ToolInput ([pscustomobject]@{ command = $command })

            $records = @(ConvertTo-CodexFileEditInput -Payload $payload)

            $records[0].content | Should -Be 'added only'
        }
    }
}
