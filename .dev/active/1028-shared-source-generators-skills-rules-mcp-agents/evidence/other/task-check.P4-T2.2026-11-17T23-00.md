# Task Check — [P4-T2]

Timestamp: 2026-11-17T23-00
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-rulesrc.ps1 -Write; sh SCRATCH/issue-1028-gen.sh rules check
EXIT_CODE: 0 for the source build. The read-only check exits 1, which is expected before [P4-T3]'s write run.
Output Summary: `Get-HarnessRuleFileMap` renders all 40 source files (20 pairs) without throwing. It produces 108 files and 0 findings, so every selected target has a source and every source passes validation, including the `claudeUnconditional` and `paths` rules. `-Surface rules -Check` reports exactly 8 `DRIFT` lines and nothing else: the four Copilot normalizations listed in `evidence/qa-gates/rule-sources.2026-11-17T23-00.md` and their bundle copies. The other 100 rendered files equal the tree.

Changed files: `scripts/harness-generation/sources/rules/*.json` and `*.md` (40 new data files) and `evidence/qa-gates/rule-sources.2026-11-17T23-00.md`.
Selection rule: `## Test Cadence (Mandatory)`. The task adds data files only, and no test reads `sources/rules/`. The check is the generator's own validation, run through the read-only `-Check` path. [P4-T3] runs the rule-wording suites after the write.
