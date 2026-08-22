#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Mermaid validation PreToolUse hook (issue #491).

.DESCRIPTION
    Covers the deny paths (invalid diagram file, invalid Markdown fence, managed
    diagram), the allow paths, the fail-open matrix, the opt-out marker scope, the
    missing-module guard, and the entry-point protocol.

    Diagram fixtures are here-strings assembled into tool-input JSON by a helper, so
    no test hand-escapes JSON and no fixture is a committed diagram file. The on-disk
    read for the managed-diagram gate goes through the hook's named wrapper seam,
    which the relevant tests mock; no test creates a temporary file, starts a process
    other than the deliberately-spawned pwsh of the entry-point context, or sleeps.
#>

Describe 'enforce-mermaid-validation.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-mermaid-validation.ps1").Path
        . $script:UnderTest

        function Get-WriteToolInputJson {
            param(
                [Parameter(Mandatory)][string] $FilePath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $Content
            )
            return ([ordered]@{
                    tool_name  = 'Write'
                    tool_input = [ordered]@{ file_path = $FilePath; content = $Content }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-EditToolInputJson {
            param(
                [Parameter(Mandatory)][string] $FilePath,
                [Parameter(Mandatory)][string] $OldString,
                [Parameter(Mandatory)][string] $NewString
            )
            return ([ordered]@{
                    tool_name  = 'Edit'
                    tool_input = [ordered]@{ file_path = $FilePath; old_string = $OldString; new_string = $NewString }
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    Context 'diagram-file syntax gate' {
        It 'denies a Write of an invalid diagram file naming the defect, the line, and the pointer' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/flow.mmd' -Content @'
flowchart TD
    A --> B
    B ->> C
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -Match '^MERMAID_VALIDATION_BLOCKED:'
            $reason | Should -Match 'InvalidArrowToken'
            $reason | Should -Match 'line 3'
            $reason | Should -Match ([regex]::Escape('.claude/skills/mermaid-diagram/SKILL.md'))
        }

        It 'denies a Write of a diagram file with an unbalanced bracket' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/flow.mermaid' -Content @'
flowchart TD
    A[Start --> B
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'UnbalancedBracket'
        }

        It 'allows a Write of a valid diagram file' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/flow.mmd' -Content @'
flowchart TD
    A[Start] --> B{Choice}
    B -->|yes| C(Done)
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Markdown fence gate' {
        It 'denies a Markdown Write whose fenced block is invalid and reports the file line' {
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
# Notes

```mermaid
flowchart TD
    A[Start --> B
```
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -Match 'UnbalancedBracket'
            $reason | Should -Match 'line 5'
            $reason | Should -Match 'fence opening at line 3'
        }

        It 'allows a Markdown Write whose fenced block is valid' {
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
# Notes

```mermaid
flowchart TD
    A --> B
```
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a Markdown Write carrying no Mermaid fence at all' {
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
# Notes

```powershell
Get-ChildItem
```
'@
            Invoke-MermaidValidationDecision -ToolInputRaw $json | Should -BeNullOrEmpty
        }

        It 'leaves a path outside the Mermaid scope untouched' {
            $json = Get-WriteToolInputJson -FilePath 'scripts/dev-tools/Invoke-Thing.ps1' -Content @'
flowchart TD
    A[Start --> B
'@
            Invoke-MermaidValidationDecision -ToolInputRaw $json | Should -BeNullOrEmpty
        }

        It 'allows an invalid Mermaid fence nested inside an outer fence' {
            # Fail-open item 6: documentation showing example Mermaid is not a diagram.
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
# Notes

````markdown
```mermaid
flowchart TD
    A[Start --> B
```
````
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'opt-out marker scope' {
        It 'allows an invalid block carrying the opt-out marker on the preceding line' {
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
<!-- mermaid-validator: ignore -->
```mermaid
flowchart TD
    A[Start --> B
```
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'still denies a second unmarked invalid block in the same Write' {
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
<!-- mermaid-validator: ignore -->
```mermaid
flowchart TD
    A[Start --> B
```

```mermaid
flowchart TD
    C{Choice --> D
```
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'fence opening at line 7'
        }

        It 'does not honour a marker separated from the fence by a blank line' {
            $json = Get-WriteToolInputJson -FilePath 'docs/notes.md' -Content @'
<!-- mermaid-validator: ignore -->

```mermaid
flowchart TD
    A[Start --> B
```
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'managed-diagram gate' {
        BeforeEach {
            Mock -CommandName Get-MermaidOnDiskContent -MockWith {
                @'
---
id: 8f2c1a90-managed
title: Managed flow
---
flowchart LR
    A --> B
'@
            }
        }

        It 'denies an Edit of a managed diagram file' {
            $json = Get-EditToolInputJson -FilePath 'docs/diagrams/managed.mmd' -OldString 'A --> B' -NewString 'A --> C'
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -Match '^MERMAID_MANAGED_DIAGRAM_BLOCKED:'
            $reason | Should -Match 'sync'
        }

        It 'denies a Write of a managed diagram file even when the new content is valid' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/managed.mmd' -Content @'
flowchart LR
    A --> C
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^MERMAID_MANAGED_DIAGRAM_BLOCKED:'
        }

        It 'reads the target file exactly once through the wrapper seam' {
            $json = Get-EditToolInputJson -FilePath 'docs/diagrams/managed.mmd' -OldString 'A' -NewString 'B'
            $null = Invoke-MermaidValidationDecision -ToolInputRaw $json
            Should -Invoke -CommandName Get-MermaidOnDiskContent -Times 1 -Exactly
        }
    }

    Context 'unmanaged on-disk diagram' {
        It 'allows an Edit when the on-disk frontmatter carries no id marker' {
            Mock -CommandName Get-MermaidOnDiskContent -MockWith {
                @'
---
title: Unmanaged flow
---
flowchart LR
    A --> B
'@
            }
            $json = Get-EditToolInputJson -FilePath 'docs/diagrams/plain.mmd' -OldString 'A --> B' -NewString 'A ->> B'
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an Edit when the target file does not exist on disk' {
            Mock -CommandName Get-MermaidOnDiskContent -MockWith { $null }
            $json = Get-EditToolInputJson -FilePath 'docs/diagrams/new.mmd' -OldString 'A' -NewString 'B'
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'envelope anomalies fail closed (issue #501)' {
        It 'denies an empty tool input' {
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'MERMAID_VALIDATION_BLOCKED'
        }

        It 'denies an absent tool input' {
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $null
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies an unparseable tool input' {
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw 'this is not json {'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $json = '{"file_path":"docs/diagrams/flow.mmd","content":"flowchart TD"}'
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }
    }

    Context 'content-level tolerance is preserved' {
        It 'allows a well-formed tool_input with no file_path field' {
            $json = '{"tool_name":"Write","tool_input":{"content":"flowchart TD\n    A[Start --> B\n"}}'
            Invoke-MermaidValidationDecision -ToolInputRaw $json | Should -BeNullOrEmpty
        }

        It 'allows a well-formed tool_input whose file_path is an empty string' {
            $json = '{"tool_name":"Write","tool_input":{"file_path":"","content":"flowchart TD\n    A[Start --> B\n"}}'
            Invoke-MermaidValidationDecision -ToolInputRaw $json | Should -BeNullOrEmpty
        }

        It 'allows an Edit payload whose diagram content cannot be reconstructed' {
            # Fail-open item 4: old_string/new_string is a fragment, not the file.
            Mock -CommandName Get-MermaidOnDiskContent -MockWith { $null }
            $json = Get-EditToolInputJson -FilePath 'docs/diagrams/flow.mmd' -OldString 'A --> B' -NewString 'A ->> B'
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an Edit payload targeting a Markdown file' {
            $json = Get-EditToolInputJson -FilePath 'docs/notes.md' -OldString 'A --> B' -NewString 'A[Start --> B'
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'missing-module guard' {
        BeforeEach {
            $script:SavedModulePath = $script:MermaidModulePath
            $script:MermaidModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'MermaidValidation.absent-fixture.psm1'
        }

        AfterEach {
            $script:MermaidModulePath = $script:SavedModulePath
        }

        It 'fails open when the validation module is absent from disk' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/flow.mmd' -Content @'
flowchart TD
    A[Start --> B
'@
            Invoke-MermaidValidationDecision -ToolInputRaw $json | Should -BeNullOrEmpty
        }
    }

    Context 'negative control' {
        It 'negative control: the gate rejects a deliberately invalid diagram through the decision path' {
            # Proves the gate is capable of failing. A gate that cannot deny is
            # indistinguishable from no gate, so this case is asserted explicitly
            # rather than inferred from the deny cases above.
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/negative-control.mmd' -Content @'
flowchart TD
    A[Start --> B
    B ->> C
'@
            $decision = Invoke-MermaidValidationDecision -ToolInputRaw $json
            $decision | Should -Not -BeNullOrEmpty
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'MERMAID_VALIDATION_BLOCKED'
        }
    }

    Context 'script entrypoint (no child process)' {
        It 'emits compact deny JSON and returns exit code 0 for an invalid diagram file' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/entry.mmd' -Content @'
flowchart TD
    A[Start --> B
'@
            $out = Invoke-MermaidValidationEntryPoint -ToolInputRaw $json

            $out | Should -Not -Match "`n"
            $parsed = $out | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'MERMAID_VALIDATION_BLOCKED'
        }

        It 'emits compact allow JSON for a valid diagram file' {
            $json = Get-WriteToolInputJson -FilePath 'docs/diagrams/entry.mmd' -Content @'
flowchart TD
    A[Start] --> B
'@
            $parsed = Invoke-MermaidValidationEntryPoint -ToolInputRaw $json | ConvertFrom-Json

            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'emits nothing for an out-of-scope path' {
            $json = Get-WriteToolInputJson -FilePath 'scripts/foo.txt' -Content 'plain text'

            Invoke-MermaidValidationEntryPoint -ToolInputRaw $json | Should -BeNullOrEmpty
        }

        It 'reads the payload through the shared reader' {
            $hookText = Get-Content -Path $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }
    }
}
