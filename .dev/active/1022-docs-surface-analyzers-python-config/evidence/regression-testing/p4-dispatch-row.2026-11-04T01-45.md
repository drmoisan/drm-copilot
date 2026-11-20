# [P4-T5] Dispatch row under the 1022 anchor and the CLI context (issue #1022)

Timestamp: 2026-11-04T01-45
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1,tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 -CoverageFile .claude/lib/docs/Invoke-DocsCommand.ps1,.claude/lib/docs/DocsInventory.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the two files; one process)
EXIT_CODE: 0
Output Summary: 59 passed, 0 failed, 0 errored, 0 skipped (result object Passed=59 Failed=0 Skipped=0; JUnit well-formed, counts read from it). Per suite: `DocsInventory.Tests.ps1` 13 passed (8 from [P4-T4] plus the five `It`s of the new `Context 'through Invoke-DocsCommandCli'`); `Invoke-DocsCommand.Tests.ps1` 46 passed, unchanged. Line execution: `.claude/lib/docs/DocsInventory.psm1` 100 of 100 (100%); `.claude/lib/docs/Invoke-DocsCommand.ps1` 132 of 151 (87.42%; the 19 missed lines are the pre-existing 1020 `Invoke-DocsProcess` and `Write-DocsFileText` bodies that the 1020 suite documents as not executed by tests; the added row line inside `Get-DocsCommandTable` executes).

## Numstat against MERGE_BASE

- `MERGE_BASE` derivation: `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`.
- Command: `git diff --numstat MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1`
- EXIT_CODE: 0
- Output: `1	0	.claude/lib/docs/Invoke-DocsCommand.ps1` (1 added, 0 deleted; the added line is the `inventory` row of spec `### Registration (1020 anchors)` directly under `# --- 1022: inventory ---`, with `Option` `Profile` `value`, `Analyzer` `multi`, `Revision` `value`, `Write` `switch`).

## Toolchain

- Formatter: `Already formatted:` for `.claude/lib/docs/Invoke-DocsCommand.ps1` and `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1`; 0 files rewritten.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files.
- Physical line counts: `Invoke-DocsCommand.ps1` 463 (462 at `MERGE_BASE`); `DocsInventory.Tests.ps1` 341.

## Existing-test disposition (from [P0-T3])

- `Invoke-DocsCommand.Tests.ps1`: unchanged (table validity, anchor order, 1020 exit codes, envelope keys); 46 passed with the row present.

## Behavior covered by the new `Context 'through Invoke-DocsCommandCli'`

- The dispatch table carries exactly one `inventory` row with `Invoke-DocsInventoryCommand`, an existing module path and the four options; `Test-DocsCommandTable` returns no finding.
- Every exit path runs through `Invoke-DocsCommandCli -Command inventory ... -Json` with the 1020 in-memory context and the fixed clock, and every `-Json` envelope is validated through `ENVELOPE_ROUTE` (`Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` with the composed schema set, `.Count` on the returned value equal to 0; validity only, never message text), with `command` `inventory`, `exit_code` equal to the outcome and `ok` true only on exit 0: exit 0 (dry run, `written` false, the fixed clock); exit 1 for a blocking `YAML_INVALID` (`DOCS_INVENTORY_BLOCKING_DIAGNOSTIC`, snapshot returned), an absent profile (`DOCS_PROFILE_MISSING`, `result` null) and an invalid profile (`result` null); exit 2 with `result` null and `DOCS_CLI_ARGUMENTS` for `-Analyzer not-registered`, `-Analyzer python-cli` with a `config-key`-only profile, `-Revision abc` and `-Profile C:/abs.json`; exit 3 with `result` null, `DOCS_CLI_RUNTIME` and the one stderr line for the exceeded byte bound and a read failure; `-Revision` recorded and `-Write` making the `create` then `overwrite` `WriteText` calls, with a later dry run adding none.

## Acceptance criteria checked off

- spec S14 and user-story U10 (exit 0, 1, 2 and 3 for the listed conditions, each asserted through `Invoke-DocsCommandCli` with the 1020 in-memory context and a fixed clock, `DOCS_CLI_ARGUMENTS` naming the value with `result` null, `DOCS_CLI_RUNTIME` for the bound and the read failure): proven by [P4-T4] and this task.
- spec S15 (the `-Json` output of every `inventory` exit path validates against `schemas/docs/v1/docs-command-envelope.schema.json`): proven by this task.

CI: `poshqc / PowerShell QC` (windows-latest shards).
