# Self-Hosted Verification That the New `CodeCoverage.Path` Entries Take Effect (issue #554)

Timestamp: 2026-08-26T11-30

Command:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

EXIT_CODE: 0

The MCP PoshQC test runner (`mcp__drm-copilot__run_poshqc_test`) was **not** used for this
verification. It reads its settings from the **installed extension**, so it would consume the
bundled settings file shipped with the last installed build and ignore the two `CodeCoverage.Path`
entries added by P4-T5. The self-hosted invocation above reads
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from this checkout, which is the file
the entries were added to, so it is the only invocation that can observe them.

**One mechanical deviation from the command as written in the plan, recorded rather than silently
applied.** The module path is prefixed `./`. `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`
without the prefix is interpreted by PowerShell as a module *name* to resolve against `PSModulePath`
rather than as a path, and fails with `no valid module file was found in any module directory`. The
`./` prefix makes it a path. Nothing else about the command changed, and the `-SettingsPath` argument
is passed verbatim as the plan states it.

Output Summary:

| Metric | Value |
| --- | --- |
| Tests passed | **3799** |
| Tests failed | **0** |
| Tests skipped | 9 |
| Overall line coverage | **93.73%** |
| Analyzed commands | 10,525 |
| Measured files | **88** |

## Both New Production Hook Files Appear as Measured Files

Read from the JaCoCo coverage report `artifacts/pester/powershell-coverage.xml` produced by the run,
attributing each `sourcefile` to its `package` so the two surfaces are distinguished (the JaCoCo
`sourcefile` name is a bare basename and is identical on both surfaces):

| Measured file | Instrumented lines | **Covered lines** | Per-file line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 132 | **130** | 98.48% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 132 | **108** | 81.82% |

Both new production files are named in the report with a numeric per-file covered-line count, which
is the acceptance condition for this task. Their presence is the direct proof that the two entries
added by P4-T5 took effect: `CodeCoverage.Path` is an explicit per-file allow-list with no directory
wildcard for either hooks tree, so an unregistered file cannot appear in the report at all.

The four already-registered sibling files in the same hook family, recorded for context:

| Measured file | Instrumented lines | Covered lines | Per-file line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 150 | 121 | 80.67% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 162 | 133 | 82.10% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 118 | 112 | 94.92% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 118 | 112 | 94.92% |

## Measured-File Count Reconciliation

The settings file lists **89** `CodeCoverage.Path` entries and the report measures **88** files. The
difference is a pre-existing duplicate: `.claude/hooks/enforce-pr-author-skill.ps1` is listed twice,
once under the issue #272 comment block and once under the issue #275 block. Eighty-nine entries with
one duplicate resolve to eighty-eight distinct files, so every registered entry — including both new
ones — is measured. The duplicate predates this change and is not touched by it.

## Threshold Note

The repository line-coverage threshold in `.claude/rules/quality-tiers.md` is an aggregate metric, and
the aggregate is **93.73%**, above the 85% floor. Pester measures no branch coverage, so no
branch-coverage gate applies. The per-file percentages above are recorded for the Phase 6 coverage
delta (P6-T6), which is where the changed-line condition for the two modified gate hooks is
evaluated; they are not themselves a gate at this task.
