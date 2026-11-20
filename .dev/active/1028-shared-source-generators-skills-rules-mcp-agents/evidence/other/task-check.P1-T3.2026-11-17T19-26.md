# Task Check — [P1-T3]

Timestamp: 2026-11-17T19-26
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-psstatic.ps1 -Mode both -FolderList 'scripts/harness-generation;tests/scripts/harness-generation'; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/harness-generation/HarnessInstructions.Tests.ps1
EXIT_CODE: 0
Output Summary: Format: 8 files, 0 would change. Analyze: 0 findings, 0 errors; one same-file retry after the transient PSScriptAnalyzer `NullReferenceException` recorded in the [P1-T2] task check. Pester selection: 15 tests passed, 0 failed, launcher exit 0. There is one failing-input case per finding kind (CONVERTER-HEADING, GENERATED-NOTE, EMBEDDED-RULE, MISSING-SKILL, CLAUDE-IMPORT, DUPLICATE-SECTION, BUNDLE-DRIFT, and COVERAGE-THRESHOLD as an `AGENTS.md` line stating a line-coverage minimum in percent) and one passing pair. Selection-only line coverage of `HarnessInstructions.psm1` is 100.00% (informational). The module has 157 lines, at or below 500.

Changed files: `scripts/harness-generation/HarnessInstructions.psm1` (new), `tests/scripts/harness-generation/HarnessInstructions.Tests.ps1` (new).
Selection rule: `## Test Cadence (Mandatory)`; the mirrored suite of the new production file.
Informational: `-Surface instructions -Check` on the current tree exits 1 with 33 findings. These are the converter heading, two coverage-threshold lines, 21 embedded rule sections, 9 missing skill citations and the missing `@AGENTS.md` import. That is the state [P1-T4] changes.
