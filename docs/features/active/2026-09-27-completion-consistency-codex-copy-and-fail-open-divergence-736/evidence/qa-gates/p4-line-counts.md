# Line-count gate ([P4-T3])

Timestamp: 2026-10-08T18-01
Command: wc -l <four canonical hooks and four bundled mirrors> ; wc -l <ten test files>
EXIT_CODE: 0
Output Summary: production files and mirrors: 465, 486, 268, 268 (canonical) and 465, 268, 486, 268 (mirrors), each at most 500. Test files: new files 273, 240, 152, 279, 274, 239, 153 (each at most 450); enforce-completion-consistency.Tests.ps1 491 (at most 491); enforce-completion-consistency.EditTarget.Tests.ps1 231 (at most 500); codex-pretooluse-transport.Tests.ps1 450 (fewer than 492).
