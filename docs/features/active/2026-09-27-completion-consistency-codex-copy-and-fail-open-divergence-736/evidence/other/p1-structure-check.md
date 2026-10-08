# Phase 1 structure check ([P1-T1] through [P1-T11])

Timestamp: 2026-10-08T17-49
Command: grep -c -E "TestDrive|New-TemporaryFile|env:TEMP|Set-Location|Push-Location|Start-Sleep|GetTempPath|Out-File|Set-Content|New-Item" <ten test files>
EXIT_CODE: 0
Output Summary: the nine files other than the transport suite print `<path>:0`; the transport suite prints `codex-pretooluse-transport.Tests.ps1:6` (the six pre-existing payload literals). Exit 0 because the transport count is non-zero.

Command: grep -c -F "It '" <seven new test files>
EXIT_CODE: 0
Output Summary: EditSemantics 15, FailClosed 13, DefaultReader 7 (Claude); edit-target 16, edit-semantics 15, fail-closed 13, default-reader 7 (Codex).

Command: wc -l <ten test files>
EXIT_CODE: 0
Output Summary: new files 273, 240, 152, 279, 274, 239, 153 (each at most 450); enforce-completion-consistency.Tests.ps1 491 (at most 491); enforce-completion-consistency.EditTarget.Tests.ps1 231 (at most 500); codex-pretooluse-transport.Tests.ps1 450 (fewer than 492).

Edit-row acceptance greps (all as specified in [P1-T4], [P1-T5], [P1-T10]):
- "denies an Edit when the on-disk checkpoint file does not exist" in the main Claude suite: 1
- "denies an Edit when old_string is not found in the on-disk content" in the main Claude suite: 1
- "as checkpoint-empty when the injected reader returns an empty string" in the main Claude suite: 1
- "denies an Edit that supplies no old_string" in the EditTarget suite: 1
- "ObservedReaderPath" in the transport suite: 0
- "returns null edited content" in the transport suite: 0
- "applies the old_string to new_string replacement in memory" in the transport suite: 0
