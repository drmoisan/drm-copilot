# Task Check P1-T17

Timestamp: 2026-11-19T10-36
Plan: plan.2026-10-30T18-39.md
Changed files: new `GUARD-SUITE` `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` (322 lines). `It` blocks `CLR-SKILL-TREES-ABSENT`, `CLR-BRIEF-COUNT`, `CLR-READ-FIRST`, `CLR-COPILOT-INSTRUCTIONS`, `CLR-COLLISION-CONTROLS`, `CLR-AGENT-FILES`, `CLR-CURRENT-DOCS`, `CLR-PACK-MANIFESTS`, each with a `-REJECTS` case that feeds in-memory text breaking the rule. Each check is a pure function over text supplied by the reader seams `Read-ClrText` and `Get-ClrFileUnder`, which read files only; the retired path is built at runtime from its two parts; paths are built with `Join-Path` and forward-slash relative paths; the functions are removed in `AfterAll`.
Selection rule: the new suite itself.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| PSSA and formatter comparison (SCRATCH helper) | 0 | 0 findings; 0 files differ |
| Grep for RETIRED-PATH in the suite | 0 | 0 matches |
| `wc -l` | 0 | 322 lines (under 500) |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` | 0 | Invoke-PoshQCParallelTest exit code 0; Tests Passed 16, Failed 0 (every `-REJECTS` case included); five earlier attempts exited 75 (queue timeout) |
