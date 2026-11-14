# Coverage Delta ([P6-T7])

Timestamp: 2026-11-03T20-06
Command: values read from `evidence/baseline/baseline-pester-coverage.2026-11-03T12-09.md` ([P0-T6]), `evidence/regression-testing/isolation-single-process.2026-11-03T20-06.md` ([P6-T6]), and `evidence/qa-gates/qa-pester-coverage.2026-11-03T18-44.md` ([P6-T3]); each figure originates in artifacts/pester/powershell-coverage.xml of the named run
EXIT_CODE: 0
Output Summary: Baseline overall line coverage 93.62% ([P0-T6], tests/scripts). Post-change overall line coverage 92.65% ([P6-T6], tests/scripts, current host). Every new .claude/lib/docs/ production file is at or above 85% (lowest Invoke-DocsCommand.ps1 85.91%). All recorded values are at or above 85: PASS. No branch figure is recorded because Pester measures none.

## Overall line coverage (tests/scripts scope)

| Run | covered | missed | percent | >= 85 |
|---|---|---|---|---|
| Baseline [P0-T6] (earlier host) | 21250 | 1448 | 93.62 | yes |
| Post-change [P6-T6] (current host) | 21911 | 1739 | 92.65 | yes |

The two overall figures come from different hosts. On the current host, suites under `tests/scripts/dev-tools`, `tests/scripts/codex-hooks`, `tests/scripts/codex-scripts`, `tests/scripts/claude-hooks`, and `tests/scripts/powershell/PoshQC` fail for host-dependent reasons that are pre-existing on the merge base (`evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`), so the scripts they exercise lose 268 covered lines. Excluding the new docs files, the post-change population is 20982 covered and 1716 missed lines against 21250 and 1448 at baseline; the new docs files add 929 covered and 23 missed lines. No file this branch edits outside `.claude/lib/docs/` is a PowerShell production file.

## Per-file line coverage of new production files ([P6-T3])

| File | covered | missed | percent | >= 85 |
|---|---|---|---|---|
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 119 | 0 | 100 | yes |
| .claude/lib/docs/DocsFinding.psm1 | 88 | 0 | 100 | yes |
| .claude/lib/docs/DocsJson.psm1 | 102 | 0 | 100 | yes |
| .claude/lib/docs/DocsProfile.psm1 | 81 | 0 | 100 | yes |
| .claude/lib/docs/DocsProfileCommands.psm1 | 67 | 2 | 97.1 | yes |
| .claude/lib/docs/DocsSchema.psm1 | 127 | 0 | 100 | yes |
| .claude/lib/docs/DocsSchemaWalk.psm1 | 87 | 0 | 100 | yes |
| .claude/lib/docs/DocsSurface.psm1 | 130 | 0 | 100 | yes |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 128 | 21 | 85.91 | yes |

The [P6-T6] run reports the same per-file figures for these nine files.
